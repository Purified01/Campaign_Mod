-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/DefaultLandScript.lua#137 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, Inc.
--
--
--  *****           **                          *                   *
--  *   **          *                           *                   *
--  *    *          *                           *                   *
--  *    *          *     *                 *   *          *        *
--  *   *     *** ******  * **  ****      ***   * *      * *****    * ***
--  *  **    *  *   *     **   *   **   **  *   *  *    * **   **   **   *
--  ***     *****   *     *   *     *  *    *   *  *   **  *    *   *    *
--  *       *       *     *   *     *  *    *   *   *  *   *    *   *    *
--  *       *       *     *   *     *  *    *   *   * **   *   *    *    *
--  *       **       *    *   **   *   **   *   *    **    *  *     *   *
-- **        ****     **  *    ****     *****   *    **    ***      *   *
--                                          *        *     *
--                                          *        *     *
--                                          *       *      *
--                                      *  *        *      *
--                                      ****       *       *
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
-- C O N F I D E N T I A L   S O U R C E   C O D E -- D O   N O T   D I S T R I B U T E
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/DefaultLandScript.lua $
--
--    Original Author: Eric Yiskis
--
--            $Author: Joe_Howes $
--
--            $Change: 90634 $
--
--          $DateTime: 2008/01/09 14:38:51 $
--
--          $Revision: #137 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")
require("PGMovieCommands")
require("PGAchievementAward")
require("PGOnlineAchievementDefs")
require("PGVictoryConditionDefs")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")


-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Define_Starting_Forces()
	StartingForces = { 
		[Find_Player("Alien").Get_Faction_Name()] = {
			"ALIEN_ARRIVAL_SITE",
			"ALIEN_GLYPH_CARVER",
		},
		[Find_Player("Novus").Get_Faction_Name()] = {
			"NOVUS_REMOTE_TERMINAL",
			"NOVUS_CONSTRUCTOR",
		},
		[Find_Player("Masari").Get_Faction_Name()] = {
			"MASARI_FOUNDATION",
			"MASARI_ARCHITECT",
		},
		[Find_Player("Military").Get_Faction_Name()] = {
			"MILITARY_HUMMER",
			"MILITARY_HUMMER",
			"MILITARY_HUMMER",
		},
	}
end


-- -------------------------------------------------------------------------------------------------
-- Sample functions for tutorial controls KDB 07-31-2007
-- -------------------------------------------------------------------------------------------------

function Radar_Map_Left_Clicked()
	local dummy = 0.0
end

function Radar_Map_Right_Clicked()
	local dummy = 0.0
end

function Map_Mouse_Wheel_Rotate()
	local dummy = 0.0
end

function Map_Mouse_Wheel_Zoom(zoom_in)
	if zoom_in then
		local dummy = 0.0
	else
		local dummy = 0.0
	end
end

function Map_Mouse_Wheel_Press()
	local dummy = 0.0
end

function Map_Right_Click_Scroll()
	local dummy = 0.0
end

-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Create_Forces(player, marker)
	local ftable = StartingForces[player.Get_Faction_Name()]
	
	SyncMessageNoStack("Create_Forces -- %s at %s\n", tostring(player), tostring(marker))
	
	for index, unit in pairs(ftable) do
		--Make sure the first object (ought to be the command center) goes directly at
		--the marker position (final parameter to spawn)
		Spawn_Unit(Find_Object_Type(unit), marker, player, true, index ~= 1)
	end
end



-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Look_At_Starting_Marker(players_to_markers)
	_Look_At_Starting_Marker(players_to_markers)
end



-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Setup_Teams()
	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then return end

	local ctable = scoring_script.Call_Function("Get_Player_Info_Table")
	Teams = {}

	if ctable == nil or ctable.ClientTable == nil then return end

	-- Split the client table into seperate teams.
	for idx, client in pairs(ctable.ClientTable) do
      if Teams[client.team] == nil then
			Teams[client.team] = {}
		end
		table.insert(Teams[client.team], client)
	end
end

-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Set_Player_Alliances()
	-- Iterate the teams...
	for team_id, members in pairs(Teams) do
		-- Iterate the members of each team...
		for _, client in pairs(members) do
			local player = Find_Player(client.PlayerID)
			-- Make us friendly with our teammates...
			for _, other_client in pairs(members) do
				if other_client ~= client then
					local other_player = Find_Player(other_client.PlayerID)
					player.Make_Ally(other_player);
				end
			end

			-- Make us enemies with the other teams.
			for _, other_members in pairs(Teams) do
				if other_members ~= members then
					for _, other_client in pairs(other_members) do
						local other_player = Find_Player(other_client.PlayerID)
						player.Make_Enemy(other_player);
					end
				end
			end
		end
	end
end



-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Setup_Teams_For_Campaign_Game()
	--One player per faction right now
	local max_players = 7
	Teams = {}
	for i = 0, max_players - 1 do
		Teams[i] = {}
		local player = {}
		player.PlayerID = i
		table.insert(Teams[i], player)
	end
end



-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Cache_Walkers()
	local type = Find_Object_Type("Alien_Walker_Habitat")
	if type then type.Load_Assets() end
	type = Find_Object_Type("Alien_Walker_Assembly")
	if type then type.Load_Assets() end
	type = Find_Object_Type("Alien_Walker_Science")
	if type then type.Load_Assets() end
end




-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Network_Game_Setup()
	local max_players = 16
	local max_markers = 8

	local players = {}
	local markers = {}

	scoring_script = Get_Game_Scoring_Script()

	if scoring_script and scoring_script.Get_Variable("CampaignGame") == true then 
		Setup_Teams_For_Campaign_Game()
		return 
	end

	Define_Starting_Forces()
	Setup_Teams()
	Set_Player_Alliances()
	
	-- Build marker table
	for i = 0, max_markers-1 do
		local marker = Find_First_Object("Marker_Player_" .. i .. "_Start")
		if (TestValid(marker)) then
			markers[i] = marker
		end
	end
	
	-- Build player table
	for i = 0, max_players-1 do
		local player = Find_Player(i)
		if player == nil or (player.Is_Human() == false and player.Is_AI_Player() == false) then break end
		if Is_Player_Of_Faction(player, "alien") then found_alien = true end
		players[i] = player
	end

	if found_alien then
		Cache_Walkers()
	end

	-- [6/16/2007  JLH]: Until now we've just assigned players to markers based on
	-- corresponding marker/player IDs.  If a map has it's start marker position data
	-- properly saved out, we will instead use the new method of assigning start positions
	-- based on player preference, otherwise we just default to the old method.
	local using_explicit_start_positions = false
	local script_data = scoring_script.Call_Function("Get_Game_Script_Data_Table")
	if (script_data and (script_data.start_positions ~= nil)) then
		using_explicit_start_positions = true
	end
	

	local players_to_markers = {}
	
	-- Build a lookup of start markers which are unclaimed and will be used as a pool of random-available.
	local unclaimed_start_markers = {}
	for index, marker in pairs(markers) do
		local claimed = false
		if (using_explicit_start_positions) then
			for _, marker_id in pairs(script_data.start_positions) do
				if (marker_id == index) then
					claimed = true
					break
				end
			end
		end
		if (not claimed) then
			table.insert(unclaimed_start_markers, index)
		end
	end
	
	-- Create forces for each player at the specified marker.
	for _, player in pairs(players) do
	
		local marker = nil
	
		if (using_explicit_start_positions) then
		
			-- Players have chosen their start locations
			local marker_id = script_data.start_positions[player.Get_ID()]
			if (marker_id < 0) then
				-- This player didn't choose a start position, so we'll assign a random one.
				marker_id = Get_Random_Table_Value(unclaimed_start_markers)
				DebugMessage("LUA_GAME:  Player " .. tostring(player.Get_ID()) .. " needs a random start position.")
				--_CustomScriptMessage("CTWLog.txt", "LUA_GAME:  Player " .. tostring(player.Get_ID()) .. " needs a random start position.")
			end
				
			marker = markers[marker_id]
			
			-- store this back in the game script data
			script_data.start_positions[player.Get_ID()] = marker_id;
			
			DebugMessage("LUA_GAME:  Player " .. tostring(player.Get_ID()) .. " -> Marker " .. tostring(marker_id))
			--_CustomScriptMessage("CTWLog.txt", "LUA_GAME:  Player " .. tostring(player.Get_ID()) .. " needs a random start position.")
			
		else
			-- Automated (totally random) start positions.
			--marker = markers[player.Get_ID()]
			marker_id = Get_Random_Table_Value(unclaimed_start_markers)
			marker = markers[marker_id]
		end
		
		players_to_markers[player] = marker
			
		if (marker) then
			Create_Forces(player, marker)
		else 
			OutputDebug("Error -- Unable to find marker for player %d", player.Get_ID())
		end
		
	end
	
	-- Send the game script data table back to code so we can save it for replays
	scoring_script.Call_Function("Set_Game_Script_Data_Table", script_data)
	
	Create_Thread("Look_At_Starting_Marker", players_to_markers) --{ptable, markers} )
	
end

---------------------------------------------------------------------------------------------------

function Get_Random_Table_Value(target_table)

	if ((table == nil) or (#target_table <= 0)) then
		return -1
	end
	
	local min = 1
	local max = #target_table
	DebugMessage("LUA_GAME:  Min: " .. tostring(min) .. ",  Max: " .. tostring(max))
	--_CustomScriptMessage("CTWLog.txt", "LUA_GAME:  Min: " .. tostring(min) .. ",  Max: " .. tostring(max))
	local index = GameRandom(min, max)
	local value = target_table[index]
	DebugMessage("LUA_GAME:  Randomly chose index: " .. tostring(index) .. " -> " .. tostring(value))
	--_CustomScriptMessage("CTWLog.txt", "LUA_GAME:  Randomly chose index: " .. tostring(index) .. " -> " .. tostring(value))
	table.remove(target_table, index)
	return value
	
end


---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	
	Define_State("State_Init", State_Init)
	
	ClosedHuds = false
	IsGameInitialized = false
	IsEndMissionCalled = false
	Register_Game_Scoring_Commands()
	
end

---------------------------------------------------------------------------------------------------

function Close_All_Huds(were_huds_open)
	ClosedHuds = were_huds_open[1]
end



-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function movie_thread()
	local thumper_list = {}

	while true do
		Sleep(3)
		found_list = Find_All_Objects_Of_Type("Military_Hero_Tank")
		for i,thumper in pairs(found_list) do

			if thumper_list[thumper] == nil then
				thumper_list[thumper] = true
				BlockOnCommand(Start_Hero_Movie(thumper, "PetroglyphLogo"))
			end
		end
	end
end



-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Run_Cinematic_Benchmark()
	local bench_name = GlobalValue.Get("BenchName")
	if bench_name then
		Start_Cinematic_From_File(bench_name)
	end
end



-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Initialize_Persistence_Based_State()
	local region = Get_Conflict_Location()
	if TestValid(region) then
		local invader = Get_Current_Conflict_Enemy_Player(region.Get_Owner())
		if region.Get_Strategic_FOW_Level(invader) > 0 then
			Create_Thread("Strategic_Spy_FOW_Reveal", invader)
		end
	end
end



-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Strategic_Spy_FOW_Reveal(player)
	local revealed_cells = FogOfWar.Reveal_All(player)
	Sleep(60)
	revealed_cells.Undo_Reveal()
end


-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function State_Init(message)

	if message == OnEnter then
	
		-- Make sure we are not letterboxed to begin with
		Letter_Box_Out(0)
		Lock_Controls(0)
		
		--jdg taking away fake hero(es)
		fake_alien_hero = Find_First_Object("Fake_Alien_Hero")
		if not TestValid(fake_alien_hero) then
			--_CustomScriptMessage("JoeLog.txt", string.format("ERROR!! DefaultLandScript.lua cannot find fake_alien_hero"))
		else
			_CustomScriptMessage("JoeLog.txt", string.format("DefaultLandScript fake_alien_hero.Despawn()"))
			fake_alien_hero.Despawn()
		end
	
		Initialize_Game()
		
		Sleep(0.01)
		if (DEFCONEnabled) then
			if (not DEFCONRunning) then
				DEFCONRunning = true
				Service_DEFCON()
			end
		end

	elseif message == OnUpdate then

		if Is_Campaign_Game() then
			-- KDB Just in case there are no enemy units in a region do a check after 15 seconds
			if VictoryCheckTime == nil then
				VictoryCheckTime = GetCurrentTime() + 15.0
			elseif VictoryCheckTime > 0.0 and GetCurrentTime() > VictoryCheckTime then
				Test_For_Victory_Event_Based()
				VictoryCheckTime = -1.0
			end
		end
	
		Test_For_Victory_Periodic()

		-- [07/24/2007 JLH]: If this is a DEFCON game, we want to make sure 
		-- DEFCON is running after everything is initialized.  We have to 
		-- make sure to manually call Service_DEFCON() once and only once, 
		-- because after the first call it will schedule itself 
		-- automatically for the remainder of the game.
	
	end
	
end
	
-------------------------------------------------------------------------------
-- JLH 07-20-2007
-------------------------------------------------------------------------------
function Initialize_Game()

	-- Guard this function from multiple calls.
	if (IsGameInitialized) then
		return
	end

	IsGameInitialized = true
	
	Run_Cinematic_Benchmark()
	Network_Game_Setup()
	Initialize_Medals()		-- Note this *MUST* be called at all times, regardless of context.
	Initialize_Victory_Monitoring()
	Initialize_DEFCON()
	
	if Is_Campaign_Game() then
		Initialize_Persistence_Based_State()
	end

	-- If this is a global conquest game, inform the game scoring manager.
	local is_gc, scoring_script, script_data, client_region_data = Process_GC_Data()
	
	Fade_Screen_Out(0)
	Fade_Screen_In(1.0)

	--[[
	Sleep(5)
	-- Create_Thread("movie_thread")

	local alien_hero = Find_First_Object("Alien_Hero_Kamal_Rex")
	if TestValid(alien_hero) then
		alien_hero.Register_Signal_Handler(Callback_Alien_Hero_Killed, "OBJECT_HEALTH_AT_ZERO")
	end
	local novus_hero = Find_First_Object("Novus_Hero_Mech")
	if TestValid(novus_hero) then
		novus_hero.Register_Signal_Handler(Callback_Novus_Hero_Killed, "OBJECT_HEALTH_AT_ZERO")
	end
	-- Objectives_Test()--]]
	
	local global_script = Get_Game_Mode_Script("Strategic")
	if TestValid(global_script) then
		Script.Set_Async_Data("IsScenarioCampaign", global_script.Get_Async_Data("IsScenarioCampaign"))
	else	
		Script.Set_Async_Data("IsScenarioCampaign", false)
	end
	
	-- this displays the hints for how to use transports and research trees in the masari campaign
	if Is_Campaign_Game() and not Is_Scenario_Campaign() then
		Create_Thread("Masari_Story_Campaign_Tactical_Hints")
		Create_Thread("Masari_Story_Campaign_Attribute_Modifiers")
		Create_Thread("Thread_Masari_Story_Campaign_Limit_Income")
	end
	
end

-- this is a special function that only runs inside the masari story campaign
-- it cripples the alien ai by limiting its income so that noob players can win
function Thread_Masari_Story_Campaign_Limit_Income()
   local region = Get_Conflict_Location()
  	local object_type_region16 = Find_Object_Type("Region16")
  	local object_type_region20 = Find_Object_Type("Region20")
  	local object_type_region18 = Find_Object_Type("Region18")

  	local object_type_region29 = Find_Object_Type("Region29")
  	local object_type_region30 = Find_Object_Type("Region30")
  	local object_type_region31 = Find_Object_Type("Region31")

   if region.Get_Type() == object_type_region16 or region.Get_Type() == object_type_region20 or region.Get_Type() == object_type_region18 then
      Create_Thread("Thread_Masari_Story_Campaign_Limit_Income_Loop",4000)
   elseif region.Get_Type() == object_type_region29 or region.Get_Type() == object_type_region30 or region.Get_Type() == object_type_region31 then
      Create_Thread("Thread_Masari_Story_Campaign_Limit_Income_Loop",7000)
   else
      Create_Thread("Thread_Masari_Story_Campaign_Limit_Income_Loop",9000)
   end
end

function Thread_Masari_Story_Campaign_Limit_Income_Loop(income_cap)
   local credits
   local alien_player = Find_Player("Alien")
   while not IsEndMissionCalled and alien_player ~= nil do
      Sleep(5)
		credits = alien_player.Get_Credits()
      if credits > income_cap then
         credits = (credits - income_cap) * -1
         alien_player.Give_Money(credits)
      end
   end
end


-------------------------------------------------------------------------------
-- JGS 06-20-2007
-- This function displays hints in the single player campaign 
-------------------------------------------------------------------------------
function Masari_Story_Campaign_Tactical_Hints()
	
		
	transport=Find_First_Object("MASARI_AIR_INVASION_TRANSPORT_CHAROS")
	if TestValid(transport) then
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		local scene = Get_Game_Mode_GUI_Scene()
		Register_Hint_Context_Scene(scene)			-- Set the scene to which independant hints will be attached.
		
		
		Add_Independent_Hint(HINT_MM02_TRANSPORTS)
		Sleep(2)
		Add_Independent_Hint(HINT_MM02_MISSION_COMPLETE)
		Sleep(2)

		--jdg 7/20/07 adding a research-hint to the button for masari-campaign-sandbox
		local research_button = Find_First_Object("MASARI_Hero_Chief_Scientist_PIP_Only")
		while not TestValid(research_button) do
			Sleep(1)
			_CustomScriptMessage("JoeLog.txt", string.format("DefaultLandScript.lua not TestValid(research_button)"))
		end
		Add_Attached_GUI_Hint(PG_GUI_HINT_HERO_ICON, research_button, HINT_MM02_RESEARCH)
	end
end

function Masari_Story_Campaign_Attribute_Modifiers()
	if true then 
		-- heroes nerfed late, so adding damage modifier, Charos old health(3000) / Charos new health(1000) - 1 = -.67
		charos=Find_First_Object("MASARI_HERO_CHAROS")
		if TestValid(charos) then charos.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.67) end
		-- heroes nerfed late, so adding damage modifier, Zessus old health(2500) / Charos new health(800) - 1 = -.68
		zessus=Find_First_Object("MASARI_HERO_ZESSUS")
		if TestValid(zessus) then zessus.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.68) end
	end
end

-------------------------------------------------------------------------------
-- JLH 01-05-2007
-- Performs all the initialization of medal data including the display
-- of user-selected buffs in the achievement buff window, and actually
-- applying the buff effects to the simulation.
--
-- Note that this function must be called ALWAYS regardless of context so that
-- certain medal effect behaviors are locked on all players.  When medals
-- are applied they get unlocked.
-------------------------------------------------------------------------------
function Initialize_Medals()

	-- Get the game scoring script.
	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then 
		return 
	end
			

	-- If medal buffs are not enabled for this session, all we will do is lock the lockable ones.
	local script_data = scoring_script.Call_Function("Get_Game_Script_Data_Table")
	if (script_data and script_data.medals_enabled) then
		MedalsEnabled = true
	else
		MedalsEnabled = false
	end
	

	-- Lock the unlockable medals on all players.
	local player_data = scoring_script.Call_Function("Get_Player_Info_Table")
	Set_Online_Player_Info_Models(player_data)
	
	
	-- KDB 08-21-2007 lock all player achievements
	-- This is not a good place to lock medals, moved to player_common as this is not always called (i.e. stories etc).
	-- medals if allowed should be put into player_common
	
	if (not MedalsEnabled) then
		return
	end
	

	-- ***** ACHIEVEMENT_MODELS *****
	-- Initialize all the achievement data structures.
	PGAchievementAward_Init()
	PGOnlineAchievementDefs_Init()
	-- ***** ACHIEVEMENT_MODELS *****

	-- ***** ACHIEVEMENT_AWARD_HUD *****
	--[[ JOE DELETE:::  Obsolete
	-- Send off the complete list of all player's multiplayer buffs to the achievement buff window.
	--local model = Get_Achievement_Buff_Display_Model()
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Achievement_Buff_Display_Model", nil, {model})
	-- ***** ACHIEVEMENT_AWARD_HUD *****
	--]]


	-- ***** ACHIEVEMENT_EFFECTS *****
	-- Apply all achievement effects to all players!
	local client_table = scoring_script.Call_Function("Get_Player_Info_Table")
	
	for _, client in pairs(client_table.ClientTable) do
		Apply_Medal_Effects(client)
	end
	
end

-------------------------------------------------------------------------------
-- JLH 07-30-2007
-------------------------------------------------------------------------------
function Apply_Medal_Effects(client)

	-- Never apply medal effects to AI players (they shouldn't have any specified anyway).
	if (client.is_ai) then
		return
	end

	local player = Find_Player(client.PlayerID)
	local position = Create_Position() -- this will create the vector (0,0,0)
		
	-- Iterate each achievement.
	for _, achievement_id in ipairs(client.applied_medals) do
	
		local dao = OnlineAchievementMap[achievement_id]
		local achievement_label = dao.BuffLabel
	
		if ((achievement_label ~= nil) and (achievement_label ~= "NIY")) then
			DebugMessage("LUA_MEDALS:  Creating effect object '" .. tostring(achievement_label) .. "' [ID: " .. tostring(achievement_id) .. "] on player '" .. tostring(client.name) .. "'")
			Create_Generic_Object(Find_Object_Type(achievement_label), position, player)
		end
		
		-- Some buffs have script-only requirements
		if (achievement_id == ACHIEVEMENT_MP_RESEARCHER) then			-- MEDAL:  Researcher
		
			player.Get_Script().Call_Function("Set_Research_Time_Modifier", dao.BuffValue)
			
		elseif (achievement_id == ACHIEVEMENT_MP_UNLIMITED_POWER) then	-- MEDAL:  Modular Proficiency
		
			player.Add_To_Elemental_Mode_Speed_Modifer(dao.BuffValue)
			
		end
		
	end
		
end

-------------------------------------------------------------------------------
-- JLH 05-09-2007
-------------------------------------------------------------------------------
function Initialize_DEFCON()

	DEFCONEnabled = false
	DEFCONRunning = false
	
	-- If we can't get the scoring script, leave DEFCON disabled.
	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then return end

	-- Is DEFCON enabled from the lobby?
	local script_data = scoring_script.Call_Function("Get_Game_Script_Data_Table")
	if script_data and script_data.is_defcon_game then
		DEFCONEnabled = true
	end
	
	-- [07/24/2007 JLH] NOTE::  DEFCON mode is automatically detected in the player scripts in
	-- Research_Common.lua
	
	if (not DEFCONEnabled) then
		return
	end

	-- Constants
	DEFCON_LEVEL_LOW = 1
	DEFCON_LEVEL_HIGH = 5
	
	-- Maria 07.25.2007: When adjusting this value, please make sure to adjust its equivalent values in Research_Common.lua and Generic_Packaged_Research_Scene.lua.
	-- IMPORTANT: please pay attention to the comment on the defintion of this variable in the aforementioned scripts!.
	DEFCON_COUNTDOWN = 120		-- In seconds

	-- Variables
	NextDEFCONLevel = DEFCON_LEVEL_HIGH
	NextDEFCONTechLevel = 1

	NUMBER_OF_SUITES_PER_RESEARCH_PATH = 4
	--[[JOE DELETE
	-- MAKE SURE THIS IS LAST:  Repeat until we issue a Cancel_Timer on this funciton
	Register_Timer(Service_DEFCON, DEFCON_COUNTDOWN)--]]
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("DEFCON_Set_Enabled", nil, {true})
	
end


-------------------------------------------------------------------------------
-- Notify_Player_Defcon_Level_Start (Maria)
-------------------------------------------------------------------------------
function Notify_Player_Defcon_Level_Start(defcon_lvl, player)
	
	if defcon_lvl == DEFCON_LEVEL_HIGH then
		Raise_Game_Event("MP_Defcon_Start", player, nil, nil)
	else
		local defcon_event_name = "MP_Defcon_"..defcon_lvl
		Raise_Game_Event(defcon_event_name, player, nil, nil)
	end
end

-------------------------------------------------------------------------------
-- JLH 05-09-2007
-------------------------------------------------------------------------------
function Service_DEFCON()

	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then 
		DebugMessage("LUA_DEFCON: ERROR: Service DEFCON could not get the scoring script.")
		return 
	end
	
	-- For each player, start the next research layer (if applicable) and notify of the level advancement
	local ctable = scoring_script.Call_Function("Get_Player_Info_Table")
	for idx, client in pairs(ctable.ClientTable) do
		local player = Find_Player(client.PlayerID)
		
		-- Start research only if we are not at the last defcon level for there are only 4 levels of research!.
		if NextDEFCONTechLevel <= NUMBER_OF_SUITES_PER_RESEARCH_PATH then	
			player.Get_Script().Call_Function("Set_Current_DEFCON_Level", NextDEFCONTechLevel)
			
			local node_info = 
			{
				"A",
				NextDEFCONTechLevel
			}
			
			-- Maria: NOTE: by calling Start_Research we make sure the research tree scene is updated as 
			-- research progresses!.
			player.Get_Script().Call_Function("Start_Research", node_info)
			node_info[1] = "B"
			player.Get_Script().Call_Function("Start_Research", node_info)
			node_info[1] = "C"
			player.Get_Script().Call_Function("Start_Research", node_info)		
		end
		
		-- Send SFX notification of DEFCON level advancement.
		Notify_Player_Defcon_Level_Start(NextDEFCONLevel, player)		
	end
	
	-- Update the view layer.
	local data_model = 
	{
		NextDEFCONLevel,
		DEFCON_COUNTDOWN
	}
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("DEFCON_Set_Model", nil, {data_model})
	
	NextDEFCONLevel = NextDEFCONLevel - 1
	NextDEFCONTechLevel = NextDEFCONTechLevel + 1
	
	-- If we're not at DEFCON 1, schedule another timer.
	if (NextDEFCONLevel >= DEFCON_LEVEL_LOW) then
		Register_Timer(Service_DEFCON, DEFCON_COUNTDOWN)
	end	
end


-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Set_Multiplayer_Client_Models(player_info_models)
	Set_Online_Player_Info_Models(player_info_models)
end


-- -------------------------------------------------------------------------------------------------
-- Test/Demo the objectives API
-- -------------------------------------------------------------------------------------------------
function Objectives_Test()
	Sleep(1)
	o1 = Add_Objective("Take a fleet to California")
	o2 = Add_Objective("Find the crashed UFO")
	o3 = Add_Objective("Kill 5 grays")
	local i = 5
	while i>0 do
		local plural = ""
		if i > 1 then plural = "s" end
		text = string.format("Kill %d gray%s", i, plural)
		Set_Objective_Text(o3, text)
		Sleep(2)
		i = i-1
	end
	Set_Objective_Checked(o3, true)
	Set_Objective_Text(o3, "Kill 5 grays")
	Sleep(1)
	Set_Objective_Checked(o2, true)
	Set_Objective_Checked(o1, true)
	Sleep(1)
	Delete_Objective(o3)
	Sleep(1)
	Delete_Objective(o1)
	Sleep(1)
	Delete_Objective(o2)
end


-------------------------------------------------------------------------------
-- ***** ACHIEVEMENT_AWARD *****
-------------------------------------------------------------------------------
function Callback_Alien_Hero_Killed()
	local player_id = Get_Player_By_Faction("Novus")
end

-------------------------------------------------------------------------------
-- ***** ACHIEVEMENT_AWARD *****
-------------------------------------------------------------------------------
function Callback_Novus_Hero_Killed()
	local player_id = Get_Player_By_Faction("Alien")
end


-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Force_Victory(player)
	Persist_Online_Achievements()
	End_Mission(player)
end

-- ***** ACHIEVEMENT_AWARD *****
-- Can't do this here as it will cause an OOS at the end of a multiplayer game.  Need to move the display of this
-- into the Simple_Battle_End_Dialog anyway.  5/28/2007 11:42:42 AM -- BMH
function Show_Earned_Achievements_Thread(map)
	if not Is_Singleplayer_Campaign() then return end

	local dialog = Show_Earned_Offline_Achievements(map[2])
	while (dialog.Is_Showing()) do
		Sleep(1)
	end
	End_Mission(map[1])
end
-- ***** ACHIEVEMENT_AWARD *****

-------------------------------------------------------------------------------
-- It can be possible for End_Mission to be called more than once in some
-- situations, so we'll set up a flag to make sure it is only called once
-- per session.
-------------------------------------------------------------------------------
function End_Mission(player)

	-- Make sure it's only called once!!
	if (IsEndMissionCalled) then
		return
	end
	IsEndMissionCalled = true
	
	if Is_Campaign_Game() then
		
		if not GameOver then
			--Moved Lock_Controls to the spawned thread so it won't happen
			--in response to a quit from the options menu - it was triggering
			--during shutdown and causing the mouse cursor to be gone when
			--returning to the main menu
			GameOver = true
			Create_Thread("Announce_Game_End_Thread", player)
		end
	else
		--Leaving MP/skirmish unchanged for now
		if not GameOver then
			--Moved Lock_Controls to the spawned thread so it won't happen
			--in response to a quit from the options menu - it was triggering
			--during shutdown and causing the mouse cursor to be gone when
			--returning to the main menu
			GameOver = true
			Process_GC_Data(player)
			Create_Thread("Skirmish_Game_End_Thread", player)
	
			local tmp = player.Get_ID()
			Raise_Event_All_Scenes("Multiplayer_Match_Completed", {tmp})
		end
	end	
end


-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Skirmish_Game_End_Thread(winner)
	Lock_Controls(1)
	Letter_Box_In(1)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Skirmish_Game_End_Announcement_Text", nil, {winner} )
	Sleep(4)
	Fade_Screen_Out(1)
	Sleep(1)
	Lock_Controls(0)
	-- params: winning_player, quit_to_main_menu, destroy_loser_forces, build_temporary_command_center, VerticalSliceTriggerVictorySplashFlag, show_fleet_management
	Quit_Game_Now(winner, not Is_Campaign_Game(), true, Is_Campaign_Game(), false, true)
end


-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Announce_Game_End_Thread(winner)
	Lock_Controls(1)
	Letter_Box_In(1)
	local announce_text = nil
	if winner == Find_Player("local") then
		announce_text = Get_Game_Text("TEXT_WIN_TACTICAL")
	else
		announce_text = Get_Game_Text("TEXT_LOSE_TACTICAL")
	end
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {announce_text} )
	local all_units = Find_All_Objects_Of_Type(winner)
	for _, unit in pairs(all_units) do
		unit.Make_Invulnerable(true)
	end
	Sleep(4)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {""} )
	Lock_Controls(0)
	-- params: winning_player, quit_to_main_menu, destroy_loser_forces, build_temporary_command_center, VerticalSliceTriggerVictorySplashFlag, show_fleet_management
	Quit_Game_Now(winner, not Is_Campaign_Game(), true, Is_Campaign_Game(), false, true)
end


-------------------------------------------------------------------------------
-- If winner is nil, we are just going to iterate through the data structure
-- to ensure correctness.  If the winner is non-nil, we are actually awarding 
-- a region and persisting to the backend.
-- The return value can be used to determine if this is a global conquest 
-- game.  Use:
--		local is_gc = Process_GC_Data()
-------------------------------------------------------------------------------
function Process_GC_Data(winner)

	-- Get scoring script.
	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then 
		DebugMessage("LUA_GLOBAL_CONQUEST: Unable to get game scoring script.")
		return false
	end
	
	-- Do we have game script data?
	local script_data = scoring_script.Call_Function("Get_Game_Script_Data_Table")
	if (script_data == nil) then
		DebugMessage("LUA_GLOBAL_CONQUEST: Unable to get game script data.")
		return false, scoring_script
	end
	
	-- Do we have global conquest region data?
	local client_region_data = script_data.client_region_data
	if (client_region_data == nil) then
		DebugMessage("LUA_GLOBAL_CONQUEST: No global conquest data model found.  Assuming non-global conquest game.")
		return false, scoring_script
	end
	
	local result = false
	if (winner ~= nil) then
		result = Process_GC_Endgame(winner, client_region_data)
	else
		result = Validate_GC_Data(client_region_data)
	end
	
	return result, scoring_script, script_data, client_region_data
	
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Process_GC_Endgame(winner, client_region_data)
	
	if (GCEndgameProcessed) then
		return false
	end
	
	_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST:")
	_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: **** PROCESSING NEW ENDGAME ****")
	_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST:")
		
	local winner_id = winner.Get_ID()
	local region_id = client_region_data.contested_region_id
	
	-- Get scoring script.
	local scoring_script = Get_Game_Scoring_Script()
	if (scoring_script == nil) then 
		_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: Unable to get game scoring script.")
		return false
	end
	
	-- Iterate through each player's region data, awarding the region to the winner.
	for common_addr, player_data in pairs(client_region_data.player_models) do
	
		local client = player_data.client_data
		local player_id = client.PlayerID
		local faction_id = client.faction_id
		local region_data = player_data.region_data[faction_id]
		local conquer_count = region_data.MetaData.GlobalConquerCount
		local winner_name_str = tostring(winner.Get_ID())
		local region_name_str = tostring(region_data[region_id].Name)
		
		-- If this player is the winner, award them the region
		if (player_id == winner_id) then
		
			-- *** WINNER ***
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: vvv REGION DUMP vvv")
			for _, region in ipairs(region_data) do
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: WINNER_BEFORE: Region '" .. tostring(region.Name) .. "' -> " .. tostring(region.ConqueredStatus))
			end
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: Conquer Count: " .. (tostring(region_data.MetaData.GlobalConquerCount)))
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: ^^^ REGION DUMP ^^^")
			
			-- Has the player just conquered the last region left on the globe?
			local old_region_state = player_data.region_data[faction_id][region_id].ConqueredStatus
		
			-- Award the region
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: WINNER: Awarding '" .. winner_name_str .. "' region: " .. region_name_str)
			region_data[region_id].ConqueredStatus = true
			
			-- If the region was unconquered before, and now ALL regions are conquered,
			-- then the player has *just* won the globe.
			local globe_conquered = Is_GC_Globe_Conquered(region_data) 
			
			if ((conquer_count < 0) or
				((conquer_count >= 0) and (globe_conquered))) then
				
				if (client.reset_globe) then
					-- The user wants to start a new campaign, so we make sure the conquer_count goes positive.
					if (conquer_count < 0) then
						_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: Player wants to reset the globe.  Resetting...")
						conquer_count = conquer_count * -1
					end
				end
				
			end
		
			if (conquer_count < 0) then
			
				-- A negative conquer count indicates the player has conqeured the globe but has not yet
				-- chosen to reset it.  In this case we just make sure the globe regions are cleared and
				-- the conquer count is negative.
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: Player is playing on a conquered world, so skipping conquer checks.")
				Clear_GC_Globe(region_data)
				
			elseif (not globe_conquered) then
			
				-- The globe is not conquered, just make sure the count is positive.
				region_data.MetaData.GlobalConquerCount = conquer_count

			elseif ((not old_region_state) and globe_conquered) then
			
				-- The globe has just been conquered.  Bump up the conquer count and negate.
				-- JLH: Notify achievements
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: The world has been conquered by " .. winner_name_str .. "!")
				conquer_count = conquer_count + 1	-- Safe here because conquer_count must be >= 0
				region_data.MetaData.GlobalConquerCount = conquer_count * -1
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: Conquer count is now " .. tostring(player_data.region_data[faction_id].MetaData.GlobalConquerCount))
				Clear_GC_Globe(region_data)
				
			elseif (old_region_state and globe_conquered) then
			
				-- If the whole world was conquered before and the whole world is conquered now,
				-- some wierd network problem probably occured and we just need to clear the globe.
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: World was already conquered before.  Clearing globe.")
				Clear_GC_Globe(player_data.region_data[faction_id])
				region_data[region_id].ConqueredStatus = true
				if (conquer_count == 0) then
					conquer_count = 1
					region_data.MetaData.GlobalConquerCount = conquer_count * -1
				end

			end
			
			if (region_data.MetaData.GlobalConquerCount ~= 0) then
				GameScoringManager.Notify_Achievement_System_Of_GC_Globe_Conquered(player_id)
			end
			
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: vvv REGION DUMP vvv")
			for _, region in ipairs(region_data) do
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: WINNER_AFTER: Region '" .. tostring(region.Name) .. "' -> " .. tostring(region.ConqueredStatus))
			end
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: Conquer Count: " .. (tostring(region_data.MetaData.GlobalConquerCount)))
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: ^^^ REGION DUMP ^^^")
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: WINNER: Setting GC props for winner...")
			scoring_script.Call_Function("Set_GC_Props", player_id, common_addr, player_data.region_data)
			
		elseif (player_id ~= winner_id) then
		
			-- *** LOSER ***
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: vvv REGION DUMP vvv")
			for _, region in ipairs(region_data) do
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: LOSER_BEFORE: Region '" .. tostring(region.Name) .. "' -> " .. tostring(region.ConqueredStatus))
			end
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: ^^^ REGION DUMP ^^^")
			
			local difficulty_level = conquer_count
			if (difficulty_level < 0) then
				difficulty_level = difficulty_level * -1
			end
			
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: LOSER lost in region: " .. region_name_str)
			
			if (difficulty_level == 0) then
			
				-- Do nothing
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: LOSER: Difficulty level is 0.  No regions lost.")
				
			elseif (difficulty_level == 1) then
			
				-- Lose a region
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: LOSER: Difficulty level is 1.  1 region lost.")
				Lose_GC_Regions(1, region_id, region_data)
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: LOSER: Setting GC props for loser...")
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: vvv REGION DUMP vvv")
				
			elseif (difficulty_level >= 2) then
			
				-- Lose a region
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: LOSER: Difficulty level is 3.  2 region lost.")
				Lose_GC_Regions(2, region_id, region_data)
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: LOSER: Setting GC props for loser...")
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: vvv REGION DUMP vvv")
				
			end
		
			for _, region in ipairs(region_data) do
				_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: LOSER_AFTER: Region '" .. tostring(region.Name) .. "' -> " .. tostring(region.ConqueredStatus))
			end
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: ^^^ REGION DUMP ^^^")
			_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: LOSER: Setting GC props for loser...")
			scoring_script.Call_Function("Set_GC_Props", player_id, common_addr, player_data.region_data)
				
		end
		
	end
	
	GCEndgameProcessed = true
	return true
	
end
	
function Is_Scenario_Campaign()
	return Script.Get_Async_Data("IsScenarioCampaign")
end
	
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Validate_GC_Data(client_region_data)
	
	-- Iterate through each player's region data.
	for common_addr, player_data in pairs(client_region_data.player_models) do
	
		local client = player_data.client_data
		local player_id = client.PlayerID
		local faction_id = client.faction_id
		
		DebugMessage("LUA_GLOBAL_CONQUEST: VALIDATION: Client '" .. tostring(client.name) .. "'")
		DebugMessage("LUA_GLOBAL_CONQUEST:     player_id: " .. tostring(player_id))
		DebugMessage("LUA_GLOBAL_CONQUEST:     faction_id: " .. tostring(faction_id))
		
		-- Region Statuses
		for  region_id, region in ipairs(player_data.region_data[faction_id]) do
			DebugMessage("LUA_GLOBAL_CONQUEST:     Region " .. tostring(region_id) .. ": " .. tostring(region.ConqueredStatus))
		end
		
	end
	
	return true
	
end
   
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Is_GC_Globe_Conquered(region_data)

	if (region_data == nil) then
		return
	end
	
	for key, region in pairs(region_data) do
		if ((type(key) == "number")  and			-- HACKY:  MetaData field is stored in this table ... ignore it!
			(region.ConqueredStatus ~= nil) and		-- At this point the ConqueredStatus should NEVER be nil.
			(not region.ConqueredStatus)) then
			-- If any region is unconquered, then the globe is unconquered.
			return false
		end 
	end
	
	-- If we get here, there are no unconquered regions.
	return true

end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
function Clear_GC_Globe(region_data)

	if (region_data == nil) then
		return
	end
	
	for key, region in pairs(region_data) do
		if ((type(key) == "number")  and			-- HACKY:  MetaData field is stored in this table ... ignore it!
			(region.ConqueredStatus ~= nil)) then	-- At this point the ConqueredStatus should NEVER be nil.
			region.ConqueredStatus = false
		end
	end
	
end
			
-------------------------------------------------------------------------------
-- The player has lost and we need to revert one or more of their regions
-- to an unconquered state.
-------------------------------------------------------------------------------
function Lose_GC_Regions(num_regions, played_region_id, region_data)

	_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: Unconquering " .. tostring(num_regions) .. " regions.")

	if (num_regions <= 0) then
		return
	end
	
	local count = 0
	
	-- If they were playing in a region they've already conquered, nuke it.
	if (region_data[played_region_id].ConqueredStatus) then
		region_data[played_region_id].ConqueredStatus = false
		count = count + 1
		_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: The played region was conquered, now unconquered.")
	end
	
	if (count >= num_regions) then
		return
	end
	
	-- Put together an iarray of all the conquered regions.
	conquered = {}
	for _, region in pairs(region_data) do
		if (region.ConqueredStatus) then
			table.insert(conquered, region)
		end
	end
	
	-- If there are no conquered regions, we're done.
	if (#conquered <= 0) then
		_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: No more regions can be unconquered.  Exiting...")
		return
	end
	
	-- Now go through and unconquer the rest.
	for i = 1, #conquered do
		_CustomScriptMessage("CTWLog.txt", "LUA_GLOBAL_CONQUEST: Unconquering region '" .. tostring(conquered[i].Name) .. "'")
		conquered[i].ConqueredStatus = false
		count = count + 1
		if (count >= num_regions) then
			break
		end
	end

end

-------------------------------------------------------------------------------
-- Victory condition stuff
-------------------------------------------------------------------------------
function Initialize_Victory_Monitoring()

	Init_Victory_Condition_Constants()
	if Is_Campaign_Game() then
		VictoryCondition = VICTORY_SUB_MODE
	else
		local scoring_script = Get_Game_Scoring_Script()
		VictoryCondition = VICTORY_CONQUER
		VictoryCredits = 25000
		if scoring_script then	
			local script_data = scoring_script.Call_Function("Get_Game_Script_Data_Table")
			if script_data and script_data.victory_condition then
				VictoryCondition = script_data.victory_condition
			end
		end
	end
					
	VictoryRelevantUnits = {}
	
	--Track starting objects that are victory relevant
	for _, members in pairs(Teams) do
		for _, client in pairs(members) do
			local player = Find_Player(client.PlayerID)	
			VictoryRelevantUnits[player.Get_ID()] = {}
			VictoryRelevantUnits[player.Get_ID()].victory_relevant_count = 0			
			
			local all_units_table = Find_All_Objects_Of_Type(player)
			for _, unit in pairs(all_units_table) do
				On_Construction_Complete(unit)
			end
		end
	end
	
end


-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function On_Construction_Complete(object)
	if Is_Victory_Relevant(object) then
		local owner = object.Get_Owner()
		if not VictoryRelevantUnits[owner.Get_ID()] then VictoryRelevantUnits[owner.Get_ID()] = {} end
		if not VictoryRelevantUnits[owner.Get_ID()][object.Get_ID()] then
			VictoryRelevantUnits[owner.Get_ID()].victory_relevant_count = VictoryRelevantUnits[owner.Get_ID()].victory_relevant_count + 1
			VictoryRelevantUnits[owner.Get_ID()][object.Get_ID()] = true
			object.Register_Signal_Handler(On_Victory_Object_Killed, "OBJECT_DELETE_PENDING")
			object.Register_Signal_Handler(On_Victory_Object_Killed, "OBJECT_OWNER_CHANGED")
		end
	end
end


-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function On_Victory_Object_Killed(object, old_owner)
	local owner = object.Get_Owner()
	if old_owner then
		owner = old_owner
	end
	if not VictoryRelevantUnits[owner.Get_ID()] then VictoryRelevantUnits[owner.Get_ID()] = {} end
	
	--In a campaign game, elimination of the HQ in tactical triggers an instant victory.  Check for base type
	--to accomodate wacky factions that do type switching...
	if Is_Campaign_Game() and object.Get_Type().Get_Base_Type() == owner.Get_Faction_Value("Headquarters_Type") then
		VictoryRelevantUnits[owner.Get_ID()][object.Get_ID()] = nil
		VictoryRelevantUnits[owner.Get_ID()].victory_relevant_count = 0
		
		-- Oksana: Notify achievements
		GameScoringManager.Notify_Achievement_System_Of_Player_Elimination(owner)

		Test_For_Victory_Event_Based()
		Notify_Faction_Eliminated(owner)
		return
	end
	
	if VictoryRelevantUnits[owner.Get_ID()][object.Get_ID()] then
		VictoryRelevantUnits[owner.Get_ID()].victory_relevant_count = VictoryRelevantUnits[owner.Get_ID()].victory_relevant_count - 1
		VictoryRelevantUnits[owner.Get_ID()][object.Get_ID()] = nil
		if VictoryRelevantUnits[owner.Get_ID()].victory_relevant_count <= 0 then
			-- Oksana: Notify achievements
			GameScoringManager.Notify_Achievement_System_Of_Player_Elimination(owner)

			Test_For_Victory_Event_Based()
			Notify_Faction_Eliminated(owner)
		end
	end
end



-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Test_For_Victory_Event_Based()
	local surviving_team = nil
	local survivor_is_human = false
	local is_single_player_skirmish = Is_Single_Player_Skirmish()
	for team_id, members in pairs(Teams) do
		for _, client in pairs(members) do
			local player = Find_Player(client.PlayerID)	
			if VictoryRelevantUnits[player.Get_ID()].victory_relevant_count > 0 then
				if not surviving_team or surviving_team == team_id then
					if is_single_player_skirmish then
						if not player.Is_AI_Player() then
							surviving_team = team_id
							survivor_is_human = true
						end
					else
						surviving_team = team_id
						if not player.Is_AI_Player() then
							survivor_is_human = true
						end
					end
				elseif not player.Is_AI_Player() or survivor_is_human then
					--Multiple teams have human players that are still in the game or
					--else the human is still alive and so is at least one enemy AI
					return
				end
			end
		end
	end
	
	--If we get here then at most one team is left alive OR all players left are AI
	if surviving_team == nil then
		-- In a single player skirmish, if there is no human survivor then the local player loses
		if is_single_player_skirmish then
			local local_player_id = Find_Player("local").Get_ID()
			for team_id, members in pairs(Teams) do
				local local_player_found = false
				for _, client in pairs(members) do
					if local_player_id == client.PlayerID then
						local_player_found = true
					end
				end

				-- If the local player was not found in this team, then let this team win
				if not local_player_found then
					surviving_team = team_id
					break
				end
			end
		end

		if surviving_team == nil then
			--No teams with units left??  How??  I give up
			return
		end
	end

	local winner_player = Find_Player(Teams[surviving_team][1].PlayerID)
	End_Mission(winner_player)
	
end



-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Test_For_Victory_Periodic()
	if VictoryCondition ~= VICTORY_RESOURCE_RACE then
		return
	end
	
	local winner_player = nil
	local most_credits = nil
	for team_id, members in pairs(Teams) do
		for _, client in pairs(members) do
			local player = Find_Player(client.PlayerID)	
			local player_credits = player.Get_Credits()
			if player_credits >= VictoryCredits then
				if not most_credits or player_credits > most_credits then
					winner_player = player
				end
			end
		end
	end
	
	if winner_player then
		End_Mission(winner_player)
	end
end



-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Is_Victory_Relevant(object)
	
	if not TestValid(object) then
		return false
	end
	
	if not object.Is_In_Active_Mode() then
		return false
	end
	
	if object.Has_Behavior(BEHAVIOR_FLEET) then
		return false
	end
	
	if object.Has_Behavior(BEHAVIOR_MARKER) then
		return false
	end
	
	if object.Get_Script() and object.Get_Script().Get_Variable("IS_SCIENTIST") then
		return false
	end	
	
	if VictoryCondition == VICTORY_ANNIHILATION then
		return true
	end
	
	if VictoryCondition == VICTORY_SUB_MODE then
		if object.Get_Type().Is_Hero() then
			return true
		end
	end
	
	return object.Get_Type().Is_Victory_Relevant()
end


-- -------------------------------------------------------------------------------------------------
-- 
-- -------------------------------------------------------------------------------------------------
function Notify_Faction_Eliminated(player)
	if not Is_Campaign_Game() then
		Kill_All_Units_Of_Player(player)
		player.Get_Script().Call_Function("Reset_Research")
		local message = Replace_Token(Get_Game_Text("TEXT_TACTICAL_PLAYER_ELIMINATED"), player.Get_Display_Name(), 0)
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {message} )
		--Should find something better to play here.
		Play_SFX_Event("GUI_Generic_Bad_Sound")
		local game_options = GameScoringManager.Get_Game_Options_Table()
		if IsEndMissionCalled then
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
		elseif IsEndMissionCalled == false then
			player.Set_As_Observer()
			RadarMap.Add_Filter("Radar_Map_Enable", player)
			RadarMap.Add_Filter("Radar_Map_Allow_Mouse_Input", player)
			RadarMap.Add_Filter("Radar_Map_Show_Terrain", player)
			RadarMap.Add_Filter("Radar_Map_Show_FOW", player)
			RadarMap.Add_Filter("Radar_Map_Show_Owned", player)
			RadarMap.Add_Filter("Radar_Map_Show_Allied", player)
			RadarMap.Add_Filter("Radar_Map_Show_Enemy", player)
			RadarMap.Add_Filter("Radar_Map_Show_Neutral", player)
		end
	end
end

function Pre_Save_Callback()
	local game_mode_scene = Get_Game_Mode_GUI_Scene()
	if TestValid(game_mode_scene.DEFCON_Overlay) then
		DEFCONDataModel = game_mode_scene.DEFCON_Overlay.Get_Model()
	end
end

function Post_Load_Callback()
	--Make sure that we can still call Game Scoring commands after a load
	Register_Game_Scoring_Commands()

	-- Make sure defcon is running after we load a game
	if (DEFCONEnabled) then
		if (DEFCONRunning) then
			-- Update the view layer.
			if DEFCONDataModel ~= nil then
				-- Do not call DEFCON_Initialize again, but let the game mode gui scene know that it needs to display it
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("DEFCON_Set_Enabled", nil, {true})

				local data_model = 
				{
					DEFCONDataModel.DEFCONLevel,
					DEFCONDataModel.DEFCONCountdown
				}
				DEFCONDataModel = nil
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("DEFCON_Set_Model", nil, {data_model})
			else
				-- Something was wrong with the save... disable DEFCON
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("DEFCON_Set_Enabled", nil, {false})
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- EOF

