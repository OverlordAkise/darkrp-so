local Anims = {}

if SERVER then
    util.AddNetworkString("_DarkRP_CustomAnim")
end

-- Load animations after the languages for translation purposes
hook.Add("loadCustomDarkRPItems", "loadAnimations", function()
    Anims[ACT_GMOD_GESTURE_BOW] = DarkRP.getPhrase("bow")
    Anims[ACT_GMOD_TAUNT_MUSCLE] = DarkRP.getPhrase("sexy_dance")
    Anims[ACT_GMOD_GESTURE_BECON] = DarkRP.getPhrase("follow_me")
    Anims[ACT_GMOD_TAUNT_LAUGH] = DarkRP.getPhrase("laugh")
    Anims[ACT_GMOD_TAUNT_PERSISTENCE] = DarkRP.getPhrase("lion_pose")
    Anims[ACT_GMOD_GESTURE_DISAGREE] = DarkRP.getPhrase("nonverbal_no")
    Anims[ACT_GMOD_GESTURE_AGREE] = DarkRP.getPhrase("thumbs_up")
    Anims[ACT_GMOD_GESTURE_WAVE] = DarkRP.getPhrase("wave")
    Anims[ACT_GMOD_TAUNT_DANCE] = DarkRP.getPhrase("dance")
end)

function DarkRP.addPlayerGesture(anim, text)
    Anims[anim] = text
end

function DarkRP.removePlayerGesture(anim)
    Anims[anim] = nil
end

if SERVER then
    local function CustomAnim(ply, cmd, args)
        if ply:EntIndex() == 0 then return end
        local Gesture = tonumber(args[1] or 0)
        if not Anims[Gesture] then return end

        local RP = RecipientFilter()
        RP:AddAllPlayers()

        net.Start("_DarkRP_CustomAnim", RP)
            net.WriteEntity(ply)
            net.WriteInt(Gesture,32)
        net.Send(RP)
    end
    concommand.Add("_DarkRP_DoAnimation", CustomAnim)
    return
end

net.Receive("anim_keys",function()
    local ply = net.ReadEntity()
    local act = net.ReadString()
    
    if not IsValid(ply) then return end
    ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, act == "usekeys" and ACT_GMOD_GESTURE_ITEM_PLACE or ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
end)

net.Receive("_DarkRP_CustomAnim", function()
    local ply = net.ReadEntity()
    local act = net.ReadInt(32)

    if not IsValid(ply) then return end
    ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, act, true)
end)

local AnimFrame
local function AnimationMenu()
    if AnimFrame then return end

    local Panel = vgui.Create("Panel")
    Panel:SetPos(0,0)
    Panel:SetSize(ScrW(), ScrH())
    function Panel:OnMousePressed()
        AnimFrame:Close()
    end

    AnimFrame = AnimFrame or vgui.Create("DFrame", Panel)
    local Height = table.Count(Anims) * 55 + 32
    AnimFrame:SetSize(130, Height)
    AnimFrame:SetPos(ScrW() / 2 + ScrW() * 0.1, ScrH() / 2 - (Height / 2))
    AnimFrame:SetTitle(DarkRP.getPhrase("custom_animation"))
    AnimFrame.btnMaxim:SetVisible(false)
    AnimFrame.btnMinim:SetVisible(false)
    AnimFrame:SetVisible(true)
    AnimFrame:MakePopup()
    AnimFrame:ParentToHUD()

    function AnimFrame:Close()
        Panel:Remove()
        AnimFrame:Remove()
        AnimFrame = nil
    end

    local i = 0
    for k, v in SortedPairs(Anims) do
        i = i + 1
        local button = vgui.Create("DButton", AnimFrame)
        button:SetPos(10, (i - 1) * 55 + 30)
        button:SetSize(110, 50)
        button:SetText(v)

        button.DoClick = function()
            RunConsoleCommand("_DarkRP_DoAnimation", k)
        end
    end
    --darkrp skin was here
end
concommand.Add("_DarkRP_AnimationMenu", AnimationMenu)
