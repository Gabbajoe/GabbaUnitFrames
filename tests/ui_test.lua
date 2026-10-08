local frames = {}
local function noop() end
local methods = {
    SetSize = noop, SetFrameStrata = noop, EnableMouse = noop, RegisterForClicks = noop,
    RegisterForDrag = noop, SetHighlightTexture = noop, ClearAllPoints = noop,
    RegisterEvent = noop, RegisterUnitEvent = noop, SetTextColor = noop, SetJustifyH = noop,
    SetScale = noop,
    SetJustifyV = function(self, value) self.justifyV = value end,
    SetPoint = function(self, ...) self.point = {...} end,
    SetFrameLevel = function(self, value) self.level = value end,
    SetScript = function(self, name, callback) self.scripts[name] = callback end,
    SetTexture = function(self, value) self.texture = value end,
    GetFrameLevel = function(self) return self.level or 1 end,
    GetEffectiveScale = function() return 1 end,
    SetFont = function(self, face, size, flags) self.font = {face, size, flags} end,
    GetFont = function(self) if self.font then return self.font[1], self.font[2], self.font[3] end end,
    SetText = function(self, value) assert(self.font, 'text has no font'); self.text = value end,
    SetAlpha = function(self, value) self.alpha = value end,
    Hide = function(self) self.shown = false end,
    Show = function(self) self.shown = true end,
}
local function object()
    return setmetatable({scripts = {}}, {__index = methods})
end
function methods:CreateTexture() local o = object(); self.textureObject = o; return o end
function methods:CreateFontString() local o = object(); self.label = o; return o end
function CreateFrame(_, name)
    local frame = object()
    frames[#frames + 1] = frame
    if name then _G[name] = frame end
    return frame
end
Minimap = object()
Minimap.GetCenter = function() return 100, 100 end
GetCursorPosition = function() return 180, 100 end
GameTooltip = {Hide = noop}
math.atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
local toggles = 0
local ns = { db = {minimapAngle = 220}, ToggleOptions = function() toggles = toggles + 1 end }
assert(loadfile('Minimap.lua'))('GabbaUnitFrames', ns)
ns.RefreshMinimap()
local button = GabbaUnitFramesMinimapButton
local count = #frames
ns.RefreshMinimap()
assert(#frames == count, 'duplicate minimap button')
button.scripts.OnClick(button, 'LeftButton')
button.scripts.OnClick(button, 'RightButton')
assert(toggles == 1, 'left click did not exclusively toggle options')
assert(button.textureObject.texture == 'Interface\\Minimap\\MiniMap-TrackingBorder')
button.scripts.OnDragStart(button)
button.scripts.OnUpdate(button)
assert(ns.db.minimapAngle == 0 and button.point[4] == 80)
button.scripts.OnDragStop(button)
assert(button.scripts.OnUpdate == nil, 'drag update leaked')
ns.db.minimapAngle = 90
ns.RefreshMinimap()
assert(math.abs(button.point[5] - 80) < 0.001, 'saved position ignored')

UIParent = object()
STANDARD_TEXT_FONT = 'Fonts/FRIZQT__.TTF'
TargetFrame = object()
TargetFrameHealthBar = object()
TargetFrameHealthBar.LeftText = object()
TargetFrameHealthBar.LeftText:SetFont('native-font', 10, 'OUTLINE')
TargetFrameHealthBar.RightText = object()
TargetFrameHealthBarTextRight = object()
TargetFrameToTHealthBar = object()
UnitExists = function() return true end
UnitCanAttack = function() return true end
UnitHealth = function(unit) return unit == 'target' and 1234 or 50 end
UnitHealthMax = function(unit) return unit == 'target' and 2000 or 100 end
ns.db.hostileExactHealth, ns.db.targetOfTargetPercent = true, true
ns.db.playerTargetFontSize = 12
local start = #frames
PetFrameHealthBar = object()
PetFrameHealthBar.LeftText = object()
PetFrameHealthBar.LeftText:SetFont('pet-font', 16, 'OUTLINE')
PetFrameManaBarTextRight = object()
PetFrameManaBarTextRight:SetFont('pet-font', 16, 'OUTLINE')
PetFrameManaBar = object()
PetFrameManaBar.LeftText = object()
PetFrameManaBar.LeftText:SetFont('pet-font', 16, 'OUTLINE')
PetFrameManaBarText = object()
PetFrameManaBarText:SetFont('pet-font', 16, 'OUTLINE')
local combat = false
InCombatLockdown = function() return combat end
assert(loadfile('TargetLabels.lua'))('GabbaUnitFrames', ns)
ns.RefreshTargets()
assert(PetFrameHealthBar.LeftText.font[2] == 9, 'own pet default text is too large')
assert(PetFrameManaBarTextRight.font[2] == 9, 'own pet global power text was missed')
for _, entry in ipairs({{PetFrameManaBar.LeftText, 'LEFT'},
                       {PetFrameManaBarTextRight, 'RIGHT'}, {PetFrameManaBarText, 'CENTER'}}) do
    local region, side = entry[1], entry[2]
    assert(region.point[1] == side and region.point[2] == PetFrameManaBar)
    assert(region.point[3] == side and region.point[5] == -3, 'power text needs the adjusted downward inset')
    assert(region.justifyV == 'MIDDLE')
end
assert(PetFrameHealthBar.LeftText.point[5] == 1, 'health text needs a small upward inset')
local previousAnchor = PetFrameManaBarTextRight.point
combat = true
ns.RefreshTargets()
assert(PetFrameManaBarTextRight.point == previousAnchor, 'pet text reanchored in combat')
combat = false
frames[#frames].scripts.OnEvent(nil, 'PLAYER_REGEN_ENABLED')
assert(PetFrameManaBarTextRight.point ~= previousAnchor, 'pet text anchor not refreshed after combat')
ns.db.playerPetFontSize = 10
ns.RefreshTargets()
assert(PetFrameHealthBar.LeftText.font[2] == 10, 'own pet text option not applied')
assert(TargetFrameHealthBar.LeftText.font[2] == 12, 'pet option changed target text')
local hostile, tot = frames[start + 1], frames[start + 2]
assert(hostile.shown and hostile.label.text == '1234')
assert(hostile.label.font[1] == 'native-font' and hostile.label.font[2] == 12)
assert(hostile.label.point[1] == 'RIGHT', 'hostile health is not right aligned')
assert(tot.shown and tot.label.text == '50%')
assert(TargetFrameHealthBar.RightText.alpha == 0 and TargetFrameHealthBarTextRight.alpha == 0)
ns.db.hostileExactHealth, ns.db.targetOfTargetPercent = false, false
ns.RefreshTargets()
assert(not hostile.shown and not tot.shown)
assert(TargetFrameHealthBar.RightText.alpha == 1 and TargetFrameHealthBarTextRight.alpha == 1)
print('minimap and target label regression tests passed')
