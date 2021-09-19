/*--------------------------------------------------
	=============== VJ HUD ===============
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
/*----------------------------------------------------------
	-- Screen Information --
Down = Positive
Up = Negative
Right = Positive
Left = Negative
----------------------------------------------------------*/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ SERVER ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (SERVER) then
	util.AddNetworkString("vj_hud_godmode")
	net.Receive("vj_hud_godmode", function(len, pl)
		if IsValid(pl) then
			pl:SetNW2Bool("vj_hud_godmode", pl:HasGodMode())
		end
	end)
	
	util.AddNetworkString("vj_hud_ent_info")
	net.Receive("vj_hud_ent_info", function(len, pl)
		local ent = net.ReadEntity()
		if IsValid(pl) && IsValid(ent) then
			pl:SetNW2Int("vj_hud_trhealth", ent:Health())
			pl:SetNW2Int("vj_hud_trmaxhealth", ent:GetMaxHealth())
			if ent:IsNPC() then
				local npc_hm = (ent.VJ_IsHugeMonster == true and "1") or "0"
				local npc_guard = (ent.IsGuard == true and "1") or "0"
				local npc_medic = (ent.IsMedicSNPC == true and "1") or "0"
				local npc_controlled = (ent.VJ_IsBeingControlled == true and "1") or "0"
				local npc_followingply = (ent.FollowingPlayer == true and "1") or "0"
				local npc_followingplyn = (ent.FollowingPlayer == true and ent.FollowPlayer_Entity:Nick()) or "Unknown"
				if npc_followingplyn == pl:Nick() then npc_followingplyn = "You" end
				pl:SetNW2String("vj_hud_tr_npc_info", npc_hm..ent:Disposition(pl)..npc_guard..npc_medic..npc_controlled..npc_followingply..npc_followingplyn)
			end
		end
	end)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ CLIENT ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (!CLIENT) then return end

-- Static Values
local color = Color

-- Materials
local mat_crossh1 = Material("Crosshair/vj_crosshair1.vtf")
local mat_crossh2 = Material("Crosshair/vj_crosshair2.vtf")
local mat_crossh3 = Material("Crosshair/vj_crosshair3.vtf")
local mat_crossh4 = Material("Crosshair/vj_crosshair4.vtf")
local mat_crossh5 = Material("Crosshair/vj_crosshair5.vtf")
local mat_crossh6 = Material("Crosshair/vj_crosshair6.vtf")
local mat_crossh7 = Material("Crosshair/vj_crosshair7.vtf")
local mat_crossh8 = Material("Crosshair/vj_crosshair8.vtf")
local mat_crossh9 = Material("Crosshair/vj_crosshair9.vtf")
local mat_flashlight_on = Material("vj_hud/flashlight_on.png")
local mat_flashlight_off = Material("vj_hud/flashlight_off.png")
local mat_grenade = Material("vj_hud/grenade.png")
local mat_secondary = Material("vj_hud/secondary.png")
local mat_health = Material("vj_hud/hp.png")
local mat_armor = Material("vj_hud/armor.png")
local mat_knife = Material("vj_hud/knife.png")
local mat_skull = Material("vj_hud/skull.png")
local mat_kd = Material("vj_hud/kd.png")
local mat_run = Material("vj_hud/running.png")
local mat_fps = Material("vj_hud/fps.png")
local mat_ping = Material("vj_hud/ping.png")
local mat_car = Material("vj_hud/car.png")
local mat_boss = Material("vj_hud/boss.png")
local mat_guarding = Material("vj_hud/guarding.png")
local mat_medic = Material("vj_hud/medic.png")
local mat_controller = Material("vj_hud/controller.png")
local mat_following = Material("vj_hud/following.png")

-- Networked Values
timer.Simple(0.1, function()
	if IsValid(LocalPlayer()) then
		LocalPlayer():SetNW2Bool("vj_hud_godmode", false)
		LocalPlayer():SetNW2Int("vj_hud_trhealth", 0)
		LocalPlayer():SetNW2Int("vj_hud_trmaxhealth", 0)
		LocalPlayer():SetNW2String("vj_hud_tr_npc_info", "00") -- IsHugeMonster | Disposition | IsGuard | IsMedic | Controlled | Following Player | The Player its following
	end
end)

-- As function-en mechi abranknere 24 jam ge vazen
local hud_enabled = GetConVarNumber("vj_hud_enabled")
hook.Add("HUDPaint", "vj_hud_runvars", function()
	hud_enabled = GetConVarNumber("vj_hud_enabled")
	hud_unitsystem = GetConVarNumber("vj_hud_metric")
end)

function VJ_ConvertToRealUnit(pos)
    local result;
	if hud_unitsystem == 1 then
		result = math.Round((pos / 16) / 3.281).." M"
	else
		result = math.Round(pos / 16).." FT"
	end
	return result
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Hide HL2 Elements ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local GMOD_HUD = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
	["CHudSuitPower"] = true,
    ["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
}
local GMOD_Crosshair = {
	["CHudCrosshair"] = true
}
hook.Add("HUDShouldDraw", "vj_hud_hidegmod", function(name)
	if GetConVarNumber("vj_hud_disablegmod") == 1 && GMOD_HUD[name] then return false end
	if GetConVarNumber("vj_hud_disablegmodcross") == 1 && GMOD_Crosshair[name] then return false end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Crosshair ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("HUDPaint", "vj_hud_crosshair", function()
	local ply = LocalPlayer()
	if !ply:Alive() or hud_enabled == 0 or GetConVarNumber("vj_hud_ch_enabled") == 0 then return end
	if ply:InVehicle() && GetConVarNumber("vj_hud_ch_invehicle") == 0 then return end
	
	local size = GetConVarNumber("vj_hud_ch_crosssize")
	local garmir = GetConVarNumber("vj_hud_ch_r")
	local ganach = GetConVarNumber("vj_hud_ch_g")
	local gabouyd = GetConVarNumber("vj_hud_ch_b")
	local opacity = GetConVarNumber("vj_hud_ch_opacity")
	local mat = GetConVarNumber("vj_hud_ch_mat")
	
	if mat == 0 then
		surface.SetMaterial(mat_crossh1)
	elseif mat == 1 then
		surface.SetMaterial(mat_crossh2)
	elseif mat == 2 then
		surface.SetMaterial(mat_crossh3)
	elseif mat == 3 then
		surface.SetMaterial(mat_crossh4)
	elseif mat == 4 then
		surface.SetMaterial(mat_crossh5)
	elseif mat == 5 then
		surface.SetMaterial(mat_crossh6)
	elseif mat == 6 then
		surface.SetMaterial(mat_crossh7)
	elseif mat == 7 then
		surface.SetMaterial(mat_crossh8)
	elseif mat == 8 then
		surface.SetMaterial(mat_crossh9)
	end
	surface.SetDrawColor(garmir, ganach, gabouyd, opacity)
	surface.DrawTexturedRect(ScrW() / 2 - size / 2, ScrH() / 2 - size / 2, size, size)
	
	//surface.SetDrawColor(255, 0, 255, opacity)
	//surface.DrawTexturedRect(ply:GetAimVector():ToScreen().x, ply:GetAimVector():ToScreen().y, size, size)
	//surface.DrawCircle(ScrW() / ply:GetAimVector().x, ScrH() / ply:GetAimVector().y, 100, {garmir, ganach, gabouyd, opacity})
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Ammo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("HUDPaint", "vj_hud_ammo", function()
	local ply = LocalPlayer()
	if !ply:Alive() or hud_enabled == 0 or GetConVarNumber("vj_hud_ammo") == 0 then return end
	if ply:InVehicle() && GetConVarNumber("vj_hud_ammo_invehicle") == 0 then return end
	
	local curwep = ply:GetActiveWeapon()
	if (!IsValid(curwep) or ply:GetActiveWeapon() == "Camera") then
		return -- Don't draw the ammo counter
	end
	
	-- Poon abranknere
	draw.RoundedBox(1, ScrW()-195, ScrH()-130, 180, 95, color(0, 0, 0, 150))
	//draw.SimpleText("Weapons - "..table.Count(ply:GetWeapons()),"VJFont_Trebuchet24_Small", ScrW()-340, ScrH()-95, color(255, 255, 255, 150), 0, 0) -- Kani had zenk oones
	local pri_clip = curwep:Clip1() -- Remaining ammunition for the clip
	local pri_extra = ply:GetAmmoCount(curwep:GetPrimaryAmmoType()) -- Remaining primary fire ammunition (Reserve, not counting current clip!)
	local sec_ammo = ply:GetAmmoCount(curwep:GetSecondaryAmmoType()) -- Remaining secondary fire ammunition
	local suit_power = (ply:GetSuitPower() <= 100 and ply:GetSuitPower()) or 100 -- Make sure 100 is the max!
	local flashlight = ply:FlashlightIsOn()
	
	-- Flashlight
	if suit_power < 50 or flashlight == true then
		surface.SetDrawColor(255 - (suit_power * 2.55), suit_power * 2.55, 0, (flashlight and 255) or 150)
		surface.SetMaterial((flashlight and mat_flashlight_on) or mat_flashlight_off)
		surface.DrawTexturedRectRotated(ScrW()-((flashlight and 230) or 235), ScrH()-54, 35, 35, 90)
		//draw.RoundedBox(8, ScrW()-260, ScrH()-75, 60, 40, color(0, (ply:FlashlightIsOn() and 255) or 0, (ply:FlashlightIsOn() and 255) or 0, 50))
		draw.RoundedBox(8, ScrW()-260, ScrH()-75, 60, 40, color(math.Clamp(255 - (suit_power * 2.55), 0, 150), 0, 0, 50 - (suit_power * 0.5)))
		draw.RoundedBox(8, ScrW()-260, ScrH()-75, 60, 40, color(0, 0, 0, 150))
	end
	
	-- Grenade count
	surface.SetMaterial(mat_grenade)
	surface.SetDrawColor(0, 255, 255, 150)
	surface.DrawTexturedRect(ScrW()-95, ScrH()-70, 25, 25)
	draw.SimpleText(ply:GetAmmoCount("grenade"),"VJFont_Trebuchet24_MediumLarge", ScrW()-70, ScrH()-70, color(0, 255, 255, 150), 0, 0)
	
	if curwep:IsWeapon() then
		local wepname = curwep:GetPrintName()
		if string.len(wepname) > 22 then
			wepname = string.sub(curwep:GetPrintName(),1,20).."..."
		end
		draw.SimpleText(wepname,"VJFont_Trebuchet24_Small", ScrW()-185, ScrH()-125, color(225, 255, 255, 150), 0, 0)
	end
	
	local hasammo = true
	local ammo_not_use = false -- Does it use ammo? = true for things like gravity gun or physgun
	local ammo_pri = pri_clip.." / "..pri_extra
	local ammo_pri_c = color(0, 255, 0, 150)
	local ammo_sec = sec_ammo
	local ammo_sec_c = color(0, 255, 255, 150)
	local empty_blink = math.abs(math.sin(CurTime() * 4) * 255)
	local max_ammo = curwep:GetMaxClip1()
	
	if max_ammo == nil or max_ammo == 0 or max_ammo == -1 then max_ammo = false end
	if pri_clip <= 0 && pri_extra <= 0 then hasammo = false end
	
	if max_ammo != false then // If the current weapon has a proper clip size, then continue...
		local perc_left = math.Clamp((pri_clip / max_ammo) * 255, 2, 255) -- Find the percentage of the mag left in respect to the max ammo (proportional) | Clamp at min: 2, max: 255
		if perc_left <= 127.5 then // 127.5  = 50% of 255
			ammo_pri_c = color(255, 40 + perc_left, 0, 255)
		end
	end
		
	if hasammo == true && pri_clip <= 0 then -- Mag is empty but has reserve
		ammo_pri = "--- / "..pri_extra
		ammo_pri_c = color(255, 0, 0, empty_blink)
	end
	if pri_clip == -1 && curwep:GetSecondaryAmmoType() == -1 then -- Uses primary only with no ammo reserve, ex: "weapon_rpg" or "weapon_frag"
		ammo_pri = pri_extra
		ammo_pri_c = color(0, 255, 0, 150)
		ammo_sec = "---"
		ammo_sec_c = color(255, 100, 0, 150)
	end
	if curwep:GetPrimaryAmmoType() == -1 then -- Weapons that use secondary as primary, ex: "weapon_slam"
		ammo_pri = sec_ammo
		ammo_sec = "---"
		ammo_sec_c = color(255, 100, 0, 150)
	end
	if curwep:GetPrimaryAmmoType() == -1 && curwep:GetSecondaryAmmoType() == -1 then -- Doesn't use ammo
		ammo_not_use = true
		ammo_pri = "---"
		ammo_pri_c = color(255, 100, 0, 150)
		ammo_sec = "---"
		ammo_sec_c = color(255, 100, 0, 150)
	elseif hasammo == false then -- Primary empty!
		ammo_pri = "Empty!"
		ammo_pri_c = color(255, 0, 0, empty_blink)
	end
	if curwep:GetSecondaryAmmoType() == -1 then -- Doesn't use secondary ammo
		ammo_sec = "---"
		ammo_sec_c = color(255, 100, 0, 150)
	elseif sec_ammo == 0 then -- Secondary Empty!
		ammo_sec = "Empty!"
		ammo_sec_c = color(255, 0, 0, empty_blink)
	end
	local ammo_pri_len = string.len(ammo_pri)
	local ammo_pri_pos = 110
	if ammo_pri_len > 1 then
		ammo_pri_pos = ammo_pri_pos + (6.5*ammo_pri_len)
	end
	draw.SimpleText(ammo_pri, "VJFont_Trebuchet24_Large", ScrW()-ammo_pri_pos, ScrH()-108, ammo_pri_c, 0, 0)
	surface.SetMaterial(mat_secondary)
	surface.SetDrawColor(ammo_sec_c)
	surface.DrawTexturedRect(ScrW()-190, ScrH()-70, 25, 25)
	draw.SimpleText(ammo_sec, "VJFont_Trebuchet24_MediumLarge", ScrW()-163, ScrH()-70, ammo_sec_c, 0, 0)
	
	-- Reloading bar
	if ammo_not_use == false then
		local model_vm = ply:GetViewModel()
		if ply:GetActiveWeapon().CW_VM then model_vm = ply:GetActiveWeapon().CW_VM end -- For CW 2.0 weapons
		if (model_vm:GetSequenceActivity(model_vm:GetSequence()) == ACT_VM_RELOAD or string.match(model_vm:GetSequenceName(model_vm:GetSequence()), "reload") != nil) then
			local anim_perc = math.ceil(model_vm:GetCycle() * 100) -- Get the percentage of how long it will take until it finished reloading
			local anim_dur = model_vm:SequenceDuration() - (model_vm:SequenceDuration() * model_vm:GetCycle()) -- Get the number of seconds until it finishes reloading
			anim_dur = string.format("%.1f", math.Round(anim_dur, 1)) -- Round to 1 decimal point and format it to keep a 0 (if applicable)
			if anim_perc < 100 then
				draw.RoundedBox(8, ScrW()-195, ScrH()-160, 180, 25, color(0, 255, 255, 40))
				draw.RoundedBox(8, ScrW()-195, ScrH()-160, math.Clamp(anim_perc, 0, 100)*1.8, 25, color(0, 255, 255, 160))
				draw.RoundedBox(8, ScrW()-195, ScrH()-160, 180, 25, color(0, 0, 0, 150))
				draw.SimpleText(anim_dur.."s ("..anim_perc.."%)", "VJFont_Trebuchet24_SmallMedium", ScrW()-137, ScrH()-156, color(225, 255, 255, 150), 0, 0)
			end
		end
	end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Health ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local lerp_hp = 0
local lerp_armor = 0

hook.Add("HUDPaint", "vj_hud_health", function()
	local ply = LocalPlayer()
	if hud_enabled == 0 or GetConVarNumber("vj_hud_health") == 0 then return end
	if !ply:Alive() then -- Meradz tsootsage
		local deadhealth_blinka = math.abs(math.sin(CurTime() * 6) * 200)
		local deadhealth_blinkb = math.abs(math.sin(CurTime() * 6) * 255)
		draw.RoundedBox(8, 70, ScrH()-80, 142, 30, color(150, 0, 0, deadhealth_blinka))
		draw.SimpleText("#vjhud.user.dead", "VJFont_Trebuchet24_Medium", 85, ScrH()-77, color(255, 255, 0, deadhealth_blinkb), 0, 0)
	else
		draw.RoundedBox(1, 15, ScrH()-130, 245, 95, color(0, 0, 0, 150))
		local hp_r = 0
		local hp_g = 255
		local hp_b = 0
		local hp_blink = math.abs(math.sin(CurTime() * 2) * 255)
		lerp_hp = Lerp(5*FrameTime(), lerp_hp, ply:Health())
		lerp_armor = Lerp(5*FrameTime(), lerp_armor, ply:Armor())
		net.Start("vj_hud_godmode")
		net.SendToServer()
		if ply:GetNW2Bool("vj_hud_godmode") == true then
			hp_r = 255
			hp_g = 102
			hp_b = 255
			draw.RoundedBox(8, 15, ScrH()-160, 155, 25, color(0, 0, 0, 150))
			draw.SimpleText("#vjhud.god.mode.enabled", "VJFont_Trebuchet24_SmallMedium", 25, ScrH()-156, color(hp_r, hp_g, hp_b, 255), 0, 0)
		else
			local warning = 0
			if lerp_hp <= 35 then
				hp_blink = math.abs(math.sin(CurTime() * 4) * 255)
				hp_r = 255
				hp_g = 0 + (5 * ply:Health())
				warning = 1
			end
			if lerp_hp <= 20 then -- Low Health Warning
				hp_blink = math.abs(math.sin(CurTime() * 6) * 255)
				warning = 2
			end
			if warning == 1 then
				draw.RoundedBox(8, 15, ScrH()-160, 180, 25, color(150, 0, 0, math.abs(math.sin(CurTime() * 4) * 200)))
				draw.SimpleText("#vjhud.low.health", "VJFont_Trebuchet24_SmallMedium", 25, ScrH()-156, color(255, 153, 0, math.abs(math.sin(CurTime() * 4) * 255)), 0, 0)
			elseif warning == 2 then
				draw.RoundedBox(8, 15, ScrH()-160, 220, 25, color(150, 0, 0, math.abs(math.sin(CurTime() * 6) * 200)))
				draw.SimpleText("#vjhud.death.imminent", "VJFont_Trebuchet24_SmallMedium", 25, ScrH()-156, color(255, 153, 0, math.abs(math.sin(CurTime() * 6) * 255)), 0, 0)
			end
		end
		
		-- Aroghchoutyoun
		surface.SetMaterial(mat_health)
		surface.SetDrawColor(color(hp_r, hp_g, hp_b, hp_blink))
		surface.DrawTexturedRect(22, ScrH()-127, 40, 45)
		draw.SimpleText(string.format("%.0f", lerp_hp).."%", "VJFont_Trebuchet24_Medium", 70, ScrH()-128, color(hp_r, hp_g, hp_b, 255), 0, 0)
		draw.RoundedBox(0, 70, ScrH()-105, 180, 15, color(hp_r, hp_g, hp_b, 40))
		draw.RoundedBox(0, 70, ScrH()-105, math.Clamp(lerp_hp,0,100)*1.8, 15, color(hp_r, hp_g, hp_b, 255))
		surface.SetDrawColor(hp_r, hp_g, hp_b, 255)
		surface.DrawOutlinedRect(70, ScrH()-105, 180, 15)
		
		-- Bashbanelik
		surface.SetMaterial(mat_armor)
		surface.SetDrawColor(color(0, 255, 255, 150))
		surface.DrawTexturedRect(22, ScrH()-80, 40, 40)
		draw.SimpleText(string.format("%.0f", lerp_armor).."%", "VJFont_Trebuchet24_Medium", 70, ScrH()-83, color(0, 255, 255, 160), 0, 0)
		draw.RoundedBox(0, 70, ScrH()-60, 180, 15, color(0, 255, 255, 40))
		draw.RoundedBox(0, 70, ScrH()-60, math.Clamp(lerp_armor, 0, 100)*1.8, 15, color(0, 255, 255, 160))
		surface.SetDrawColor(0, 150, 150, 255)
		surface.DrawOutlinedRect(70, ScrH()-60, 180, 15)
		
		-- Suit Auxiliary power
		local suit_power = (ply:GetSuitPower() <= 100 and ply:GetSuitPower()) or 100 -- Make sure 100 is the max!
		if suit_power < 100 then
			local suit_r = 255 - (suit_power * 2.55)
			local suit_g = suit_power * 2.55
			draw.RoundedBox(0, 100, ScrH()-89, 150, 8, color(suit_r, suit_g, 0, 40))
			draw.RoundedBox(0, 100, ScrH()-89, math.Clamp(suit_power, 0, 100)*1.5, 8, color(suit_r, suit_g, 0, 160))
			surface.SetDrawColor(suit_r, suit_g, 0, 255)
			surface.DrawOutlinedRect(100, ScrH()-89, 150, 8)
			draw.SimpleText("#vjhud.suit", "VJFont_Trebuchet24_Tiny", 70, ScrH()-89, color(suit_r, suit_g, 0, 255), 0, 0)
		end
	end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Player Information ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local fps = 0
local next_fps = 0

hook.Add("HUDPaint", "vj_hud_localplayerinfo", function()
	local ply = LocalPlayer()
	if !ply:Alive() or hud_enabled == 0 or GetConVarNumber("vj_hud_playerinfo") == 0 then return end
	draw.RoundedBox(1, 260, ScrH()-130, 200, 95, color(0, 0, 0, 150))
	//draw.RoundedBox( 8, ScrW()*0.01, ScrH()*0.01, 128, 46, color( 125, 125, 125, 125 ) )
	//draw.RoundedBox( 8, ScrW()-1665, ScrH()-235, 185, 150, color( 0, 0, 0, 150 ) )
	//draw.RoundedBox( 8, ScrW()-1665, ScrH()-235, 185, 40, color( 0, 0, 0, 100 ) )
	/*if ply:IsAdmin() then
	draw.SimpleText("#vjhud.admin.yes","VJFont_Trebuchet24_Tiny", 160, ScrH()-137, color(255, 255, 255, 150), 0, 0) else
	draw.SimpleText("#vjhud.admin.no","VJFont_Trebuchet24_Tiny", 160, ScrH()-137, color(255, 255, 255, 150), 0, 0) end
	if GetConVarNumber("sv_Cheats") == 1 then
	draw.SimpleText("#vjhud.cheats.on","VJFont_Trebuchet24_Tiny", 160, ScrH()-124, color(255, 255, 255, 150), 0, 0) else
	draw.SimpleText("#vjhud.cheats.off","VJFont_Trebuchet24_Tiny", 160, ScrH()-124, color(255, 255, 255, 150), 0, 0) end
	if GetConVarNumber("ai_disabled") == 0 then
	draw.SimpleText("#vjhud.npc.ai.on","VJFont_Trebuchet24_Tiny", 160, ScrH()-111, color(255, 255, 255, 150), 0, 0) else
	draw.SimpleText("#vjhud.npc.ai.off","VJFont_Trebuchet24_Tiny", 160, ScrH()-111, color(255, 255, 255, 150), 0, 0) end
	if GetConVarNumber("ai_ignoreplayers") == 1 then
	draw.SimpleText("IgnorePly: On","VJFont_Trebuchet24_Tiny", 160, ScrH()-98, color(255, 255, 255, 150), 0, 0) else
	draw.SimpleText("IgnorePly: Off","VJFont_Trebuchet24_Tiny", 160, ScrH()-98, color(255, 255, 255, 150), 0, 0) end*/
	/*if GetConVarNumber("ai_serverragdolls") == 1 then
	draw.SimpleText("Cropses: On","VJFont_Trebuchet24_Tiny", 160, ScrH()-90, color(255, 255, 255, 150), 0, 0) else
	draw.SimpleText("Cropses: Off","VJFont_Trebuchet24_Tiny", 160, ScrH()-90, color(255, 255, 255, 150), 0, 0) end*/
	//draw.SimpleText("Team: "..team.GetName( ply:Team() ),"VJFont_Trebuchet24_Tiny", 20, 842, color(255, 255, 255, 150), 0, 0)
	//draw.SimpleText("Map: "..game.GetMap(), "VJFont_Trebuchet24_Tiny", 30, ScrH()-143, color(255, 255, 255, 150),0,0)
	//draw.SimpleText("Gamemode: "..gmod.GetGamemode().Name, "VJFont_Trebuchet24_Tiny", 30, ScrH()-130, color(255, 255, 255, 150),0,0)
	
	//draw.SimpleText(os.date("%a,%I:%M:%S %p"), "VJFont_Trebuchet24_SmallMedium", 330, ScrH()-125, color(0, 255, 255, 150),0,0)
	//draw.SimpleText(os.date("%m/%d/20%y"), "VJFont_Trebuchet24_SmallMedium", 350, ScrH()-110, color(0, 255, 255, 150),0,0)
	
	-- Number of kills
	surface.SetMaterial(mat_knife)
	surface.SetDrawColor(color(255, 255, 255, 150))
	surface.DrawTexturedRect(260, ScrH()-125, 28, 28)
	draw.SimpleText(ply:Frags(), "VJFont_Trebuchet24_Medium", 293, ScrH()-125, color(255, 255, 255, 150), 100, 100)
	
	-- Number of deaths
	surface.SetMaterial(mat_skull)
	surface.SetDrawColor(color(255, 255, 255, 150))
	surface.DrawTexturedRect(260, ScrH()-95, 28, 28)
	draw.SimpleText(ply:Deaths(), "VJFont_Trebuchet24_Medium", 293, ScrH()-93, color(255, 255, 255, 150), 100, 100)
	
	-- Kill / death ratio
	local kd;
	if ply:Frags() == 0 && ply:Deaths() == 0 then
		kd = 0
	elseif ply:Deaths() == 0 then
		kd = ply:Frags()
	else
		kd = math.Round(ply:Frags() / ply:Deaths(), 2)
	end
	if kd < 0 then kd = 0 end
	if kd > 10 then kd = math.Round(kd, 1) end
	surface.SetMaterial(mat_kd)
	surface.SetDrawColor(color(255, 255, 255, 150))
	surface.DrawTexturedRect(260, ScrH()-65, 28, 28)
	draw.SimpleText(kd, "VJFont_Trebuchet24_Medium", 293, ScrH()-63, color(255, 255, 255, 150), 100, 100)
	
	-- Movement speed
    local speed;
	if hud_unitsystem == 1 then
		speed = math.Round((ply:GetVelocity():Length() * 0.04263382283) * 1.6093).."KPH"
	else
		speed = math.Round(ply:GetVelocity():Length() * 0.04263382283).."mph"
	end
	surface.SetMaterial(mat_run)
	surface.SetDrawColor(color(255, 255, 255, 150))
	surface.DrawTexturedRect(340, ScrH()-125, 28, 28)
	draw.SimpleText(speed, "VJFont_Trebuchet24_Medium", 373, ScrH()-125, color(255, 255, 255, 150), 100, 100)
	
	-- FPS
	if CurTime() > next_fps then
		fps = tostring(math.ceil(1 / FrameTime()))
		next_fps = CurTime() + 0.5
	end
	surface.SetMaterial(mat_fps)
	surface.SetDrawColor(color(255, 255, 255, 150))
	surface.DrawTexturedRect(340, ScrH()-95, 28, 28)
	draw.SimpleText(fps.."fps", "VJFont_Trebuchet24_Medium", 373, ScrH()-93, color(255, 255, 255, 150),0,0)
	
	-- Ping
	local ping = ply:Ping()
	local ping_calc = 255 - ping -- Make it more red the higher the ping is!
	surface.SetMaterial(mat_ping)
	surface.SetDrawColor(color(255, ping_calc, ping_calc, 150))
	surface.DrawTexturedRect(340, ScrH()-65, 28, 28)
	draw.SimpleText(ping.."ms", "VJFont_Trebuchet24_Medium", 373, ScrH()-63, color(255, ping_calc, ping_calc, 150),0,0)
	
	-- Vehicle speed
	if IsValid(ply:GetVehicle()) then
		draw.RoundedBox(1, 320, ScrH()-160, 140, 30, color(0, 0, 0, 150))
		local speedcalc = (IsValid(ply:GetVehicle():GetParent()) and ply:GetVehicle():GetParent():GetVelocity():Length()) or ply:GetVehicle():GetVelocity():Length()
		if hud_unitsystem == 1 then
			speedcalc = math.Round((speedcalc * 0.04263382283) * 1.6093).."kph"
		else
			speedcalc = math.Round(speedcalc * 0.04263382283).."mph"
		end
		surface.SetMaterial(mat_car)
		surface.SetDrawColor(color(255, 255, 255, 150))
		surface.DrawTexturedRect(320, ScrH()-170, 50, 50)
		draw.SimpleText(speedcalc, "VJFont_Trebuchet24_Medium", 373, ScrH()-155, color(255, 255, 255, 150), 100, 100)
	end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Compass ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("HUDPaint", "vj_hud_compass", function()
	local ply = LocalPlayer()
	if !ply:Alive() or hud_enabled == 0 or GetConVarNumber("vj_hud_compass") == 0 then return end
	draw.RoundedBox(1, ScrW() / 2.015, 10, 60, 60, color(0, 0, 0, 150))
	local ang = ply:GetAngles().y
	local comp_dir = "Unknown!"
	if ang >= -18 and ang <= 18 then
		comp_dir = "N"
	elseif ang >= 162 and ang < 862 then
		comp_dir = "S"
	elseif ang <= -162 and ang > -862 then
		comp_dir = "S"
	elseif ang == 180 or ang == -862 then
		comp_dir = "S"
	elseif ang >= 72 and ang <= 108 then
		comp_dir = "W"
	elseif ang <= -72 and ang >= -108 then
		comp_dir = "E"
	elseif ang > 18 and ang < 72 then
		comp_dir = "NW"
	elseif ang > 108 and ang < 162 then
		comp_dir = "SW"
	elseif ang < -18 and ang > -72 then
		comp_dir = "NE"
	elseif ang < -108 and ang > -162 then
		comp_dir = "SE"
	end
	draw.SimpleText(comp_dir, "VJFont_Trebuchet24_Large", ScrW() / 1.955, 26, color(0, 255, 255, 255), 1, 1)
	local trace = util.TraceLine(util.GetPlayerTrace(ply))
    local distrl = VJ_ConvertToRealUnit(ply:GetPos():Distance(trace.HitPos))
	local distrllen = string.len(tostring(distrl))
  	local move_ft = 0
	if distrllen > 4 then
		move_ft = move_ft - (0.007*(distrllen-4))
	end
	draw.SimpleText(distrl, "VJFont_Trebuchet24_Small", ScrW() / (1.985 - move_ft), 40, color(255, 255, 255, 200), 0, 0)
	local dist = math.Round(ply:GetPos():Distance(trace.HitPos),2)
	local distlen = string.len(tostring(dist))
	if distlen >= 7 then
		dist = math.Round(ply:GetPos():Distance(trace.HitPos))
		distlen = string.len(tostring(dist))
	end
  	local move_wu = 0
	if distlen > 1 then
		move_wu = move_wu - (0.007*(distlen-1))
	end
	draw.SimpleText(dist.." WU", "VJFont_Trebuchet24_Tiny", ScrW()/(1.975-move_wu), 55, color(0, 255, 255, 255), 0, 0)
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Trace Information ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local lerp_trace_hp = 0
local lerp_trace_hp_entid = 0

hook.Add("HUDPaint", "vj_hud_traceinfo", function()
	local ply = LocalPlayer()
	if !ply:Alive() or hud_enabled == 0 or GetConVarNumber("vj_hud_trace") == 0 then return end
	local trace = util.TraceLine(util.GetPlayerTrace(ply))
	if IsValid(trace.Entity) then
		local ent = trace.Entity
		if !ent:IsNPC() && !ent:IsPlayer() && GetConVarNumber("vj_hud_trace_limited") == 1 then return end -- Yete limited option terver e, mi sharnager
		-- Don't trace the vehicle that the player is currently in
		if IsValid(ply:GetVehicle()) then
			if ent == ply:GetVehicle() then return end -- Yete oton trace-in abrankne, mi sharnager
			if IsValid(ply:GetVehicle():GetParent()) && ent == ply:GetVehicle():GetParent() then return end -- Yete otonyin dznokhke trace-in abrankne, mi sharnager
		end
		local pos = ent:LocalToWorld(ent:OBBMaxs()):ToScreen()
		if (pos.visible) then
			local distrl = VJ_ConvertToRealUnit(ply:GetPos():Distance(trace.HitPos))
			local dist = math.Round(ply:GetPos():Distance(trace.HitPos),2)
			net.Start("vj_hud_ent_info")
			net.WriteEntity(ent)
			net.SendToServer()
			draw.SimpleText(distrl.."("..dist.." WU)", "VJFont_Trebuchet24_SmallMedium", pos.x, pos.y - 26, color(0, 255, 255, 255), 0, 0)
			draw.SimpleText(language.GetPhrase(ent:GetClass()), "VJFont_Trebuchet24_Medium", pos.x, pos.y - 12, color(255, 255, 255, 255), 0, 0)
			draw.SimpleText(tostring(ent), "VJFont_Trebuchet24_Small", pos.x, pos.y + 10, color(255, 255, 255, 200), 0, 0)
			
			if ent:IsNPC() then -- NPC-ineroon hamar minag:
				local npc_info = ply:GetNW2String("vj_hud_tr_npc_info")
				
				-- Boss Icon
				if string.sub(npc_info, 1, 1) == "1" then
					surface.SetMaterial(mat_boss)
					surface.SetDrawColor(color(255, 0, 0, 255))
					surface.DrawTexturedRect(pos.x - 30, pos.y + 27, 26, 26)
				end
				
				local npc_spacing = 0 -- How many spaces (left-right) should it move
				-- Disposition
				local npc_disp = tonumber(string.sub(npc_info, 2, 2))
				local npc_disp_t = "Unknown"
				local npc_disp_color = color(255, 255, 255, 255)
				if npc_disp == 1 then
					npc_disp_color = color(255, 0, 0, 255)
					npc_disp_t = "Hostile"
				elseif npc_disp == 2 then
					npc_disp_color = color(255, 150, 0, 255)
					npc_disp_t = "Frightened"
				elseif npc_disp == 3 then
					npc_disp_color = color(0, 255, 0, 255)
					npc_disp_t = "Friendly"
				elseif npc_disp == 4 then
					npc_disp_color = color(255, 150, 0, 255)
					npc_disp_t = "Neutral"
				end
				npc_spacing = draw.SimpleText(npc_disp_t, "VJFont_Trebuchet24_SmallMedium", pos.x, pos.y + 50, npc_disp_color, 0, 0)
				npc_spacing = npc_spacing + 10
				
				-- Guarding
				if string.sub(npc_info, 3, 3) == "1" then
					surface.SetMaterial(mat_guarding)
					surface.SetDrawColor(color(50, 50, 50, 150))
					surface.DrawTexturedRect(pos.x + npc_spacing - 2, pos.y + 55 - 2, 26, 26)
					surface.SetDrawColor(color(102, 178, 255, 255))
					surface.DrawTexturedRect(pos.x + npc_spacing, pos.y + 55, 22, 22)
					npc_spacing = npc_spacing + 32
				end
				
				-- Medic
				if string.sub(npc_info, 4, 4) == "1" then
					surface.SetMaterial(mat_medic)
					surface.SetDrawColor(color(50, 50, 50, 150))
					surface.DrawTexturedRect(pos.x + npc_spacing - 2, pos.y + 55 - 2, 26, 26)
					surface.SetDrawColor(color(200, 255, 153, 255))
					surface.DrawTexturedRect(pos.x + npc_spacing, pos.y + 55, 22, 22)
					npc_spacing = npc_spacing + 32
				end
				
				-- Controlled
				if string.sub(npc_info, 5, 5) == "1" then
					surface.SetMaterial(mat_controller)
					surface.SetDrawColor(color(50, 50, 50, 150))
					surface.DrawTexturedRect(pos.x + npc_spacing - 2, pos.y + 55 - 2, 26, 26)
					surface.SetDrawColor(color(255, 213, 0, 255))
					surface.DrawTexturedRect(pos.x + npc_spacing, pos.y + 55, 22, 22)
					npc_spacing = npc_spacing + 32
				end
				
				-- Following Player
				if string.sub(npc_info, 6, 6) == "1" then
					surface.SetMaterial(mat_following)
					surface.SetDrawColor(color(50, 50, 50, 150))
					surface.DrawTexturedRect(pos.x - 2, pos.y + 68, 34, 34)
					surface.SetDrawColor(color(221, 160, 221, 255))
					surface.DrawTexturedRect(pos.x, pos.y + 70, 30, 30)
					draw.SimpleText(string.sub(npc_info, 7, -1), "VJFont_Trebuchet24_SmallMedium", pos.x + 32, pos.y + 75, color(221, 160, 221, 255), 0, 0)
				end
			end
			
			local ent_hp = ply:GetNW2Int("vj_hud_trhealth")
			local ent_hpm = ply:GetNW2Int("vj_hud_trmaxhealth")
			if !ent:IsWorld() && !ent:IsVehicle() && ent:Health() != 0 then
				if lerp_trace_hp_entid != ent:EntIndex() then lerp_trace_hp = ent_hpm end
				lerp_trace_hp_entid = ent:EntIndex()
				lerp_trace_hp = Lerp(8*FrameTime(),lerp_trace_hp,ent_hp)
				local hp_box = (190*math.Clamp(lerp_trace_hp,0,ent_hpm))/ent_hpm
				local hp_num = (surface.GetTextSize(ent_hp.."/"..ent_hpm))/2
				local hp_numformat = "/"..ent_hpm
				
				if ent:IsPlayer() then
					hp_box = math.Clamp(lerp_trace_hp,0,100)*1.9
					hp_num = (surface.GetTextSize(ent_hp.."/100"))/2
					hp_numformat = "%"
				end

				draw.RoundedBox(1,pos.x,pos.y+30,190,20,color(0,255,255,50))
				surface.SetDrawColor(0,255,255,150)
				surface.DrawOutlinedRect(pos.x,pos.y+30,190,20)
				draw.RoundedBox(1,pos.x,pos.y+30,hp_box,20,color(0,255,255,150))
				draw.SimpleText(string.format("%.0f", lerp_trace_hp)..hp_numformat, "VJFont_Trebuchet24_Small",(pos.x+105)-hp_num,pos.y+31,color(255, 255, 255, 255))
			end
		end
	end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Proximity Scanner ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local AbranknerVorKedne = {
	-- Barz Abrankner --
	gmod_button={Anoon = "Button", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(255, 255, 255, 150)},
	edit_sky={Anoon = "Sky Editor", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(255, 255, 255, 150)},
	edit_sun={Anoon = "Sun Editor", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(255, 255, 255, 150)},
	edit_fog={Anoon = "Fog Editor", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(255, 255, 255, 150)},
	
	-- Aroghchoutyoun yev Bashbanelik --
	item_healthkit={Anoon = "Health Kit", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(0, 255, 0, 150)},
	item_healthvial={Anoon = "Health Vial", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(0, 255, 0, 150)},
	item_battery={Anoon = "Suit Battery", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(0, 255, 0, 150)},
	item_suitcharger={Anoon = "Suit Charger", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(0, 255, 0, 150)},
	item_healthcharger={Anoon = "Health Charger", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(0, 255, 0, 150)},
	item_suit={Anoon = "HEV Suit", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(0, 255, 0, 150)},
	
	-- Panpousht --
	item_ammo_ar2={Anoon = "AR2 Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_ammo_ar2_large={Anoon = "Large AR2 Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_ammo_pistol={Anoon = "Pistol Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_ammo_pistol_large={Anoon = "Large Pistol Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_box_buckshot={Anoon = "Shotgun Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_ammo_357={Anoon = ".357 Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_ammo_357_large={Anoon = "Large .357 Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_ammo_smg1={Anoon = "SMG Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_ammo_smg1_large={Anoon = "Large SMG Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_ammo_ar2_altfire={Anoon = "Combine Ball Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_ammo_crossbow={Anoon = "Crossbow Bolts Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_ammo_smg1_grenade={Anoon = "SMG Grenade Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	item_rpg_round={Anoon = "RPG Ammo", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 300, DariKouyn = color(0, 255, 255, 150)},
	
	-- Vdankavor --
	combine_mine={Anoon = "Mine!", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1)},
	prop_combine_ball={Anoon = "Combine Ball!", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1)},
	npc_rollermine={Anoon = "RollerMine!", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1)},
	grenade_helicopter={Anoon = "Bomb!", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1)},
	npc_grenade_frag={Anoon = "Grenade!", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1)},
	obj_vj_grenade={Anoon = "Grenade!", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1)},
	fas2_thrown_m67={Anoon = "Grenade!", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1)},
	doom3_grenade={Anoon = "Grenade!", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1)},
	cw_grenade_thrown={Anoon = "Grenade!", Negar = "negar/negar", DariDesag = "VJFont_Trebuchet24_Medium", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1)},
}

hook.Add("HUDPaint", "vj_hud_proximityscanner", function()
	local ply = LocalPlayer()
	if !ply:Alive() or hud_enabled == 0 or GetConVarNumber("vj_hud_scanner") == 0 then return end
	local kouyne_pes = math.abs(math.sin(CurTime() * 5) * 255)
	for _, ent in pairs(ents.FindInSphere(ply:GetPos(), 320)) do
		local v = AbranknerVorKedne[ent:GetClass()]
		if v then
			local pos = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
			if math.Round(ply:GetPos():Distance(ent:GetPos())) < v.Heravorutyoun then
				local kouyne_poon_pare = v.DariKouyn
				if v.DariKouyn.a == -1 then kouyne_poon_pare = color(v.DariKouyn.r, v.DariKouyn.g, v.DariKouyn.b, kouyne_pes) end
				draw.SimpleText(v.Anoon, v.DariDesag,pos.x + 1, pos.y + 1, kouyne_poon_pare, 0, 0)
				draw.SimpleText(VJ_ConvertToRealUnit(ply:GetPos():Distance(ent:GetPos())), "HudHintTextLarge", pos.x + 30, pos.y + 25, color(255, 255, 255, 255), 0, 0)
				
				-- Hin abrank (Goghme negar ge tsetsen e)
				//surface.SetTexture(surface.GetTextureID(v.Negar))
				//surface.SetDrawColor(color(255, 255, 255, 255))
				//surface.DrawTexturedRect(pos.x-(20), pos.y-(20), 25, 25)
			end
		end
	end
end)