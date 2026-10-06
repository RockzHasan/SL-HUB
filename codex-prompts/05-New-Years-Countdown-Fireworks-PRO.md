# New Year's Eve Countdown & Synchronized Fireworks Engine PRO

Creator: RockzHasan

You are an expert production-quality Second Life LSL developer.

Create a complete premium product named:

**NEW YEAR'S EVE COUNTDOWN & SYNCHRONIZED FIREWORKS ENGINE PRO**

It must be suitable for Second Life clubs, regions, event venues, and parties, compile in official Second Life LSL, and work reliably in-world.

## Script Count

Preferred:
1. `01 - New Year Event Core.lsl`
2. `02 - Fireworks Satellite Receiver.lsl`

Third script only if technically necessary for a separate temporary/rezzed firework object.

**Absolute maximum: 3 scripts.**

Avoid unnecessary script splitting.

## Countdown System

Support:
- configurable target year/month/day/hour/minute
- timezone offset
- automatic countdown
- manual countdown
- test countdown
- arm/disarm
- pause/resume
- post-event state

Milestones:
24 hours, 12 hours, 6 hours, 1 hour, 30 minutes, 10 minutes, 5 minutes, 1 minute, 30 seconds, 10 seconds, 9..1, HAPPY NEW YEAR.

## Intelligent Timer

Do not run a one-second timer all day.

Use adaptive intervals:
- long intervals while hours away
- shorter intervals near event
- one-second intervals only for final countdown
- stop unnecessary timers after event

## Finale Sequence

Create configurable sequence:
- T-60 announcement
- T-30 cue
- T-10 dramatic mode
- final 10-second countdown
- midnight sound
- HAPPY NEW YEAR
- fireworks wave 1
- fireworks wave 2
- fireworks wave 3
- confetti
- lights
- grand finale
- celebration ambience

Allow timing configuration.

## Firework FX

Use legitimate `llParticleSystem` effects wherever appropriate.

Presets may include:
BURST, STAR, RING, SPARKLE, GOLD, MULTI, FINALE.

Particle effects must stop automatically.
Do not use excessive particle rates/counts.
Allow texture/sound configuration.

## Satellite Receivers

Remote emitter objects use the same universal receiver.

Communication:
- private negative channel
- network token
- event/controller ID
- command
- optional sequence number

Commands may include:
PING, STATUS, FIREWORK, LIGHT, CONFETTI, SOUND, OFF, RESET.

Reject malformed or unauthorized messages.

## Linked Stage Prims

Core should discover/cache linked prims such as:
`LIGHT_`, `LASER_`, `CONFETTI_`, `DISPLAY_`, `STAGE_`.

Do not require child scripts for those linked parts.

## Display

Support:
- hover-text countdown
- event status
- optional linked display prim states
- configurable title/messages

Do not invent dynamic text-to-texture APIs. Use valid hover text/texture state alternatives.

## Sound

Support:
- countdown cues
- final 10-second sounds
- midnight celebration
- fireworks sounds
- ambience

Validate inventory.
Avoid repeated audio spam.

## Time Safety

Do not assume SL server time equals customer local timezone.
Use configurable offset correctly.

Handle:
- December 31
- January 1
- target year
- next-year reuse
- midnight rollover
- script reset before/after target
- region restart before/after target

No external time API.

## Anti-Double-Finale Protection

Mandatory.

The real finale must not repeatedly trigger due to:
- timer jitter
- duplicate timer events
- script reset
- region restart
- repeated target checks
- duplicate messages

Persist an event-completed marker where appropriate.

**TEST FINALE must never mark the real event as completed.**

Provide an owner reset for next year's reuse.

## Admin Menu

Include:
STATUS, ARM, DISARM, DATE, TIMEZONE, TEST 60, TEST 10, TEST FINALE, FIREWORK, SATELLITES, PING, SOUND, FX, PAUSE, RESUME, RESET, HELP.

Use randomized negative dialog channel and listener cleanup.

## Optional Rezzed Fireworks

Prefer particle emitters without physical rezzing.

If rezzed firework shells are included because technically useful:
- limit active shells
- temporary shells self-delete
- handle parcel rez disabled
- handle object/parcel limits
- avoid griefing
- use safe velocity
- never push avatars
- provide enable/disable

## Security

Only owner/admin can:
- arm/disarm
- change date
- test
- trigger manual finale
- reset event
- control satellites

Residents must not be able to spoof finale commands.

## Performance

Avoid:
- all-day 1-second timers
- excessive region chat
- uncontrolled particles
- repeated linkset scans
- excess listeners
- unlimited temporary objects

## Mandatory LSL Audit

Check:
- syntax
- event signatures
- valid functions/constants
- parameter/return types
- scope
- timers
- lists
- parsing
- particle settings
- linked prim parameters
- listener lifecycle
- sounds
- date calculations

No invented functions, fake APIs, or non-LSL syntax.

## Mandatory In-World Test Simulation

Test:
1. Event 24 hours away
2. Event 1 hour away
3. T-5 minutes
4. T-60 seconds
5. T-10 seconds
6. Midnight
7. Seconds after midnight
8. Script reset at T-30
9. Script reset after midnight
10. Region restart before midnight
11. Region restart after finale
12. Satellite missing
13. Satellite reset
14. Wrong token
15. Duplicate satellite packet
16. Missing sound
17. Missing particle texture
18. TEST FINALE
19. Real finale after TEST FINALE
20. Duplicate timer event at midnight
21. Wrong timezone
22. Invalid date
23. Owner change
24. Next-year reuse
25. Parcel rez disabled if optional rezzing is enabled

Correct every issue before output.

## Final Output

Return complete compile-ready scripts, then:
- script explanation
- customer setup
- configuration
- satellite setup
- testing
- troubleshooting
- technical limitations

No pseudocode, TODOs, or unfinished code.

## Customer Setup Instructions Requirement

Explain simply:
1. Rez main controller.
2. Put New Year Event Core into ROOT.
3. Name linked stage prims with supported prefixes.
4. Rez remote firework emitters if desired.
5. Put Satellite Receiver in each remote emitter.
6. Match channel/token/event ID.
7. Add configured sounds/textures.
8. Set target date/time/timezone.
9. Reset scripts.
10. Run PING.
11. Test TEST 10.
12. Test TEST FINALE.
13. Verify particles stop.
14. ARM the real countdown.

Clearly state TEST FINALE does not consume the real event.
