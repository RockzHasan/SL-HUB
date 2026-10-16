# Haunted Fortune Teller & Tarot Engine PRO

Create a complete, production-ready Second Life LSL product named **Haunted Fortune Teller & Tarot Engine PRO** by **RockzHasan**.

## Purpose
Build a self-contained Halloween fortune-telling experience that can be dropped into one standard prim and run with exactly one LSL script. It must work in-world without mandatory notecards, web services, linked objects, or additional scripts.

## Core Experience
- Touch the prim to begin a fortune reading.
- Choose a tarot-style reading category or let the system select one at random.
- Deliver original, atmospheric readings without claiming to predict the future or guarantee financial outcomes.
- Include at least 30 distinct readings, represented compactly enough to respect LSL script memory limits.

## Categories and Readings
Include all five categories:
- LOVE
- WEALTH
- DESTINY
- DARKNESS
- MYSTERY

Provide at least six distinct readings per category. Ensure every reading is non-identical, concise enough for in-world chat, and clearly framed as entertainment or role-play rather than certain prophecy. Wealth readings must not promise money, investment returns, or other financial outcomes.

Use efficient randomized selection. Avoid repeatedly selecting the same fortune for the same avatar when practical, but do not use expensive calculations, unbounded lists, or fragile list-index assumptions. Validate category and fortune indices before accessing list entries.

## Interaction and Access
- Offer a simple public touch-to-read flow.
- Provide an owner-only configuration menu with clear controls for reading access mode, cooldown, visual effects, optional sounds, theme, and optional payment.
- Support PUBLIC mode and OWNER-ONLY mode. OWNER-ONLY must limit readings to the object owner, not merely the avatar who last touched it.
- Use short dialog labels that comply with Second Life button-label limits and concise dialog text.
- Generate a private, unpredictable negative dialog channel at runtime. Listen only while a menu is active, validate the menu user's UUID, and remove each listener on selection, timeout, reset, or owner change.
- Handle repeated touches and overlapping menus without listener leaks or stale menu state. Do not allow one avatar's response to operate another avatar's menu.

## Cooldowns and Anti-Spam
- Enforce a configurable per-avatar cooldown.
- Prevent rapid repeated touches and repeated payment attempts from bypassing cooldowns or causing duplicate readings.
- Keep tracking bounded: expire old avatar entries and impose a safe maximum on any in-memory cooldown table.
- Treat timestamps and list indices defensively. Do not rely on script memory surviving a reset.

## Crystal Ball Effects
- Use the prim itself for a crystal-ball-style glow and color/theme changes; do not require a separate object.
- Add optional, restrained particle magic using supported LSL particle-system rules.
- Make effects optional, stop particles when disabled, and restore the selected visual theme after temporary effects.
- Keep effects efficient and avoid excessive particle rates or continuously running timers.
- Optional sound must use a documented LSL sound mechanism and must not require an embedded sound asset. If a sound UUID is configurable, validate and explain its inventory/permission requirements.

## Optional Payment and Tips
- Payment mode must be disabled by default and optional to enable using the owner menu.
- If enabled, set a clear, configurable price and configure the prim's pay buttons using supported LSL functions.
- Clearly tell the payer the price and what the payment purchases before payment is made; do not imply payment buys a true prediction or guaranteed result.
- Handle `money(key id, integer amount)` explicitly. Validate the payer, exact configured amount, enabled state, access mode, and cooldown before issuing a reading.
- Do not treat arbitrary amounts as valid payments. Do not claim payment can be automatically refunded: LSL has no supported automatic refund operation. Explain that incorrectly sent payments require owner follow-up through supported Second Life processes.
- Keep free reading mode available. If payment validation fails, explain the issue clearly and do not issue a paid reading.

## State, Reset, and Ownership
- Handle `state_entry`, `touch_start`, `listen`, `timer`, `money`, and `changed` only with valid LSL event signatures.
- On owner change, remove listeners, stop timers and particles, reset configuration to safe defaults, and reconfigure pay buttons. Do not carry the previous owner's access or payment settings to the new owner.
- On reset or script start, initialize all runtime state safely, remove stale listeners where applicable, stop old effects, configure payment buttons consistently, and restore a known visual state.
- Never create an always-running timer. Use a timer only for active menu expiration or a temporary effect, and disable it when no timer work remains.
- Use only valid LSL syntax, functions, constants, events, and supported Second Life behavior. Do not use unsupported external services, invented APIs, or C-style constructs.

## Memory and Performance
- Store fortunes efficiently, such as compact category-delimited strings or carefully validated lists.
- Keep the complete source and runtime data within realistic LSL script memory limits; avoid duplicated fortune text and oversized hardcoded structures.
- Minimize active listeners, timer use, repeated object updates, chat, and list manipulation.
- Do not use infinite loops, expensive sorting, or unbounded per-avatar state.

## Final Deliverables
Return:
1. Complete single-tab LSL source code in one code block. The final implementation must use exactly one standard prim and one script.
2. A simple customer installation guide.
3. Instructions for choosing fortune categories and using every owner-menu setting.
4. A clear explanation of public versus owner-only mode.
5. A clear explanation of optional payment mode, payment validation, incorrect payments, and the lack of automatic refunds.
6. A troubleshooting guide and practical in-world test checklist.
7. A detailed static audit of syntax, event signatures, scope, randomization, list indexing, dialog channels/listeners, memory use, timers, payment handling, owner changes, and runtime risks.

## Mandatory Static Audit
Before presenting the deliverables, inspect the entire script and verify:
- The source uses valid LSL syntax and actual Second Life functions, constants, and event signatures.
- Variable declarations and scopes are valid; types and casts are appropriate.
- Every fortune category and randomized list index is valid, and all five categories contain at least six unique readings.
- Dialog labels and text respect Second Life limits; channels are private and listeners are removed on every exit path.
- The correct avatar is authorized for each menu, reading, and payment operation.
- Cooldowns and anti-spam remain safe for repeated touches and bounded under many avatars.
- `money` validates enabled status, payer, amount, access mode, and cooldown without promising unsupported refunds.
- Owner changes and resets clean up listeners, timers, particles, and payment settings.
- Particle and sound behavior uses supported LSL APIs and does not require extra prims or scripts.
- The script avoids unbounded memory growth, infinite loops, and idle timers.

Perform a final explicit review asking: **"Would this compile as actual Linden Scripting Language in the current Second Life script compiler?"** Correct every issue found. Do not claim that code was compiled or tested in Second Life unless it actually was.

## Installation and Test Checklist
Include tests for:
- Rez the single prim, insert the single script, and verify its initial appearance and touch response.
- Try each of the five categories and verify that readings vary and are entertainment-only.
- Verify at least 30 unique readings are represented and category selection never produces an invalid result.
- Verify PUBLIC and OWNER-ONLY access using the owner and a second avatar.
- Verify cooldowns, rapid repeated touches, repeated menus, menu timeout, and listener cleanup.
- Enable and disable glow, particles, themes, and optional sound.
- Confirm payment is off by default; then test correct, incorrect, and repeated payment amounts when enabled.
- Verify the prim gives no misleading refund promise and clearly explains owner follow-up for an incorrect payment.
- Change object owner and reset the script; confirm prior settings do not leak and the object returns to a safe state.
- Check script memory, listen behavior, timer shutdown, and particle cleanup during ordinary use.
