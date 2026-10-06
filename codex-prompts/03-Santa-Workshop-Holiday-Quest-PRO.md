# Santa Workshop & Holiday Quest Engine PRO

Creator: RockzHasan

You are an expert commercial Second Life LSL developer.

Create a complete in-world Christmas roleplay/game engine named:

**SANTA WORKSHOP & HOLIDAY QUEST ENGINE PRO**

It must be production-ready, compile in official Second Life LSL, and be suitable for Marketplace sale.

## Script Count Limit

Maximum scripts: **3**.

Preferred:
1. `01 - Santa Workshop Core.lsl`
2. `02 - Universal Workshop Station.lsl`
3. `03 - Optional Leaderboard Display.lsl`

Only include #3 if genuinely useful.

Do not create different scripts for Assembly, Wrapping, Testing, Sorting, Loading, etc. One configurable station script must support all station types.

## Player Flow

Player:
1. joins workshop
2. receives task/order
3. goes to required station
4. completes task
5. advances
6. completes order
7. earns points
8. builds streak
9. earns achievements/rewards
10. appears on leaderboard

Example:
ASSEMBLY -> TESTING -> WRAPPING -> SORTING -> SLEIGH_LOADING -> COMPLETE

## Station Types

Universal station should support:
ASSEMBLY, TESTING, WRAPPING, SORTING, PACKING, QUALITY, LOADING, WISH_DESK, BONUS.

Each station must have configurable `STATION_ID` and `STATION_TYPE`.

## Quest Engine

Support:
- fixed chains
- random chains
- easy/normal/hard
- timed orders
- daily challenge
- bonus challenge
- individual play
- optional team play
- retry
- failure
- cooldown
- perfect-order bonus
- streak/combo
- random reward
- seasonal achievements

## Core Validation

The Core is authoritative.

Validate:
- player UUID
- session ID
- quest/order ID
- station ID
- expected stage
- duplicate completion
- timeout

Players must not skip stages.

## Communication

For unlinked stations use:
- private negative channel
- security token
- controller ID
- compact packet format

Before list indexing, validate packet field count.

Reject:
- malformed data
- wrong token
- wrong controller
- wrong station
- stale/replayed completion where practical

## Persistent Data

Use Linkset Data where appropriate for:
- score
- completed orders
- achievements
- rewards claimed
- leaderboard

Keep storage bounded.
Provide cleanup.
Handle failed writes/storage limits.

## Leaderboard

Support:
- current score
- top players
- daily score where practical
- seasonal score
- configurable max entries
- owner reset
- remove user

Never allow unlimited growth.

## Rewards

Allow configurable inventory rewards for:
- first completion
- score milestones
- achievements
- daily winner
- seasonal winner

Prevent duplicates.
Check inventory.
Handle copy/transfer limitations safely.

## Santa / Elf Presentation

Dialogs, text, sounds, and objects may present Santa/elf interactions.

Do not invent external AI.
Do not claim pathfinding unless implementing real supported LSL pathfinding capabilities.

## Admin Menu

Include:
STATUS, START, STOP, PLAYERS, STATIONS, PING, QUEST, DIFFICULTY, TEAMS, SCORES, LEADERBOARD, REWARDS, RESET USER, RESET SCORES, DEBUG, HELP.

## Performance

Avoid high-frequency sensor loops and permanent fast timers.
Expire abandoned sessions.
Clean stale quests.
Throttle repeated station messages.

## Security

Admin controls owner/admin only.
Residents cannot fake score, station completion, rewards, achievements, or quest completion.

## Mandatory LSL Review

Audit all scripts for:
- syntax
- scope
- return types
- valid events/functions/constants
- list bounds
- key conversions
- string parsing
- timers
- listeners
- data persistence
- duplicate globals
- nonexistent functions
- illegal language constructs
- correct chat/link communication

Cross-check Core and Station protocol exactly.

## In-World Test Cases

Test:
1. Fresh Core
2. Fresh Station
3. Station discovers Core
4. Wrong token
5. Duplicate station ID
6. Two players same station
7. Many active players
8. Player leaves region
9. Player returns
10. Wrong station
11. Stage skip
12. Repeat completed station
13. Quest expires
14. Core reset mid-quest
15. Station reset mid-quest
16. Region restart
17. Reward missing
18. Leaderboard full
19. Linkset Data full
20. Owner change
21. Team member disconnect
22. Malformed packet
23. Dialog timeout
24. Invalid time/difficulty
25. STOP during active game

Correct all issues before output.

## Final Output

Return complete compile-ready scripts, then:
- script purpose
- configuration guide
- customer setup
- station setup
- reward setup
- testing
- troubleshooting

## Customer Setup Instructions Requirement

Explain:
1. Rez controller.
2. Add Santa Workshop Core.
3. Rez stations.
4. Add same Universal Workshop Station script to each.
5. Change STATION_TYPE and unique STATION_ID.
6. Match channel/token/controller settings.
7. Add rewards to Core.
8. Reset all scripts.
9. Run PING/STATIONS.
10. Test one full order before opening.

Use simple language for SL customers.
