// Haunted House Interactive Horror Engine PRO - Core Controller
// Creator: RockzHasan
// Internal protocol: 100 control, 110 zone request, 200 scene, 900 state.

float GLOBAL_COOLDOWN = 8.0;
integer SCARE_PROBABILITY = 75; // 0..100
integer AUTOMATIC_MODE = TRUE;
integer DEBUG_MODE = FALSE;
integer CONTROL_CHANNEL = -19471041;
list STAFF = []; // UUID strings, e.g. ["00000000-0000-0000-0000-000000000000"]

integer LM_CONTROL = 100;
integer LM_ZONE_REQUEST = 110;
integer LM_SCENE = 200;
integer LM_STATE = 900;
integer enabled = TRUE;
integer safeMode = FALSE;
integer lastGlobal = 0;
integer listenHandle;
integer menuHandle;
integer menuChannel;
key menuUser = NULL_KEY;
integer menuExpires;
integer sequenceStep;
key sequenceVisitor = NULL_KEY;

integer authorized(key id)
{
    key principal = llGetOwnerKey(id); // avatar for chat, object owner for HUD chat
    if (principal == llGetOwner()) return TRUE;
    return (llListFindList(STAFF, [(string)principal]) != -1);
}

debug(string message)
{
    if (DEBUG_MODE) llOwnerSay("[Haunted Core] " + message);
}

broadcastState()
{
    llMessageLinked(LINK_SET, LM_STATE,
        (string)enabled + "|" + (string)safeMode + "|" + (string)AUTOMATIC_MODE, NULL_KEY);
}

showMenu(key id)
{
    if (menuHandle) llListenRemove(menuHandle);
    menuChannel = -1000000 - (integer)llFrand(1000000000.0);
    menuUser = id;
    menuExpires = llGetUnixTime() + 30;
    menuHandle = llListen(menuChannel, "", id, "");
    llDialog(id, "Haunted House PRO\nEnabled: " + (string)enabled +
        "  SAFE: " + (string)safeMode + "  Auto: " + (string)AUTOMATIC_MODE,
        ["RANDOM", "AUTO", "ENABLE", "DISABLE", "SAFE", "RESET", "STATUS", "CLOSE"], menuChannel);
    llSetTimerEvent(1.0);
}

status(key id)
{
    llRegionSayTo(id, 0, "Haunted House PRO: enabled=" + (string)enabled +
        ", safe=" + (string)safeMode + ", automatic=" + (string)AUTOMATIC_MODE +
        ", probability=" + (string)SCARE_PROBABILITY + "%, global cooldown=" +
        (string)GLOBAL_COOLDOWN + "s, free memory=" + (string)llGetFreeMemory() + ".");
}

runScene(integer scene, key visitor)
{
    if (!enabled || safeMode) return;
    lastGlobal = llGetUnixTime();
    if (scene == 5)
    {
        sequenceStep = 1;
        sequenceVisitor = visitor;
        llMessageLinked(LINK_SET, LM_SCENE, "1", visitor);
        llSetTimerEvent(1.0);
    }
    else llMessageLinked(LINK_SET, LM_SCENE, (string)scene, visitor);
    debug("Scene " + (string)scene + " for " + (string)visitor);
}

handleCommand(string command, key id)
{
    command = llToUpper(llStringTrim(command, STRING_TRIM));
    if (!authorized(id)) return;
    if (command == "MENU") showMenu(id);
    else if (command == "RANDOM") runScene(1 + (integer)llFrand(5.0), id);
    else if (command == "AUTO") { AUTOMATIC_MODE = !AUTOMATIC_MODE; broadcastState(); }
    else if (command == "ENABLE") { enabled = TRUE; safeMode = FALSE; broadcastState(); }
    else if (command == "DISABLE") { enabled = FALSE; broadcastState(); }
    else if (command == "SAFE" || command == "STOP")
    {
        safeMode = TRUE;
        enabled = FALSE;
        llStopSound();
        llParticleSystem([]);
        llMessageLinked(LINK_SET, LM_CONTROL, "SAFE", id);
        broadcastState();
    }
    else if (command == "STATUS") status(id);
    if (command == "RESET")
    {
        llMessageLinked(LINK_SET, LM_CONTROL, "RESET", id);
        llResetScript();
    }
}

default
{
    state_entry()
    {
        listenHandle = llListen(CONTROL_CHANNEL, "", NULL_KEY, "");
        broadcastState();
    }

    on_rez(integer start) { llResetScript(); }
    changed(integer change)
    {
        if (change & CHANGED_OWNER) llResetScript();
    }

    touch_start(integer count)
    {
        key id = llDetectedKey(0);
        if (authorized(id)) showMenu(id);
    }

    listen(integer channel, string name, key id, string message)
    {
        if (channel == CONTROL_CHANNEL) handleCommand(message, id);
        else if (channel == menuChannel && id == menuUser)
        {
            if (message == "CLOSE")
            {
                llListenRemove(menuHandle); menuHandle = 0;
                if (!sequenceStep) llSetTimerEvent(0.0);
            }
            else { handleCommand(message, id); if (message != "RESET") showMenu(id); }
        }
    }

    timer()
    {
        if (sequenceStep)
        {
            ++sequenceStep;
            if (sequenceStep <= 4)
                llMessageLinked(LINK_SET, LM_SCENE, (string)sequenceStep, sequenceVisitor);
            else { sequenceStep = 0; sequenceVisitor = NULL_KEY; }
        }
        if (menuHandle && llGetUnixTime() >= menuExpires)
        {
            llListenRemove(menuHandle); menuHandle = 0; menuUser = NULL_KEY;
        }
        if (!menuHandle && !sequenceStep) llSetTimerEvent(0.0);
    }

    link_message(integer sender, integer number, string message, key id)
    {
        if (number == LM_ZONE_REQUEST && enabled && !safeMode && AUTOMATIC_MODE)
        {
            integer now = llGetUnixTime();
            if ((now - lastGlobal) >= (integer)GLOBAL_COOLDOWN &&
                (integer)llFrand(100.0) < SCARE_PROBABILITY)
                runScene(1 + (integer)llFrand(5.0), id);
        }
        else if (number == LM_CONTROL) handleCommand(message, id);
    }
}
