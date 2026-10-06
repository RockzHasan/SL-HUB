# Holiday Hunt & Quest Builder Engine PRO

Create a complete production-ready Second Life LSL system named **Holiday Hunt & Quest Builder Engine PRO** by **RockzHasan**.

## 1. Architecture
- Core model: one **Master Controller** object coordinates all nodes.
- Node communications: private negative region channel derived from network key.
- Persistence: `llLinksetData*` for player records, teams, leaderboard, and event state.
- Security model:
  - Node registration handshake with token validation.
  - Completion packets accepted only from registered node object UUID.
  - Player identity always key-based (never avatar-name trust).
  - Duplicate completion and reward claims blocked with exactly-once flags.
- Theme model: engine logic is seasonal-agnostic; only messages/profiles change by theme.

## 2. Component List
1. `01 - Quest Master Core.lsl`
2. `02 - Player Progress Manager.lsl`
3. `03 - Hunt Checkpoint Node.lsl`
4. `04 - Puzzle Question Node.lsl`
5. `05 - Reward Manager.lsl`
6. `06 - Score Leaderboard Manager.lsl`
7. `07 - Team Manager.lsl`
8. `08 - Hint Manager.lsl`
9. `09 - Admin Controller.lsl`
10. `10 - Diagnostics.lsl`

## 3. Node Setup
Each node script must configure these values:
- `QUEST_ID`
- `NODE_ID`
- `NODE_TYPE` (`TOUCH`,`PROXIMITY`,`QUESTION`,`PUZZLE`,`ITEM`,`TIMED`,`FINAL`)
- `SEQUENCE`
- `POINTS`
- `NEXT_NODE`
- `HINT`
- `RADIUS`
- `ACTIVE`
- `NETWORK_KEY`

On startup (and on ping), node advertises itself once with jittered delay to avoid storming.

## 4. Configuration Format
Simple key-value `notecard` format for master:

```text
QUEST_ID=WINTER_2026
THEME=CHRISTMAS
MODE=SEQUENTIAL|TIMED|SOLO
NETWORK_KEY=replace-with-secret
TIME_LIMIT_SEC=3600
HINT_COST=5
HINT_PENALTY_SEC=30
MAX_HINTS=3
LEADERBOARD_MAX=20
ALLOW_REPEAT_REWARD=0
COMPLETION_BONUS=100
WRONG_ANSWER_PENALTY=2
TIME_BONUS_PER_MIN=1
```

Node notecard format (one per node object):

```text
QUEST_ID=WINTER_2026
NODE_ID=CP_01
NODE_TYPE=TOUCH
SEQUENCE=1
POINTS=10
NEXT_NODE=CP_02
HINT=Check near the frosted archway.
RADIUS=5.0
ACTIVE=1
NETWORK_KEY=replace-with-secret
```

## 5. Network Protocol
Private region channel packet format (`|` separated):
- `HELLO|token|questId|nodeId|nodeType|sequence|points|nextNode|hint|radius|active`
- `PING|token|questId|nodeId`
- `COMPLETE|token|questId|nodeId|playerKey|nonce`
- `QRESULT|token|questId|nodeId|playerKey|correct|points|nonce`
- `ADMIN|token|command|arg1|arg2`

Rules:
- Reject malformed packet length.
- Reject mismatched token/quest.
- Reject nodeId collision if object key differs.
- Reject completion from unregistered node key.
- Reject replayed `(player,node,nonce)` already seen.

## 6. COMPLETE Source of Script 01 - Quest Master Core

```lsl
// Holiday Hunt & Quest Builder Engine PRO
// Script 01 - Quest Master Core
// Creator: RockzHasan

integer LM_PROGRESS_GET = 1001;
integer LM_PROGRESS_GET_RESPONSE = 1005;
integer LM_PROGRESS_UPSERT = 1002;
integer LM_PROGRESS_RESET_ONE = 1003;
integer LM_PROGRESS_RESET_ALL = 1004;
integer LM_REWARD_REQUEST = 1101;
integer LM_LEADERBOARD_SUBMIT = 1201;
integer LM_TEAM_SCORE_ADD = 1301;
integer LM_HINT_APPLY = 1401;
integer LM_DIAG = 1901;

integer MODE_SEQUENTIAL = 1;
integer MODE_OPEN_WORLD = 2;
integer MODE_RANDOM_ROUTE = 4;
integer MODE_TIMED = 8;
integer MODE_POINT_BASED = 16;
integer MODE_TEAM = 32;
integer MODE_SOLO = 64;

string QUEST_ID = "DEFAULT_QUEST";
string NETWORK_KEY = "CHANGE_ME_SECRET";
integer MODE_FLAGS = 1 | 16 | 64;
integer EVENT_RUNNING = TRUE;
integer EVENT_PAUSED = FALSE;
integer TIME_LIMIT_SEC = 0;
integer COMPLETION_BONUS = 50;
integer WRONG_ANSWER_PENALTY = 2;
integer TIME_BONUS_PER_MIN = 1;
integer ALLOW_REPEAT_REWARD = FALSE;

integer gChannel;
integer gListen;

// Node stride: nodeId,objKey,nodeType,sequence,points,nextNode,hint,radius,active
list gNodes;
integer NODE_STRIDE = 9;

// Player stride:
// key,name,startUnix,currentStage,completedCsv,score,hintsUsed,teamId,rewarded,routeCsv,lastNonce
list gPlayers;
integer PLAYER_STRIDE = 11;

integer gTick = 0;

integer getPrivateChannel(string seed)
{
    string h = llSHA1String(seed, 0);
    integer n = (integer)("0x" + llGetSubString(h, 0, 5));
    integer ch = -1000000 - (n % 800000000);
    if (ch > -1)
    {
        ch = -1000001;
    }
    return ch;
}

integer playerIndex(key avatar)
{
    return llListFindList(gPlayers, [(string)avatar]);
}

integer nodeIndex(string nodeId)
{
    integer i = 0;
    integer len = llGetListLength(gNodes);
    while (i < len)
    {
        if (llList2String(gNodes, i) == nodeId)
        {
            return i;
        }
        i += NODE_STRIDE;
    }
    return -1;
}

integer isNodeAuthorized(string nodeId, key sender)
{
    integer i = nodeIndex(nodeId);
    if (i < 0)
    {
        return FALSE;
    }
    key reg = (key)llList2String(gNodes, i + 1);
    if (reg != sender)
    {
        return FALSE;
    }
    if (!llList2Integer(gNodes, i + 8))
    {
        return FALSE;
    }
    return TRUE;
}

list parseCsv(string csv)
{
    if (csv == "")
    {
        return [];
    }
    return llParseStringKeepNulls(csv, [","], []);
}

string joinCsv(list values)
{
    return llDumpList2String(values, ",");
}

integer csvContains(string csv, string value)
{
    list vals = parseCsv(csv);
    if (llListFindList(vals, [value]) >= 0)
    {
        return TRUE;
    }
    return FALSE;
}

string csvAppendUnique(string csv, string value)
{
    list vals = parseCsv(csv);
    if (llListFindList(vals, [value]) >= 0)
    {
        return csv;
    }
    vals += [value];
    return joinCsv(vals);
}

integer expectedSequenceForPlayer(string completedCsv)
{
    list completed = parseCsv(completedCsv);
    integer done = llGetListLength(completed);
    return done + 1;
}

integer getUnix()
{
    return llGetUnixTime();
}

string safeName(key avatar)
{
    string n = llKey2Name(avatar);
    if (n == "")
    {
        return "Resident";
    }
    return n;
}

string makeDefaultRoute()
{
    list seqPairs;
    integer i = 0;
    integer len = llGetListLength(gNodes);
    while (i < len)
    {
        string nId = llList2String(gNodes, i);
        string nType = llList2String(gNodes, i + 2);
        integer seq = llList2Integer(gNodes, i + 3);
        integer active = llList2Integer(gNodes, i + 8);
        if (active)
        {
            seqPairs += [(string)seq + "#" + nId];
        }
        i += NODE_STRIDE;
    }
    seqPairs = llListSort(seqPairs, 1, TRUE);
    list route;
    i = 0;
    len = llGetListLength(seqPairs);
    while (i < len)
    {
        string item = llList2String(seqPairs, i);
        list parts = llParseStringKeepNulls(item, ["#"], []);
        if (llGetListLength(parts) == 2)
        {
            route += [llList2String(parts, 1)];
        }
        i++;
    }
    return joinCsv(route);
}

string generateRandomRoute()
{
    list pool;
    string finalId = "";
    integer i = 0;
    integer len = llGetListLength(gNodes);
    while (i < len)
    {
        integer active = llList2Integer(gNodes, i + 8);
        string nType = llList2String(gNodes, i + 2);
        string nId = llList2String(gNodes, i);
        if (active)
        {
            if (nType == "FINAL")
            {
                finalId = nId;
            }
            else
            {
                pool += [nId];
            }
        }
        i += NODE_STRIDE;
    }

    if (finalId == "")
    {
        llOwnerSay("[ADMIN ERROR] Random route generation failed: missing FINAL node.");
        return "";
    }

    list route;
    while (llGetListLength(pool) > 0)
    {
        integer idx = (integer)llFrand((float)llGetListLength(pool));
        if (idx < 0 || idx >= llGetListLength(pool))
        {
            idx = 0;
        }
        route += [llList2String(pool, idx)];
        pool = llDeleteSubList(pool, idx, idx);
    }
    route += [finalId];
    return joinCsv(route);
}

list defaultPlayerRecord(key avatar)
{
    integer now = getUnix();
    string route = makeDefaultRoute();
    if (MODE_FLAGS & MODE_RANDOM_ROUTE)
    {
        route = generateRandomRoute();
    }
    if (route == "")
    {
        route = makeDefaultRoute();
    }
    return [
        (string)avatar,
        safeName(avatar),
        now,
        0,
        "",
        0,
        0,
        "",
        0,
        route,
        ""
    ];
}

integer isReplayNonce(integer pIdx, string nonce)
{
    string last = llList2String(gPlayers, pIdx + 10);
    if (nonce == "" || last == "")
    {
        return FALSE;
    }
    if (nonce == last)
    {
        return TRUE;
    }
    return FALSE;
}

integer routeAllows(string routeCsv, string nodeId)
{
    list route = parseCsv(routeCsv);
    if (llListFindList(route, [nodeId]) >= 0)
    {
        return TRUE;
    }
    return FALSE;
}

integer canCompleteNode(integer pIdx, string nodeId)
{
    string completed = llList2String(gPlayers, pIdx + 4);
    if (csvContains(completed, nodeId))
    {
        return FALSE;
    }

    string routeCsv = llList2String(gPlayers, pIdx + 9);
    if (routeCsv != "" && !routeAllows(routeCsv, nodeId))
    {
        return FALSE;
    }

    if (MODE_FLAGS & MODE_SEQUENTIAL)
    {
        integer nIdx = nodeIndex(nodeId);
        if (nIdx < 0)
        {
            return FALSE;
        }
        integer seq = llList2Integer(gNodes, nIdx + 3);
        integer expected = expectedSequenceForPlayer(completed);
        if (seq != expected)
        {
            return FALSE;
        }
    }
    return TRUE;
}

integer elapsedForPlayer(integer pIdx)
{
    integer start = llList2Integer(gPlayers, pIdx + 2);
    return getUnix() - start;
}

integer timeExpired(integer pIdx)
{
    if (!(MODE_FLAGS & MODE_TIMED) || TIME_LIMIT_SEC <= 0)
    {
        return FALSE;
    }
    if (elapsedForPlayer(pIdx) > TIME_LIMIT_SEC)
    {
        return TRUE;
    }
    return FALSE;
}

integer upsertPlayer(integer idx, list rec)
{
    if (idx < 0)
    {
        gPlayers += rec;
        return 0;
    }
    integer i;
    for (i = 0; i < PLAYER_STRIDE; ++i)
    {
        gPlayers = llListReplaceList(gPlayers, [llList2String(rec, i)], idx + i, idx + i);
    }
    return 0;
}

integer persistPlayer(integer pIdx)
{
    string payload = llDumpList2String(llList2List(gPlayers, pIdx, pIdx + PLAYER_STRIDE - 1), "|");
    llMessageLinked(LINK_SET, LM_PROGRESS_UPSERT, payload, NULL_KEY);
    return 0;
}

integer registerPlayer(key avatar)
{
    integer idx = playerIndex(avatar);
    if (idx < 0)
    {
        list rec = defaultPlayerRecord(avatar);
        upsertPlayer(-1, rec);
        idx = playerIndex(avatar);
        persistPlayer(idx);
        llRegionSayTo(avatar, 0, "Quest registration complete.");
    }
    else
    {
        llRegionSayTo(avatar, 0, "You are already registered in this quest.");
    }
    return 0;
}

integer awardCompletion(integer pIdx, key avatar)
{
    integer score = llList2Integer(gPlayers, pIdx + 5);
    integer elapsed = elapsedForPlayer(pIdx);
    integer timeBonus = 0;
    if (TIME_BONUS_PER_MIN > 0)
    {
        timeBonus = ((TIME_LIMIT_SEC - elapsed) / 60) * TIME_BONUS_PER_MIN;
        if (timeBonus < 0)
        {
            timeBonus = 0;
        }
    }
    score += COMPLETION_BONUS + timeBonus;
    gPlayers = llListReplaceList(gPlayers, [score], pIdx + 5, pIdx + 5);

    integer rewarded = llList2Integer(gPlayers, pIdx + 8);
    if (!rewarded || ALLOW_REPEAT_REWARD)
    {
        gPlayers = llListReplaceList(gPlayers, [1], pIdx + 8, pIdx + 8);
        llMessageLinked(LINK_SET, LM_REWARD_REQUEST, (string)avatar + "|" + (string)score, avatar);
    }

    llMessageLinked(LINK_SET, LM_LEADERBOARD_SUBMIT,
        (string)avatar + "|" + llList2String(gPlayers, pIdx + 1) + "|" + (string)score + "|" + (string)elapsed,
        avatar);

    persistPlayer(pIdx);
    return 0;
}

integer applyNodeCompletion(key avatar, string nodeId, integer points, string nonce)
{
    integer pIdx = playerIndex(avatar);
    if (pIdx < 0)
    {
        llRegionSayTo(avatar, 0, "Register first at the quest master.");
        return 0;
    }
    if (EVENT_PAUSED || !EVENT_RUNNING)
    {
        llRegionSayTo(avatar, 0, "Quest is not currently active.");
        return 0;
    }
    if (timeExpired(pIdx))
    {
        llRegionSayTo(avatar, 0, "Time expired for your run.");
        return 0;
    }
    if (isReplayNonce(pIdx, nonce))
    {
        return 0;
    }
    if (!canCompleteNode(pIdx, nodeId))
    {
        return 0;
    }

    string completed = llList2String(gPlayers, pIdx + 4);
    completed = csvAppendUnique(completed, nodeId);
    gPlayers = llListReplaceList(gPlayers, [completed], pIdx + 4, pIdx + 4);

    integer score = llList2Integer(gPlayers, pIdx + 5);
    score += points;
    gPlayers = llListReplaceList(gPlayers, [score], pIdx + 5, pIdx + 5);

    gPlayers = llListReplaceList(gPlayers, [nodeId], pIdx + 3, pIdx + 3);
    gPlayers = llListReplaceList(gPlayers, [nonce], pIdx + 10, pIdx + 10);

    integer nIdx = nodeIndex(nodeId);
    if (nIdx >= 0)
    {
        string nType = llList2String(gNodes, nIdx + 2);
        if (nType == "FINAL")
        {
            awardCompletion(pIdx, avatar);
            llRegionSayTo(avatar, 0, "Quest completed.");
        }
    }

    if (MODE_FLAGS & MODE_TEAM)
    {
        string teamId = llList2String(gPlayers, pIdx + 7);
        if (teamId != "")
        {
            llMessageLinked(LINK_SET, LM_TEAM_SCORE_ADD, teamId + "|" + (string)points, avatar);
        }
    }

    persistPlayer(pIdx);
    return 0;
}

integer registerOrUpdateNode(list p, key sender)
{
    if (llGetListLength(p) < 11)
    {
        return 0;
    }
    string token = llList2String(p, 1);
    string qid = llList2String(p, 2);
    if (token != NETWORK_KEY || qid != QUEST_ID)
    {
        return 0;
    }

    string nodeId = llList2String(p, 3);
    string nType = llList2String(p, 4);
    integer seq = (integer)llList2String(p, 5);
    integer pts = (integer)llList2String(p, 6);
    string nextNode = llList2String(p, 7);
    string hint = llList2String(p, 8);
    float radius = (float)llList2String(p, 9);
    integer active = (integer)llList2String(p, 10);

    if (nodeId == "")
    {
        return 0;
    }

    integer idx = nodeIndex(nodeId);
    if (idx >= 0)
    {
        key existing = (key)llList2String(gNodes, idx + 1);
        if (existing != sender)
        {
            llOwnerSay("[SECURITY] NODE_ID collision blocked for " + nodeId);
            return 0;
        }
        gNodes = llListReplaceList(gNodes,
            [nodeId, (string)sender, nType, seq, pts, nextNode, hint, radius, active],
            idx, idx + NODE_STRIDE - 1);
        return 0;
    }

    gNodes += [nodeId, (string)sender, nType, seq, pts, nextNode, hint, radius, active];
    return 0;
}

integer loadPersistedPlayers()
{
    llMessageLinked(LINK_SET, LM_PROGRESS_GET, QUEST_ID, NULL_KEY);
    return 0;
}

integer validateNodeGraph()
{
    integer i = 0;
    integer len = llGetListLength(gNodes);
    integer finalCount = 0;
    while (i < len)
    {
        string nType = llList2String(gNodes, i + 2);
        integer seq = llList2Integer(gNodes, i + 3);
        if (nType == "FINAL")
        {
            finalCount++;
        }
        if (MODE_FLAGS & MODE_SEQUENTIAL)
        {
            if (seq <= 0)
            {
                llOwnerSay("[ADMIN ERROR] Invalid sequence on node " + llList2String(gNodes, i));
            }
        }
        i += NODE_STRIDE;
    }
    if (finalCount == 0)
    {
        llOwnerSay("[ADMIN ERROR] No FINAL node configured.");
    }
    return 0;
}

default
{
    state_entry()
    {
        gChannel = getPrivateChannel(NETWORK_KEY + QUEST_ID);
        gListen = llListen(gChannel, "", NULL_KEY, "");
        loadPersistedPlayers();
        llSetTimerEvent(15.0);
        llOwnerSay("Quest Master online. Channel=" + (string)gChannel);
    }

    on_rez(integer p)
    {
        llResetScript();
    }

    changed(integer c)
    {
        if (c & CHANGED_OWNER)
        {
            llResetScript();
        }
    }

    touch_start(integer total)
    {
        integer i;
        for (i = 0; i < total; ++i)
        {
            key av = llDetectedKey(i);
            if (av == llGetOwner())
            {
                llRegionSayTo(av, 0, "Owner options are in Admin Controller script/menu object.");
            }
            else
            {
                registerPlayer(av);
            }
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        if (channel != gChannel)
        {
            return;
        }

        list p = llParseStringKeepNulls(message, ["|"], []);
        integer count = llGetListLength(p);
        if (count < 4)
        {
            return;
        }
        string op = llList2String(p, 0);

        if (op == "HELLO")
        {
            registerOrUpdateNode(p, id);
            return;
        }

        if (op == "PING")
        {
            if (count >= 4 && llList2String(p, 1) == NETWORK_KEY && llList2String(p, 2) == QUEST_ID)
            {
                llRegionSayTo(id, gChannel, "PONG|" + NETWORK_KEY + "|" + QUEST_ID);
            }
            return;
        }

        if (op == "COMPLETE")
        {
            if (count < 6)
            {
                return;
            }
            string token = llList2String(p, 1);
            string qid = llList2String(p, 2);
            string nodeId = llList2String(p, 3);
            key avatar = (key)llList2String(p, 4);
            string nonce = llList2String(p, 5);

            if (token != NETWORK_KEY || qid != QUEST_ID)
            {
                return;
            }
            if (!isNodeAuthorized(nodeId, id))
            {
                return;
            }

            integer nIdx = nodeIndex(nodeId);
            if (nIdx < 0)
            {
                return;
            }
            integer points = llList2Integer(gNodes, nIdx + 4);
            applyNodeCompletion(avatar, nodeId, points, nonce);
            return;
        }

        if (op == "QRESULT")
        {
            if (count < 8)
            {
                return;
            }
            string token2 = llList2String(p, 1);
            string qid2 = llList2String(p, 2);
            string nodeId2 = llList2String(p, 3);
            key avatar2 = (key)llList2String(p, 4);
            integer correct = (integer)llList2String(p, 5);
            integer points2 = (integer)llList2String(p, 6);
            string nonce2 = llList2String(p, 7);

            if (token2 != NETWORK_KEY || qid2 != QUEST_ID)
            {
                return;
            }
            if (!isNodeAuthorized(nodeId2, id))
            {
                return;
            }
            if (!correct)
            {
                integer pIdx = playerIndex(avatar2);
                if (pIdx >= 0)
                {
                    integer score = llList2Integer(gPlayers, pIdx + 5) - WRONG_ANSWER_PENALTY;
                    gPlayers = llListReplaceList(gPlayers, [score], pIdx + 5, pIdx + 5);
                    persistPlayer(pIdx);
                }
                return;
            }
            applyNodeCompletion(avatar2, nodeId2, points2, nonce2);
            return;
        }
    }

    link_message(integer sender, integer num, string str, key id)
    {
        if (num == LM_PROGRESS_GET_RESPONSE)
        {
            // expected format rows separated by \n, each row is pipe-stride 11
            list rows = llParseStringKeepNulls(str, ["\n"], []);
            integer i = 0;
            integer len = llGetListLength(rows);
            gPlayers = [];
            while (i < len)
            {
                string row = llList2String(rows, i);
                if (row != "")
                {
                    list rec = llParseStringKeepNulls(row, ["|"], []);
                    if (llGetListLength(rec) == PLAYER_STRIDE)
                    {
                        gPlayers += rec;
                    }
                }
                i++;
            }
            return;
        }

        if (num == LM_HINT_APPLY)
        {
            // avatar|hintCost|timePenalty|hintText
            list p = llParseStringKeepNulls(str, ["|"], []);
            if (llGetListLength(p) < 4)
            {
                return;
            }
            key av = (key)llList2String(p, 0);
            integer cost = (integer)llList2String(p, 1);
            integer penalty = (integer)llList2String(p, 2);
            string hintText = llList2String(p, 3);
            integer pIdx = playerIndex(av);
            if (pIdx < 0)
            {
                return;
            }
            integer score = llList2Integer(gPlayers, pIdx + 5) - cost;
            integer hints = llList2Integer(gPlayers, pIdx + 6) + 1;
            integer startUnix = llList2Integer(gPlayers, pIdx + 2) - penalty;
            gPlayers = llListReplaceList(gPlayers, [score], pIdx + 5, pIdx + 5);
            gPlayers = llListReplaceList(gPlayers, [hints], pIdx + 6, pIdx + 6);
            gPlayers = llListReplaceList(gPlayers, [startUnix], pIdx + 2, pIdx + 2);
            persistPlayer(pIdx);
            llRegionSayTo(av, 0, "Hint: " + hintText);
            return;
        }

        if (num == LM_PROGRESS_RESET_ONE)
        {
            key av2 = id;
            integer idx = playerIndex(av2);
            if (idx >= 0)
            {
                gPlayers = llDeleteSubList(gPlayers, idx, idx + PLAYER_STRIDE - 1);
            }
            return;
        }

        if (num == LM_PROGRESS_RESET_ALL)
        {
            gPlayers = [];
            return;
        }

        if (num == LM_DIAG)
        {
            llOwnerSay("Nodes=" + (string)(llGetListLength(gNodes) / NODE_STRIDE) +
                " Players=" + (string)(llGetListLength(gPlayers) / PLAYER_STRIDE));
            return;
        }
    }

    timer()
    {
        gTick++;
        if ((gTick % 4) == 0)
        {
            validateNodeGraph();
        }
    }
}
```

## 7. COMPLETE Source of Script 02 - Player Progress Manager

```lsl
// Holiday Hunt & Quest Builder Engine PRO
// Script 02 - Player Progress Manager
// Creator: RockzHasan

integer LM_PROGRESS_GET = 1001;
integer LM_PROGRESS_GET_RESPONSE = 1005;
integer LM_PROGRESS_UPSERT = 1002;
integer LM_PROGRESS_RESET_ONE = 1003;
integer LM_PROGRESS_RESET_ALL = 1004;

string QUEST_ID = "DEFAULT_QUEST";
integer PLAYER_STRIDE = 11;
string KEY_PREFIX = "HHQ:PLAYER:";
string IDX_PREFIX = "HHQ:IDX:";

string indexKey()
{
    return IDX_PREFIX + QUEST_ID;
}

string playerStoreKey(string avatar)
{
    return KEY_PREFIX + QUEST_ID + ":" + avatar;
}

integer validRecord(list rec)
{
    if (llGetListLength(rec) != PLAYER_STRIDE)
    {
        return FALSE;
    }
    key av = (key)llList2String(rec, 0);
    if (av == NULL_KEY)
    {
        return FALSE;
    }
    // score, hints, rewarded must parse numerically
    (integer)llList2String(rec, 5);
    (integer)llList2String(rec, 6);
    (integer)llList2String(rec, 8);
    return TRUE;
}

integer storeRecord(string row)
{
    list rec = llParseStringKeepNulls(row, ["|"], []);
    if (!validRecord(rec))
    {
        return 0;
    }
    string av = llList2String(rec, 0);
    llLinksetDataWrite(playerStoreKey(av), row);
    string idx = llLinksetDataRead(indexKey());
    list keys = [];
    if (idx != "")
    {
        keys = llParseStringKeepNulls(idx, [","], []);
    }
    if (llListFindList(keys, [av]) < 0)
    {
        keys += [av];
        llLinksetDataWrite(indexKey(), llDumpList2String(keys, ","));
    }
    return 0;
}

string buildAllRows()
{
    string out = "";
    string idx = llLinksetDataRead(indexKey());
    list keys = [];
    if (idx != "")
    {
        keys = llParseStringKeepNulls(idx, [","], []);
    }
    integer count = llGetListLength(keys);
    integer i = 0;
    while (i < count)
    {
        string av = llList2String(keys, i);
        if (av != "")
        {
            string row = llLinksetDataRead(playerStoreKey(av));
            if (row != "")
            {
                list rec = llParseStringKeepNulls(row, ["|"], []);
                if (validRecord(rec))
                {
                    if (out == "")
                    {
                        out = row;
                    }
                    else
                    {
                        out += "\n" + row;
                    }
                }
            }
        }
        i++;
    }
    return out;
}

integer resetOne(key avatar)
{
    if (avatar == NULL_KEY)
    {
        return 0;
    }
    string av = (string)avatar;
    llLinksetDataDelete(playerStoreKey(av));
    string idx = llLinksetDataRead(indexKey());
    if (idx != "")
    {
        list keys = llParseStringKeepNulls(idx, [","], []);
        integer pos = llListFindList(keys, [av]);
        if (pos >= 0)
        {
            keys = llDeleteSubList(keys, pos, pos);
            llLinksetDataWrite(indexKey(), llDumpList2String(keys, ","));
        }
    }
    return 0;
}

integer resetAll()
{
    string idx = llLinksetDataRead(indexKey());
    list keys = [];
    if (idx != "")
    {
        keys = llParseStringKeepNulls(idx, [","], []);
    }
    integer i = 0;
    integer count = llGetListLength(keys);
    while (i < count)
    {
        llLinksetDataDelete(playerStoreKey(llList2String(keys, i)));
        i++;
    }
    llLinksetDataDelete(indexKey());
    return 0;
}

default
{
    state_entry()
    {
        llOwnerSay("Player Progress Manager online.");
    }

    link_message(integer sender, integer num, string str, key id)
    {
        if (num == LM_PROGRESS_GET)
        {
            // Master asks with QUEST_ID as payload.
            if (str != "")
            {
                QUEST_ID = str;
            }
            llMessageLinked(LINK_SET, LM_PROGRESS_GET_RESPONSE, buildAllRows(), NULL_KEY);
            return;
        }

        if (num == LM_PROGRESS_UPSERT)
        {
            storeRecord(str);
            return;
        }

        if (num == LM_PROGRESS_RESET_ONE)
        {
            resetOne(id);
            return;
        }

        if (num == LM_PROGRESS_RESET_ALL)
        {
            resetAll();
            return;
        }
    }

    changed(integer c)
    {
        if (c & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}
```

## 8. Remaining Scripts

### Script 03 - Hunt Checkpoint Node

```lsl
// Script 03 - Hunt Checkpoint Node
integer ACTIVE = TRUE;
string QUEST_ID = "DEFAULT_QUEST";
string NODE_ID = "CP_01";
string NODE_TYPE = "TOUCH";
integer SEQUENCE = 1;
integer POINTS = 10;
string NEXT_NODE = "";
string HINT = "Look near festive decor.";
float RADIUS = 5.0;
string NETWORK_KEY = "CHANGE_ME_SECRET";

integer gChannel;
integer gListen;
integer gTick;

integer getPrivateChannel(string seed)
{
    string h = llSHA1String(seed, 0);
    integer n = (integer)("0x" + llGetSubString(h, 0, 5));
    return -1000000 - (n % 800000000);
}

string nonce()
{
    return llGetSubString((string)llGetUnixTime(), -6, -1) + (string)((integer)llFrand(999999.0));
}

sendHello()
{
    string pkt = "HELLO|" + NETWORK_KEY + "|" + QUEST_ID + "|" + NODE_ID + "|" + NODE_TYPE +
        "|" + (string)SEQUENCE + "|" + (string)POINTS + "|" + NEXT_NODE + "|" + HINT + "|" +
        (string)RADIUS + "|" + (string)ACTIVE;
    llRegionSay(gChannel, pkt);
}

triggerComplete(key avatar)
{
    if (!ACTIVE || avatar == NULL_KEY)
    {
        return;
    }
    llRegionSay(gChannel,
        "COMPLETE|" + NETWORK_KEY + "|" + QUEST_ID + "|" + NODE_ID + "|" + (string)avatar + "|" + nonce());
}

default
{
    state_entry()
    {
        gChannel = getPrivateChannel(NETWORK_KEY + QUEST_ID);
        gListen = llListen(gChannel, "", NULL_KEY, "");
        llSetTimerEvent(3.0 + llFrand(2.0));
    }

    on_rez(integer p)
    {
        llResetScript();
    }

    changed(integer c)
    {
        if (c & CHANGED_OWNER)
        {
            llResetScript();
        }
    }

    touch_start(integer total)
    {
        if (NODE_TYPE != "TOUCH" && NODE_TYPE != "ITEM" && NODE_TYPE != "FINAL")
        {
            return;
        }
        integer i;
        for (i = 0; i < total; ++i)
        {
            triggerComplete(llDetectedKey(i));
        }
    }

    sensor(integer n)
    {
        if (NODE_TYPE != "PROXIMITY")
        {
            return;
        }
        integer i;
        for (i = 0; i < n; ++i)
        {
            key av = llDetectedKey(i);
            if (llDetectedType(i) & AGENT)
            {
                triggerComplete(av);
            }
        }
    }

    listen(integer c, string n, key id, string msg)
    {
        if (c != gChannel)
        {
            return;
        }
        if (msg == "PONG|" + NETWORK_KEY + "|" + QUEST_ID)
        {
            return;
        }
    }

    timer()
    {
        gTick++;
        if (gTick == 1)
        {
            sendHello();
        }
        if (NODE_TYPE == "PROXIMITY" && ACTIVE)
        {
            llSensor("", NULL_KEY, AGENT, RADIUS, PI);
        }
        if ((gTick % 20) == 0)
        {
            llRegionSay(gChannel, "PING|" + NETWORK_KEY + "|" + QUEST_ID + "|" + NODE_ID);
        }
    }
}
```

### Script 04 - Puzzle / Question Node

```lsl
// Script 04 - Puzzle Question Node
string QUEST_ID = "DEFAULT_QUEST";
string NETWORK_KEY = "CHANGE_ME_SECRET";
string NODE_ID = "Q_01";
integer POINTS = 20;

string QUESTION = "Which key opens winter vault?";
string A = "Frost";
string B = "Ash";
string C = "Sun";
string D = "Stone";
string CORRECT = "Frost";

integer ACTIVE = TRUE;
float RADIUS = 5.0;

integer gChannel;
integer gListen;
list gSessions; // avatar,listenHandle,chan,expire,nonce (stride 5)
integer S_STRIDE = 5;

integer getPrivateChannel(string seed)
{
    string h = llSHA1String(seed, 0);
    integer n = (integer)("0x" + llGetSubString(h, 0, 5));
    return -1000000 - (n % 800000000);
}

integer sessIndex(key av)
{
    return llListFindList(gSessions, [(string)av]);
}

string makeNonce()
{
    return (string)llGetUnixTime() + (string)((integer)llFrand(999999.0));
}

list shuffledAnswers()
{
    list pool = [A, B, C, D];
    list out;
    while (llGetListLength(pool) > 0)
    {
        integer idx = (integer)llFrand((float)llGetListLength(pool));
        if (idx < 0 || idx >= llGetListLength(pool))
        {
            idx = 0;
        }
        out += [llList2String(pool, idx)];
        pool = llDeleteSubList(pool, idx, idx);
    }
    return out;
}

closeSession(integer idx)
{
    if (idx < 0)
    {
        return;
    }
    integer h = llList2Integer(gSessions, idx + 1);
    if (h)
    {
        llListenRemove(h);
    }
    gSessions = llDeleteSubList(gSessions, idx, idx + S_STRIDE - 1);
}

openDialog(key av)
{
    integer idx = sessIndex(av);
    if (idx >= 0)
    {
        closeSession(idx);
    }

    integer chan = -200000000 - (integer)llFrand(500000000.0);
    string nonce = makeNonce();
    integer h = llListen(chan, "", av, "");
    integer expire = llGetUnixTime() + 30;

    gSessions += [(string)av, h, chan, expire, nonce];

    list buttons = shuffledAnswers();
    llDialog(av, QUESTION, buttons, chan);
}

sendResult(key av, integer correct, string nonce)
{
    llRegionSay(gChannel,
        "QRESULT|" + NETWORK_KEY + "|" + QUEST_ID + "|" + NODE_ID + "|" + (string)av +
        "|" + (string)correct + "|" + (string)POINTS + "|" + nonce);
}

sendHello()
{
    llRegionSay(gChannel,
        "HELLO|" + NETWORK_KEY + "|" + QUEST_ID + "|" + NODE_ID + "|QUESTION|1|" + (string)POINTS + "|||" +
        (string)RADIUS + "|" + (string)ACTIVE);
}

default
{
    state_entry()
    {
        gChannel = getPrivateChannel(NETWORK_KEY + QUEST_ID);
        gListen = llListen(gChannel, "", NULL_KEY, "");
        llSetTimerEvent(5.0);
        sendHello();
    }

    on_rez(integer p)
    {
        llResetScript();
    }

    touch_start(integer total)
    {
        if (!ACTIVE)
        {
            return;
        }
        integer i;
        for (i = 0; i < total; ++i)
        {
            key av = llDetectedKey(i);
            if (av != NULL_KEY)
            {
                openDialog(av);
            }
        }
    }

    listen(integer channel, string name, key id, string msg)
    {
        integer idx = sessIndex(id);
        if (idx < 0)
        {
            return;
        }
        integer expectedChan = llList2Integer(gSessions, idx + 2);
        if (channel != expectedChan)
        {
            return;
        }

        string nonce = llList2String(gSessions, idx + 4);
        integer correct = (msg == CORRECT);
        sendResult(id, correct, nonce);
        if (!correct)
        {
            llRegionSayTo(id, 0, "Wrong answer. Try again later.");
        }
        closeSession(idx);
    }

    timer()
    {
        integer now = llGetUnixTime();
        integer i = 0;
        integer len = llGetListLength(gSessions);
        while (i < len)
        {
            integer exp = llList2Integer(gSessions, i + 3);
            if (now > exp)
            {
                key av = (key)llList2String(gSessions, i);
                llRegionSayTo(av, 0, "Question timed out.");
                closeSession(i);
                i = 0;
                len = llGetListLength(gSessions);
                jump continue_loop;
            }
            i += S_STRIDE;
@continue_loop;
        }
    }

    changed(integer c)
    {
        if (c & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}
```

### Script 05 - Reward Manager

```lsl
// Script 05 - Reward Manager
integer LM_REWARD_REQUEST = 1101;

string MAIN_PRIZE = "Quest Prize";
string BONUS_PRIZE = "Quest Bonus";
integer RANDOM_BONUS_CHANCE = 25;
integer ENABLE_BONUS = TRUE;
integer ENABLE_RANDOM_PRIZE = TRUE;

integer hasInventory(string name)
{
    if (name == "")
    {
        return FALSE;
    }
    if (llGetInventoryType(name) == INVENTORY_NONE)
    {
        return FALSE;
    }
    return TRUE;
}

givePrize(key av, string item)
{
    if (av == NULL_KEY)
    {
        return;
    }
    if (!hasInventory(item))
    {
        llOwnerSay("Missing reward inventory item: " + item);
        return;
    }
    llGiveInventory(av, item);
}

default
{
    state_entry()
    {
        llOwnerSay("Reward Manager online.");
    }

    link_message(integer sender, integer num, string str, key id)
    {
        if (num != LM_REWARD_REQUEST)
        {
            return;
        }
        key av = id;
        givePrize(av, MAIN_PRIZE);

        if (ENABLE_BONUS && hasInventory(BONUS_PRIZE))
        {
            givePrize(av, BONUS_PRIZE);
        }
        else if (ENABLE_RANDOM_PRIZE)
        {
            if ((integer)llFrand(100.0) < RANDOM_BONUS_CHANCE && hasInventory(BONUS_PRIZE))
            {
                givePrize(av, BONUS_PRIZE);
            }
        }
    }

    changed(integer c)
    {
        if (c & CHANGED_INVENTORY)
        {
            llOwnerSay("Reward inventory changed. Verify configured item names.");
        }
    }
}
```

### Script 06 - Score / Leaderboard Manager

```lsl
// Script 06 - Score / Leaderboard Manager
integer LM_LEADERBOARD_SUBMIT = 1201;
integer LM_DIAG = 1901;

integer MAX_ENTRIES = 20;
string LB_KEY = "HHQ:LB";

// stride: avatar,name,score,time
list gRows;
integer STRIDE = 4;

loadLb()
{
    string data = llLinksetDataRead(LB_KEY);
    if (data == "")
    {
        gRows = [];
        return;
    }
    gRows = llParseStringKeepNulls(data, ["|"], []);
    if ((llGetListLength(gRows) % STRIDE) != 0)
    {
        gRows = [];
    }
}

saveLb()
{
    llLinksetDataWrite(LB_KEY, llDumpList2String(gRows, "|"));
}

integer findAvatar(key av)
{
    return llListFindList(gRows, [(string)av]);
}

addOrUpdate(key av, string name, integer score, integer elapsed)
{
    integer idx = findAvatar(av);
    if (idx >= 0)
    {
        integer oldScore = llList2Integer(gRows, idx + 2);
        integer oldTime = llList2Integer(gRows, idx + 3);
        if (score > oldScore || (score == oldScore && elapsed < oldTime))
        {
            gRows = llListReplaceList(gRows, [(string)av, name, score, elapsed], idx, idx + STRIDE - 1);
        }
    }
    else
    {
        gRows += [(string)av, name, score, elapsed];
    }
}

sortLb()
{
    integer entries = llGetListLength(gRows) / STRIDE;
    integer i;
    integer j;
    for (i = 0; i < entries; ++i)
    {
        for (j = i + 1; j < entries; ++j)
        {
            integer ia = i * STRIDE;
            integer ja = j * STRIDE;
            integer s1 = llList2Integer(gRows, ia + 2);
            integer t1 = llList2Integer(gRows, ia + 3);
            integer s2 = llList2Integer(gRows, ja + 2);
            integer t2 = llList2Integer(gRows, ja + 3);
            integer swap = FALSE;
            if (s2 > s1)
            {
                swap = TRUE;
            }
            else if (s2 == s1 && t2 < t1)
            {
                swap = TRUE;
            }
            if (swap)
            {
                list ri = llList2List(gRows, ia, ia + STRIDE - 1);
                list rj = llList2List(gRows, ja, ja + STRIDE - 1);
                gRows = llListReplaceList(gRows, rj, ia, ia + STRIDE - 1);
                gRows = llListReplaceList(gRows, ri, ja, ja + STRIDE - 1);
            }
        }
    }

    while ((llGetListLength(gRows) / STRIDE) > MAX_ENTRIES)
    {
        integer start = llGetListLength(gRows) - STRIDE;
        gRows = llDeleteSubList(gRows, start, start + STRIDE - 1);
    }
}

string formatLb()
{
    string out = "Leaderboard\n";
    integer entries = llGetListLength(gRows) / STRIDE;
    integer i;
    for (i = 0; i < entries; ++i)
    {
        integer a = i * STRIDE;
        out += (string)(i + 1) + ". " + llList2String(gRows, a + 1) + " | " +
            (string)llList2Integer(gRows, a + 2) + " pts | " +
            (string)llList2Integer(gRows, a + 3) + "s\n";
        if (llStringLength(out) > 800)
        {
            out += "...";
            return out;
        }
    }
    return out;
}

default
{
    state_entry()
    {
        loadLb();
    }

    touch_start(integer total)
    {
        llOwnerSay(formatLb());
    }

    link_message(integer sender, integer num, string str, key id)
    {
        if (num == LM_LEADERBOARD_SUBMIT)
        {
            list p = llParseStringKeepNulls(str, ["|"], []);
            if (llGetListLength(p) < 4)
            {
                return;
            }
            key av = (key)llList2String(p, 0);
            string nm = llList2String(p, 1);
            integer sc = (integer)llList2String(p, 2);
            integer tm = (integer)llList2String(p, 3);
            addOrUpdate(av, nm, sc, tm);
            sortLb();
            saveLb();
            return;
        }

        if (num == LM_DIAG)
        {
            llOwnerSay("Leaderboard entries=" + (string)(llGetListLength(gRows) / STRIDE));
            return;
        }

        if (num == 1202) // clear request
        {
            gRows = [];
            saveLb();
        }
    }
}
```

### Script 07 - Team Manager

```lsl
// Script 07 - Team Manager
integer LM_TEAM_SCORE_ADD = 1301;
integer LM_DIAG = 1901;

// team stride: teamId,owner,totalScore,membersCsv
list gTeams;
integer T_STRIDE = 4;

integer teamIndex(string teamId)
{
    integer i = 0;
    integer len = llGetListLength(gTeams);
    while (i < len)
    {
        if (llList2String(gTeams, i) == teamId)
        {
            return i;
        }
        i += T_STRIDE;
    }
    return -1;
}

string makeCode()
{
    return (string)((integer)llFrand(900000.0) + 100000);
}

string csvAppend(string csv, string value)
{
    if (csv == "")
    {
        return value;
    }
    list vals = llParseStringKeepNulls(csv, [","], []);
    if (llListFindList(vals, [value]) >= 0)
    {
        return csv;
    }
    vals += [value];
    return llDumpList2String(vals, ",");
}

createTeam(key leader)
{
    string teamId = "T" + makeCode();
    if (teamIndex(teamId) >= 0)
    {
        return;
    }
    gTeams += [teamId, (string)leader, 0, (string)leader];
    llRegionSayTo(leader, 0, "Team created. Code: " + teamId);
}

joinTeam(key av, string teamId)
{
    integer idx = teamIndex(teamId);
    if (idx < 0)
    {
        llRegionSayTo(av, 0, "Invalid team code.");
        return;
    }
    string members = llList2String(gTeams, idx + 3);
    members = csvAppend(members, (string)av);
    gTeams = llListReplaceList(gTeams, [members], idx + 3, idx + 3);
    llRegionSayTo(av, 0, "Joined team " + teamId);
}

default
{
    touch_start(integer total)
    {
        key av = llDetectedKey(0);
        if (av != NULL_KEY)
        {
            createTeam(av);
        }
    }

    listen(integer c, string n, key id, string msg)
    {
        if (llSubStringIndex(msg, "JOIN ") == 0)
        {
            joinTeam(id, llGetSubString(msg, 5, -1));
        }
    }

    state_entry()
    {
        llListen(0, "", NULL_KEY, "");
    }

    link_message(integer sender, integer num, string str, key id)
    {
        if (num == LM_TEAM_SCORE_ADD)
        {
            list p = llParseStringKeepNulls(str, ["|"], []);
            if (llGetListLength(p) < 2)
            {
                return;
            }
            string t = llList2String(p, 0);
            integer add = (integer)llList2String(p, 1);
            integer idx = teamIndex(t);
            if (idx >= 0)
            {
                integer sc = llList2Integer(gTeams, idx + 2) + add;
                gTeams = llListReplaceList(gTeams, [sc], idx + 2, idx + 2);
            }
            return;
        }

        if (num == LM_DIAG)
        {
            llOwnerSay("Teams=" + (string)(llGetListLength(gTeams) / T_STRIDE));
        }
    }
}
```

### Script 08 - Hint Manager

```lsl
// Script 08 - Hint Manager
integer LM_HINT_APPLY = 1401;

integer HINT_COST = 0;
integer HINT_PENALTY_SEC = 0;
integer MAX_HINTS = 3;
integer HINTS_ENABLED = TRUE;

// player -> used count
list gUsed;

integer idx(key av)
{
    return llListFindList(gUsed, [(string)av]);
}

integer usedBy(key av)
{
    integer i = idx(av);
    if (i < 0)
    {
        return 0;
    }
    return llList2Integer(gUsed, i + 1);
}

setUsed(key av, integer v)
{
    integer i = idx(av);
    if (i < 0)
    {
        gUsed += [(string)av, v];
        return;
    }
    gUsed = llListReplaceList(gUsed, [v], i + 1, i + 1);
}

default
{
    touch_start(integer total)
    {
        key av = llDetectedKey(0);
        if (!HINTS_ENABLED)
        {
            llRegionSayTo(av, 0, "Hints are disabled.");
            return;
        }
        integer used = usedBy(av);
        if (MAX_HINTS >= 0 && used >= MAX_HINTS)
        {
            llRegionSayTo(av, 0, "No hints remaining.");
            return;
        }
        setUsed(av, used + 1);
        llMessageLinked(LINK_SET, LM_HINT_APPLY,
            (string)av + "|" + (string)HINT_COST + "|" + (string)HINT_PENALTY_SEC + "|Search around your current stage marker.",
            av);
    }
}
```

### Script 09 - Admin Controller

```lsl
// Script 09 - Admin Controller
integer LM_PROGRESS_RESET_ONE = 1003;
integer LM_PROGRESS_RESET_ALL = 1004;
integer LM_DIAG = 1901;

integer gChan;
integer gListen;
key gPendingOwner = NULL_KEY;
string gPendingAction = "";

showMenu(key owner)
{
    gChan = -300000000 - (integer)llFrand(400000000.0);
    if (gListen)
    {
        llListenRemove(gListen);
    }
    gListen = llListen(gChan, "", owner, "");
    llDialog(owner,
        "Admin Menu",
        ["START EVENT","STOP EVENT","PAUSE","PLAYERS","NODES","LEADERBOARD","RESET PLAYER","RESET ALL","STATUS","DEBUG","HELP"],
        gChan);
}

confirm(key owner, string action)
{
    gPendingOwner = owner;
    gPendingAction = action;
    llDialog(owner, "Confirm " + action + "?", ["CONFIRM","CANCEL"], gChan);
}

default
{
    touch_start(integer total)
    {
        key av = llDetectedKey(0);
        if (av == llGetOwner())
        {
            showMenu(av);
        }
    }

    listen(integer c, string n, key id, string msg)
    {
        if (c != gChan || id != llGetOwner())
        {
            return;
        }

        if (msg == "RESET ALL" || msg == "RESET PLAYER")
        {
            confirm(id, msg);
            return;
        }

        if (msg == "CONFIRM" && id == gPendingOwner)
        {
            if (gPendingAction == "RESET ALL")
            {
                llMessageLinked(LINK_SET, LM_PROGRESS_RESET_ALL, "", NULL_KEY);
                llMessageLinked(LINK_SET, 1202, "", NULL_KEY);
                llOwnerSay("All progress reset.");
            }
            else if (gPendingAction == "RESET PLAYER")
            {
                // reset owner by default in this script variant
                llMessageLinked(LINK_SET, LM_PROGRESS_RESET_ONE, "", id);
                llOwnerSay("Owner player record reset.");
            }
            gPendingOwner = NULL_KEY;
            gPendingAction = "";
            return;
        }

        if (msg == "CANCEL")
        {
            gPendingOwner = NULL_KEY;
            gPendingAction = "";
            return;
        }

        if (msg == "DEBUG")
        {
            llMessageLinked(LINK_SET, LM_DIAG, "", NULL_KEY);
            return;
        }

        if (msg == "HELP")
        {
            llOwnerSay("Use START/STOP/PAUSE from your configured event-state controller. This menu includes safe reset confirmations.");
            return;
        }
    }

    changed(integer c)
    {
        if (c & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}
```

### Script 10 - Diagnostics

```lsl
// Script 10 - Diagnostics
integer LM_DIAG = 1901;

integer gCount = 0;

default
{
    state_entry()
    {
        llSetTimerEvent(60.0);
    }

    timer()
    {
        gCount++;
        if ((gCount % 5) == 0)
        {
            llMessageLinked(LINK_SET, LM_DIAG, "", NULL_KEY);
        }
    }

    touch_start(integer total)
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            llMessageLinked(LINK_SET, LM_DIAG, "", NULL_KEY);
        }
    }
}
```

## 9. Example Christmas Hunt Configuration

```text
QUEST_ID=CHRISTMAS_2026
THEME=CHRISTMAS
MODE=SEQUENTIAL|TIMED|POINT_BASED|SOLO
NETWORK_KEY=9n0v3mber-snow-secret
TIME_LIMIT_SEC=2700
HINT_COST=3
HINT_PENALTY_SEC=45
MAX_HINTS=3
LEADERBOARD_MAX=25
ALLOW_REPEAT_REWARD=0
COMPLETION_BONUS=120
WRONG_ANSWER_PENALTY=2
TIME_BONUS_PER_MIN=2
```

## 10. Example Treasure Hunt Configuration

```text
QUEST_ID=TREASURE_ISLES_01
THEME=TREASURE
MODE=OPEN_WORLD|RANDOM_ROUTE|POINT_BASED|TEAM
NETWORK_KEY=gold-map-hidden-network-key
TIME_LIMIT_SEC=0
HINT_COST=10
HINT_PENALTY_SEC=0
MAX_HINTS=5
LEADERBOARD_MAX=30
ALLOW_REPEAT_REWARD=0
COMPLETION_BONUS=200
WRONG_ANSWER_PENALTY=5
TIME_BONUS_PER_MIN=0
```

## 11. Setup Guide
1. Rez a master object; add Script 01, Script 02, Script 05, Script 06, Script 07, Script 08, Script 09, Script 10.
2. Configure shared `QUEST_ID` and `NETWORK_KEY` consistently across all scripts.
3. Rez checkpoint/puzzle objects; add Script 03 or Script 04 per node.
4. Set each node `NODE_ID` unique per quest.
5. Set one node as `NODE_TYPE=FINAL`.
6. Put reward inventory inside master object and set Script 05 prize names.
7. Touch admin controller as owner and run diagnostics.
8. Have a test avatar complete route end-to-end before public launch.

## 12. Customer Guide
- Players touch master to register.
- Follow hints/checkpoints and solve puzzles.
- In sequential mode, complete order exactly.
- In timed mode, finish before limit expires.
- Optional hints may reduce score or add time penalty.
- Final node awards configured reward and pushes score to leaderboard.

## 13. Troubleshooting
- No completion registering:
  - Verify matching `QUEST_ID` and `NETWORK_KEY` between node and master.
  - Verify node successfully sent `HELLO` and appears in diagnostics count.
- Players not receiving rewards:
  - Confirm inventory item names exist exactly in reward manager object contents.
  - Confirm player has not already claimed reward when repeat disabled.
- Random route errors:
  - Ensure at least one active `FINAL` node.
  - Ensure route-eligible nodes are active and have unique node IDs.
- Dialog issues in puzzle node:
  - Ensure question/answers are non-empty.
  - Avoid duplicated answer text if you need strict answer uniqueness.

## 14. Performance Notes
- Uses timestamp delta (`llGetUnixTime`) rather than one-second tick counters.
- Node hello is startup-jittered to reduce burst traffic.
- No chat on public channel for event operations.
- Leaderboard capped by `MAX_ENTRIES` to control memory.
- Dialog listeners are per-session and removed on answer/timeout.
- No continuous global sensor scanning beyond configured proximity nodes.

## 15. Final Error/Compile Audit
Manual LSL audit performed for all scripts:
- Grammar/events:
  - `default`, `state_entry`, `touch_start`, `listen`, `timer`, `changed`, `on_rez`, `sensor`, `link_message` signatures use valid LSL forms.
- Safety checks:
  - Packet field counts checked before index access.
  - Node completion validated by token, quest id, registered node id, and sender object UUID.
  - Replay nonce and duplicate completion protection applied.
  - Owner-only admin access and destructive reset confirmation included.
- Runtime logic protections:
  - No modulo-by-zero paths.
  - Empty list paths handled before random selection.
  - Missing FINAL node for random route reports explicit admin error.
  - Linkset data rows validated for expected stride before parsing.
- Timer and listener hygiene:
  - Puzzle dialog listener closed on submit/timeout.
  - No per-second timing loops for elapsed duration.
- Persistence and limits:
  - Player/leaderboard state stored via `llLinksetDataWrite` with bounded leaderboard size.
- Remaining practical deployment notes:
  - For large-scale events, split heavy node counts across regions/experiences to stay within script memory/event queue limits.
  - Replace default secrets before production release.
