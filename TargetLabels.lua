local _, ns = ...

local hostileOverlay = CreateFrame("Frame", nil, UIParent)
local hostileText = hostileOverlay:CreateFontString(nil, "OVERLAY")
hostileText:SetPoint("CENTER"); hostileText:SetTextColor(1, 1, 1); hostileOverlay:Hide()
local totOverlay = CreateFrame("Frame", nil, UIParent)
local totText = totOverlay:CreateFontString(nil, "OVERLAY")
totText:SetPoint("CENTER"); totText:SetTextColor(1, 1, 1); totOverlay:Hide()
local hostileAnchor, totAnchor

local function Font(region, size)
    if not region or not region.GetFont then return end
    local face, _, flags = region:GetFont()
    if face then region:SetFont(face, size, flags or "OUTLINE") end
end

local function ResizeFrame(frame, seen, size)
    if not frame or seen[frame] then return end
    seen[frame] = true
    if frame.GetObjectType and frame:GetObjectType() == "StatusBar" and frame.GetRegions then
        for _, region in ipairs({ frame:GetRegions() }) do
            if region.GetObjectType and region:GetObjectType() == "FontString" then Font(region, size) end
        end
    end
    if frame.GetChildren then for _, child in ipairs({ frame:GetChildren() }) do ResizeFrame(child, seen, size) end end
end

local function TargetBar()
    return TargetFrameHealthBar or (TargetFrame and (TargetFrame.healthbar or TargetFrame.HealthBar))
end

local function ToTBar()
    return TargetFrameToTHealthBar or (TargetFrameToT and (TargetFrameToT.healthbar or TargetFrameToT.HealthBar))
end

local function Layer(overlay, owner, bar)
    overlay:SetFrameStrata("MEDIUM")
    overlay:SetFrameLevel(math.max(owner and owner:GetFrameLevel() or 1, bar:GetFrameLevel() or 1) + 20)
    local uiScale, barScale = UIParent:GetEffectiveScale() or 1, bar:GetEffectiveScale() or 1
    overlay:SetScale(uiScale > 0 and barScale / uiScale or 1)
end

local function Update()
    if not ns.db then return end
    local size = tonumber(ns.db.playerTargetFontSize) or 11
    local seen = {}; ResizeFrame(PlayerFrame, seen, size); ResizeFrame(TargetFrame, seen, size)
    -- Classic parents some native status text to texture frames rather than to
    -- the StatusBars themselves, so the recursive pass cannot discover it.
    for _, region in pairs({
        PlayerFrameHealthBarText, PlayerFrameHealthBarTextLeft, PlayerFrameHealthBarTextRight,
        PlayerFrameManaBarText, PlayerFrameManaBarTextLeft, PlayerFrameManaBarTextRight,
        TargetFrameHealthBarText, TargetFrameHealthBarTextLeft, TargetFrameHealthBarTextRight,
        TargetFrameManaBarText, TargetFrameManaBarTextLeft, TargetFrameManaBarTextRight,
        PlayerFrameTextureFrame and PlayerFrameTextureFrame.HealthBarText,
        PlayerFrameTextureFrame and PlayerFrameTextureFrame.ManaBarText,
        TargetFrameTextureFrame and TargetFrameTextureFrame.HealthBarText,
        TargetFrameTextureFrame and TargetFrameTextureFrame.ManaBarText,
    }) do Font(region, size) end

    local totBar = ToTBar()
    if ns.db.targetOfTargetPercent and totBar and UnitExists("targettarget") then
        if totAnchor ~= totBar then totAnchor = totBar; totOverlay:ClearAllPoints(); totOverlay:SetPoint("CENTER", totBar) end
        Layer(totOverlay, TargetFrameToT, totBar); totText:SetFont(STANDARD_TEXT_FONT, math.max(8, size - 2), "OUTLINE")
        local hp, maximum = UnitHealth("targettarget") or 0, UnitHealthMax("targettarget") or 0
        if maximum > 0 then totText:SetText(math.floor(hp / maximum * 100 + 0.5) .. "%"); totOverlay:Show() else totOverlay:Hide() end
    else totOverlay:Hide() end

    local bar = TargetBar()
    local hostile = ns.db.hostileExactHealth and UnitExists("target") and UnitCanAttack("player", "target")
    local nativeRight = bar and (bar.RightText or TargetFrameHealthBarTextRight)
    if nativeRight and nativeRight.SetAlpha then nativeRight:SetAlpha(hostile and 0 or 1) end
    if hostile and bar then
        if hostileAnchor ~= bar then hostileAnchor = bar; hostileOverlay:ClearAllPoints(); hostileOverlay:SetPoint("RIGHT", bar, "RIGHT", -2, 0) end
        Layer(hostileOverlay, TargetFrame, bar); Font(hostileText, size)
        local hp, maximum = UnitHealth("target") or 0, UnitHealthMax("target") or 0
        if maximum > 0 then hostileText:SetText(hp); hostileOverlay:Show() else hostileOverlay:Hide() end
    else hostileOverlay:Hide() end
end

ns.RefreshTargets = Update
local events = CreateFrame("Frame")
for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED", "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_TARGET" }) do events:RegisterEvent(event) end
events:SetScript("OnEvent", Update)
