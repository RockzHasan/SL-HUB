# Vampire Coffin & Transformation System PRO

Create a complete, production-ready Second Life LSL product named **Vampire Coffin & Transformation System PRO** by **RockzHasan**.

## Purpose
Build an immersive, configurable vampire coffin interaction system that runs in exactly **one prim with one LSL script**. Use only valid Linden Scripting Language and supported Second Life features. The system should be suitable for Halloween, gothic roleplay, and vampire-themed experiences.

## Single-Prim Requirements
- Use one prim and one script only.
- Do not require child prims, linked objects, external objects, additional scripts, or external services.
- Create visual effects using supported single-prim features such as particles, prim color/glow, and texture animation.
- Do not implement or promise mechanical coffin doors; a single prim cannot provide separate moving door geometry.
- Keep the coffin's visual appearance and interaction functional without optional inventory assets.

## Interaction and Access
- Provide intuitive touch controls and clear feedback about the selected mode and active effect.
- Support a configurable public interaction mode, with owner-only access to administrative settings.
- Validate the toucher and permissions for every administrative action. Do not expose configuration changes to public users.
- Provide a safe way to cancel an effect and restore the coffin to its idle appearance.
- Ensure repeated touches, simultaneous interactions, owner changes where relevant, and script resets cannot leave stale listeners, timers, or effects.

## Modes and Awakening Sequences
Provide configurable **NIGHT**, **AWAKEN**, **REST**, **CURSE**, and **RANDOM** modes:
- NIGHT: atmospheric vampire-night effects.
- AWAKEN: a configurable sequence with bounded stages and durations.
- REST: subdued or inactive coffin effects.
- CURSE: a configurable dark-magic visual sequence.
- RANDOM: select from the configured modes or sequences without unbounded processing.

Let the owner configure sequence timing and relevant effect settings using a documented, beginner-friendly method. Use sensible defaults and validate configuration values before applying them. Prevent overlapping sequences from creating runaway timers or particle updates.

## Visual Effects
Create a cohesive vampire theme using combinations of:
- Red mist.
- A blood-moon-inspired glow using prim color and glow.
- Bat-like particle effects.
- Dark magical energy.
- A transformation illusion built from particle and visual effects.

The transformation is only a visual illusion. Do not claim the script can replace or change an avatar's body, clothing, shape, or appearance. Explain that any actual avatar appearance change requires the user's participation and appropriate inventory items.

Use valid particle-system rules and parameters, bounded burst settings, and suitable lifetimes. Restore the prim's original or configured idle color, glow, texture animation, and particle state during cleanup.

## Day/Night Selection
- Where supported, use documented Second Life environmental information to select day/night effects.
- Explain exactly what environmental information the script reads and its limitations; do not imply it can read a viewer's local time or detect an avatar's personal time setting.
- Provide a configurable manual fallback when environmental information is unavailable or unsuitable.
- Avoid continuous polling. Check environmental state at sensible event-driven points or with a slow, bounded timer only when necessary.

## Optional Sound Assets
- Support optional vampire sound effects from the object's inventory.
- Clearly identify the expected inventory asset names and behavior when an asset is absent.
- Never make sounds required for compilation or core operation.
- Do not include or imply that external sound assets are supplied.

## Sitting and Animation
- Make avatar sitting and animation support optional and clearly configurable.
- Explain how to set up the single-prim sit target, if used.
- Request only the permissions needed, from the correct avatar, and handle permission grants and denials explicitly.
- Start animations only after the required permission is granted; stop animations and release any controls or permissions cleanly when appropriate.
- Do not force an avatar to sit, animate, or remain in the object. Describe viewer and permission limitations.

## Performance and Cleanup
- Use event-driven logic, bounded lists and operations, and safe timer frequencies.
- Avoid continuous sensors, fast repeating timers, excessive particle updates, and unnecessary chat or listener activity.
- Remove temporary listeners and stop timers when no longer needed.
- Implement reliable cleanup for normal completion, cancellation, mode changes, avatar standing, permission denial, reset, and relevant state transitions.
- Ensure cleanup stops particles and texture animation and restores visual properties consistently.

## Owner Setup and Customer Documentation
Include:
1. A beginner-friendly setup guide for placing the script in the single prim and testing it.
2. Owner instructions for public interaction, administrative access, mode selection, sequence configuration, day/night fallback, and reset/cleanup.
3. Optional inventory sound setup, including exact expected names and missing-asset behavior.
4. Optional sit-target and animation setup, permission behavior, and limitations.
5. Troubleshooting guidance for permissions, missing assets, environmental detection, particles, script resets, and interactions.

## Mandatory Static Error Audit
Before presenting the final result, audit the complete source for:
- Actual LSL syntax and compiler compatibility; no syntax borrowed from other languages.
- Valid event signatures, functions, constants, API parameters, and return types.
- Variable scope, initialization, duplicate declarations, type compatibility, casts, and list operations.
- Particle-system parameter names, types, ordering, and valid values.
- Texture animation, color, glow, sound, sit-target, and permission API usage.
- Listener handles, timer frequencies, timer shutdown, state transitions, and cleanup.
- Authorization checks and owner-only configuration paths.
- Bounded processing, memory use, and repeated-touch behavior.

Explicitly re-check: **Would this compile as actual Linden Scripting Language in the current Second Life script compiler without modification?** Do not present pseudocode, imaginary APIs, unfinished placeholders, or unverified function signatures. If a feature cannot be implemented within the one-prim/one-script constraints, state the limitation and provide the closest valid alternative.

## Deliverables
Return:
1. The complete, self-contained single-script LSL source.
2. The setup, owner configuration, optional asset, and troubleshooting instructions above.
3. A concise static validation report summarizing the audit and any platform limitations; do not claim an in-world compile or test that was not performed.
4. An in-world test checklist covering public and owner access, all modes, sequence cancellation, day/night and fallback behavior, absent/present sounds, sit and animation permission grant/denial, avatar standing, reset, repeated touches, cleanup, and operation with no optional assets.
