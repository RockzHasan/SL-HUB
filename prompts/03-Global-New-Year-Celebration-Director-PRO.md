You are a senior LSL engineer specializing in large Second Life event systems.

Build a commercial-quality FULL-PERMISSION product:

GLOBAL NEW YEAR CELEBRATION DIRECTOR PRO

Creator: RockzHasan

This should NOT be just a basic New Year countdown script.

Create a professional multi-time-zone celebration automation and synchronized event-control framework for clubs, regions, cities, event venues and virtual communities.

==================================================
CONCEPT
==================================================

The system should coordinate New Year celebrations for multiple world time zones.

Example celebration progression:

SYDNEY
TOKYO
DHAKA
DUBAI
PARIS
LONDON
NEW YORK
CHICAGO
LOS ANGELES
HONOLULU

Make zone list configurable.

Do not hard-code the product permanently to one year.

Determine target New Year dynamically/configurably.

==================================================
CORE MODULES
==================================================

Recommended:

01 - Global Celebration Master
02 - Timezone / Schedule Engine
03 - Countdown Display
04 - FX Director
05 - Firework Node
06 - Sound / Music Trigger
07 - Lighting Controller
08 - Region Node Network
09 - Attendance / Reward Manager
10 - Admin & Diagnostics

Use modular architecture.

==================================================
TIME ENGINE
==================================================

This is CRITICAL.

LSL provides Unix time / UTC-oriented time functions but does not automatically provide a complete modern timezone/DST database.

Therefore:

Implement a safe configurable UTC-offset schedule system.

Do NOT fabricate automatic timezone APIs that do not exist.

Allow each celebration profile to specify:

CITY_NAME
UTC_OFFSET
TARGET_LOCAL_DATE
TARGET_LOCAL_TIME
SCENE_NAME
ENABLED

For fixed New Year midnight events, calculate UTC trigger timestamps safely.

Examples should be configurable rather than blindly hard-coded.

Handle positive and negative UTC offsets.

Handle half-hour and quarter-hour offsets if practical.

Examples:

UTC+05:30
UTC+05:45
UTC+06:00

Never assume every timezone uses whole hours.

==================================================
COUNTDOWN
==================================================

Countdown stages:

24 HOURS
12 HOURS
6 HOURS
1 HOUR
30 MIN
10 MIN
5 MIN
60 SEC
30 SEC
10 SEC
9
8
7
6
5
4
3
2
1
HAPPY NEW YEAR

Do not use a constant one-second timer during the entire multi-day countdown.

Use adaptive timer scheduling.

Only increase update frequency close to event.

==================================================
DISPLAY
==================================================

Support linked display prims and/or hover text.

Show:

City
Local target
Time remaining
Next celebration
Celebrations completed

Keep hover text within reasonable size.

If using linked number/texture displays, make implementation configurable and document prim naming.

==================================================
MULTI-TIME-ZONE EVENT QUEUE
==================================================

Build upcoming celebrations list.

Sort by UTC trigger time.

After one celebration completes:

mark complete
advance next
prepare next scene

If multiple zones share same UTC midnight, group or safely process simultaneous scenes.

Do not accidentally trigger the same city twice after script reset.

Persist completed state where appropriate.

==================================================
SCENE DIRECTOR
==================================================

Each city/timezone can trigger a configured scene.

Example:

SYDNEY_GOLD
TOKYO_NEON
DHAKA_GREEN_RED
DUBAI_LUXURY
LONDON_BELLS
NYC_BALLDROP
LA_LIGHTSHOW
FINALE

Scenes send event commands to FX modules/nodes.

==================================================
FIREWORK SYSTEM
==================================================

Create configurable synchronized firework nodes.

Patterns may include:

BURST
RING
SPIRAL
GOLD
MULTI
FINALE

Use valid llParticleSystem functionality.

Do not create uncontrolled particle spam.

Support performance modes.

Provide global KILL FX command.

==================================================
REGION-WIDE NODES
==================================================

Allow separate objects around an event venue/region.

Master broadcasts authenticated commands.

Node packet should contain:

NETWORK_ID
VERSION if helpful
SEQUENCE/TIMESTAMP if helpful
COMMAND
SCENE
AUTH TOKEN

Validate message before acting.

Prevent random residents from sending:

FIRE
FINALE
RESET

Never use channel 0 for control.

==================================================
NODE TYPES
==================================================

FIREWORK
LIGHT
SOUND
DISPLAY
FOG
PARTICLE
DECOR
CUSTOM

Node should have configurable NODE_ID.

Master status can show registered/active nodes where practical.

==================================================
MUSIC / SOUND
==================================================

Allow sounds to be triggered at milestones.

Validate inventory.

Avoid overlapping long sounds incorrectly.

Do not claim frame-perfect multi-object audio synchronization if LSL cannot guarantee it.

Use best practical synchronization.

==================================================
ATTENDANCE / REWARDS
==================================================

Optional attendance rewards.

Resident may register/check in.

At configured celebration, eligible attendees can claim reward.

Exactly-once reward protection.

Modes:

PUBLIC
GROUP
VIP
ACCESS_LIST

Do not spam every avatar in region.

==================================================
NEW YEAR ROLLOVER
==================================================

The system must work beyond a single named year.

Provide:

AUTO NEXT YEAR

or configurable target year.

After event finishes, owner can prepare next year without rewriting code.

Correctly handle Dec 31 → Jan 1.

==================================================
ADMIN MENU
==================================================

STATUS
NEXT CITY
SCHEDULE
AUTO
MANUAL
TRIGGER
COUNTDOWN
FX
NODES
SOUND
REWARDS
TEST
RESET
DEBUG
HELP

MANUAL TRIGGER should allow testing scenes without marking real celebration complete unless explicitly chosen.

==================================================
TEST MODE
==================================================

Essential.

Owner can simulate:

T-1 HOUR
T-10 MIN
T-60 SEC
T-10 SEC
MIDNIGHT
CITY SCENE
FINALE

Test mode should not corrupt real schedule state.

==================================================
FAIL-SAFE
==================================================

If controller resets near midnight:

reconstruct schedule from timestamps
determine whether event already passed
prevent unintentional duplicate reward/scene where stored completion data exists

If persistent state is unavailable/corrupt:

fail safely
notify owner

==================================================
EMERGENCY STOP
==================================================

One command:

EMERGENCY STOP

All cooperating nodes should stop:

particles
sounds
temporary FX
timers where appropriate

==================================================
PERFORMANCE
==================================================

Use adaptive timers.

Example logic:

Far from event = long interval
Near event = shorter interval
Final minute = approximately one-second updates if required

Do NOT maintain one-second polling for weeks.

Avoid constant network heartbeat spam.

Avoid repeatedly rebuilding schedule lists.

==================================================
DATE/TIME ERROR AUDIT
==================================================

Pay particular attention to:

Unix timestamp math
UTC offsets
negative offsets
half-hour offsets
quarter-hour offsets
date rollovers
Dec 31 → Jan 1
leap years where date utilities matter
month lengths
sorting timestamps
events occurring at identical UTC timestamps
script reset before/after trigger
duplicate triggers
missed triggers
clock comparison boundaries

Do not implement timezone rules by guessing.

If DST rules are not available natively, require explicit offsets in configuration and document this honestly.

==================================================
FULL LSL COMPILATION AUDIT
==================================================

Before final output, inspect every generated script line-by-line for:

LSL syntax
semicolons
braces
scope
variables
functions
event signatures
return types
built-in signatures
valid constants
list operations
list indexing
strings
key types
vector/rotation syntax
casts
timestamps
link messages
listener lifecycle
timers
sensors if any
inventory checks
permissions
changed events
owner change
link change
remote network protocol

Specifically eliminate:

nonexistent functions
invented constants
JavaScript/Python/C++ syntax
unsupported data structures
pseudo-code
invalid switch constructs if unsupported
invalid exception handling
bad list indexing
out-of-range accesses
zero-length random ranges
divide/modulo by zero
infinite loops
rapid timers
listener leaks
event queue flooding
recursive linked messages
network echo loops
duplicate fireworks
duplicate rewards
timezone double triggers
malformed UTC offsets
message spoofing
authorization bypass
NULL_KEY errors
stale menu users
simultaneous dialog collisions
debug spam
particle spam
sound spam
memory growth
oversized persistent records
unsafe reset behavior

Perform at least TWO internal audit passes:

PASS 1:
Compile/syntax/API validity.

PASS 2:
Runtime/logic/security/performance/date-time edge cases.

Correct all issues found before displaying code.

==================================================
CURRENT LSL REQUIREMENT
==================================================

When uncertain whether a function/event/constant exists, verify against current Second Life LSL documentation.

Do not invent an API.

Only write code that should compile in the official Second Life LSL compiler.

==================================================
OUTPUT FORMAT
==================================================

Give:

1. Architecture
2. Object/linkset arrangement
3. Configuration
4. Time calculation strategy
5. Network protocol
6. Complete Script 01
7. Complete Script 02
8. Every remaining complete script
9. Example worldwide schedule
10. Installation instructions
11. Testing instructions
12. Admin guide
13. Performance tuning
14. Troubleshooting
15. Final PASS 1 audit results
16. Final PASS 2 audit results

Do not truncate code.

Do not say "remaining code omitted".

Do not use pseudo implementations.

Creator: RockzHasan
Product: Global New Year Celebration Director PRO