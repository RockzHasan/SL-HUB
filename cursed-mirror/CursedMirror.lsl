// Cursed Mirror Illusion Engine PRO  -  by RockzHasan
// ONE prim, ONE script. No real reflections: texture swaps, tint, glow and particles only.
// Optional inventory: textures ghost_*, crack_*   sounds whisper_*

// ---------- CONFIG ----------
integer MIRROR_FACE   = 0;      // face that shows the mirror (see README)
float   RANGE         = 6.0;    // trigger range (m)
integer COOLDOWN      = 60;     // seconds between events
integer CHANCE        = 60;     // % chance per detection
float   EVENT_TIME    = 6.0;    // seconds an event lasts
float   TICK          = 0.5;    // timer period
integer MENU_TIMEOUT  = 60;     // seconds
float   SOUND_VOL     = 0.6;

// ---------- STATE ----------
integer gEnabled   = TRUE;
integer gSound     = TRUE;
integer gMode      = 3;         // 0 curse 1 ghost 2 nightmare 3 random
integer gBusy      = FALSE;     // event running
integer gTicks;
integer gMaxTicks;
integer gLastEvent;             // unix time
integer gEventMode;
integer gMenuChan;
integer gListen;
integer gMenuTicks;
integer gMenuOpen;
integer gPage;

// snapshot of user's look (never overwritten permanently)
key     sTex; vector sRep; vector sOff; float sRot;
vector  sCol; float sAlpha; float sGlow; integer sFB;
integer gHaveSnap;

list gGhost; list gCrack; list gSnd;

list WHISPERS = ["...get out...","...I see you...","...behind you...","...she is watching...","...don't look...","...stay with us..."];

// ---------- HELPERS ----------
list scan(integer type, string prefix)
{
    list r; integer n = llGetInventoryNumber(type); integer i; integer pl = llStringLength(prefix);
    if (n > 60) n = 60;
    for (i = 0; i < n; ++i)
    {
        string nm = llGetInventoryName(type, i);
        if (llToLower(llGetSubString(nm, 0, pl - 1)) == prefix) r += nm;
    }
    return r;
}

rescan()
{
    gGhost = scan(INVENTORY_TEXTURE, "ghost_");
    gCrack = scan(INVENTORY_TEXTURE, "crack_");
    gSnd   = scan(INVENTORY_SOUND, "whisper_");
}

snapshot()
{
    list p = llGetPrimitiveParams([PRIM_TEXTURE, MIRROR_FACE, PRIM_COLOR, MIRROR_FACE, PRIM_GLOW, MIRROR_FACE, PRIM_FULLBRIGHT, MIRROR_FACE]);
    sTex = llList2Key(p,0); sRep = llList2Vector(p,1); sOff = llList2Vector(p,2); sRot = llList2Float(p,3);
    sCol = llList2Vector(p,4); sAlpha = llList2Float(p,5); sGlow = llList2Float(p,6); sFB = llList2Integer(p,7);
    gHaveSnap = TRUE;
}

restore()
{
    llParticleSystem([]);
    llStopSound();
    if (gHaveSnap)
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
            PRIM_TEXTURE, MIRROR_FACE, (string)sTex, sRep, sOff, sRot,
            PRIM_COLOR, MIRROR_FACE, sCol, sAlpha,
            PRIM_GLOW, MIRROR_FACE, sGlow,
            PRIM_FULLBRIGHT, MIRROR_FACE, sFB]);
    }
    gBusy = FALSE;
    gTicks = 0;
}

setTex(string name)
{
    if (llGetInventoryType(name) == INVENTORY_TEXTURE)
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXTURE, MIRROR_FACE, name, <1,1,0>, ZERO_VECTOR, 0.0]);
}

setTint(vector c, float glow)
{
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, MIRROR_FACE, c, 1.0, PRIM_GLOW, MIRROR_FACE, glow, PRIM_FULLBRIGHT, MIRROR_FACE, TRUE]);
}

string pick(list l) { return llList2String(l, (integer)llFrand((float)llGetListLength(l))); }

mist(vector col)
{
    llParticleSystem([
        PSYS_PART_FLAGS, PSYS_PART_EMISSIVE_MASK | PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_FOLLOW_VELOCITY_MASK,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE,
        PSYS_SRC_BURST_RATE, 0.2, PSYS_SRC_BURST_PART_COUNT, 2,
        PSYS_PART_MAX_AGE, 3.0,
        PSYS_PART_START_COLOR, col, PSYS_PART_END_COLOR, <0,0,0>,
        PSYS_PART_START_ALPHA, 0.5, PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, <0.15,0.15,0>, PSYS_PART_END_SCALE, <0.5,0.5,0>,
        PSYS_SRC_BURST_RADIUS, 0.2,
        PSYS_SRC_ANGLE_BEGIN, 0.0, PSYS_SRC_ANGLE_END, 0.8,
        PSYS_SRC_BURST_SPEED_MIN, 0.05, PSYS_SRC_BURST_SPEED_MAX, 0.3,
        PSYS_SRC_ACCEL, <0,0,0.1>,
        PSYS_SRC_MAX_AGE, 0.0]);
}

startEvent()
{
    if (gBusy) return;
    if (llGetListLength(gGhost) + llGetListLength(gCrack) == 0) {} // tint/particle fallback
    snapshot();
    gBusy = TRUE; gTicks = 0;
    gMaxTicks = (integer)(EVENT_TIME / TICK);
    gLastEvent = llGetUnixTime();
    gEventMode = gMode;
    if (gEventMode > 2) gEventMode = (integer)llFrand(3.0);
    if (gSound && llGetListLength(gSnd) > 0) llPlaySound(pick(gSnd), SOUND_VOL);
    else llWhisper(0, pick(WHISPERS));
    if (gEventMode == 0) { if (llGetListLength(gCrack) > 0) setTex(pick(gCrack)); setTint(<0.7,0.0,0.0>, 0.15); mist(<0.6,0,0>); }
    else if (gEventMode == 1) { if (llGetListLength(gGhost) > 0) setTex(pick(gGhost)); setTint(<0.6,0.9,1.0>, 0.2); mist(<0.7,0.9,1>); }
    else { setTint(<0.2,0.0,0.3>, 0.1); mist(<0.4,0,0.5>); }
    llSetTimerEvent(TICK);
}

openMenu(key id)
{
    if (gListen) llListenRemove(gListen);
    gMenuChan = -1 - (integer)llFrand(2000000000.0);
    gListen = llListen(gMenuChan, "", id, "");
    gMenuOpen = TRUE; gMenuTicks = 0;
    string t = "Cursed Mirror PRO\nEnabled: " + (string)gEnabled + "  Sound: " + (string)gSound +
        "\nMode: " + llList2String(["Curse","Ghost","Nightmare","Random"], gMode) +
        "\nRange: " + llGetSubString((string)RANGE,0,3) + "m  Cooldown: " + (string)COOLDOWN + "s" +
        "\nGhost tex: " + (string)llGetListLength(gGhost) + " Crack tex: " + (string)llGetListLength(gCrack) + " Sounds: " + (string)llGetListLength(gSnd);
    list b;
    if (gPage == 0) b = ["On/Off","Test","Sound","Curse","Ghost","Nightmare","Random","More >>","RESTORE","RESET"];
    else b = ["Range +","Range -","CD +","CD -","Rescan","<< Back","RESTORE","RESET"];
    llDialog(id, t, b, gMenuChan);
    llSetTimerEvent(TICK);
}

closeMenu()
{
    if (gListen) llListenRemove(gListen);
    gListen = 0; gMenuOpen = FALSE;
    if (!gBusy) llSetTimerEvent(0.0);
}

sense()
{
    llSensorRemove();
    if (gEnabled) llSensorRepeat("", NULL_KEY, AGENT, RANGE, PI, 2.0);
}

default
{
    state_entry()
    {
        restore(); // no snapshot yet: just clears particles/sound
        snapshot();
        rescan();
        gLastEvent = 0;
        sense();
        llOwnerSay("Cursed Mirror ready. Touch to configure.");
    }
    on_rez(integer p) { llResetScript(); }
    changed(integer c)
    {
        if (c & CHANGED_OWNER) llResetScript();
        if (c & CHANGED_INVENTORY) rescan();
    }
    sensor(integer n)
    {
        if (gBusy || !gEnabled) return;
        if (llGetUnixTime() - gLastEvent < COOLDOWN) return;
        if ((integer)llFrand(100.0) < CHANCE) startEvent();
        else gLastEvent = llGetUnixTime() - COOLDOWN + 10; // short re-roll delay
    }
    touch_start(integer n)
    {
        if (llDetectedKey(0) != llGetOwner()) return;
        gPage = 0;
        openMenu(llGetOwner());
    }
    listen(integer ch, string nm, key id, string msg)
    {
        if (id != llGetOwner() || ch != gMenuChan) return;
        gMenuTicks = 0;
        integer reopen = TRUE;
        if (msg == "On/Off") { gEnabled = !gEnabled; sense(); }
        else if (msg == "Test") { gLastEvent = 0; startEvent(); }
        else if (msg == "Sound") gSound = !gSound;
        else if (msg == "Curse") gMode = 0;
        else if (msg == "Ghost") gMode = 1;
        else if (msg == "Nightmare") gMode = 2;
        else if (msg == "Random") gMode = 3;
        else if (msg == "More >>") gPage = 1;
        else if (msg == "<< Back") gPage = 0;
        else if (msg == "Range +") { RANGE += 1.0; if (RANGE > 20.0) RANGE = 20.0; sense(); }
        else if (msg == "Range -") { RANGE -= 1.0; if (RANGE < 1.0) RANGE = 1.0; sense(); }
        else if (msg == "CD +") { COOLDOWN += 15; if (COOLDOWN > 3600) COOLDOWN = 3600; }
        else if (msg == "CD -") { COOLDOWN -= 15; if (COOLDOWN < 10) COOLDOWN = 10; }
        else if (msg == "Rescan") rescan();
        else if (msg == "RESTORE") { restore(); if (!gMenuOpen) llSetTimerEvent(0.0); }
        else if (msg == "RESET") { llResetScript(); return; }
        if (reopen) openMenu(id);
    }
    timer()
    {
        if (gBusy)
        {
            ++gTicks;
            if (gTicks % 3 == 0 && gEventMode != 2) // gentle flicker, bounded rate
            {
                if (gEventMode == 1 && llGetListLength(gGhost) > 0) setTex(pick(gGhost));
                if (gEventMode == 0 && llGetListLength(gCrack) > 0) setTex(pick(gCrack));
            }
            if (gEventMode == 2 && gTicks % 2 == 0)
                setTint(<llFrand(0.5), 0.0, llFrand(0.6)>, llFrand(0.3));
            if (gTicks >= gMaxTicks) restore();
        }
        if (gMenuOpen)
        {
            ++gMenuTicks;
            if (gMenuTicks * TICK > MENU_TIMEOUT) closeMenu();
        }
        if (!gBusy && !gMenuOpen) llSetTimerEvent(0.0);
    }
}
