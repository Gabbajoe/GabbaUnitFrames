# Releases

## Validate and build

```sh
LUAC=luac5.1 bash tests/run_tests.sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
python3 tools/build_package.py --tag v1.0.0
```

Packages and SHA256 checksums are written to `dist/`. Every ZIP contains exactly
one top-level `GabbaUnitFrames` directory, regardless of the checkout name.
Development tools, tests, Git metadata, and CurseForge artwork are excluded.

For future runtime changes, test login/reload, `/guf`, `/guf reset`, party joining
and leaving, pets, target changes, target-of-target, raid Separate Groups, and
layout changes during combat followed by leaving combat in the target client.
Static tests do not establish in-game compatibility or absence of taint.

For 1.0.0, the author confirmed on 2026-10-08 that the module extracted from
Gabba works well in-game. The subsequent code comparison identified missing
fixes, now ported from Gabba. The standalone settings, minimap button and Gabba
coexistence changes still need the planned in-game test before publication.

## Publish

1. Update the TOC version, `CHANGELOG.md`, and matching
   `curseforge/CHANGELOG-<version>.md`.
2. Run checks and commit/push to `main`.
3. Tag that commit with `v<version>` and push the tag.

The Release workflow checks that the tag matches the TOC, tests and packages
the addon, then publishes the ZIP and checksum on GitHub. Versions suffixed
`-dev.N` or `-alpha.N` upload as Alpha; `-beta.N` and `-rc.N` as Beta; plain
major.minor.patch as Release. All suffixed versions are GitHub prereleases.

## CurseForge automation

CurseForge project **1734116** was created by the author. Configure:

- Repository variable `CURSEFORGE_PROJECT_ID`: `1734116`.
- Actions secret `CURSEFORGE_API_TOKEN`: an author upload token.

Never commit tokens or paste them into documentation. The upload uses the
author API, resolves the exact Classic Era game version from the TOC, and fails
if it cannot find one unambiguous match. Without both settings GitHub releases
still work and the CurseForge step reports that it was skipped.

After configuring credentials, the upload can also be run manually with these
environment variables set:

```sh
python3 tools/upload_curseforge.py --check
python3 tools/upload_curseforge.py \
  --archive dist/GabbaUnitFrames-1.0.0.zip \
  --notes curseforge/CHANGELOG-1.0.0.md --tag v1.0.0
```

`--check` validates the token/version lookup, not project ownership. Check the
dashboard before retrying a failed upload or rerunning the Release workflow:
CurseForge uploads are not idempotent and could create duplicate files.
