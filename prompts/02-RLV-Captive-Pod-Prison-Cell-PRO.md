# Smart Captive Pod & Prison Cell Engine PRO

Create a complete production-ready Second Life LSL system named **Smart Captive Pod & Prison Cell Engine PRO** by **RockzHasan**.

## Purpose
Build a reusable creator framework for Second Life cages, prison cells, containment pods, sci-fi chambers, RP jail systems, trap furniture, interrogation rooms, fantasy prisons, and similar interactive builds. It must be fully workable in-world using valid LSL and documented RLV/RLVa-compatible behavior.

## Core Experience
Implement a clear state machine:
IDLE → USER INTERACTION → CONSENT/SESSION → CAPTURED → LOCKDOWN → TIMER/CHALLENGE → RELEASE → CLEANUP

## Required Features
- Touch activation
- Authorized controller activation
- Wearer/prisoner consent where required
- Sit target support and occupant detection
- Door control through linked prims
- Lock/unlock
- Captivity timer and sentence duration
- Random sentence option
- Configurable RLV restrictions
- Sit/stand control where supported
- Teleport, location, chat/emote, inventory/outfit, and camera restriction profiles where supported
- Controller whitelist and temporary guards
- Prisoner status
- Escape challenge
- PIN/code release
- Key-based release API
- Emergency release
- Safeword
- Administrator recovery
- Automatic cleanup

## Escape System
Support OFF, EASY, NORMAL, HARD, RANDOM. Possible mechanics: randomized button sequence, generated PIN challenge, timed interaction challenge, multiple linked controls, or probability-based escape with cooldown. Avoid click spam and region-heavy processing.

## Door/Linkset
Use llMessageLinked for:
DOOR_OPEN, DOOR_CLOSE, LOCK_LIGHT, ALARM, CAPTURE_FX, RELEASE_FX, DISPLAY, SOUND.
Document child-prim naming or link-number configuration.

## RLV/RLVa
Use only documented compatible commands. Gracefully handle viewers without RLV enabled. Never assume a restriction succeeded merely because a command was sent. Keep visual/RP state separate from viewer-enforced state.

## Consent and Access
Provide explicit configurable consent/session handling. Do not grant permanent hidden authority by touch alone. Roles: OWNER, ADMIN, GUARD, OCCUPANT. Validate authorization for every privileged command.

## Timers and Persistence
Use llGetUnixTime() to avoid timer drift. Resolve expired sentences correctly after offline periods. Use linkset data where suitable and store only necessary metadata.

## Recovery
Handle script reset, object reset, region restart, occupant disconnect, occupant stand, controller disconnect, stale RLV state, expired sentence, invalid sitter, and missing/replaced linked components.

## Menus
Main menu:
CAPTURE
RELEASE
SENTENCE
RESTRICTIONS
GUARDS
ESCAPE
STATUS
CONFIG
RECOVERY
Use pagination where necessary and remove listener handles after timeout.

## Performance
Avoid continuous sensors. Prefer event-driven logic. Keep idle script time extremely low.

## Security
Use unpredictable/private session communication where cross-object communication is required. Validate UUIDs and active sessions. Prevent nearby avatar spoofing, unauthorized release/capture/control, stale guard authority, replay of expired commands, and link-message loops.

## Mandatory Error Audit
Before output, perform an exhaustive static/compile review for:
- LSL syntax
- valid events, functions, and constants
- variable scope/initialization
- types/casts
- list stride/index errors
- vectors/rotations
- returns
- listeners and timers
- permissions and sit-target logic
- link-number assumptions
- RLV command syntax
- session security
- state transitions
- reset/recovery
- Unix timestamps
- memory usage
- race conditions

Final pass must explicitly ask: **"Can every supplied script compile in the actual Second Life LSL compiler without modification?"**

Fix every issue found. No pseudocode, imaginary functions, optional dependency unless clearly labeled, or unfinished TODO sections.

Return complete scripts, setup instructions, and a full in-world QA checklist.