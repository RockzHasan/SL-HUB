// Halloween Trick-or-Treat Event Network PRO
// 07 - Personal Progress HUD (optional) | Creator: RockzHasan
integer NETWORK_CHANNEL = -8842107;
string EVENT_TOKEN = "CHANGE-ME-TO-A-LONG-RANDOM-TOKEN";
string PROTOCOL = "HTN1";
integer gListen;
string gSession = "CLOSED";
integer query()
{
    string nonce = llGetSubString((string)llGenerateKey(), 0, 15);
    llRegionSay(NETWORK_CHANNEL, llList2Json(JSON_ARRAY,
        [PROTOCOL, EVENT_TOKEN, gSession, "QUERY", llGetOwner(), nonce]));
    return 0;
}
default
{
    state_entry() { gListen = llListen(NETWORK_CHANNEL, "", NULL_KEY, ""); }
    on_rez(integer p) { llResetScript(); }
    attach(key id) { if (id != NULL_KEY) llResetScript(); }
    changed(integer c) { if (c & CHANGED_OWNER) llResetScript(); }
    touch_start(integer total) { if (llDetectedKey(0) == llGetOwner()) query(); }
    listen(integer channel, string name, key id, string message)
    {
        if (llGetOwnerKey(id) != llGetOwner() && id != llGetKey()) return;
        if (llJsonValueType(message, []) != JSON_ARRAY) return;
        list m = llJson2List(message);
        if (llGetListLength(m) < 4 || llList2String(m, 0) != PROTOCOL || llList2String(m, 1) != EVENT_TOKEN) return;
        string command = llList2String(m, 3);
        if (command == "STATE") gSession = llList2String(m, 2);
        else if (command == "QUERY_RESULT" && llGetListLength(m) == 10)
        {
            gSession = llList2String(m, 2);
            string done = "not complete"; if (llList2Integer(m, 8)) done = "COMPLETE";
            llOwnerSay("Candy: " + llList2String(m, 6) + " | Unique houses: " +
                llList2String(m, 7) + "/" + llList2String(m, 9) + " | " + done);
        }
    }
}
