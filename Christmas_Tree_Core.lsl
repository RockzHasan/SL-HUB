/*
    INTERACTIVE CHRISTMAS TREE PRO
    Created by RockzHasan
    Version 1.0.0

    Put LIGHT, STAR, or ORNAMENT in controlled prim names or descriptions.
    With no LIGHT tag, the linkset becomes a reversible setup fallback. The script
    snapshots every changed face and restores it through the Restore command.
*/

integer VERSION_CHANNEL = -918274;
integer MENU_TIMEOUT = 45;

integer gOwnerOnly = TRUE;
integer gLights = TRUE;
integer gStar = TRUE;
integer gOrnaments = TRUE;
integer gHover = FALSE;
integer gAuto = FALSE;
integer gAmbient = FALSE;
integer gSpeed = 1;              // 0 slow, 1 normal, 2 fast
integer gMode = 0;               // 0 static, 1 blink, 2 pulse, 3 twinkle, 4 random
integer gPalette = 0;
integer gPhase;
integer gListen;
integer gChannel;
integer gMenuExpires;
integer gNextSunCheck;
integer gNight = TRUE;
key gUser;
string gParticle = "Off";

list gLightsList;
list gStars;
list gOrnamentsList;
// Snapshot stride: link, face, color, alpha, glow, fullbright
list gOriginal;
list gSnapshotLinks;
integer gFallbackLight;

list PALETTE_NAMES = ["Classic", "Candy", "Ice", "Gold", "Rainbow"];
list MODE_NAMES = ["Static", "Blink", "Pulse", "Twinkle", "Random"];
list SPEED_NAMES = ["Slow", "Normal", "Fast"];

integer containsTag(string name, string description, string tag)
{
    string searchable = llToUpper(name + " " + description);
    return llSubStringIndex(searchable, tag) != -1;
}

vector paletteColor(integer palette, integer n)
{
    if (palette == 0)
    {
        if ((n % 3) == 0) return <1.0, 0.03, 0.03>;
        if ((n % 3) == 1) return <0.03, 0.85, 0.08>;
        return <1.0, 0.72, 0.05>;
    }
    if (palette == 1)
    {
        if ((n % 2) == 0) return <1.0, 0.05, 0.12>;
        return <1.0, 1.0, 1.0>;
    }
    if (palette == 2)
    {
        if ((n % 2) == 0) return <0.15, 0.65, 1.0>;
        return <0.8, 0.95, 1.0>;
    }
    if (palette == 3) return <1.0, 0.55, 0.03>;
    if ((n % 4) == 0) return <1.0, 0.02, 0.02>;
    if ((n % 4) == 1) return <0.05, 1.0, 0.1>;
    if ((n % 4) == 2) return <0.1, 0.35, 1.0>;
    return <0.85, 0.05, 1.0>;
}

snapshotLink(integer link)
{
    integer sides = llGetLinkNumberOfSides(link);
    integer face;
    for (face = 0; face < sides; ++face)
    {
        list c = llGetLinkPrimitiveParams(link,
            [PRIM_COLOR, face, PRIM_GLOW, face, PRIM_FULLBRIGHT, face]);
        gOriginal += [link, face, llList2Vector(c, 0), llList2Float(c, 1),
            llList2Float(c, 2), llList2Integer(c, 3)];
    }
}

snapshotOnce(integer link)
{
    if (llListFindList(gSnapshotLinks, [link]) == -1)
    {
        gSnapshotLinks += [link];
        snapshotLink(link);
    }
}

discoverLinks()
{
    gLightsList = [];
    gStars = [];
    gOrnamentsList = [];
    gOriginal = [];
    gSnapshotLinks = [];
    gFallbackLight = FALSE;
    integer count = llGetNumberOfPrims();
    integer link;
    for (link = 1; link <= count; ++link)
    {
        string name = llGetLinkName(link);
        string description = llList2String(llGetLinkPrimitiveParams(link, [PRIM_DESC]), 0);
        if (containsTag(name, description, "LIGHT"))
        {
            gLightsList += [link];
            snapshotOnce(link);
        }
        if (containsTag(name, description, "STAR"))
        {
            gStars += [link];
            snapshotOnce(link);
        }
        if (containsTag(name, description, "ORNAMENT"))
        {
            gOrnamentsList += [link];
            snapshotOnce(link);
        }
    }
    // A freshly dropped script must do something in an untagged mesh tree.
    // The whole linkset is a reversible fallback because every affected link is
    // snapshotted before the first render. Builders can tag dedicated light
    // children and reset the script to disable this fallback.
    if (!llGetListLength(gLightsList))
    {
        for (link = 1; link <= count; ++link)
        {
            gLightsList += [link];
            snapshotOnce(link);
        }
        gFallbackLight = TRUE;
    }
}

restoreOriginal()
{
    integer i;
    for (i = 0; i < llGetListLength(gOriginal); i += 6)
    {
        llSetLinkPrimitiveParamsFast(llList2Integer(gOriginal, i),
            [PRIM_COLOR, llList2Integer(gOriginal, i + 1),
                llList2Vector(gOriginal, i + 2), llList2Float(gOriginal, i + 3),
             PRIM_GLOW, llList2Integer(gOriginal, i + 1), llList2Float(gOriginal, i + 4),
             PRIM_FULLBRIGHT, llList2Integer(gOriginal, i + 1), llList2Integer(gOriginal, i + 5)]);
    }
}

setVisible(list links, integer visible)
{
    integer i;
    if (!visible)
    {
        for (i = 0; i < llGetListLength(links); ++i)
            llSetLinkAlpha(llList2Integer(links, i), 0.0, ALL_SIDES);
        return;
    }
    integer row;
    for (i = 0; i < llGetListLength(links); ++i)
    {
        integer link = llList2Integer(links, i);
        for (row = 0; row < llGetListLength(gOriginal); row += 6)
        {
            if (llList2Integer(gOriginal, row) == link)
                llSetLinkAlpha(link, llList2Float(gOriginal, row + 3),
                    llList2Integer(gOriginal, row + 1));
        }
    }
}

paintLight(integer link, integer ordinal, float level)
{
    vector c = paletteColor(gPalette, ordinal + gPhase);
    llSetLinkPrimitiveParamsFast(link,
        [PRIM_COLOR, ALL_SIDES, c * level, 1.0,
         PRIM_FULLBRIGHT, ALL_SIDES, (level > 0.15),
         PRIM_GLOW, ALL_SIDES, 0.15 * level]);
}

render()
{
    integer enabled = gLights;
    if (gAuto && !gNight) enabled = FALSE;
    integer n = llGetListLength(gLightsList);
    integer i;
    for (i = 0; i < n; ++i)
    {
        float level = 1.0;
        if (!enabled) level = 0.03;
        else if (gMode == 1 && (gPhase % 2)) level = 0.03;
        else if (gMode == 2) level = 0.25 + (0.15 * (float)(gPhase % 6));
        else if (gMode == 3 && llFrand(1.0) < 0.45) level = 0.08;
        else if (gMode == 4) level = 0.25 + llFrand(0.75);
        paintLight(llList2Integer(gLightsList, i), i, level);
    }
    setVisible(gStars, gStar);
    setVisible(gOrnamentsList, gOrnaments);
}

stopParticles()
{
    llLinkParticleSystem(LINK_SET, []);
    gParticle = "Off";
}

particleEffect(string effect)
{
    stopParticles();
    integer target = LINK_THIS;
    vector color = <1.0, 1.0, 1.0>;
    integer flags = PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK |
        PSYS_PART_EMISSIVE_MASK;
    if (effect == "Snow")
    {
        llLinkParticleSystem(target,
            [PSYS_PART_FLAGS, flags, PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
             PSYS_PART_START_COLOR, color, PSYS_PART_END_COLOR, color,
             PSYS_PART_START_ALPHA, 0.9, PSYS_PART_END_ALPHA, 0.2,
             PSYS_PART_START_SCALE, <0.08,0.08,0.0>, PSYS_PART_END_SCALE, <0.03,0.03,0.0>,
             PSYS_PART_MAX_AGE, 6.0, PSYS_SRC_BURST_RATE, 0.25,
             PSYS_SRC_BURST_PART_COUNT, 6, PSYS_SRC_BURST_RADIUS, 1.5,
             PSYS_SRC_BURST_SPEED_MIN, 0.15, PSYS_SRC_BURST_SPEED_MAX, 0.5,
             PSYS_SRC_ACCEL, <0.0,0.0,-0.2>, PSYS_SRC_MAX_AGE, 0.0]);
    }
    else
    {
        if (effect == "Star" && llGetListLength(gStars)) target = llList2Integer(gStars, 0);
        llLinkParticleSystem(target,
            [PSYS_PART_FLAGS, flags, PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
             PSYS_PART_START_COLOR, <1.0,0.8,0.2>, PSYS_PART_END_COLOR, color,
             PSYS_PART_START_ALPHA, 0.9, PSYS_PART_END_ALPHA, 0.0,
             PSYS_PART_START_SCALE, <0.06,0.06,0.0>, PSYS_PART_END_SCALE, <0.01,0.01,0.0>,
             PSYS_PART_MAX_AGE, 1.5, PSYS_SRC_BURST_RATE, 0.18,
             PSYS_SRC_BURST_PART_COUNT, 3, PSYS_SRC_BURST_RADIUS, 0.25,
             PSYS_SRC_BURST_SPEED_MIN, 0.05, PSYS_SRC_BURST_SPEED_MAX, 0.3,
             PSYS_SRC_MAX_AGE, 0.0]);
    }
    gParticle = effect;
}

playSound(string prefix, integer loop)
{
    integer count = llGetInventoryNumber(INVENTORY_SOUND);
    integer i;
    for (i = 0; i < count; ++i)
    {
        string name = llGetInventoryName(INVENTORY_SOUND, i);
        if (llSubStringIndex(llToUpper(name), llToUpper(prefix)) == 0)
        {
            if (loop) llLoopSound(name, 0.45);
            else llTriggerSound(name, 0.8);
            return;
        }
    }
    llRegionSayTo(gUser, 0, "No sound named " + prefix + "* was found in the tree.");
}

setHover()
{
    if (gHover)
        llSetText("Interactive Christmas Tree Pro\n" + llList2String(MODE_NAMES, gMode),
            <0.2,1.0,0.3>, 1.0);
    else llSetText("", ZERO_VECTOR, 0.0);
}

closeMenu()
{
    if (gListen) llListenRemove(gListen);
    gListen = 0;
    gMenuExpires = 0;
}

openListen(key avatar)
{
    closeMenu();
    gUser = avatar;
    gChannel = -100000 - (integer)llFrand(900000000.0);
    gListen = llListen(gChannel, "", avatar, "");
    gMenuExpires = llGetUnixTime() + MENU_TIMEOUT;
}

mainMenu()
{
    string access = "Public";
    if (gOwnerOnly) access = "Owner";
    llDialog(gUser, "INTERACTIVE CHRISTMAS TREE PRO\nLights: " + (string)gLights +
        " | Mode: " + llList2String(MODE_NAMES, gMode) + "\nAccess: " + access,
        ["Lights", "Patterns", "Colors", "Decor", "Effects", "Sounds",
         "Auto", "Status", "Close"], gChannel);
}

adminMenu()
{
    llDialog(gUser, "Owner settings", ["Access", "Hover", "Defaults", "Restore", "Back"], gChannel);
}

showStatus()
{
    integer free = llGetFreeMemory();
    string s = "Version 1.0.0\nLights/Stars/Ornaments: " + (string)llGetListLength(gLightsList) + "/" +
        (string)llGetListLength(gStars) + "/" + (string)llGetListLength(gOrnamentsList) +
        "\nMode: " + llList2String(MODE_NAMES, gMode) + " / " + llList2String(SPEED_NAMES, gSpeed) +
        "\nParticles: " + gParticle + "\nFree memory: " + (string)free;
    if (gFallbackLight) s += "\nSetup: LINKSET FALLBACK (tag light prims for best results)";
    llRegionSayTo(gUser, 0, s);
}

setDefaults()
{
    gLights = TRUE; gStar = TRUE; gOrnaments = TRUE; gHover = FALSE;
    gAuto = FALSE; gAmbient = FALSE; gSpeed = 1; gMode = 0; gPalette = 0;
    llStopSound(); stopParticles(); setHover(); render();
}

float tickRate()
{
    if (gSpeed == 0) return 1.5;
    if (gSpeed == 2) return 0.25;
    return 0.65;
}

default
{
    state_entry()
    {
        vector sunDirection = llGetSunDirection();
        discoverLinks();
        if (gFallbackLight)
            llOwnerSay("No LIGHT tag was found. The full linkset is being used so controls remain visible. " +
                "For best results, put LIGHT in each light prim's name or description, then reset this script.");
        gNight = (sunDirection.z < 0.0);
        gNextSunCheck = llGetUnixTime() + 60;
        setHover(); render();
        llSetTimerEvent(tickRate());
    }

    changed(integer change)
    {
        if (change & CHANGED_OWNER) llResetScript();
        if (change & CHANGED_LINK)
        {
            restoreOriginal();
            discoverLinks(); render();
        }
        if (change & CHANGED_INVENTORY)
        {
            if (gAmbient) playSound("SOUND_AMBIENT", TRUE);
        }
    }

    touch_start(integer total)
    {
        key who = llDetectedKey(0);
        if (gOwnerOnly && who != llGetOwner())
        {
            llRegionSayTo(who, 0, "This tree is currently owner-controlled.");
            return;
        }
        openListen(who); mainMenu();
    }

    listen(integer channel, string name, key id, string message)
    {
        gMenuExpires = llGetUnixTime() + MENU_TIMEOUT;
        integer owner = (id == llGetOwner());
        if (message == "Close") { closeMenu(); return; }
        if (message == "Back") { mainMenu(); return; }
        if (message == "Lights")
            llDialog(id, "Light controls", ["On", "Off", "Patterns", "Colors", "Speed", "Back"], channel);
        else if (message == "On") { gLights = TRUE; render(); mainMenu(); }
        else if (message == "Off") { gLights = FALSE; render(); mainMenu(); }
        else if (message == "Patterns") llDialog(id, "Choose a pattern", MODE_NAMES + ["Back"], channel);
        else if (llListFindList(MODE_NAMES, [message]) != -1)
        { gMode = llListFindList(MODE_NAMES, [message]); render(); mainMenu(); }
        else if (message == "Colors") llDialog(id, "Choose a palette", PALETTE_NAMES + ["Back"], channel);
        else if (llListFindList(PALETTE_NAMES, [message]) != -1)
        { gPalette = llListFindList(PALETTE_NAMES, [message]); render(); mainMenu(); }
        else if (message == "Speed") llDialog(id, "Animation speed", SPEED_NAMES + ["Back"], channel);
        else if (llListFindList(SPEED_NAMES, [message]) != -1)
        { gSpeed = llListFindList(SPEED_NAMES, [message]); llSetTimerEvent(tickRate()); mainMenu(); }
        else if (message == "Decor") llDialog(id, "Decoration controls", ["Star On", "Star Off", "Ornaments On", "Ornaments Off", "Glow", "Back"], channel);
        else if (message == "Star On") { gStar = TRUE; render(); mainMenu(); }
        else if (message == "Star Off") { gStar = FALSE; render(); mainMenu(); }
        else if (message == "Ornaments On") { gOrnaments = TRUE; render(); mainMenu(); }
        else if (message == "Ornaments Off") { gOrnaments = FALSE; render(); mainMenu(); }
        else if (message == "Glow")
        {
            integer i;
            for (i = 0; i < llGetListLength(gLightsList); ++i)
                llSetLinkPrimitiveParamsFast(llList2Integer(gLightsList, i), [PRIM_GLOW, ALL_SIDES, 0.35]);
            llSetTimerEvent(tickRate()); mainMenu();
        }
        else if (message == "Effects") llDialog(id, "Particle effects", ["Snow", "Sparkle", "Star FX", "FX Off", "Back"], channel);
        else if (message == "Snow") { particleEffect("Snow"); mainMenu(); }
        else if (message == "Sparkle") { particleEffect("Sparkle"); mainMenu(); }
        else if (message == "Star FX") { particleEffect("Star"); mainMenu(); }
        else if (message == "FX Off") { stopParticles(); mainMenu(); }
        else if (message == "Sounds") llDialog(id, "Sound controls", ["Bells", "Cheer", "Ambient On", "Ambient Off", "Back"], channel);
        else if (message == "Bells") { playSound("SOUND_BELLS", FALSE); mainMenu(); }
        else if (message == "Cheer") { playSound("SOUND_CHEER", FALSE); mainMenu(); }
        else if (message == "Ambient On") { gAmbient = TRUE; playSound("SOUND_AMBIENT", TRUE); mainMenu(); }
        else if (message == "Ambient Off") { gAmbient = FALSE; llStopSound(); mainMenu(); }
        else if (message == "Auto") { gAuto = !gAuto; render(); mainMenu(); }
        else if (message == "Status")
        {
            showStatus();
            if (owner) adminMenu(); else mainMenu();
        }
        else if (owner && message == "Access") { gOwnerOnly = !gOwnerOnly; adminMenu(); }
        else if (owner && message == "Hover") { gHover = !gHover; setHover(); adminMenu(); }
        else if (owner && message == "Defaults") { setDefaults(); adminMenu(); }
        else if (owner && message == "Restore") { restoreOriginal(); stopParticles(); llStopSound(); adminMenu(); }
    }

    timer()
    {
        ++gPhase;
        if (gMode || gLights) render();
        integer now = llGetUnixTime();
        if (gListen && now > gMenuExpires) closeMenu();
        if (now >= gNextSunCheck)
        {
            vector sunDirection = llGetSunDirection();
            integer night = (sunDirection.z < 0.0);
            if (night != gNight) { gNight = night; if (gAuto) render(); }
            gNextSunCheck = now + 60;
        }
    }
}
