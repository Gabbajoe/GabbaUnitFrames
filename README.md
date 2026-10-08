# Gabba Unit Frames

A small standalone WoW Classic Era addon extracted from Gabba's unit-frame
features. It does not require the main Gabba addon.

Features:

- health and power values on Blizzard's portrait-style party frames;
- configurable party-pet frames with compact labels;
- optional Blizzard raid-group wrapping and orientation;
- consistent player/target status-text size;
- exact hostile-target health and target-of-target percentage.

Use `/guf` to open the configuration window. Layout changes that touch
protected Blizzard frames are deferred until combat ends.

Left-click the GUF minimap icon to toggle the settings window, or drag it around
the minimap to reposition it. The same icon appears in WoW's addon list.
Press Escape to close settings.

When used with the updated Gabba addon, Gabba automatically skips its own party,
raid, and target-frame modules while GabbaUnitFrames is enabled. Other Gabba
features remain available. Disable GabbaUnitFrames and reload to use Gabba's
built-in modules again. The two addons keep separate character settings.

Install by copying the `GabbaUnitFrames` directory into the client's
`Interface/AddOns` directory.

Download the installable ZIP from [GitHub Releases](https://github.com/Gabbajoe/GabbaUnitFrames/releases).
The GitHub-generated source archives are not the installable addon package.

`/guf reset` restores the per-character defaults. Version 1.0.0 targets Classic
Era interface 11509 (1.15.9). The original module in Gabba has been used in-game;
the standalone configuration, minimap button, and coexistence changes are ready
for an in-game test. Raid-layout options require Blizzard's Separate
Groups mode and the corresponding layout APIs.

See [RELEASING.md](RELEASING.md) for checks, reproducible builds, and publishing,
and [curseforge/PROJECT.md](curseforge/PROJECT.md) for project setup materials.
