# Gabba Unit Frames

Gabba Unit Frames adds readable health and power information to Blizzard's
unit frames in **World of Warcraft Classic Era**. It is a standalone addon
and does not require Gabba or any external libraries.

## Features

- Display health and power percentages alongside numeric values on Blizzard's portrait-style party frames.
- Customize party-pet labels, scale, and placement below, left, or right of party members.
- Adjust player and target status-text size.
- Show hostile-target health values as reported by the game and target-of-target health percentages.
- Adjust raid-group orientation and wrapping when Blizzard's Separate Groups layout and required layout APIs are available.
- Save settings separately for each character.

## Getting started

Install the `GabbaUnitFrames` folder in `Interface/AddOns`, then enter the game
and type **`/guf`** to open the options. Use **`/guf reset`** to restore defaults.
Changes to protected party and raid layouts are deferred until combat ends.

## Compatibility and development status

The initial version is a **development alpha**, targeting Classic Era interface
11509 (1.15.9). In-game validation is still required. Retail and other Classic
branches are not currently declared supported. This addon enhances Blizzard's
frames; custom unit-frame replacements may not expose the frames it needs.

Please report problems with your client version, addon version, enabled options,
and any Lua error at https://github.com/Gabbajoe/GabbaUnitFrames/issues.
