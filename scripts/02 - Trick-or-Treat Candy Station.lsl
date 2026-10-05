// Halloween Trick-or-Treat Event Network PRO
// 02 - Trick-or-Treat Candy Station | Creator: RockzHasan
integer NETWORK_CHANNEL = -8842107;
string EVENT_TOKEN = "CHANGE-ME-TO-A-LONG-RANDOM-TOKEN";
string STATION_ID = "HOUSE_001"; // unique, 1-32 letters/numbers/_/-
string STATION_NAME = "The Haunted Porch";
integer CANDY_MIN = 1;
integer CANDY_MAX = 5;
integer RARE_PERCENT = 5;
integer BONUS_LOCATION = FALSE;
integer LOCAL_COOLDOWN = 10;
string SUCCESS_SOUND = ""; // inventory sound name or UUID; blank disables
integer DECORATIVE_LINK = 0; // linked prim number; 0 disables
integer DEBUG = FALSE;

string PROTOCOL = "HTN1";
integer gListen;
string gSession = "CLOSED";
integer gOpen;
// pending stride avatar, nonce, sent-at; local cooldown stride avatar, time
list gPending;
list gCooldowns;
integer sayCore(list fields) { llRegionSay(NETWORK_CHANNEL, llList2Json(JSON_ARRAY, fields)); return 0; }
integer validSound()
{
    if (SUCCESS_SOUND == "") return FALSE;
    if ((key)SUCCESS_SOUND != NULL_KEY) return TRUE;
    return llGetInventoryType(SUCCESS_SOUND) == INVENTORY_SOUND;
}
integer findAvatar(list data, integer stride, key avatar)
{
    integer i;
    for (i = 0; i < llGetListLength(data); i += stride) if (llList2Key(data, i) == avatar) return i;
    return -1;
}
integer feedback(vector color)
{
    if (DECORATIVE_LINK > 0)
    {
        llSetLinkColor(DECORATIVE_LINK, color, ALL_SIDES);
        llSetTimerEvent(2.0);
    }
    llParticleSystem([PSYS_PART_FLAGS, PSYS_PART_EMISSIVE_MASK | PSYS_PART_INTERP_COLOR_MASK,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE, PSYS_PART_START_COLOR, color,
        PSYS_PART_END_COLOR, <0.1,0.0,0.0>, PSYS_PART_START_ALPHA, 0.9,
        PSYS_PART_END_ALPHA, 0.0, PSYS_PART_START_SCALE, <0.12,0.12,0.0>,
        PSYS_PART_END_SCALE, <0.03,0.03,0.0>, PSYS_PART_MAX_AGE, 1.2,
        PSYS_SRC_BURST_PART_COUNT, 12, PSYS_SRC_BURST_RADIUS, 0.4,
        PSYS_SRC_BURST_SPEED_MIN, 0.2, PSYS_SRC_BURST_SPEED_MAX, 1.0,
        PSYS_SRC_MAX_AGE, 0.2]);
    return 0;
}
integer hello()
{
    sayCore([PROTOCOL, EVENT_TOKEN, "*", "HELLO", STATION_ID, STATION_NAME,
        CANDY_MIN, CANDY_MAX, RARE_PERCENT, BONUS_LOCATION]);
    return 0;
}
default
{
    state_entry()
    {
        gListen = llListen(NETWORK_CHANNEL, "", NULL_KEY, "");
        llSetText(STATION_NAME + "\nConnecting...", <1.0,0.5,0.0>, 1.0);
        llSetTimerEvent(5.0);
        hello();
    }
    on_rez(integer p) { llResetScript(); }
    changed(integer c) { if (c & (CHANGED_OWNER | CHANGED_INVENTORY)) llResetScript(); }
    touch_start(integer total)
    {
        key avatar = llDetectedKey(0);
        if (!gOpen) { llRegionSayTo(avatar, 0, STATION_NAME + ": The event is closed."); return; }
        integer now = llGetUnixTime();
        integer c = findAvatar(gCooldowns, 2, avatar);
        if (c != -1 && now - llList2Integer(gCooldowns, c + 1) < LOCAL_COOLDOWN)
        { llRegionSayTo(avatar, 0, STATION_NAME + ": Please wait before trying again."); return; }
        if (findAvatar(gPending, 3, avatar) != -1)
        { llRegionSayTo(avatar, 0, STATION_NAME + ": Your request is already being checked."); return; }
        string nonce = llGetSubString((string)llGenerateKey(), 0, 15);
        gPending += [avatar, nonce, now];
        if (c == -1) gCooldowns += [avatar, now];
        else gCooldowns = llListReplaceList(gCooldowns, [avatar, now], c, c + 1);
        sayCore([PROTOCOL, EVENT_TOKEN, gSession, "COLLECT", STATION_ID, avatar,
            llGetSubString(llDetectedName(0), 0, 47), nonce]);
        llRegionSayTo(avatar, 0, STATION_NAME + ": Checking your candy bag…");
    }
    listen(integer channel, string name, key id, string message)
    {
        if (id == llGetKey() || llGetOwnerKey(id) != llGetOwner()) return;
        if (llJsonValueType(message, []) != JSON_ARRAY) return;
        list m = llJson2List(message);
        if (llGetListLength(m) < 4 || llList2String(m, 0) != PROTOCOL || llList2String(m, 1) != EVENT_TOKEN) return;
        string command = llList2String(m, 3);
        if (command == "DISCOVER") hello();
        else if (command == "HELLO_ACK")
        {
            if (llList2String(m, 4) != "OK") { gOpen = FALSE; llOwnerSay("Station rejected: " + llList2String(m, 4)); return; }
            gSession = llList2String(m, 2); gOpen = llList2Integer(m, 5);
            if (gOpen) llSetText(STATION_NAME + "\nTRICK OR TREAT!", <0.3,1.0,0.2>, 1.0);
            else llSetText(STATION_NAME + "\nCLOSED", <0.7,0.7,0.7>, 1.0);
        }
        else if (command == "STATE")
        {
            gSession = llList2String(m, 2);
            gOpen = (llList2String(m, 4) == "OPEN");
            gPending = [];
            if (gOpen) llSetText(STATION_NAME + "\nTRICK OR TREAT!", <0.3,1.0,0.2>, 1.0);
            else llSetText(STATION_NAME + "\nCLOSED", <0.7,0.7,0.7>, 1.0);
        }
        else if (command == "RESULT" && llList2String(m, 2) == gSession && llGetListLength(m) == 9)
        {
            string nonce = llList2String(m, 4);
            key avatar = llList2Key(m, 5);
            integer p = findAvatar(gPending, 3, avatar);
            if (p == -1 || llList2String(gPending, p + 1) != nonce) return;
            gPending = llDeleteSubList(gPending, p, p + 2);
            string status = llList2String(m, 6);
            if (status == "OK")
            {
                llRegionSayTo(avatar, 0, "Happy Halloween! You found " + llList2String(m, 7) +
                    " candy point(s). Total: " + llList2String(m, 8));
                feedback(<1.0,0.25,0.0>); if (validSound()) llTriggerSound(SUCCESS_SOUND, 1.0);
            }
            else if (status == "DUPLICATE") llRegionSayTo(avatar, 0, "You already collected candy at this house.");
            else if (status == "GLOBAL_COOLDOWN") llRegionSayTo(avatar, 0, "Your magic candy bag needs a moment. Try again shortly.");
            else llRegionSayTo(avatar, 0, "The event is closed or this request expired.");
        }
    }
    timer()
    {
        llParticleSystem([]);
        if (DECORATIVE_LINK > 0) llSetLinkColor(DECORATIVE_LINK, <1.0,1.0,1.0>, ALL_SIDES);
        integer cutoff = llGetUnixTime() - 30;
        integer i; list keep; list cool;
        for (i = 0; i < llGetListLength(gPending); i += 3)
            if (llList2Integer(gPending, i + 2) >= cutoff) keep += llList2List(gPending, i, i + 2);
        gPending = keep;
        for (i = 0; i < llGetListLength(gCooldowns); i += 2)
            if (llGetUnixTime() - llList2Integer(gCooldowns, i + 1) < LOCAL_COOLDOWN)
                cool += llList2List(gCooldowns, i, i + 1);
        gCooldowns = cool;
        llSetTimerEvent(5.0);
    }
}
