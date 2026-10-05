// Halloween Trick-or-Treat Event Network PRO
// 06 - Optional Admin HUD | Creator: RockzHasan
integer NETWORK_CHANNEL = -8842107;
string EVENT_TOKEN = "CHANGE-ME-TO-A-LONG-RANDOM-TOKEN";
string PROTOCOL = "HTN1";
integer gListen;
integer gDialogChannel;
integer gDialogListen;
string gSession = "CLOSED";
integer gWaitingForUUID;
integer sendAdmin(string action, string extra)
{
    list m = [PROTOCOL, EVENT_TOKEN, gSession, "ADMIN", llGetOwner(), action];
    if (extra != "") m += [extra];
    llRegionSay(NETWORK_CHANNEL, llList2Json(JSON_ARRAY, m));
    return 0;
}
integer menu()
{
    llDialog(llGetOwner(), "Halloween Event Network PRO\nSession: " + gSession,
        ["START", "STOP", "STATUS", "RESET ALL", "RESET PLAYER", "EMERGENCY"], gDialogChannel);
    return 0;
}
default
{
    state_entry()
    {
        gListen = llListen(NETWORK_CHANNEL, "", NULL_KEY, "");
        gDialogChannel = -100000 - (integer)llFrand(900000.0);
        gDialogListen = llListen(gDialogChannel, "", llGetOwner(), "");
    }
    on_rez(integer p) { llResetScript(); }
    attach(key id) { if (id != NULL_KEY) llResetScript(); }
    changed(integer c) { if (c & CHANGED_OWNER) llResetScript(); }
    touch_start(integer total) { if (llDetectedKey(0) == llGetOwner()) menu(); }
    listen(integer channel, string name, key id, string message)
    {
        if (channel == gDialogChannel)
        {
            if (gWaitingForUUID)
            {
                gWaitingForUUID = FALSE;
                if ((key)message == NULL_KEY) llOwnerSay("Invalid UUID; no player was reset.");
                else sendAdmin("RESET_PLAYER", message);
            }
            else if (message == "RESET PLAYER")
            {
                gWaitingForUUID = TRUE;
                llTextBox(llGetOwner(), "Paste the resident UUID to reset:", gDialogChannel);
            }
            else if (message == "RESET ALL") sendAdmin("RESET_ALL", "");
            else sendAdmin(message, "");
            return;
        }
        if (llJsonValueType(message, []) != JSON_ARRAY) return;
        list m = llJson2List(message);
        if (llGetListLength(m) < 4 || llList2String(m, 0) != PROTOCOL || llList2String(m, 1) != EVENT_TOKEN) return;
        if (llList2String(m, 3) == "STATE") gSession = llList2String(m, 2);
        else if (llList2String(m, 3) == "ADMIN_STATUS")
        { gSession = llList2String(m, 2); llOwnerSay("Active: " + llList2String(m, 4) + ", stations: " + llList2String(m, 5)); }
        else if (channel == gDialogChannel) { }
    }
    dataserver(key q, string data) { }
}
