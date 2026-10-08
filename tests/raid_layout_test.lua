local ns = { Gabba_Print = function() end }
local combat, raid = false, true
local events, hooks = {}, {}
local layouts = 0
local displayType = 1
local editMode, groupShown = false, true
local timers = {}
GabbaCharDB = { raidFrameLayout = { orientation = "default", maxPerLine = 2 } }
Enum = {
    EditModeUnitFrameSetting = { RaidGroupDisplayType = 1 },
    RaidGroupDisplayType = { SeparateGroupsHorizontal = 1, SeparateGroupsVertical = 2 },
}
function InCombatLockdown() return combat end
function IsInRaid() return raid end
function CreateFrame(_, name)
    -- The optional Edit Mode dialog is outside this runtime regression test.
    if name then error("no UI in test") end
    return {
        RegisterEvent = function() end,
        SetScript = function(_, script, callback) events[script] = callback end,
    }
end
C_Timer = { After = function(_, callback) timers[#timers + 1] = callback end }
local function FlushTimers()
    local queued = timers
    timers = {}
    for _, callback in ipairs(queued) do callback() end
end
function SetCVar() end
function hooksecurefunc(_, method, callback) hooks[method] = callback end
local function forbidden() error("full unit-frame refresh must not run from Gabba") end
EditModeManagerFrame = { UpdateRaidContainerFlow = forbidden, IsShown = function() return editMode end }
local group = { GetName = function() return "CompactRaidGroup1" end,
    IsShown = function() return groupShown end, isFlowGroup = true }
local party = setmetatable({ GetName = function() return "CompactPartyFrameMember1" end }, {
    __newindex = function() error("party button must not be modified") end,
})
CompactRaidFrameContainer = {
    flowFrames = { group, "linebreak", party },
    flowOrientation = "vertical", flowMaxPerLine = 5,
    alwaysUseTopLeftAnchor = true,
    GetSettingValue = function() return displayType end,
    TryUpdate = forbidden,
    SetSize = function() assert(not combat, "resize in combat") end,
    Layout = function() assert(not combat); layouts = layouts + 1 end,
}
function FlowContainer_SetOrientation(container, value)
    assert(not combat)
    container.flowOrientation = value
end
function FlowContainer_SetMaxPerLine(container, value)
    assert(not combat)
    container.flowMaxPerLine = value
end
function FlowContainer_DoLayout() assert(not combat) end
ns.db = { raidOrientation = "default", raidGroupsPerLine = 2 }
ns.Print = function() end
assert(loadfile("RaidLayout.lua"))("GabbaUnitFrames", ns)
ns.Gabba_RaidFrameLayout_SetOrientation = function(value)
    ns.db.raidOrientation = value
    ns.RefreshRaid()
end
ns.Gabba_RaidFrameLayout_SetMaxPerLine = function(value)
    ns.db.raidGroupsPerLine = value
    ns.RefreshRaid()
end
events.OnEvent(nil, "PLAYER_ENTERING_WORLD")
assert(CompactRaidFrameContainer.alwaysUseTopLeftAnchor == true, "default login changed container")
assert(layouts == 0)

ns.Gabba_RaidFrameLayout_SetOrientation("horizontal")
assert(layouts == 1 and group.isFlowGroup == false)
assert(CompactRaidFrameContainer.flowMaxPerLine == 2)
combat = true
ns.Gabba_RaidFrameLayout_SetMaxPerLine(3)
assert(layouts == 1, "combat change was not deferred")
combat = false
events.OnEvent(nil, "PLAYER_REGEN_ENABLED")
assert(layouts == 2 and CompactRaidFrameContainer.flowMaxPerLine == 3)

combat = true
ns.Gabba_RaidFrameLayout_SetOrientation("default")
assert(layouts == 2)
combat = false
events.OnEvent(nil, "PLAYER_REGEN_ENABLED")
assert(layouts == 3 and group.isFlowGroup == true)
assert(CompactRaidFrameContainer.flowOrientation == "vertical")
assert(CompactRaidFrameContainer.flowMaxPerLine == 5)
assert(CompactRaidFrameContainer.alwaysUseTopLeftAnchor == true)

ns.Gabba_RaidFrameLayout_SetOrientation("horizontal")
-- Simulate Blizzard changing its defaults and then running our secure post-hook.
CompactRaidFrameContainer.flowOrientation = "horizontal"
CompactRaidFrameContainer.flowMaxPerLine = 4
hooks.UpdateRaidContainerFlow()
ns.Gabba_RaidFrameLayout_SetOrientation("default")
assert(CompactRaidFrameContainer.flowMaxPerLine == 4, "reset used stale Edit Mode defaults")
assert(CompactRaidFrameContainer.alwaysUseTopLeftAnchor == true, "Edit Mode lost original anchor preference")

ns.Gabba_RaidFrameLayout_SetOrientation("horizontal")
raid = false
local before = layouts
ns.Gabba_RaidFrameLayout_SetMaxPerLine(8)
ns.Gabba_RaidFrameLayout_SetOrientation("default")
assert(layouts == before, "raid-to-party transition modified the shared container")
raid = true
ns.Gabba_RaidFrameLayout_SetOrientation("default")
assert(layouts == before + 1)
displayType = 3
ns.Gabba_RaidFrameLayout_SetOrientation("horizontal")
assert(layouts == before + 1, "combined groups were modified")

-- A solo character must be able to configure the visible Edit Mode raid preview.
displayType = 1
raid, editMode = false, true
ns.Gabba_RaidFrameLayout_SetMaxPerLine(4)
assert(layouts == before + 2, "solo raid preview was ignored")
assert(CompactRaidFrameContainer.flowMaxPerLine == 4 and group.isFlowGroup == false)
ns.Gabba_RaidFrameLayout_SetOrientation("default")
assert(group.isFlowGroup == true, "solo preview reset was ignored")
groupShown = false
before = layouts
ns.Gabba_RaidFrameLayout_SetOrientation("horizontal")
assert(layouts == before, "Edit Mode party-only preview was modified")
editMode = false
FlushTimers()

-- Joining a raid after login must apply the setting after Blizzard fills the pool.
raid, groupShown = true, true
events.OnEvent(nil, "GROUP_ROSTER_UPDATE")
assert(layouts == before, "roster update applied before Blizzard populated frames")
FlushTimers()
assert(layouts == before + 1 and CompactRaidFrameContainer.flowMaxPerLine == 4)
group.isFlowGroup = true
combat = true
events.OnEvent(nil, "GROUP_ROSTER_UPDATE")
FlushTimers()
assert(layouts == before + 1 and group.isFlowGroup == true, "roster update changed frames in combat")
combat = false
events.OnEvent(nil, "PLAYER_REGEN_ENABLED")
assert(layouts == before + 2 and group.isFlowGroup == false)
raid, groupShown = false, false
events.OnEvent(nil, "GROUP_ROSTER_UPDATE")
FlushTimers()
assert(layouts == before + 2, "leaving raid modified party container")

-- Edit Mode can rebuild its preview independently of a roster/flow-setting event.
editMode, groupShown = true, true
group.isFlowGroup = true
CompactRaidFrameContainer.flowOrientation = "vertical"
CompactRaidFrameContainer.flowMaxPerLine = 5
before = layouts
hooks.LayoutFrames()
hooks.LayoutFrames()
assert(layouts == before, "reflow ran inside Blizzard's frame rebuild")
FlushTimers()
assert(layouts == before + 1, "frame rebuild refresh was missing or not coalesced")
assert(group.isFlowGroup == false)
assert(CompactRaidFrameContainer.flowOrientation == "horizontal")
assert(CompactRaidFrameContainer.flowMaxPerLine == 4)
ns.Gabba_RaidFrameLayout_SetOrientation("default")
before = layouts
hooks.LayoutFrames()
FlushTimers()
assert(layouts == before and group.isFlowGroup == true, "rebuild hook overrode default layout")
print("raid frame layout regression tests passed")
