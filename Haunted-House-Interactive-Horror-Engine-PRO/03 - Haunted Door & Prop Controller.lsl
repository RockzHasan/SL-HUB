// Names are exact, case-sensitive linked-prim names. Keep controlled prims nonphysical.
string DOOR_NAME = "HH_DOOR";
string PROP_NAME = "HH_PROP";
vector DOOR_OFFSET = <0.0, 0.0, 0.0>;
rotation DOOR_ROTATION = <0.0, 0.0, 0.7071068, 0.7071068>; // 90 degrees local
vector PROP_OFFSET = <0.0, 0.0, 0.20>;
float RETURN_DELAY = 3.0;
integer ENABLE_DOOR = TRUE;
integer ENABLE_PROP = TRUE;

integer doorLink;
integer propLink;
vector doorPos;
rotation doorRot;
vector propPos;
rotation propRot;
integer active;

integer findLink(string wanted)
{
    integer i;
    for (i = 1; i <= llGetNumberOfPrims(); ++i)
        if (llGetLinkName(i) == wanted) return i;
    return 0;
}

captureHome()
{
    doorLink = findLink(DOOR_NAME);
    propLink = findLink(PROP_NAME);
    if (doorLink) { doorPos = llList2Vector(llGetLinkPrimitiveParams(doorLink, [PRIM_POS_LOCAL]), 0); doorRot = llList2Rot(llGetLinkPrimitiveParams(doorLink, [PRIM_ROT_LOCAL]), 0); }
    if (propLink) { propPos = llList2Vector(llGetLinkPrimitiveParams(propLink, [PRIM_POS_LOCAL]), 0); propRot = llList2Rot(llGetLinkPrimitiveParams(propLink, [PRIM_ROT_LOCAL]), 0); }
}

restore()
{
    if (doorLink) llSetLinkPrimitiveParamsFast(doorLink, [PRIM_POS_LOCAL, doorPos, PRIM_ROT_LOCAL, doorRot]);
    if (propLink) llSetLinkPrimitiveParamsFast(propLink, [PRIM_POS_LOCAL, propPos, PRIM_ROT_LOCAL, propRot]);
    active = FALSE; llSetTimerEvent(0.0);
}

default
{
    state_entry() { captureHome(); }
    on_rez(integer start) { llResetScript(); }
    changed(integer change) { if (change & (CHANGED_LINK | CHANGED_OWNER)) llResetScript(); }
    link_message(integer sender, integer number, string message, key id)
    {
        if (number == 200)
        {
            integer scene = (integer)message;
            if (ENABLE_DOOR && doorLink && (scene == 1 || scene == 4))
                llSetLinkPrimitiveParamsFast(doorLink, [PRIM_POS_LOCAL, doorPos + DOOR_OFFSET, PRIM_ROT_LOCAL, doorRot * DOOR_ROTATION]);
            if (ENABLE_PROP && propLink && (scene == 2 || scene == 4))
                llSetLinkPrimitiveParamsFast(propLink, [PRIM_POS_LOCAL, propPos + PROP_OFFSET]);
            active = TRUE; llSetTimerEvent(RETURN_DELAY);
        }
        else if (number == 100 && (message == "SAFE" || message == "RESET")) restore();
    }
    timer() { if (active) restore(); }
}
