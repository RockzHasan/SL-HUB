# Winter Resort & Snow Games Engine PRO

Creator: RockzHasan

You are an expert production-quality Second Life LSL developer.

Create a complete commercial product named:

**WINTER RESORT & SNOW GAMES ENGINE PRO**

It must be suitable for ski resorts, skating areas, winter events, snow regions, and competitions, and compile in official Second Life LSL.

## Script Limit

Maximum scripts: **3**.

Preferred:
1. `01 - Winter Games Core.lsl`
2. `02 - Universal Course Gate.lsl`
3. `03 - Optional Snowball Game Module.lsl`

Do not create separate scripts for START, CHECKPOINT, FINISH, or collectible gates. One Universal Course Gate must support all gate types through configuration.

## Game Modes

Support:
- Ski race
- Sled race
- Skating time trial
- Snowboard-style race
- Snowflake collection
- Snowball battle
- Team tournament
- Practice

## Race System

Implement:
- player registration
- start gate
- numbered checkpoints
- finish gate
- ordered validation
- configurable laps
- race timing
- personal best
- round best
- leaderboard
- DNF timeout
- restart
- optional time penalties
- tournament rounds

## Universal Gate

Configuration:
- COURSE_ID
- GATE_ID
- GATE_TYPE
- CHECKPOINT_NUMBER
- TOTAL_CHECKPOINTS

Supported gate types:
START, CHECKPOINT, FINISH, COLLECTIBLE.

Use touch/collision/volume detection as technically appropriate.
Do not constantly sensor-scan avatars.

## Anti-Cheat Validation

Core verifies:
- active session
- player UUID
- course ID
- session ID
- expected checkpoint order
- lap
- duplicate gate hit suppression
- plausible minimum elapsed time
- finish eligibility

Never market as impossible to cheat.

## Collectible Mode

Support:
- unique collectible ID
- duplicate prevention per round
- collection count
- points
- completion bonus
- round reset

## Snowball Battle

If the third script is included, make it an optional reusable Snowball Game Module.

Requirements:
- explicit player opt-in
- only registered players score hits
- safe cooldown
- no avatar pushing
- no griefing
- no damage requirement
- no forced animation
- no forced attachments
- no excessive object rezzing
- range validation
- hit cooldown
- team validation

Use only legitimate Second Life mechanics.

## Tournament

Support:
- solo
- teams
- practice
- timed tournament
- countdown
- round start
- round finish
- winner
- leaderboard
- optional prize

## Rewards

Optional inventory prizes.

Validate:
- prize exists
- player legitimately won
- prize not previously issued
- copy/transfer limitations

## Communication

Gates communicate with Core via secure private negative channel with token/course-controller ID, or via link messages when linked.

Validate every packet and list length before indexing.

## Admin Menu

Include:
STATUS, GAME MODE, COURSE, START ROUND, STOP, PLAYERS, TEAMS, SCORES, LEADERBOARD, GATES, PING, REWARDS, RESET, DEBUG, HELP.

Use secure temporary negative dialog channels and listener cleanup.

## Player Safety

Do not:
- force teleport
- push avatars
- force camera
- spam dialogs
- force animations without proper permission
- attach items without permission

Collect only data needed for the game.

## Performance

Avoid:
- rapid timers
- sensor loops
- uncontrolled collision spam
- huge/unbounded lists
- unlimited leaderboard history
- excessive region chat

Throttle gate events and expire abandoned race sessions.

## Mandatory Compile Review

Verify:
- valid LSL syntax
- valid functions/constants/events
- correct scope
- correct return types
- correct arguments
- safe list indexes
- safe parsing
- timer/listener cleanup
- collision handling
- protocol consistency
- no invented APIs
- no unsupported C/JS/Python syntax

## In-World Testing

Logically test:
1. Fresh rez
2. Start gate hit twice
3. Two players start simultaneously
4. Many avatars cross same gate
5. Wrong checkpoint
6. Skipped checkpoint
7. Finish early
8. Correct full race
9. Multiple laps
10. Gate reset
11. Core reset
12. Region restart
13. Player leaves
14. Player relogs
15. Duplicate GATE_ID
16. Wrong COURSE_ID
17. Missing finish gate
18. Zero checkpoints
19. Zero laps
20. Negative/invalid minimum time
21. Tournament stopped mid-round
22. Missing prize
23. Snowball vs unregistered target
24. Rapid snowball spam
25. Owner change

Fix all discovered issues before output.

## Final Output

Return:
- complete compile-ready scripts
- explanation
- configuration guide
- customer setup
- gate setup
- race testing guide
- snowball setup if included
- troubleshooting

No pseudocode, TODOs, fake functions, or unfinished sections.

## Customer Setup Instructions Requirement

Include a simple guide:
1. Rez main controller.
2. Add Winter Games Core.
3. Rez START/CHECKPOINT/FINISH gates.
4. Add the same Universal Course Gate script to each.
5. Set COURSE_ID.
6. Set gate type.
7. Number checkpoints in order.
8. Match communication settings.
9. Reset all scripts.
10. Run PING/GATES.
11. Complete a full test race.
12. Enable public/tournament mode.

Explain everything for customers with minimal scripting knowledge.
