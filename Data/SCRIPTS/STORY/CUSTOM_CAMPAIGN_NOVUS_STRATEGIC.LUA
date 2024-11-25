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

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_Start_NM01", State_Start_NM01)
	Define_State("State_Start_NM01_Dialogue", State_Start_NM01_Dialogue) 
	Define_State("State_Start_NM02", State_Start_NM02)
	Define_State("State_Start_NM02_Dialogue", State_Start_NM02_Dialogue) 
	Define_State("State_Campaign_Over", State_Campaign_Over)

    Define_Retry_State()
    
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")

	PGFactions_Init()
	PGColors_Init_Constants()

	NM01_successful = false
	NM02_successful = false
    
	bool_user_chose_mission = false
	global_story_dialogue_done=false
end

function State_Init(message)
	if message == OnEnter then
		Force_Default_Game_Speed()
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		Register_Game_Scoring_Commands()

		local data_table = GameScoringManager.Get_Game_Script_Data_Table()
		if data_table == nil or data_table.Debug_Start_Mission == nil then
			Set_Next_State("State_Start_NM01_Dialogue")
		else
			Set_Next_State(tostring(data_table.Debug_Start_Mission))
			data_table.Debug_Start_Mission = nil
			GameScoringManager.Set_Game_Script_Data_Table(data_table)
		end
		--Set_Next_State("State_Start_NM01_Dialogue")
		
		hero = Find_First_Object("Novus_Hero_Mech")
		hero.Set_Selectable(false)
		globe = Find_First_Object("Global_Core_Art_Model")
		old_yaw_transition, old_pitch_transition = Point_Camera_At.Set_Transition_Time(1, 1)
		globe_spinning_thread=nil
		
		current_global_story_dialogue_id=nil
		
		Pause_Sun(true)
	end
end

function State_Start_NM01_Dialogue(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("NM01_Global_Story_Dialogue")

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_NM01")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					--Point_Camera_At.Set_Transition_Time(old_yaw_transition, old_pitch_transition)
					--Zoom_Camera.Set_Transition_Time(old_zoom_time)
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					
					Set_PIP_Model(1, nil)
					Set_PIP_Model(2, nil)
					Set_PIP_Model(3, nil)
					
					Point_Camera_At.Set_Transition_Time(1,1)
					Point_Camera_At(Find_First_Object("Region15"))
					Create_Thread("Thread_Region_Flash", Find_First_Object("Region15"))
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

function NM01_Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region1"))
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region23"))
	Fade_Screen_In(1)
	
		local hero = Find_First_Object("Novus_Hero_Mech")
		local fleet = hero.Get_Parent_Object()
		fleet.Move_Fleet_To_Region(Find_First_Object("Region23"), true)
		global_story_dialogue_setup = true
		
	old_zoom_time = Zoom_Camera.Set_Transition_Time(5)
	Zoom_Camera(.3)
		
	transition_time = 4
	Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
	Point_Camera_At(Find_First_Object("Region1"))
		
	Fade_Screen_Out(2)
	Sleep(2)
	global_story_dialogue_done=true
end
	
function State_Start_NM01(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		Point_Sun_At(Find_First_Object("Region1"))
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_NVS01_LOAD_SCREEN_TEXT")
			Force_Land_Invasion(Find_First_Object("Region1"), aliens, novus, false)
		end
		
	end
end

function State_Start_NM02_Dialogue(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("NM02_Global_Story_Dialogue")

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_NM02")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					--Point_Camera_At.Set_Transition_Time(old_yaw_transition, old_pitch_transition)
					--Zoom_Camera.Set_Transition_Time(old_zoom_time)
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					
					Set_PIP_Model(1, nil)
					Set_PIP_Model(2, nil)
					Set_PIP_Model(3, nil)
					
					Point_Camera_At.Set_Transition_Time(1,1)
					Point_Camera_At(Find_First_Object("Region1"))
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

function NM02_Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region3"))
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region1"))
	Fade_Screen_In(1)
	
		local hero = Find_First_Object("Novus_Hero_Mech")
		local fleet = hero.Get_Parent_Object()
		fleet.Move_Fleet_To_Region(Find_First_Object("Region1"), true)
		global_story_dialogue_setup = true
		
	old_zoom_time = Zoom_Camera.Set_Transition_Time(5)
	Zoom_Camera(.3)
		
	transition_time = 2
	Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
	Point_Camera_At(Find_First_Object("Region3"))
		
	Fade_Screen_Out(2)
	Sleep(2)
	global_story_dialogue_done=true
end
	
function State_Start_NM02(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		Point_Sun_At(Find_First_Object("Region3"))
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_NOVUS)
			UI_Set_Loading_Screen_Background("splash_novus.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_NVS01_LOAD_SCREEN_TEXT")
			Force_Land_Invasion(Find_First_Object("Region3"), aliens, novus, false)
		end
		
	end
end

function On_Land_Invasion()

    if CurrentState == "State_Start_NM01" then
        InvasionInfo.OverrideMapName = "./Data/Art/Maps/CustomCampaignM1.ted"
        InvasionInfo.TacticalScript = "Custom_Campaign_Novus_M1"
        InvasionInfo.UseStrategicPersistence = false
        InvasionInfo.UseStrategicProductionRules = false
        InvasionInfo.StartingContext = "CustomCampaign"
        InvasionInfo.NightMission = false
    elseif CurrentState == "State_Start_NM02" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/CustomCampaignM2.ted"
		InvasionInfo.TacticalScript = "Custom_Campaign_Novus_M2"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "CustomCampaign"
		InvasionInfo.NightMission = true
    end
end

function Novus_Tactical_Mission_Over(victorious)
    if CurrentState == "State_Start_NM01" then 
		if victorious then
			NM01_successful = true
			Set_Next_State("State_Start_NM02_Dialogue")
		end
    elseif CurrentState == "State_Start_NM02" then 
		if victorious then
			NM02_successful = true
			Set_Next_State("State_Campaign_Over")
		end
    end

	if not victorious then
		Retry_Current_Mission()
	end
end

function State_Campaign_Over(message)
	if message == OnEnter then
		Register_Campaign_Commands()
		Quit_Game_Now(novus, true, true, false)
	end
end