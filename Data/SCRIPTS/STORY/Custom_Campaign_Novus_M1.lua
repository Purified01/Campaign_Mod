
require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGMoveUnits")
require("PGColors")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")
require("PGSpawnUnits")
require("PGAchievementAward")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")
require("RetryMission")

--require("PGBase")
--require("PGColors")
require("PGUICommands")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")
	
	novus_two=Find_Player("NovusTwo")

	PGColors_Init_Constants()
--	aliens.Enable_Colorization(true, COLOR_RED)
--	uea.Enable_Colorization(true, COLOR_GREEN)
--	novus.Enable_Colorization(true, COLOR_CYAN)
--	novus_two.Enable_Colorization(true, COLOR_BLUE)

	pip_moore = "MH_Moore_pip_Head.alo"
	pip_comm = "mi_comm_officer_pip_head.alo"
	pip_woolard = "Mi_Wollard_pip_head.alo"
	pip_marine = "mi_marine_pip_head.alo"
	
	pip_mirabel = "NH_Mirabel_pip_Head.alo"
	pip_vertigo = "NH_Vertigo_pip_Head.alo"
	pip_founder = "NH_Founder_pip_Head.alo"
	pip_novscience = "NI_Science_Officer_pip_Head.alo"
	pip_novcomm = "NI_Comm_Officer_pip_Head.alo"

	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through
function State_Init(message)
	if message == OnEnter then
		-- ***** ACHIEVEMENT_AWARD *****
		PGAchievementAward_Init()
		-- ***** ACHIEVEMENT_AWARD *****

		-- ***** HINT SYSTEM *****
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		local scene = Get_Game_Mode_GUI_Scene()
		Register_Hint_Context_Scene(scene)			-- Set the scene to which independant hints will be attached.
		-- ***** HINT SYSTEM *****

		Fade_Screen_Out(0)

	uea.Allow_AI_Unit_Behavior(false)
	aliens.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	novus_two.Allow_AI_Unit_Behavior(false)
	
	novus.Lock_Unit_Ability("Novus_Hero_Founder", "Novus_Founder_Retreat_From_Tactical_Ability", true, STORY)
	novus.Lock_Unit_Ability("Novus_Hero_Vertigo", "Novus_Vertigo_Retreat_From_Tactical_Ability", true, STORY)
	novus.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", true, STORY)

		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
			
		Create_Thread("Thread_Mission_Start")
	
	elseif message == OnUpdate then
	end
end


--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script
function Thread_Mission_Start()

	aliens.Allow_Autonomous_AI_Goal_Activation(false)

	failure_text="TEXT_SP_MISSION_MISSION_FAILED"

	--define defeat condifition: hero dies
	hero = Find_Hint("NOVUS_HERO_MECH", "mirabel") 
	Register_Death_Event(hero, Death_Hero)
	
	objective_a_completed=false;
	objective_b_completed=false;
	objective_c_completed=false;
	objective_d_completed=false;
	
	
	novusbase1=Find_Hint("MARKER_GENERIC","novusbase1")
		
	alien_walkers_spawned=false
	superweapon_ready=false
	
	sub_base_built=false;
	base_built=false;
	
	lastattack1=Find_Hint("MARKER_GENERIC_YELLOW","lastattack1")
	lastattack2=Find_Hint("MARKER_GENERIC_YELLOW","lastattack2")
	lastattack3=Find_Hint("MARKER_GENERIC_YELLOW","lastattack3")
	
	alienspawn1=Find_Hint("MARKER_GENERIC","alienspawn1")
	alienspawn2=Find_Hint("MARKER_GENERIC","alienspawn2")
	alienspawn3=Find_Hint("MARKER_GENERIC","alienspawn3")
	alienattack1=Find_Hint("MARKER_GENERIC","alienattack1")
	alienattack2=Find_Hint("MARKER_GENERIC","alienattack2")
	alienattack3=Find_Hint("MARKER_GENERIC","alienattack3")
	sites_defended=false;
	
	alien_spawn_brutality=Find_Hint("MARKER_GENERIC","spawnalienbrutality")
	alien_forces_brutality=Find_Hint("MARKER_GENERIC","alienbrutality")
	
	alieninvasionspawn1=Find_Hint("MARKER_GENERIC","alieninvasionspawn1")
	alieninvasionspawn2=Find_Hint("MARKER_GENERIC","alieninvasionspawn2")
	base_defended=false;
	alien_forces_defeated=0
	
	story_dialogue_first=false
	story_dialogue_last=false
	
	mission_success = false
	mission_failure = false
	time_objective_sleep = 5
	time_radar_sleep = 2
	
	reminder_wait_time=45
	
	novus.Give_Money(20000)
	
	Point_Camera_At(hero)
	Lock_Controls(1)
	Fade_Screen_Out(0)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	Transition_Cinematic_Target_Key(hero, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(hero, 0, 200, 55, 65, 1, 0, 0, 0)
	Fade_Screen_In(1) 
	Transition_To_Tactical_Camera(5)
	Sleep(1)
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()
        
        
    Create_Thread("Aliens_Attack_Resources")

    while not(objective_a_completed) do
        Sleep(1)
        if not mission_success and not mission_failure then
            if sites_defended then
                objective_a_completed=true;
            end
        end
    end
	
	Create_Thread("Aliens_Attack_Base")

    while not(objective_b_completed) do
        Sleep(1)
        if not mission_success and not mission_failure then
            if alien_forces_defeated>=2 then
                objective_b_completed=true;
            end
        end
    end

	Create_Thread("Thread_Mission_Complete")
	
end


function Aliens_Attack_Resources()
	local alienspawns1arr=Find_All_Objects_With_Hint("alienspawn1")
	alien_forces = { "ALIEN_GRUNT", "ALIEN_GRUNT", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_DEFILER" }

	for i=1, #alienspawns1arr do
		alien_forces_1 = SpawnList(alien_forces, alienspawns1arr[i].Get_Position(), aliens)
		Hunt(alien_forces_1, "PrioritiesLikeOneWouldExpectThemToBe", false, false, alienattack1, 350)
		drone=Create_Generic_Object(Find_Object_Type("ALIEN_HERO_ORLOK"), alienspawns1arr[i].Get_Position(), aliens)
			for i, unit in pairs(alien_forces_1) do
				if TestValid(unit) then
					unit.Highlight_Small(true)
				end
			end
		table.insert(alien_forces_1,drone)

		drone.Highlight(true,-50)
		drone.Move_To(alienattack1)
	end
	
	local drone_distance = drone.Get_Distance(alienattack1)
	
	aliens_left=1
	local drone_time = 0.0
	while aliens_left>0 do
		aliens_left=0
		for i, unit in pairs(alien_forces_1) do
			if TestValid(unit) then
				aliens_left=aliens_left+1
			end
		end
		
		if TestValid(drone) and GetCurrentTime() > drone_time then
			-- KDB keep giving this unit move commands
			local new_dist = drone.Get_Distance(alienattack1)
			drone_time = GetCurrentTime() + 6.0
			if new_dist > 250.0 and new_dist >= drone_distance then
				drone_distance = new_dist
				drone.Move_To(alienattack1)
			end
		end
		
		Sleep(1)
	end
	

	sites_defended=true
end


function Aliens_Attack_Base()
	alien_forces_a = Create_Generic_Object(Find_Object_Type("NM01_CUSTOM_HABITAT_WALKER"),alieninvasionspawn1.Get_Position(), aliens)
	alien_forces_a.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Death_Alien_Forces_A") 
	Create_Thread("Thread_Habitat_Walker_Produce",{alien_forces_a,2})
	--Register_Death_Event(alien_forces_a, Death_Alien_Forces_A)
	Sleep(.25)
	alien_forces_b = Create_Generic_Object(Find_Object_Type("NM01_CUSTOM_HABITAT_WALKER"),alieninvasionspawn2.Get_Position(), aliens)
	alien_forces_b.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Death_Alien_Forces_B") 
	Create_Thread("Thread_Habitat_Walker_Produce",{alien_forces_b,2})
	--Register_Death_Event(alien_forces_b, Death_Alien_Forces_B)
	alien_walkers_spawned=true
	
	Sleep(1)
	
	alien_forces_a.Add_Reveal_For_Player(novus)
	alien_forces_b.Add_Reveal_For_Player(novus)
	
	if TestValid(novusbase1) then
		alien_forces_a.Move_To(novusbase1)
		alien_forces_b.Move_To(novusbase1)
	else 
		if TestValid(hero) then
			alien_forces_a.Move_To(hero)
			alien_forces_b.Move_To(hero)
		end
	end
	
	while not story_dialogue_last do
		Sleep(1)
	end
end

function Thread_Habitat_Walker_Produced_Hunt()
	while alien_forces_defeated<2 do
		local grunts=Find_All_Objects_Of_Type("ALIEN_GRUNT")
		for i, unit in pairs(grunts) do
			Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", false, true, unit, 300)
			--unit.Guard_Target(novusbase7)
		end
		Sleep(GameRandom(5,7))
	end
end

function Thread_Habitat_Walker_Produce(params)
	local walker_obj,number = params[1],params[2]
	local prod_unit=Find_Object_Type("ALIEN_GRUNT")
	local prod_num=4
	local built={}
	local inqueue={}
	local queued=0
	local build=0
	while TestValid(walker_obj) do
		queued=0
		built=Find_All_Objects_Of_Type(prod_unit)
		inqueue=walker_obj.Tactical_Enabler_Get_Queued_Objects()
		if inqueue then
			for i, unit in pairs(inqueue) do
				if TestValid(unit) then
					if unit.Get_Type()==prod_unit then
						queued=queued+1
					end
				end
			end
		end
		if table.getn(built)>0 then 
			build=table.getn(built)/2
		else
			build=0
		end
		if (queued+build)<prod_num then
			Tactical_Enabler_Begin_Production(walker_obj, prod_unit, 1, aliens)
		end
		Sleep(GameRandom(20,25))
	end
end

function Death_Alien_Forces_A()
	alien_forces_defeated=alien_forces_defeated+1
end

function Death_Alien_Forces_B()
	alien_forces_defeated=alien_forces_defeated+1
end

--on hero death, force defeat
--jdg 12/05/07 fix for a SEGA bug where Mirabel's death would not end mission...
--had to remove/move the blockoncommand'ing of the talking heads.
function Death_Hero()
	Create_Thread("Thread_Death_Hero")
end

function Thread_Death_Hero()
	BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS01_SCENE06_14"))
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"
	if mission_failure == false then
		Create_Thread("Thread_Mission_Failed")
	end
end

function Thread_Mission_Failed()

		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
			
	mission_failure = true --this flag is what I check to make sure no game logic continues when the mission is over
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
	Play_Music("Lose_To_Alien_Event") -- this music is faction specific, use: UEA_Lose_Tactical_Event Alien_Lose_Tactical_Event Novus_Lose_Tactical_Event Masari_Lose_Tactical_Event
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,30)
	-- the variable  failure_text  is set at the start of mission to contain the default string "TEXT_SP_MISSION_MISSION_FAILED"
	-- upon mission failure of an objective, or hero death, replace the string  failure_text  with the appropriate xls tag 
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {failure_text} )
	Sleep(time_objective_sleep)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(0)
	Force_Victory(aliens)
end

function Thread_Mission_Complete()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
			
	mission_success = true --this flag is what I check to make sure no game logic continues when the mission is over
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
	Play_Music("Novus_Win_Tactical_Event") -- this music is faction specific, use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,90)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
	Sleep(time_objective_sleep)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(0)
	Force_Victory(novus)
end


--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script
function Force_Victory(player)
		if player == novus then
			Export_Base_To_Global()
			
				-- Inform the campaign script of our victory.
				global_script.Call_Function("Novus_Tactical_Mission_Over", true) -- true == player wins/false == player loses
				--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
				Quit_Game_Now(player, false, true, false)
			--end
		else
			Show_Retry_Dialog()
		end
end


function Post_Load_Callback()
	Movie_Commands_Post_Load_Callback()
end



