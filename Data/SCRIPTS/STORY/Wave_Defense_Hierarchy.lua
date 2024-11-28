
require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGSpawnUnits")
require("PGMoveUnits")
require("RetryMission")
require("PGColors")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)

	-- Factions
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	military = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")

	
	-- Variables
	mission_success = false
	mission_failure = false
    
	
	
	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
end


--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		novus.Allow_Autonomous_AI_Goal_Activation(false)
		masari.Allow_Autonomous_AI_Goal_Activation(false)		
	
        military.Allow_AI_Unit_Behavior(false)
        novus.Allow_AI_Unit_Behavior(false)
        masari.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
		
		-- Construction Locks/Unlocks
		aliens.Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Retreat_From_Tactical_Ability", true,STORY)
		aliens.Lock_Unit_Ability("Alien_Hero_Nufai", "Alien_Nufai_Retreat_From_Tactical_Ability", true,STORY)
		aliens.Lock_Unit_Ability("Alien_Hero_Kamal", "Alien_Kamal_Retreat_From_Tactical_Ability", true,STORY)

        aliens.Give_Money(10000)
		
		Create_Thread("Thread_Mission_Start")

	elseif message == OnUpdate then
    end  
end

function Thread_Mission_Start(message) 
	startloc = Find_Hint("ALIEN_HIERARCHY_CORE", "start") 
	
	Point_Camera_At(startloc)
	Lock_Controls(1)
	Fade_Screen_Out(0)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	Transition_Cinematic_Target_Key(startloc, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(startloc, 0, 200, 55, 65, 1, 0, 0, 0)
	Fade_Screen_In(1) 
	Transition_To_Tactical_Camera(5)
	Sleep(1)
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()

    Sleep(10)

    Create_Thread("Thread_Mission_Complete")
end


function Story_On_Construction_Complete(obj)
	local obj_type
	
	if TestValid(obj) then
	end
end


function Thread_Mission_Failed(mission_failed_text)
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
	mission_failure = true
   Stop_All_Speech()
   Flush_PIP_Queue()
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
	Play_Music("Lose_To_Alien_Event")
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,30)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {mission_failed_text} )
	Sleep(2)
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
   Fade_Screen_Out(2)
   Sleep(2)
   Lock_Controls(0)
	Force_Victory(novus)
end

function Thread_Mission_Complete()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
	local i, marker

	mission_success = true
   Stop_All_Speech()
   Flush_PIP_Queue()
   
   Letter_Box_In(1)
   Lock_Controls(1)
   Suspend_AI(1)
   Disable_Automatic_Tactical_Mode_Music()
   Play_Music("Alien_Win_Tactical_Event")
   Zoom_Camera.Set_Transition_Time(10)
   Zoom_Camera(.3)
   Rotate_Camera_By(180,90)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
	Sleep(2)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(0)

   Fade_Out_Music()
	Force_Victory(aliens)
end

function Force_Victory(player)
   Fade_Out_Music()
	if player == aliens then
	   
		-- Inform the campaign script of our victory.
		global_script.Call_Function("Hierarchy_Tactical_Mission_Over", true) -- true == player wins/false == player loses
		--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
		Quit_Game_Now(player, false, true, false)
	else
		Show_Retry_Dialog()
	end
end

function Post_Load_Callback()
end