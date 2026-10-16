# Cursed Mirror Illusion Engine PRO

Create a complete, production-ready Second Life product named **Cursed Mirror Illusion Engine PRO** by **RockzHasan**.

## Purpose

Build a premium interactive supernatural mirror illusion that operates with exactly **one prim and one LSL script**. It must work in-world using valid Linden Scripting Language (LSL), standard Second Life functions, and optional owner-supplied inventory assets.

## Technical Boundaries

- Do not claim or imply real-time avatar reflections, camera-based mirror rendering, or a true reflective surface. Use texture overlays, color/glow changes, particles, sound, and other supported visual illusions.
- The core system must not require extra prims, scripts, external assets, or a network service.
- Make all owner-supplied textures and sounds optional. Check inventory before use and fall back safely when assets are absent.
- Do not overwrite owner-selected textures permanently. Provide a reliable way to capture/configure the intended baseline appearance and restore it after effects.
- Document any face-specific texture requirements and explain how to identify/configure the target mirror face.
- Keep the implementation within LSL memory, runtime, and event limitations.

## Required Features

- Avatar proximity detection with configurable trigger range.
- Randomized supernatural mirror events, subject to a configurable cooldown.
- Optional ghost-face texture overlays.
- Optional cracked-glass texture switching.
- Mirror glow and eerie color changes.
- Horror whispers and optional inventory sound playback.
- Curse, ghost, nightmare, and random effect modes.
- Touch-operated owner settings.
- Automatic visual restoration after every event.

## Effects and Appearance Safety

Use supported texture, color, glow, and particle operations only. Preserve the mirror's initial or owner-configured appearance, including relevant face-specific texture settings, and restore it when an event ends, the mode changes, or the script is reset.

Provide explicit **RESTORE** and **RESET** commands:

- RESTORE immediately stops active effects and returns the mirror to its saved baseline appearance.
- RESET performs safe cleanup, removes listeners, stops timers and particles/sounds as applicable, restores the baseline, and reinitializes the system without leaving an event partially active.

Define behavior for missing or invalid baseline data. Never leave the object in a damaged or unintentionally modified visual state because an optional texture or sound is missing.

## Proximity, Cooldown, and Event Control

- Use an appropriate sensor pattern for proximity detection; do not poll continuously or use a tight loop.
- Keep at most the necessary timer/listener active, and stop or remove them when idle or no longer needed.
- Enforce cooldowns so repeated sensor or touch events cannot flood effects, sounds, particles, or texture changes.
- Prevent overlapping events from racing or restoring stale appearance data.
- Use bounded event durations and restore visuals automatically even when an event is interrupted.
- Make range and cooldown configurable by the owner within sensible safe bounds.

## Owner Menu

Only the object owner may open or operate configuration controls. Provide a concise dialog menu that supports:

- Effect mode: CURSE, GHOST, NIGHTMARE, RANDOM, OFF
- Trigger range
- Cooldown
- Enable/disable proximity triggering
- Enable/disable optional sound
- RESTORE
- RESET
- STATUS

Validate dialog responses and remove listener handles on response, timeout, reset, and menu replacement. Use a private dialog channel and do not leave listeners open unnecessarily.

## Optional Inventory Assets

Support clearly named, optional inventory assets for:

- Ghost-face overlay texture
- Cracked-glass texture
- Horror whisper sound(s)

Check each requested inventory item before using it. Define safe behavior for missing inventory, wrong asset type, or an unavailable texture face. Do not block baseline restoration on asset checks. Do not require any asset for the system to initialize and operate safely.

## Particles and Sounds

Use restrained, short-lived particle illusions only where appropriate. Configure valid LSL particle-system parameters, keep particle count/rate/lifetime bounded, and stop the particle system after each event and during cleanup.

Play sounds only when enabled and an appropriate inventory sound exists. Avoid repeated or overlapping sound playback. Clearly document that sounds and particles are subject to Second Life viewer, parcel, and inventory permissions/availability.

## Performance and Runtime Safety

- Avoid tight loops, excessive memory use, timer flooding, uncontrolled texture switching, and script-timeout risks.
- Prefer event-driven behavior and one managed timer over multiple competing timers.
- Bound all lists and temporary state.
- Ensure sensors, timers, listeners, and visual effects have explicit start/stop and cleanup paths.
- Do not assume script memory survives reset.

## Mandatory Static Syntax and Runtime-Safety Audit

Before returning the result, review the complete script and verify:

- Actual LSL syntax, variable declarations, scope, and type compatibility.
- Valid event names and event signatures.
- Valid LSL functions, constants, and return handling.
- Timer setup, cancellation, expiry, and event cleanup.
- Listener creation, response validation, timeout, and removal.
- Sensor signatures, range limits, cooldown enforcement, and re-entry behavior.
- Inventory checks and safe handling of missing or wrong-type optional assets.
- Texture, color, glow, and particle parameter operations, including face indices and baseline restoration.
- Sound playback and stop/cleanup behavior.
- RESET and RESTORE behavior from idle, active, and partially configured states.
- No uncontrolled event overlap, texture churn, listener leaks, or indefinite effects.
- Memory and script-time use remain bounded and suitable for an in-world script.

Perform a final pass asking: **“Would this compile as actual Linden Scripting Language in the current Second Life script compiler?”** Correct all issues found. Do not provide pseudocode, imaginary APIs, incomplete placeholders, or unsupported features. Clearly disclose any behavior that cannot be guaranteed by LSL or Second Life.

## Deliverables

1. The complete, self-contained one-prim LSL script.
2. Customer setup instructions, including permissions and initial baseline appearance configuration.
3. Texture and sound installation guide, including expected inventory names/types and face-specific texture requirements.
4. Owner menu reference with controls, ranges, defaults, and effect behavior.
5. Troubleshooting guide for missing assets, sensor behavior, cooldowns, sounds/particles, texture faces, and restoration.
6. A static syntax and runtime-safety verification checklist covering every audit item above.

Do not split the implementation into multiple scripts or require additional prims. Keep all optional asset requirements clearly labeled and ensure core operation and safe cleanup work without them.
