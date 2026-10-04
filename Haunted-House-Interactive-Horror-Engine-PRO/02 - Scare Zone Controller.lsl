// One copy per zone object/linkset. For best spatial accuracy use a separate invisible prim.
float DETECTION_RANGE = 8.0;
float SCAN_INTERVAL = 2.5;
integer ZONE_COOLDOWN = 20;
integer REQUIRE_NEW_ENTRY = TRUE;
integer DEBUG_MODE = FALSE;

integer LM_ZONE_REQUEST = 110;
integer LM_STATE = 900;
integer enabled = TRUE;
integer automatic = TRUE;
integer safeMode = FALSE;
integer lastTrigger;
list inside = [];

startScanner()
{
    llSensorRemove();
    if (enabled && automatic && !safeMode)
        llSensorRepeat("", NULL_KEY, AGENT, DETECTION_RANGE, PI, SCAN_INTERVAL);
}

processDetections(integer count)
{
    list seen = [];
    integer i;
    integer now = llGetUnixTime();
    for (i = 0; i < count; ++i)
    {
        key avatar = llDetectedKey(i);
        seen += [avatar];
        integer wasInside = (llListFindList(inside, [avatar]) != -1);
        if ((!REQUIRE_NEW_ENTRY || !wasInside) && now - lastTrigger >= ZONE_COOLDOWN)
        {
            lastTrigger = now;
            llMessageLinked(LINK_SET, LM_ZONE_REQUEST, llGetObjectName(), avatar);
            if (DEBUG_MODE) llOwnerSay("[Zone] request for " + llDetectedName(i));
        }
    }
    inside = seen;
}

default
{
    state_entry() { startScanner(); }
    on_rez(integer start) { llResetScript(); }
    changed(integer change) { if (change & CHANGED_OWNER) llResetScript(); }
    sensor(integer count) { processDetections(count); }
    no_sensor() { inside = []; }
    link_message(integer sender, integer number, string message, key id)
    {
        if (number == LM_STATE)
        {
            list fields = llParseStringKeepNulls(message, ["|"], []);
            if (llGetListLength(fields) >= 3)
            {
                enabled = (integer)llList2String(fields, 0);
                safeMode = (integer)llList2String(fields, 1);
                automatic = (integer)llList2String(fields, 2);
                startScanner();
            }
        }
        else if (number == 100 && (message == "SAFE" || message == "RESET"))
        {
            inside = []; if (message == "SAFE") { safeMode = TRUE; startScanner(); }
        }
    }
}
