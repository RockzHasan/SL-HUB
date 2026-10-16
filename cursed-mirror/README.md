# Cursed Mirror Illusion Engine PRO — by RockzHasan

One prim, one script (`CursedMirror.lsl`). **This is not a real reflection.** It uses texture swaps, tint/glow, whispers/sounds and particle mist to *imitate* a haunted mirror.

## 1. Setup
1. Rez a flat prim (box/plank) and texture it as your mirror.
2. Drop `CursedMirror.lsl` into it. Owner is told "ready".
3. Touch (owner only) to open the menu. Use **Test** to preview.

## 2. Textures and sounds
- Optional textures: name them `ghost_<anything>` (ghost faces) and `crack_<anything>` (cracked glass). Drop into the prim; the script rescans automatically (or menu **Rescan**).
- Optional sounds: `whisper_<anything>`. Sounds must be short, full-perm-to-you uploads.
- Fallback: none supplied → tint, glow, particles and local-chat whispers only.
- Face requirement: effects apply to face `MIRROR_FACE` (default 0). Edit that constant if your mirror uses another face. Textures are applied with repeat 1,1 / offset 0.
- Your own texture is snapshotted at every event start and restored after it, so it is never permanently overwritten.

## 3. Owner menu
| Button | Action |
|---|---|
| On/Off | Enable/disable proximity sensing |
| Test | Trigger an event now (ignores cooldown) |
| Sound | Toggle sound (chat whisper fallback) |
| Curse / Ghost / Nightmare / Random | Select effect mode |
| More >> / << Back | Switch page |
| Range +/- | ±1 m (1–20 m) |
| CD +/- | ±15 s (10–3600 s) |
| Rescan | Re-read inventory |
| RESTORE | Immediately stop effects and restore original look |
| RESET | Reset the script (settings return to defaults) |

Settings are held in memory only and return to defaults on RESET/re-rez.

## 4. Troubleshooting
- **Nothing happens:** check menu Enabled, increase range, press Test; chance per detection is 60% (`CHANCE`).
- **Wrong face changes:** set `MIRROR_FACE`.
- **No ghost faces:** names must start with `ghost_`; textures must be in prim inventory.
- **No sound:** sound must be named `whisper_*`, Sound toggle on.
- **Look stuck:** press RESTORE.
- **Menu gone:** touch again; it closes after 60 s.

## 5. Static verification checklist
- [x] Single `default` state; events: state_entry, on_rez, changed, sensor, touch_start, listen, timer.
- [x] All globals declared before use; no shadowing; functions defined before `default`.
- [x] One timer, ≥0.5 s, stopped (0.0) when idle; no loops in events except bounded inventory scan (≤60).
- [x] Texture ops by inventory name only after `llGetInventoryType` check; flicker every 1.5 s max.
- [x] One listener, random negative channel, owner-filtered, removed on timeout/choice reuse.
- [x] `llSensorRepeat` at 2 s with `llSensorRemove` before re-arm; cooldown enforced.
- [x] Particles valid constants; cleared by `llParticleSystem([])` on restore.
- [x] Owner change and rez reset the script; RESTORE/RESET implemented.
- [ ] Compile in-world (no LSL compiler available in this repo environment).
