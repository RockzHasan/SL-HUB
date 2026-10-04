// Name light/emitter child prims HH_LIGHT and HH_EMITTER.
string LIGHT_NAME = "HH_LIGHT";
string EMITTER_NAME = "HH_EMITTER";
string SCARE_SOUND = ""; // inventory sound name or UUID; blank disables audio
vector LIGHT_COLOR = <1.0, 0.05, 0.02>;
float LIGHT_INTENSITY = 1.0;
float FX_DURATION = 2.5;
integer ENABLE_SOUND = TRUE;
integer ENABLE_LIGHT = TRUE;
integer ENABLE_PARTICLES = TRUE;
integer lightLink;
integer emitterLink;

integer findLink(string wanted)
{
    integer i; for (i = 1; i <= llGetNumberOfPrims(); ++i) if (llGetLinkName(i) == wanted) return i;
    return 0;
}

stopFX()
{
    llStopSound();
    if (lightLink) llSetLinkPrimitiveParamsFast(lightLink, [PRIM_POINT_LIGHT, FALSE, LIGHT_COLOR, 0.0, 10.0, 0.75, PRIM_FULLBRIGHT, ALL_SIDES, FALSE, PRIM_GLOW, ALL_SIDES, 0.0]);
    if (emitterLink) llLinkParticleSystem(emitterLink, []);
    llSetTimerEvent(0.0);
}

default
{
    state_entry() { lightLink = findLink(LIGHT_NAME); emitterLink = findLink(EMITTER_NAME); }
    on_rez(integer start) { llResetScript(); }
    changed(integer change) { if (change & (CHANGED_LINK | CHANGED_OWNER)) llResetScript(); }
    link_message(integer sender, integer number, string message, key id)
    {
        if (number == 200)
        {
            if (ENABLE_SOUND && SCARE_SOUND != "") llTriggerSound(SCARE_SOUND, 1.0);
            if (ENABLE_LIGHT && lightLink) llSetLinkPrimitiveParamsFast(lightLink, [PRIM_POINT_LIGHT, TRUE, LIGHT_COLOR, LIGHT_INTENSITY, 10.0, 0.75, PRIM_FULLBRIGHT, ALL_SIDES, TRUE, PRIM_GLOW, ALL_SIDES, 0.12]);
            if (ENABLE_PARTICLES && emitterLink) llLinkParticleSystem(emitterLink,
                [PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK,
                PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE, PSYS_PART_START_COLOR, <0.4, 0.4, 0.4>,
                PSYS_PART_END_COLOR, <0.02, 0.02, 0.02>, PSYS_PART_START_ALPHA, 0.55,
                PSYS_PART_END_ALPHA, 0.0, PSYS_PART_START_SCALE, <0.5, 0.5, 0.0>,
                PSYS_PART_END_SCALE, <2.0, 2.0, 0.0>, PSYS_PART_MAX_AGE, 2.0,
                PSYS_SRC_BURST_RATE, 0.15, PSYS_SRC_BURST_PART_COUNT, 4,
                PSYS_SRC_BURST_SPEED_MIN, 0.1, PSYS_SRC_BURST_SPEED_MAX, 0.6,
                PSYS_SRC_MAX_AGE, FX_DURATION, PSYS_SRC_TEXTURE, ""]);
            llSetTimerEvent(FX_DURATION);
        }
        else if (number == 100 && (message == "SAFE" || message == "RESET")) stopFX();
    }
    timer() { stopFX(); }
}
