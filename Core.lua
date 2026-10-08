local ADDON, ns = ...

ns.defaults = {
    partyHealth = true,
    partyPower = true,
    showPartyPets = true,
    petName = true,
    petHealth = true,
    petPower = true,
    petScale = 1.5,
    petPosition = "below",
    raidOrientation = "default",
    raidGroupsPerLine = 1,
    playerTargetFontSize = 11,
    hostileExactHealth = true,
    targetOfTargetPercent = true,
}

local function ApplyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then target[key] = value end
    end
end

function ns.Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Gabba Unit Frames:|r " .. tostring(message))
end

function ns.Notify()
    if ns.RefreshParty then ns.RefreshParty(true) end
    if ns.RefreshRaid then ns.RefreshRaid() end
    if ns.RefreshTargets then ns.RefreshTargets() end
    if ns.RefreshOptions then ns.RefreshOptions() end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(_, _, addon)
    if addon ~= ADDON then return end
    GabbaUnitFramesDB = GabbaUnitFramesDB or {}
    ApplyDefaults(GabbaUnitFramesDB, ns.defaults)
    ns.db = GabbaUnitFramesDB
    ns.Notify()
end)

SLASH_GABBAUNITFRAMES1 = "/guf"
SlashCmdList.GABBAUNITFRAMES = function(message)
    message = (message or ""):lower():match("^%s*(.-)%s*$")
    if message == "reset" then
        GabbaUnitFramesDB = {}
        ApplyDefaults(GabbaUnitFramesDB, ns.defaults)
        ns.db = GabbaUnitFramesDB
        ns.Notify()
        ns.Print("Settings reset.")
    elseif ns.ToggleOptions then
        ns.ToggleOptions()
    end
end
