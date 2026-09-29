# Permanent Weld Restraint & Cuffs Engine PRO

Create a complete, production-ready Second Life LSL product named:

**Permanent Weld Restraint & Cuffs Engine PRO**  
Creator: **RockzHasan**

## Purpose
Build a professional full-permission creator engine for mesh wrist cuffs, ankle cuffs, shackles, armbinders, belts, chains, restraint accessories, and linked restraint products.

The system must be designed specifically for real Second Life in-world use and use only valid Linden Scripting Language (LSL), supported Second Life functions, and documented RLV/RLVa-compatible command patterns.

## Core System
Support:
- Left/right cuff pairing
- Multiple restraint component synchronization
- Lock/unlock
- Weld mode
- Timed lock
- Authorized keyholder/controller system
- Wearer controls
- Owner configuration
- Trusted-user whitelist
- Blacklist
- Temporary controller access
- Access revocation
- Configurable RLV/RLVa restrictions
- Detach restriction while an accepted restraint session is active
- Sit restrictions
- Stand restrictions where supported
- Teleport restrictions
- Inventory/outfit-related restriction profiles where supported
- Configurable chat/emote restrictions
- Configurable touch/interact restrictions
- Leash-ready command interface
- Linked-message API
- Optional chain/particle communication hooks
- Status reporting
- Emergency release
- Safeword
- Recovery/reset system

## Consent
Do not silently impose RLV restrictions on an unrelated avatar.

Create an explicit consent/session system for controller actions. The wearer must be able to understand when a control session is active.

Provide:
- ACCEPT
- DECLINE
- REVOKE
- SAFEWORD
- STATUS

The system must safely clear its own active restrictions when the session is legitimately terminated.

## Weld Mode
Create NORMAL LOCK and WELD modes.

Weld mode should represent a high-security persistent state at the script/application level, while still retaining documented emergency recovery and respecting Second Life/Viewer limitations.

Never falsely claim that an LSL object can become technically impossible for the account owner to recover from.

## Pairing
Use secure session-based pairing.

Do NOT rely on one publicly known static negative chat channel as the only security mechanism.

Generate/use appropriate session identifiers or derived private communication channels.

Validate:
- sender UUID
- wearer UUID
- session
- command
- authorization level
- expiry where applicable

Reject malformed and unauthorized commands.

## Linkset Support
Allow child restraint components to communicate with the root controller using llMessageLinked.

Define a clean internal protocol such as:
LOCK
UNLOCK
WELD
RELEASE
STATUS
TIMER
PAIR
UNPAIR
SAFEWORD
CHAIN
ANIM
RESET

Avoid linked-message loops.

## Menus
Create clean dialog menus with pagination where necessary.

Suggested main menu:
LOCK
UNLOCK
WELD
TIMER
ACCESS
RLV
CHAIN
STATUS
RECOVERY

Menus must expire and listeners must be removed.

## Timer
Support:
- 5 minutes
- 15 minutes
- 30 minutes
- 1 hour
- custom duration
- optional randomized duration

Prevent timer bypass caused by simple menu reopening.

Handle Unix time safely with llGetUnixTime().

## Recovery
Design robust recovery for:
- script reset
- region restart
- wearer relog
- attachment reattach
- controller disappearance
- stale sessions
- invalid configuration
- expired controller
- missing paired component

Persist only appropriate non-sensitive configuration using valid Second Life techniques such as linkset data when suitable.

Do not assume ordinary script memory survives resets.

## Performance
Minimize:
- active listeners
- sensor use
- timers
- chat traffic
- repeated RLV commands
- unnecessary list growth

Do not use a fast repeating timer when event-driven logic can perform the same job.

## Deliverable
Produce the complete LSL source code.

If a modular architecture is substantially safer or more maintainable, separate it clearly into scripts such as:
01 - Restraint Core
02 - RLV Controller
03 - Access & Consent
04 - Cuff/Chain Bridge

Only split scripts when there is a real architectural reason.

## Mandatory Error Audit
Before presenting the final code, perform a complete static review.

Check every script for:
- LSL syntax errors
- unsupported syntax borrowed from C/C++/JavaScript/Python
- invalid functions
- invalid constants
- wrong event signatures
- missing semicolons
- mismatched braces
- undeclared variables
- variable scope errors
- duplicate declarations
- invalid list operations
- incorrect casts
- string/key/integer/float/vector/rotation type mismatches
- invalid return values
- functions missing required returns
- incorrect llMessageLinked parameters
- listener leaks
- stale handles
- timer bugs
- dialog-channel collisions
- authorization bypasses
- command spoofing
- race conditions
- state transition problems
- RLV command formatting mistakes
- reset/relog recovery errors
- infinite message loops
- memory/list growth problems

Do a second pass specifically asking:

**"Would this compile as actual Linden Scripting Language in the current Second Life script compiler?"**

Correct every issue found before returning the scripts.

Do not provide pseudocode, incomplete placeholders, imaginary APIs, or functions that do not exist in LSL.

Finally include concise in-world setup instructions and an in-world test checklist covering pairing, lock, weld, timer, RLV-enabled viewer behavior, RLV-disabled viewer behavior, safeword, reset, relog, region restart recovery, unauthorized controller attempts, and linked restraint synchronization.
