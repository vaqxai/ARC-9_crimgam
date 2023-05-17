local defaulttracemat = Material("arc9/laser2")
local defaultflaremat = Material("sprites/light_glow02_add", "mips smooth")
local lasercolorred = Color(255, 0, 0)
local lasercolor200 = Color(200, 200, 200)

function SWEP:DrawLaser(pos, dir, atttbl, behav)
    behav = behav or false
    local strength = atttbl.LaserStrength or 1
    local color = atttbl.LaserColor or lasercolorred
    local flaremat = atttbl.LaserFlareMat or defaultflaremat
    local lasermat = atttbl.LaserTraceMat or defaulttracemat

    local dist = 5000

    local tr = util.TraceLine({
        start = pos,
        endpos = pos + (dir * 15000),
        mask = MASK_SHOT,
        filter = self:GetOwner()
    })

    if tr.StartSolid then return end

    local width = math.Rand(0.1, 0.5) * strength

    local hit = tr.Hit
    local hitpos = tr.HitPos

    if tr.HitSky then
        hit = false
        hitpos = pos + (dir * dist)
    end

    local truedist = math.min((tr.Fraction or 1) * 15000, dist)
    local fraction = truedist / dist

    local laspos = pos + (dir * truedist)

    if !behav then
        render.SetMaterial(lasermat)
        render.DrawBeam(pos, laspos, width * 0.2, 0, fraction, lasercolor200)
        render.DrawBeam(pos, laspos, width, 0, fraction, color)
    end

    if hit then
        local rad = math.Rand(4, 6) * strength * math.max(fraction * 3, 1)
        local dotcolor = color
        local whitedotcolor = lasercolor200

        dotcolor.a = 255 - math.min(fraction * 30, 250)
        whitedotcolor.a = 255 - math.min(fraction * 25, 250)

        render.SetMaterial(flaremat)

        render.DrawSprite(hitpos, rad, rad, dotcolor)
        render.DrawSprite(hitpos, rad * 0.3, rad * 0.3, whitedotcolor)
    end
end

function SWEP:DrawLasers(wm, behav)
    if !wm and !IsValid(self:GetOwner()) then return end
    if !wm and self:GetOwner():IsNPC() then return end

    local mdl = self.VModel

    if wm then
        mdl = self.WModel
    end

    if !mdl then
        self:SetupModel(wm)

        mdl = self.VModel

        if wm then
            mdl = self.WModel
        end
    end

    for _, model in ipairs(mdl) do
        local slottbl = model.slottbl
        local atttbl = self:GetFinalAttTable(slottbl)

        if atttbl.Laser then
            local pos, ang = self:GetAttachmentPos(slottbl, wm, false)
            model:SetPos(pos)
            model:SetAngles(ang)

            local a

            if atttbl.LaserAttachment then
                a = model:GetAttachment(atttbl.LaserAttachment)
            else
                a = {
                    Pos = model:GetPos(),
                    Ang = model:GetAngles()
                }

                a.Ang:RotateAroundAxis(a.Ang:Up(), -90)
            end

            if !a then return end

            local lasercorrectionangle = model.LaserCorrectionAngle
            local lasang = a.Ang

            if lasercorrectionangle then
                local up, right, forward = lasang:Up(), lasang:Right(), lasang:Forward()

                lasang:RotateAroundAxis(up, lasercorrectionangle.p)
                lasang:RotateAroundAxis(right, lasercorrectionangle.y)
                lasang:RotateAroundAxis(forward, lasercorrectionangle.r)
            end
                
            self:DrawLightFlare(a.Pos, lasang, atttbl.LaserColor, wm and 5 or 10, slottbl.Address + 69, !wm)
                
            if !wm or self:GetOwner() == LocalPlayer() then
                if behav then
                    self:DrawLaser(a.Pos, self:GetShootDir():Forward(), atttbl, behav)
                else
                    self:DrawLaser(a.Pos, -lasang:Right(), atttbl, behav)
                end
            else
                self:DrawLaser(a.Pos, self:GetShootDir():Forward(), atttbl, behav)
            end
        end
    end
end