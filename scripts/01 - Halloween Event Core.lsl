// Halloween Trick-or-Treat Event Network PRO
// 01 - Halloween Event Core | Creator: RockzHasan
integer NETWORK_CHANNEL = -8842107; // Must match stations/HUD. Use a unique nonzero channel.
string EVENT_TOKEN = "CHANGE-ME-TO-A-LONG-RANDOM-TOKEN";
integer REQUIRED_STATIONS = 10;
integer GLOBAL_COOLDOWN = 3;
integer AUTO_START = FALSE;
integer AUTO_STOP_AFTER_MINUTES = 0;
integer DEBUG = FALSE;

string PROTOCOL = "HTN1";
integer gListen;
integer gActive;
string gSession = "CLOSED";
integer gEndsAt;
// station stride: object key, id, friendly name, min, max, rare percent, bonus
list gStations;
// recently handled request stride: station object, nonce, unix time
list gRequests;

integer validStationID(string value)
{
    integer n = llStringLength(value);
    if (n < 1 || n > 32) return FALSE;
    integer i;
    string allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-";
    for (i = 0; i < n; ++i)
        if (llSubStringIndex(allowed, llGetSubString(value, i, i)) == -1) return FALSE;
    return TRUE;
}
integer stationIndexByID(string stationID)
{
    integer i;
    for (i = 0; i < llGetListLength(gStations); i += 7)
        if (llList2String(gStations, i + 1) == stationID) return i;
    return -1;
}
integer stationIndexByObject(key objectID)
{
    integer i;
    for (i = 0; i < llGetListLength(gStations); i += 7)
        if (llList2Key(gStations, i) == objectID) return i;
    return -1;
}
integer sameOwner(key objectID) { return llGetOwnerKey(objectID) == llGetOwner(); }
string newSession() { return (string)llGetUnixTime() + "-" + llGetSubString((string)llGenerateKey(), 0, 7); }
integer sendTo(key objectID, list fields)
{
    llRegionSayTo(objectID, NETWORK_CHANNEL, llList2Json(JSON_ARRAY, fields));
    return 0;
}
integer announce(string text)
{
    llRegionSay(0, "[Halloween Event] " + text);
    return 0;
}
integer debug(string text)
{
    if (DEBUG) llOwnerSay("DEBUG: " + text);
    return 0;
}
integer beginEvent()
{
    if (REQUIRED_STATIONS < 1) REQUIRED_STATIONS = 1;
    gSession = newSession();
    gActive = TRUE;
    gRequests = [];
    gEndsAt = 0;
    if (AUTO_STOP_AFTER_MINUTES > 0) gEndsAt = llGetUnixTime() + (AUTO_STOP_AFTER_MINUTES * 60);
    llMessageLinked(LINK_SET, 0, llList2Json(JSON_ARRAY,
        ["RESET_ALL", gSession, REQUIRED_STATIONS, GLOBAL_COOLDOWN]), NULL_KEY);
    llRegionSay(NETWORK_CHANNEL, llList2Json(JSON_ARRAY,
        [PROTOCOL, EVENT_TOKEN, gSession, "STATE", "OPEN"]));
    announce("Trick-or-Treat is now OPEN! Visit participating candy stations.");
    return 0;
}
integer stopEvent(string reason)
{
    gActive = FALSE;
    llMessageLinked(LINK_SET, 0, llList2Json(JSON_ARRAY, ["EVENT_STATE", gSession, "CLOSED"]), NULL_KEY);
    llRegionSay(NETWORK_CHANNEL, llList2Json(JSON_ARRAY,
        [PROTOCOL, EVENT_TOKEN, gSession, "STATE", "CLOSED"]));
    announce("The event is now closed. " + reason);
    return 0;
}
integer pruneRequests()
{
    integer cutoff = llGetUnixTime() - 120;
    integer i;
    list keep;
    for (i = 0; i < llGetListLength(gRequests); i += 3)
        if (llList2Integer(gRequests, i + 2) >= cutoff)
            keep += llList2List(gRequests, i, i + 2);
    gRequests = keep;
    return 0;
}
integer requestSeen(key stationObject, string nonce)
{
    integer i;
    for (i = 0; i < llGetListLength(gRequests); i += 3)
        if (llList2Key(gRequests, i) == stationObject && llList2String(gRequests, i + 1) == nonce) return TRUE;
    gRequests += [stationObject, nonce, llGetUnixTime()];
    return FALSE;
}
integer handleHello(key id, list m)
{
    // [HTN1, token, session-or-*, HELLO, stationID, name, min, max, rare%, bonus]
    if (!sameOwner(id)) return 0;
    string stationID = llList2String(m, 4);
    if (!validStationID(stationID)) { sendTo(id, [PROTOCOL, EVENT_TOKEN, gSession, "HELLO_ACK", "BAD_ID"]); return 0; }
    integer low = llList2Integer(m, 6);
    integer high = llList2Integer(m, 7);
    integer rare = llList2Integer(m, 8);
    integer bonus = llList2Integer(m, 9);
    if (low < 0) low = 0;
    if (high < low) high = low;
    if (high > 10000) high = 10000;
    if (rare < 0) rare = 0;
    if (rare > 100) rare = 100;
    if (bonus != 0) bonus = 1;
    integer byID = stationIndexByID(stationID);
    integer byObject = stationIndexByObject(id);
    if (byID != -1 && llList2Key(gStations, byID) != id)
    { sendTo(id, [PROTOCOL, EVENT_TOKEN, gSession, "HELLO_ACK", "DUPLICATE_ID"]); return 0; }
    list record = [id, stationID, llGetSubString(llList2String(m, 5), 0, 47), low, high, rare, bonus];
    if (byObject != -1) gStations = llListReplaceList(gStations, record, byObject, byObject + 6);
    else gStations += record;
    sendTo(id, [PROTOCOL, EVENT_TOKEN, gSession, "HELLO_ACK", "OK", gActive, llGetUnixTime()]);
    debug("Registered station " + stationID);
    return 0;
}
integer handleCollect(key id, list m)
{
    // [HTN1, token, session, COLLECT, stationID, avatarUUID, avatarName, nonce]
    string stationID = llList2String(m, 4);
    key avatar = llList2Key(m, 5);
    string nonce = llList2String(m, 7);
    integer s = stationIndexByID(stationID);
    if (!sameOwner(id) || s == -1 || llList2Key(gStations, s) != id) return 0;
    if (!gActive) { sendTo(id, [PROTOCOL, EVENT_TOKEN, gSession, "RESULT", nonce, avatar, "CLOSED", 0, 0]); return 0; }
    if (llList2String(m, 2) != gSession) { sendTo(id, [PROTOCOL, EVENT_TOKEN, gSession, "RESULT", nonce, avatar, "STALE", 0, 0]); return 0; }
    if (avatar == NULL_KEY || nonce == "") return 0;
    if (requestSeen(id, nonce)) return 0;
    integer low = llList2Integer(gStations, s + 3);
    integer high = llList2Integer(gStations, s + 4);
    integer points = low;
    if (high > low) points += (integer)llFrand((float)(high - low + 1));
    integer rare = (llFrand(100.0) < (float)llList2Integer(gStations, s + 5));
    llMessageLinked(LINK_SET, 0, llList2Json(JSON_ARRAY,
        ["COLLECT", gSession, avatar, llGetSubString(llList2String(m, 6), 0, 47), stationID,
         points, rare, llList2Integer(gStations, s + 6), id, nonce]), NULL_KEY);
    return 0;
}
integer adminAllowed(key objectID, key avatar)
{
    return avatar == llGetOwner() && sameOwner(objectID);
}

default
{
    state_entry()
    {
        if (NETWORK_CHANNEL == 0) { llOwnerSay("ERROR: NETWORK_CHANNEL must be nonzero."); return; }
        gListen = llListen(NETWORK_CHANNEL, "", NULL_KEY, "");
        llSetTimerEvent(30.0);
        llRegionSay(NETWORK_CHANNEL, llList2Json(JSON_ARRAY,
            [PROTOCOL, EVENT_TOKEN, "*", "DISCOVER"]));
        if (AUTO_START) beginEvent();
        else llOwnerSay("Halloween Event Core ready. Touch for owner controls.");
    }
    on_rez(integer p) { llResetScript(); }
    changed(integer c) { if (c & CHANGED_OWNER) llResetScript(); }
    touch_start(integer total)
    {
        if (llDetectedKey(0) != llGetOwner()) return;
        llOwnerSay("Halloween Event Network PRO — active: " + (string)gActive +
            ", session: " + gSession + ", registered stations: " +
            (string)(llGetListLength(gStations) / 7) + ". Use the optional Admin HUD for controls.");
    }
    listen(integer channel, string name, key id, string message)
    {
        if (llJsonValueType(message, []) != JSON_ARRAY) return;
        list m = llJson2List(message);
        if (llGetListLength(m) < 4 || llList2String(m, 0) != PROTOCOL || llList2String(m, 1) != EVENT_TOKEN) return;
        string command = llList2String(m, 3);
        if (command == "HELLO" && llGetListLength(m) == 10) handleHello(id, m);
        else if (command == "COLLECT" && llGetListLength(m) == 8) handleCollect(id, m);
        else if (command == "QUERY" && llGetListLength(m) == 6)
        {
            key avatar = llList2Key(m, 4);
            if (avatar == llGetOwnerKey(id) && (llList2String(m, 2) == gSession || llList2String(m, 2) == "*" || llList2String(m, 2) == "CLOSED"))
                llMessageLinked(LINK_SET, 0, llList2Json(JSON_ARRAY, ["QUERY", gSession, avatar, id, llList2String(m, 5)]), NULL_KEY);
        }
        else if (command == "ADMIN" && llGetListLength(m) >= 6)
        {
            key avatar = llList2Key(m, 4);
            string action = llList2String(m, 5);
            if (!adminAllowed(id, avatar)) return;
            if (action == "START") beginEvent();
            else if (action == "STOP") stopEvent("Stopped by the owner.");
            else if (action == "EMERGENCY") stopEvent("Emergency stop engaged.");
            else if (action == "RESET_ALL") { stopEvent("Progress reset."); beginEvent(); }
            else if (action == "RESET_PLAYER" && llGetListLength(m) == 7)
                llMessageLinked(LINK_SET, 0, llList2Json(JSON_ARRAY, ["RESET_PLAYER", gSession, llList2Key(m, 6)]), NULL_KEY);
            else if (action == "STATUS") sendTo(id, [PROTOCOL, EVENT_TOKEN, gSession, "ADMIN_STATUS", gActive, llGetListLength(gStations) / 7]);
        }
    }
    link_message(integer sender, integer number, string message, key id)
    {
        if (llJsonValueType(message, []) != JSON_ARRAY) return;
        list m = llJson2List(message);
        string command = llList2String(m, 0);
        if (command == "COLLECT_RESULT" && llList2String(m, 1) == gSession)
        {
            // session, station object, nonce, avatar, status, points, total, unique, complete, rare
            key stationObject = llList2Key(m, 2);
            sendTo(stationObject, [PROTOCOL, EVENT_TOKEN, gSession, "RESULT", llList2String(m, 3),
                llList2Key(m, 4), llList2String(m, 5), llList2Integer(m, 6), llList2Integer(m, 7), llList2Integer(m, 8)]);
            if (llList2String(m, 5) == "OK" && llList2Integer(m, 10))
                llMessageLinked(LINK_SET, 0, llList2Json(JSON_ARRAY, ["AWARD", gSession, llList2Key(m, 4), "RARE"]), NULL_KEY);
            if (llList2String(m, 5) == "OK" && llList2Integer(m, 9))
                llMessageLinked(LINK_SET, 0, llList2Json(JSON_ARRAY, ["AWARD", gSession, llList2Key(m, 4), "COMPLETE"]), NULL_KEY);
        }
        else if (command == "QUERY_RESULT" && llList2String(m, 1) == gSession)
            sendTo(llList2Key(m, 2), [PROTOCOL, EVENT_TOKEN, gSession, "QUERY_RESULT"] + llList2List(m, 3, -1));
    }
    timer()
    {
        pruneRequests();
        if (gActive && gEndsAt > 0 && llGetUnixTime() >= gEndsAt) stopEvent("The scheduled end time was reached.");
    }
}
