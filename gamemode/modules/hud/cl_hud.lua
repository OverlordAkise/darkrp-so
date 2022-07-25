local Color = Color
local CurTime = CurTime
local DarkRP = DarkRP
local draw = draw
local localplayer
local surface = surface
local plyMeta = FindMetaTable("Player")

local colors = {}
colors.black = Color(0, 0, 0, 255)
colors.brightred = Color(200, 30, 30, 255)
colors.darkblack = Color(0, 0, 0, 200)
colors.gray1 = Color(0, 0, 0, 155)
colors.gray2 = Color(51, 58, 51,100)
colors.red = Color(255, 0, 0, 255)
colors.white = Color(255, 255, 255, 255)
colors.white1 = Color(255, 255, 255, 200)

--[[---------------------------------------------------------------------------
HUD separate Elements
---------------------------------------------------------------------------]]

local VoiceChatTexture = surface.GetTextureID("voice/icntlk_pl")
local function DrawVoiceChat()
    if localplayer.DRPIsTalking then
        local _, chboxY = chat.GetChatBoxPos()

        local Rotating = math.sin(CurTime() * 3)
        local backwards = 0

        if Rotating < 0 then
            Rotating = 1 - (1 + Rotating)
            backwards = 180
        end

        surface.SetTexture(VoiceChatTexture)
        surface.SetDrawColor(colors.red)
        surface.DrawTexturedRectRotated(Scrw - 100, chboxY, Rotating * 96, 96, backwards)
    end
end

local AdminTell = fnothing

usermessage.Hook("AdminTell", function(msg)
    timer.Remove("DarkRP_AdminTell")
    local Message = msg:ReadString()

    AdminTell = function()
        draw.RoundedBox(4, 10, 10, Scrw - 20, 110, colors.darkblack)
        draw.DrawNonParsedText(DarkRP.getPhrase("listen_up"), "GModToolName", Scrw / 2 + 10, 10, colors.white, 1)
        draw.DrawNonParsedText(Message, "ChatFont", Scrw / 2 + 10, 90, colors.brightred, 1)
    end

    timer.Create("DarkRP_AdminTell", 10, 1, function()
        AdminTell = fnothing
    end)
end)

--[[
Drawing the HUD elements such as Health etc.
--]]
local function DrawHUD()
    local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_HUD")
    if shouldDraw == false then return end

    DrawVoiceChat()
    AdminTell()
end

--[[---------------------------------------------------------------------------
Entity HUDPaint things
---------------------------------------------------------------------------]]
-- Draw a player's name, health and/or job above the head
-- This syntax allows for easy overriding
plyMeta.drawPlayerInfo = plyMeta.drawPlayerInfo or function(self)
    local pos = self:EyePos()

    pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
    pos = pos:ToScreen()

    if GAMEMODE.Config.showname then
        local nick, plyTeam = self:Nick(), self:Team()
        draw.DrawNonParsedText(nick, "DarkRPHUD2", pos.x + 1, pos.y + 1, colors.black, 1)
        draw.DrawNonParsedText(nick, "DarkRPHUD2", pos.x, pos.y, RPExtraTeams[plyTeam] and RPExtraTeams[plyTeam].color or team.GetColor(plyTeam) , 1)
    end

    if GAMEMODE.Config.showhealth then
        local health = DarkRP.getPhrase("health", math.max(0, self:Health()))
        draw.DrawNonParsedText(health, "DarkRPHUD2", pos.x + 1, pos.y + 21, colors.black, 1)
        draw.DrawNonParsedText(health, "DarkRPHUD2", pos.x, pos.y + 20, colors.white1, 1)
    end

    if GAMEMODE.Config.showjob then
        local teamname = self:getDarkRPVar("job") or team.GetName(self:Team())
        draw.DrawNonParsedText(teamname, "DarkRPHUD2", pos.x + 1, pos.y + 41, colors.black, 1)
        draw.DrawNonParsedText(teamname, "DarkRPHUD2", pos.x, pos.y + 40, colors.white1, 1)
    end
end

--[[---------------------------------------------------------------------------
The Entity display: draw HUD information about entities
---------------------------------------------------------------------------]]
local function DrawEntityDisplay()
    local shouldDraw, players = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_EntityDisplay")
    if shouldDraw == false then return end

    local ent = localplayer:GetEyeTrace().Entity
    if IsValid(ent) and not ent == localplayer and ply:Alive() and not ply:GetNoDraw() and not ply:IsDormant() then
        ent:drawPlayerInfo()
    end
    if IsValid(ent) and ent:isKeysOwnable() and ent:GetPos():DistToSqr(localplayer:GetPos()) < 40000 then
        ent:drawOwnableInfo()
    end
end

--[[---------------------------------------------------------------------------
Drawing death notices
---------------------------------------------------------------------------]]
function GM:DrawDeathNotice(x, y)
    if not GAMEMODE.Config.showdeaths then return end
    self.Sandbox.DrawDeathNotice(self, x, y)
end

--[[---------------------------------------------------------------------------
Display notifications
---------------------------------------------------------------------------]]
local notificationSound = GM.Config.notificationSound
net.Receive("_Notify", function()
    local txt = net.ReadString()
    GAMEMODE:AddNotify(txt, net.ReadInt(8), net.ReadInt(32))
    surface.PlaySound(notificationSound)

    -- Log to client console
    MsgC(Color(255, 20, 20, 255), "[DarkRP] ", Color(200, 200, 200, 255), txt, "\n")
end)


--Actual HUD stuff from now on

local noDraw = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudSuitPower"] = true,
    ["CHUDQuickInfo"] = true
}
function GM:HUDShouldDraw(name)
    if noDraw[name] or (HelpToggled and name == "CHudChat") then
        return false
    else
        return self.Sandbox.HUDShouldDraw(self, name)
    end
end


function GM:HUDDrawTargetID()
    return false
end


function GM:HUDPaint()
    localplayer = localplayer or LocalPlayer()

    DrawHUD()
    DrawEntityDisplay()

    self.Sandbox.HUDPaint(self)
end
