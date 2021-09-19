/*--------------------------------------------------
	=============== Language Files ===============
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end

/*
	How it works:
		* Looks for the current set language and translates all the strings that are given.
		* If a string isn't translated, it will automatically default to English.
		* When a updated while in a map, it will try to refresh some of the menus, but many menus requires a map restart!
	
	How to edit & contribute:
		* Make any edits in any language you would like.
		* If a line doesn't exist in your language, then copy & paste it from the default (English) list.
		* Once you are done translating or editing, you can push the edited file on GitHub.
		* Once the file is pushed, I will review it and merge it with the base, it will then be included with the next update on Workshop.
		* NOTE: Over time more lines will be added in the default (English) list. You are welcome to check back whenever and copy & paste any new lines that added and translate it.
	
	Q: I would like to translate and my language isn't listed below =(
	A: No worries! Just simply contact me (DrVrej) and I will set up the profile for your language!
	
	Q: Someone has already translated my language, how can I contribute now?
	A: You can go over the translated lines and fix any errors. You can also compare it with the English version and make sure all lines are translated!
	
	Thank you to all of your contributions everyone!
*/

if CLIENT then
	local function add(name, str) -- Aveli tirountsnelou hamar e
		language.Add(name, str)
	end
	
	function VJ_REFRESH_LANGUAGE()
		local conv = GetConVar("vj_language"):GetString()
		
		-- DEFAULT (English) LIST | Copy & paste any of the lines below to your preferred language to translate it.
		
		-- VJ HUD Settings
		add("vjhud.settings.reset.everything", "Reset Everything")
		add("vjhud.settings.menu", "Client Settings")
		add("vjhud.settings.gmod.hud", "Garry's Mod HUD:")
		add("vjhud.settings.disable.gmod.hud", "Disable Garry's Mod HUD")
		add("vjhud.settings.disable.gmod.crosshair", "Disable Garry's Mod Crosshair")
		add("vjhud.settings.hud", "HUD:")
		add("vjhud.settings.enable.vj.hud", "Enable VJ HUD")
		add("vjhud.settings.enable.health.and.suit", "Enable Health and Suit")
		add("vjhud.settings.enable.ammunition.counter", "Enable Ammunition Counter")
		add("vjhud.settings.enable.local.player.information", "Enable Local Player Information")
		add("vjhud.settings.enable.compass", "Enable Compass")
		add("vjhud.settings.enable.trace.information", "Enable Trace Information")
		add("vjhud.settings.enable.proximity.scanner", "Enable Proximity Scanner")
		add("vjhud.settings.enable.ammunition.counter.in.vehicle", "Enable Ammunition Counter in Vehicle")
		add("vjhud.settings.limited.trace.information", "Limited Trace Information")
		add("vjhud.settings.limited.trace.information.desc", "Will only display for NPCs & Players")
		add("vjhud.settings.use.metric.instead.of.imperial", "Use Metric instead of Imperial")
		add("vjhud.settings.crosshair", "Crosshair:")
		add("vjhud.settings.enable.crosshair", "Enable Crosshair")
		add("vjhud.settings.enable.crosshair.in.vehicle", "Enable Crosshair While in Vehicle")
		add("vjhud.settings.crosshair.material", "Crosshair Material:")
		add("vjhud.settings.crosshair.material.arrow", "Arrow (Two, Default)")
		add("vjhud.settings.crosshair.material.dot", "Dot")
		add("vjhud.settings.crosshair.material.dot.small", "Dot (Five, Small)")
		add("vjhud.settings.crosshair.material.dot.large", "Dot (Five, Large)")
		add("vjhud.settings.crosshair.material.dot.sniper", "Dot (Five, Sniper)")
		add("vjhud.settings.crosshair.material.dot.four", "Dot (Four)")
		add("vjhud.settings.crosshair.material.dot.circle", "Circle")
		
		-- VJ HUD
		add("vjhud.user.dead", "USER DEAD")
		add("vjhud.god.mode.enabled", "God Mode Enabled!")
		add("vjhud.low.health", "WARNING: Low Health!")
		add("vjhud.death.imminent", "WARNING: Death Imminent!")
		add("vjhud.suit", "SUIT")
		add("vjhud.admin.yes", "Admin: Yes")
		add("vjhud.admin.no", "Admin: No")
		add("vjhud.cheats.on", "Cheats: On")
		add("vjhud.cheats.off", "Cheats: Off")
		add("vjhud.npc.ai.on", "NPC AI: On")
		add("vjhud.npc.ai.off", "NPC AI: Off")
			
		if conv == "armenian" then
			
		elseif conv == "russian" then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		elseif conv == "german" then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
		elseif conv == "french" then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
		elseif conv == "lithuanian" then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		elseif conv == "spanish_lt" then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					
		elseif conv == "portuguese_br" then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
		elseif conv == "schinese" then
		
		-- VJ HUD Settings
		add("vjhud.settings.reset.everything", "重置全部")
		add("vjhud.settings.menu", "客户端设置")
		add("vjhud.settings.gmod.hud", "Garry's Mod HUD：")
		add("vjhud.settings.disable.gmod.hud", "禁用 Garry's Mod HUD")
		add("vjhud.settings.disable.gmod.crosshair", "禁用 Garry's Mod 准心")
		add("vjhud.settings.hud", "HUD：")
		add("vjhud.settings.enable.vj.hud", "启用 VJ HUD")
		add("vjhud.settings.enable.health.and.suit", "显示生命值和防护衣")
		add("vjhud.settings.enable.ammunition.counter", "显示弹药")
		add("vjhud.settings.enable.local.player.information", "显示本地玩家信息")
		add("vjhud.settings.enable.compass", "显示指南针")
		add("vjhud.settings.enable.trace.information", "显示准心信息")
		add("vjhud.settings.enable.proximity.scanner", "启用近距离探测器")
		add("vjhud.settings.enable.ammunition.counter.in.vehicle", "在载具中时显示弹药")
		add("vjhud.settings.limited.trace.information", "部分准心信息")
		add("vjhud.settings.limited.trace.information.desc", "仅会显示 NPC 和玩家的信息")
		add("vjhud.settings.use.metric.instead.of.imperial", "使用公制而不是英制")
		add("vjhud.settings.crosshair", "准心：")
		add("vjhud.settings.enable.crosshair", "显示准心")
		add("vjhud.settings.enable.crosshair.in.vehicle", "在载具中时显示准心")
		add("vjhud.settings.crosshair.material", "准心材质：")
		add("vjhud.settings.crosshair.material.arrow", "箭头（两个，默认）")
		add("vjhud.settings.crosshair.material.dot", "点")
		add("vjhud.settings.crosshair.material.dot.small", "点（五个，小型）")
		add("vjhud.settings.crosshair.material.dot.large", "点（五个，大型）")
		add("vjhud.settings.crosshair.material.dot.sniper", "点（五个，狙击型）")
		add("vjhud.settings.crosshair.material.dot.four", "点（四个）")
		add("vjhud.settings.crosshair.material.dot.circle", "圆环")
		
		-- VJ HUD
		add("vjhud.user.dead", "使用者死亡")
		add("vjhud.god.mode.enabled", "无敌模式已开启！")
		add("vjhud.low.health", "警告：低生命值！")
		add("vjhud.death.imminent", "警告：濒临死亡！")
		add("vjhud.suit", "防护衣")
		add("vjhud.admin.yes", "管理员：是")
		add("vjhud.admin.no", "管理员：否")
		add("vjhud.cheats.on", "作弊：开启")
		add("vjhud.cheats.off", "作弊：关闭")
		add("vjhud.npc.ai.on", "NPC AI：开启")
		add("vjhud.npc.ai.off", "NPC AI：关闭")

		end
		end
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ ///// WARNING: Don't touch anything below this line! \\\\\ ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	VJ_REFRESH_LANGUAGE() -- Arachin ankam ganch e, garevor e asiga!
end
