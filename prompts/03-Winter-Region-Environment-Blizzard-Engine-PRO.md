# Winter Region Environment & Blizzard Engine PRO

Create a complete, production-ready, full-permission Second Life product named:

**Winter Region Environment & Blizzard Engine PRO**  
Creator: **RockzHasan**

## Purpose

Build an advanced modular winter weather simulation and parcel/region atmosphere control system for winter villages, ski resorts, Christmas regions, mountains, roleplay builds, and event venues. It must work entirely in Second Life without an external server and use only valid Linden Scripting Language (LSL) and supported simulator features.

Coordinate multiple weather effect nodes distributed around a parcel or estate. Keep simulated visual and audio effects distinct from actual simulator or viewer environment controls that LSL cannot perform.

## Weather Presets

Support:
- CLEAR WINTER
- LIGHT SNOW
- SNOW
- HEAVY SNOW
- BLIZZARD
- WHITEOUT
- FROZEN FOG
- WINDSTORM
- ICE STORM
- AURORA NIGHT
- CUSTOM

Allow smooth, configurable transitions between weather states. Transitions should use sensible stages where practical, such as increasing wind before snow, then fog and stronger gusts; clearing weather should reverse effects gradually.

## Modules

Use separate scripts with clear filenames when modularity provides a real benefit:
1. Winter Weather Core
2. Weather Scheduler
3. Snow FX Node
4. Wind / Ground Snow Node
5. Fog / Atmosphere Node
6. Sound Controller
7. Lighting / Glow Controller
8. Aurora FX Node
9. Zone / Avatar Detection Manager
10. Admin & Diagnostics

Use `llMessageLinked()` for communication between scripts in the same linkset. Document each module’s responsibilities and message protocol. Avoid link-message loops.

## Master Weather Controller

Maintain and report:
- Current and target weather
- Intensity and wind level
- Transition progress and duration
- Automatic/manual mode
- Weather duration and next change
- FX, sound, and night-effects enabled states
- Detection mode and performance mode
- Known nodes and network status

Allow owner-controlled manual weather selection and automatic weather. Automatic mode must select from configurable weighted profiles, enforce configurable minimum and maximum scene durations, avoid unrealistic rapid changes, and prevent extreme weather from repeating indefinitely unless explicitly configured.

## Smooth Transitions

Do not switch every effect instantly from zero to maximum. Interpolate or stage particle, wind, fog, sound, and lighting changes over a configurable duration. Avoid unnecessary fast timers; use the slowest update interval that still creates a smooth result, and stop timers when no transition or scheduled control requires them.

## Snow FX

Provide LIGHT, NORMAL, HEAVY, and BLIZZARD profiles with configurable particle count/rate, lifetime, velocity, acceleration, spread, alpha, scale, wind direction, emission radius, and optional texture UUID/name.

Use only valid `llParticleSystem()` rules and documented particle constants/flags. Validate configured texture inventory before use, handle a missing texture safely, and provide a complete particle-off state.

## Ground Snow, Fog, and Wind

- Provide a separate, optimized near-ground blowing-snow effect driven by master wind direction and intensity.
- Support LOW, MEDIUM, and HIGH fog-like particle settings around configured nodes without excessive particle spam.
- Simulate wind through snow direction, particle acceleration, gust cycles, and optional safe linked-prim movement.
- Do not claim or attempt to modify actual region wind; LSL cannot control simulator-wide wind.

## Sound Environment

Support looping LIGHT_WIND, MEDIUM_WIND, HEAVY_WIND, BLIZZARD, ICE, and AMBIENCE sounds, with master sound on/off and configurable volume.

Validate that configured sounds exist in object inventory before playing them. Prevent multiple nearby nodes from creating excessive overlapping loops, and stop or replace loops cleanly when weather changes or sound is disabled.

## Aurora and Lighting

Provide an optional aurora-style visual node using safe linked-prim color/glow/texture animation and/or particles. Explain the visual simulation accurately. Do not claim that LSL can directly manipulate arbitrary viewer environment settings; only use officially supported mechanisms and distinguish them from simulated FX.

## Zones

Support optional zones such as village, mountain, and frozen lake. Let nodes apply individual intensity multipliers while remaining synchronized to the master weather state. Document how nodes are assigned to zones and what happens when zone configuration is missing or invalid.

## Node Network

Support separate weather objects using authenticated communication on negative channels. Every packet must carry enough information to validate the network identifier, command, optional sequence/version, and authorization token where appropriate. Nodes must ignore unrelated or malformed chat.

Validate sender identity and owner/admin authority for privileged commands. Use a secure design appropriate to LSL’s limitations; do not treat a negative channel or an embedded shared token alone as proof of sender identity. Document provisioning, token changes, replay handling, and the trust boundary.

Include a conservative heartbeat/status mechanism so the master can identify active nodes where practical. Bound stored node data, expire stale nodes, and avoid duplicate registration and chat loops.

## Proximity Optimization

Provide an optional mode that enables high-cost local effects only when avatars are near a node. Select an efficient supported approach (such as `llGetAgentList()` or sensors), explain its permissions, scope, update-frequency, and performance trade-offs, and avoid high-frequency continuous scanning.

## Weather Scheduler

Support configurable weighted probabilities and duration ranges, including sequential and randomized weather patterns. Prevent unrealistic instant changes and indefinitely repeating extreme conditions by default. Clearly document how probabilities, scene durations, and transition duration interact.

## Admin Menu

Provide an owner/admin menu with:

WEATHER, INTENSITY, AUTO, MANUAL, TRANSITION, SOUND, PARTICLES, AURORA, ZONES, NODES, STATUS, RESET, DEBUG.

Paginate safely. Use private randomized negative dialog channels, restrict access to authorized users, remove listeners when the menu closes or times out, and handle `CHANGED_OWNER` by clearing old authorization and reinitializing safely.

## Emergency Off and Performance Modes

Provide an owner-only **EMERGENCY OFF** command that immediately stops particles, sounds, and visual FX and returns nodes to idle. Retain only timers/listeners needed for control and recovery; ensure nodes cannot remain stuck in an active effect state.

Provide ECO, BALANCED (recommended default), and ULTRA modes. ECO reduces particle emission and slows updates; ULTRA increases visual density without intentionally abusive simulator load. Document the modes’ practical trade-offs.

## Diagnostics

STATUS should report master mode, weather, intensity, elapsed weather time, next transition, known/active nodes, FX and sound states, performance mode, and network status. Include script free memory where useful and supported. Keep debug output owner-controlled and free of unnecessary chat spam.

## Owner Change, Reset, and Recovery

Handle `CHANGED_OWNER`, `CHANGED_LINK`, inventory changes, region/object/script reset, detach/re-rez, and node/master restart safely. Close or replace stale listeners, reset old authorization data, revalidate inventory-dependent effects, and prevent weather-state desynchronization. Do not assume ordinary script memory survives a reset.

## Performance and Safety

- Keep scripts event-driven and minimize timers, listeners, sensors, chat, and repeated linked-prim searches.
- Cache link-map information when safe and refresh it on relevant link changes.
- Bound lists and other state that can grow over time.
- Prevent simultaneous timer-state bugs, transition races, duplicate nodes, stale node state, and event queue flooding.
- Ensure all effects can be shut down, and keep node behavior safe when configuration or inventory is incomplete.
- Use only real LSL functions, valid event signatures, supported constants, and documented particle/primitive parameter lists.

## Required Deliverable

Return:
1. Architecture explanation
2. Required prim and node setup
3. Inventory list, including required/optional textures and sounds
4. Linkset and inter-object communication protocols
5. Complete source for every script, with a clear filename per module
6. Configuration guide
7. Installation instructions
8. Region/parcel deployment guide
9. Optimization guide
10. Troubleshooting
11. Final error-audit report

Do not shorten scripts with placeholders. Clearly identify configuration values the creator must supply, optional assets, limitations, and any feature that cannot be implemented with supported LSL. Do not claim that source has been compiled unless it was actually compiled with the Second Life LSL compiler.

## Mandatory Error Audit

Before returning the code, review every script as if it will be pasted directly into the Second Life editor. Check and fix:
- Semicolons, braces, parentheses, scope, duplicate identifiers, types, casts, lists, vectors, rotations, keys, and return values
- Event and function signatures, valid constants/APIs, particle flags, primitive parameters, sound, sensor, inventory, timer, listen, changed, state, and link-message handling
- List bounds, division by zero, invalid timer intervals, permanent high-frequency timers, listener leaks, recursive link messages, chat loops, command spoofing, malformed packets, authorization failures, and event queue flooding
- Uncontrolled particles, overlapping looping sounds, missing textures/sounds, invalid configuration, memory/list growth, excessive script time, unnecessary sensors, transition races, desynchronized weather, stale/duplicate nodes, and network channel collisions
- Owner changes, resets, region restarts, detached/re-rezzed objects, and recovery from incomplete or missing node state

Perform a second review after fixing the first round. Explicitly answer: **Would every supplied script compile as actual Linden Scripting Language in the current Second Life script compiler without modification?** If compilation cannot be performed, say so and report the limits of the static review; never claim unverified compilation.
