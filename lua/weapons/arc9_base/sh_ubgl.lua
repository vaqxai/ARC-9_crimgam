function SWEP:ThinkUBGL()
    if !self:GetProcessedValue("UBGLInsteadOfSights", true) and self:GetValue("UBGL") then
        local owner = self:GetOwner()
        
        if (owner:KeyDown(IN_USE) and owner:KeyPressed(IN_ATTACK2)) or owner:KeyPressed(ARC9.IN_UBGL) then
            if self.NextUBGLSwitch and self.NextUBGLSwitch > CurTime() then return end
            self.NextUBGLSwitch = CurTime() + 1

            if self:GetUBGL() then
                self:ToggleUBGL(false)
            else
                self:ToggleUBGL(true)
            end
        end
    end
end

function SWEP:ToggleUBGL(on)
    if on == nil then on = !self:GetUBGL() end
    if self:GetReloading() then on = false end
    if self:GetCustomize() then on = false end

    if on == self:GetUBGL() then return end

    if self:StillWaiting() then return end

    self:CancelReload()
    self:SetUBGL(on)

    if on then
        local soundtab = {
            name = "enterubgl",
            sound = self:RandomChoice(self:GetProcessedValue("EnterUBGLSound", true)),
            channel = ARC9.CHAN_FIDDLE
        }

        self:PlayTranslatedSound(soundtab)

        self:PlayAnimation("enter_ubgl", 1, true)
        self:ExitSights()

        if game.SinglePlayer() then
            self:CallOnClient("RecalculateIKGunMotionOffset")
        end
    else
        local soundtab = {
            name = "exitubgl",
            sound = self:RandomChoice(self:GetProcessedValue("ExitUBGLSound", true)),
            channel = ARC9.CHAN_FIDDLE
        }

        self:PlayTranslatedSound(soundtab)

        self:PlayAnimation("exit_ubgl", 1, true)
    end
end