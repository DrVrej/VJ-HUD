/*--------------------------------------------------
	*** Copyright (c) 2012-2025 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
VJ.AddPlugin("VJ HUD", "HUD")

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
if SERVER then
	util.AddNetworkString("vj_hud_ent_info")
	net.Receive("vj_hud_ent_info", function(len, ply)
		local ent = net.ReadEntity()
		if IsValid(ply) && IsValid(ent) then
			ply:SetNW2Int("vj_hud_trhealth", ent:Health())
			ply:SetNW2Int("vj_hud_trmaxhealth", ent:GetMaxHealth())
			if ent:IsNPC() then
				local npc_hm = (ent.VJ_ID_Boss == true and "1") or "0"
				local npc_guard = (ent.IsGuard == true and "1") or "0"
				local npc_medic = (ent.IsMedic == true and "1") or "0"
				local npc_controlled = (ent.VJ_IsBeingControlled == true and "1") or "0"
				local npc_following = "0"
				local npc_followingn = "Unknown"
				local npc_iscontroller = ((ply.VJ_IsControllingNPC and IsValid(ply.VJ_TheControllerEntity.VJCE_NPC) and ply.VJ_TheControllerEntity.VJCE_NPC == ent) and "1") or "0"
				if ent.IsFollowing then
					npc_following = "1"
					local followEnt = ent.FollowData.Target
					if followEnt:IsPlayer() then
						npc_followingn = followEnt:Nick()
					elseif followEnt:IsNPC() then
						npc_followingn = list.Get("NPC")[followEnt:GetClass()].Name
					else
						npc_followingn = followEnt:GetClass()
					end
				end
				if npc_followingn == ply:Nick() then npc_followingn = "You" end
				ply:SetNW2String("vj_hud_tr_npc_info", npc_hm..ent:Disposition(ply)..npc_guard..npc_medic..npc_controlled..npc_iscontroller..npc_following..npc_followingn)
			end
		end
	end)
end

if (!CLIENT) then return end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ ConVars ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Main Components
VJ.AddClientConVar("vj_hud_enabled", 1) -- Enable VJ HUD
VJ.AddClientConVar("vj_hud_health", 1) -- Enable health and suit
VJ.AddClientConVar("vj_hud_ammo", 1) -- Enable ammo
VJ.AddClientConVar("vj_hud_compass", 1) -- Enable compass
VJ.AddClientConVar("vj_hud_playerinfo", 1) -- Enable local player information
VJ.AddClientConVar("vj_hud_trace", 1) -- Enable trace information
VJ.AddClientConVar("vj_hud_trace_limited", 0) -- Should it only display the trace information when looking at a player or an NPC?
VJ.AddClientConVar("vj_hud_scanner", 1) -- Enable proximity scanner

-- Conversion
VJ.AddClientConVar("vj_hud_metric", 0) -- Use Metric instead of Imperial

-- Crosshair
VJ.AddClientConVar("vj_hud_ch_enabled", 1) -- Enable VJ Crosshair
VJ.AddClientConVar("vj_hud_ch_invehicle", 1) -- Should the Crosshair be enabled in the vehicle?
VJ.AddClientConVar("vj_hud_ch_size", 50) -- Crosshair Size
VJ.AddClientConVar("vj_hud_ch_opacity", 255) -- Opacity of the Crosshair
VJ.AddClientConVar("vj_hud_ch_r", 0) -- Crosshair Color - Red
VJ.AddClientConVar("vj_hud_ch_g", 255) -- Crosshair Color - Green
VJ.AddClientConVar("vj_hud_ch_b", 0) -- Crosshair Color - Blue
VJ.AddClientConVar("vj_hud_ch_mat", 0) -- The Crosshair Material

-- Garry's Mod HUD
VJ.AddClientConVar("vj_hud_disablegmod", 1) -- Disable Garry's Mod HUD
VJ.AddClientConVar("vj_hud_disablegmodcross", 1) -- Disable Garry's Mod Crosshair

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Menu ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("PopulateToolMenu", "VJ_ADDTOMENU_HUD_SETTINGS", function()
	spawnmenu.AddToolMenuOption("DrVrej", "HUDs", "VJ HUD Settings", "Settings", "", "", function(panel)
		panel:AddControl("Button", {Text = "#vjbase.menu.general.reset.everything", Command = "vj_hud_enabled 1\n vj_hud_disablegmod 1\n vj_hud_health 1\n vj_hud_ammo 1\n vj_hud_playerinfo 1\n vj_hud_trace 1\n vj_hud_compass 1\n vj_hud_scanner 1\n vj_hud_metric 0\n vj_hud_disablegmodcross 1\n vj_hud_ch_enabled 1\n vj_hud_ch_size 50\n vj_hud_ch_opacity 255\n vj_hud_ch_r 0\n vj_hud_ch_g 255\n vj_hud_ch_b 0\n vj_hud_ch_mat 0\n vj_hud_ch_invehicle 1\n vj_hud_trace_limited 0"})
		panel:Help("Garry's Mod HUD:")
		panel:CheckBox("Disable Garry's Mod HUD", "vj_hud_disablegmod")
		panel:CheckBox("Disable Garry's Mod Crosshair", "vj_hud_disablegmodcross")
		
		panel:Help("HUD:")
		panel:CheckBox("Enable VJ HUD", "vj_hud_enabled")
		panel:CheckBox("Enable Health and Suit", "vj_hud_health")
		panel:CheckBox("Enable Ammunition Counter", "vj_hud_ammo")
		panel:CheckBox("Enable Local Player Information", "vj_hud_playerinfo")
		panel:CheckBox("Enable Compass", "vj_hud_compass")
		panel:CheckBox("Enable Trace Information", "vj_hud_trace")
		panel:CheckBox("Enable Proximity Scanner", "vj_hud_scanner")
		panel:CheckBox("Limited Trace Information", "vj_hud_trace_limited")
		panel:ControlHelp("Will only display for NPCs & Players")
		panel:CheckBox("Use Metric instead of Imperial", "vj_hud_metric")
		
		panel:Help("Crosshair:")
		panel:CheckBox("Enable Crosshair", "vj_hud_ch_enabled")
		panel:CheckBox("Enable Crosshair While in Vehicle", "vj_hud_ch_invehicle")
		local vj_crossoption = {Options = {}, CVars = {}, Label = "Crosshair Material:", MenuButton = "0"}
		vj_crossoption.Options["Arrow (Two, Default)"] = {
			vj_hud_ch_mat = "0",
		}
		vj_crossoption.Options["Dot (Five, Small)"] = {
			vj_hud_ch_mat = "1",
		}
		vj_crossoption.Options["Dot"] = {
			vj_hud_ch_mat = "2",
		}
		vj_crossoption.Options["Dot (Five, Sniper)"] = {
			vj_hud_ch_mat = "3",
		}
		vj_crossoption.Options["Circle (Dashed)"] = {
			vj_hud_ch_mat = "4",
		}
		vj_crossoption.Options["Dot (Four)"] = {
			vj_hud_ch_mat = "5",
		}
		vj_crossoption.Options["Circle"] = {
			vj_hud_ch_mat = "6",
		}
		vj_crossoption.Options["Line (Four, Angled)"] = {
			vj_hud_ch_mat = "7",
		}
		vj_crossoption.Options["Dot (Five, Large)"] = {
			vj_hud_ch_mat = "8",
		}
		panel:AddControl("ComboBox", vj_crossoption)
		local colorPicker = vgui.Create("CtrlColor", panel) -- Color Picker
			colorPicker.Mixer:SetAlphaBar(false)
			colorPicker:SetLabel("Crosshair Color:")
			colorPicker:SetConVarR("vj_hud_ch_r")
			colorPicker:SetConVarG("vj_hud_ch_g")
			colorPicker:SetConVarB("vj_hud_ch_b")
		panel:AddItem(colorPicker)
		panel:NumSlider("Crosshair Size", "vj_hud_ch_size", 0, 1000, 0)
		panel:NumSlider("Crosshair Opacity", "vj_hud_ch_opacity", 0, 255, 0)
	end)
end)

local math_round = math.Round
local math_clamp = math.Clamp
local math_abs = math.abs
local math_sin = math.sin
local math_ceil = math.ceil

local usingMetric = 0

local defaultHUD_Elements = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
	["CHudSuitPower"] = true,
    ["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
}
local defaultCH_Elements = {
	["CHudCrosshair"] = true
}

-- Color Values
local color = Color
local color_white = color(255, 255, 255, 255)
local color_white_muted = color(255, 255, 255, 150)
local color_red = color(255, 0, 0, 255)
local color_orange = color(255, 150, 0, 255)
local color_orange_muted = color(255, 100, 0, 150)
local color_green = color(0, 255, 0, 255)
local color_green_muted = color(0, 255, 0, 150)
local color_cyan = color(0, 255, 255, 255)
local color_cyan_muted = color(0, 255, 255, 150)
local color_cyan_under = color(0, 255, 255, 40)
local color_box = color(0, 0, 0, 150)

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
local mat_ammoBox = Material("vj_hud/ammobox.png")
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
local mat_info = Material("vj_hud/info.png")

-- ConVars
local cv_hud_disablegmod, cv_hud_disablegmodcross, cv_hud_enabled, cv_hud_unitsystem, cv_hud_health, cv_hud_ammo, cv_hud_compass, cv_hud_playerinfo, cv_hud_trace, cv_hud_trace_limited, cv_hud_scanner, cv_ch_enabled, cv_ch_invehicle, cv_ch_crosssize, cv_ch_opacity, cv_ch_r, cv_ch_g, cv_ch_b, cv_ch_mat;
local cl_drawhud = GetConVar("cl_drawhud")

-- Handle initialize and default HUD elements
hook.Add("HUDShouldDraw", "vj_hud_init", function()
	local ply = LocalPlayer()
	-- Run it until local player exists then set everything and delete itself
	if IsValid(ply) then
		-- Networked Values
		ply:SetNW2Int("vj_hud_trhealth", 0)
		ply:SetNW2Int("vj_hud_trmaxhealth", 0)
		ply:SetNW2String("vj_hud_tr_npc_info", "00") -- IsBoss | Disposition | IsGuard | IsMedic | Controlled | If traced NPC is being controlled by local player | Following Player | The Player its following
		
		-- Initialize the ConVars
		cv_hud_disablegmod = GetConVar("vj_hud_disablegmod")
		cv_hud_disablegmodcross = GetConVar("vj_hud_disablegmodcross")
		cv_hud_enabled = GetConVar("vj_hud_enabled")
		cv_hud_unitsystem = GetConVar("vj_hud_metric")
		cv_hud_health = GetConVar("vj_hud_health")
		cv_hud_ammo = GetConVar("vj_hud_ammo")
		cv_hud_compass = GetConVar("vj_hud_compass")
		cv_hud_playerinfo = GetConVar("vj_hud_playerinfo")
		cv_hud_trace = GetConVar("vj_hud_trace")
		cv_hud_trace_limited = GetConVar("vj_hud_trace_limited")
		cv_hud_scanner = GetConVar("vj_hud_scanner")
		cv_ch_enabled = GetConVar("vj_hud_ch_enabled")
		cv_ch_invehicle = GetConVar("vj_hud_ch_invehicle")
		cv_ch_crosssize = GetConVar("vj_hud_ch_size")
		cv_ch_opacity = GetConVar("vj_hud_ch_opacity")
		cv_ch_r = GetConVar("vj_hud_ch_r")
		cv_ch_g = GetConVar("vj_hud_ch_g")
		cv_ch_b = GetConVar("vj_hud_ch_b")
		cv_ch_mat = GetConVar("vj_hud_ch_mat")
		
		-- Change the hook
		hook.Remove("HUDShouldDraw", "vj_hud_init") -- Remove this hook, we only wanna run it once!
		hook.Add("HUDShouldDraw", "vj_hud_hidegmod", function(name)
			if cv_hud_disablegmod:GetInt() == 1 && defaultHUD_Elements[name] then return false end
			if cv_hud_disablegmodcross:GetInt() == 1 && defaultCH_Elements[name] then return false end
		end)
	end
end)

-- Convert given Source world unit to a real world unit (meters / feet)
local function convertToRealUnit(worldUnit)
	if usingMetric == 1 then
		return math_round((worldUnit / 16) / 3.281).." M"
	else
		return math_round(worldUnit / 16).." FT"
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Crosshair ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function VJ_HUD_Crosshair(ply, curTime, srcW, srcH)
	if cv_ch_enabled:GetInt() == 0 then return end
	if ply:InVehicle() && cv_ch_invehicle:GetInt() == 0 then return end
	
	local size = cv_ch_crosssize:GetInt()
	local garmir = cv_ch_r:GetInt()
	local ganach = cv_ch_g:GetInt()
	local gabouyd = cv_ch_b:GetInt()
	local opacity = cv_ch_opacity:GetInt()
	local mat = cv_ch_mat:GetInt()

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
	surface.DrawTexturedRect(srcW / 2 - size / 2, srcH / 2 - size / 2, size, size)
	
	//surface.SetDrawColor(255, 0, 255, opacity)
	//surface.DrawTexturedRect(ply:GetAimVector():ToScreen().x, ply:GetAimVector():ToScreen().y, size, size)
	//surface.DrawCircle(srcW / ply:GetAimVector().x, srcH / ply:GetAimVector().y, 100, {garmir, ganach, gabouyd, opacity})
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Ammo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function VJ_HUD_Ammo(ply, curTime, srcW, srcH)
	if cv_hud_ammo:GetInt() == 0 then return end
	if ply:InVehicle() && !ply:GetAllowWeaponsInVehicle() then return end -- If in a vehicle and can't use weapon, then don't draw
	
	local curwep = ply:GetActiveWeapon()
	if (!IsValid(curwep) or ply:GetActiveWeapon() == "Camera") then
		return -- Don't draw the ammo counter
	end
	
	-- Poon abranknere
	draw.RoundedBox(1, srcW-195, srcH-130, 180, 95, color_box)
	//draw.SimpleText("Weapons - "..table.Count(ply:GetWeapons()), "VJBaseSmall", srcW-340, srcH-95, color_white_muted, 0, 0) -- Kani had zenk oones
	local pri_clip = curwep:Clip1() -- Remaining ammunition for the clip
	local pri_extra = ply:GetAmmoCount(curwep:GetPrimaryAmmoType()) -- Remaining primary fire ammunition (Reserve, not counting current clip!)
	local sec_ammo = ply:GetAmmoCount(curwep:GetSecondaryAmmoType()) -- Remaining secondary fire ammunition
	local suit_power = (ply:GetSuitPower() <= 100 and ply:GetSuitPower()) or 100 -- Make sure 100 is the max!
	local flashlight = ply:FlashlightIsOn()
	
	-- Flashlight
	if suit_power < 50 or flashlight == true then
		surface.SetDrawColor(255 - (suit_power * 2.55), suit_power * 2.55, 0, (flashlight and 255) or 150)
		surface.SetMaterial((flashlight and mat_flashlight_on) or mat_flashlight_off)
		surface.DrawTexturedRectRotated(srcW-((flashlight and 230) or 235), srcH-54, 35, 35, 90)
		//draw.RoundedBox(8, srcW-260, srcH-75, 60, 40, color(0, (ply:FlashlightIsOn() and 255) or 0, (ply:FlashlightIsOn() and 255) or 0, 50))
		draw.RoundedBox(8, srcW-260, srcH-75, 60, 40, color(math_clamp(255 - (suit_power * 2.55), 0, 150), 0, 0, 50 - (suit_power * 0.5)))
		draw.RoundedBox(8, srcW-260, srcH-75, 60, 40, color_box)
	end
	
	-- Grenade count
	surface.SetMaterial(mat_grenade)
	surface.SetDrawColor(0, 255, 255, 150)
	surface.DrawTexturedRect(srcW-95, srcH-70, 25, 25)
	draw.SimpleText(ply:GetAmmoCount("grenade"), "VJBaseMediumLarge", srcW-70, srcH-70, color_cyan_muted, 0, 0)
	
	if curwep:IsWeapon() then
		local wepname = curwep:GetPrintName()
		if string.len(wepname) > 22 then
			wepname = string.sub(curwep:GetPrintName(), 1, 20).."..."
		end
		draw.SimpleText(wepname, "VJBaseSmall", srcW-185, srcH-125, color_white_muted, 0, 0)
	end
	
	local hasammo = true
	local ammo_not_use = false -- Does it use ammo? = true for things like gravity gun or physgun
	local ammo_pri = pri_clip.." / "..pri_extra
	local ammo_pri_c = color_green_muted
	local ammo_sec = sec_ammo
	local ammo_sec_c = color_cyan_muted
	local empty_blink = math_abs(math_sin(curTime * 4) * 255)
	local max_ammo = curwep:GetMaxClip1()
	
	if max_ammo == nil or max_ammo == 0 or max_ammo == -1 then max_ammo = false end
	if pri_clip <= 0 && pri_extra <= 0 then hasammo = false end
	
	if max_ammo != false then // If the current weapon has a proper clip size, then continue...
		local perc_left = math_clamp((pri_clip / max_ammo) * 255, 2, 255) -- Find the percentage of the mag left in respect to the max ammo (proportional) | Clamp at min: 2, max: 255
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
		ammo_pri_c = color_green_muted
		ammo_sec = "---"
		ammo_sec_c = color_orange_muted
	end
	if curwep:GetPrimaryAmmoType() == -1 then -- Weapons that use secondary as primary, ex: "weapon_slam"
		ammo_pri = sec_ammo
		ammo_sec = "---"
		ammo_sec_c = color_orange_muted
	end
	if curwep:GetPrimaryAmmoType() == -1 && curwep:GetSecondaryAmmoType() == -1 then -- Doesn't use ammo
		ammo_not_use = true
		ammo_pri = "---"
		ammo_pri_c = color_orange_muted
		ammo_sec = "---"
		ammo_sec_c = color_orange_muted
	elseif hasammo == false then -- Primary empty
		ammo_pri = "Empty"
		ammo_pri_c = color(255, 0, 0, empty_blink)
	end
	if curwep:GetSecondaryAmmoType() == -1 then -- Doesn't use secondary ammo
		ammo_sec = "---"
		ammo_sec_c = color_orange_muted
	elseif sec_ammo == 0 then -- Secondary empty
		ammo_sec = "Empty"
		ammo_sec_c = color(255, 0, 0, empty_blink)
	end
	local ammo_pri_len = string.len(ammo_pri)
	local ammo_pri_pos = 110
	if ammo_pri_len > 1 then
		ammo_pri_pos = ammo_pri_pos + (6.5*ammo_pri_len)
	end
	draw.SimpleText(ammo_pri, "VJBaseLarge", srcW-ammo_pri_pos, srcH-108, ammo_pri_c, 0, 0)
	surface.SetMaterial(mat_secondary)
	surface.SetDrawColor(ammo_sec_c)
	surface.DrawTexturedRect(srcW-190, srcH-70, 25, 25)
	draw.SimpleText(ammo_sec, "VJBaseMediumLarge", srcW-163, srcH-70, ammo_sec_c, 0, 0)
	
	-- Reloading bar
	if ammo_not_use == false then
		local model_vm = ply:GetViewModel()
		if ply:GetActiveWeapon().CW_VM then model_vm = ply:GetActiveWeapon().CW_VM end -- For CW 2.0 weapons
		if (model_vm:GetSequenceActivity(model_vm:GetSequence()) == ACT_VM_RELOAD or string.match(model_vm:GetSequenceName(model_vm:GetSequence()), "reload") != nil) then
			local anim_perc = math_ceil(model_vm:GetCycle() * 100) -- Get the percentage of how long it will take until it finished reloading
			local anim_dur = model_vm:SequenceDuration() - (model_vm:SequenceDuration() * model_vm:GetCycle()) -- Get the number of seconds until it finishes reloading
			anim_dur = string.format("%.1f", math_round(anim_dur, 1)) -- Round to 1 decimal point and format it to keep a 0 (if applicable)
			if anim_perc < 100 then
				draw.RoundedBox(8, srcW-195, srcH-160, 180, 25, color_cyan_under)
				draw.RoundedBox(8, srcW-195, srcH-160, math_clamp(anim_perc, 0, 100)*1.8, 25, color_cyan_muted)
				draw.RoundedBox(8, srcW-195, srcH-160, 180, 25, color_box)
				draw.SimpleText(anim_dur.."s ("..anim_perc.."%)", "VJBaseSmallMedium", srcW-137, srcH-156, color_white_muted, 0, 0)
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Health ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local lerp_hp = 0
local lerp_armor = 0

local function VJ_HUD_Health(ply, curTime, srcW, srcH, plyAlive)
	if cv_hud_health:GetInt() == 0 then return end
	if !plyAlive then -- Meradz tsootsage
		draw.RoundedBox(8, 70, srcH-80, 142, 30, color(150, 0, 0, math_abs(math_sin(curTime * 6) * 200)))
		draw.SimpleText("USER DEAD", "VJBaseMedium", 85, srcH-77, color(255, 255, 0, math_abs(math_sin(curTime * 6) * 255)), 0, 0)
	else
		draw.RoundedBox(1, 15, srcH-130, 245, 95, color_box)
		local hp_r = 0
		local hp_g = 255
		local hp_b = 0
		local hp_blink = math_abs(math_sin(curTime * 2) * 255)
		lerp_hp = Lerp(5*FrameTime(), lerp_hp, ply:Health())
		lerp_armor = Lerp(5*FrameTime(), lerp_armor, ply:Armor())
		if ply:HasGodMode() then
			hp_r = 255
			hp_g = 102
			hp_b = 255
			draw.RoundedBox(8, 15, srcH-160, 155, 25, color_box)
			draw.SimpleText("God Mode Enabled!", "VJBaseSmallMedium", 25, srcH-156, color(hp_r, hp_g, hp_b, 255), 0, 0)
		else
			local warning = 0
			if lerp_hp <= 35 then
				hp_blink = math_abs(math_sin(curTime * 4) * 255)
				hp_r = 255
				hp_g = 0 + (5 * ply:Health())
				warning = 1
			end
			if lerp_hp <= 20 then -- Low Health Warning
				hp_blink = math_abs(math_sin(curTime * 6) * 255)
				warning = 2
			end
			if warning == 1 then
				draw.RoundedBox(8, 15, srcH-160, 180, 25, color(150, 0, 0, math_abs(math_sin(curTime * 4) * 200)))
				draw.SimpleText("WARNING: Low Health!", "VJBaseSmallMedium", 25, srcH-156, color(255, 153, 0, math_abs(math_sin(curTime * 4) * 255)), 0, 0)
			elseif warning == 2 then
				draw.RoundedBox(8, 15, srcH-160, 220, 25, color(150, 0, 0, math_abs(math_sin(curTime * 6) * 200)))
				draw.SimpleText("WARNING: Death Imminent!", "VJBaseSmallMedium", 25, srcH-156, color(255, 153, 0, math_abs(math_sin(curTime * 6) * 255)), 0, 0)
			end
		end
		
		-- Aroghchoutyoun
		surface.SetMaterial(mat_health)
		surface.SetDrawColor(color(hp_r, hp_g, hp_b, hp_blink))
		surface.DrawTexturedRect(22, srcH-127, 40, 45)
		draw.SimpleText(string.format("%.0f", lerp_hp).."%", "VJBaseMedium", 70, srcH-128, color(hp_r, hp_g, hp_b, 255), 0, 0)
		draw.RoundedBox(0, 70, srcH-105, 180, 15, color(hp_r, hp_g, hp_b, 40))
		draw.RoundedBox(0, 70, srcH-105, math_clamp(lerp_hp, 0, 100)*1.8, 15, color(hp_r, hp_g, hp_b, 255))
		surface.SetDrawColor(hp_r, hp_g, hp_b, 255)
		surface.DrawOutlinedRect(70, srcH-105, 180, 15)
		
		-- Bashbanelik
		surface.SetMaterial(mat_armor)
		surface.SetDrawColor(color_cyan_muted)
		surface.DrawTexturedRect(22, srcH-80, 40, 40)
		draw.SimpleText(string.format("%.0f", lerp_armor).."%", "VJBaseMedium", 70, srcH-83, color_cyan_muted, 0, 0)
		draw.RoundedBox(0, 70, srcH-60, 180, 15, color_cyan_under)
		draw.RoundedBox(0, 70, srcH-60, math_clamp(lerp_armor, 0, 100)*1.8, 15, color_cyan_muted)
		surface.SetDrawColor(0, 150, 150, 255)
		surface.DrawOutlinedRect(70, srcH-60, 180, 15)
		
		-- Suit Auxiliary power
		local suit_power = (ply:GetSuitPower() <= 100 and ply:GetSuitPower()) or 100 -- Make sure 100 is the max!
		if suit_power < 100 then
			local suit_r = 255 - (suit_power * 2.55)
			local suit_g = suit_power * 2.55
			draw.RoundedBox(0, 100, srcH-89, 150, 8, color(suit_r, suit_g, 0, 40))
			draw.RoundedBox(0, 100, srcH-89, math_clamp(suit_power, 0, 100)*1.5, 8, color(suit_r, suit_g, 0, 160))
			surface.SetDrawColor(suit_r, suit_g, 0, 255)
			surface.DrawOutlinedRect(100, srcH-89, 150, 8)
			draw.SimpleText("SUIT", "VJBaseTiny", 70, srcH-89, color(suit_r, suit_g, 0, 255), 0, 0)
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Player Information ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local fps = 0
local next_fps = 0

local function VJ_HUD_PlayerInfo(ply, curTime, srcW, srcH)
	if cv_hud_playerinfo:GetInt() == 0 then return end
	draw.RoundedBox(1, 260, srcH-130, 200, 95, color_box)
	
	-- Number of kills
	surface.SetMaterial(mat_knife)
	surface.SetDrawColor(color_white_muted)
	surface.DrawTexturedRect(260, srcH-125, 28, 28)
	draw.SimpleText(ply:Frags(), "VJBaseMedium", 293, srcH-125, color_white_muted, 100, 100)
	
	-- Number of deaths
	surface.SetMaterial(mat_skull)
	surface.SetDrawColor(color_white_muted)
	surface.DrawTexturedRect(260, srcH-95, 28, 28)
	draw.SimpleText(ply:Deaths(), "VJBaseMedium", 293, srcH-93, color_white_muted, 100, 100)
	
	-- Kill / death ratio
	local kd;
	if ply:Frags() == 0 && ply:Deaths() == 0 then
		kd = 0
	elseif ply:Deaths() == 0 then
		kd = ply:Frags()
	else
		kd = math_round(ply:Frags() / ply:Deaths(), 2)
	end
	if kd < 0 then kd = 0 end
	if kd > 10 then kd = math_round(kd, 1) end
	surface.SetMaterial(mat_kd)
	surface.SetDrawColor(color_white_muted)
	surface.DrawTexturedRect(260, srcH-65, 28, 28)
	draw.SimpleText(kd, "VJBaseMedium", 293, srcH-63, color_white_muted, 100, 100)
	
	-- Movement speed
    local speed;
	if usingMetric == 1 then
		speed = math_round((ply:GetVelocity():Length() * 0.04263382283) * 1.6093).."kph"
	else
		speed = math_round(ply:GetVelocity():Length() * 0.04263382283).."mph"
	end
	surface.SetMaterial(mat_run)
	surface.SetDrawColor(color_white_muted)
	surface.DrawTexturedRect(340, srcH-125, 28, 28)
	draw.SimpleText(speed, "VJBaseMedium", 373, srcH-125, color_white_muted, 100, 100)
	
	-- FPS
	if curTime > next_fps then
		fps = tostring(math_ceil(1 / FrameTime()))
		next_fps = curTime + 0.5
	end
	surface.SetMaterial(mat_fps)
	surface.SetDrawColor(color_white_muted)
	surface.DrawTexturedRect(340, srcH-95, 28, 28)
	draw.SimpleText(fps.."fps", "VJBaseMedium", 373, srcH-93, color_white_muted, 0, 0)
	
	-- Ping
	local ping = ply:Ping()
	local ping_calc = 255 - ping -- Make it more red the higher the ping is!
	surface.SetMaterial(mat_ping)
	surface.SetDrawColor(color(255, ping_calc, ping_calc, 150))
	surface.DrawTexturedRect(340, srcH-65, 28, 28)
	draw.SimpleText(ping.."ms", "VJBaseMedium", 373, srcH-63, color(255, ping_calc, ping_calc, 150), 0, 0)
	
	-- Vehicle speed
	if IsValid(ply:GetVehicle()) then
		draw.RoundedBox(1, 320, srcH-160, 140, 30, color_box)
		local speedcalc = (IsValid(ply:GetVehicle():GetParent()) and ply:GetVehicle():GetParent():GetVelocity():Length()) or ply:GetVehicle():GetVelocity():Length()
		if usingMetric == 1 then
			speedcalc = math_round((speedcalc * 0.04263382283) * 1.6093).."kph"
		else
			speedcalc = math_round(speedcalc * 0.04263382283).."mph"
		end
		surface.SetMaterial(mat_car)
		surface.SetDrawColor(color_white_muted)
		surface.DrawTexturedRect(320, srcH-170, 50, 50)
		draw.SimpleText(speedcalc, "VJBaseMedium", 373, srcH-155, color_white_muted, 100, 100)
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Compass ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function VJ_HUD_Compass(ply, curTime, srcW, srcH)
	if cv_hud_compass:GetInt() == 0 then return end
	draw.RoundedBox(1, srcW / 2.015, 10, 60, 60, color_box)
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
	draw.SimpleText(comp_dir, "VJBaseLarge", srcW / 1.955, 26, color_cyan, 1, 1)
	local trace = util.TraceLine(util.GetPlayerTrace(ply))
    local distrl = convertToRealUnit(ply:GetPos():Distance(trace.HitPos))
	local distrllen = string.len(tostring(distrl))
  	local move_ft = 0
	if distrllen > 4 then
		move_ft = move_ft - (0.007*(distrllen-4))
	end
	draw.SimpleText(distrl, "VJBaseSmall", srcW / (1.985 - move_ft), 38, color_white, 0, 0)
	local dist = math_round(ply:GetPos():Distance(trace.HitPos), 2)
	local distlen = string.len(tostring(dist))
	if distlen >= 7 then
		dist = math_round(ply:GetPos():Distance(trace.HitPos))
		distlen = string.len(tostring(dist))
	end
  	local move_wu = 0
	if distlen > 1 then
		move_wu = move_wu - (0.007*(distlen-1))
	end
	draw.SimpleText(dist.." WU", "VJBaseTiny", srcW/(1.975-move_wu), 55, color_cyan, 0, 0)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Trace Information ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local lerp_trace_hp = 0
local lerp_trace_hp_entid = 0

local function VJ_HUD_TraceInfo(ply, curTime, srcW, srcH)
	if cv_hud_trace:GetInt() == 0 then return end
	local trace = util.TraceLine(util.GetPlayerTrace(ply))
	if IsValid(trace.Entity) then
		local ent = trace.Entity
		if !ent:IsNPC() && !ent:IsPlayer() && cv_hud_trace_limited:GetInt() == 1 then return end -- Yete limited option terver e, mi sharnager
		-- Don't trace the vehicle that the player is currently in
		if IsValid(ply:GetVehicle()) then
			if ent == ply:GetVehicle() then return end -- Yete oton trace-in abrankne, mi sharnager
			if IsValid(ply:GetVehicle():GetParent()) && ent == ply:GetVehicle():GetParent() then return end -- Yete otonyin dznokhke trace-in abrankne, mi sharnager
		end
		local pos = ent:LocalToWorld(ent:OBBMaxs()):ToScreen()
		if (pos.visible) then
			local distrl = convertToRealUnit(ply:GetPos():Distance(trace.HitPos))
			local dist = math_round(ply:GetPos():Distance(trace.HitPos), 2)
			net.Start("vj_hud_ent_info")
			net.WriteEntity(ent)
			net.SendToServer()
			
			if ent:IsNPC() then -- NPC-ineroon hamar minag:
				local npc_info = ply:GetNW2String("vj_hud_tr_npc_info")
				
				-- Don't trace the NPC we are controlling!
				if string.sub(npc_info, 6, 6) == "1" then
					return
				end
				
				-- Boss Icon
				if string.sub(npc_info, 1, 1) == "1" then
					surface.SetMaterial(mat_boss)
					surface.SetDrawColor(color_red)
					surface.DrawTexturedRect(pos.x - 30, pos.y + 27, 26, 26)
				end
				
				local npc_spacing = 0 -- How many spaces (left-right) should it move
				-- Disposition
				local npc_disp = tonumber(string.sub(npc_info, 2, 2))
				local npc_disp_t = "Unknown"
				local npc_disp_color = color_white
				if npc_disp == 1 then
					npc_disp_color = color_red
					npc_disp_t = "Hostile"
				elseif npc_disp == 2 then
					npc_disp_color = color_orange
					npc_disp_t = "Frightened"
				elseif npc_disp == 3 then
					npc_disp_color = color_green
					npc_disp_t = "Friendly"
				elseif npc_disp == 4 then
					npc_disp_color = color_orange
					npc_disp_t = "Neutral"
				end
				npc_spacing = draw.SimpleText(npc_disp_t, "VJBaseSmallMedium", pos.x, pos.y + 55, npc_disp_color, 0, 0)
				npc_spacing = npc_spacing + 10
				
				-- Guarding
				if string.sub(npc_info, 3, 3) == "1" then
					surface.SetMaterial(mat_guarding)
					surface.SetDrawColor(50, 50, 50, 150)
					surface.DrawTexturedRect(pos.x + npc_spacing - 2, pos.y + 55 - 2, 26, 26)
					surface.SetDrawColor(102, 178, 255, 255)
					surface.DrawTexturedRect(pos.x + npc_spacing, pos.y + 55, 22, 22)
					npc_spacing = npc_spacing + 32
				end
				
				-- Medic
				if string.sub(npc_info, 4, 4) == "1" then
					surface.SetMaterial(mat_medic)
					surface.SetDrawColor(50, 50, 50, 150)
					surface.DrawTexturedRect(pos.x + npc_spacing - 2, pos.y + 55 - 2, 26, 26)
					surface.SetDrawColor(200, 255, 153, 255)
					surface.DrawTexturedRect(pos.x + npc_spacing, pos.y + 55, 22, 22)
					npc_spacing = npc_spacing + 32
				end
				
				-- Controlled
				if string.sub(npc_info, 5, 5) == "1" then
					surface.SetMaterial(mat_controller)
					surface.SetDrawColor(50, 50, 50, 150)
					surface.DrawTexturedRect(pos.x + npc_spacing - 2, pos.y + 55 - 2, 26, 26)
					surface.SetDrawColor(255, 213, 0, 255)
					surface.DrawTexturedRect(pos.x + npc_spacing, pos.y + 55, 22, 22)
					npc_spacing = npc_spacing + 32
				end
				
				-- Following Player
				if string.sub(npc_info, 7, 7) == "1" then
					surface.SetMaterial(mat_following)
					surface.SetDrawColor(50, 50, 50, 150)
					surface.DrawTexturedRect(pos.x - 2, pos.y + 68, 34, 34)
					surface.SetDrawColor(221, 160, 221, 255)
					surface.DrawTexturedRect(pos.x, pos.y + 70, 30, 30)
					draw.SimpleText(string.sub(npc_info, 8, -1), "VJBaseSmallMedium", pos.x + 32, pos.y + 75, color(221, 160, 221, 255), 0, 0)
				end
			end
			
			draw.SimpleText(distrl.."("..dist.." WU)", "VJBaseSmallMedium", pos.x, pos.y - 26, color_cyan, 0, 0)
			draw.SimpleText(language.GetPhrase(ent:GetClass()), "VJBaseMedium", pos.x, pos.y - 12, color_white, 0, 0)
			draw.SimpleText(tostring(ent), "VJBaseSmall", pos.x, pos.y + 10, color_white_muted, 0, 0)
			
			local ent_hp = ply:GetNW2Int("vj_hud_trhealth")
			local ent_hpm = ply:GetNW2Int("vj_hud_trmaxhealth")
			if !ent:IsWorld() && !ent:IsVehicle() && ent:Health() != 0 then
				if lerp_trace_hp_entid != ent:EntIndex() then lerp_trace_hp = ent_hpm end
				lerp_trace_hp_entid = ent:EntIndex()
				lerp_trace_hp = Lerp(8*FrameTime(), lerp_trace_hp, ent_hp)
				local hp_box = (190*math_clamp(lerp_trace_hp, 0, ent_hpm))/ent_hpm
				local hp_num = (surface.GetTextSize(ent_hp.."/"..ent_hpm))/2
				local hp_numformat = "/"..ent_hpm
				
				if ent:IsPlayer() then
					hp_box = math_clamp(lerp_trace_hp, 0, 100)*1.9
					hp_num = (surface.GetTextSize(ent_hp.."/100"))/2
					hp_numformat = "%"
				end

				-- Health box
				draw.RoundedBox(1, pos.x, pos.y + 30, 190, 20, color_cyan_under)
				surface.SetDrawColor(0, 255, 255, 150)
				surface.DrawOutlinedRect(pos.x, pos.y + 30, 190, 20)
				draw.RoundedBox(1, pos.x, pos.y + 30, hp_box, 20, color_cyan_muted)
				draw.SimpleText(string.format("%.0f",  lerp_trace_hp)..hp_numformat,  "VJBaseSmall", (pos.x + 105)-hp_num, pos.y + 31, color_white)
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Proximity Scanner ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local AbranknerVorKedne = {
	-- Barz Abrankner --
	gmod_button = {Anoon = "Button", Heravorutyoun = 200, DariKouyn = color_white_muted, Negar = mat_info},
	edit_sky = {Anoon = "Sky Editor", Heravorutyoun = 200, DariKouyn = color_white_muted, Negar = mat_info},
	edit_sun = {Anoon = "Sun Editor", Heravorutyoun = 200, DariKouyn = color_white_muted, Negar = mat_info},
	edit_fog = {Anoon = "Fog Editor", Heravorutyoun = 200, DariKouyn = color_white_muted, Negar = mat_info},
	
	-- Aroghchoutyoun yev Bashbanelik --
	item_healthkit = {Anoon = "Health Kit", Heravorutyoun = 400, DariKouyn = color_green_muted, Negar = mat_medic},
	item_healthvial = {Anoon = "Health Vial", Heravorutyoun = 400, DariKouyn = color_green_muted, Negar = mat_medic},
	item_battery = {Anoon = "Suit Battery", Heravorutyoun = 400, DariKouyn = color_green_muted, Negar = mat_armor},
	item_suitcharger = {Anoon = "Suit Charger", Heravorutyoun = 400, DariKouyn = color_green_muted, Negar = mat_armor},
	item_healthcharger = {Anoon = "Health Charger", Heravorutyoun = 400, DariKouyn = color_green_muted, Negar = mat_medic},
	item_suit = {Anoon = "HEV Suit", Heravorutyoun = 400, DariKouyn = color_green_muted, Negar = mat_armor},
	
	-- Panpousht --
	item_ammo_ar2 = {Anoon = "AR2 Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_ammo_ar2_large = {Anoon = "Large AR2 Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_ammo_pistol = {Anoon = "Pistol Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_ammo_pistol_large = {Anoon = "Large Pistol Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_box_buckshot = {Anoon = "Shotgun Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_ammo_357 = {Anoon = ".357 Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_ammo_357_large = {Anoon = "Large .357 Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_ammo_smg1 = {Anoon = "SMG Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_ammo_smg1_large = {Anoon = "Large SMG Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_ammo_ar2_altfire = {Anoon = "Combine Ball Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_ammo_crossbow = {Anoon = "Crossbow Bolts Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_ammo_smg1_grenade = {Anoon = "SMG Grenade Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	item_rpg_round = {Anoon = "RPG Ammo", Heravorutyoun = 200, DariKouyn = color_cyan_muted, Negar = mat_ammoBox},
	
	-- Vdankavor --
	combine_mine = {Anoon = "Mine!", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1), Negar = mat_skull},
	prop_combine_ball = {Anoon = "Combine Ball!", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1), Negar = mat_skull},
	npc_rollermine = {Anoon = "RollerMine!", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1), Negar = mat_skull},
	grenade_helicopter = {Anoon = "Bomb!", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1), Negar = mat_skull},
}
local grenadeObj = {Anoon = "Grenade!", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1), Negar = mat_grenade}

local function VJ_HUD_Scanner(ply, curTime, srcW, srcH)
	if cv_hud_scanner:GetInt() == 0 then return end
	local blinkAlpha = math_abs(math_sin(curTime * 5) * 255)
	local plyPos = ply:GetPos()
	for _, ent in ipairs(ents.FindInSphere(plyPos, 320)) do
		local v = AbranknerVorKedne[ent:GetClass()]
		if ent.VJ_ID_Grenade && !v then -- If its tagged as a grenade and no entity was found then label it as a grenade!
			v = grenadeObj
		end
		if v then
			local dist = plyPos:Distance(ent:GetPos())
			if dist < v.Heravorutyoun then
				local startPos = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
				local matColor = (v.DariKouyn.a == -1 and color(v.DariKouyn.r, v.DariKouyn.g, v.DariKouyn.b, blinkAlpha)) or v.DariKouyn
				draw.SimpleText(v.Anoon, "VJBaseMedium", startPos.x + 1, startPos.y + 1, matColor, 0, 0)
				draw.SimpleText(convertToRealUnit(dist), "HudHintTextLarge", startPos.x + 30, startPos.y + 25, color_white, 0, 0)
				
				-- Goghme negar ge tsetsen e
				surface.SetMaterial(v.Negar)
				surface.SetDrawColor(matColor)
				surface.DrawTexturedRect(startPos.x - 32, startPos.y, 30, 30)
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Main ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("HUDPaint", "vj_hud", function()
	if cv_hud_enabled:GetInt() != 0 && cl_drawhud:GetInt() == 1 then
		local ply = LocalPlayer()
		local curTime = CurTime()
		local srcW = ScrW()
		local srcH = ScrH()
		local plyAlive = ply:Alive()
		usingMetric = cv_hud_unitsystem:GetInt()
		if plyAlive then
			VJ_HUD_Crosshair(ply, curTime, srcW, srcH)
			VJ_HUD_Ammo(ply, curTime, srcW, srcH)
			VJ_HUD_PlayerInfo(ply, curTime, srcW, srcH)
			VJ_HUD_Compass(ply, curTime, srcW, srcH)
			VJ_HUD_TraceInfo(ply, curTime, srcW, srcH)
			VJ_HUD_Scanner(ply, curTime, srcW, srcH)
		end
		VJ_HUD_Health(ply, curTime, srcW, srcH, plyAlive)
	end
end)