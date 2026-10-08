-- Exact target health text for Classic Era's portrait-style TargetFrame.
-- The text belongs to Gabba and is parented to UIParent; it is only anchored
-- visually to Blizzard's health bar. We never add fields, scripts or
-- attributes to the protected target button itself.

local ADDON_NAME, ns = ...

local overlay = CreateFrame("Frame", nil, UIParent)
overlay:SetSize(1, 1)
overlay:Hide()

local text = overlay:CreateFontString(nil, "OVERLAY")
text:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
text:SetTextColor(1, 1, 1)
text:SetJustifyH("RIGHT")

local anchoredTo

local targetOfTargetOverlay = CreateFrame("Frame", nil, UIParent)
targetOfTargetOverlay:SetSize(1, 1)
targetOfTargetOverlay:Hide()

local targetOfTargetText = targetOfTargetOverlay:CreateFontString(nil, "OVERLAY")
targetOfTargetText:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
targetOfTargetText:SetTextColor(1, 1, 1)
targetOfTargetText:SetJustifyH("CENTER")

local targetOfTargetAnchoredTo

local function StatusFontSize()
    return tonumber(ns.db and ns.db.playerTargetFontSize) or 11
end

local function ResizeFontString(region)
    if not region or not region.GetFont or not region.SetFont then return end
    local font, _, flags = region:GetFont()
    if font then region:SetFont(font, StatusFontSize(), flags or "OUTLINE") end
end

local function ResizeStatusBarText(frame, visited)
    if not frame or visited[frame] then return end
    visited[frame] = true

    if frame.GetObjectType and frame:GetObjectType() == "StatusBar" and frame.GetRegions then
        for _, region in ipairs({ frame:GetRegions() }) do
            if region.GetObjectType
                and region:GetObjectType() == "FontString"
                and region.GetFont
                and region.SetFont
            then
                ResizeFontString(region)
            end
        end
    end

    if frame.GetChildren then
        for _, child in ipairs({ frame:GetChildren() }) do
            ResizeStatusBarText(child, visited)
        end
    end
end

local function ResizePlayerAndTargetText()
    local visited = {}
    ResizeStatusBarText(PlayerFrame, visited)
    ResizeStatusBarText(TargetFrame, visited)

    -- Classic's portrait frames parent several status texts to their texture
    -- frame instead of the StatusBar itself, so GetRegions() above cannot see
    -- them. Cover both table fields and the stable global names used by the
    -- Blizzard unit-frame code and compatible addons.
    for _, region in pairs({
        PlayerFrameHealthBar and PlayerFrameHealthBar.TextString,
        PlayerFrameHealthBar and PlayerFrameHealthBar.LeftText,
        PlayerFrameHealthBar and PlayerFrameHealthBar.RightText,
        PlayerFrameManaBar and PlayerFrameManaBar.TextString,
        PlayerFrameManaBar and PlayerFrameManaBar.LeftText,
        PlayerFrameManaBar and PlayerFrameManaBar.RightText,
        PlayerFrameTextureFrame and PlayerFrameTextureFrame.HealthBarText,
        PlayerFrameTextureFrame and PlayerFrameTextureFrame.ManaBarText,
        PlayerFrameHealthBarText,
        PlayerFrameHealthBarTextLeft,
        PlayerFrameHealthBarTextRight,
        PlayerFrameManaBarText,
        PlayerFrameManaBarTextLeft,
        PlayerFrameManaBarTextRight,
        TargetFrameHealthBar and TargetFrameHealthBar.TextString,
        TargetFrameHealthBar and TargetFrameHealthBar.LeftText,
        TargetFrameHealthBar and TargetFrameHealthBar.RightText,
        TargetFrameManaBar and TargetFrameManaBar.TextString,
        TargetFrameManaBar and TargetFrameManaBar.LeftText,
        TargetFrameManaBar and TargetFrameManaBar.RightText,
        TargetFrameTextureFrame and TargetFrameTextureFrame.HealthBarText,
        TargetFrameTextureFrame and TargetFrameTextureFrame.ManaBarText,
        TargetFrameHealthBarText,
        TargetFrameHealthBarTextLeft,
        TargetFrameHealthBarTextRight,
        TargetFrameManaBarText,
        TargetFrameManaBarTextLeft,
        TargetFrameManaBarTextRight,
    }) do
        ResizeFontString(region)
    end
end

local function SetNativeTargetRightTextShown(shown)
    local alpha = shown and 1 or 0
    for _, region in pairs({
        TargetFrameHealthBar and TargetFrameHealthBar.RightText,
        TargetFrameHealthBarTextRight,
    }) do
        if region and region.SetAlpha then region:SetAlpha(alpha) end
    end
end

local function GetTargetHealthBar()
    if TargetFrameHealthBar then return TargetFrameHealthBar end
    if not TargetFrame then return nil end
    return TargetFrame.healthbar
        or TargetFrame.HealthBar
        or (TargetFrame.TargetFrameContent
            and TargetFrame.TargetFrameContent.TargetFrameContentMain
            and TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBar)
end

local function GetTargetOfTargetHealthBar()
    if TargetFrameToTHealthBar then return TargetFrameToTHealthBar end
    if not TargetFrameToT then return nil end
    return TargetFrameToT.healthbar or TargetFrameToT.HealthBar
end

local function SyncOverlayLayer(frame, owner, healthBar)
    -- These overlays deliberately live on UIParent to avoid modifying
    -- protected unit frames. Classic's portrait frames render some bar
    -- textures above the strata reported by the StatusBar itself, so use a
    -- stable middle layer: above unit-frame artwork, below bags and dialogs.
    frame:SetFrameStrata("MEDIUM")
    local ownerLevel = owner and owner.GetFrameLevel and owner:GetFrameLevel() or 1
    local barLevel = healthBar:GetFrameLevel() or 1
    frame:SetFrameLevel(math.max(ownerLevel, barLevel) + 20)
end

local function UpdateTargetOfTarget()
    if not ns.db.targetOfTargetPercent then
        targetOfTargetOverlay:Hide()
        return
    end

    local healthBar = GetTargetOfTargetHealthBar()
    if not healthBar or not UnitExists("targettarget") then
        targetOfTargetOverlay:Hide()
        return
    end

    if targetOfTargetAnchoredTo ~= healthBar then
        targetOfTargetAnchoredTo = healthBar
        targetOfTargetOverlay:ClearAllPoints()
        targetOfTargetOverlay:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
        targetOfTargetText:ClearAllPoints()
        targetOfTargetText:SetPoint("CENTER", targetOfTargetOverlay, "CENTER", 0, 0)
    end
    SyncOverlayLayer(targetOfTargetOverlay, TargetFrameToT, healthBar)

    local uiScale = UIParent:GetEffectiveScale() or 1
    local barScale = healthBar:GetEffectiveScale() or uiScale
    targetOfTargetOverlay:SetScale(uiScale > 0 and barScale / uiScale or 1)

    local health = UnitHealth("targettarget") or 0
    local maximum = UnitHealthMax("targettarget") or 0
    if maximum <= 0 then
        targetOfTargetOverlay:Hide()
        return
    end

    targetOfTargetText:SetFont(STANDARD_TEXT_FONT, math.max(8, StatusFontSize() - 2), "OUTLINE")
    targetOfTargetText:SetText(math.floor(health / maximum * 100 + 0.5) .. "%")
    targetOfTargetOverlay:Show()
end

local function Anchor()
    local healthBar = GetTargetHealthBar()
    if not healthBar then return false end
    if anchoredTo ~= healthBar then
        anchoredTo = healthBar
        overlay:ClearAllPoints()
        overlay:SetPoint("RIGHT", healthBar, "RIGHT", -2, 0)
        text:ClearAllPoints()
        text:SetPoint("RIGHT", overlay, "RIGHT", 0, 0)
    end
    SyncOverlayLayer(overlay, TargetFrame, healthBar)

    -- The addon overlay is parented to UIParent for taint safety, so it does
    -- not naturally inherit a moved/scaled TargetFrame's effective scale.
    -- Mirror that scale explicitly and copy the native left percentage's font
    -- face/flags so the added hostile-health value is visually identical.
    local uiScale = UIParent:GetEffectiveScale() or 1
    local barScale = healthBar:GetEffectiveScale() or uiScale
    overlay:SetScale(uiScale > 0 and barScale / uiScale or 1)

    text:SetFont(STANDARD_TEXT_FONT, StatusFontSize(), "OUTLINE")
    local nativeLeft = healthBar.LeftText or TargetFrameHealthBarTextLeft
    if nativeLeft and nativeLeft.GetFont then
        local font, _, flags = nativeLeft:GetFont()
        if font then text:SetFont(font, StatusFontSize(), flags or "OUTLINE") end
    end
    return true
end

local function Update()
    if not ns.db then return end
    ResizePlayerAndTargetText()
    UpdateTargetOfTarget()
    -- Blizzard already displays exact health for friendly targets. Classic Era
    -- leaves only the right-hand value empty for hostile targets, while still
    -- exposing the real UnitHealth value. Fill precisely that missing slot so
    -- the native percentage on the left remains unobstructed.
    local hostile = ns.db.hostileExactHealth and UnitExists("target") and UnitCanAttack("player", "target")
    SetNativeTargetRightTextShown(not hostile)
    if not hostile
        or not Anchor()
    then
        overlay:Hide()
        return
    end

    local health = UnitHealth("target") or 0
    local maximum = UnitHealthMax("target") or 0
    if maximum <= 0 then
        overlay:Hide()
        return
    end

    text:SetText(tostring(health))
    overlay:Show()
end

ns.RefreshTargets = Update

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
events:RegisterUnitEvent("UNIT_HEALTH", "target", "targettarget")
events:RegisterUnitEvent("UNIT_MAXHEALTH", "target", "targettarget")
events:RegisterUnitEvent("UNIT_TARGET", "target")
events:SetScript("OnEvent", Update)
