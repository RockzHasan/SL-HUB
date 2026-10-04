// All child prims whose names begin HH_GHOST are controlled together.
string GHOST_PREFIX = "HH_GHOST";
float VISIBLE_ALPHA = 0.65;
float SHOW_TIME = 4.0;
integer ENABLE_GHOST = TRUE;
list ghostLinks = [];

discover()
{
    ghostLinks = [];
    integer i; integer length = llStringLength(GHOST_PREFIX);
    for (i = 1; i <= llGetNumberOfPrims(); ++i)
        if (llGetSubString(llGetLinkName(i), 0, length - 1) == GHOST_PREFIX) ghostLinks += [i];
}

setGhost(float alpha)
{
    integer i;
    for (i = 0; i < llGetListLength(ghostLinks); ++i)
        llSetLinkPrimitiveParamsFast(llList2Integer(ghostLinks, i), [PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, alpha, PRIM_GLOW, ALL_SIDES, alpha * 0.12, PRIM_FULLBRIGHT, ALL_SIDES, (alpha > 0.0)]);
}

hide()
{
    setGhost(0.0); llSetTimerEvent(0.0);
}

default
{
    state_entry() { discover(); hide(); }
    on_rez(integer start) { llResetScript(); }
    changed(integer change) { if (change & (CHANGED_LINK | CHANGED_OWNER)) llResetScript(); }
    link_message(integer sender, integer number, string message, key id)
    {
        if (number == 200 && ENABLE_GHOST)
        {
            integer scene = (integer)message;
            if (scene == 3 || scene == 4 || scene == 5) { setGhost(VISIBLE_ALPHA); llSetTimerEvent(SHOW_TIME); }
        }
        else if (number == 100 && (message == "SAFE" || message == "RESET")) hide();
    }
    timer() { hide(); }
}
