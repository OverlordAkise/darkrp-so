ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "DarkRP billboard"
ENT.Instructions = "Shows advertisements."
ENT.Author = "FPtje"

ENT.Spawnable = false
ENT.Editable = true
ENT.IsDarkRPBillboard = true

cleanup.Register("advert_billboards")

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "TopText", {
        KeyName = "toptext",
        Edit = {
            type = "Generic",
            title = "Top text",
            category = "Text",
            order = 0
        }
    })

    self:NetworkVar("String", 1, "BottomText", {
        KeyName = "bottomtext",
        Edit = {
            type = "Generic",
            title = "Bottom text",
            category = "Text",
            order = 1
        }
    })

    self:NetworkVar("Vector", 0, "BackgroundColor", {
        KeyName = "backgroundcolor",
        Edit = {
            type = "VectorColor",
            title = "Background color",
            category = "Color",
            order = 0
        }
    })

    self:NetworkVar("Vector", 1, "BarColor", {
        KeyName = "barcolor",
        Edit = {
            type = "VectorColor",
            title = "Top bar color",
            category = "Color",
            order = 1
        }
    })
end

DarkRP.declareChatCommand{
    command = "advert",
    description = "Create a billboard holding an advertisement.",
    delay = 1.5
}
