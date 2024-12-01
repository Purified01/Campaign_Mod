-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Tutorial_Strategic.lua#16 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Tutorial_Strategic.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: oksana_kubushyna $
--
--            $Change: 85961 $
--
--          $DateTime: 2007/10/15 18:16:12 $
--
--          $Revision: #16 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("RetryMission")
require("PGColors")
require("PGPlayerProfile")
require("PGFactions")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")
ScriptPoolCount = 0

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_Start_Tut01", State_Start_Tut01) -- first tutorial ... at capitol building
	Define_State("State_Start_Tut02", State_Start_Tut02) -- second tutorial ... at military base south of Capitol Building
	Define_State("State_Tutorial_Campaign_Over", State_Tutorial_Campaign_Over) -- goto Novus campaign -- right now just exits to main menu
	
	Define_Retry_State()

	-- Oksana: mark as tutorial so scoring manager knows what to expect
	IsTutorialCampaign = true;

	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")

	PGFactions_Init()
	PGColors_Init_Constants()
	PGPlayerProfile_Init_Constants()
	--aliens.Enable_Colorization(true, COLOR_RED)
	--novus.Enable_Colorization(true, COLOR_CYAN)
	--uea.Enable_Colorization(true, COLOR_GREEN)
	--masari.Enable_Colorization(true, COLOR_DARK_GREEN)
	
	--define pip heads for global dialogue	
	--tutorial/military
	pip_moore = "MH_Moore_pip_Head.alo"
	pip_comm = "mi_comm_officer_pip_head.alo"
	pip_woolard = "Mi_Wollard_pip_head.alo"
	pip_marine = "mi_marine_pip_head.alo"
	
	--novus
	pip_mirabel = "NH_Mirabel_pip_Head.alo"
	pip_viktor = "NH_Viktor_pip_Head.alo"
	pip_vertigo = "NH_Vertigo_pip_Head.alo"
	pip_founder = "NH_Founder_pip_Head.alo"
	pip_novscience = "NI_Science_Officer_pip_Head.alo"
	pip_novcomm = "NI_Comm_Officer_pip_Head.alo"

	--mission win/loss bools
	tutorial01_successful = false
	tutorial02_successful = false
	
	--used in skip-mission cheats
	bool_user_chose_mission = false
	global_story_dialogue_done=false
	
	--this is used to hold data generated at the end of novus 1 to be used again in mission 7
	novus_base_table = {}
	
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		Force_Default_Game_Speed()
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("\n\n\n\n\n\n\n\n\n\n*************NOVUS CAMPAIGN START********"))
		
		Register_Game_Scoring_Commands()

		local data_table = GameScoringManager.Get_Game_Script_Data_Table()
		if data_table == nil or data_table.Debug_Start_Mission == nil then
			Set_Next_State("State_Start_Tut01")
		else
			Set_Next_State(tostring(data_table.Debug_Start_Mission))
			data_table.Debug_Start_Mission = nil
			GameScoringManager.Set_Game_Script_Data_Table(data_table)
		end
		--Set_Next_State("State_Start_NM01_Dialogue")
		
		--puts up text in the objective box to let player know how to skip to specific missions
		--skipping info getting commented out for sega delivery of first four missions ... jdg 1/5/07
		--objective_skipping_info = Add_Objective("To skip to a specific mission via console commands: \n1. Type 'attach Story_Campaign_Tutorial_Strategic'\n2. Type 'lua' then which mission to start Tut01() - NM07()\n** eg. 'lua NM01()'")
		--objective_skipping_info = Add_Objective("Move your hero to the red-zone to begin.")
		
		globe = Find_First_Object("Global_Core_Art_Model")
		old_yaw_transition, old_pitch_transition = Point_Camera_At.Set_Transition_Time(1, 1)
		globe_spinning_thread=nil
		
		current_global_story_dialogue_id=nil
		current_global_story_dialogue_id_sub_a=nil
		current_global_story_dialogue_id_sub_b=nil
		
		Pause_Sun(true)
	end
end

function State_Start_Tut01(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		JumpToNextMission=false
		EscToStartState=false
		Change_Local_Faction("Military")
		hero = Find_First_Object("Military_Hero_Randal_Moore")
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_Tut01"))
		--making the campaign goto the first mission 
		local region = Find_First_Object("Region22") -- (22  - Washington DC/using 23 - Gulf Coast for now)

		UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MILITARY)
		UI_Set_Loading_Screen_Background("splash_military.tga")
		UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT01_LOAD_SCREEN_TEXT")
		Force_Land_Invasion(region, aliens, uea, false)
	end
end

function State_Start_Tut02(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		JumpToNextMission=false
		EscToStartState=false
		Change_Local_Faction("Military")
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_Tut02"))
		
		if bool_user_chose_mission ~= true then
			_CustomScriptMessage("JoeLog.txt", string.format("Now moving to psuedo-Washington D.C. for Tutorial 02"))
			local region = Find_First_Object("Region23") -- (22  - Washington DC/using 23 - Gulf Coast for now)
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MILITARY)
			UI_Set_Loading_Screen_Background("splash_military.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT02_LOAD_SCREEN_TEXT")
			Force_Land_Invasion(region, aliens, uea, false)
		end
	end
end

--detects the win of Tut02 and then exits to main menu
function State_Tutorial_Campaign_Over(message)
	if message == OnEnter then
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Tutorial_Campaign_Over"))
		MessageBox("You Won! Thanks for playing\nNow returning you to the Main Menu...")
		Set_Profile_Value(PP_CAMPAIGN_TUTORIAL_COMPLETED, true)
		
				
		-- Oksana: Notify achievements
		GameScoringManager.Notify_Achievement_System_Of_Campaign_Completion("Tutorial")

		
		--Quit_Game_Now(novus, true, true, false)
		Register_Campaign_Commands()
		CampaignManager.Start_Campaign("NOVUS_Story_Campaign", true)
	end
end

--***************************************THREADS****************************************************************************************************





--***************************************EVENT HANDLERS****************************************************************************************************
--this is used to overwrite the "Sandbox" map lineup and force which maps+scripts to use
function On_Land_Invasion()

	if objective_triggering_info ~= nil then
		--this just removes old (now redundant) text
		Delete_Objective(objective_triggering_info)
	end
	
	if objective_skipping_info ~= nil then
		--this just removes old (now redundant) text
		Delete_Objective(objective_skipping_info)
	end
	
	if CurrentState == "State_Start_Tut01" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/TUT_01_Washington_DC.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Novus_Tut01"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = true
		InvasionInfo.StartingContext = "Tut01_StoryCampaign"
		InvasionInfo.RequiredContexts = { "hide_me" }
		
	elseif CurrentState == "State_Start_Tut02" then 	
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/TUT_02_FortMcNair.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Novus_Tut02"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "Tut02_StoryCampaign"
		InvasionInfo.RequiredContexts = { "Tut02_StoryCampaign_Novus", "Tut02_StoryCampaign_Midtro" }
	end
end



--***************************************FUNCTIONS****************************************************************************************************
-- This is the "global" win/lose function triggered in the Novus "TACTICAL" mission scripts 
function Novus_Tactical_Mission_Over(victorious)
	if CurrentState == "State_Start_Tut01" then 
		if victorious then
			tutorial01_successful = true
			Set_Next_State("State_Start_Tut02")
			
		end
	elseif CurrentState == "State_Start_Tut02" then
		if victorious then
			tutorial02_successful = true
			Set_Next_State("State_Tutorial_Campaign_Over")
			Set_Profile_Value(PP_CAMPAIGN_TUTORIAL_COMPLETED, true)
		end
	end
	
	if not victorious then
		Retry_Current_Mission()
	end
	
	--changing this bool forces campaign back on track if player had skipped to a specific mission
	bool_user_chose_mission = false
	
	
end

function Force_Victory(player)
	-- Quit_Game_Now(winning_player, quit_to_main_menu, destroy_loser_forces, build_temporary_command_center, VerticalSliceTriggerVictorySplashFlag)
	Quit_Game_Now(player, false, false, false)
end

--This is called from UI when the Start Mission button is clicked.
--function Request_Start_Mission()
--	if not JumpToNextMission then
--		JumpToNextMission = true
--	end
--end

function Story_Handle_Esc()
	if not EscToStartState then
		EscToStartState = true
	end
end

function Thread_Region_Flash(target)
	for i=1,3 do
		UI_Set_Region_Color(target, {1,1,0})
		Sleep(.5)
		UI_Clear_Region_Color(target)
		Sleep(.5)
	end
	current_global_story_dialogue_id_sub_a = nil
end

function Post_Load_Callback()
	--Make sure that we can still call Game Scoring commands after a load
	Register_Game_Scoring_Commands()
	Movie_Commands_Post_Load_Callback()
end

--***************************************CHEATS****************************************************************************************************
--***************************************CHEATS****************************************************************************************************
--***************************************CHEATS****************************************************************************************************
-- below are the "cheat-functions" to launch specific missions (from global mode)
function Tut01()
	_CustomScriptMessage("JoeLog.txt", string.format("*************Player choosing to skip to Tut01"))
	Set_Next_State("State_Start_Tut01")
	bool_user_chose_mission = true

	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: Tut01\nMove your hero to any enemy territory to trigger the mission.")

end

function Tut02()
	_CustomScriptMessage("JoeLog.txt", string.format("*************Player choosing to skip to Tut02"))
	Set_Next_State("State_Start_Tut02")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: Tut02\nMove your hero to any enemy territory to trigger the mission.")
end
