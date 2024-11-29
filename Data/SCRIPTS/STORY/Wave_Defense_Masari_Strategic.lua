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
	Define_State("State_Start_Defense", State_Start_Defense)
	Define_State("State_Start_Dialogue", State_Start_Dialogue) 
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

	masari.Enable_Colorization(true, COLOR_BLUE)
	aliens.Enable_Colorization(true, COLOR_RED)
    MM01_successful = false
    
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
			Set_Next_State("State_Start_Dialogue")
		else
			Set_Next_State(tostring(data_table.Debug_Start_Mission))
			data_table.Debug_Start_Mission = nil
			GameScoringManager.Set_Game_Script_Data_Table(data_table)
		end
		
		hero = Find_First_Object("Masari_Hero_Charos")
		hero.Set_Selectable(false)
		globe = Find_First_Object("Global_Core_Art_Model")
		old_yaw_transition, old_pitch_transition = Point_Camera_At.Set_Transition_Time(1, 1)
		globe_spinning_thread=nil
		
		current_global_story_dialogue_id=nil
		
		Pause_Sun(true)
	end
end

function State_Start_Dialogue(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		JumpToNextMission=false
		EscToStartState=false
		global_story_dialogue_done = false
		global_story_dialogue_setup = false
		start_mission_ready=false
		current_global_story_dialogue_id = Create_Thread("Global_Story_Dialogue")

		Play_Music("Music_Technical_Data")
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			if JumpToNextMission then
				JumpToNextMission=false
				Set_Next_State("State_Start_Defense")
			end

			--Handle user request to skip straight to the next mission.
			if not start_mission_ready then
				if EscToStartState or global_story_dialogue_done then
				  if global_story_dialogue_setup then 
					Stop_All_Speech()
					EscToStartState = false
					
					if not (current_global_story_dialogue_id == nil) then
						Thread.Kill(current_global_story_dialogue_id)
					end
					
					Lock_Controls(0)
					global_story_dialogue_done=true
					start_mission_ready=true
					JumpToNextMission=true
				  end				
				end
			end
		end
	end
end

function Global_Story_Dialogue()
	Lock_Controls(1)
	Point_Sun_At(Find_First_Object("Region1")) --goto
	Point_Camera_At.Set_Transition_Time(1,1)
	Point_Camera_At(Find_First_Object("Region23")) --start
	Fade_Screen_In(1)
	
    local hero = Find_First_Object("Masari_Hero_Charos")
    local fleet = hero.Get_Parent_Object()
    fleet.Move_Fleet_To_Region(Find_First_Object("Region23"), true) --start
    global_story_dialogue_setup = true
		
	old_zoom_time = Zoom_Camera.Set_Transition_Time(5)
	Zoom_Camera(.3)
		
	transition_time = 1
	Point_Camera_At.Set_Transition_Time(transition_time, transition_time)
	Point_Camera_At(Find_First_Object("Region1")) --goto
		
	Fade_Screen_Out(1)
	Sleep(1)
	global_story_dialogue_done=true
end
	
function State_Start_Defense(message)
	if message == OnEnter then
		Allow_Speech_Events(true)
		
		Fade_Screen_Out(0)
		Point_Sun_At(Find_First_Object("Region1")) --goto
		
	elseif message == OnUpdate then
		if bool_user_chose_mission ~= true then
			UI_Set_Loading_Screen_Faction_ID(PG_FACTION_MASARI)
			UI_Set_Loading_Screen_Background("splash_masari.tga")
			UI_Set_Loading_Screen_Mission_Text("TEXT_WAVE_DEFENSE_LOAD_SCREEN_TEXT")
			Force_Land_Invasion(Find_First_Object("Region1"), aliens, masari, false) --goto
		end
		
	end
end


function On_Land_Invasion()

    if CurrentState == "State_Start_Defense" then
        InvasionInfo.OverrideMapName = "./Data/Art/Maps/WaveDefenseM1.ted"
        InvasionInfo.TacticalScript = "Wave_Defense_Masari"
        InvasionInfo.UseStrategicPersistence = false
        InvasionInfo.UseStrategicProductionRules = false
        InvasionInfo.StartingContext = "WaveDefenseM"
        InvasionInfo.NightMission = false
    end
end

function Masari_Tactical_Mission_Over(victorious)
    if CurrentState == "State_Start_Defense" then 
		if victorious then
			MM01_successful = true
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
		Quit_Game_Now(aliens, true, true, false)
	end
end