-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Masari_Strategic.lua#63 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Masari_Strategic.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Jeff_Stewart $
--
--            $Change: 87743 $
--
--          $DateTime: 2007/11/12 17:04:14 $
--
--          $Revision: #63 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGSpawnUnits")
require("RetryMission")
require("PGColors")
require("PGPlayerProfile")
require("PGFactions")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")
ScriptPoolCount = 0

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_Start_MM01", State_Start_MM01) -- TBD Anahuac
	Define_State("State_Start_Global", State_Start_Global) -- Global Game
	Define_State("State_Start_MM07", State_Start_MM07) -- 34 - Anahuac
	Define_State("State_Masari_Campaign_Over", State_Masari_Campaign_Over) -- right now just exits to main menu
	
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")
	
	PGFactions_Init()
--	PGColors_Init_Constants()
	PGPlayerProfile_Init_Constants()
--	aliens.Enable_Colorization(true, COLOR_RED)
--	masari.Enable_Colorization(true, COLOR_DARK_GREEN)
	
	Define_Retry_State()
	
	--mission win/loss bools
	MM01_successful = false
	MMGL_successful = false
	MM07_successful = false
	
	dialogue_active=false
	
	first_global_win=false
	zessus_found=false;
	reached_coast=false;
	sabotaged_aliens=false;
	begin_finale=false
	zrh_hq_in_range=false
	
	econ_built = false
	prod_built = false
	tech_built = false
	
	pip_moore = "MH_Moore_pip_Head.alo"
	pip_comm = "mi_comm_officer_pip_head.alo"
	pip_woolard = "Mi_Wollard_pip_head.alo"
	pip_marine = "Mi_marine_pip_head.alo"

	pip_mirabel = "NH_Mirabel_pip_Head.alo"
	pip_vertigo = "NH_Vertigo_pip_Head.alo"
	pip_founder = "NH_Founder_pip_Head.alo"
	pip_novscience = "NI_Science_Officer_pip_Head.alo"
	pip_novcomm = "NI_Comm_Officer_pip_Head.alo"

	pip_charos = "ZH_Charos_Pip_head.alo"
	pip_altea = "ZH_Altea_Pip_head.alo"
	pip_zessus = "ZH_Zessus_Pip_head.alo"
	--pip_mascomm = ""
	--pip_masscience = "ZI_Architect_pip_head.alo"
	
	dialogue_active=false
	dialogue_wait_time=1;
	EscToStartState=false;
	current_global_story_dialogue_id=nil
	missions_played=0
	last_missions_played=0

	--used in skip-mission cheats
	bool_user_chose_mission = false
	
	MAX_PLAYERS = 7
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through
function State_Init(message)
	if message == OnEnter then
		Force_Default_Game_Speed()
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("\n\n\n\n\n\n\n\n\n\n*************MASARI CAMPAIGN START********"))
		
		charos = Find_First_Object("Masari_Hero_Charos")
		altea = Find_First_Object("Masari_Hero_Alatea")
		--zessus = Find_First_Object("Masari_Hero_Zessus")
		globe = Find_First_Object("Global_Core_Art_Model")
		
		--zessus.Change_Owner(aliens)
		--zessus.Set_In_Limbo(true)
		--zessus.Hide(true)
		
		Register_Game_Scoring_Commands()

		local data_table = GameScoringManager.Get_Game_Script_Data_Table()
		if data_table == nil or data_table.Debug_Start_Mission == nil then
			Set_Next_State("State_Start_MM01")
		else
			Set_Next_State(tostring(data_table.Debug_Start_Mission))
			data_table.Debug_Start_Mission = nil
			GameScoringManager.Set_Game_Script_Data_Table(data_table)
		end
		
		--puts up text in the objective box to let player know how to skip to specific missions
		--objective_skipping_info = Add_Objective("To skip to a specific mission via console commands: \n1. Type 'attach Story_Campaign_Masari_Strategic'\n2. Type 'lua' then which mission to start, eg. 'lua MM01()'")
		
		Pause_Sun(false)

  		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		local scene = Get_Game_Mode_GUI_Scene()
		Register_Hint_Context_Scene(scene)			-- Set the scene to which independant hints will be attached.
		
		-- upgrade the alien command core with a hardpoint and then return when that hardpoint is destroyed
		command_core=Find_First_Object("Alien_Hierarchy_Core")
		if not TestValid(command_core) then MessageBox("complain no core") end
		command_region=command_core.Get_Region_In()
		Global_Begin_Production(aliens, command_region, Find_Object_Type("Alien_Foundation_Basic_Defense_Upgrade"), command_core)
		Create_Thread("Thread_Track_Final_Defense_HP")
		g_old_yaw, g_old_pitch = Point_Camera_At.Set_Transition_Time(0.5, 0.5)
		
	elseif message == OnUpdate then
	end
end

function Thread_Track_Final_Defense_HP()
	final_defense=Find_First_Object("Alien_Foundation_Basic_Defense_Upgrade")
	while not TestValid(final_defense) do
		Sleep(1)
		final_defense=Find_First_Object("Alien_Foundation_Basic_Defense_Upgrade")
	end
	MessageBox("defense built on headquarters")
	while TestValid(final_defense) do
		Sleep(1)
	end
	current_global_story_dialogue_id=Create_Thread("Dialogue_Goto_Finale")
	sabotaged_aliens=true;
	play_generic_win=false
	picked_dialogue_set=true
end

function State_Start_MM01(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_MM01"))
		local region = Find_First_Object("Region11") -- Kamchatka
		
		Enforce_Global_Production_Dependencies(novus, false)
		Enforce_Global_Production_Dependencies(aliens, false)
		Enforce_Global_Production_Dependencies(uea, false)
		Enforce_Global_Production_Dependencies(masari, false)
		
		if bool_user_chose_mission ~= true then
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MASARI)
			UI_Set_Loading_Screen_Background("splash_masari.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_MAS01_LOAD_SCREEN_TEXT")
			Force_Land_Invasion(region, aliens, masari, false)
		end
		
	end
end

function State_Start_Global(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_Global"))
		local region = Find_First_Object("Region17") -- (17 - East Africa)

		Point_Camera_At(region)
		
		Enforce_Global_Production_Dependencies(novus, false)
		Enforce_Global_Production_Dependencies(aliens, false)
		Enforce_Global_Production_Dependencies(uea, false)
		Enforce_Global_Production_Dependencies(masari, true)
		
		--Prevent building of the Masari megaweapon - the player must fight their way through
		--to the final battle
		masari.Lock_Object_Type(Find_Object_Type("Masari_Megaweapon"), true, STORY)
		
		if bool_user_chose_mission ~= true then
			--Force_Land_Invasion(region, charos.Get_Parent_Object(), masari, false)
		end
		current_global_story_dialogue_id=Create_Thread("Dialogue_Global_Intro",region)
		missions_played=2
		
		start_forces={"MASARI_DISCIPLE","MASARI_DISCIPLE","MASARI_DISCIPLE","MASARI_DISCIPLE","MASARI_DISCIPLE","MASARI_DISCIPLE"}
		Strategic_SpawnList(start_forces, masari, charos.Get_Parent_Object())
		
	elseif message == OnUpdate then
		if not econ_built then
			obj_structure = Find_All_Objects_Of_Type("Masari_Element_Magnet")
			if table.getn(obj_structure)>0 then
				current_global_story_dialogue_id=Create_Thread("Dialogue_Built_Econ")
				econ_built = true
			end
		end
		if not tech_built then
			obj_structure = Find_All_Objects_Of_Type("Masari_Will_Processor")
			if table.getn(obj_structure)>0 then
				current_global_story_dialogue_id=Create_Thread("Dialogue_Built_Tech")
				Add_Independent_Hint(HINT_MM02_RESEARCH_ADD)
				tech_built = true
			end
		end
		if not prod_built then
			obj_structure = Find_All_Objects_Of_Type("Masari_Key_Inspiration")
			if table.getn(obj_structure)>0 then
				current_global_story_dialogue_id=Create_Thread("Dialogue_Built_Prod")
				prod_built = true
			end
		end
		
		--Handle user request to skip straight to the next mission.
		if EscToStartState then
				Stop_All_Speech()
				EscToStartState = false
				
				if not (current_global_story_dialogue_id == nil) then
					Thread.Kill(current_global_story_dialogue_id)
				end
				
				--Point_Camera_At.Set_Transition_Time(1,1)
				--Point_Camera_At(Find_First_Object("Masari_Hero_Charos"))
				
				Lock_Controls(0)
		end
		
		if missions_played>last_missions_played then
			last_missions_played=missions_played
			if missions_played==2 then 
				UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MASARI)
				UI_Set_Loading_Screen_Background("splash_masari.tga")
				UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_MAS02_LOAD_SCREEN_TEXT")
				Add_Independent_Hint(HINT_MM02_MOVING_UNITS)
			end
			if missions_played==3 then 
				UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MASARI)
				UI_Set_Loading_Screen_Background("splash_masari.tga")
				UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_MAS03_LOAD_SCREEN_TEXT")
				Add_Independent_Hint(HINT_MM02_HOW_TO_BUILD_STRUCTURES)
				Add_Independent_Hint(HINT_MM02_HOW_TO_BUILD_UNITS)
			end
			if missions_played==4 then 
				UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MASARI)
				UI_Set_Loading_Screen_Background("splash_masari.tga")
				UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_MAS04_LOAD_SCREEN_TEXT")
			end
			if missions_played==5 then 
				UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MASARI)
				UI_Set_Loading_Screen_Background("splash_masari.tga")
				UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_MAS05_LOAD_SCREEN_TEXT")
			end
			if missions_played==6 then 
				UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MASARI)
				UI_Set_Loading_Screen_Background("splash_masari.tga")
				UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_MAS06_LOAD_SCREEN_TEXT")
			end
			if missions_played==7 then 
				UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MASARI)
				UI_Set_Loading_Screen_Background("splash_masari.tga")
				UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_MAS07_LOAD_SCREEN_TEXT")
			end
			if missions_played==8 then 
				UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MASARI)
				UI_Set_Loading_Screen_Background("splash_masari.tga")
				UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_MAS08_LOAD_SCREEN_TEXT")
			end
			if missions_played==9 then 
				UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MASARI)
				UI_Set_Loading_Screen_Background("splash_masari.tga")
				UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_MAS09_LOAD_SCREEN_TEXT")
			end
		end
	end
end

function State_Start_MM07(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Start_MM03"))
		local region = Find_First_Object("Region34") -- (34 - Anahuac)
		
		Point_Camera_At(region)
		
		Enforce_Global_Production_Dependencies(novus, false)
		Enforce_Global_Production_Dependencies(aliens, false)
		Enforce_Global_Production_Dependencies(uea, false)
		Enforce_Global_Production_Dependencies(masari, false)
		
		if bool_user_chose_mission ~= true then
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MASARI)
			UI_Set_Loading_Screen_Background("splash_masari.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_MAS10_LOAD_SCREEN_TEXT")
			Force_Land_Invasion(region, aliens, masari, false)
		end
	end
end



--detects the win of MM10 and then exits to main menu
function State_Masari_Campaign_Over(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("*************State_Masari_Campaign_Over"))
		Set_Profile_Value(PP_CAMPAIGN_MASARI_COMPLETED, true)
		
		-- Oksana: Notify achievements
		GameScoringManager.Notify_Achievement_System_Of_Campaign_Completion("Masari")


		Quit_Game_Now(masari, true, true, false)
	end
end



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
	
	if CurrentState == "State_Start_MM01" then
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/MAS_M01_Quetzalcoatl.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Masari_MM01"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "Default"
		InvasionInfo.NightMission = false
	
	elseif CurrentState == "State_Start_Global" then 
		InvasionInfo.UseStrategicPersistence = true
		InvasionInfo.UseStrategicProductionRules = true
		
		local human_player = Find_Player("local")
		local is_defender = (InvasionInfo.Location.Get_Owner() == human_player)
		local is_invader = (InvasionInfo.Invader == human_player)

		if is_invader then
			message = Get_Game_Text("TEXT_STRATEGIC_BATTLE_LOCAL_INVADER")
		elseif is_defender then
			message = Get_Game_Text("TEXT_STRATEGIC_BATTLE_LOCAL_DEFENDER")		
		else
			--AI vs AI battle.  Allow it to procede
			Start_Pending_Battle()
			return	
		end
		
		message = Replace_Token(message, InvasionInfo.Location.Get_Type().Get_Display_Name(), 0)
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {message} )
 		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("End_Tooltip", nil, nil)
		Lock_Controls(1)
		Create_Thread("Pending_Battle_Thread", InvasionInfo.Location)
		
	elseif CurrentState == "State_Start_MM07" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/M34_Anahuac_StoryCampaign.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Masari_MM07"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "StoryCampaign_MM07"
		InvasionInfo.RequiredContexts = { "hide_me" }
		InvasionInfo.NightMission = false
		
	end
end


function Pending_Battle_Thread(location)
	while dialogue_active do Sleep(1) end -- this is so multiple attackers doesn't hose the story sequences for masari global

	local old_yaw, old_pitch = Point_Camera_At.Set_Transition_Time(0.5, 0.5)
	old_zoom = Zoom_Camera.Set_Transition_Time(3.0)
	Point_Camera_At(location)
	Zoom_Camera(1.0)
	Sleep(4)
	Fade_Screen_Out(1)
	Sleep(1)
	
	--Make sure that building in tactical has no strategic dependencies.
	for player_index = 0, MAX_PLAYERS - 1 do
		local player = Find_Player(player_index)
		if player then
			Enforce_Global_Production_Dependencies(player, false)
		end
	end	
		
	UI_Set_Loading_Screen_Faction_ID(Get_Faction_Numeric_Form_From_Localized(Find_Player("local").Get_Faction_Display_Name()))
	Start_Pending_Battle()
	Point_Camera_At.Set_Transition_Time(old_yaw, old_pitch)
	Zoom_Camera.Set_Transition_Time(old_zoom)
	Lock_Controls(0)
end


--***************************************FUNCTIONS****************************************************************************************************
-- This is the "global" win/lose function triggered in the Masari "TACTICAL" mission scripts 
function Masari_Tactical_Mission_Over(victorious)
	if CurrentState == "State_Start_MM01" then 
		if victorious then
			MM01_successful = true
			Set_Next_State("State_Start_Global")
		end
	elseif CurrentState == "State_Start_Global" then 
		if sabotaged_aliens and begin_finale then
			MMGL_successful = true
			--MessageBox("Does this even run?")
			Set_Next_State("State_Start_MM07")
		end
	elseif CurrentState == "State_Start_MM07" then 
		if victorious then
			MM07_successful = true
			Set_Next_State("State_Masari_Campaign_Over")
		end
	end
	
	if not victorious then
		Retry_Current_Mission()
	end
	
	--changing this bool forces campaign back on track if player had skipped to a specific mission
	bool_user_chose_mission = false
	
end



--***************************************Global Functions****************************************************************************************************
function On_Sub_Mode_Ended(location, winner, loser)

	Fade_Screen_In(0)		

	--Go back to enforcing strategic dependencies 
	for player_index = 0, MAX_PLAYERS - 1 do
		local player = Find_Player(player_index)
		if player then
			Enforce_Global_Production_Dependencies(player, true)
			local player_script = player.Get_Script()
			if TestValid(player_script) then
				--Reset research
				player_script.Call_Function("Reset_Research_Tree", false)
			end
		end
	end	

	--congratulate the player if they won, chastise them if they lost
	local human_player = Find_Player("local")
	if loser == human_player then
		final_defense=Find_First_Object("Alien_Foundation_Basic_Defense_Upgrade")
		if TestValid(final_defense) then
			current_global_story_dialogue_id=Create_Thread("Dialogue_Generic_Loss")
		end
	else
		missions_played=missions_played+1
		play_generic_win=true
		
		picked_dialogue_set=false
		
		if not picked_dialogue_set then
			if not sabotaged_aliens then
				alien_hq_region = Find_First_Object("Region35")
				if location==alien_hq_region then
					current_global_story_dialogue_id=Create_Thread("Dialogue_Goto_Finale")
					sabotaged_aliens=true;
					play_generic_win=false
					picked_dialogue_set=true
				end
			end
		end
		
		if not picked_dialogue_set then
			--check to see if we can spring zessus or not
			if not zessus_found then
				zessus_region_a = Find_First_Object("Region29")
				zessus_region_b = Find_First_Object("Region30")
				zessus_region_c = Find_First_Object("Region31")
				zessus_region_d = Find_First_Object("Region33")
				if location==zessus_region_a or location==zessus_region_b or location==zessus_region_c or location==zessus_region_d then
					current_global_story_dialogue_id=Create_Thread("Dialogue_Found_Zessus",location)
					--zessus=Create_Generic_Object(Find_Object_Type("Masari_Hero_Zessus"),location.Get_Position(),masari)
					--zessus=Spawn_Unit(Find_Object_Type("Masari_Hero_Zessus"),location.Get_Position(),masari)
					-- spawn him in the home region and then move him to our captured lcation. This will capture the region if Charos died
					zessus=Spawn_Unit(Find_Object_Type("Masari_Hero_Zessus"), masari, Find_First_Object("Region17"))
					local fleet = zessus.Get_Parent_Object()
					fleet.Move_Fleet_To_Region(location, true)
					--zessus.Change_Owner(masari)
					--zessus.Set_In_Limbo(false)
					--zessus.Hide(false)
					zessus_found=true;
					reached_coast=true;
					play_generic_win=false
					picked_dialogue_set=true
				end
			end
		end
			
		if not picked_dialogue_set then
			if not reached_coast then
				coastal_region_a = Find_First_Object("Region18")
				if location==coastal_region_a then
					current_global_story_dialogue_id=Create_Thread("Dialogue_Reached_Coast")
					first_global_win=true
					reached_coast=true;
					play_generic_win=false
					picked_dialogue_set=true
				end
			end
		end
			
		if not picked_dialogue_set then
			if not first_global_win then
				current_global_story_dialogue_id=Create_Thread("Dialogue_First_Victory",location)
				first_global_win=true
				play_generic_win=false
				picked_dialogue_set=true
			end
		end
			
		if not picked_dialogue_set then
			if not zrh_hq_in_range then
				range_region_a = Find_First_Object("Region30")
				range_region_b = Find_First_Object("Region31")
				range_region_c = Find_First_Object("Region33")
				if location==range_region_a or location==range_region_b or location==range_region_c then
					current_global_story_dialogue_id=Create_Thread("Dialogue_ZRH_HQ_In_Range",location)
					zrh_hq_in_range=true;
					play_generic_win=false
					picked_dialogue_set=true
				end
			end
		end
			
		if not picked_dialogue_set then
			if play_generic_win then
				current_global_story_dialogue_id=Create_Thread("Dialogue_Generic_Win")		
			end
		end
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

function Fire_Purifier(weapon_target)
	local weapon_object=Find_First_Object("Alien_Megaweapon_Purifier_Story")
	if TestValid(weapon_object) then
		local script = weapon_object.Get_Script()
		if script ~= nil then
			script.Call_Function("Fire_Megaweapon_At_Region", weapon_target)
		end
	else
		MessageBox("Purifier not found!")
	end
end

function Story_Handle_Esc()
	if not EscToStartState then
		if not sabotaged_aliens then
			EscToStartState = true
			dialogue_active=false
			Set_PIP_Model (1, nil)
			Set_PIP_Model (2, nil)
			Set_PIP_Model (3, nil)
			Point_Camera_At.Set_Transition_Time(g_old_yaw,g_old_pitch)
		end
	end
end

function Dialogue_Global_Intro(loc)
	dialogue_active=true
	Lock_Controls(1)
	Fade_Screen_Out(0)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS02_MEANWHILE"} )
	--Sleep(5)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_In(2)
	Sleep(2)
	local old_trans_1, old_trans_2 = Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region21"))
	Create_Thread("Fire_Purifier",Find_First_Object("Region21"))
	
	--local masscience_slot=1
	local altea_slot=1
	local charos_slot=3
	
	--Set_PIP_Model (masscience_slot, pip_masscience)
	Set_PIP_Model (altea_slot, pip_altea)
	Set_PIP_Model (charos_slot, pip_charos)
	
	Queue_Speech_Event("MAS02_SCENE02_01")
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS02_SCENE02_02", altea_slot))
	BlockOnCommand(Queue_Talking_Head(pip_charos, "MAS02_SCENE02_03", charos_slot))
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region34"))
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region34"))
	BlockOnCommand(Queue_Talking_Head(pip_charos, "MAS02_SCENE02_04", charos_slot))
	Point_Camera_At.Set_Transition_Time(3,3)
	Point_Camera_At(loc)
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS02_SCENE02_05", altea_slot))
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS02_SCENE02_06", altea_slot))
	Lock_Controls(0)
	dialogue_active=false
		Set_PIP_Model (1, nil)
		Set_PIP_Model (2, nil)
		Set_PIP_Model (3, nil)
	current_global_story_dialogue_id=nil
	Point_Camera_At.Set_Transition_Time(g_old_yaw,g_old_pitch)
end

function Dialogue_First_Victory(loc)
	dialogue_active=true
	Lock_Controls(1)
	Sleep(dialogue_wait_time)

	--local masscience_slot=1
	local altea_slot=1
	local charos_slot=3
	
	--Set_PIP_Model (masscience_slot, pip_masscience)
	Set_PIP_Model (altea_slot, pip_altea)
	Set_PIP_Model (charos_slot, pip_charos)
	
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS03_SCENE01_01", altea_slot))
	local old_trans_1, old_trans_2 = Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region1"))
	Create_Thread("Fire_Purifier",Find_First_Object("Region1"))
	Queue_Speech_Event("MAS03_SCENE01_02")
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS03_SCENE01_03", altea_slot))
	Point_Camera_At.Set_Transition_Time(3,3)
	Point_Camera_At(loc)
	Lock_Controls(0)
	dialogue_active=false
		Set_PIP_Model (1, nil)
		Set_PIP_Model (2, nil)
		Set_PIP_Model (3, nil)
	current_global_story_dialogue_id=nil
	Point_Camera_At.Set_Transition_Time(g_old_yaw,g_old_pitch)
end

function Dialogue_Generic_Win()
	dialogue_active=true
	Lock_Controls(1)
	Sleep(dialogue_wait_time)
	if true then
		choice=GameRandom(1,3)
		if(choice==1) then BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS02_SCENE03_01", altea_slot)) end
		if(choice==2) then BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS02_SCENE03_02", altea_slot)) end
		if(choice==3) then BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS02_SCENE03_03", altea_slot)) end
	--else
	--	MessageBox("Good job!")
	end
	Lock_Controls(0)
	dialogue_active=false
	current_global_story_dialogue_id=nil
end

function Dialogue_Generic_Loss()
	dialogue_active=true
	Lock_Controls(1)
	Sleep(dialogue_wait_time)
	if true then
		choice=GameRandom(1,3)
		if(choice==1) then BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS02_SCENE03_04", altea_slot)) end
		if(choice==2) then BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS02_SCENE03_05", altea_slot)) end
		if(choice==3) then BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS02_SCENE03_06", altea_slot)) end
	else
		MessageBox("Oh well. Better luck next time.")
	end
	Lock_Controls(0)
	dialogue_active=false
	current_global_story_dialogue_id=nil
end

function Dialogue_Reached_Coast()
	dialogue_active=true
	Lock_Controls(1)
	Sleep(dialogue_wait_time)

	--local masscience_slot=1
	local altea_slot=1
	local charos_slot=3
	
	--Set_PIP_Model (masscience_slot, pip_masscience)
	Set_PIP_Model (altea_slot, pip_altea)
	Set_PIP_Model (charos_slot, pip_charos)
	
	local old_trans_1, old_trans_2 = Point_Camera_At.Set_Transition_Time(3,3)
	Point_Camera_At(Find_First_Object("Region18"))
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region18"))
	BlockOnCommand(Queue_Talking_Head(pip_charos, "MAS03_SCENE01_04", charos_slot))
	BlockOnCommand(Queue_Talking_Head(pip_charos, "MAS03_SCENE01_05", charos_slot))
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS03_SCENE01_06", altea_slot))
	Lock_Controls(0)
	dialogue_active=false
		Set_PIP_Model (1, nil)
		Set_PIP_Model (2, nil)
		Set_PIP_Model (3, nil)
	current_global_story_dialogue_id=nil
	Point_Camera_At.Set_Transition_Time(g_old_yaw,g_old_pitch)
end

function Dialogue_Found_Zessus(loc)
	dialogue_active=true
	Lock_Controls(1)
	Sleep(dialogue_wait_time)

	local zessus_slot=1
	local altea_slot=2
	local charos_slot=3
	
	Set_PIP_Model (zessus_slot, pip_zessus)
	Set_PIP_Model (altea_slot, pip_altea)
	Set_PIP_Model (charos_slot, pip_charos)
	
	local old_trans_1, old_trans_2 = Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region29"))
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region29"))
	BlockOnCommand(Queue_Talking_Head(pip_charos, "MAS04_SCENE01_01", charos_slot))
	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS04_SCENE01_02", zessus_slot))
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region35"))
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region35"))
	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS04_SCENE01_03", zessus_slot))
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS04_SCENE01_04", altea_slot))
	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS04_SCENE01_05", zessus_slot))
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS04_SCENE01_06", altea_slot))
	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS04_SCENE01_07", zessus_slot))
	Set_PIP_Model (zessus_slot, pip_moore)
	BlockOnCommand(Queue_Talking_Head(pip_moore, "MAS04_SCENE01_08", moore_slot))
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS04_SCENE01_09", altea_slot))
	BlockOnCommand(Queue_Talking_Head(pip_moore, "MAS04_SCENE01_10", moore_slot))
	BlockOnCommand(Queue_Talking_Head(pip_charos, "MAS04_SCENE01_11", charos_slot))
	Point_Camera_At.Set_Transition_Time(3,3)
	Point_Camera_At(loc)
	Lock_Controls(0)
	dialogue_active=false
		Set_PIP_Model (1, nil)
		Set_PIP_Model (2, nil)
		Set_PIP_Model (3, nil)
	current_global_story_dialogue_id=nil
	Point_Camera_At.Set_Transition_Time(g_old_yaw,g_old_pitch)
end

function Dialogue_Built_Econ()
	while dialogue_active do Sleep(1) end
	if true then
		--Set_PIP_Model (2, pip_masscience)
		BlockOnCommand(Queue_Speech_Event("MAS02_SCENE03_07"))
		--Set_PIP_Model (2, nil)
	else
		MessageBox("You built an economy structure!  Way to go!")
	end
	current_global_story_dialogue_id=nil
end

function Dialogue_Built_Prod()
	while dialogue_active do Sleep(1) end
	Sleep(dialogue_wait_time/2)
	if true then
		--Set_PIP_Model (2, pip_masscience)
		BlockOnCommand(Queue_Speech_Event("MAS02_SCENE03_08"))
		--Set_PIP_Model (2, nil)
	else
		MessageBox("You built a production structure!  You are the man (or woman)!")
	end
	current_global_story_dialogue_id=nil
end

function Dialogue_Built_Tech()
	while dialogue_active do Sleep(1) end
	Sleep(dialogue_wait_time/2)
	if true then
		--Set_PIP_Model (2, pip_masscience)
		BlockOnCommand(Queue_Speech_Event("MAS02_SCENE03_09"))
		--Set_PIP_Model (2, nil)
	else
		MessageBox("You built a technology structure!  Smart move!")
	end
	current_global_story_dialogue_id=nil
end

function Dialogue_ZRH_HQ_In_Range(loc)
	dialogue_active=true
	Lock_Controls(1)
	Sleep(dialogue_wait_time)

	--local masscience_slot=1
	local altea_slot=1
	local charos_slot=3
	
	--Set_PIP_Model (masscience_slot, pip_masscience)
	Set_PIP_Model (altea_slot, pip_altea)
	Set_PIP_Model (charos_slot, pip_charos)
	
	local old_trans_1, old_trans_2 = Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region35"))
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region35"))
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS05_SCENE01_01", altea_slot))
	BlockOnCommand(Queue_Talking_Head(pip_charos, "MAS05_SCENE01_02", charos_slot))
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS05_SCENE01_03", altea_slot))
	Queue_Speech_Event("MAS05_SCENE01_04")
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS05_SCENE01_05", altea_slot))
	Point_Camera_At.Set_Transition_Time(3,3)
	Point_Camera_At(loc)
	Lock_Controls(0)
	dialogue_active=false
		Set_PIP_Model (1, nil)
		Set_PIP_Model (2, nil)
		Set_PIP_Model (3, nil)
	current_global_story_dialogue_id=nil
	Point_Camera_At.Set_Transition_Time(g_old_yaw,g_old_pitch)
end

function Dialogue_Goto_Finale()
	dialogue_active=true
	Lock_Controls(1)
	
	if TestValid(charos) then
		fleet1 = charos.Get_Parent_Object()
		if fleet1.Is_Fleet_Moving() then
			if not fleet1.Get_In_Flight_Retreat() then
				fleet1.On_In_Flight_Retreat()
			end
		end
	end
	if TestValid(zessus) then
		fleet2 = zessus.Get_Parent_Object()
		if fleet2.Is_Fleet_Moving() then
			if not fleet2.Get_In_Flight_Retreat() then
				fleet2.On_In_Flight_Retreat()
			end
		end
	end
	
	Sleep(dialogue_wait_time)

	local mirabel_slot=1
	local altea_slot=2
	local charos_slot=3
	
	Set_PIP_Model (mirabel_slot, pip_mirabel)
	Set_PIP_Model (altea_slot, pip_altea)
	Set_PIP_Model (charos_slot, pip_charos)
	
	local old_trans_1, old_trans_2 = Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region34"))
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region34"))
	BlockOnCommand(Queue_Talking_Head(pip_charos, "MAS06_SCENE01_01", charos_slot))
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS06_SCENE01_02", altea_slot))
	BlockOnCommand(Queue_Talking_Head(pip_altea, "MAS06_SCENE01_03", altea_slot))
	BlockOnCommand(Queue_Talking_Head(pip_mirabel, "MAS06_SCENE01_04", mirabel_slot))
	Sleep(dialogue_wait_time)
	Lock_Controls(0)
	dialogue_active=false
	begin_finale=true
		Set_PIP_Model (1, nil)
		Set_PIP_Model (2, nil)
		Set_PIP_Model (3, nil)
	current_global_story_dialogue_id=nil
	Point_Camera_At.Set_Transition_Time(g_old_yaw,g_old_pitch)
	Set_Next_State("State_Start_MM07")
end

function Force_Victory(player)
	-- Quit_Game_Now(winning_player, quit_to_main_menu, destroy_loser_forces, build_temporary_command_center, VerticalSliceTriggerVictorySplashFlag)
	Quit_Game_Now(player, false, false, false)
end

function Post_Load_Callback()
	--Make sure that we can still call Game Scoring commands after a load
	Register_Game_Scoring_Commands()
	Movie_Commands_Post_Load_Callback()
end

