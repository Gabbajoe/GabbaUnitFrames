local _, ns = ...

local overridden, pending, warned = false, false, false

local function Available()
    return CompactRaidFrameContainer and CompactRaidFrameContainer.flowFrames
        and EditModeManagerFrame and FlowContainer_SetOrientation and FlowContainer_SetMaxPerLine
end

local function IsRaidGroup(frame)
    local name = frame and frame.GetName and frame:GetName()
    return name and name:match("^CompactRaidGroup%d+$") ~= nil
end

local function SetGroupFlags(value)
    for _, frame in pairs(CompactRaidFrameContainer.flowFrames) do
        if IsRaidGroup(frame) then frame.isFlowGroup = value end
    end
end

local function SeparateGroups()
    if not Enum or not Enum.EditModeUnitFrameSetting or not Enum.RaidGroupDisplayType
        or not CompactRaidFrameContainer.GetSettingValue then return false end
    local ok, value = pcall(CompactRaidFrameContainer.GetSettingValue, CompactRaidFrameContainer,
        Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
    if not ok then return false end
    return value == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
        or value == Enum.RaidGroupDisplayType.SeparateGroupsVertical
end

local function Apply()
    if not ns.db or not Available() or not IsInRaid() then return end
    local orientation = ns.db.raidOrientation
    if orientation == "default" then
        if overridden then
            if InCombatLockdown() then pending = true; return end
            SetGroupFlags(true); overridden = false
            EditModeManagerFrame:UpdateRaidContainerFlow()
        end
        return
    end
    if InCombatLockdown() then pending = true; return end
    pending = false
    if not SeparateGroups() then
        if not warned then ns.Print("Raid layout requires Blizzard's Separate Groups layout."); warned = true end
        return
    end
    FlowContainer_SetOrientation(CompactRaidFrameContainer, orientation)
    FlowContainer_SetMaxPerLine(CompactRaidFrameContainer, ns.db.raidGroupsPerLine)
    SetGroupFlags(false); overridden = true
    CompactRaidFrameContainer:TryUpdate()
end

ns.RefreshRaid = Apply
local hooked = false
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("GROUP_ROSTER_UPDATE")
events:SetScript("OnEvent", function(_, event)
    if Available() and not hooked then
        hooked = true
        hooksecurefunc(EditModeManagerFrame, "UpdateRaidContainerFlow", function()
            if ns.db and ns.db.raidOrientation ~= "default" then C_Timer.After(0, Apply) end
        end)
    end
    if event == "PLAYER_REGEN_ENABLED" and pending then Apply() else C_Timer.After(0, Apply) end
end)
