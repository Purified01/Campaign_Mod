-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM01.lua#80 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM01.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Dan_Etter $
--
--            $Change: 90967 $
--
--          $DateTime: 2008/01/14 15:45:22 $
--
--          $Revision: #80 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

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

	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_SIGNAL_TOWER"),false,STORY)
	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_INPUT_STATION"),true,STORY)
	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_ROBOTIC_ASSEMBLY"),true,STORY)
	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_POWER_ROUTER"),true,STORY)
	-- Lock_Objects(true)
	
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

	UI_Hide_Research_Button()
	UI_Hide_Sell_Button()

	failure_text="TEXT_SP_MISSION_MISSION_FAILED"

	--define defeat condifition: hero dies
	hero = Find_Hint("NOVUS_HERO_MECH", "mirabel") 
	-- heroes nerfed late, so adding damage modifier, Mirabel old health(1800) / Mirabel new health(1000) - 1 = -.45
	if TestValid(hero) then hero.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.45) end
	
	--Point_Camera_At(hero)
	Register_Death_Event(hero, Death_Hero)
	
	super = Find_Hint("NM01_GRAVITY_BOMB","super")
	
	objective_a_completed=false;
	objective_b_completed=false;
	objective_c_completed=false;
	objective_csub_completed=false;
	objective_d_completed=false;
	
	buildtower=Find_Hint("MARKER_GENERIC","buildtower2")
	tower_built=false;
	buildpower=Find_Hint("MARKER_GENERIC","buildpower")
	power_built=false;
	
	transportspawn=Find_Hint("MARKER_GENERIC","transportspawn")
	
	novusbase1=Find_Hint("MARKER_GENERIC","novusbase1")
		
	buildinput1=Find_Hint("MARKER_GENERIC","buildinput1")
	buildinput2=Find_Hint("MARKER_GENERIC","buildinput2")
	alien_walkers_spawned=false
	superweapon_ready=false
	
	sub_base_built=false;
	base_built=false;
	used_flow_a=false;
	used_flow_b=false;
	used_flow_c=false;
	power_router_destroyed=false;
	
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
	
	Create_Thread("Setup_Military_Attacks")
	
	novus.Make_Ally(civilian)
	novus.Make_Ally(novus_two)
	uea.Make_Ally(novus_two)
	novus.Make_Ally(uea)
	
	-- Maximum saucers alive for attack
	max_saucers = 15
	cur_saucers = 0
	
	--set low civ population on large maps (esp single player)
	Spawn_Civilians_Automatically(true)
	Set_Desired_Civilian_Population(30)
	
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
	Create_Thread("Audio_Objective_A")
	Sleep(4)
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()
	
	Create_Thread("Maintain_Constructors")
	
if true  then
	
	Show_Objective_A()
	Add_Independent_Hint(HINT_NM01_BUILDING_STRUCTURES)
	Add_Independent_Hint(HINT_NM01_POWER_NETWORK)

	UI_Start_Flash_Queue_Buttons("NOVUS_SIGNAL_TOWER")
	Create_Thread("Highlight_Constructors")

	while not(objective_a_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if tower_built then
				Create_Thread("Audio_Objective_Done")
				Set_Objective_Text(nov01_objective_a, "TEXT_SP_MISSION_NVS01_OBJECTIVE_A")
				Objective_Complete(nov01_objective_a)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_A_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_a_completed=true;
			end
		end
	end
	
	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_INPUT_STATION"),false,STORY)
	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_ROBOTIC_ASSEMBLY"),true,STORY)
	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_POWER_ROUTER"),true,STORY)
	-- Lock_Objects(true)
	Create_Thread("Audio_Objective_B_Sub")
	Sleep(1)
	Show_Objective_B_Sub()
	--Add_Independent_Hint(HINT_SYSTEM_NOVUS_MULTIPLE_CONSTRUCTORS)
	UI_Start_Flash_Queue_Buttons("NOVUS_INPUT_STATION")
	Create_Thread("Highlight_Constructors")
	
	while not(objective_bsub_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			--novus_built_input = Find_All_Objects_Of_Type("NOVUS_INPUT_STATION")
			if not sub_base_built then
				--if not (last_sub_base_built==table.getn(novus_built_input)) then
					if (not input1_built and not input2_built) then
						Set_Objective_Text(nov01_objective_bsub, "TEXT_SP_MISSION_NVS01_OBJECTIVE_BSUB_STATE_1")
					end
					if (input1_built or input2_built) then
						Set_Objective_Text(nov01_objective_bsub, "TEXT_SP_MISSION_NVS01_OBJECTIVE_BSUB_STATE_2")
					end
					if (input1_built and input2_built) then
						sub_base_built = true
						Set_Objective_Text(nov01_objective_bsub, "TEXT_SP_MISSION_NVS01_OBJECTIVE_BSUB")
					end
					--last_sub_base_built=table.getn(novus_built_input)
				--end
			else
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE06_16"))
				Sleep(time_radar_sleep)
				Set_Objective_Text(nov01_objective_bsub, "TEXT_SP_MISSION_NVS01_OBJECTIVE_BSUB")
				Objective_Complete(nov01_objective_bsub)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_BSUB_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_bsub_completed=true;
			end
		end
	end

	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_INPUT_STATION"),false,STORY)
	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_ROBOTIC_ASSEMBLY"),false,STORY)
	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_POWER_ROUTER"),true,STORY)
	-- Lock_Objects(true)
	Create_Thread("Audio_Objective_B")
	Sleep(1)
	Show_Objective_B()
	--Add_Independent_Hint(HINT_SYSTEM_RESOURCES)
	UI_Start_Flash_Queue_Buttons("NOVUS_ROBOTIC_ASSEMBLY")
	Create_Thread("Highlight_Constructors")
	
	while not(objective_b_completed) do
		if not mission_success and not mission_failure then
			novus_built_assemblies = Find_All_Objects_Of_Type("NOVUS_ROBOTIC_ASSEMBLY")
			novus_built_assembly=0
			for i, unit in pairs(novus_built_assemblies) do
				if unit.Get_Attribute_Integer_Value("Is_Powered") == 1.0 then
					novus_built_assembly = novus_built_assembly + 1
				end
			end
			
			if not base_built then
					if novus_built_assembly==0 then
						Set_Objective_Text(nov01_objective_b, "TEXT_SP_MISSION_NVS01_OBJECTIVE_B_STATE_1")
					end
					if novus_built_assembly==1 then
						Set_Objective_Text(nov01_objective_b, "TEXT_SP_MISSION_NVS01_OBJECTIVE_B_STATE_2")
					end
					if novus_built_assembly>=2 then
						base_built = true
						Set_Objective_Text(nov01_objective_b, "TEXT_SP_MISSION_NVS01_OBJECTIVE_B")
					end
			else
				if story_dialogue_first then
					Create_Thread("Audio_Objective_Done")
					Sleep(time_radar_sleep)
					Set_Objective_Text(nov01_objective_b, "TEXT_SP_MISSION_NVS01_OBJECTIVE_B")
					Objective_Complete(nov01_objective_b)
					Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_B_COMPLETE"} )
					Sleep(time_objective_sleep)
					--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
					objective_b_completed=true;
				end
			end
		end
		Sleep(1)
	end

	Sleep(1)
	Show_Objective_C()
	--Add_Independent_Hint(HINT_SYSTEM_CONSTRUCTING_UNITS)
	UI_Start_Flash_Queue_Buttons("NOVUS_ROBOTIC_ASSEMBLY", "NOVUS_ROBOTIC_INFANTRY")
	Create_Thread("Track_Building_Robots")
	Create_Thread("Aliens_Attack_Resources")
	
	while not(objective_c_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if sites_defended then
				Create_Thread("Audio_Objective_Done")
				Sleep(time_radar_sleep)
				Set_Objective_Text(nov01_objective_c, "TEXT_SP_MISSION_NVS01_OBJECTIVE_C")
				Objective_Complete(nov01_objective_c)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_C_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_c_completed=true;
			end
		end
	end
	
end
		 
	
	Show_Objective_D()
	
	Create_Thread("Delete_Hulks")
	Create_Thread("Saucers_Kill_Power")
	while not power_router_destroyed do
		Sleep(1)
	end
	Show_Objective_C_Sub()
	
	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_INPUT_STATION"),false,STORY)
	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_ROBOTIC_ASSEMBLY"),false,STORY)
	-- novus.Lock_Object_Type(Find_Object_Type("NOVUS_POWER_ROUTER"),false,STORY)
	-- Lock_Objects(true)
	UI_Start_Flash_Queue_Buttons("NOVUS_POWER_ROUTER")
	
	while not(objective_csub_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if power_built then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE06_10"))
				Sleep(time_radar_sleep)
				Set_Objective_Text(nov01_objective_csub, "TEXT_SP_MISSION_NVS01_OBJECTIVE_CSUB")
				Objective_Complete(nov01_objective_csub)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_CSUB_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_csub_completed=true;
			end
		end
	end
	
	Create_Thread("Activate_Super")
	Sleep(1)
	Create_Thread("Aliens_Attack_Base")
	UI_Start_Flash_Superweapon("NM01_GRAVITY_BOMB")
	
	while not(objective_d_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if 	alien_forces_defeated==2 then
				Set_Objective_Text(nov01_objective_d, "TEXT_SP_MISSION_NVS01_OBJECTIVE_D")
				Objective_Complete(nov01_objective_d)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_D_COMPLETE"} )
				--Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_d_completed=true;
			end
		end
		
		command=Find_First_Object("NOVUS_REMOTE_TERMINAL")
		if not TestValid(command) then
			failure_text="TEXT_SP_MISSION_NVS01_OBJECTIVE_D_FAIL"
			if mission_failure == false then
				Create_Thread("Thread_Mission_Failed")
			end
		end
	end
	
	Sleep(2)
	hero.Set_Cannot_Be_Killed(true)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE05_04"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE05_05"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE05_06"))
	end
	Create_Thread("Thread_Mission_Complete");
	
end

function Delete_Hulks()
	while not objective_csub_completed do
		trigger_obj=Find_First_Object("ALIEN_FOO_CORE_DEATH_CLONE")
		if TestValid(trigger_obj) then
			trigger_obj.Despawn()
		end
		Sleep(1/2)
	end
end

function Maintain_Constructors()
	transport_enroute=false
	while true do
		local constructors=Find_All_Objects_Of_Type("NOVUS_CONSTRUCTOR")
		if not transport_enroute then
			if table.getn(constructors)<2 then
				transport_enroute=true
				Create_Thread("Reinforce_Shuttle",{Find_Object_Type("NOVUS_CONSTRUCTOR"),2})
			end
		end
		Sleep(5)
	end
end

function Reinforce_Shuttle(obj_list)
	obj_type,obj_num=obj_list[1],obj_list[2]
	transport=Create_Generic_Object("Novus_Air_Retreat_Transport",transportspawn,novus)
	transport.Set_Selectable(false)
	while TestValid(hero) and TestValid(transport) do
		if transport.Get_Distance(hero)>200 then
			BlockOnCommand(transport.Move_To(hero))
		else
			Raise_Game_Event("Reinforcements_Arrived", novus, transport.Get_Position())
			for i=1, obj_num do
				object=Create_Generic_Object(Find_Object_Type("NOVUS_CONSTRUCTOR"),transport,novus)
				Sleep(.5)
			end
			if TestValid(transport) then
				BlockOnCommand(transport.Move_To(transportspawn))
				if TestValid(transport) then
					transport.Despawn()
				end
				transport_enroute=false
			else
				transport_enroute=false
			end
		end
	end
end

function Highlight_Constructors()
	constructors=Find_All_Objects_Of_Type("NOVUS_CONSTRUCTOR")
	for i, unit in pairs(constructors) do
		if TestValid(unit) then
			unit.Highlight_Small(true)
		end
	end
	Sleep(10)
	for i, unit in pairs(constructors) do
		if TestValid(unit) then
			unit.Highlight_Small(false)
		end
	end
end

function Saucers_Kill_Power()
	alien_forces = { "ALIEN_DEFILER", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE",
					"ALIEN_DEFILER", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_DEFILER" }
	alien_brutality = SpawnList(alien_forces, alien_spawn_brutality.Get_Position(), aliens)
	for i, unit in pairs(alien_brutality) do
		if TestValid(unit) then
			Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", true, true, unit, 300)
		end
	end

	Add_Radar_Blip(alien_forces_brutality, "Default_Beacon_Placement", "blip_objective_c")
	Sleep(1)
	
	--insert story moment here
	if true then
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE04_01"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE04_02"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE04_03"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE04_04"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE04_05"))
		end
		
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE04_06"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE04_07"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE04_08"))
		end

		Create_Thread("Spawn_Foos")

		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE04_09"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE04_10"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE04_11"))
		end
		
		Create_Thread("Audio_Saucers_Attack")
	end

	router = Find_First_Object("NOVUS_POWER_ROUTER")
	router.Register_Signal_Handler(On_Power_Router_Destroyed, "OBJECT_DELETE_PENDING")

end

function On_Saucer_Death(unit)
	local alienspawns=Find_All_Objects_With_Hint("saucerspawn")
	local alienspawns_num = table.getn(alienspawns)
	
	cur_saucers = cur_saucers - 1
	if TestValid(router) then 
		if cur_saucers < max_saucers then
			for i=1, 3 do
				saucer=Create_Generic_Object(Find_Object_Type("ALIEN_FOO_CORE"), alienspawns[GameRandom(1,alienspawns_num)].Get_Position(), aliens)
				saucer.Attack_Target(router) 
			end
		end
	end
end

function On_Power_Router_Destroyed(router)
	power_router_destroyed = true
	saucers=Find_All_Objects_Of_Type("ALIEN_FOO_CORE")
	for units, unit in pairs(saucers) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(true)
			unit.Register_Signal_Handler(On_Foo_Core_Arrival, "OBJECT_MOVEMENT_FINISHED")
		end
	end
	Create_Thread("GTFO")
end

function GTFO()
	saucer_goto=Find_Hint("MARKER_GENERIC","saucergoto")
	Formation_Move(saucers, saucer_goto) --Blocking
end

function On_Foo_Core_Arrival(unit)
	if TestValid(unit) then
		unit.Despawn()
	end
end

function Spawn_Foos()
	local alienspawns=Find_All_Objects_With_Hint("saucerspawn")
	local alienspawns_num = table.getn(alienspawns)
	
	router=Find_First_Object("NOVUS_POWER_ROUTER")
	if TestValid(router) then
		for i=1, 5 do
			saucer=Create_Generic_Object(Find_Object_Type("ALIEN_FOO_CORE"), alienspawns[GameRandom(1,alienspawns_num)].Get_Position(), aliens)
			if TestValid(router) then saucer.Attack_Target(router) end
			saucer.Register_Signal_Handler(On_Saucer_Death, "OBJECT_DELETE_PENDING")
			Sleep(.5)
			saucer=Create_Generic_Object(Find_Object_Type("ALIEN_FOO_CORE"), alienspawns[GameRandom(1,alienspawns_num)].Get_Position(), aliens)		
			if TestValid(router) then saucer.Attack_Target(router) end
			saucer.Register_Signal_Handler(On_Saucer_Death, "OBJECT_DELETE_PENDING")
			Sleep(.5)
			saucer=Create_Generic_Object(Find_Object_Type("ALIEN_FOO_CORE"), alienspawns[GameRandom(1,alienspawns_num)].Get_Position(), aliens)		
			if TestValid(router) then saucer.Attack_Target(router) end
			saucer.Register_Signal_Handler(On_Saucer_Death, "OBJECT_DELETE_PENDING")
			Sleep(.5)
			cur_saucers = cur_saucers + 3
		end
	end
end

function Setup_Military_Attacks()
	human_forces = { "MILITARY_APACHE" }
	spawns=Find_All_Objects_With_Hint("militaryspawn")
	for units, unit in pairs(spawns) do
		if TestValid(unit) then
			military_forces = SpawnList(human_forces, unit.Get_Position(), uea)
			Hunt(military_forces, "PrioritiesLikeOneWouldExpectThemToBe", true, true, unit, 200)
		end
	end
	
	while not objective_b_completed do
		Sleep(5)
	end
	Sleep(20)
	
	spawns=Find_All_Objects_Of_Type(uea, "CanAttack")
	for units, unit in pairs(spawns) do
		if TestValid(unit) then
			Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", true, true, alien_spawn_brutality, 300)
		end
	end
	uea.Make_Ally(novus)
	
	while not alien_walkers_spawned do
		Sleep(1)
	end
	
	spawns=Find_All_Objects_Of_Type(uea, "CanAttack")
	for units, unit in pairs(spawns) do
		if TestValid(unit) then
			if GameRandom(1,2)<2 then
				Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", true, true, alien_forces_b, 100)
			else
				Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", true, true, alien_forces_b, 100)
			end
		end
	end
	
	while not superweapon_ready do
		Sleep(1)
	end
	
	spawns=Find_All_Objects_Of_Type(uea, "CanAttack")
	for units, unit in pairs(spawns) do
		if TestValid(unit) then
			Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", true, true, saucer_goto, 300)
		end
	end
end

-- adds mission objective for objective A
function Show_Objective_A()
	buildtower_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), buildtower, neutral)
	
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_A_ADD"} )
	Sleep(time_objective_sleep)
	nov01_objective_a = Add_Objective("TEXT_SP_MISSION_NVS01_OBJECTIVE_A")
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	
	Add_Radar_Blip(buildtower, "DEFAULT", "blip_objective_a_b")
	buildtower.Highlight(true)
	
end

function Story_On_Construction_Complete(obj)
	local obj_type
	if TestValid(obj) then
		if obj.Get_Owner().Get_Faction_Name() == "NOVUS" then
			obj_type = obj.Get_Type()
			if not tower_built then
				if obj_type == Find_Object_Type("Novus_Signal_Tower") then
					Create_Thread("Tower_Built_Check", obj)
				end
			end
			if (tower_built) and not (input1_built and input2_built) then
				if obj_type == Find_Object_Type("Novus_Signal_Tower") then
					Create_Thread("Tower_Built_Check_Input", obj)
				end
				if obj_type == Find_Object_Type("Novus_Input_Station") then
					Create_Thread("Input_Built_Check", obj)
				end
			end
			if power_router_destroyed and not power_built then
				if not (obj_type == Find_Object_Type("Novus_Power_Router")) then
					Create_Thread("Power_Built_Check_Other", obj)
				end
			end
		end
	end
end

function Power_Built_Check_Other(other)
	if TestValid(other) then
		if (other.Get_Distance(buildpower)<60) then
			novus.Give_Money(other.Get_Type().Get_Tactical_Build_Cost())
			other.Take_Damage(9999)
			if not mission_success and not mission_failure then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE06_09"))
			end
		end
	end
end

function Tower_Built_Check(tower)
	if TestValid(tower) then
		if (tower.Get_Distance(buildtower)<60) then
			tower_built=true;
			Remove_Radar_Blip("blip_objective_a_b")
			buildtower.Highlight(false)
			if TestValid(buildtower_area) then buildtower_area.Despawn() end
		else
			tower.Take_Damage(9999)
			novus.Give_Money(Find_Object_Type("NOVUS_SIGNAL_TOWER").Get_Tactical_Build_Cost())
			if not mission_success and not mission_failure then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_03"))
			end
		end
	end
end

function Input_Built_Check(input)
	if TestValid(input) then
		if (input.Get_Distance(buildinput1)<50) then
			input1_built=true;
			Remove_Radar_Blip("blip_objective_b_a")
			if TestValid(buildinput1_area) then buildinput1_area.Despawn() end
			buildinput1.Highlight(false)
		elseif (input.Get_Distance(buildinput2)<50) then
			input2_built=true;
			Remove_Radar_Blip("blip_objective_b_b")
			if TestValid(buildinput2_area) then buildinput2_area.Despawn() end
			buildinput2.Highlight(false)
		else
			input.Take_Damage(9999)
			novus.Give_Money(Find_Object_Type("NOVUS_INPUT_STATION").Get_Tactical_Build_Cost())
			if not mission_success and not mission_failure then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS03_SCENE12_11"))
			end
		end
	end
end

function Tower_Built_Check_Input(tower)
	if TestValid(tower) then
		if (tower.Get_Distance(buildinput1)<60 or tower.Get_Distance(buildinput2)<60) then
			tower.Take_Damage(9999)
			novus.Give_Money(Find_Object_Type("NOVUS_SIGNAL_TOWER").Get_Tactical_Build_Cost())
			if not TestValid(buildinput1_area) then buildinput1_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), buildinput1, neutral) end
			if not TestValid(buildinput2_area) then buildinput2_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), buildinput2, neutral) end
		end
	end
end


-- adds mission objective for objective B
function Show_Objective_B_Sub()
	buildinput1_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), buildinput1, neutral)
	buildinput2_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), buildinput2, neutral)
	
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_BSUB_ADD"} )
	Sleep(time_objective_sleep)
	nov01_objective_bsub = Add_Objective("TEXT_SP_MISSION_NVS01_OBJECTIVE_BSUB_STATE_1")
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	
	Add_Radar_Blip(buildinput1, "DEFAULT", "blip_objective_b_a")
	buildinput1.Highlight(true)
	Add_Radar_Blip(buildinput2, "DEFAULT", "blip_objective_b_b")
	buildinput2.Highlight(true)
	
	--Register_Prox(buildinput1, Prox_Input_Built_1, 50, novus)
	--Register_Prox(buildinput2, Prox_Input_Built_2, 50, novus)
end

function Prox_Input_Built_1(prox_obj,trigger_obj)
	-- Check to make sure the object is alive and not a hardpoint
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Type()==Find_Object_Type("NOVUS_INPUT_STATION") then
			if trigger_obj.Get_Attribute_Integer_Value("Is_Powered") == 1.0 then
				input1_built=true;
				Remove_Radar_Blip("blip_objective_b_a")
				if TestValid(buildinput1_area) then buildinput1_area.Despawn() end
				buildinput1.Highlight(false)
				prox_obj.Cancel_Event_Object_In_Range(Prox_Input_Built_1)
			end
		end
	end
end


-- adds mission objective for objective B
function Show_Objective_B()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_B_ADD"} )
	Sleep(time_objective_sleep)
	nov01_objective_b = Add_Objective("TEXT_SP_MISSION_NVS01_OBJECTIVE_B_STATE_1")
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

-- adds mission objective for objective C
function Show_Objective_C()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_C_ADD"} )
	Sleep(time_objective_sleep)
	nov01_objective_c = Add_Objective("TEXT_SP_MISSION_NVS01_OBJECTIVE_C")
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

function Aliens_Attack_Resources()
	if not mission_success and not mission_failure then
		Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_11")
	end
	if not mission_success and not mission_failure then
		Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_12")
	end
	if not mission_success and not mission_failure then
		Queue_Talking_Head(pip_mirabel, "NVS01_SCENE06_13")
	end
	
	local alienspawns1arr=Find_All_Objects_With_Hint("alienspawn1")
	alien_forces = { "ALIEN_GRUNT", "ALIEN_GRUNT", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_DEFILER" }

	for i=1, #alienspawns1arr do
		alien_forces_1 = SpawnList(alien_forces, alienspawns1arr[i].Get_Position(), aliens)
		Hunt(alien_forces_1, "PrioritiesLikeOneWouldExpectThemToBe", false, false, alienattack1, 350)
		drone=Create_Generic_Object(Find_Object_Type("ALIEN_SCAN_DRONE"), alienspawns1arr[i].Get_Position(), aliens)
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
	
	Add_Radar_Blip(alienattack1, "DEFAULT", "blip_objective_c")
	--alienattack1.Highlight(true, -50)
	Register_Prox(alienattack1, Prox_Used_Flow_A, 250, novus)
	--Add_Independent_Hint(HINT_SYSTEM_SHARED_ABILITIES)
	--Add_Independent_Hint(HINT_SYSTEM_SHARED_TARGETING)

	times=0
	aliens_left=1
	local drone_time = 0.0
	while aliens_left>0 do
		aliens_left=0
		for i, unit in pairs(alien_forces_1) do
			if TestValid(unit) then
				aliens_left=aliens_left+1
				_CustomScriptMessage("JoeLog.txt", string.format("tick %d-%d",i,times))
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
		_CustomScriptMessage("JoeLog.txt", string.format("aliens left: %d \n",aliens_left))
		times=times+1
	end
	--alienattack1.Highlight(false)
	Remove_Radar_Blip("blip_objective_c")
	
	if not mission_success and not mission_failure then
		Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_20")
	end
	Sleep(3)
	if not mission_success and not mission_failure then
		Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_21")
	end
	--Create_Thread("Audio_Flow_Late_B")
	alien_forces = { "ALIEN_GRUNT", "ALIEN_GRUNT", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_DEFILER" }
	alien_forces_2 = SpawnList(alien_forces, alienspawn2.Get_Position(), aliens)
	Hunt(alien_forces_2, "PrioritiesLikeOneWouldExpectThemToBe", false, false, alienattack2, 350)
	drone=Create_Generic_Object(Find_Object_Type("ALIEN_SCAN_DRONE"), alienspawn2.Get_Position(), aliens)
		for i, unit in pairs(alien_forces_2) do
			if TestValid(unit) then
				unit.Highlight_Small(true)
			end
		end
	table.insert(alien_forces_2,drone)
	drone.Move_To(alienattack2)
	drone.Highlight(true,-50)
	Remove_Radar_Blip("blip_objective_c")
	--alienattack2.Highlight(true, -50)
	Add_Radar_Blip(alienattack2, "DEFAULT", "blip_objective_c")
	Register_Prox(alienattack2, Prox_Used_Flow_B, 250, novus)
	--Add_Independent_Hint(HINT_SYSTEM_RADAR_MOVEMENT)
	
	aliens_left=1
	while aliens_left>0 do
		aliens_left=0
		for i, unit in pairs(alien_forces_2) do
			if TestValid(unit) then
				aliens_left=aliens_left+1
			end
		end
		Sleep(1)
		_CustomScriptMessage("JoeLog.txt", string.format("aliens left: %d \n",aliens_left))
	end
	--alienattack2.Highlight(false)
	Remove_Radar_Blip("blip_objective_c")

	Remove_Radar_Blip("blip_objective_c")

	if not mission_success and not mission_failure then
		Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_24")
	end
	alien_forces = { "ALIEN_GRUNT", "ALIEN_GRUNT", "ALIEN_GRUNT", "ALIEN_LOST_ONE", 
					"ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_DEFILER" }
	alien_forces_3 = SpawnList(alien_forces, alienspawn3.Get_Position(), aliens)
	Hunt(alien_forces_3, "PrioritiesLikeOneWouldExpectThemToBe", false, false, alienattack3, 350)
	drone=Create_Generic_Object(Find_Object_Type("ALIEN_SCAN_DRONE"), alienspawn3.Get_Position(), aliens)
		for i, unit in pairs(alien_forces_3) do
			if TestValid(unit) then
				unit.Highlight_Small(true)
			end
		end
	table.insert(alien_forces_3,drone)
	drone.Move_To(alienattack3)
	drone.Highlight(true,-50)
	Remove_Radar_Blip("blip_objective_c")
	Add_Radar_Blip(alienattack3, "DEFAULT", "blip_objective_c")
	--alienattack3.Highlight(true, -50)
	Register_Prox(alienattack3, Prox_Used_Flow_C, 250, novus)
	
	aliens_left=1
	while aliens_left>0 do
		aliens_left=0
		for i, unit in pairs(alien_forces_3) do
			if TestValid(unit) then
				aliens_left=aliens_left+1
			end
		end
		Sleep(1)
		_CustomScriptMessage("JoeLog.txt", string.format("aliens left: %d \n",aliens_left))
	end
	--alienattack3.Highlight(false)
	Remove_Radar_Blip("blip_objective_c")

	sites_defended=true
end

function Track_Building_Robots()
	assemblies=Find_All_Objects_Of_Type("NOVUS_ROBOTIC_ASSEMBLY")
	for i, robot in pairs(assemblies) do
		robot.Highlight(true, -50)
	end
	
	bots = Find_First_Object("NOVUS_ROBOTIC_INFANTRY")
	while not TestValid(bots) do
		Sleep(reminder_wait_time)
		bots = Find_First_Object("NOVUS_ROBOTIC_INFANTRY")
	end
	
	for i, structures in pairs(assemblies) do
		structures.Highlight(false)
	end
	
	Sleep(1)
	robot=Find_First_Object("NOVUS_ROBOTIC_INFANTRY")
	Add_Independent_Hint(HINT_NM01_FLOW)
	Create_Thread("Audio_Demonstrate_Flow")
end

function Prox_Used_Flow_A(prox_obj,trigger_obj)
	-- Check to make sure the object is alive and not a hardpoint
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Type()==Find_Object_Type("NOVUS_ROBOTIC_INFANTRY") then
			if TestValid(hero) then
				if not mission_success and not mission_failure then
					Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_29")
				end
			end
			used_flow_a=true;
			prox_obj.Cancel_Event_Object_In_Range(Prox_Used_Flow_A)
		end
	end
end

function Prox_Used_Flow_B(prox_obj,trigger_obj)
	-- Check to make sure the object is alive and not a hardpoint
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Type()==Find_Object_Type("NOVUS_ROBOTIC_INFANTRY") then
			used_flow_b=true;
			prox_obj.Cancel_Event_Object_In_Range(Prox_Used_Flow_B)
		end
	end
end

function Prox_Used_Flow_C(prox_obj,trigger_obj)
	-- Check to make sure the object is alive and not a hardpoint
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Type()==Find_Object_Type("NOVUS_ROBOTIC_INFANTRY") then
			used_flow_c=true;
			prox_obj.Cancel_Event_Object_In_Range(Prox_Used_Flow_C)
		end
	end
end

-- adds mission objective for objective C Sub Mission
function Show_Objective_C_Sub()
	buildpower_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), buildpower, neutral)

	local obj_list = Find_All_Objects_Of_Type(buildpower, 80.0, "Stationary")

	-- get rid of structures too close to power router build area
	if obj_list then
		for _, unit in pairs (obj_list) do
			if TestValid( unit ) then
				unit.Take_Damage(999999)
			end
		end
	end
	
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_CSUB_ADD"} )
	Sleep(time_objective_sleep)
	nov01_objective_csub = Add_Objective("TEXT_SP_MISSION_NVS01_OBJECTIVE_CSUB")
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	
	Add_Radar_Blip(buildpower, "DEFAULT", "blip_objective_csub")
	buildpower.Highlight(true)
	
	Register_Prox(buildpower, Prox_Power_Built, 60, novus)
	
end

function Prox_Power_Built(prox_obj,trigger_obj)
	-- Check to make sure the object is alive and not a hardpoint
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Type()==Find_Object_Type("NOVUS_POWER_ROUTER") then
			Create_Thread("Power_Built_Check",trigger_obj)
			prox_obj.Cancel_Event_Object_In_Range(Prox_Power_Built)
		end
	end
end

function Power_Built_Check(router)
	Sleep(1)
	local target=Find_First_Object("NM01_GRAVITY_BOMB")
	if ((target.Get_Attribute_Integer_Value("Is_Powered") == 1.0) and (super.Get_Attribute_Integer_Value("Is_Powered") == 1.0)) then
		power_built=true;
		Remove_Radar_Blip("blip_objective_csub")
		buildpower.Highlight(false)
		if TestValid(buildpower_area) then buildpower_area.Despawn() end
	else
		router.Take_Damage(9999)
		novus.Give_Money(Find_Object_Type("Novus_Power_Router").Get_Tactical_Build_Cost())
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE06_07"))
		end
		Sleep(1)
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE06_09"))
		end
		Register_Prox(buildpower, Prox_Power_Built, 60, novus)
	end
end

-- adds mission objective for objective C
function Show_Objective_D()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS01_OBJECTIVE_D_ADD"} )
	Sleep(time_objective_sleep)
	nov01_objective_d = Add_Objective("TEXT_SP_MISSION_NVS01_OBJECTIVE_D")
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

function Activate_Super()
	Add_Attached_GUI_Hint(PG_GUI_HINT_SUPERWEAPON_BUTTON, "NM01_GRAVITY_BOMB_VARIANT", HINT_BUILT_NOVUS_BLACK_HOLE_GENERATOR)

	if not objective_d_completed and not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_31"))
	end
	if not objective_d_completed and not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_40"))
	end
	Add_Radar_Blip(super, "DEFAULT", "blip_objective_d")
	super.Change_Owner(novus)
	if not objective_d_completed and not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_39"))
	end
	story_dialogue_last=true
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
	
	--track gravity bomb and record time left
	gravitybomb=Find_First_Object("NM01_GRAVITY_BOMB")
	gravitybomb.Highlight(true, -50)
	player = hero.Get_Owner()
	player_script = player.Get_Script()

	hps_a=Find_All_Objects_Of_Type("ALIEN_WALKER_HABITAT_BACK_HP01")
	hps_b=Find_All_Objects_Of_Type("ALIEN_WALKER_HABITAT_BACK_HP02")
	for ni,nunit in pairs(hps_a) do
		nunit.Take_Damage(9999)
	end
	for ni,nunit in pairs(hps_b) do
		nunit.Take_Damage(9999)
	end
	alien_forces_a.Override_Max_Speed(.4)
	alien_forces_b.Override_Max_Speed(.4)
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
	best_time_max = player_script.Call_Function("SW_Get_Cooldown_Time", "NM01_GRAVITY_BOMB_VARIANT" )
	best_time=best_time_max
		while (best_time>(best_time_max*.75)) do
			Sleep(1)
			best_time = player_script.Call_Function("SW_Get_Cooldown_Time", "NM01_GRAVITY_BOMB_VARIANT" )
			_CustomScriptMessage("JoeLog.txt", string.format("1 time left: %d",best_time))
		end
		if not mission_success and not mission_failure then
			if story_dialogue_last and TestValid(hero) then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_41"))
			end
		end
		
	best_time = player_script.Call_Function("SW_Get_Cooldown_Time", "NM01_GRAVITY_BOMB_VARIANT" )
		while (best_time>(best_time_max*.50)) do
			Sleep(1)
			best_time = player_script.Call_Function("SW_Get_Cooldown_Time", "NM01_GRAVITY_BOMB_VARIANT" )
			_CustomScriptMessage("JoeLog.txt", string.format("2 time left: %d",best_time))
		end
		if not mission_success and not mission_failure then
			if story_dialogue_last and TestValid(hero) then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_42"))
			end
		end
	best_time = player_script.Call_Function("SW_Get_Cooldown_Time", "NM01_GRAVITY_BOMB_VARIANT" )
		while (best_time>(best_time_max*.25)) do
			Sleep(1)
			best_time = player_script.Call_Function("SW_Get_Cooldown_Time", "NM01_GRAVITY_BOMB_VARIANT" )
			_CustomScriptMessage("JoeLog.txt", string.format("3 time left: %d",best_time))
		end
		if not mission_success and not mission_failure then
			if story_dialogue_last and TestValid(hero) then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_41"))
			end
		end
	best_time = player_script.Call_Function("SW_Get_Cooldown_Time", "NM01_GRAVITY_BOMB_VARIANT" )
		while (best_time>0) do
			Sleep(1)
			best_time = player_script.Call_Function("SW_Get_Cooldown_Time", "NM01_GRAVITY_BOMB_VARIANT" )
			_CustomScriptMessage("JoeLog.txt", string.format("4 time left: %d",best_time))
		end
		if not mission_success and not mission_failure then
			if story_dialogue_last and TestValid(hero) then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_44"))
			end
		end
	best_time = player_script.Call_Function("SW_Get_Cooldown_Time", "NM01_GRAVITY_BOMB_VARIANT" )
		superweapon_ready=true
		UI_Start_Flash_Superweapon("NM01_GRAVITY_BOMB_VARIANT")
		
		UI_Start_Flash_Superweapon("NOVUS_SUPERWEAPON_GRAVITY_BOMB_WEAPON")
		while (best_time<=0) do
			Sleep(1)
			best_time = player_script.Call_Function("SW_Get_Cooldown_Time", "NM01_GRAVITY_BOMB_VARIANT" )
		end
		gravitybomb.Highlight(false)
		UI_Stop_Flash_Superweapon("NM01_GRAVITY_BOMB_VARIANT")
	Sleep(15)
	
	best_time = player_script.Call_Function("SW_Get_Cooldown_Time", "NM01_GRAVITY_BOMB_VARIANT" )
		if story_dialogue_last then
			if alien_forces_defeated>0 then
				if not mission_success and not mission_failure then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_49"))
				end
			else
				if not mission_success and not mission_failure then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_45"))
				end
				if not mission_success and not mission_failure then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_46"))
				end
			end
			if alien_forces_defeated<2 then
				if not mission_success and not mission_failure then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_48"))
				end
			end
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
			
			Lock_Objects(false)
			
			-- ***** ACHIEVEMENT_AWARD *****
			--if (Player_Earned_Offline_Achievements()) then
				--Supply Novus as the player here - the parameter is only used to determine which version of the *_Tactical_Mission_Over
				--function we call, and as with the no achievements case below the Novus campaign is the one we want to move forward.
			--	Create_Thread("Show_Earned_Achievements_Thread", {Get_Game_Mode_GUI_Scene(), novus})
			--else
				
				-- Inform the campaign script of our victory.
				global_script.Call_Function("Novus_Tactical_Mission_Over", true) -- true == player wins/false == player loses
				--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
				Quit_Game_Now(player, false, true, false)
			--end
		else
			Show_Retry_Dialog()
		end
end

-- ***** ACHIEVEMENT_AWARD *****
function Show_Earned_Achievements_Thread(map)
	local dialog = Show_Earned_Offline_Achievements(map[1])
	while (dialog.Is_Showing()) do
		Sleep(1)
	end
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Cleanup_Hint_System", nil, {})
	Process_Tactical_Mission_Over(map[2])
end


-- here is where objects are locked or unlocked for the tactical game
function Lock_Objects(boolean)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_AIRCRAFT_ASSEMBLY"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_CENTRAL_PROCESSOR"),boolean,STORY)
		--novus.Lock_Object_Type(Find_Object_Type("NOVUS_HQ_MULTIPLAYER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_MATERIAL_CENTER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_MEGAWEAPON"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_NANOCENTER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_REDIRECTION_TURRET"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_REMOTE_TERMINAL"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_RESEARCH_CENTER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_SCIENCE_LAB"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_SUPERWEAPON_EMP"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_SUPERWEAPON_GRAVITY_BOMB"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_VEHICLE_ASSEMBLY"),boolean,STORY)
		
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_HERO_FOUNDER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_HERO_VERTIGO"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_AMPLIFIER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_ANTIMATTER_TANK"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_CORRUPTOR"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_DERVISH_JET"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_FIELD_INVERTER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_HACKER"),boolean,STORY)
		--novus.Lock_Object_Type(Find_Object_Type("NOVUS_REFLECTOR"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_REFLEX_TROOPER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_VARIANT"),boolean,STORY)
		
		novus.Lock_Unit_Ability("Novus_Robotic_Infantry", "Robotic_Infantry_Capture", true, STORY)
		novus.Lock_Generator("RoboticInfantryCaptureGenerator", true, STORY)
		
		novus.Lock_Unit_Ability("Novus_Hero_Founder", "Novus_Founder_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Vertigo", "Novus_Vertigo_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Object_Type(Find_Object_Type("Novus_Robotic_Assembly_Instance_Generator"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NM04_NOVUS_PORTAL"),boolean,STORY)

		
end

function Export_Base_To_Global()
	--structures_table = Find_All_Objects_Of_Type(novus, "NOVUS_SIGNAL_TOWER")
	structures_table = {}
	towers_table = Find_All_Objects_Of_Type("NOVUS_SIGNAL_TOWER")
	routers_table = Find_All_Objects_Of_Type("NOVUS_POWER_ROUTER")
	input_table = Find_All_Objects_Of_Type("NOVUS_INPUT_STATION")
	remote_table = Find_All_Objects_Of_Type("NOVUS_REMOTE_TERMINAL")
	assembly_table = Find_All_Objects_Of_Type("NOVUS_ROBOTIC_ASSEMBLY")
	for i, structure in pairs(towers_table) do
		table.insert(structures_table, structure)
	end
	for i, structure in pairs(routers_table) do
		table.insert(structures_table, structure)
	end
	for i, structure in pairs(input_table) do
		table.insert(structures_table, structure)
	end
	for i, structure in pairs(remote_table) do
		table.insert(structures_table, structure)
	end
	for i, structure in pairs(assembly_table) do
		table.insert(structures_table, structure)
	end
	structures_type_table = {}
	structures_pos_table = {}
	structures_face_table = {}
	for i, structure in pairs(structures_table) do
		structures_type_table[i] = structure.Get_Type()
		structures_pos_table[i] = structure.Get_Position()
		structures_face_table[i] = structure.Get_Facing()
	end
	global_script.Call_Function("Global_Store_Novus_Layout", {structures_type_table, structures_pos_table, structures_face_table})
end




function Audio_Objective_A()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_01"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_02"))
	end
end

function Audio_Objective_B_Sub()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE06_15"))
	end
end

function Audio_Objective_B()
	--if not mission_success and not mission_failure then
	--	BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_07"))
	--end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_08"))
	end
	Sleep(2)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE03_01"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE03_02"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE03_03"))
	end
	Sleep(2)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE03_04"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE03_13"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE03_06"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE03_07"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE03_08"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE03_09"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE03_10"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE03_11"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE03_12"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE02_14"))
	end
	story_dialogue_first=true
end


function Audio_Saucers_Attack()
	router=Find_First_Object("NOVUS_POWER_ROUTER")
	if TestValid(router) then 
		while router.Get_Hull()==1 do
			Sleep(1)
		end
	end
	if TestValid(router) then
		if TestValid(hero) then
			if not mission_success and not mission_failure then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE06_06"))
			end
			if not mission_success and not mission_failure then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE06_08"))
			end
		end
	end
	router_death_time=10
	while TestValid(router) and router_death_time>0 do
		router=Find_First_Object("NOVUS_POWER_ROUTER")
		router.Take_Damage(GameRandom(25,35))
		router_death_time=router_death_time-1
		Sleep(1)
	end
	if TestValid(router) then router.Take_Damage(9999) end
	Sleep(4)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_26"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE06_09"))
	end
end

function Audio_Demonstrate_Flow()
	if not used_flow_a  then
		--if not mission_success and not mission_failure then
		--	BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_16"))
		--end
		--if not mission_success and not mission_failure then
		--	BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_17"))
		--end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS01_SCENE06_20"))
		end
		Sleep(reminder_wait_time)
	end
end


function Audio_Objective_Done()
	if not mission_success and not mission_failure then
		if TestValid(hero) then
			kudos=GameRandom(1,5)
			if kudos==1 then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_05"))
			end
			if kudos==2 then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_06"))
			end
			if kudos==3 then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_30"))
			end
			if kudos==4 then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_51"))
			end
			if kudos==5 then
				BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS01_SCENE01_52"))
			end
		end
	end
end

function Post_Load_Callback()
	UI_Hide_Research_Button()
	UI_Hide_Sell_Button()
	Movie_Commands_Post_Load_Callback()
end



