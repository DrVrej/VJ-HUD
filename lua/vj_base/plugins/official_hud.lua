/*--------------------------------------------------
	*** Copyright (c) 2012-2025 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
VJ.AddPlugin("VJ HUD", "HUD", "1.3.0")

/*----------------------------------------------------------
	-- Screen Helper --
	Down = Positive
	Up = Negative
	Right = Positive
	Left = Negative
----------------------------------------------------------*/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ SERVER ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if SERVER then
	-- Initialize player's networked variables
	gameevent.Listen("player_activate")
	hook.Add("player_activate", "vj_hud_player_activate", function(data)
		local ply = Player(data.userid)
		ply:SetNW2Int("vj_hud_trhealth", 0)
		ply:SetNW2Int("vj_hud_trmaxhealth", 0)
		ply:SetNW2String("vj_hud_tr_npc_info", "00")
	end)

	util.AddNetworkString("vj_hud_ent_info")
	-- IsBoss | Disposition | IsGuard | IsMedic | Controlled | If traced NPC is being controlled by local player | Following Player | The Player its following
	net.Receive("vj_hud_ent_info", function(len, ply)
		local ent = net.ReadEntity()
		if IsValid(ply) && IsValid(ent) then
			ply:SetNW2Int("vj_hud_trhealth", ent:Health())
			ply:SetNW2Int("vj_hud_trmaxhealth", ent:GetMaxHealth())
			if ent:IsNPC() then
				local npc_boss = (ent.VJ_ID_Boss and "1") or "0"
				local npc_guard = (ent.IsGuard and "1") or "0"
				local npc_medic = (ent.IsMedic and "1") or "0"
				local npc_controlled = (ent.VJ_IsBeingControlled and "1") or "0"
				local npc_iscontroller = ((ply.VJ_IsControllingNPC and IsValid(ply.VJ_TheControllerEntity.VJCE_NPC) and ply.VJ_TheControllerEntity.VJCE_NPC == ent) and "1") or "0"
				local npc_following = "0"
				local npc_followingn = "Unknown"
				if ent.IsFollowing then
					npc_following = "1"
					local followEnt = ent.FollowData.Target
					if followEnt:IsPlayer() then
						npc_followingn = followEnt == ply and "You" or followEnt:Nick()
					elseif followEnt:IsNPC() then
						npc_followingn = list.Get("NPC")[followEnt:GetClass()].Name
					else
						npc_followingn = followEnt:GetClass()
					end
				end
				ply:SetNW2String("vj_hud_tr_npc_info", npc_boss .. "|" .. ent:Disposition(ply) .. "|" .. npc_guard .. "|" .. npc_medic .. "|" .. npc_controlled .. "|" .. npc_iscontroller .. "|" .. npc_following .. "|" .. npc_followingn)
			end
		end
	end)
end

if !CLIENT then return end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ ConVars ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Main Components
local vj_hud_enabled = VJ.AddClientConVar("vj_hud_enabled", 1) -- Enable VJ HUD
local vj_hud_health = VJ.AddClientConVar("vj_hud_health", 1) -- Enable health and suit
local vj_hud_ammo = VJ.AddClientConVar("vj_hud_ammo", 1) -- Enable ammo
local vj_hud_compass = VJ.AddClientConVar("vj_hud_compass", 1) -- Enable compass
local vj_hud_playerinfo = VJ.AddClientConVar("vj_hud_playerinfo", 1) -- Enable local player information
local vj_hud_trace = VJ.AddClientConVar("vj_hud_trace", 1) -- Enable trace information
local vj_hud_trace_limited = VJ.AddClientConVar("vj_hud_trace_limited", 0) -- Should it only display the trace information when looking at a player or an NPC?
local vj_hud_scanner = VJ.AddClientConVar("vj_hud_scanner", 1) -- Enable proximity scanner
local vj_hud_metric = VJ.AddClientConVar("vj_hud_metric", 0) -- Use Metric instead of Imperial

-- Crosshair
local vj_hud_ch_enabled = VJ.AddClientConVar("vj_hud_ch_enabled", 1) -- Enable VJ Crosshair
local vj_hud_ch_invehicle = VJ.AddClientConVar("vj_hud_ch_invehicle", 1) -- Should the Crosshair be enabled in the vehicle?
local vj_hud_ch_size = VJ.AddClientConVar("vj_hud_ch_size", 50) -- Crosshair Size
local vj_hud_ch_opacity = VJ.AddClientConVar("vj_hud_ch_opacity", 255) -- Opacity of the Crosshair
local vj_hud_ch_r = VJ.AddClientConVar("vj_hud_ch_r", 0) -- Crosshair Color - Red
local vj_hud_ch_g = VJ.AddClientConVar("vj_hud_ch_g", 255) -- Crosshair Color - Green
local vj_hud_ch_b = VJ.AddClientConVar("vj_hud_ch_b", 0) -- Crosshair Color - Blue
local vj_hud_ch_mat = VJ.AddClientConVar("vj_hud_ch_mat", 0) -- The Crosshair Material

-- Garry's Mod Components
local vj_hud_disablegmod = VJ.AddClientConVar("vj_hud_disablegmod", 1) -- Disable Garry's Mod HUD
local vj_hud_disablegmodcross = VJ.AddClientConVar("vj_hud_disablegmodcross", 1) -- Disable Garry's Mod Crosshair

local cl_drawhud = GetConVar("cl_drawhud")
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
		local crosshairComboBox = {Options = {}, CVars = {}, Label = "Crosshair Material:", MenuButton = "0"}
		crosshairComboBox.Options["Arrow (Two, Default)"] = {
			vj_hud_ch_mat = "0",
		}
		crosshairComboBox.Options["Dot (Five, Small)"] = {
			vj_hud_ch_mat = "1",
		}
		crosshairComboBox.Options["Dot"] = {
			vj_hud_ch_mat = "2",
		}
		crosshairComboBox.Options["Dot (Five, Sniper)"] = {
			vj_hud_ch_mat = "3",
		}
		crosshairComboBox.Options["Circle (Dashed)"] = {
			vj_hud_ch_mat = "4",
		}
		crosshairComboBox.Options["Dot (Four)"] = {
			vj_hud_ch_mat = "5",
		}
		crosshairComboBox.Options["Circle"] = {
			vj_hud_ch_mat = "6",
		}
		crosshairComboBox.Options["Line (Four, Angled)"] = {
			vj_hud_ch_mat = "7",
		}
		crosshairComboBox.Options["Dot (Five, Large)"] = {
			vj_hud_ch_mat = "8",
		}
		panel:AddControl("ComboBox", crosshairComboBox)
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
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Static Variables ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local defaultHUD_Elements = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
	["CHudSuitPower"] = true,
    ["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true
}
local defaultCH_Elements = {
	["CHudCrosshair"] = true
}

-- Functions
local tonumber = tonumber
local math_round = math.Round
local math_clamp = math.Clamp
local math_abs = math.abs
local math_sin = math.sin
local math_ceil = math.ceil
local string_Explode = string.Explode

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
local color_under = color(0, 0, 0, 180) -- Used to apply shading for progress bars

-- Box Values
local box_border_thickness = 2 -- Border thickness for boxes that use them
local box_border_thickness_adjusted = box_border_thickness * 2 -- Used to adjust the other boxes that are associated with the border box
local box_roundness = 6 -- Roundness value for the main boxes
local box_roundness_popup = 8 -- Roundness value for the popup boxes

-- Materials
local mat_crossh1 = Material("vj_hud/crosshair/crosshair1.vtf")
local mat_crossh2 = Material("vj_hud/crosshair/crosshair2.vtf")
local mat_crossh3 = Material("vj_hud/crosshair/crosshair3.vtf")
local mat_crossh4 = Material("vj_hud/crosshair/crosshair4.vtf")
local mat_crossh5 = Material("vj_hud/crosshair/crosshair5.vtf")
local mat_crossh6 = Material("vj_hud/crosshair/crosshair6.vtf")
local mat_crossh7 = Material("vj_hud/crosshair/crosshair7.vtf")
local mat_crossh8 = Material("vj_hud/crosshair/crosshair8.vtf")
local mat_crossh9 = Material("vj_hud/crosshair/crosshair9.vtf")
local mat_flashlight_on = Material("vj_hud/flashlight_on.png", "mips smooth")
local mat_flashlight_off = Material("vj_hud/flashlight_off.png", "mips smooth")
local mat_grenade = Material("vj_hud/grenade.png", "mips smooth")
local mat_ammoBox = Material("vj_hud/ammobox.png", "mips smooth")
local mat_secondary = Material("vj_hud/secondary.png", "mips smooth")
local mat_health = Material("vj_hud/hp.png", "mips smooth")
local mat_armor = Material("vj_hud/armor.png", "mips smooth")
local mat_knife = Material("vj_hud/knife.png", "mips smooth")
local mat_skull = Material("vj_hud/skull.png", "mips smooth")
local mat_kd = Material("vj_hud/kd.png", "mips smooth")
local mat_run = Material("vj_hud/running.png", "mips smooth")
local mat_fps = Material("vj_hud/fps.png", "mips smooth")
local mat_ping = Material("vj_hud/ping.png", "mips smooth")
local mat_car = Material("vj_hud/car.png", "mips smooth")
local mat_boss = Material("vj_hud/crown.png", "mips smooth")
local mat_guarding = Material("vj_hud/guarding.png", "mips smooth")
local mat_medic = Material("vj_hud/medic.png", "mips smooth")
local mat_controller = Material("vj_hud/controller.png", "mips smooth")
local mat_following = Material("vj_hud/following.png", "mips smooth")
local mat_info = Material("vj_hud/info.png", "mips smooth")
local mat_compass = Material("vj_hud/compass.png", "smooth noclamp 1")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Helpers ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local usingMetric = 0

-- Convert Source world unit to a real unit (meters / feet)
local function convertToRealUnit(worldUnit)
	if usingMetric == 1 then
		return math_round((worldUnit / 16) / 3.281, 2) .. " M"
	else
		return math_round(worldUnit / 16, 2) .. " FT"
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local traceMask = bit.bor(CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_GRATE, CONTENTS_DEBRIS, CONTENTS_HITBOX)
--
local function getTrace(ply)
	local frameNum = FrameNumber()
	if ply.VJ_LastPlayerTrace == frameNum then
		return ply.VJ_PlayerTrace
	end
	local eyePos = ply:EyePos()
	local tr = util.TraceLine({
		start = eyePos,
		endpos = eyePos + ply:GetAimVector() * 32768,
		filter = ply,
		mask = traceMask
	})
	ply.VJ_LastPlayerTrace = frameNum
	ply.VJ_PlayerTrace = tr
	return tr
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Crosshair ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function VJ_HUD_Crosshair(ply, curTime, srcW, srcH)
	if vj_hud_ch_enabled:GetInt() == 0 then return end
	if ply:InVehicle() && vj_hud_ch_invehicle:GetInt() == 0 then return end
	
	local size = vj_hud_ch_size:GetInt()
	local garmir = vj_hud_ch_r:GetInt()
	local ganach = vj_hud_ch_g:GetInt()
	local gabouyd = vj_hud_ch_b:GetInt()
	local opacity = vj_hud_ch_opacity:GetInt()
	local mat = vj_hud_ch_mat:GetInt()

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
	if vj_hud_ammo:GetInt() == 0 then return end
	if ply:InVehicle() && !ply:GetAllowWeaponsInVehicle() then return end -- If in a vehicle and can't use weapon, then don't draw
	
	local weapon = ply:GetActiveWeapon()
	if !IsValid(weapon) then
		return -- Don't draw the ammo counter
	end
	
	-- Poon abranknere
	draw.RoundedBox(box_roundness, srcW-195, srcH-130, 180, 95, color_box)
	//draw.SimpleText("Weapons - " .. table.Count(ply:GetWeapons()), "VJBaseSmall", srcW-340, srcH-95, color_white_muted, 0, 0) -- Kani had zenk oones
	local pri_clip = weapon:Clip1() -- Remaining ammunition for the clip
	local pri_reserve = ply:GetAmmoCount(weapon:GetPrimaryAmmoType()) -- Remaining primary fire ammunition (Reserve, not counting current clip!)
	local sec_ammo = ply:GetAmmoCount(weapon:GetSecondaryAmmoType()) -- Remaining secondary fire ammunition
	local suit_power = (ply:GetSuitPower() <= 100 and ply:GetSuitPower()) or 100 -- Make sure 100 is the max!
	local flashlight = ply:FlashlightIsOn()
	
	-- Flashlight
	if suit_power < 50 or flashlight then
		surface.SetDrawColor(255 - (suit_power * 2.55), suit_power * 2.55, 0, (flashlight and 255) or 150)
		surface.SetMaterial((flashlight and mat_flashlight_on) or mat_flashlight_off)
		surface.DrawTexturedRectRotated(srcW-((flashlight and 230) or 235), srcH-54, 35, 35, 90)
		//draw.RoundedBox(box_roundness_popup, srcW-260, srcH-75, 60, 40, color(0, (ply:FlashlightIsOn() and 255) or 0, (ply:FlashlightIsOn() and 255) or 0, 50))
		draw.RoundedBox(box_roundness_popup, srcW-260, srcH-75, 60, 40, color(math_clamp(255 - (suit_power * 2.55), 0, 150), 0, 0, 50 - (suit_power * 0.5)))
		draw.RoundedBox(box_roundness_popup, srcW-260, srcH-75, 60, 40, color_box)
	end
	
	-- Grenade count
	surface.SetMaterial(mat_grenade)
	surface.SetDrawColor(0, 255, 255, 150)
	surface.DrawTexturedRect(srcW-95, srcH-70, 25, 25)
	draw.SimpleText(ply:GetAmmoCount("grenade"), "VJBaseMediumLarge", srcW-70, srcH-70, color_cyan_muted, 0, 0)
	
	-- Weapon name
	if weapon:IsWeapon() then
		local name = language.GetPhrase(weapon:GetPrintName())
		if string.len(name) > 22 then
			name = string.sub(name, 1, 20) .. "..."
		end
		draw.SimpleText(name, "VJBaseSmall", srcW-185, srcH-125, color_white_muted, 0, 0)
	end
	
	local ammo_empty = true
	local ammo_unavailable = false -- Does it use ammo? = true for things like gravity gun or physgun
	local ammo_pri = pri_clip .. " / " .. pri_reserve
	local ammo_pri_c = color_green_muted
	local ammo_sec = sec_ammo
	local ammo_sec_c = color_cyan_muted
	local empty_blink = math_abs(math_sin(curTime * 4) * 255)
	local max_ammo = weapon:GetMaxClip1()
	
	if max_ammo == nil or max_ammo == 0 or max_ammo == -1 then max_ammo = false end
	if pri_clip <= 0 && pri_reserve <= 0 then ammo_empty = false end
	
	if max_ammo != false then // If the current weapon has a proper clip size, then continue...
		local perc_left = math_clamp((pri_clip / max_ammo) * 255, 2, 255) -- Find the percentage of the mag left in respect to the max ammo (proportional) | Clamp at min: 2, max: 255
		if perc_left <= 127.5 then // 127.5  = 50% of 255
			ammo_pri_c = color(255, 40 + perc_left, 0, 255)
		end
	end
		
	if ammo_empty && pri_clip <= 0 then -- Mag is empty but has reserve
		ammo_pri = "--- / " .. pri_reserve
		ammo_pri_c = color(255, 0, 0, empty_blink)
	end
	if pri_clip == -1 && weapon:GetSecondaryAmmoType() == -1 then -- Uses primary only with no ammo reserve, ex: "weapon_rpg" or "weapon_frag"
		ammo_pri = pri_reserve
		ammo_pri_c = color_green_muted
		ammo_sec = "---"
		ammo_sec_c = color_orange_muted
	end
	if weapon:GetPrimaryAmmoType() == -1 then -- Weapons that use secondary as primary, ex: "weapon_slam"
		ammo_pri = sec_ammo
		ammo_sec = "---"
		ammo_sec_c = color_orange_muted
	end
	if weapon:GetPrimaryAmmoType() == -1 && weapon:GetSecondaryAmmoType() == -1 then -- Doesn't use ammo
		ammo_unavailable = true
		ammo_pri = "---"
		ammo_pri_c = color_orange_muted
		ammo_sec = "---"
		ammo_sec_c = color_orange_muted
	elseif !ammo_empty then -- Primary empty
		ammo_pri = "Empty"
		ammo_pri_c = color(255, 0, 0, empty_blink)
	end
	if weapon:GetSecondaryAmmoType() == -1 then -- Doesn't use secondary ammo
		ammo_sec = "---"
		ammo_sec_c = color_orange_muted
	elseif sec_ammo == 0 then -- Secondary empty
		ammo_sec = "Empty"
		ammo_sec_c = color(255, 0, 0, empty_blink)
	end
	local ammo_pri_len = string.len(ammo_pri)
	local ammo_pri_pos = 110
	if ammo_pri_len > 1 then
		ammo_pri_pos = ammo_pri_pos + (6.5 * ammo_pri_len)
	end
	draw.SimpleText(ammo_pri, "VJBaseLarge", srcW-ammo_pri_pos, srcH-108, ammo_pri_c, 0, 0)
	surface.SetMaterial(mat_secondary)
	surface.SetDrawColor(ammo_sec_c)
	surface.DrawTexturedRect(srcW-190, srcH-70, 25, 25)
	draw.SimpleText(ammo_sec, "VJBaseMediumLarge", srcW-163, srcH-70, ammo_sec_c, 0, 0)
	
	-- Reloading bar
	if !ammo_unavailable then
		local model_vm = ply:GetViewModel()
		if weapon.CW_VM then model_vm = weapon.CW_VM end -- For CW 2.0 weapons
		if weapon.Base == "mg_base" && weapon:HasFlag("Reloading") then model_vm = weapon:GetViewModel() end -- For MW Base weapons
		if model_vm:GetSequenceActivity(model_vm:GetSequence()) == ACT_VM_RELOAD or string.match(model_vm:GetSequenceName(model_vm:GetSequence()), "reload") then
			local anim_perc = math_ceil(model_vm:GetCycle() * 100) -- Get the percentage of how long the reload animation is
			local anim_dur = model_vm:SequenceDuration() - (model_vm:SequenceDuration() * model_vm:GetCycle()) -- Get the number of seconds until it finishes reloading
			anim_dur = string.format("%.1f", math_round(anim_dur, 1)) -- Round to 1 decimal point and format it to keep a 0 (if applicable)
			if anim_perc < 100 then
				draw.RoundedBox(box_roundness_popup, srcW - 195, srcH - 160, 180, 25, color_cyan_under)
				draw.RoundedBox(box_roundness_popup, srcW - 195, srcH - 160, math_clamp(anim_perc, 0, 100) * 1.8, 25, color_cyan_muted)
				draw.RoundedBox(box_roundness_popup, srcW - 195, srcH - 160, 180, 25, color_box)
				draw.SimpleText(anim_dur .. "s (" .. anim_perc .. "%)", "VJBaseSmallMedium", srcW - 137, srcH - 156, color_white_muted, 0, 0)
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
	if vj_hud_health:GetInt() == 0 then return end
	if !plyAlive then -- Meradz tsootsage
		draw.RoundedBox(box_roundness_popup, 70, srcH-80, 145, 30, color(150, 0, 0, math_abs(math_sin(curTime * 6) * 200)))
		draw.SimpleText("USER DEAD", "VJBaseMedium", 85, srcH-77, color(255, 255, 0, math_abs(math_sin(curTime * 6) * 255)), 0, 0)
	else
		draw.RoundedBox(box_roundness, 15, srcH-130, 245, 95, color_box)
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
			draw.RoundedBox(box_roundness_popup, 15, srcH - 160, 160, 25, color_box)
			draw.SimpleText("God Mode Enabled!", "VJBaseSmallMedium", 25, srcH - 156, color(hp_r, hp_g, hp_b, 255), 0, 0)
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
				draw.RoundedBox(box_roundness_popup, 15, srcH - 160, 190, 25, color(150, 0, 0, math_abs(math_sin(curTime * 4) * 200)))
				draw.SimpleText("WARNING: Low Health!", "VJBaseSmallMedium", 25, srcH-156, color(255, 153, 0, math_abs(math_sin(curTime * 4) * 255)), 0, 0)
			elseif warning == 2 then
				draw.RoundedBox(box_roundness_popup, 15, srcH - 160, 222, 25, color(150, 0, 0, math_abs(math_sin(curTime * 6) * 200)))
				draw.SimpleText("WARNING: Death Imminent!", "VJBaseSmallMedium", 25, srcH-156, color(255, 153, 0, math_abs(math_sin(curTime * 6) * 255)), 0, 0)
			end
		end
		
		-- Aroghchoutyoun
		surface.SetMaterial(mat_health)
		surface.SetDrawColor(color(hp_r, hp_g, hp_b, hp_blink))
		surface.DrawTexturedRect(22, srcH - 127, 40, 45)
		draw.SimpleText(string.format("%.0f", lerp_hp) .. "%", "VJBaseMedium", 70, srcH - 128, color(hp_r, hp_g, hp_b, 255), 0, 0)
		draw.RoundedBox(box_roundness, 70, srcH - 105, 180, 15, color(hp_r, hp_g, hp_b, 255))
		draw.RoundedBox(box_roundness, 70 + box_border_thickness, srcH - 105 + box_border_thickness, 180 - box_border_thickness_adjusted, 15 - box_border_thickness_adjusted, color_under)
		draw.RoundedBox(box_roundness, 70 + box_border_thickness, srcH - 105 + box_border_thickness, math_clamp(lerp_hp, 0, 100) * 1.8 - box_border_thickness_adjusted, 15 - box_border_thickness_adjusted, color(hp_r, hp_g, hp_b, 255))
		//surface.SetDrawColor(hp_r, hp_g, hp_b, 255)
		//surface.DrawOutlinedRect(70, srcH-105, 180, 15)
		
		-- Bashbanelik
		surface.SetMaterial(mat_armor)
		surface.SetDrawColor(color_cyan_muted)
		surface.DrawTexturedRect(22, srcH - 80, 40, 40)
		draw.SimpleText(string.format("%.0f", lerp_armor) .. "%", "VJBaseMedium", 70, srcH - 83, color_cyan_muted, 0, 0)
		draw.RoundedBox(box_roundness, 70, srcH - 60, 180, 15, color_cyan_muted)
		draw.RoundedBox(box_roundness, 70 + box_border_thickness, srcH - 60 + box_border_thickness, 180 - box_border_thickness_adjusted, 15 - box_border_thickness_adjusted, color_under)
		draw.RoundedBox(box_roundness, 70 + box_border_thickness, srcH - 60 + box_border_thickness, math_clamp(lerp_armor, 0, 100) * 1.8 - box_border_thickness_adjusted, 15 - box_border_thickness_adjusted, color_cyan_muted)
		//surface.SetDrawColor(0, 150, 150, 255)
		//surface.DrawOutlinedRect(70, srcH-60, 180, 15)
		
		//draw.RoundedBox(box_roundness, pos.x, pos.y + 30, 190, 20, color_cyan_muted)
		//draw.RoundedBox(box_roundness, pos.x + box_border_thickness, pos.y + 30 + box_border_thickness, 190 - box_border_thickness_adjusted, 20 - box_border_thickness_adjusted, color_under)
		//draw.RoundedBox(box_roundness, pos.x + box_border_thickness, pos.y + 30 + box_border_thickness, hp_box - box_border_thickness_adjusted, 20 - box_border_thickness_adjusted, color_cyan_muted)
		
		-- Suit Auxiliary power
		local suit_power = (ply:GetSuitPower() <= 100 and ply:GetSuitPower()) or 100 -- Make sure 100 is the max!
		if suit_power < 100 then
			local suit_r = 255 - (suit_power * 2.55)
			local suit_g = suit_power * 2.55
			draw.RoundedBox(box_roundness, 100, srcH - 89, 150, 8, color(suit_r, suit_g, 0, 160))
			draw.RoundedBox(box_roundness, 100 + box_border_thickness, srcH - 89 + box_border_thickness, 150 - box_border_thickness_adjusted, 8 - box_border_thickness_adjusted, color_under)
			draw.RoundedBox(box_roundness, 100 + box_border_thickness, srcH - 89 + box_border_thickness, math_clamp(suit_power, 0, 100) * 1.5 - box_border_thickness_adjusted, 8 - box_border_thickness_adjusted, color(suit_r, suit_g, 0, 160))
			//surface.SetDrawColor(suit_r, suit_g, 0, 255)
			//surface.DrawOutlinedRect(100, srcH-89, 150, 8)
			draw.SimpleText("SUIT", "VJBaseTiny", 70, srcH - 89, color(suit_r, suit_g, 0, 255), 0, 0)
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Player Information ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local fps = 0
local next_fps = 0

local function VJ_HUD_PlayerInfo(ply, curTime, srcW, srcH)
	if vj_hud_playerinfo:GetInt() == 0 then return end
	local curVehicle = ply:GetVehicle()
	local curVehicleValid = IsValid(curVehicle)
	draw.RoundedBoxEx(box_roundness, 260, srcH-130, 200, 95, color_box, true, !curVehicleValid, true, true)
	
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
		speed = math_round((ply:GetVelocity():Length() * 0.04263382283) * 1.6093) .. "kph"
	else
		speed = math_round(ply:GetVelocity():Length() * 0.04263382283) .. "mph"
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
	draw.SimpleText(fps .. "fps", "VJBaseMedium", 373, srcH-93, color_white_muted, 0, 0)
	
	-- Ping
	local ping = ply:Ping()
	local ping_calc = 255 - ping -- Make it more red the higher the ping is!
	surface.SetMaterial(mat_ping)
	surface.SetDrawColor(color(255, ping_calc, ping_calc, 150))
	surface.DrawTexturedRect(340, srcH-65, 28, 28)
	draw.SimpleText(ping .. "ms", "VJBaseMedium", 373, srcH-63, color(255, ping_calc, ping_calc, 150), 0, 0)
	
	-- Vehicle speed
	if curVehicleValid then
		local curVehicleParent = curVehicle:GetParent()
		local speedVehicle = (IsValid(curVehicleParent) and curVehicleParent:GetVelocity():Length()) or curVehicle:GetVelocity():Length()
		if usingMetric == 1 then
			speedVehicle = math_round((speedVehicle * 0.04263382283) * 1.6093) .. "kph"
		else
			speedVehicle = math_round(speedVehicle * 0.04263382283) .. "mph"
		end
		draw.RoundedBoxEx(box_roundness, 320, srcH-160, 140, 30, color_box, true, true)
		surface.SetMaterial(mat_car)
		surface.SetDrawColor(color_white_muted)
		surface.DrawTexturedRect(320, srcH-170, 50, 50)
		draw.SimpleText(speedVehicle, "VJBaseMedium", 373, srcH-155, color_white_muted, 100, 100)
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Compass ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local texW = 1244
local texH = 35
local drawW = 300
local middleLineW = 3
--
local function VJ_HUD_Compass(ply, curTime, srcW, srcH)
	if vj_hud_compass:GetInt() == 0 then return end
	
    local x, y = srcW / 2 - drawW / 2, 10
    local yaw = (math.NormalizeAngle(ply:EyeAngles().y) + 180) / 360
    local u1 = (yaw * texW) % texW / texW
    local u2 = ((yaw * texW + drawW) % texW) / texW
	
	draw.RoundedBox(box_roundness, srcW / 2 - 160, y + 3, 320, 50, color_box) -- Background
	draw.RoundedBoxEx(box_roundness, srcW / 2 - (middleLineW / 2), y + 33, middleLineW, 18, color_white_muted) -- Middle line
	
    surface.SetMaterial(mat_compass)
    surface.SetDrawColor(color_white_muted)

    if u2 > u1 then
        surface.DrawTexturedRectUV(x, y, drawW, texH, u1, 0, u2, 1)
    else -- Middle part between the end and start of the texture
        local w1 = (1 - u1) * texW
        surface.DrawTexturedRectUV(x, y, w1 + 1.5, texH, u1, 0, 1, 1)
        surface.DrawTexturedRectUV(x + w1, y, drawW - w1 + 1.5, texH, 0, 0, u2, 1)
    end
	
	-- Distance numbers
	local dist = ply:GetPos():Distance(getTrace(ply).HitPos)
	draw.SimpleText(convertToRealUnit(dist), "VJBaseSmall", srcW / 2.02, 45, color_cyan, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
	draw.SimpleText(math_round(dist, 2) .. " WU", "VJBaseSmall", srcW / 1.98, 45, color_cyan, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	
	-- Very old compass code (before v1.3.0)
	/*draw.RoundedBox(box_roundness, srcW / 2.015, 10, 60, 60, color_box)
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
	local plyPos = ply:GetPos()
	local trace = getTrace(ply)
    local dist_converted = convertToRealUnit(plyPos:Distance(trace.HitPos))
	local dist_convertedlen = string.len(tostring(dist_converted))
  	local move_ft = 0
	if dist_convertedlen > 4 then
		move_ft = move_ft - (0.007 * (dist_convertedlen - 4))
	end
	draw.SimpleText(dist_converted, "VJBaseSmall", srcW / (1.985 - move_ft), 38, color_white, 0, 0)
	local dist = math_round(plyPos:Distance(trace.HitPos), 2)
	local distlen = string.len(tostring(dist))
	if distlen >= 7 then
		dist = math_round(plyPos:Distance(trace.HitPos))
		distlen = string.len(tostring(dist))
	end
  	local move_wu = 0
	if distlen > 1 then
		move_wu = move_wu - (0.007*(distlen-1))
	end
	draw.SimpleText(dist .. " WU", "VJBaseTiny", srcW/(1.975-move_wu), 55, color_cyan, 0, 0)*/
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Trace Information ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local lerp_trace_hp = 0
local lerp_trace_hp_entid = 0

local function VJ_HUD_TraceInfo(ply, curTime, srcW, srcH)
	if vj_hud_trace:GetInt() == 0 then return end
	local trace = getTrace(ply)
	local ent = trace.Entity
	//PrintTable(trace)
	if IsValid(trace.Entity) then
		-- If trace limiting is enabled, then skip entities that are not NPCs or Players
		if !ent.VJ_ID_Living && vj_hud_trace_limited:GetInt() == 1 then return end
		
		-- Skip the vehicle that the player is currently in
		local curVehicle = ply:GetVehicle()
		if IsValid(curVehicle) then
			if ent == curVehicle then return end
			local curVehicleParent = curVehicle:GetParent()
			if IsValid(curVehicleParent) && ent == curVehicleParent then return end
		end
		
		-- Determine the main position and ensure that it stays within the screen bounds
		local pos = ent:LocalToWorld(ent:OBBMaxs()):ToScreen()
		pos.x = math_clamp(pos.x, 40, srcW - 230)
		pos.y = math_clamp(pos.y, 40, srcH - 210)
		
		//if pos.visible then -- No longer needed!
		net.Start("vj_hud_ent_info")
		net.WriteEntity(ent)
		net.SendToServer()
		
		local ent_hp = ply:GetNW2Int("vj_hud_trhealth")
		local ent_hpMax = ply:GetNW2Int("vj_hud_trmaxhealth")
		local ent_hpDraw = !ent:IsWorld() && !ent:IsVehicle() && ent_hp != 0
		local ent_isNPC = ent:IsNPC()
		
		local npc_info = string_Explode("|", ply:GetNW2String("vj_hud_tr_npc_info"))
		local npc_boss = npc_info[1]
		local npc_disp = tonumber(npc_info[2])
		local npc_guard = npc_info[3]
		local npc_medic = npc_info[4]
		local npc_controlled = npc_info[5]
		local npc_iscontroller = npc_info[6]
		local npc_following = npc_info[7]
		local npc_followingn = npc_info[8]
		
		-- Don't trace the NPC we are controlling!
		if ent_isNPC && npc_iscontroller == "1" then
			return
		end
		
		draw.SimpleText(language.GetPhrase(ent:GetClass()), "VJBaseMedium", pos.x, pos.y - 12, color_white, 0, 0)
		draw.SimpleText(tostring(ent), "VJBaseSmall", pos.x, pos.y + 10, color_white_muted, 0, 0)
		
		-- Move the position up if we are not drawing the health bar
		if !ent_hpDraw then
			pos.y = pos.y - 20
		end
		
		if ent_isNPC then
			local npc_spacing = 0 -- How many spaces (left-right) should it move
			draw.RoundedBoxEx(box_roundness, pos.x, pos.y + 48, 190, 34, color_box, !ent_hpDraw, !ent_hpDraw, true, true)
			
			-- Disposition
			local npc_disp_t = "ER"
			local npc_disp_color = color_white
			if npc_disp == 1 then
				npc_disp_color = color_red
				npc_disp_t = "HT"
			elseif npc_disp == 2 then
				npc_disp_color = color_orange
				npc_disp_t = "FR"
			elseif npc_disp == 3 then
				npc_disp_color = color_green
				npc_disp_t = "LI"
			elseif npc_disp == 4 then
				npc_disp_color = color_orange
				npc_disp_t = "NU"
			elseif npc_disp == D_VJ_INTEREST then
				npc_disp_color = color_orange_muted
				npc_disp_t = "IN"
			end
			npc_spacing = draw.SimpleText(npc_disp_t, "VJBaseMedium", pos.x + 5, pos.y + 55, npc_disp_color, 0, 0) + 12
			
			-- Boss Icon
			if npc_boss == "1" then
				surface.SetMaterial(mat_boss)
				surface.SetDrawColor(50, 50, 50, 150)
				surface.DrawTexturedRect(pos.x + npc_spacing - 2, pos.y + 55 - 2, 26, 26)
				surface.SetDrawColor(color_red)
				surface.DrawTexturedRect(pos.x + npc_spacing, pos.y + 55, 22, 22)
				npc_spacing = npc_spacing + 32
			end
			
			-- Guarding
			if npc_guard == "1" then
				surface.SetMaterial(mat_guarding)
				surface.SetDrawColor(50, 50, 50, 150)
				surface.DrawTexturedRect(pos.x + npc_spacing - 2, pos.y + 55 - 2, 26, 26)
				surface.SetDrawColor(102, 178, 255, 255)
				surface.DrawTexturedRect(pos.x + npc_spacing, pos.y + 55, 22, 22)
				npc_spacing = npc_spacing + 32
			end
			
			-- Medic
			if npc_medic == "1" then
				surface.SetMaterial(mat_medic)
				surface.SetDrawColor(50, 50, 50, 150)
				surface.DrawTexturedRect(pos.x + npc_spacing - 2, pos.y + 55 - 2, 26, 26)
				surface.SetDrawColor(200, 255, 153, 255)
				surface.DrawTexturedRect(pos.x + npc_spacing, pos.y + 55, 22, 22)
				npc_spacing = npc_spacing + 32
			end
			
			-- Controlled
			if npc_controlled == "1" then
				surface.SetMaterial(mat_controller)
				surface.SetDrawColor(50, 50, 50, 150)
				surface.DrawTexturedRect(pos.x + npc_spacing - 2, pos.y + 55 - 2, 26, 26)
				surface.SetDrawColor(255, 213, 0, 255)
				surface.DrawTexturedRect(pos.x + npc_spacing, pos.y + 55, 22, 22)
				npc_spacing = npc_spacing + 32
			end
			
			-- Following Player
			if npc_following == "1" then
				surface.SetMaterial(mat_following)
				surface.SetDrawColor(50, 50, 50, 150)
				surface.DrawTexturedRect(pos.x - 2, pos.y + 83, 34, 34)
				surface.SetDrawColor(221, 160, 221, 255)
				surface.DrawTexturedRect(pos.x, pos.y + 85, 30, 30)
				draw.SimpleText(npc_followingn, "VJBaseMedium", pos.x + 34, pos.y + 88, color(221, 160, 221, 255), 0, 0)
			end
		end
		
		-- Health bar
		if ent_hpDraw then
			local entIndex = ent:EntIndex()
			if lerp_trace_hp_entid != entIndex then lerp_trace_hp = ent_hpMax end
			lerp_trace_hp_entid = entIndex
			lerp_trace_hp = Lerp(8 * FrameTime(), lerp_trace_hp, ent_hp)
			local hp_box = (190 * math_clamp(lerp_trace_hp, 0, ent_hpMax)) / ent_hpMax
			local hp_num = (surface.GetTextSize(ent_hp .. "/" .. ent_hpMax)) / 2
			local hp_numformat = "/" .. ent_hpMax
			
			if ent:IsPlayer() then
				hp_box = math_clamp(lerp_trace_hp, 0, 100) * 1.9
				hp_num = (surface.GetTextSize(ent_hp .. "/100")) / 2
				hp_numformat = "%"
			end
			
			draw.RoundedBox(box_roundness, pos.x, pos.y + 30, 190, 20, color_cyan_muted)
			draw.RoundedBox(box_roundness, pos.x + box_border_thickness, pos.y + 30 + box_border_thickness, 190 - box_border_thickness_adjusted, 20 - box_border_thickness_adjusted, color_under)
			draw.RoundedBox(box_roundness, pos.x + box_border_thickness, pos.y + 30 + box_border_thickness, hp_box - box_border_thickness_adjusted, 20 - box_border_thickness_adjusted, color_cyan_muted)
			draw.SimpleText(string.format("%.0f",  lerp_trace_hp) .. hp_numformat,  "VJBaseSmall", (pos.x + 105) - hp_num, pos.y + 31, color_white)
		end
	end
	//end
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
	npc_rollermine = {Anoon = "Rollermine!", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1), Negar = mat_skull},
	grenade_helicopter = {Anoon = "Bomb!", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1), Negar = mat_skull},
}
local grenadeObj = {Anoon = "Grenade!", Heravorutyoun = 400, DariKouyn = color(255, 0, 0, -1), Negar = mat_grenade}

local function VJ_HUD_Scanner(ply, curTime, srcW, srcH)
	if vj_hud_scanner:GetInt() == 0 then return end
	local blinkAlpha = math_abs(math_sin(curTime * 5) * 255)
	local plyPos = ply:GetPos()
	for _, ent in ipairs(ents.FindInSphere(plyPos, 320)) do
		local entInfo = AbranknerVorKedne[ent:GetClass()]
		if ent.VJ_ID_Grenade && !entInfo then -- Check for grenade tag if no entity is found
			entInfo = grenadeObj
		end
		if entInfo then
			local dist = plyPos:Distance(ent:GetPos())
			if dist < entInfo.Heravorutyoun then
				local startPos = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
				local matColor = (entInfo.DariKouyn.a == -1 and color(entInfo.DariKouyn.r, entInfo.DariKouyn.g, entInfo.DariKouyn.b, blinkAlpha)) or entInfo.DariKouyn
				draw.SimpleText(entInfo.Anoon, "VJBaseMedium", startPos.x + 1, startPos.y + 1, matColor, 0, 0)
				draw.SimpleText(convertToRealUnit(dist), "HudHintTextLarge", startPos.x + 30, startPos.y + 25, color_white, 0, 0)
				
				-- Goghme negar ge tsetsen e
				surface.SetMaterial(entInfo.Negar)
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
	if vj_hud_enabled:GetInt() != 0 && cl_drawhud:GetInt() == 1 then
		local ply = LocalPlayer()
		local curTime = CurTime()
		local srcW = ScrW()
		local srcH = ScrH()
		local plyAlive = ply:Alive()
		usingMetric = vj_hud_metric:GetInt()
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
---------------------------------------------------------------------------------------------------------------------------------------------
-- Control GMod's default HUD elements
hook.Add("HUDShouldDraw", "vj_hud_hidegmod", function(name)
	if vj_hud_disablegmod:GetInt() == 1 && defaultHUD_Elements[name] then return false end
	if vj_hud_disablegmodcross:GetInt() == 1 && defaultCH_Elements[name] then return false end
end)