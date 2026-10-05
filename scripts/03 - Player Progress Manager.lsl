// Halloween Trick-or-Treat Event Network PRO
// 03 - Player Progress Manager | Creator: RockzHasan
integer BONUS_POINTS = 3;
integer MAX_PLAYERS = 300; // memory safety ceiling; tune after script-memory testing
integer DEBUG = FALSE;
string gSession = "CLOSED";
integer gRequired = 10;
integer gGlobalCooldown = 3;
integer gOpen;
// stride: uuid, name, score, unique count, complete, last collection unix, |station|station|
list gPlayers;
integer playerIndex(key avatar)
{
    integer i;
    for (i = 0; i < llGetListLength(gPlayers); i += 7) if (llList2Key(gPlayers, i) == avatar) return i;
    return -1;
}
integer sendResult(string session, key stationObject, string nonce, key avatar, string status,
    integer awarded, integer total, integer unique, integer complete, integer rare)
{
    llMessageLinked(LINK_SET, 0, llList2Json(JSON_ARRAY,
        ["COLLECT_RESULT", session, stationObject, nonce, avatar, status, awarded, total, unique, complete, rare]), NULL_KEY);
    return 0;
}
default
{
    state_entry() { llSetMemoryLimit(65536); }
    link_message(integer sender, integer number, string message, key id)
    {
        if (llJsonValueType(message, []) != JSON_ARRAY) return;
        list m = llJson2List(message);
        string command = llList2String(m, 0);
        if (command == "RESET_ALL" && llGetListLength(m) == 4)
        { gSession = llList2String(m, 1); gRequired = llList2Integer(m, 2); gGlobalCooldown = llList2Integer(m, 3); gPlayers = []; gOpen = TRUE; return; }
        if (command == "EVENT_STATE" && llList2String(m, 1) == gSession)
        { gOpen = (llList2String(m, 2) == "OPEN"); return; }
        if (command == "RESET_PLAYER" && llList2String(m, 1) == gSession)
        {
            integer r = playerIndex(llList2Key(m, 2));
            if (r != -1) gPlayers = llDeleteSubList(gPlayers, r, r + 6);
            return;
        }
        if (command == "COLLECT" && llGetListLength(m) == 10 && llList2String(m, 1) == gSession)
        {
            key avatar = llList2Key(m, 2); string avatarName = llList2String(m, 3);
            string stationID = llList2String(m, 4); integer points = llList2Integer(m, 5);
            integer rare = llList2Integer(m, 6); integer bonus = llList2Integer(m, 7);
            key stationObject = llList2Key(m, 8); string nonce = llList2String(m, 9);
            if (!gOpen) { sendResult(gSession, stationObject, nonce, avatar, "CLOSED", 0, 0, 0, 0, 0); return; }
            integer p = playerIndex(avatar);
            if (p == -1)
            {
                if (llGetListLength(gPlayers) / 7 >= MAX_PLAYERS)
                { sendResult(gSession, stationObject, nonce, avatar, "FULL", 0, 0, 0, 0, 0); return; }
                gPlayers += [avatar, avatarName, 0, 0, 0, 0, "|"];
                p = llGetListLength(gPlayers) - 7;
            }
            integer now = llGetUnixTime(); integer last = llList2Integer(gPlayers, p + 5);
            integer score = llList2Integer(gPlayers, p + 2); integer unique = llList2Integer(gPlayers, p + 3);
            integer complete = llList2Integer(gPlayers, p + 4); string visited = llList2String(gPlayers, p + 6);
            if (llSubStringIndex(visited, "|" + stationID + "|") != -1)
            { sendResult(gSession, stationObject, nonce, avatar, "DUPLICATE", 0, score, unique, complete, 0); return; }
            if (gGlobalCooldown > 0 && last > 0 && now - last < gGlobalCooldown)
            { sendResult(gSession, stationObject, nonce, avatar, "GLOBAL_COOLDOWN", 0, score, unique, complete, 0); return; }
            integer awarded = points + (bonus * BONUS_POINTS);
            score += awarded; ++unique; visited += stationID + "|";
            integer justCompleted = FALSE;
            if (!complete && unique >= gRequired) { complete = TRUE; justCompleted = TRUE; }
            gPlayers = llListReplaceList(gPlayers,
                [avatar, avatarName, score, unique, complete, now, visited], p, p + 6);
            sendResult(gSession, stationObject, nonce, avatar, "OK", awarded, score, unique, justCompleted, rare);
            llMessageLinked(LINK_SET, 0, llList2Json(JSON_ARRAY,
                ["PLAYER_UPDATE", gSession, avatar, avatarName, score, unique, complete]), NULL_KEY);
            return;
        }
        if (command == "QUERY" && llGetListLength(m) == 5 && llList2String(m, 1) == gSession)
        {
            key avatar = llList2Key(m, 2); integer q = playerIndex(avatar);
            if (q == -1) llMessageLinked(LINK_SET, 0, llList2Json(JSON_ARRAY,
                ["QUERY_RESULT", gSession, llList2Key(m, 3), llList2String(m, 4), avatar, 0, 0, 0, gRequired]), NULL_KEY);
            else llMessageLinked(LINK_SET, 0, llList2Json(JSON_ARRAY,
                ["QUERY_RESULT", gSession, llList2Key(m, 3), llList2String(m, 4), avatar,
                 llList2Integer(gPlayers, q + 2), llList2Integer(gPlayers, q + 3), llList2Integer(gPlayers, q + 4), gRequired]), NULL_KEY);
        }
    }
}
