local _, ns = ...

local ICON = "Interface\\AddOns\\GabbaUnitFrames\\Assets\\Icon.tga"
local button

local function UpdatePosition()
    local angle = math.rad(tonumber(ns.db.minimapAngle) or 220)
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", 80 * math.cos(angle), 80 * math.sin(angle))
end

local function Drag()
    local mx, my = Minimap:GetCenter()
    if not mx or not my then return end
    local x, y = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    ns.db.minimapAngle = math.deg(math.atan2(y / scale - my, x / scale - mx))
    UpdatePosition()
end

function ns.RefreshMinimap()
    if not ns.db or not Minimap then return end
    if not button then
        button = CreateFrame("Button", "GabbaUnitFramesMinimapButton", Minimap)
        button:SetSize(31, 31)
        button:SetFrameStrata("MEDIUM")
        button:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 8)
        button:EnableMouse(true)
        button:RegisterForClicks("LeftButtonUp")
        button:RegisterForDrag("LeftButton")

        local icon = button:CreateTexture(nil, "BACKGROUND")
        icon:SetTexture(ICON)
        icon:SetSize(20, 20)
        icon:SetPoint("CENTER", 0, 1)
        button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
        local border = button:CreateTexture(nil, "OVERLAY")
        border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        border:SetSize(53, 53)
        border:SetPoint("TOPLEFT", 0, 0)

        button:SetScript("OnClick", function(_, mouseButton)
            if mouseButton == "LeftButton" and ns.ToggleOptions then ns.ToggleOptions() end
        end)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("Gabba Unit Frames")
            GameTooltip:AddLine("Left-click: open settings", 1, 1, 1)
            GameTooltip:AddLine("Drag: move this button", 1, 1, 1)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        button:SetScript("OnDragStart", function(self)
            GameTooltip:Hide()
            self:SetScript("OnUpdate", Drag)
        end)
        button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
        button:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil); GameTooltip:Hide() end)
    end
    UpdatePosition()
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", ns.RefreshMinimap)
