
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
		Fade_Screen_Out(0)

		uea.Allow_AI_Unit_Behavior(false)
		aliens.Allow_AI_Unit_Behavior(false)
		masari.Allow_AI_Unit_Behavior(false)
		novus_two.Allow_AI_Unit_Behavior(false)
		
		novus.Lock_Unit_Ability("Novus_Hero_Founder", "Novus_Founder_Retreat_From_Tactical_Ability", true, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Vertigo", "Novus_Vertigo_Retreat_From_Tactical_Ability", true, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", true, STORY)
		novus.Lock_Object_Type(Find_Object_Type("NM04_NOVUS_PORTAL"),true,STORY)

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
	
	
	walker1 = Find_Hint("HM06_KAMAL_ASSEMBLY_WALKER","targetwalker1")
	walker2 = Find_Hint("HM06_KAMAL_ASSEMBLY_WALKER","targetwalker2")
	walker3 = Find_Hint("HM06_KAMAL_ASSEMBLY_WALKER","targetwalker3")
	Register_Death_Event(walker1, Death_Walker_1)
	Register_Death_Event(walker2, Death_Walker_2)
	Register_Death_Event(walker3, Death_Walker_3)

	walkerspawn=Find_Hint("MARKER_GENERIC","walkerspawn")
	walkerattack=Find_Hint("MARKER_GENERIC","walkerattack")

	story_dialogue_first=false
	story_dialogue_last=false
	
	mission_success = false
	mission_failure = false
	time_objective_sleep = 5
	time_radar_sleep = 2
	
	reminder_wait_time=45
	
	novus.Give_Money(5000)
	
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
        
    Show_Objective_A()
    Create_Thread("Aliens_Attack_Base")


    while not(objective_a_completed) and not(objective_b_completed) and not(objective_c_completed) do
        Sleep(1)
    end

	mission_success = true
	Create_Thread("Thread_Mission_Complete")
	
end

-- adds mission objective for objective A
function Show_Objective_A()
	Sleep(3)
	objective_a = Add_Objective("TEXT_CUSTOM_CAMPAIGN_ATTACK_WALKER")
	walker1.Add_Reveal_For_Player(novus)
	Sleep(3)
	objective_b = Add_Objective("TEXT_CUSTOM_CAMPAIGN_ATTACK_WALKER")
	walker2.Add_Reveal_For_Player(novus)
	Sleep(3)
	objective_c = Add_Objective("TEXT_CUSTOM_CAMPAIGN_ATTACK_WALKER")
	walker3.Add_Reveal_For_Player(novus)
end


function Aliens_Attack_Base()
	Sleep(15)
	alien_forces = { "ALIEN_GRUNT", "ALIEN_GRUNT", "ALIEN_GRUNT", "ALIEN_GRUNT", "Alien_RECON_TANK", "Alien_RECON_TANK" }
	alien_forces_attack = SpawnList(alien_forces, walkerspawn.Get_Position(), aliens)
	walker=Create_Generic_Object(Find_Object_Type("HM06_ORLOK_HABITAT_WALKER"), walkerspawn.Get_Position(), aliens)
	Hunt(alien_forces_attack, "PrioritiesLikeOneWouldExpectThemToBe", false, false, walkerattack, 350)
	walker.Move_To(walkerattack)
	Create_Thread("Thread_Assembly_Walker_Produce",{walker,3})

	local walker_distance = walker.Get_Distance(walkerattack)
	
	aliens_left=1
	local walker_time = 0.0
	while aliens_left>0 do
		aliens_left=0
		for i, unit in pairs(alien_forces_attack) do
			if TestValid(unit) then
				aliens_left=aliens_left+1
			end
		end
		
		if TestValid(walker) and GetCurrentTime() > walker_time then
			-- KDB keep giving this unit move commands
			local new_dist = walker.Get_Distance(walkerattack)
			walker_time = GetCurrentTime() + 6.0
			if new_dist > 250.0 and new_dist >= walker_distance then
				walker_distance = new_dist
				walker.Move_To(walkerattack)
			end
		end
		
		Sleep(1)
	end
	
	Sleep(30)
	if not(mission_success) and not(mission_failure) then
    	Create_Thread("Aliens_Attack_Base")
	end
end

function Thread_Assembly_Walker_Produced_Hunt()
	while true do
		local saucers=Find_All_Objects_Of_Type("ALIEN_FOO_CORE")
		for i, unit in pairs(saucers) do
			Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", false, true, unit, 300)
			--unit.Guard_Target(novusbase7)
		end
		Sleep(GameRandom(5,7))
	end
end

function Thread_Assembly_Walker_Produce(params)
	local walker_obj,number = params[1],params[2]
	local prod_unit=Find_Object_Type("ALIEN_FOO_CORE")
	local prod_num=6
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


function Death_Walker_1()
	objective_a_completed = true
	Objective_Complete(objective_a)
end

function Death_Walker_2()
	objective_b_completed = true
	Objective_Complete(objective_b)
end

function Death_Walker_3()
	objective_c_completed = true
	Objective_Complete(objective_c)
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
			-- Inform the campaign script of our victory.
			global_script.Call_Function("Novus_Tactical_Mission_Over", true) -- true == player wins/false == player loses
			--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
			Quit_Game_Now(player, false, true, false)
		else
			Show_Retry_Dialog()
		end
end


function Post_Load_Callback()
	Movie_Commands_Post_Load_Callback()
end



