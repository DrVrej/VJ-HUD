/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
------------------ Addon Information ------------------
local AddonName = "VJ HUD"
local AddonType = "HUD"
-------------------------------------------------------
local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua", "GAME")
if VJExists == true then
	include('autorun/vj_controls.lua')

	if CLIENT then
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
		hook.Add("PopulateToolMenu", "VJ_ADDTOMENU_HUD_SETTINGS", function()	
			spawnmenu.AddToolMenuOption("DrVrej", "HUDs", "VJ HUD Settings", "Client Settings", "", "", function(Panel)
				Panel:ControlHelp(" ") -- Spacer
				Panel:AddControl("Button",{Text = "#vjbase.menu.general.reset.everything", Command = "vj_hud_enabled 1\n vj_hud_disablegmod 1\n vj_hud_health 1\n vj_hud_ammo 1\n vj_hud_playerinfo 1\n vj_hud_trace 1\n vj_hud_compass 1\n vj_hud_scanner 1\n vj_hud_metric 0\n vj_hud_disablegmodcross 1\n vj_hud_ch_enabled 1\n vj_hud_ch_crosssize 50\n vj_hud_ch_opacity 255\n vj_hud_ch_r 0\n vj_hud_ch_g 255\n vj_hud_ch_b 0\n vj_hud_ch_mat 0\n vj_hud_ammo_invehicle 1\n vj_hud_ch_invehicle 1\n vj_hud_trace_limited 0"})
				Panel:AddControl("Label", {Text = "Garry's Mod HUD:"})
				Panel:AddControl("Checkbox", {Label = "Disable Garry's Mod HUD", Command = "vj_hud_disablegmod"})
				Panel:AddControl("Checkbox", {Label = "Disable Garry's Mod Crosshair", Command = "vj_hud_disablegmodcross"})
				
				Panel:AddControl("Label", {Text = "HUD:"})
				Panel:AddControl("Checkbox", {Label = "Enable VJ HUD", Command = "vj_hud_enabled"})
				Panel:AddControl("Checkbox", {Label = "Enable Health and Suit", Command = "vj_hud_health"})
				Panel:AddControl("Checkbox", {Label = "Enable Ammunition Counter", Command = "vj_hud_ammo"})
				Panel:AddControl("Checkbox", {Label = "Enable Local Player Information", Command = "vj_hud_playerinfo"})
				Panel:AddControl("Checkbox", {Label = "Enable Compass", Command = "vj_hud_compass"})
				Panel:AddControl("Checkbox", {Label = "Enable Trace Information", Command = "vj_hud_trace"})
				Panel:AddControl("Checkbox", {Label = "Enable Proximity Scanner", Command = "vj_hud_scanner"})
				Panel:AddControl("Checkbox", {Label = "Enable Ammunition Counter in Vehicle", Command = "vj_hud_ammo_invehicle"})
				Panel:AddControl("Checkbox", {Label = "Limited Trace Information", Command = "vj_hud_trace_limited"})
				Panel:ControlHelp("Will only display for NPCs & Players")
				Panel:AddControl("Checkbox", {Label = "Use Metric instead of Imperial", Command = "vj_hud_metric"})
				
				Panel:AddControl("Label", {Text = "Crosshair:"})
				Panel:AddControl("Checkbox", {Label = "Enable Crosshair", Command = "vj_hud_ch_enabled"})
				Panel:AddControl("Checkbox", {Label = "Enable Crosshair While in Vehicle", Command = "vj_hud_ch_invehicle"})
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
			end)
		end)
	end
	
-- !!!!!! DON'T TOUCH ANYTHING BELOW THIS !!!!!! -------------------------------------------------------------------------------------------------------------------------
	AddCSLuaFile()
	VJ.AddAddonProperty(AddonName, AddonType)
else
	if CLIENT then
		chat.AddText(Color(0, 200, 200), AddonName,
		Color(0, 255, 0), " was unable to install, you are missing ",
		Color(255, 100, 0), "VJ Base!")
	end
	
	timer.Simple(1, function()
		if not VJBASE_ERROR_MISSING then
			VJBASE_ERROR_MISSING = true
			if CLIENT then
				// Get rid of old error messages from addons running on older code...
				if VJF && type(VJF) == "Panel" then
					VJF:Close()
				end
				VJF = true
				
				local frame = vgui.Create("DFrame")
				frame:SetSize(600, 160)
				frame:SetPos((ScrW() - frame:GetWide()) / 2, (ScrH() - frame:GetTall()) / 2)
				frame:SetTitle("Error: VJ Base is missing!")
				frame:SetBackgroundBlur(true)
				frame:MakePopup()
	
				local labelTitle = vgui.Create("DLabel", frame)
				labelTitle:SetPos(250, 30)
				labelTitle:SetText("VJ BASE IS MISSING!")
				labelTitle:SetTextColor(Color(255,128,128))
				labelTitle:SizeToContents()
				
				local label1 = vgui.Create("DLabel", frame)
				label1:SetPos(170, 50)
				label1:SetText("Garry's Mod was unable to find VJ Base in your files!")
				label1:SizeToContents()
				
				local label2 = vgui.Create("DLabel", frame)
				label2:SetPos(10, 70)
				label2:SetText("You have an addon installed that requires VJ Base but VJ Base is missing. To install VJ Base, click on the link below. Once\n                                                   installed, make sure it is enabled and then restart your game.")
				label2:SizeToContents()
				
				local link = vgui.Create("DLabelURL", frame)
				link:SetSize(300, 20)
				link:SetPos(195, 100)
				link:SetText("VJ_Base_Download_Link_(Steam_Workshop)")
				link:SetURL("https://steamcommunity.com/sharedfiles/filedetails/?id=131759821")
				
				local buttonClose = vgui.Create("DButton", frame)
				buttonClose:SetText("CLOSE")
				buttonClose:SetPos(260, 120)
				buttonClose:SetSize(80, 35)
				buttonClose.DoClick = function()
					frame:Close()
				end
			elseif (SERVER) then
				VJF = true
				timer.Remove("VJBASEMissing")
				timer.Create("VJBASE_ERROR_CONFLICT", 5, 0, function()
					print("VJ Base is missing! Download it from the Steam Workshop! Link: https://steamcommunity.com/sharedfiles/filedetails/?id=131759821")
				end)
			end
		end
	end)
end