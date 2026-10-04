// Wear this object as a HUD. It talks to nearby controllers on the configured channel.
integer CONTROL_CHANNEL = -19471041;
list STAFF = []; // HUD owner's UUID is always allowed; optional transferable staff UUIDs
integer listenHandle;
integer menuChannel;

integer allowed(key id)
{
    return (id == llGetOwner() || llListFindList(STAFF, [(string)id]) != -1);
}

show(key id)
{
    if (listenHandle) llListenRemove(listenHandle);
    menuChannel = -1000000 - (integer)llFrand(1000000000.0);
    listenHandle = llListen(menuChannel, "", id, "");
    llDialog(id, "Haunted House PRO Admin HUD", ["RANDOM", "AUTO", "ENABLE", "DISABLE", "SAFE", "RESET", "STATUS", "CLOSE"], menuChannel);
    llSetTimerEvent(30.0);
}

default
{
    state_entry() { }
    on_rez(integer start) { llResetScript(); }
    changed(integer change) { if (change & CHANGED_OWNER) llResetScript(); }
    touch_start(integer count) { key id = llDetectedKey(0); if (allowed(id)) show(id); }
    listen(integer channel, string name, key id, string message)
    {
        if (channel == menuChannel && allowed(id))
        {
            if (message == "CLOSE") { llListenRemove(listenHandle); listenHandle = 0; llSetTimerEvent(0.0); }
            else { llRegionSay(CONTROL_CHANNEL, message); show(id); }
        }
    }
    timer() { if (listenHandle) llListenRemove(listenHandle); listenHandle = 0; llSetTimerEvent(0.0); }
}
