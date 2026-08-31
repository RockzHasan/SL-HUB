# INTERACTIVE CHRISTMAS TREE PRO

Created by RockzHasan — Version 1.0.0

## Installation

1. Put the word `LIGHT` anywhere in each light prim's **name or description**,
   `STAR` in topper prim names/descriptions, and `ORNAMENT` in ornament group
   names/descriptions. Tags are case-insensitive and a prim may have more than
   one tag.
2. Drop `Christmas_Tree_Core.lsl` into the root prim of the linked tree. The
   controller starts automatically and snapshots the color, alpha, glow, and
   full-bright values of every face it controls.
3. Optionally add sounds named `SOUND_BELLS*`, `SOUND_CHEER*`, and
   `SOUND_AMBIENT*`. The first matching sound is used.
4. Touch the tree. Only the owner can change **Access**, **Hover**, **Defaults**,
   and **Restore**. Switching Access to Public gives visitors the normal festive
   controls but never the administrator settings.
5. Before removing the script or rebuilding the linkset, choose **Status** and
   then **Restore** to put tagged prim faces back to their captured appearance.

If no `LIGHT` tag exists, the controller automatically uses the entire linkset as
a reversible fallback and reports this in owner chat and **Status**. This makes
the menu visibly functional immediately on single-prim and unconfigured linked
trees. For a finished product, tag dedicated light prims and reset the script so
only those parts are animated.

Settings remain active through normal use and region crossings, but deliberately
return to defaults after a script reset, owner change, or recompilation. Day/night
automatic mode follows the region sun direction and checks it once per minute.

## Builder notes

- Put the script in the root prim for predictable hover text, ambient sound, and
  snow placement.
- Particle systems replace existing particle systems on affected tree prims.
- Use modest face counts on tagged prims. The original-material snapshot is held
  in script memory so Restore remains immediate and does not modify object data.
- The product contains no DRM, external service, fixed UUID, or permission check;
  set the inventory permissions appropriate for your full-permission package.
