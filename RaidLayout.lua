local _, ns = ...

local layoutOverridden, pendingApply, enumWarningShown = false, false, false
local layoutDefaults

local function Available()
    return CompactRaidFrameContainer and CompactRaidFrameContainer.flowFrames
        and EditModeManagerFrame and FlowContainer_SetOrientation
        and FlowContainer_SetMaxPerLine and FlowContainer_DoLayout
        and CompactRaidFrameContainer.Layout and CompactRaidFrameContainer.SetSize
end

local function IsRaidGroupContainer(frame)
    if type(frame) ~= "table" or not frame.GetName then return false end
    local name = frame:GetName()
    return name and name:match("^CompactRaidGroup%d+$") ~= nil
end

local function SetFlowGroupFlag(value)
    -- Blizzard skips maxPerLine for frames flagged isFlowGroup -- has to be
    -- cleared for Column/Row Size to take effect, and restored so Blizzard's
    -- own default layout keeps working once we reset to "default". Uses pairs,
    -- not ipairs -- flowFrames isn't guaranteed gap-free, and ipairs stopping
    -- early would leave the tail end of the groups stuck on the default flag.
    for _, frame in pairs(CompactRaidFrameContainer.flowFrames) do
        -- The flow pool is shared with Compact Party Frames on this client.
        -- Writing isFlowGroup to every table taints CompactPartyFrameMemberX;
        -- Blizzard later gets blocked when it updates that member's protected
        -- private-aura attributes in combat. Only raid group containers belong
        -- to this feature.
        if IsRaidGroupContainer(frame) then
            frame.isFlowGroup = value
        end
    end
end

local function GetGroupCount()
    -- flowFrames keeps a pooled entry per possible group slot even when a group has
    -- no members -- IsShown() filters down to the groups actually on screen, matching
    -- what the player can count visually.
    local count = 0
    for _, frame in pairs(CompactRaidFrameContainer.flowFrames) do
        if IsRaidGroupContainer(frame) and frame:IsShown() then
            count = count + 1
        end
    end
    return count
end

local function IsSeparateGroupsActive()
    local ok, groupsSetting = pcall(CompactRaidFrameContainer.GetSettingValue, CompactRaidFrameContainer,
        Enum and Enum.EditModeUnitFrameSetting and Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)

    if not ok then
        if not enumWarningShown then
            enumWarningShown = true
            ns.Print("Raid frame layout: couldn't read the Separate Groups setting on this client build, cols/orientation disabled.")
        end
        return false
    end

    if not Enum or not Enum.RaidGroupDisplayType then return false end
    return groupsSetting == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
        or groupsSetting == Enum.RaidGroupDisplayType.SeparateGroupsVertical
end

local function ApplyLayout()
    if not ns.db or not Available() then return end
    local settings = ns.db

    -- CompactRaidFrameContainer's flow pool is also used while displaying a
    -- five-player Compact Party Frame. Allow Edit Mode's visible raid preview
    -- without requiring actual raid membership, but leave the party pool alone.
    local raidPreview = EditModeManagerFrame and EditModeManagerFrame:IsShown()
        and GetGroupCount() > 0
    if not IsInRaid() and not raidPreview then
        return
    end

    if settings.raidOrientation == "default" then
        if layoutOverridden then
            if InCombatLockdown() then
                pendingApply = true
                return
            end
            SetFlowGroupFlag(true)
            CompactRaidFrameContainer.alwaysUseTopLeftAnchor = layoutDefaults.alwaysUseTopLeftAnchor
            FlowContainer_SetOrientation(CompactRaidFrameContainer, layoutDefaults.orientation)
            FlowContainer_SetMaxPerLine(CompactRaidFrameContainer, layoutDefaults.maxPerLine)
            layoutOverridden = false
            layoutDefaults = nil
            pendingApply = false
            CompactRaidFrameContainer:SetSize(3000, 3000)
            FlowContainer_DoLayout(CompactRaidFrameContainer)
            CompactRaidFrameContainer:Layout()
        end
        return
    end

    if InCombatLockdown() then
        pendingApply = true
        return
    end
    pendingApply = false

    if not IsSeparateGroupsActive() then
        return -- Only meaningful while "Separate Groups" is the active raid layout.
    end

    if not layoutOverridden then
        layoutDefaults = {
            orientation = CompactRaidFrameContainer.flowOrientation,
            maxPerLine = CompactRaidFrameContainer.flowMaxPerLine,
            alwaysUseTopLeftAnchor = CompactRaidFrameContainer.alwaysUseTopLeftAnchor,
        }
    end
    CompactRaidFrameContainer.alwaysUseTopLeftAnchor = false
    FlowContainer_SetOrientation(CompactRaidFrameContainer, settings.raidOrientation)
    FlowContainer_SetMaxPerLine(CompactRaidFrameContainer, settings.raidGroupsPerLine)
    SetFlowGroupFlag(false)
    layoutOverridden = true
    -- TryUpdate also calls CompactPartyFrame:RefreshMembers, even in a raid.
    -- Running that setup from addon code can taint state used by later secure
    -- updates (including SetSize). Only reflow the existing objects here; do
    -- not rebuild unit frames or call Edit Mode's full refresh on reset.
    CompactRaidFrameContainer:SetSize(3000, 3000)
    FlowContainer_DoLayout(CompactRaidFrameContainer)
    CompactRaidFrameContainer:Layout()
end

ns.RefreshRaid = ApplyLayout
local hooked, queued = false, false
local function QueueRefresh()
    if queued then return end
    queued = true
    C_Timer.After(0, function()
        queued = false
        ApplyLayout()
    end)
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("GROUP_ROSTER_UPDATE")
events:SetScript("OnEvent", function(_, event)
    if not ns.db or not Available() then return end
    if not hooked then
        if InCombatLockdown() then pendingApply = true; return end
        hooked = true
        hooksecurefunc(CompactRaidFrameContainer, "LayoutFrames", QueueRefresh)
        hooksecurefunc(EditModeManagerFrame, "UpdateRaidContainerFlow", function()
            if layoutDefaults then
                layoutDefaults.orientation = CompactRaidFrameContainer.flowOrientation
                layoutDefaults.maxPerLine = CompactRaidFrameContainer.flowMaxPerLine
            end
            if ns.db.raidOrientation ~= "default" then ApplyLayout() end
        end)
    end
    if event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_REGEN_ENABLED" and pendingApply) then
        ApplyLayout()
    elseif event == "GROUP_ROSTER_UPDATE" then
        QueueRefresh()
    end
end)
