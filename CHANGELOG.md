# Changelog

## 1.0.0

- Match Gabba's MEDIUM/top-level window behavior so clicking other windows can bring them in front; raise options when opened.
- Use a dedicated, simplified game icon for the minimap and addon list.

- Add a small vertical gap between own-pet health and resource text.

- Center own-pet health and power labels on their bars after changing font size; defer anchoring during combat.
- Added independent own-pet health and power label sizing (8–16 px, default 9 px).
- First stable standalone release of Gabba's unit-frame module.
- Based on the original module used in-game by the author.
- Restored Gabba's raid reflow, Edit Mode preview, pet layering, and target-text fixes.
- Added a draggable minimap button opening standalone settings with a left-click.
- Added the GUF icon to WoW's addon list and Escape support for settings.
- Added reproducible release packaging, checksums, and release automation.

## 1.0.0-dev.1

- Extracted Gabba's party-member and party-pet value overlays.
- Added combat-safe pet scale and position controls.
- Added optional raid group orientation and wrapping for Separate Groups.
- Extracted player/target label sizing, hostile exact health and
  target-of-target percentage display.
- Added a compact standalone configuration window available through `/guf`.
