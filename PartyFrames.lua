local _, ns = ...

local memberOverlays = setmetatable({}, { __mode = "k" })
local petOverlays = setmetatable({}, { __mode = "k" })
local petDefaults = setmetatable({}, { __mode = "k" })
local pendingLayout = false

local function Percent(value, maximum)
    return maximum > 0 and math.floor(value / maximum * 100 + 0.5) .. "%" or "0%"
end

local function Frames()
    local result = {}
    for index = 1, 4 do
        local member = PartyFrame and PartyFrame["MemberFrame" .. index]
        local pet = member and member.PetFrame
        if member and pet then result[#result + 1] = { index = index, member = member, pet = pet } end
    end
    return result
end

local function NewValuePair(parent, bar, size)
    local left = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
    left:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
    left:SetPoint("LEFT", bar, "LEFT", 2, 0)
    local right = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
    right:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
    right:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
    return left, right
end

local function MemberOverlay(member)
    if memberOverlays[member] then return memberOverlays[member] end
    if InCombatLockdown() then pendingLayout = true; return nil end
    local frame = CreateFrame("Frame", nil, member)
    frame:SetAllPoints(member); frame:SetFrameLevel(member:GetFrameLevel() + 20); frame:EnableMouse(false)
    local health = member.HealthBar or member.healthBar or member
    local power = member.ManaBar or member.PowerBar or member.manaBar or member.powerBar or health
    frame.health, frame.healthValue = NewValuePair(frame, health, 9)
    frame.power, frame.powerValue = NewValuePair(frame, power, 9)
    memberOverlays[member] = frame
    return frame
end

local function PetOverlay(pet, member)
    if petOverlays[pet] then return petOverlays[pet] end
    if InCombatLockdown() then pendingLayout = true; return nil end
    local frame = CreateFrame("Frame", nil, member)
    frame:SetAllPoints(member); frame:SetFrameStrata("HIGH"); frame:SetFrameLevel(member:GetFrameLevel() + 20); frame:EnableMouse(false)
    local health = pet.HealthBar or pet.healthBar or pet
    local power = pet.ManaBar or pet.PowerBar or pet.manaBar or pet.powerBar or health
    frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.name:SetFont(STANDARD_TEXT_FONT, 8, "OUTLINE"); frame.name:SetPoint("BOTTOMLEFT", health, "TOPLEFT", 0, 3)
    frame.health, frame.healthValue = NewValuePair(frame, health, 8)
    frame.power, frame.powerValue = NewValuePair(frame, power, 8)
    petOverlays[pet] = frame
    return frame
end

local function UpdateValues()
    if not ns.db then return end
    for _, entry in ipairs(Frames()) do
        local memberUnit = "party" .. entry.index
        local member = MemberOverlay(entry.member)
        local memberExists = UnitExists(memberUnit)
        if member then
            member.health:SetShown(memberExists and ns.db.partyHealth)
            member.healthValue:SetShown(memberExists and ns.db.partyHealth)
            member.power:SetShown(memberExists and ns.db.partyPower)
            member.powerValue:SetShown(memberExists and ns.db.partyPower)
            if memberExists then
                local hp, hpMax = UnitHealth(memberUnit) or 0, UnitHealthMax(memberUnit) or 0
                local mp, mpMax = UnitPower(memberUnit) or 0, UnitPowerMax(memberUnit) or 0
                member.health:SetText(Percent(hp, hpMax)); member.healthValue:SetText(hp)
                member.power:SetText(Percent(mp, mpMax)); member.powerValue:SetText(mp)
            end
        end

        local petUnit = "partypet" .. entry.index
        local pet = PetOverlay(entry.pet, entry.member)
        local petExists = UnitExists(petUnit)
        if pet then
            pet:SetFrameStrata("HIGH"); pet:SetFrameLevel(math.max(entry.member:GetFrameLevel(), entry.pet:GetFrameLevel()) + 20)
            pet.name:SetShown(petExists and ns.db.petName)
            pet.health:SetShown(petExists and ns.db.petHealth); pet.healthValue:SetShown(petExists and ns.db.petHealth)
            pet.power:SetShown(petExists and ns.db.petPower); pet.powerValue:SetShown(petExists and ns.db.petPower)
            if petExists then
                local hp, hpMax = UnitHealth(petUnit) or 0, UnitHealthMax(petUnit) or 0
                local mp, mpMax = UnitPower(petUnit) or 0, UnitPowerMax(petUnit) or 0
                pet.name:SetText(UnitName(petUnit) or "Pet")
                pet.health:SetText(Percent(hp, hpMax)); pet.healthValue:SetText(hp)
                pet.power:SetText(Percent(mp, mpMax)); pet.powerValue:SetText(mp)
            end
        end
    end
end

local function ApplyLayout()
    if not ns.db then return end
    if InCombatLockdown() then pendingLayout = true; UpdateValues(); return end
    pendingLayout = false
    local desired = ns.db.showPartyPets and true or false
    if GetCVarBool and GetCVarBool("showPartyPets") ~= desired then SetCVar("showPartyPets", desired and "1" or "0") end
    for _, entry in ipairs(Frames()) do
        local pet, member = entry.pet, entry.member
        if not petDefaults[pet] then petDefaults[pet] = { scale = pet:GetScale() } end
        local scale = math.max(1, math.min(2, tonumber(ns.db.petScale) or 1.5))
        pet:SetScale(scale); pet:ClearAllPoints()
        if ns.db.petPosition == "left" then pet:SetPoint("RIGHT", member, "LEFT", -4 / scale, 0)
        elseif ns.db.petPosition == "right" then pet:SetPoint("LEFT", member, "RIGHT", 4 / scale, 0)
        else pet:SetPoint("TOP", member, "BOTTOM", 0, 15 / scale) end
    end
    UpdateValues()
end

ns.RefreshParty = ApplyLayout
local events = CreateFrame("Frame")
for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED", "GROUP_ROSTER_UPDATE", "UNIT_PET", "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_NAME_UPDATE", "CVAR_UPDATE" }) do events:RegisterEvent(event) end
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" and pendingLayout then ApplyLayout()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" or event == "UNIT_PET" or event == "CVAR_UPDATE" then C_Timer.After(0, ApplyLayout)
    else UpdateValues() end
end)
