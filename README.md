# Halloween Trick-or-Treat Event Network PRO

**Creator: RockzHasan**

A modular, single-region Second Life event system. Residents collect randomized candy at unique houses, encounter rare prizes and bonus locations, complete a unique-house goal, and appear on a compact leaderboard. All source files are production LSL, not pseudocode.

## Product contents

| File | Placement | Purpose |
|---|---|---|
| `01 - Halloween Event Core.lsl` | controller root prim | session, station registry, validation, routing, owner controls |
| `02 - Trick-or-Treat Candy Station.lsl` | one script per distributed station | touches, effects, local throttling, requests |
| `03 - Player Progress Manager.lsl` | controller linkset | authoritative UUID progress and duplicate prevention |
| `04 - Reward - Prize Controller.lsl` | controller linkset | checked inventory delivery and award deduplication |
| `05 - Leaderboard Controller.lsl` | visible controller child prim | top-ten display and safe ranking |
| `06 - Optional Admin HUD.lsl` | owner-attached HUD | start, stop, reset, emergency stop, status |
| `07 - Personal Progress HUD.lsl` | resident-attached HUD | private progress query |

# 1. Installation guide

1. Create a controller linkset. The leaderboard script should be in the prim whose floating text will display. Put scripts 01, 03, 04 and 05 in that same linkset. Linked messages do not cross linksets.
2. Choose a nonzero negative `NETWORK_CHANNEL` and a long random `EVENT_TOKEN`. Put exactly the same values into Core, every Station, Admin HUD and Personal HUD. Do not ship the example token.
3. Rez the controller before the stations. Rez one station object per location and install script 02.
4. Set the controller and every station to the **same owner**. The Core rejects objects whose `llGetOwnerKey` differs.
5. Add configured prizes to the same prim inventory as script 04.
6. Reset scripts after configuration. Start through the Admin HUD. Scripts reset on owner change; progress is intentionally volatile and does not survive a region/script reset.

The network is **region-wide only**. `llRegionSay` on a nonzero channel and `llRegionSayTo` provide valid region-wide communication within one simulator, but do not cross region borders. For a multi-region estate, deploy one complete controller/event per region, or replace transport with a real external HTTPS service using `llHTTPRequest`; that option needs web hosting, authentication, persistence, privacy disclosure, retry/rate-limit handling, and is not included here.

# 2. Event-controller setup

Configure Core constants before compiling:

- `REQUIRED_STATIONS`: unique stations required for completion.
- `GLOBAL_COOLDOWN`: minimum seconds between accepted collections anywhere.
- `AUTO_START`: starts a fresh session after script reset when true.
- `AUTO_STOP_AFTER_MINUTES`: zero disables scheduled stop.
- `DEBUG`: owner-only diagnostic output.

`START` creates a new session and clears all progress, leaderboard rows, and reward ledgers. `STOP` closes collection while retaining current display/progress in memory. `RESET ALL` closes and immediately creates a clean session. `EMERGENCY` immediately closes collection. Because START is destructive, do not use it merely to reopen an accidentally stopped event: this release deliberately treats each start as a new event session.

# 3. Candy-station setup

Edit each station's constants:

- friendly `STATION_NAME`;
- unique `STATION_ID`;
- inclusive `CANDY_MIN`/`CANDY_MAX` (Core clamps values to 0–10,000);
- `RARE_PERCENT` (Core clamps 0–100);
- `BONUS_LOCATION` and controller-side `BONUS_POINTS`;
- `LOCAL_COOLDOWN` to throttle repeated touches;
- optional inventory sound name or sound asset UUID;
- optional `DECORATIVE_LINK` child-prim number.

The station registers at reset. If it reports `DUPLICATE_ID`, change its ID and reset it. If reset while an event is open, HELLO_ACK supplies the current session/open state. Successful collections emit a short particle burst, optionally play sound, and briefly color the selected decorative prim. Closed, pending, cooldown and duplicate outcomes receive distinct messages.

# 4. Station ID configuration

IDs are case-sensitive and limited to 1–32 ASCII letters, digits, underscore, or hyphen. Examples: `HOUSE_001`, `CRYPT-WEST`. Never reuse an ID within one controller. Core binds each ID to the registering object key and rejects a second object using it. Progress stores IDs between `|` delimiters, which the allowed character set cannot contain.

Moving a configured station is safe. Taking it into inventory and re-rezzing creates a new object UUID; reset it so its HELLO replaces that object's registration. If an old copy remains rezzed, remove it before registering the replacement.

# 5. Prize inventory setup

Set `RARE_PRIZE` and `COMPLETION_PRIZE` to exact case-sensitive inventory names and place those assets in the **same prim** as Reward Controller. Any inventory type can be passed to `llGiveInventory`, but the script checks the item exists first. A rare award is once per avatar per session; completion is once per avatar per session.

Second Life permissions still apply. The next owner permissions on the delivered asset are honored; this code cannot grant copy/modify/transfer rights the creator does not possess. A no-copy item can be transferred and will leave the dispenser, so stock enough copies or use a copyable master. Scripts cannot verify receipt acceptance and offline/capped delivery behavior should be tested with the actual asset. Missing inventory produces an owner error and is not falsely marked delivered, allowing a later valid award event, but the system does not automatically retry old events.

# 6. Player instructions

1. Visit participating houses while the event is open.
2. Touch each candy station once. Wait for its response before moving on.
3. Each unique station counts once per event session. Bonus locations add bonus candy but still count as one house.
4. Wear the optional Personal Progress HUD and touch it to view candy, unique houses, requirement, and completion.
5. The leaderboard ranks candy first, then unique visits. Display names are informational; UUID is the identity key.

A newly attached HUD may query with its initial `CLOSED` session; Core treats that value as a discovery request and returns the current session. This avoids periodic state broadcasts.

# 7. Admin instructions

The Admin HUD works only for the controller object's owner. Touch it and choose:

- **START**: new session and erased progress;
- **STOP**: close;
- **STATUS**: return activity and registered-station count;
- **RESET ALL**: destructive fresh session;
- **RESET PLAYER**: paste an exact avatar UUID; progress, leaderboard row, and that player's reward ledger are cleared;
- **EMERGENCY**: immediate close.

Core checks both the avatar UUID inside the request and the sending object's owner. UUIDs, not display names, are used for reset. Touching the Core gives read-only status so no permanent dialog listener is created there.

# 8. Communication protocol reference

All distributed messages are JSON arrays on the configured private nonzero channel. Field 0 is `HTN1`, field 1 the shared token, field 2 the session, and field 3 the command. JSON avoids delimiter injection. Numeric JSON values arrive through `llJson2List` and are explicitly read as integers where required.

| Producer → consumer | Command and ordered fields after command |
|---|---|
| Station → Core | `HELLO`, station ID, name, min, max, rare percent, bonus flag (session `*`) |
| Core → Station | `HELLO_ACK`, status, active flag, Unix time |
| Core → all | `STATE`, `OPEN` or `CLOSED` |
| Core → all stations | `DISCOVER` (session `*`; asks already-rezzed stations to send HELLO) |
| Station → Core | `COLLECT`, station ID, avatar UUID, display name, nonce |
| Core → Station | `RESULT`, nonce, avatar UUID, status, awarded points, total score |
| Player HUD → Core | `QUERY`, owner UUID, nonce |
| Core → Player HUD | `QUERY_RESULT`, nonce, avatar UUID, score, unique, completion, requirement |
| Admin HUD → Core | `ADMIN`, owner UUID, action, optional target UUID |
| Core → Admin HUD | `ADMIN_STATUS`, active flag, station count |

Internal linked messages are also JSON arrays: `RESET_ALL(session, required, global cooldown)`, `EVENT_STATE(session, state)`, `RESET_PLAYER(session, UUID)`, `COLLECT(...)`, `COLLECT_RESULT(...)`, `PLAYER_UPDATE(...)`, `AWARD(session, UUID, kind)`, `QUERY(...)`, and `QUERY_RESULT(...)`. Core alone accepts network collection inputs; Progress alone commits scores.

The private channel and token reduce accidental cross-talk and casual spoofing; **LSL chat is not cryptographic security**. A malicious script able to learn the channel/token and owned by the event owner could impersonate components. Same-owner object validation, registered object UUID binding, session checking, station IDs, request nonces, pending ledgers, and authoritative duplicate checks provide layered operational protection, not encryption or a trust boundary against the owner.

# 9. Performance recommendations

- Use one controller per region; do not add listeners per resident.
- The Core, each station, and each HUD create one persistent private-channel listener. HUDs should be detached after use.
- No periodic broadcasts occur. Leaderboard redraw is local every 15 seconds; Core cleanup is every 30 seconds; station cleanup is every 5 seconds.
- Keep `TOP_COUNT` near 10 and names truncated. Floating text is capped defensively at 1,000 characters.
- `MAX_PLAYERS` defaults to 300 because Mono script memory is finite. The visited-ID string grows with every unique visit. For larger events, lower station counts, shard events, or use an external database/HTTP architecture.
- Registry and player lookup are linear lists, appropriate for modest in-world events. Load-test your actual station/player target and watch `llGetFreeMemory` during staging.
- Volatile list storage is intentionally simple and fast, but script reset loses data. Persistent production events requiring recovery need Experience KVP (with an enabled Experience and its constraints) or external HTTP storage.

# 10. In-world test plan

1. Compile every script with the Second Life Mono compiler; confirm no warnings/errors.
2. Use a fresh token/channel, rez Core, then two stations with unique IDs. Verify both register and STATUS reports two.
3. START and verify both stations show open.
4. Touch station A as avatar A: check randomized award, effect, total and leaderboard.
5. Touch A again after local cooldown: expect `DUPLICATE` and no score change.
6. Touch B too quickly: expect `GLOBAL_COOLDOWN`; retry later and expect success.
7. Set B to bonus, restart, and verify `points + BONUS_POINTS` exactly.
8. Temporarily set rare to 100, restart/reset station, collect, and verify named inventory delivery.
9. Set requirement to two, visit both, and verify completion reward only once and completed leaderboard state internally.
10. Touch Personal HUD and compare its score/count with leaderboard.
11. STOP and verify stations reject collection. START and verify old progress is zero and a new session appears.
12. Reset one player by UUID and verify only that player disappears/restarts.

# 11. Abuse and edge-case tests

- Rez two stations with one ID: second must receive `DUPLICATE_ID`.
- Change token/channel on one station: it must remain disconnected, not award locally.
- Replay an old `COLLECT` with an old session: expect `STALE` and no mutation.
- Send the same station nonce twice within two minutes: only the first reaches Progress.
- Rapid-click: pending/local cooldown suppresses repeats; authoritative visited set prevents delayed duplicates.
- Forge a request from another owner's object: Core silently rejects it.
- Try an invalid ID containing `|`, spaces, or over 32 characters: expect `BAD_ID`.
- Stop between touch and processing: Core/Progress session and active gates prevent a later new-session credit.
- Remove a prize, force award: expect owner error and no impossible delivery promise.
- Use no-copy prize stock: verify it leaves inventory and subsequent absence is reported.
- Reset scripts/region during an event: verify documented volatile-data loss and closed/reinitialized behavior.
- Reach `MAX_PLAYERS`: new player gets `FULL` (station presents generic expired/closed wording); existing players remain intact.

# 12. Final compile/runtime audit report

A source-level compatibility audit was performed across all produced commands and handlers. Braces and semicolons are balanced; event signatures are standard LSL; calls used are real LSL functions/constants; explicit list-to-key/integer/string conversions are used; list accesses are gated by exact/minimum lengths; all stride loops advance by their declared stride; replacements/deletions use full-record boundaries; and no unbounded or zero-step loop exists.

Protocol cross-check: every distributed producer command has a matching Core/Station/HUD consumer with the same field order. Every Core-to-Progress command has a matching handler; `COLLECT_RESULT` contains 11 fields and Core reads indices 0–10; leaderboard update contains seven; query request contains five internally and result contains nine internally, becoming ten fields on the network after the four-field envelope. Session equality is checked at every mutation/response boundary. Station object UUID and same-owner checks occur before collection acceptance.

Race review: the Core records each `(station object, nonce)` before forwarding; Station permits one pending request per avatar; Progress checks visited state before mutation; global cooldown is applied only to accepted visits; Reward maintains per-session delivery types. LSL events execute serially within each script, while linked messages are asynchronous, so the Progress script is the sole score writer. STOP blocks new forwards and sends an internal closed state to Progress. Messages from one Core script retain event-queue ordering, so a collection forwarded before STOP may complete and one after STOP cannot.

Listener/timer review: listener handles are created once after reset; none are repeatedly leaked. Timers are 5/15/30 seconds, not high-frequency. Temporary Core nonce entries expire after 120 seconds; station pending requests after 30 seconds. Expired station pending and local-cooldown entries are pruned on the five-second timer.

Known operational limits are explicit: same-region transport, shared-secret rather than cryptographic security, volatile memory, owner-homogeneous components, finite Mono memory, inventory permissions, and no delivery receipt. Compile again in the target grid/viewer because only the platform compiler is authoritative, then execute both test plans before Marketplace release.
