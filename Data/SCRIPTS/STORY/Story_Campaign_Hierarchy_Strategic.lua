-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_Strategic.lua#57 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_Strategic.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Jeff_Stewart $
--
--            $Change: 86904 $
--
--          $DateTime: 2007/10/29 17:13:16 $
--
--          $Revision: #57 $
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
	Define_State("State_Start_ZM01", State_Start_ZM01) -- first Hierarchy mission: (16) Sahara (Pyramids of Giza)
	Define_State("State_Start_ZM02_Dialogue", State_Start_ZM02_Dialogue)
	Define_State("State_Start_ZM02", State_Start_ZM02) -- second Hierarchy mission: (23) Gulf Coast (Florida)
	Define_State("State_Start_ZM03_Dialogue", State_Start_ZM03_Dialogue)
	Define_State("State_Start_ZM03", State_Start_ZM03) -- third Hierarchy mission: (22) Atlantic Ocean (Atlatea)
	Define_State("State_Start_ZM04_Dialogue", State_Start_ZM04_Dialogue)
	Define_State("State_Start_ZM04", State_Start_ZM04) -- forth Hierarchy mission: (30) Altiplano
	Define_State("State_Start_ZM05_Dialogue", State_Start_ZM05_Dialogue)
	Define_State("State_Start_ZM05", State_Start_ZM05) -- fifth Hierarchy mission: (13) Indochina (Masari Temple)
	Define_State("State_Start_ZM06", State_Start_ZM06) -- sixth Hierarchy mission: (35) Central America (Arecibo, Puerto Rico)
	Define_State("State_Hierarchy_Campaign_Over", State_Hierarchy_Campaign_Over) -- goto Masari campaign -- right now just exits to main menu

	Define_Retry_State()
	
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	military = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")

	PGFactions_Init()
--	PGColors_Init_Constants()
	PGPlayerProfile_Init_Constants()
--	aliens.Enable_Colorization(true, COLOR_RED)
--	novus.Enable_Colorization(true, COLOR_CYAN)
--	military.Enable_Colorization(true, COLOR_GREEN)
--	masari.Enable_Colorization(true, COLOR_DARK_GREEN)
	
	-- Pip Heads
	pip_orlok = "AH_Orlok_Pip_Head.alo"
	pip_kamal = "AH_Kamal_Rex_Pip_head.alo"
	pip_science = "AI_Science_officer_Pip_Head.alo"
	pip_comm = "AI_Comm_officer_Pip_head.alo"
	pip_nufai = "AH_Nufai_Pip_Head.alo"
	
	--mission win/loss bools
	ZM01_successful = false
	ZM02_successful = false
	ZM03_successful = false
	ZM04_successful = false
	ZM05_successful = false
	ZM06_successful = false
	
	-- Variables
	region_flashing_thread = nil
	
	--used in skip-mission cheats
	bool_user_chose_mission = false
	global_story_dialogue_done = false
	
end


--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		Force_Default_Game_Speed()
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("RickLog.txt", string.format("\n\n\n\n\n\n\n\n\n\n*************HIERARCHY CAMPAIGN START********"))
		
		hero = Find_First_Object("Alien_Hero_Orlok")
		
		Register_Game_Scoring_Commands()

		local data_table = GameScoringManager.Get_Game_Script_Data_Table()
		if data_table == nil or data_table.Debug_Start_Mission == nil then
			Set_Next_State("State_Start_ZM01")
		else
			Set_Next_State(tostring(data_table.Debug_Start_Mission))
			data_table.Debug_Start_Mission = nil
			GameScoringManager.Set_Game_Script_Data_Table(data_table)
		end
		
		--puts up text in the objective box to let player know how to skip to specific missions
		--skipping info getting commented out for sega delivery of first four missions ... jdg 1/5/07
		--objective_skipping_info = Add_Objective("To skip to a specific mission via console commands: \n1. Type 'attach Story_Campaign_Novus_Strategic'\n2. Type 'lua' then which mission to start Tut01() - NM07()\n** eg. 'lua NM01()'")
		--objective_skipping_info = Add_Objective("Move your hero to the red-zone to begin.")

		globe = Find_First_Object("Global_Core_Art_Model")
		old_yaw_transition, old_pitch_transition = 0,0
		globe_spinning_thread = nil
		
		current_global_story_dialogue_id=nil
		current_global_story_dialogue_id_sub_a=nil
		current_global_story_dialogue_id_sub_b=nil
		
		Pause_Sun(true)

	end
end

function State_Start_ZM01(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("RickLog.txt", string.format("*************State_Start_ZM01"))
				
   	Point_Sun_At(Find_First_Object("Region16"))

		UI_Set_Loading_Screen_Faction_ID(PG_FACTION_ALIEN)
		UI_Set_Loading_Screen_Background("Splash_Alien.tga")
		UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_HIE01_LOAD_SCREEN_TEXT")
			
		local region = Find_First_Object("Region16") -- (16 - Sahara)
		Force_Land_Invasion(region, null, aliens, false)
	end
end

function State_Start_ZM02_Dialogue(message)
	if message == OnEnter then
		Allow_Speech_Events(true)

		JumpToNextMission=false
		EscToStartState=false
		--UI_Hide_Start_Mission_Button()
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("ZM02_Global_Story_Dialogue")
		Create_Thread("Thread_Region_Flash", Find_First_Object("Region16"))

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_ZM02")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					globe.Play_Animation("Anim_Build",true,0)
					End_Cinematic_Camera()
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					if not (current_global_story_dialogue_id_sub_b == nil) then
						Thread.Kill(current_global_story_dialogue_id_sub_b)
					end
					
					Set_PIP_Model (1, nil)
					Set_PIP_Model (2, nil)
					Set_PIP_Model (3, nil)
					
					Point_Camera_At.Set_Transition_Time(1,1)
					Point_Camera_At(Find_First_Object("Region23"))
					Create_Thread("Thread_Region_Flash", Find_First_Object("Region23"))
					Zoom_Camera.Set_Transition_Time(1)
					Zoom_Camera(1)
					
					Lock_Controls(0)
					--UI_Show_Start_Mission_Button()
					global_story_dialogue_done=true
					start_mission_ready=true
					JumpToNextMission=true
				  end
				end
			end
		end
	end
end

function ZM02_Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region23"))
	Start_Cinematic_Camera()
	Fade_Screen_Out(0)
	
	local region=Find_First_Object("Region16")
	local center=region.Get_Command_Center()
	if TestValid(center) then center.Despawn() end
	Sleep(1) -- must be here to give the command center time to despawn (jgs?)
	local hero = Find_First_Object("Alien_Hero_Orlok")
	local fleet = hero.Get_Parent_Object()
	fleet.Move_Fleet_To_Region(Find_First_Object("Region16"), true)
	region.Start_Command_Center_Construction(Find_Object_Type("Alien_Hierarchy_Core"),aliens,true)
	global_story_dialogue_setup=true
		
	local science_slot = 1
	local kamal_slot = 2
	local orlok_slot = 3
	
	Set_PIP_Model (science_slot, pip_science)
	Set_PIP_Model (kamal_slot, pip_kamal)
	Set_PIP_Model (orlok_slot, pip_orlok)
	
	globe.Play_Animation("Anim_Cinematic",true,3)
	globe.Play_Animation("Anim_Cinematic",true,3)
	Letter_Box_In(0)
	
	if true then
		camera_pos = globe.Get_Bone_Position("camera_cine_04")
		target_pos = globe.Get_Bone_Position("target_cine_04")
		-- Set_Cinematic_Camera_Key(target_pos, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
		Set_Cinematic_Camera_Key(camera_pos, 0, 0, 0, 1, 0, 0, 0)
		Set_Cinematic_Target_Key(target_pos, 0, 0, 0, 1, 0, 0, 0)
		Transition_Cinematic_Camera_Key(target_pos, 110, 0, 0, 0, 1, 0, 0, 0)
		-- Transition_Cinematic_Camera_Key(target_pos, time, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
		Fade_Screen_In(2)
		
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE01_SCENE07_01", kamal_slot))
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE07_02", orlok_slot))
		globe.Play_Animation("Anim_Cinematic",true,12)
		Sleep(1)
		globe.Play_Animation("Anim_Cinematic",true,13)
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE01_SCENE07_03", science_slot))

		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE01_SCENE07_04", kamal_slot))
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE07_05", orlok_slot))
		globe.Play_Animation("Anim_Cinematic",true,4)
		Play_SFX_Event("SFX_Military_Missile_Fire")
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE01_SCENE07_06", science_slot))
		Transition_Cinematic_Target_Key(Find_First_Object("Region20"), 40, 0, 0, 0, 1, 0, 0, 0)
		
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE01_SCENE07_07", kamal_slot))
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE07_08", orlok_slot))
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE01_SCENE07_09", science_slot))
		
		Play_SFX_Event("SFX_Military_Missile_FlyBy")
		Sleep(1.6)
		Play_SFX_Event("SFX_Alien_Small_Structure_Death")
		Shake_Camera(2,2)
		Sleep(4)
		--globe.Play_Animation("Anim_Cinematic",true,5)
	end
	
	Fade_Screen_Out(1)
	Sleep(1)
	End_Cinematic_Camera()
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region16"))
	globe.Play_Animation("Anim_Build",true,0)
	Fade_Screen_In(1)
	Sleep(1)
		current_global_story_dialogue_id_sub_b = Create_Thread("Fake_Fleet_Move_ZM02")

		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE02_SCENE01_01", kamal_slot))
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE02_SCENE01_02", science_slot))
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE01_03", orlok_slot))
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE02_SCENE01_04", kamal_slot))
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE02_SCENE01_05", kamal_slot))
		
	Fade_Screen_Out(2)
	Sleep(2)
	global_story_dialogue_done=true
end

function Fake_Fleet_Move_ZM02()
	local hero = Find_First_Object("Alien_Hero_Orlok")
	local fleet = hero.Get_Parent_Object()
	local region_start, region_end, move_time = nil, nil, 0
	Sleep(2)
	region_start=Find_First_Object("Region16")
	region_end=Find_First_Object("Region29")
	move_time = 5
	Point_Camera_At.Set_Transition_Time(move_time,move_time)
	Point_Camera_At(Find_First_Object("Region29"))
	local oldServiceRate = ServiceRate
	ServiceRate = 0.01
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region29")
	region_end=Find_First_Object("Region33")
	move_time = 5
	Point_Camera_At.Set_Transition_Time(move_time,move_time)
	Point_Camera_At(Find_First_Object("Region33"))
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region33")
	region_end=Find_First_Object("Region34")
	move_time = 5
	Point_Camera_At.Set_Transition_Time(move_time,move_time)
	Point_Camera_At(Find_First_Object("Region34"))
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region34")
	region_end=Find_First_Object("Region23")
	move_time = 3
	Point_Camera_At.Set_Transition_Time(move_time,move_time)
	Point_Camera_At(Find_First_Object("Region23"))
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	ServiceRate = oldServiceRate
	current_global_story_dialogue_id_sub_b = nil
end

function State_Start_ZM02(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("RickLog.txt", string.format("*************State_Start_ZM02"))
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			
			if not current_global_story_dialogue_id_sub_a == nil then
				Thread.Kill(current_global_story_dialogue_id_sub_a)
			end

      	Point_Sun_At(Find_First_Object("Region23"))
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_ALIEN)
			UI_Set_Loading_Screen_Background("Splash_Alien.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_HIE02_LOAD_SCREEN_TEXT")
			
			local region = Find_First_Object("Region23") -- (23 - Gulf Coast)
			Force_Land_Invasion(region, null, aliens, false)
		end

	end
end

function State_Start_ZM03_Dialogue(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		--UI_Hide_Start_Mission_Button()
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		current_global_story_dialogue_id = Create_Thread("ZM03_Global_Story_Dialogue")
		Create_Thread("Thread_Region_Flash", Find_First_Object("Region23"))

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then

			--Handle user request to skip straight to the next mission.
			if EscToStartState or global_story_dialogue_done then
			  if global_story_dialogue_setup then 
				Stop_All_Speech()
				EscToStartState = false
				
				globe.Play_Animation("Anim_Idle",true,0)
				End_Cinematic_Camera()
				
				if not (current_global_story_dialogue_id == nil) then
					Thread.Kill(current_global_story_dialogue_id)
				end
				if not (current_global_story_dialogue_id_sub_b == nil) then
					Thread.Kill(current_global_story_dialogue_id_sub_b)
				end
				
				Set_PIP_Model (1, nil)
				Set_PIP_Model (2, nil)
				Set_PIP_Model (3, nil)
				
				Point_Camera_At.Set_Transition_Time(1,1)
				Point_Camera_At(Find_First_Object("Region23"))
				--Create_Thread("Thread_Region_Flash", Find_First_Object("Region22"))
				Zoom_Camera.Set_Transition_Time(1)
				Zoom_Camera(1)
				
				Lock_Controls(0)
				global_story_dialogue_done=true
				Set_Next_State("State_Start_ZM03")
			  end
			end
		end
	end
end

function ZM03_Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region22"))
	
	local region=Find_First_Object("Region23")
	local center=region.Get_Command_Center()
	if TestValid(center) then center.Despawn() end
	Sleep(1) -- must be here to give the command center time to despawn (jgs?)
	local hero = Find_First_Object("Alien_Hero_Orlok")
	local fleet = hero.Get_Parent_Object()
	fleet.Move_Fleet_To_Region(Find_First_Object("Region23"), true)
	region.Start_Command_Center_Construction(Find_Object_Type("Alien_Hierarchy_Core"),aliens,true)
	global_story_dialogue_setup=true
	
	local science_slot = 1
	local kamal_slot = 2
	local orlok_slot = 3
	
	Set_PIP_Model (science_slot, pip_science)
	Set_PIP_Model (kamal_slot, pip_kamal)
	Set_PIP_Model (orlok_slot, pip_orlok)
	
	Letter_Box_In(0)
	globe.Play_Animation("Anim_Cinematic",true,11)
	Fade_Screen_Out(0)

			Start_Cinematic_Camera()
			camera_pos = globe.Get_Bone_Position("camera_cine_10")
			target_pos = globe.Get_Bone_Position("target_cine_10")
			-- Set_Cinematic_Camera_Key(target_pos, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
			Set_Cinematic_Camera_Key(target_pos, 0, 0, 0, 1, 0, 0, 0)
			Set_Cinematic_Target_Key(target_pos, 0, 0, 0, 1, 0, 0, 0)
	
			Transition_Cinematic_Camera_Key(camera_pos, 2, 0, 0, 0, 1, 0, 0, 0)
			Transition_Cinematic_Target_Key(Find_First_Object("Region18"), 3, 0, 0, 0, 1, 0, 0, 0)
			Sleep(1)
			Transition_Cinematic_Camera_Key(camera_pos, 18, 0, 0, 0, 1, 0, 0, 0)
			Transition_Cinematic_Target_Key(target_pos, 180, 0, 0, 0, 1, 0, 0, 0)
			Fade_Screen_In(2)
			globe.Play_Animation("Anim_Cinematic",true,11)
	
	if false then -- used to cut out obsolete cine stuff
		
		Start_Cinematic_Camera()
		Fade_Screen_Out(0)
		globe.Play_Animation("Anim_Cinematic",true,6) -- for some reason the anim system won't update soon enough (temp fix)
			
		if true then
			globe.Play_Animation("Anim_Cinematic",true,6)
			camera_pos = globe.Get_Bone_Position("camera_cine_07")
			target_pos = globe.Get_Bone_Position("target_cine_07")
			-- Set_Cinematic_Camera_Key(target_pos, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
			if true then
			Set_Cinematic_Camera_Key(camera_pos, 0, 0, 0, 1, 0, 0, 0)
			Set_Cinematic_Target_Key(target_pos, 0, 0, 0, 1, 0, 0, 0)
			Transition_Cinematic_Camera_Key(target_pos, 180, 10, 0, 10, 1, 0, 0, 0)
			Transition_Cinematic_Target_Key(Find_First_Object("Region18"), 2, 0, 0, 0, 1, 0, 0, 0)
			Sleep(1)
			Transition_Cinematic_Target_Key(target_pos, 60, 0, 0, 0, 1, 0, 0, 0)
			end
			-- Transition_Cinematic_Camera_Key(target_pos, time, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
			
			Sleep(1)
			Fade_Screen_In(2)
			
			globe.Play_Animation("Anim_Cinematic",true,7)
			BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE02_SCENE08_01", kamal_slot))
			Shake_Camera(.1,6)
			BlockOnCommand(Queue_Talking_Head(pip_science, "HIE02_SCENE08_02", science_slot))
			BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE02_SCENE08_03", kamal_slot))
			BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE08_04", orlok_slot))
			globe.Play_Animation("Anim_Cinematic",false,14)
			BlockOnCommand(Queue_Talking_Head(pip_science, "HIE02_SCENE08_05", science_slot))
			BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE02_SCENE08_06", kamal_slot))
			--globe.Play_Animation("Anim_Cinematic",true,15)
			BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE08_07", orlok_slot))
			globe.Play_Animation("Anim_Cinematic",true,16)
			BlockOnCommand(Queue_Talking_Head(pip_science, "HIE02_SCENE08_08", science_slot))
			globe.Play_Animation("Anim_Cinematic",true,9)

			BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE02_SCENE08_09", kamal_slot))
			Fade_Screen_Out(1)
			Sleep(1)
		end
		if true then
			camera_pos = globe.Get_Bone_Position("camera_cine_10")
			target_pos = globe.Get_Bone_Position("target_cine_10")
			-- Set_Cinematic_Camera_Key(target_pos, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
			Set_Cinematic_Camera_Key(target_pos, 0, 0, 0, 1, 0, 0, 0)
			Set_Cinematic_Target_Key(target_pos, 0, 0, 0, 1, 0, 0, 0)
			Transition_Cinematic_Camera_Key(camera_pos, 2, 0, 0, 0, 1, 0, 0, 0)
			Transition_Cinematic_Target_Key(Find_First_Object("Region18"), 3, 0, 0, 0, 1, 0, 0, 0)
			Sleep(1)
			Transition_Cinematic_Camera_Key(camera_pos, 18, 0, 0, 0, 1, 0, 0, 0)
			Transition_Cinematic_Target_Key(target_pos, 180, 0, 0, 0, 1, 0, 0, 0)
			Fade_Screen_In(1)
			
			globe.Play_Animation("Anim_Cinematic",true,10)
			
			Sleep(4)
			Shake_Camera(1,2)
			Sleep(2)
			Shake_Camera(1,2)
			Sleep(1)
			globe.Play_Animation("Anim_Cinematic",true,11)
		end
	end
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE03_SCENE01_01", science_slot))
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE03_SCENE01_02", kamal_slot))
		local nufai_slot = 1
		Set_PIP_Model (nufai_slot, pip_nufai)
		BlockOnCommand(Queue_Talking_Head(pip_nufai, "HIE03_SCENE01_03", nufai_slot))
		Point_Camera_At(Find_First_Object("Region23"))
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE03_SCENE01_04", kamal_slot))
	
	Fade_Screen_Out(2)
	Sleep(2)
	End_Cinematic_Camera()
		
	global_story_dialogue_done=true
end

function State_Start_ZM03(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("RickLog.txt", string.format("*************State_Start_ZM03"))
		
		if bool_user_chose_mission ~= true then
			
			if not current_global_story_dialogue_id_sub_a == nil then
				Thread.Kill(current_global_story_dialogue_id_sub_a)
			end
			
      	Point_Sun_At(Find_First_Object("Region22"))

			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_ALIEN)
			UI_Set_Loading_Screen_Background("Splash_Alien.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_HIE03_LOAD_SCREEN_TEXT")
			
			local region = Find_First_Object("Region22") -- (22 - Appalachia)
			Force_Land_Invasion(region, null, aliens, false)
		end
	end
end

function State_Start_ZM04_Dialogue(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		--UI_Hide_Start_Mission_Button()
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("ZM04_Global_Story_Dialogue")
		--Create_Thread("Thread_Region_Flash", Find_First_Object("Region16"))

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_ZM04")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					--globe.Play_Animation("Anim_Idle",true,0)
					--End_Cinematic_Camera()
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					if not (current_global_story_dialogue_id_sub_b == nil) then
						Thread.Kill(current_global_story_dialogue_id_sub_b)
					end
					
					Set_PIP_Model (1, nil)
					Set_PIP_Model (2, nil)
					Set_PIP_Model (3, nil)
					
					Point_Camera_At.Set_Transition_Time(1,1)
					Point_Camera_At(Find_First_Object("Region30"))
					Create_Thread("Thread_Region_Flash", Find_First_Object("Region30"))
					Zoom_Camera.Set_Transition_Time(1)
					Zoom_Camera(1)
					
					Lock_Controls(0)
					--UI_Show_Start_Mission_Button()
					global_story_dialogue_done=true
					start_mission_ready=true
					JumpToNextMission=true
				  end
				end
			end
		end
	end
end

function ZM04_Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region30"))
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region23"))
	Fade_Screen_In(1)
	
	local region=Find_First_Object("Region23")
	local center=region.Get_Command_Center()
	if TestValid(center) then 
		if not center.Get_Owner()==aliens then
			center.Despawn()
			Sleep(1) -- must be here to give the command center time to despawn (jgs?)
			local hero = Find_First_Object("Alien_Hero_Orlok")
			local fleet = hero.Get_Parent_Object()
			fleet.Move_Fleet_To_Region(Find_First_Object("Region23"), true)
			region.Start_Command_Center_Construction(Find_Object_Type("Alien_Hierarchy_Core"),aliens,true)
		end
	end
	global_story_dialogue_setup=true
		
	local science_slot = 1
	local kamal_slot = 2
	local orlok_slot = 3
	
	Set_PIP_Model (science_slot, pip_science)
	Set_PIP_Model (kamal_slot, pip_kamal)
	Set_PIP_Model (orlok_slot, pip_orlok)
	
	Sleep(1)
	
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE04_SCENE01_01", kamal_slot))
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE04_SCENE01_02", orlok_slot))
		
		old_zoom_time = Zoom_Camera.Set_Transition_Time(5)
		Zoom_Camera(.3)
		transition_time = 12
		Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
		Point_Camera_At(Find_First_Object("Region30"))
		current_global_story_dialogue_id_sub_b = Create_Thread("Fake_Fleet_Move_ZM04")
		
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE04_SCENE01_03", kamal_slot))
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE04_SCENE01_04", science_slot))
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE04_SCENE01_05", science_slot))
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE04_SCENE01_06", kamal_slot))
	end
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region30"))
	Zoom_Camera(1)
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE04_SCENE01_07", kamal_slot))
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE04_SCENE01_08", orlok_slot))
	end
	Fade_Screen_Out(2)
	Sleep(2)
	global_story_dialogue_done=true
end
	
function Fake_Fleet_Move_ZM04()
	local hero = Find_First_Object("Alien_Hero_Orlok")
	local fleet = hero.Get_Parent_Object()
	local region_start, region_end, move_time = nil, nil, 0
	region_start=Find_First_Object("Region23")
	region_end=Find_First_Object("Region35")
	move_time = 5
	local oldServiceRate = ServiceRate
	ServiceRate = 0.01
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region35")
	region_end=Find_First_Object("Region31")
	move_time = 5
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region31")
	region_end=Find_First_Object("Region30")
	move_time = 5
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	ServiceRate = oldServiceRate
  	current_global_story_dialogue_id_sub_b = nil
end

function State_Start_ZM04(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("RickLog.txt", string.format("*************State_Start_ZM04"))

		if bool_user_chose_mission ~= true then
			if not current_global_story_dialogue_id_sub_a == nil then
				Thread.Kill(current_global_story_dialogue_id_sub_a)
			end

      	Point_Sun_At(Find_First_Object("Region30"))
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_ALIEN)
			UI_Set_Loading_Screen_Background("Splash_Alien.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_HIE04_LOAD_SCREEN_TEXT")
			
			local region = Find_First_Object("Region30") -- (30 - Altiplano)
			Force_Land_Invasion(region, null, aliens, false)
		end
	end
end

function State_Start_ZM05_Dialogue(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		--UI_Hide_Start_Mission_Button()
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("ZM05_Global_Story_Dialogue")
		Create_Thread("Thread_Region_Flash", Find_First_Object("Region30"))

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_ZM05")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					--globe.Play_Animation("Anim_Idle",true,0)
					--End_Cinematic_Camera()
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					if not (current_global_story_dialogue_id_sub_b == nil) then
						Thread.Kill(current_global_story_dialogue_id_sub_b)
					end
					
					Set_PIP_Model (1, nil)
					Set_PIP_Model (2, nil)
					Set_PIP_Model (3, nil)
					
					Point_Camera_At.Set_Transition_Time(1,1)
					Point_Camera_At(Find_First_Object("Region13"))
					Create_Thread("Thread_Region_Flash", Find_First_Object("Region13"))
					Zoom_Camera.Set_Transition_Time(1)
					Zoom_Camera(1)
					
					Lock_Controls(0)
					--UI_Show_Start_Mission_Button()
					global_story_dialogue_done=true
					start_mission_ready=false
					JumpToNextMission=true
				  end
				end
			end
		end
	end
end

function ZM05_Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region13"))
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region30"))
	Fade_Screen_In(1)
	
	local region=Find_First_Object("Region30")
	local center=region.Get_Command_Center()
	if TestValid(center) then center.Despawn() end
	Sleep(1) -- must be here to give the command center time to despawn (jgs?)
	local hero = Find_First_Object("Alien_Hero_Orlok")
	local fleet = hero.Get_Parent_Object()
	fleet.Move_Fleet_To_Region(Find_First_Object("Region30"), true)
	region.Start_Command_Center_Construction(Find_Object_Type("Alien_Hierarchy_Core"),aliens,true)
	global_story_dialogue_setup=true
		
	local science_slot = 1
	local kamal_slot = 2
	local orlok_slot = 3
	
	Set_PIP_Model (science_slot, pip_science)
	Set_PIP_Model (kamal_slot, pip_kamal)
	Set_PIP_Model (orlok_slot, pip_orlok)
	
	Sleep(1)
	
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE05_SCENE01_01", kamal_slot))
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE05_SCENE01_02", kamal_slot))
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE05_SCENE01_03", orlok_slot))
		
		old_zoom_time = Zoom_Camera.Set_Transition_Time(5)
		Zoom_Camera(.3)
		transition_time = 15
		Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
		Point_Camera_At(Find_First_Object("Region13"))
		current_global_story_dialogue_id_sub_b = Create_Thread("Fake_Fleet_Move_ZM05")
		
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE05_SCENE01_04", kamal_slot))
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE05_SCENE01_05", orlok_slot))
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE05_SCENE01_06", science_slot))
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE05_SCENE01_07", orlok_slot))
		
	end
	Create_Thread("Thread_Region_Flash", Find_First_Object("Region13"))
	Zoom_Camera(1)
	if true then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE05_SCENE01_08", kamal_slot))
	end
	Fade_Screen_Out(2)
	Sleep(2)
	global_story_dialogue_done=true
end
	
function Fake_Fleet_Move_ZM05()
	local hero = Find_First_Object("Alien_Hero_Orlok")
	local fleet = hero.Get_Parent_Object()
	local region_start, region_end, move_time = nil, nil, 0
	Sleep(2)
	region_start=Find_First_Object("Region30")
	region_end=Find_First_Object("Region18")
	move_time = 5
	Point_Camera_At.Set_Transition_Time(move_time,move_time)
	Point_Camera_At(Find_First_Object("Region18"))
	local oldServiceRate = ServiceRate
	ServiceRate = 0.01
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region18")
	region_end=Find_First_Object("Region17")
	move_time = 5
	Point_Camera_At.Set_Transition_Time(move_time,move_time)
	Point_Camera_At(Find_First_Object("Region17"))
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region17")
	region_end=Find_First_Object("Region9")
	move_time = 5
	Point_Camera_At.Set_Transition_Time(move_time,move_time)
	Point_Camera_At(Find_First_Object("Region9"))
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	region_start=Find_First_Object("Region9")
	region_end=Find_First_Object("Region13")
	move_time = 3
	Point_Camera_At.Set_Transition_Time(move_time,move_time)
	Point_Camera_At(Find_First_Object("Region13"))
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
	ServiceRate = oldServiceRate
	current_global_story_dialogue_id_sub_b = nil
end

function State_Start_ZM05(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("RickLog.txt", string.format("*************State_Start_ZM05"))

		if bool_user_chose_mission ~= true then
			if not current_global_story_dialogue_id_sub_a == nil then
				Thread.Kill(current_global_story_dialogue_id_sub_a)
			end

      	Point_Sun_At(Find_First_Object("Region13"))
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_ALIEN)
			UI_Set_Loading_Screen_Background("Splash_Alien.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_HIE05_LOAD_SCREEN_TEXT")
			
			local region = Find_First_Object("Region13") -- (30 - Altiplano)
			Force_Land_Invasion(region, null, aliens, false)
		end
	end
end

function State_Start_ZM06(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		_CustomScriptMessage("RickLog.txt", string.format("*************State_Start_ZM06"))

		if bool_user_chose_mission ~= true then
			if not current_global_story_dialogue_id_sub_a == nil then
				Thread.Kill(current_global_story_dialogue_id_sub_a)
			end

      	Point_Sun_At(Find_First_Object("Region35"))
			
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_ALIEN)
			UI_Set_Loading_Screen_Background("Splash_Alien.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_HIE06_LOAD_SCREEN_TEXT")
			
			local region = Find_First_Object("Region35") -- (30 - Altiplano)
			Force_Land_Invasion(region, null, aliens, false)
		end
	end
end


--detects the win of ZM07 and then exits to main menu
function State_Hierarchy_Campaign_Over(message)
	if message == OnEnter then
		_CustomScriptMessage("RickLog.txt", string.format("*************State_Hierarchy_Campaign_Over"))
		--MessageBox("You Won! Thanks for playing\nNow returning you to the Main Menu...")
		Set_Profile_Value(PP_CAMPAIGN_HIERARCHY_COMPLETED, true)
		
		-- Oksana: Notify achievements
		GameScoringManager.Notify_Achievement_System_Of_Campaign_Completion("Alien")

		
		--Quit_Game_Now(aliens, true, true, false)
		Register_Campaign_Commands()
		CampaignManager.Start_Campaign("MASARI_Story_Campaign", true)
	end
end

--***************************************THREADS*********************************************************************************************

function Flash_Region(target)
	region_flashing_thread = Create_Thread("Thread_Region_Flash",target)
end

function Thread_Region_Flash(target)
	local i
	for i = 1,20 do
		UI_Set_Region_Color(target, {1,1,0})
		Sleep(.5)
		UI_Clear_Region_Color(target)
		Sleep(.5)
	end
end

function Fake_Fleet_Move(params)
	local region_start, region_end, move_time = params[1], params[2], params[3]
	BlockOnCommand(Fake_Fleet_Movement(region_start, region_end, move_time))
end


--***************************************EVENT HANDLERS*********************************************************************************************
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
	
	if CurrentState == "State_Start_ZM01" then
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/M16_Sahara.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Hierarchy_ZM01"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "ZM01"
		InvasionInfo.NightMission = false
	
	elseif CurrentState == "State_Start_ZM02" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/M23_Gulf_Coast.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Hierarchy_ZM02"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "ZM02"
		InvasionInfo.NightMission = false
	
	elseif CurrentState == "State_Start_ZM03" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/ZRH_M03_Atlatea.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Hierarchy_ZM03"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "ZM03"
		InvasionInfo.NightMission = false
	
	elseif CurrentState == "State_Start_ZM04" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/M30_Altiplano_StoryCampaign.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Hierarchy_ZM04"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "ZM04"
		InvasionInfo.NightMission = false
	
	elseif CurrentState == "State_Start_ZM05" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/ZRH_M05_Indochina.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Hierarchy_ZM05"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "ZM05"
		InvasionInfo.RequiredContexts = { "hide_me" }
		InvasionInfo.NightMission = false
	
	elseif CurrentState == "State_Start_ZM06" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/ZRH_M06_Arecibo.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Hierarchy_ZM06"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "ZM06"
		InvasionInfo.NightMission = false
	
	end
end


--***************************************FUNCTIONS****************************************************************************************************
-- This is the "global" win/lose function triggered in the Hierarchy "TACTICAL" mission scripts

function Hierarchy_Tactical_Mission_Over(victorious)
	if CurrentState == "State_Start_ZM01" then 
		if victorious then
			ZM01_successful = true
			Set_Next_State("State_Start_ZM02_Dialogue")
		end
	elseif CurrentState == "State_Start_ZM02" then 
		if victorious then
			ZM02_successful = true
			Set_Next_State("State_Start_ZM03_Dialogue")
		end
	elseif CurrentState == "State_Start_ZM03" then 
		if victorious then
			ZM03_successful = true
			Set_Next_State("State_Start_ZM04_Dialogue")
		end
	elseif CurrentState == "State_Start_ZM04" then 
		if victorious then
			ZM04_successful = true
			Set_Next_State("State_Start_ZM05_Dialogue")
		end
	elseif CurrentState == "State_Start_ZM05" then 
		if victorious then
			ZM05_successful = true
			Set_Next_State("State_Start_ZM06")
		end
	elseif CurrentState == "State_Start_ZM06" then 
		if victorious then
			ZM06_successful = true
			Set_Next_State("State_Hierarchy_Campaign_Over")
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
-- below are the "cheat-functions" to launch specific missions (from global mode)

function ZM01()
	_CustomScriptMessage("RickLog.txt", string.format("*************Player choosing to skip to ZM01"))
	Set_Next_State("State_Start_ZM01")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: ZM01\nMove your hero to any enemy territory to trigger the mission.")
end

function ZM02()
	_CustomScriptMessage("RickLog.txt", string.format("*************Player choosing to skip to ZM02"))
	Set_Next_State("State_Start_ZM02")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: ZM02\nMove your hero to any enemy territory to trigger the mission.")
end

function ZM03()
	_CustomScriptMessage("RickLog.txt", string.format("*************Player choosing to skip to ZM03"))
	Set_Next_State("State_Start_ZM03")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: ZM03\nMove your hero to any enemy territory to trigger the mission.")
end

function ZM04()
	_CustomScriptMessage("RickLog.txt", string.format("*************Player choosing to skip to ZM04"))
	Set_Next_State("State_Start_ZM04")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: ZM04\nMove your hero to any enemy territory to trigger the mission.")
end

function ZM05()
	_CustomScriptMessage("RickLog.txt", string.format("*************Player choosing to skip to ZM05"))
	Set_Next_State("State_Start_ZM05")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: ZM05\nMove your hero to any enemy territory to trigger the mission.")
end

function ZM06()
	_CustomScriptMessage("RickLog.txt", string.format("*************Player choosing to skip to ZM06"))
	Set_Next_State("State_Start_ZM06")
	bool_user_chose_mission = true
	
	Delete_Objective(objective_skipping_info)
	objective_triggering_info = Add_Objective("You have chosen to play: ZM06\nMove your hero to any enemy territory to trigger the mission.")
end
