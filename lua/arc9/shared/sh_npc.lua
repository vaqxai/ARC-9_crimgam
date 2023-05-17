hook.Add("InitPostEntity", "ARC9_NPCRegister", function()
    for _, wpn in pairs(weapons.GetList()) do
        local tbl = weapons.Get(wpn.ClassName)

        if !tbl.ARC9 then continue end
        if tbl.NotForNPCs then continue end
        if !tbl.Spawnable then continue end

        list.Add("NPCUsableWeapons",
            {
                class = wpn.ClassName or "Missing ARC9 ClassName",
                title = wpn.PrintName or "Missing ARC9 PrintName"
            }
        )
    end
end)

if SERVER then
    local arc9_npc_give_weapons = GetConVar("arc9_npc_give_weapons")

    net.Receive("arc9_givenpcweapon", function(len, ply)
        local ent = net.ReadEntity()

        if !arc9_npc_give_weapons:GetBool() then return end

        if !ent:IsValid() then return end
        if !ent:IsNPC() then return end

        ARC9.GiveNPCPlayerWeapon(ent, ply)
    end)
end

function ARC9.GiveNPCPlayerWeapon(npc, ply)
    if bit.band(npc:CapabilitiesGet(), CAP_USE_WEAPONS) != CAP_USE_WEAPONS then return end

    if ply:GetPos():DistToSqr(npc:GetPos()) > 40000 then return end

    local weapon = ply:GetActiveWeapon()

    if !weapon.ARC9 then return end

    npc:DropWeapon(nil, ply:GetPos())
    npc:Give(weapon:GetClass())

    timer.Simple(0.05, function() 
        if !IsValid(npc) then return end
        local wpn = npc:GetActiveWeapon()
        if !IsValid(wpn) then return end

        wpn.Attachments = weapon.Attachments
        wpn.WeaponWasGiven = true
        wpn:NPC_Initialize()
        wpn:SendWeapon()
        -- wpn:Activate() -- idk what this for
        wpn:SetClip1(weapon:Clip1())

        ply:StripWeapon(weapon:GetClass())
    end)
end

hook.Add("AllowPlayerPickup", "ARC9_AllowPlayerPickup", function(ply, ent)
    local wep = ply:GetActiveWeapon()
    if !wep.ARC9 then return end

    if wep:GetBipod() then return false end
end)