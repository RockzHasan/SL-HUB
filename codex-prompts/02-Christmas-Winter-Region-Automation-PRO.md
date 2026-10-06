# Christmas & Winter Region Automation Engine PRO

Creator: RockzHasan

You are an expert production Second Life LSL developer.

Create a complete premium commercial product named:

**CHRISTMAS & WINTER REGION AUTOMATION ENGINE PRO**

The finished system must compile in official Second Life LSL and operate reliably in-world.

## Script Count

Preferred:
1. `01 - Winter Region Core.lsl`
2. `02 - Winter Satellite Receiver.lsl`

Maximum scripts: **2**.

Do not create individual scripts for every light, snow emitter, tree, lamp, fireplace, or decoration. Linked objects should be controlled by the ROOT Core wherever possible. Use the satellite only for separate unlinked objects.

## Purpose

Create centralized automation for:
- Christmas regions
- winter villages
- ski resorts
- clubs
- RP regions
- holiday stores
- parks
- event venues

## Scene Presets

Implement configurable presets:
WINTER_DAY, WINTER_NIGHT, LIGHT_SNOW, MEDIUM_SNOW, HEAVY_SNOW, BLIZZARD, COZY_NIGHT, CHRISTMAS, CHRISTMAS_EVE, CHRISTMAS_DAY, NORTH_POLE, FROZEN, PARTY, NEW_YEAR, OFF.

Scenes may control:
- snow
- particles
- lights
- glow
- fullbright
- fireplaces
- sounds
- decorations
- tree lights
- stars
- texture effects where valid

## Automation

Support:
- manual mode
- auto cycling
- scheduled scenes
- scene durations
- random mode
- next/previous
- pause/resume
- stop
- temporary manual override
- automatic resume
- schedule enable/disable

Use one efficient scheduler. Avoid rapid polling.

## Linked Prim Discovery

Discover/cache child prims using prefixes such as:
`LIGHT_`, `LAMP_`, `TREE_`, `FIRE_`, `SNOW_`, `DECOR_`, `STAR_`, `ICE_`, `CONFETTI_`.

Never hardcode link numbers.
Rescan on CHANGED_LINK or manual refresh.
Handle duplicate/missing names gracefully.

## Snow Particle System

Implement safe configurable presets: LIGHT, MEDIUM, HEAVY, BLIZZARD.

Use valid `llParticleSystem` rules only.

Allow configuration of:
- texture
- size
- lifetime
- velocity
- acceleration
- burst rate
- burst count
- radius

Validate values and stop old effects when switching.

## Lighting / Decor

Use legitimate LSL prim parameters for:
- glow
- fullbright
- point lights
- alpha
- color
- texture animation where enabled

Do not invent material/environment APIs.

## Sound

Support seasonal ambience and scene sounds.
Handle missing sounds safely.
Avoid rapid restarting/audio spam.

## Satellite Receiver

Use one universal receiver in separate objects.

Communication:
- private negative channel
- configurable security token
- controller/event ID
- strict packet validation

Commands may include:
PING, STATUS, SCENE, ON, OFF, SNOW, LIGHT, SOUND, FX, RESET.

Ignore malformed packets, wrong token, wrong controller, and unknown commands.

## Schedule

Support optional date/time triggers for:
- Christmas Eve
- Christmas Day
- New Year's Eve
- custom dates

Use configurable timezone offset.
No external server required.

## Admin Menu

Include:
STATUS, AUTO, MANUAL, SCENES, SNOW, LIGHTS, SOUND, NEXT, PREVIOUS, PAUSE, RESUME, STOP, SCHEDULE, SATELLITES, PING, REFRESH, RESET, HELP.

Use temporary negative dialog channels and cleanup.

## Security

Only owner/configured admin UUIDs may operate admin controls.
Residents cannot spoof automation commands.

## Second Life Limitations

Never claim unsupported EEP/environment control.
Only use actual supported LSL capabilities.
If direct EEP control is not valid/appropriate, use particles, prim lighting, textures, and sound instead and document the limitation.

## Performance

Avoid:
- excessive timers
- constant link scans
- sensors
- rapid region chat
- uncontrolled particles
- unlimited lists
- listener leaks

Use event-driven logic and caching.

## Mandatory Error Audit

Check:
- syntax
- scope
- valid functions/constants/events
- timer logic
- listener lifecycle
- link discovery
- message parsing
- list bounds
- inventory handling
- particles
- sounds
- prim parameter calls

No invented functions or unsupported language syntax.

## In-World Test Scenarios

Test:
1. Fresh rez
2. Core reset
3. Satellite reset
4. Region restart
5. Owner change
6. Link change
7. Missing child prim
8. Duplicate prim name
9. Missing texture
10. Missing sound
11. No satellites
12. Many satellites
13. Wrong token/channel
14. Malformed packet
15. Zero/negative scene duration
16. Empty scene list
17. Pause/resume
18. Manual override
19. Scheduled transition
20. Midnight rollover
21. Christmas Eve/Day
22. New Year
23. Particles OFF
24. Controller take/re-rez

Fix every issue before output.

## Final Output

Return complete compile-ready scripts, then:
- script explanation
- customer setup guide
- prim naming guide
- satellite setup
- configuration
- testing
- troubleshooting

## Customer Setup Instructions Requirement

Explain simply:
1. Put Winter Region Core into ROOT controller.
2. Name linked decoration prims with supported prefixes.
3. Put Satellite Receiver only inside separate unlinked decorations.
4. Match network channel/token.
5. Add optional sounds/textures.
6. Configure scenes.
7. Reset scripts.
8. Run STATUS.
9. Run PING for satellites.
10. Test scenes before AUTO mode.

Keep instructions easy for non-programmers.
