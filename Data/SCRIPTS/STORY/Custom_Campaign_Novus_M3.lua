
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
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_SUPERWEAPON_GRAVITY_BOMB"),true,STORY)

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
	hero1 = Find_Hint("NOVUS_HERO_MECH", "mirabel") 
	hero2 = Find_Hint("NOVUS_HERO_VERTIGO", "vertigo") 
	Register_Death_Event(hero1, Death_Hero_M)
	Register_Death_Event(hero2, Death_Hero_V)
	
	objective_a_completed=false;
	objective_b_completed=false;
	objective_c_completed=false;
	objective_d_completed=false;
	
    protect = Find_Hint("NOVUS_MEGAWEAPON", "protect")
	-- Register_Death_Event(protect, Death_Objective)
	
	base1 = Find_Hint("MASARI_KEY_INSPIRATION","destroybasemain")
	base2 = Find_Hint("MASARI_FOUNDATION","destroybasea")
	base3 = Find_Hint("MASARI_FOUNDATION","destroybaseb")
	Register_Death_Event(base1, Death_Base_1)
	Register_Death_Event(base2, Death_Base_2)
	Register_Death_Event(base3, Death_Base_3)

	object_type_enforcer = Find_Object_Type("MASARI_ENFORCER")
	object_type_enforcer_fire = Find_Object_Type("MASARI_ENFORCER_FIRE")
	object_type_enforcer_ice = Find_Object_Type("MASARI_ENFORCER_ICE")
    object_type_sentry = Find_Object_Type("MASARI_SENTRY")
    object_type_sentry_fire = Find_Object_Type("MASARI_SENTRY_FIRE")
    object_type_sentry_ice = Find_Object_Type("MASARI_SENTRY_ICE")
    object_type_peace_bringer = Find_Object_Type("MASARI_PEACEBRINGER")
    object_type_peace_bringer_fire = Find_Object_Type("MASARI_PEACEBRINGER_FIRE")
    object_type_peace_bringer_ice = Find_Object_Type("MASARI_PEACEBRINGER_ICE")
    object_type_inquisitor = Find_Object_Type("MASARI_SEEKER")
    object_type_inquisitor_fire = Find_Object_Type("MASARI_SEEKER_FIRE")
    object_type_inquisitor_ice = Find_Object_Type("MASARI_SEEKER_ICE")
    object_type_disciple = Find_Object_Type("MASARI_DISCIPLE")
    object_type_disciple_fire = Find_Object_Type("MASARI_DISCIPLE_FIRE")
    object_type_disciple_ice = Find_Object_Type("MASARI_DISCIPLE_ICE")
    vehicle_production_lista = Find_All_Objects_With_Hint("vehicleproductiona")
    vehicle_production_listb = Find_All_Objects_With_Hint("vehicleproductionb")
    vehicle_production_listc = Find_All_Objects_With_Hint("vehicleproductionc")
    air_production_list = Find_All_Objects_With_Hint("airproduction")
    infantry_production_lista = Find_All_Objects_With_Hint("infantryproductiona")
    infantry_production_listb = Find_All_Objects_With_Hint("infantryproductionb")

	walkerspawn=Find_Hint("MARKER_GENERIC","walkerspawn")
	walkerattack=Find_Hint("MARKER_GENERIC","walkerattack")

	story_dialogue_first=false
	story_dialogue_last=false
	
	mission_success = false
	mission_failure = false
	time_objective_sleep = 5
	time_radar_sleep = 2
	
	reminder_wait_time=45
	
	novus.Give_Money(10000)
	masari.Give_Money(99999)
	
	Point_Camera_At(protect)
	Lock_Controls(1)
	Fade_Screen_Out(0)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	Transition_Cinematic_Target_Key(protect, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(protect, 0, 200, 55, 65, 1, 0, 0, 0)
	Fade_Screen_In(1) 
	Transition_To_Tactical_Camera(5)
	Sleep(1)
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()
        
    Show_Objective_A()
    Create_Thread("Masari_Attack_Base")


    while not(objective_a_completed) or not(objective_b_completed) or not(objective_c_completed) do
        Sleep(1)
    end

	mission_success = true
	Create_Thread("Thread_Mission_Complete")
	
end

-- adds mission objective for objective A
function Show_Objective_A()
	objective_a = Add_Objective("TEXT_CUSTOM_CAMPAIGN_MEGAWEAPON_PROTECT")
	base1.Add_Reveal_For_Player(novus)
	Sleep(3)
	objective_a = Add_Objective("TEXT_CUSTOM_CAMPAIGN_ATTACK_BASE")
	base1.Add_Reveal_For_Player(novus)
	Sleep(3)
	objective_b = Add_Objective("TEXT_CUSTOM_CAMPAIGN_ATTACK_BASE")
	base2.Add_Reveal_For_Player(novus)
	objective_c = Add_Objective("TEXT_CUSTOM_CAMPAIGN_ATTACK_BASE")
	base3.Add_Reveal_For_Player(novus)
end


function Masari_Attack_Base()
	-- Sleep(15)
	Create_Thread("Thread_Construct_Enforcers")
	Create_Thread("Thread_Construct_Sentries")
	Create_Thread("Thread_Construct_Peace_Bringers")
	Create_Thread("Thread_Construct_Disciples_Fast")
	Create_Thread("Thread_Construct_Disciples_Slow")
	Create_Thread("Thread_Construct_Inquistors")
end


function Thread_Construct_Enforcers()
	local i, structure
	
	while not mission_success and not mission_failure do
		for i,structure in pairs(vehicle_production_listb) do
			if TestValid(structure) then
				if structure.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(structure, object_type_enforcer, 2, masari)
				end
			end
		end

		Sleep(GameRandom(10,20))
	
	end
end

function Thread_Construct_Sentries()
	local i, structure
	
	while not mission_success and not mission_failure do
		for i,structure in pairs(vehicle_production_listc) do
			if TestValid(structure) then
				if structure.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(structure, object_type_sentry, 2, masari)
				end
			end
		end

		Sleep(GameRandom(5,20))
	
	end
end

function Thread_Construct_Peace_Bringers()
	local i, structure
	
	while not mission_success and not mission_failure do
		for i,structure in pairs(vehicle_production_lista) do
			if TestValid(structure) then
				if structure.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(structure, object_type_peace_bringer, 2, masari)
				end
			end
		end

		Sleep(GameRandom(25,40))
	
	end
end

function Thread_Construct_Disciples_Slow()
	local i, structure
	
	while not mission_success and not mission_failure do
		for i,structure in pairs(infantry_production_listb) do
			if TestValid(structure) then
				if structure.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(structure, object_type_disciple, 2, masari)
				end
			end
		end

		Sleep(GameRandom(20, 30))
	
	end
end

function Thread_Construct_Disciples_Fast()
	local i, structure
	
	while not mission_success and not mission_failure do
		for i,structure in pairs(infantry_production_lista) do
			if TestValid(structure) then
				if structure.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(structure, object_type_disciple, 2, masari)
				end
			end
		end

		Sleep(GameRandom(15,20))
	
	end
end

function Thread_Construct_Inquistors()
	local i, structure
	
	while not mission_success and not mission_failure do
		for i,structure in pairs(air_production_list) do
			if TestValid(structure) then
				if structure.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(structure, object_type_inquisitor, 2, masari)
				end
			end
		end

		Sleep(GameRandom(20,50))
	
	end
end

function Story_On_Construction_Complete(obj)
	local nearest, obj_type
	
	if TestValid(obj) then
		obj_type = obj.Get_Type()
		if obj_type == object_type_enforcer or obj_type == object_type_enforcer_fire or obj_type == object_type_enforcer_ice then
      	    Hunt(obj, "AntiDefault", true, false)
        end
		if obj_type == object_type_peace_bringer or obj_type == object_type_peace_bringer_fire or obj_type == object_type_peace_bringer_ice then
      	    Hunt(obj, "AntiDefault", true, false)
        end
		if obj_type == object_type_inquisitor or obj_type == object_type_inquisitor_fire or obj_type == object_type_inquisitor_ice then
      	    Hunt(obj, "AntiDefault", true, false)
        end
        if obj_type == object_type_sentry or obj_type == object_type_sentry_fire or obj_type == object_type_sentry_ice then
		    obj.Attack_Move(protect.Get_Position())
        end
        if obj_type == object_type_disciple or obj_type == object_type_disciple_fire or obj_type == object_type_disciple_ice then
			local p = GameRandom(20,50)
			if p % 2 then
		    	obj.Attack_Move(protect.Get_Position())
			else 
				Hunt(obj, "AntiDefault", true, false)
			end
        end
   end
end


function Death_Base_1()
	objective_a_completed = true
	Objective_Complete(objective_a)
end

function Death_Base_2()
	objective_b_completed = true
	Objective_Complete(objective_b)
end

function Death_Base_3()
	objective_c_completed = true
	Objective_Complete(objective_c)
end
--on hero death, force defeat
--jdg 12/05/07 fix for a SEGA bug where Mirabel's death would not end mission...
--had to remove/move the blockoncommand'ing of the talking heads.
function Death_Hero_M()
	Create_Thread("Thread_Death_Mirabel")
end

function Death_Hero_V()
	Create_Thread("Thread_Death_Vertigo")
end

function Death_Objective()
	Create_Thread("Thread_Death_Objective")
end

function Thread_Death_Mirabel()
	BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS01_SCENE06_14"))
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"
	if mission_failure == false then
		Create_Thread("Thread_Mission_Failed")
	end
end

function Thread_Death_Vertigo()
	BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS01_SCENE06_14"))
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_VERTIGO"
	if mission_failure == false then
		Create_Thread("Thread_Mission_Failed")
	end
end

function Thread_Death_Objective()
	BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS01_SCENE06_14"))
	failure_text="TEXT_CUSTOM_CAMPAIGN_FAILED_PROTECT"
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



