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

Install by copying the `GabbaUnitFrames` directory into the client's
`Interface/AddOns` directory.

Download the installable ZIP from [GitHub Releases](https://github.com/Gabbajoe/GabbaUnitFrames/releases).
The GitHub-generated source archives are not the installable addon package.

`/guf reset` restores the per-character defaults. The current version is a
development alpha targeting Classic Era interface 11509 (1.15.9); in-game
validation is still required. Raid-layout options require Blizzard's Separate
Groups mode and the corresponding layout APIs.

See [RELEASING.md](RELEASING.md) for checks, reproducible builds, and publishing,
and [curseforge/PROJECT.md](curseforge/PROJECT.md) for project setup materials.
