local _, ns = ...

local frame, controls

local function Checkbox(parent, label, x, y, key)
    local box = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    box:SetPoint("TOPLEFT", x, y); box.text:SetText(label)
    box:SetScript("OnClick", function(self) ns.db[key] = self:GetChecked() and true or false; ns.Notify() end)
    return box
end

local function Slider(parent, name, label, x, y, minimum, maximum, step, key, format, transform)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y); slider:SetWidth(180)
    slider:SetMinMaxValues(minimum, maximum); slider:SetValueStep(step)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    _G[name .. "Low"]:SetText(tostring(minimum)); _G[name .. "High"]:SetText(tostring(maximum))
    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / step + 0.5) * step
        _G[name .. "Text"]:SetText(label .. ": " .. format(value))
        if controls and controls.updating then return end
        ns.db[key] = transform and transform(value) or value; ns.Notify()
    end)
    return slider
end

local function CycleButton(parent, x, y, label, key, values, labels)
    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", x, y); title:SetText(label)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(130, 24); button:SetPoint("LEFT", title, "RIGHT", 10, 0)
    button:SetScript("OnClick", function()
        local current = ns.db[key]
        local nextIndex = 1
        for index, value in ipairs(values) do if value == current then nextIndex = index % #values + 1; break end end
        ns.db[key] = values[nextIndex]; ns.Notify()
    end)
    button.Refresh = function(self) self:SetText(labels[ns.db[key]] or tostring(ns.db[key])) end
    return button
end

local function Build()
    frame = CreateFrame("Frame", "GabbaUnitFramesOptions", UIParent, "BasicFrameTemplateWithInset")
    -- Match Gabba's normal windows: clicking changes their front-to-back order.
    -- DIALOG would pin these options above every MEDIUM window.
    frame:SetFrameStrata("MEDIUM")
    frame:SetToplevel(true)
    frame:SetSize(560, 650); frame:SetPoint("CENTER"); frame:SetClampedToScreen(true)
    UISpecialFrames[#UISpecialFrames + 1] = "GabbaUnitFramesOptions"
    frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving); frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    local title = frame.TitleText or _G[frame:GetName() .. "TitleText"]
    if title then title:SetText("Gabba Unit Frames") end

    controls = { updating = false }
    local y = -42
    local function Heading(text)
        local heading = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        heading:SetPoint("TOPLEFT", 24, y); heading:SetText(text); y = y - 30
    end

    Heading("Party members")
    controls.partyHealth = Checkbox(frame, "Show health percentage and value", 24, y, "partyHealth")
    y = y - 28
    controls.partyPower = Checkbox(frame, "Show mana / power percentage and value", 24, y, "partyPower"); y = y - 34

    Heading("Party pets")
    controls.showPartyPets = Checkbox(frame, "Show party pet frames", 24, y, "showPartyPets"); y = y - 32
    controls.petName = Checkbox(frame, "Name", 24, y, "petName")
    controls.petHealth = Checkbox(frame, "Health", 150, y, "petHealth")
    controls.petPower = Checkbox(frame, "Mana / power", 275, y, "petPower"); y = y - 42
    controls.petScale = Slider(frame, "GabbaUnitFramesPetScale", "Pet size", 34, y, 100, 200, 10, "petScale",
        function(v) return v .. "%" end, function(v) return v / 100 end)
    controls.petPosition = CycleButton(frame, 275, y - 2, "Position", "petPosition",
        { "below", "left", "right" }, { below = "Below", left = "Left", right = "Right" }); y = y - 66

    Heading("Raid layout")
    local raidHint = frame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    raidHint:SetPoint("TOPLEFT", 24, y); raidHint:SetWidth(440); raidHint:SetJustifyH("LEFT")
    raidHint:SetText("Applies only to Blizzard raid frames using Separate Groups and is deferred during combat."); y = y - 42
    controls.raidOrientation = CycleButton(frame, 24, y, "Orientation", "raidOrientation",
        { "default", "horizontal", "vertical" }, { default = "Blizzard default", horizontal = "Horizontal", vertical = "Vertical" })
    controls.raidGroupsPerLine = Slider(frame, "GabbaUnitFramesRaidGroups", "Groups per line", 285, y - 4, 1, 8, 1,
        "raidGroupsPerLine", function(v) return tostring(v) end); y = y - 66

    Heading("Player and target labels")
    controls.hostileExactHealth = Checkbox(frame, "Show exact hostile target health", 24, y, "hostileExactHealth")
    y = y - 28
    controls.targetOfTargetPercent = Checkbox(frame, "Show target-of-target health %", 24, y, "targetOfTargetPercent"); y = y - 48
    controls.playerTargetFontSize = Slider(frame, "GabbaUnitFramesLabelSize", "Label size", 34, y, 8, 16, 1,
        "playerTargetFontSize", function(v) return v .. " px" end)
    controls.playerPetFontSize = Slider(frame, "GabbaUnitFramesPlayerPetLabelSize", "Own pet labels", 300, y, 8, 16, 1,
        "playerPetFontSize", function(v) return v .. " px" end)

    local footer = frame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    footer:SetPoint("BOTTOMLEFT", 24, 18); footer:SetText("Open with /guf · Changes made during combat apply afterward.")
    frame:Hide()
end

function ns.RefreshOptions()
    if not frame or not ns.db then return end
    controls.updating = true
    for _, key in ipairs({ "partyHealth", "partyPower", "showPartyPets", "petName", "petHealth", "petPower", "hostileExactHealth", "targetOfTargetPercent" }) do
        controls[key]:SetChecked(ns.db[key])
    end
    controls.petScale:SetValue((ns.db.petScale or 1.5) * 100)
    controls.raidGroupsPerLine:SetValue(ns.db.raidGroupsPerLine or 1)
    controls.playerTargetFontSize:SetValue(ns.db.playerTargetFontSize or 11)
    controls.playerPetFontSize:SetValue(ns.db.playerPetFontSize or 9)
    controls.petPosition:Refresh(); controls.raidOrientation:Refresh()
    controls.updating = false
end

function ns.ToggleOptions()
    if not ns.db then return end
    if not frame then Build() end
    if frame:IsShown() then frame:Hide() else ns.RefreshOptions(); frame:Show(); frame:Raise() end
end
