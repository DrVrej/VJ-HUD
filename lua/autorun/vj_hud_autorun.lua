/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
------------------ Addon Information ------------------
local PublicAddonName = "VJ HUD"
local AddonName = "VJ HUD"
local AddonType = "HUD"
local AutorunFile = "autorun/vj_hud_autorun.lua"
-------------------------------------------------------
local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")
if VJExists == true then
	include('autorun/vj_controls.lua')

	if (CLIENT) then
		-- Main Components
		VJ.AddClientConVar("vj_hud_enabled", 1) -- Enable VJ HUD
		VJ.AddClientConVar("vj_hud_health", 1) -- Enable health and suit
		VJ.AddClientConVar("vj_hud_ammo", 1) -- Enable ammo
		VJ.AddClientConVar("vj_hud_ammo_invehicle", 1) -- Should the ammo be enabled in the vehicle?
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
		VJ.AddClientConVar("vj_hud_ch_crosssize", 50) -- Crosshair Size
		VJ.AddClientConVar("vj_hud_ch_opacity", 255) -- Opacity of the Crosshair
		VJ.AddClientConVar("vj_hud_ch_r", 0) -- Crosshair Color - Red
		VJ.AddClientConVar("vj_hud_ch_g", 255) -- Crosshair Color - Green
		VJ.AddClientConVar("vj_hud_ch_b", 0) -- Crosshair Color - Blue
		VJ.AddClientConVar("vj_hud_ch_mat", 0) -- The Crosshair Material

		-- Garry's Mod HUD
		VJ.AddClientConVar("vj_hud_disablegmod", 1) -- Disable Garry's Mod HUD
		VJ.AddClientConVar("vj_hud_disablegmodcross", 1) -- Disable Garry's Mod Crosshair
		
		---------------------------------------------------------------------------------------------------------------------------
		local function VJ_HUD_CLIENT_SETTINGS(Panel)
			Panel:ControlHelp(" ") -- Spacer
			Panel:AddControl("Button",{Text = "#vjhud.settings.reset.everything", Command = "vj_hud_enabled 1\n vj_hud_disablegmod 1\n vj_hud_health 1\n vj_hud_ammo 1\n vj_hud_playerinfo 1\n vj_hud_trace 1\n vj_hud_compass 1\n vj_hud_scanner 1\n vj_hud_metric 0\n vj_hud_disablegmodcross 1\n vj_hud_ch_enabled 1\n vj_hud_ch_crosssize 50\n vj_hud_ch_opacity 255\n vj_hud_ch_r 0\n vj_hud_ch_g 255\n vj_hud_ch_b 0\n vj_hud_ch_mat 0\n vj_hud_ammo_invehicle 1\n vj_hud_ch_invehicle 1\n vj_hud_trace_limited 0"})
			Panel:AddControl("Label", {Text = "#vjhud.settings.gmod.hud"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.disable.gmod.hud", Command = "vj_hud_disablegmod"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.disable.gmod.crosshair", Command = "vj_hud_disablegmodcross"})
			
			Panel:AddControl("Label", {Text = "#vjhud.settings.hud"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.enable.vj.hud", Command = "vj_hud_enabled"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.enable.health.and.suit", Command = "vj_hud_health"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.enable.ammunition.counter", Command = "vj_hud_ammo"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.enable.local.player.information", Command = "vj_hud_playerinfo"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.enable.compass", Command = "vj_hud_compass"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.enable.trace.information", Command = "vj_hud_trace"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.enable.proximity.scanner", Command = "vj_hud_scanner"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.enable.ammunition.counter.in.vehicle", Command = "vj_hud_ammo_invehicle"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.limited.trace.information", Command = "vj_hud_trace_limited"})
			Panel:ControlHelp("#vjhud.settings.limited.trace.information.desc")
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.use.metric.instead.of.imperial", Command = "vj_hud_metric"})
			
			Panel:AddControl("Label", {Text = "#vjhud.settings.crosshair"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.enable.crosshair", Command = "vj_hud_ch_enabled"})
			Panel:AddControl("Checkbox", {Label = "#vjhud.settings.enable.crosshair.in.vehicle", Command = "vj_hud_ch_invehicle"})
			local vj_crossoption = {Options = {}, CVars = {}, Label = "#vjhud.settings.crosshair.material", MenuButton = "0"}
			vj_crossoption.Options["#vjhud.settings.crosshair.material.arrow"] = {
				vj_hud_ch_mat = "0",
			}
			vj_crossoption.Options["#vjhud.settings.crosshair.material.dot.small"] = {
				vj_hud_ch_mat = "1",
			}
			vj_crossoption.Options["#vjhud.settings.crosshair.material.dot"] = {
				vj_hud_ch_mat = "2",
			}
			vj_crossoption.Options["#vjhud.settings.crosshair.material.dot.sniper"] = {
				vj_hud_ch_mat = "3",
			}
			vj_crossoption.Options["Circle (Dashed)"] = {
				vj_hud_ch_mat = "4",
			}
			vj_crossoption.Options["#vjhud.settings.crosshair.material.dot.four"] = {
				vj_hud_ch_mat = "5",
			}
			vj_crossoption.Options["#vjhud.settings.crosshair.material.dot.circle"] = {
				vj_hud_ch_mat = "6",
			}
			vj_crossoption.Options["Line (Four, Angled)"] = {
				vj_hud_ch_mat = "7",
			}
			vj_crossoption.Options["#vjhud.settings.crosshair.material.dot.large"] = {
				vj_hud_ch_mat = "8",
			}
			Panel:AddControl("ComboBox", vj_crossoption)
			Panel:AddControl("Color",{ -- Color Picker
				Label = "Crosshair Color:", 
				Red = "vj_hud_ch_r", -- red
				Green = "vj_hud_ch_g", -- green
				Blue = "vj_hud_ch_b", -- blue
				ShowAlpha = "0", 
				ShowHSV = "1",
				ShowRGB = "1"
			})
			Panel:AddControl("Slider", {Label = "Crosshair Size",min = 0,max = 1000,Command = "vj_hud_ch_crosssize"})
			Panel:AddControl("Slider", {Label = "Crosshair Opacity",min = 0,max = 255,Command = "vj_hud_ch_opacity"})
		end
		----=================================----
		hook.Add("PopulateToolMenu", "VJ_ADDTOMENU_HUD_SETTINGS", function()
			spawnmenu.AddToolMenuOption("DrVrej", "HUDs", "VJ HUD Settings", "#vjhud.settings.menu", "", "", VJ_HUD_CLIENT_SETTINGS, {})
		end)
	end
	
-- !!!!!! DON'T TOUCH ANYTHING BELOW THIS !!!!!! -------------------------------------------------------------------------------------------------------------------------
	AddCSLuaFile(AutorunFile)
	VJ.AddAddonProperty(AddonName,AddonType)
else
	if (CLIENT) then
		chat.AddText(Color(0,200,200),PublicAddonName,
		Color(0,255,0)," was unable to install, you are missing ",
		Color(255,100,0),"VJ Base!")
	end
	timer.Simple(1,function()
		if not VJF then
			if (CLIENT) then
				VJF = vgui.Create("DFrame")
				VJF:SetTitle("ERROR!")
				VJF:SetSize(790,560)
				VJF:SetPos((ScrW()-VJF:GetWide())/2,(ScrH()-VJF:GetTall())/2)
				VJF:MakePopup()
				VJF.Paint = function()
					draw.RoundedBox(8,0,0,VJF:GetWide(),VJF:GetTall(),Color(200,0,0,150))
				end
				
				local VJURL = vgui.Create("DHTML",VJF)
				VJURL:SetPos(VJF:GetWide()*0.005, VJF:GetTall()*0.03)
				VJURL:Dock(FILL)
				VJURL:SetAllowLua(true)
				VJURL:OpenURL("https://sites.google.com/site/vrejgaming/vjbasemissing")
			elseif (SERVER) then
				timer.Create("VJBASEMissing",5,0,function() print("VJ Base is Missing! Download it from the workshop!") end)
			end
		end
	end)
end