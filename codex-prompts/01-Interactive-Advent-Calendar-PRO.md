# Interactive Advent Calendar & Daily Reward Network PRO

Creator: RockzHasan

You are an expert production-level Second Life LSL developer.

Create a complete commercial-quality Second Life product named:

**INTERACTIVE ADVENT CALENDAR & DAILY REWARD NETWORK PRO**

This must be a real, production-ready Second Life system, not pseudocode, not an example, and not a partial framework. It must compile successfully in official Second Life LSL and be suitable for Marketplace sale.

## Critical Script Count Rule

Keep the entire product in **ONE MAIN LSL SCRIPT whenever technically possible**.

Preferred:
1. `01 - Advent Calendar Core.lsl`

Optional only if genuinely required:
2. `02 - Advent Remote Module.lsl`

**Maximum scripts: 2.**

Do not create one script per door. Do not create unnecessary child-prim scripts. The ROOT script should control linked calendar doors via link numbers, prim names, touch detection, link parameters, link messages where useful, and Linkset Data.

## Product Purpose

Build a configurable Advent Calendar system for SL stores, Christmas regions, clubs, communities, RP locations, winter festivals, holiday events, and promotional giveaways.

Residents touch the appropriate calendar door and receive that day's configured reward.

## Required Calendar Features

Support:
- December 1–24 mode
- December 1–25 mode
- December 1–31 mode
- custom start/end date
- automatic day detection
- configurable timezone offset
- current/explicit year handling
- same-day-only claiming
- optional missed-day claiming
- future-day lockout
- one claim per avatar per day
- duplicate claim prevention
- public mode
- group-only mode
- owner-only test mode
- staff/admin list
- enable/disable
- manual lock/unlock
- manual day override
- test reward mode

## Linked Door System

Use child prim naming:
`DAY_01`, `DAY_02`, ... up to `DAY_25`, optionally `DAY_31`.

Requirements:
- discover doors by prim name
- never hardcode link numbers
- use touched link number to identify the day
- cache link numbers
- rescan only after link change or manual refresh
- detect missing day prims
- detect duplicate day names
- detect invalid names
- support states: LOCKED, AVAILABLE, CLAIMED, ADMIN TEST
- optional visual state changes using glow, fullbright, color, alpha, and configured textures
- never destroy creator materials/textures unless explicitly configured

## Reward System

Allow each day to have one or multiple inventory rewards.

Support transferable SL inventory types where LSL allows delivery.

Handle:
- objects
- notecards
- landmarks
- textures
- clothing/assets where transferable
- multiple-item packages

Use an easy naming/configuration convention.

Validate inventory before delivery.

Handle safely:
- missing reward
- incorrect name
- no-copy items
- no-transfer limitations
- inventory changed
- empty reward day
- multiple rewards

Warn owner clearly without crashing.

## Persistent Claim Data

Use Linkset Data where suitable.

Track:
- avatar UUID
- claimed days
- total claims
- daily claim count
- optional streak
- optional bonus eligibility

Provide:
- storage status
- reset one avatar
- reset one day
- reset all claims
- clear old year data
- clear stats

Keep storage compact and bounded. Handle write failures/capacity safely.

## Bonus Features

Include configurable:
- streak rewards
- mystery days
- special Christmas Eve reward
- Christmas Day reward
- welcome gift
- final completion reward
- optional group bonus

## Admin Menu

Provide owner/admin menu with:
STATUS, ENABLE, DISABLE, TODAY, MODE, CLAIMS, STATS, TIMEZONE, TEST DAY, UNLOCK, LOCK, RESET USER, RESET DAY, RESET ALL, BLACKLIST, REFRESH, HELP.

Use paginated dialogs if required.
Use randomized negative dialog channels.
Never use channel 0.
Close stale listeners.
Use menu timeout.
Only accept responses from the active menu user.

## Security

Only owner/authorized admins may alter settings, unlock days, reset claims, clear storage, test rewards, or change modes.

Residents must not be able to spoof commands through chat.

## Date/Time Safety

Do not assume SL server time equals customer local time.
Use configurable timezone offset.
Handle midnight and year rollover correctly.
Do not use external APIs.

## Performance

Avoid:
- rapid permanent timers
- unnecessary sensors
- repeated full linkset scans
- excessive listens
- chat spam
- excessive hover-text updates
- unbounded lists
- busy loops

Use event-driven logic.

## Mandatory LSL Audit

Before returning code, check:
- valid LSL syntax only
- valid functions/constants/events
- correct event signatures
- correct argument counts/types
- correct return types
- proper variable scope
- no use-before-declaration
- no duplicate globals/functions
- no illegal nested functions
- no C/C++/JS/Python-only syntax
- correct key/string/int/float/list/vector/rotation handling
- safe list indexes
- safe substring logic
- correct semicolons/braces
- no invented Linden functions
- no fake APIs
- no infinite loops
- no zero-delay timer loops
- no divide by zero
- no listener/timer leaks
- no unsafe malformed message parsing

## Mandatory In-World Review

Logically test:
1. Fresh rez
2. Script reset
3. Object reset
4. Region restart
5. Owner change
6. Take/re-rez
7. Child prim rename/delete/add
8. Duplicate DAY name
9. Missing reward
10. Inventory change
11. Missing sound
12. Multiple simultaneous users
13. Same user rapid touches
14. Duplicate claim
15. Future day access
16. Missed-day access
17. Group/non-group users
18. Admin test
19. Midnight rollover
20. Christmas Day
21. December 31 / January 1
22. Linkset Data nearly full
23. Dialog timeout
24. Menu use during resident claim
25. Malformed data

Correct all issues before final output.

## Final Output

Return:
1. Complete compile-ready LSL script(s)
2. Short explanation of each script
3. Customer Setup Instructions
4. Configuration guide
5. Testing guide
6. Troubleshooting

No pseudocode. No TODOs. No unfinished functions. No external server requirement.

## Customer Setup Instructions Requirement

Include a simple customer guide explaining:
1. Link calendar doors to one ROOT prim.
2. Name doors `DAY_01`, `DAY_02`, etc.
3. Put Advent Calendar Core in the ROOT.
4. Add reward inventory.
5. Configure timezone/calendar mode.
6. Reset the script.
7. Touch ROOT as owner.
8. Run status.
9. Test a day.
10. Enable public mode.

Explain the reward naming convention clearly for non-programmers.
