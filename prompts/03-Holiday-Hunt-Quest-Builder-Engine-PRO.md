# Holiday Hunt & Quest Builder Engine PRO

Create a professional FULL-PERMISSION commercial Second Life LSL system named **Holiday Hunt & Quest Builder Engine PRO** by **RockzHasan**.

You are an expert Second Life LSL game-system developer. This must be a GENERAL PURPOSE hunt/quest framework, not Christmas-only. No external web server is required.

## Use Cases
Christmas, Halloween, Easter egg, treasure, store, anniversary hunts; region quests; roleplay missions; puzzle trails; adventure events.

## Architecture
Modular scripts (use only as many as useful):
01 Quest Master Core, 02 Player Progress Manager, 03 Hunt Checkpoint Node, 04 Puzzle/Question Node, 05 Reward Manager, 06 Score/Leaderboard Manager, 07 Team Manager, 08 Hint Manager, 09 Admin Controller, 10 Diagnostics.

## Quest Modes
SEQUENTIAL (N+1 not completable before N), OPEN_WORLD (any order), RANDOM_ROUTE (per-player randomized valid route), TIMED (configurable time), POINT_BASED, TEAM, SOLO.

## Player Registration
Register at master controller; track by avatar UUID. Store: UUID, optional display-safe name, start time, current stage, completed stages, score, hints used, elapsed time, team ID, reward status. Use efficient persistent storage (Linkset Data if officially supported). Do not invent database APIs.

## Checkpoint Nodes
Config: QUEST_ID, NODE_ID, NODE_TYPE, SEQUENCE, POINTS, NEXT_NODE, HINT, RADIUS, ACTIVE, SECRET TOKEN / NETWORK ID.
Types: TOUCH, PROXIMITY, QUESTION, PUZZLE, ITEM, TIMED, FINAL.
Nodes communicate safely with master; prevent spoofing via normal chat.

## Question / Puzzle System
Multiple-choice riddles (question, answers A-D, correct answer). Randomize button order without breaking validation. Paginated dialogs if needed. Handle dialog timeout, clean listeners, isolate each player session (no shared dialog state).

## Hint System
Hints may cost points, add time penalty, be limited, free, or disabled. Track hint use per resident.

## Random Routes
Generate a valid route from configured nodes. Prevent duplicate nodes, impossible routes, missing final node, broken sequence. Report invalid configuration to admin; never fail silently.

## Team Mode
Optional teams: creation, join code, team score, team progress, shared or individual checkpoint behavior. UUID-based only, never avatar-name matching.

## Timing
Use Unix timestamps; no one-second timers just to count elapsed time; compute durations from timestamps; reliable expiration handling.

## Scoring
Configurable: checkpoint points, puzzle points, time bonus, hint penalty, wrong-answer penalty, completion bonus. Prevent corruption via duplicate node triggers.

## Leaderboard
Local, configurable max entries. Show rank, player, score, completion time. Avoid oversized hover text. Owner can clear. Persistent where practical.

## Rewards
Inventory prize, bonus prize, random prize, team prize. Validate inventory before delivery. Exactly-once protection; repeated FINAL clicks must not give unlimited copies unless owner enables repeat rewards.

## Event Protection
Prevent: checkpoint replay abuse, chat packet spoofing, reward duplication, score duplication, unauthorized reset commands, UUID impersonation, out-of-order sequential completion, fake node IDs, node ID collision.

## Admin Menu
START EVENT, STOP EVENT, PAUSE, MODE, PLAYERS, NODES, LEADERBOARD, RESET PLAYER, RESET ALL, TEST NODE, REWARDS, STATUS, DEBUG, HELP. Dangerous resets require confirmation.

## Node Discovery
Master maintains registered nodes. Nodes advertise carefully at startup or on request; no broadcast storms. Handle duplicate NODE_ID. Report missing node sequences.

## Event Themes
Engine independent of theme. Profiles: CHRISTMAS, HALLOWEEN, EASTER, TREASURE, CUSTOM. Only presentation and default messages depend on theme.

## Mandatory Compiler + Logic Audit
Before output, inspect EVERY script for: LSL grammar, syntax, semicolons, braces, scope, shadowing, undefined/duplicate functions, return types, event signatures/placement, valid constants and built-ins, argument order, parameter types, casts, keys/lists/vectors/rotations/strings, integer overflow, timestamp logic, link messages, listeners, sensors, inventory, permissions, changed events. Reject any invented/non-LSL feature.

Also check runtime logic: empty lists, invalid indexes, stride errors, invalid/duplicate node IDs, random selection from zero elements, modulo zero, missing questions/correct answers, unanswered dialogs, stale listeners, multi-player dialog collisions, team state collisions, timer conflicts, races, double rewards/points/checkpoint completion, sequence bypass, malformed or spoofed packets, public-channel commands, UUID errors, NULL_KEY, owner change, region restart, script reset, re-rez, inventory/linkset modification, memory exhaustion, unbounded player lists, huge leaderboards, high-frequency polling, sensor spam, event queue flooding, recursive communication, debug spam.

For persistent records: validate serialized data before parsing; never assume llParseString2List returns the expected field count; bounds-check every field.

## LSL Compatibility
Use ONLY functions/events/constants existing in current Second Life LSL. Implement any helper yourself in valid LSL. No JavaScript objects, Python dicts, C structs, classes, threads, async/await, exceptions, or regex APIs. If requirements exceed LSL limits, implement the closest robust alternative and document it.

## Code Quality
Descriptive names; comment complex logic; central constants for link message codes; no magic numbers; no giant duplicated blocks; explicit security-sensitive code; efficient lists.

## Output
1. Architecture
2. Component list
3. Node setup
4. Configuration format
5. Network protocol
6. COMPLETE source of Script 01
7. COMPLETE source of Script 02
8. All remaining scripts
9. Example Christmas Hunt configuration
10. Example Treasure Hunt configuration
11. Setup guide
12. Customer guide
13. Troubleshooting
14. Performance notes
15. Final error/compile audit

No placeholders, pseudocode, or unfinished functions.

Creator: RockzHasan
Product: Holiday Hunt & Quest Builder Engine PRO
