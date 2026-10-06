# Global New Year Celebration Director PRO

Create a complete production-ready Second Life LSL system named **Global New Year Celebration Director PRO** by **RockzHasan**.

## Purpose
Build a reusable creator framework for New Year countdown stages, club events, public plazas, private venues, rooftop parties, roleplay city celebrations, and synchronized multi-region fireworks shows. It must function in real Second Life in-world conditions using valid LSL and documented viewer-compatible behavior.

## Core Experience
Implement a clear event state machine:
IDLE -> SCHEDULED -> PREPARE -> PRE-SHOW -> COUNTDOWN -> MIDNIGHT TRIGGER -> CELEBRATION -> COOL-DOWN -> RESET

## Required Features
- Event scheduling by UTC timestamp and optional local offset labels for display
- Manual start/abort controls for authorized operators
- Countdown display (days/hours/minutes/seconds)
- 10-minute, 5-minute, 1-minute, and final 10-second milestone callouts
- Synchronized midnight trigger across linked components
- Fireworks sequence controller with multiple pattern presets
- Particle and sound cue orchestration
- Stage light/prim glow color transitions by linked-message signals
- Optional confetti burst timing
- Greeting/message broadcaster with configurable lines
- DJ/host announcement cue list
- Zone-safe audience notification channels
- Staff roles: OWNER, ADMIN, HOST, TECH
- Temporary event operator access with expiry
- Whitelist and blacklist support
- Emergency stop and safe reset
- Post-event cleanup and auto-return to IDLE

## Time and Scheduling
Use llGetUnixTime() for all countdown and trigger calculations.

Support:
- One-time scheduled event
- Daily recurring event (optional)
- Test mode with shortened countdown
- Grace window for delayed script start or region hiccups

Never rely on timer drift-prone arithmetic without timestamp correction.

## Synchronization
Use secure, session-scoped synchronization where cross-object communication is needed.

Validate:
- sender UUID
- authorized role
- active event session ID
- command type
- command timestamp/expiry

Reject stale, malformed, or unauthorized trigger messages.

## Linkset Messaging
Use llMessageLinked for orchestration signals such as:
PREPARE
COUNTDOWN_TICK
MILESTONE_10M
MILESTONE_5M
MILESTONE_1M
MILESTONE_10S
MIDNIGHT
FIREWORKS_START
LIGHTS_SHIFT
CONFETTI
SOUND_CUE
STOP_ALL
RESET

Avoid linked-message feedback loops.

## Menus
Create clean dialog menus with pagination where necessary.

Suggested main menu:
SCHEDULE
START NOW
ABORT
COUNTDOWN
SHOW FX
MESSAGES
ACCESS
STATUS
RECOVERY

Menus must timeout safely and remove listeners.

## Performance
Minimize:
- always-on listeners
- high-frequency timers
- unnecessary particle spam
- repeated llOwnerSay/llRegionSay noise
- avoidable list growth

Use event-driven logic where possible and keep idle script time low.

## Reliability and Recovery
Handle:
- script reset
- region restart
- object relink/re-rez scenarios where feasible
- clock drift edge cases
- missed milestone while region was lagged
- stale operator sessions
- half-finished FX state after abort

Persist only necessary non-sensitive settings using valid in-world techniques such as linkset data when appropriate.

## Security
Do not grant hidden permanent control through public interaction alone.

Require explicit authorization checks for all privileged actions including schedule edits, manual triggers, FX controls, and abort/reset operations.

Prevent:
- unauthorized show starts/stops
- replay of old trigger messages
- forged operator commands
- accidental duplicate midnight triggers

## Mandatory Error Audit
Before returning final code, perform an exhaustive static/compile review for:
- LSL syntax
- valid functions/events/constants
- variable declarations and scope
- list indexing/stride mistakes
- type-cast correctness
- timer lifecycle bugs
- listener leaks
- linked-message parameter correctness
- race conditions at trigger boundaries
- state transition consistency
- timestamp math errors
- security/authorization bypass paths
- memory growth risks

Final verification question must be:
**"Can every supplied script compile in the actual Second Life LSL compiler without modification?"**

Fix all discovered issues before output. Do not return pseudocode, imaginary APIs, or incomplete TODO blocks.

Return complete scripts, setup instructions, and an in-world QA checklist covering schedule setup, countdown milestones, midnight trigger sync, fireworks and FX execution, abort flow, recovery after reset/restart, role-based access checks, and anti-replay validation.
