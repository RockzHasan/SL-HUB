# Haunted House Interactive Horror Engine PRO

**Creator:** RockzHasan
**Platform:** Second Life / Linden Scripting Language

This package is a modular, no-Experience haunted-attraction controller. It never moves avatars. A zone only reports an avatar key to the core; the effect modules alter nonphysical linked scenery, light, sound, particles, and hidden apparition prims.

## Package scripts

1. `01 - Haunted House Core Controller.lsl` — access control, menu, global cooldown, probability, random/manual selection, sequential scene 5, SAFE, and shared state.
2. `02 - Scare Zone Controller.lsl` — low-frequency avatar sensor, entry detection, and per-zone cooldown.
3. `03 - Haunted Door & Prop Controller.lsl` — reversible linked-prim local transforms.
4. `04 - Horror FX Controller.lsl` — sound, point light/full-bright/glow, and bounded particles.
5. `05 - Ghost - Apparition Controller.lsl` — show/hide for one or more ghost prims.
6. `06 - Optional Admin HUD.lsl` — wearable remote for the configured region chat channel.

## 1. Installation

1. Make a backup of the build. Link decorative child prims to the house controller root. The moving prims must be nonphysical and must not be the root prim.
2. Name controlled child prims as described below. Inventory sounds may be placed in the root prim.
3. Create six new scripts with the exact corresponding filenames and paste each source into its own script. Put scripts 01–05 in the same linkset root. Script 02 may instead be used in a separate zone object only if the separate-object extension below is implemented; the supplied linked-message version belongs in the controlled linkset.
4. Configure the uppercase settings at the beginning of every script before saving. Save/compile one module at a time and confirm no compiler errors.
5. Reset the core after all modules are running, or use **RESET**, so every module receives a clean state. Touch the root as owner and choose **STATUS**, then **RANDOM**.
6. For the optional HUD, put script 06 into a separate attachment and ensure its `CONTROL_CHANNEL` and staff configuration match the core.

## 2. Linkset and prim naming

Names are exact and case-sensitive. A link-number discovery pass runs on startup and again after a link change.

| Name | Purpose |
| --- | --- |
| `HH_DOOR` | Door/window prim transformed by script 03 |
| `HH_PROP` | Painting, furniture, or other translated prop |
| `HH_LIGHT` | Point-light/glow/full-bright effect prim |
| `HH_EMITTER` | Particle source prim |
| `HH_GHOST`, `HH_GHOST_2`, … | Any apparition prim; prefix matching is intentional |

The door's and prop's local position/rotation at script startup are their home transforms. Put them in the closed/resting pose **before** resetting script 03. `DOOR_OFFSET` and `PROP_OFFSET` are local-space vectors. `DOOR_ROTATION` is multiplied onto the captured local rotation. Do not configure a root prim as a moving child; root motion uses different semantics and is deliberately unsupported. One script controls the first exact door and prop name. Duplicate the prop controller with unique configured names to operate more parts.

## 3. Configuration guide

### Core

* `GLOBAL_COOLDOWN` prevents attraction-wide rapid retriggers; because Unix time has integer resolution, use whole-second values.
* `SCARE_PROBABILITY` is an integer from 0 through 100.
* `AUTOMATIC_MODE`, `DEBUG_MODE`, and `CONTROL_CHANNEL` set initial behavior. Use a private negative channel different from nearby products.
* `STAFF` contains quoted avatar UUID strings. The core authenticates avatar chat and HUD object chat by resolving the speaker's owner with `llGetOwnerKey`.

### Zone

* `DETECTION_RANGE` is the spherical radius and `SCAN_INTERVAL` should normally remain 2 seconds or higher.
* `ZONE_COOLDOWN` is per script instance. `REQUIRE_NEW_ENTRY` makes an avatar leave the sensor sphere before triggering again. The `no_sensor` event clears presence.
* Second Life sensors are spherical/conical, not box volumes. Place independent zone linksets centrally for accurate rooms; do not simulate large areas using very fast scans.

### Props and effects

* Configure exact names, offsets, local rotation, return delay, and each `ENABLE_*` switch.
* `SCARE_SOUND` accepts a sound asset UUID or an inventory sound name. Leave it blank to disable. `llTriggerSound` is used once per accepted scene.
* Particle production is bounded by `PSYS_SRC_MAX_AGE`, then explicitly cleared. Texture is blank by default; set a texture UUID if desired.
* Ghost visibility changes all faces of prefix-matched child prims. Their color is set to white, so bake desired coloration into textures or alter `setGhost`.

## 4. Admin commands

Owner/staff may touch the controller for its dialog, speak commands on `CONTROL_CHANNEL`, or use the optional HUD:

| Command | Result |
| --- | --- |
| `MENU` | Opens the controller dialog when sent by avatar chat |
| `RANDOM` | Runs a random scene immediately (manual operation still respects enabled/SAFE state) |
| `AUTO` | Toggles automatic zone requests |
| `ENABLE` | Enables and leaves SAFE mode |
| `DISABLE` | Stops new scenes but lets an already-running short effect finish |
| `SAFE` / `STOP` | Emergency stop: disables the engine and tells every module to restore/clear |
| `RESET` | Tells modules to restore, then resets the core |
| `STATUS` | Reports state, probability, cooldown, and free memory privately |

Dialogs use eight buttons (below the twelve-button platform limit). Their temporary listener is restricted to the requesting avatar and removed on close or after 30 seconds. The permanent core listener is necessary for the HUD and configured once.

## 5. Communication protocol

### Internal link messages

All modules use `llMessageLinked(LINK_SET, code, payload, avatarKey)` and do not echo received messages.

| Code | Sender → receiver | Payload | Key |
| ---: | --- | --- | --- |
| 100 | Core/admin-capable linked script → modules/core | `SAFE`, `RESET`, or an admin command | requesting avatar |
| 110 | Zone → core | diagnostic zone/object name | detected avatar |
| 200 | Core → effect modules | scene integer `1`–`4`; random choice 5 is expanded to a timed 1→4 sequence | triggering avatar |
| 900 | Core → zone(s) | `enabled|safe|automatic`, each `0` or `1` | null key |

Scene mapping is intentionally modular: 1 door + FX, 2 prop + FX, 3 ghost + FX, 4 combined + FX. Choice 5 becomes a sequential scene. Unknown codes and payloads are ignored.

### Separate objects

The supplied zone communicates through linked messages and therefore must share a linkset with the core. For separate zone objects, use a private negative channel and a dedicated relay design with messages such as `HH1|sessionNonce|ZONE|zoneId|avatarUUID|unixTime`. The core must verify the speaking object's owner (`llGetOwnerKey`), nonce, field count, UUID, and a short timestamp window before converting it to code 110. A static channel alone is not authentication. This optional relay is not included, avoiding an always-open listener in every zone and avoiding a misleading insecure implementation.

The HUD sends plain admin commands on the private channel. The core accepts them only when the speaking avatar—or the owner of the speaking object—is the owner or configured staff. A malicious object owned by an authorized staff member could issue their commands, so distribute HUD objects carefully and change the channel for each product installation.

## 6. Testing checklist

* [ ] Every script compiles in the Second Life Mono compiler without modification after settings are filled in.
* [ ] Controlled prim names are exact; **RANDOM** moves them and they return to captured local transforms.
* [ ] Door/prop prims are nonphysical and do not collide dangerously with visitors.
* [ ] An avatar entering range generates at most one request; remaining inside does not retrigger when `REQUIRE_NEW_ENTRY` is true.
* [ ] Leaving and returning after the zone cooldown can trigger; global cooldown and probability still apply.
* [ ] Probability 0 never auto-triggers and 100 always does when both cooldowns allow.
* [ ] Scene 5 sends the four one-second sequence stages and finishes without leaving the core timer active.
* [ ] Sound is audible, the light clears, particle emission ends, and ghosts hide after their durations.
* [ ] **SAFE** immediately restores props, hides ghosts, stops the local sound, clears particles, and stops zone sensors.
* [ ] **ENABLE** resumes scanning; **AUTO** off/on stops/restarts scanners.
* [ ] Unauthorized avatar chat, object chat, and touches cannot control the engine.
* [ ] Owner and every configured staff UUID can use status and controls; a mismatched HUD channel does nothing.
* [ ] Dialog listener closes via **CLOSE** and automatically expires after 30 seconds.
* [ ] Link/unlink or owner change causes safe script rediscovery/reset.
* [ ] Test multiple avatars entering simultaneously and confirm zone/global cooldowns prevent floods.
* [ ] Inspect Statistics/Script Info under expected event load and increase scan interval if the attraction has many zones.

## 7. Final error-audit report

The package was reviewed script by script against actual LSL event/function signatures and types. The review verified semicolons, braces, returns, local/global scope, list indexes, explicit casts, key/string conversion, sensor/no-sensor handling, and shared codes/payloads. It uses supported functions/events only: `llSensorRepeat`, `llSensorRemove`, link messages, local link primitive parameters, link particle systems, sounds, listeners, dialogs, and timers.

The `PRIM_POS_LOCAL`/`PRIM_ROT_LOCAL`, point-light, full-bright, glow, and color parameter lists are in documented ordering. Particle rules have matching value types and are explicitly stopped. Sound calls accept an inventory name or UUID string. No permissions are requested and no avatar is moved or controlled. Listener handles are retained and removed; only the core's configured HUD listener is permanent. Menu filtering checks both channel and speaker. Sensor frequency defaults to a conservative 2.5 seconds. Loops are bounded by detected avatars or link count, and no recursion or unbounded list growth exists (`inside` is replaced each scan).

Timers are single-purpose within each component; the core deliberately multiplexes menu expiry and the short sequence. SAFE recovery clears every transient component. Owner/link changes reset discovery. Link-message names, codes, payloads, and directions were cross-checked with every sender and receiver. Scene requests are serialized by cooldowns; a new effect safely restarts that component's return timer from its captured home state.

Known platform/design limits are explicit: sensor regions are spherical; transforms are immediate rather than interpolated; script resets do not persist runtime toggles; linked messages cannot cross objects; local chat does not provide encryption; and visibility cannot defeat viewer-side rendering choices. No Experience, external service, deprecated function, pseudocode, avatar force-control, or griefing behavior is used.

**Audit conclusion:** Yes—every supplied script is intended to compile in the actual Second Life LSL compiler without modification (with blank asset settings remaining valid). As with all LSL deliveries, perform the in-world compile and checklist above because this repository does not include Linden Lab's proprietary compiler/runtime.
