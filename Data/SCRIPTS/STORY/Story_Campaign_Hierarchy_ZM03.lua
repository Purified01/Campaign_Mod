-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM03.lua#77 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM03.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Maria_Teruel $
--
--            $Change: 84781 $
--
--          $DateTime: 2007/09/25 14:27:22 $
--
--          $Revision: #77 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGSpawnUnits")
require("PGMoveUnits")
require("PGAchievementAward")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")
require("RetryMission")
require("PGColors")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_ZM03_Act01", State_ZM03_Act01)
	Define_State("State_ZM03_Act02", State_ZM03_Act02)
	Define_State("State_ZM03_Act03", State_ZM03_Act03)
	
	-- Debug Bools
	debug_orlok_invulnerable = false
	
	-- Factions
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	military = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")

--	PGColors_Init_Constants()
--	aliens.Enable_Colorization(true, COLOR_RED)
--	masari.Enable_Colorization(true, COLOR_DARK_GREEN)

	-- Object Types
	object_type_transport = Find_Object_Type("ALIEN_AIR_RETREAT_TRANSPORT")
	object_type_enforcer = Find_Object_Type("MASARI_ENFORCER")
	object_type_enforcer_fire = Find_Object_Type("MASARI_ENFORCER_FIRE")
	object_type_enforcer_ice = Find_Object_Type("MASARI_ENFORCER_ICE")
	object_type_defiler = Find_Object_Type("Alien_Defiler")
	
	-- Unit Lists
	list_alien_starting_units = {
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Defiler",
		"Alien_Defiler",
		"Alien_Defiler"
	}
	
	list_alien_lost_ones = {
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Lost_One"
	}
	
	list_masari_disciple_guards = {
      "Masari_Disciple"
	}
	
	list_masari_enforcers_01 = {
		"Masari_Enforcer" 
	}
	
	list_masari_enforcers_02 = {
		"Masari_Enforcer"
	}
	
	list_masari_disciples_02 = {
		"Masari_Disciple",
		"Masari_Disciple",
		"Masari_Disciple"
	}
	
	list_generator_horde_01 = {
		"Masari_Disciple",
		"Masari_Disciple",
		"Masari_Disciple",
		"Masari_Disciple",
		"Masari_Disciple",
		"Masari_Disciple"
	}
	
	list_single_alien_saucer = {
	   "ALIEN_AIR_RETREAT_TRANSPORT"
	}
	
	list_single_masari_gate_off = {
	   "HM03_Masari_Gate_Off"
	}
	
	list_single_masari_architect = {
	   "Masari_Architect"
	}
	
	-- Variables
	mission_success = false
	mission_failure = false

	time_objective_sleep = 5
	time_radar_sleep = 2

	time_spawn_enforcers = 20
   time_spawn_disciples = 30
   time_construct_enforcers = 15
   time_enforcer_construction_delay = 1

	distance_prox_reinforcements = 450
	
	generator2_killed = false
	generator3_killed = false

	distance_approach_generator = 500
	distance_pre_approach_retreat = 600
	distance_approach_retreat = 250
	distance_approach_guards = 350
	distance_conversation_01_prox = 300
   distance_approach_architects = 100
	
   ground_inspiration_total = 2

	final_enforcer_list = {}
	
	elemental_mode_fire = false
	zm03_objective06_complete = false

   fow_ground_inspiration01 = nil

	-- Pip Heads
	pip_orlok = "AH_Orlok_Pip_Head.alo"
	pip_kamal = "AH_Kamal_Rex_Pip_head.alo"
	pip_science = "AI_Science_officer_Pip_Head.alo"
	pip_comm = "AI_Comm_officer_Pip_head.alo"
	pip_nufai = "AH_Nufai_Pip_Head.alo"
	
	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through
function State_Init(message)
	local i, unit, enforcer_list, credit_total, credits
	
	if message == OnEnter then
		novus.Allow_Autonomous_AI_Goal_Activation(false)
		masari.Allow_Autonomous_AI_Goal_Activation(false)		
	
	military.Allow_AI_Unit_Behavior(false)
	novus.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
		
		_CustomScriptMessage("RickLog.txt", string.format("*********************************************Story_Campaign_Hierarchy_ZM03 START!"))
		
		Cache_Models()

		UI_Hide_Research_Button()
		UI_Hide_Sell_Button()

		Fade_Screen_Out(0)
      Fade_Out_Music()
            
		-- Initial Starting Credits
		credit_total = 0
		credits = aliens.Get_Credits()
      if credits > credit_total then
         credits = (credits - credit_total) * -1
         aliens.Give_Money(credits)
      elseif credits < credit_total then
         credits = credit_total - credits
         aliens.Give_Money(credits)
      end
  		masari.Give_Money(1000000)

		-- Construction and Ability Locks
		aliens.Reset_Story_Locks()
		aliens.Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Retreat_From_Tactical_Ability", true, STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Lost_One_Plasma_Bomb_Unit_Ability", false,STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Grey_Phase_Unit_Ability", false,STORY)
		aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("Alien_Grunt"), "Grunt_Grenade_Attack", false, STORY)
		
		-- Hint System Initialization
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		Register_Hint_Context_Scene(Get_Game_Mode_GUI_Scene())

		-- Markers
		enforcer_marker = Find_Hint("MARKER_GENERIC_BLUE","enforcers")
		if not TestValid(enforcer_marker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find enforcer_marker!"))
		end
      regulars_marker = Find_Hint("MARKER_GENERIC_BLUE","regulars")
		if not TestValid(regulars_marker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find regulars_marker!"))
		end
		marker_generator_01_horde = Find_Hint("MARKER_GENERIC_BLUE","generator01horde")
		if not TestValid(marker_generator_01_horde) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_generator_01_horde!"))
		end

		generator_marker_01 = Find_Hint("MARKER_GENERIC_YELLOW","zm03-marker-01")
		if not TestValid(generator_marker_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find generator_marker_01!"))
		end
		generator_marker_02 = Find_Hint("MARKER_GENERIC_YELLOW","zm03-marker-02")
		if not TestValid(generator_marker_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find generator_marker_02!"))
		end
		generator_marker_03 = Find_Hint("MARKER_GENERIC_YELLOW","zm03-marker-03")
		if not TestValid(generator_marker_03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find generator_marker_03!"))
		end
		
		marker_new_conversation_prox = Find_Hint("MARKER_GENERIC_GREEN","zm03-conv-01-prox")
		if not TestValid(marker_new_conversation_prox) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_new_conversation_prox!"))
		end
		marker_conversation_01_prox = Find_Hint("MARKER_GENERIC_GREEN","conv01")
		if not TestValid(marker_conversation_01_prox) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_conversation_01_prox!"))
		end
		marker_conversation_02_prox = Find_Hint("MARKER_GENERIC_GREEN","conv02")
		if not TestValid(marker_conversation_02_prox) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_conversation_02_prox!"))
		end
		marker_reinforcement_prox = Find_Hint("MARKER_GENERIC_GREEN","reinforcementprox")
		if not TestValid(marker_reinforcement_prox) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_reinforcement_prox!"))
		end
		marker_transport_start = Find_Hint("MARKER_GENERIC_GREEN","transport-start")
		if not TestValid(marker_transport_start) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_transport_start!"))
		end
		marker_transport_finish = Find_Hint("MARKER_GENERIC_GREEN","transport-finish")
		if not TestValid(marker_transport_finish) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_transport_finish!"))
		end
		retreat_marker = Find_Hint("MARKER_GENERIC_GREEN","zm03-retreat")
		if not TestValid(retreat_marker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find retreat_marker!"))
		end
		retreat_orlok_marker = Find_Hint("MARKER_GENERIC_GREEN","zm03-retreat-orlok")
		if not TestValid(retreat_orlok_marker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find retreat_orlok_marker!"))
		end
		retreat_transport_marker = Find_Hint("MARKER_GENERIC_GREEN","zm03-transport-retreat")
		if not TestValid(retreat_transport_marker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find retreat_transport_marker!"))
		end

      marker_architect_01 = Find_Hint("MARKER_GENERIC_GREEN","a1")
		if not TestValid(marker_architect_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_architect_01!"))
		end
      marker_architect_02 = Find_Hint("MARKER_GENERIC_GREEN","a2")
		if not TestValid(marker_architect_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_architect_02!"))
		end

		architect_start_marker = Find_Hint("MARKER_GENERIC_GREEN","architect-start")
		if not TestValid(architect_start_marker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find architect_start_marker!"))
		end
      masari_ground_inspiration_list = Find_All_Objects_Of_Type("Masari_Ground_Inspiration")
		if table.getn(masari_ground_inspiration_list) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find masari_ground_inspiration_list!"))
		end
      ground_inspiration_01 = Find_Hint("Masari_Ground_Inspiration","b1")
		if not TestValid(ground_inspiration_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find ground_inspiration_01!"))
		end
      ground_inspiration_02 = Find_Hint("Masari_Ground_Inspiration","b2")
		if not TestValid(ground_inspiration_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find ground_inspiration_02!"))
		end

		flankers_marker = Find_Hint("MARKER_GENERIC_PURPLE","flankers")
		if not TestValid(flankers_marker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find flankers_marker!"))
		end
		
		list_act1_masari_guard_markers = Find_All_Objects_With_Hint("zm03-act01-masari")
		if table.getn(list_act1_masari_guard_markers) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_act1_masari_guard_markers!"))
		end
		list_act3_masari_guard_markers = Find_All_Objects_With_Hint("zm03-act03-masari")
		if table.getn(list_act3_masari_guard_markers) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_act3_masari_guard_markers!"))
		end
		list_masari_enforcer_markers = Find_All_Objects_With_Hint("zm03-enforcer")
		if table.getn(list_masari_enforcer_markers) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_masari_enforcer_markers!"))
		end
		
		-- Generators
		generator_01 = Find_Hint("HM03_MASARI_TEMPLE", "zm03-gen-01")
		if not TestValid(generator_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find generator_01!"))
		end
		generator_02 = Find_Hint("HM03_MASARI_TEMPLE", "zm03-gen-02")
		if not TestValid(generator_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find generator_02!"))
		end
		generator_03 = Find_Hint("HM03_MASARI_TEMPLE", "zm03-gen-03")
		if not TestValid(generator_03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find generator_03!"))
		end
		
		-- Orlok
		hero = Find_First_Object("Alien_Hero_Orlok")
		if not TestValid(hero) then
			MessageBox("Story_Campaign_Hierarchy_ZM03 cannot find Orlok!")
		end

		-- Radar Initialization
		local radar_filter_id1 = RadarMap.Add_Filter("Radar_Map_Enable", aliens)
		local radar_filter_id2 = RadarMap.Add_Filter("Radar_Map_Allow_Mouse_Input", aliens)
		local radar_filter_id3 = RadarMap.Add_Filter("Radar_Map_Show_Terrain", aliens)
		local radar_filter_id4 = RadarMap.Add_Filter("Radar_Map_Show_FOW", aliens)
		local radar_filter_id5 = RadarMap.Add_Filter("Radar_Map_Show_Owned", aliens)
		local radar_filter_id6 = RadarMap.Add_Filter("Radar_Map_Show_Allied", aliens)
		local radar_filter_id7 = RadarMap.Add_Filter("Radar_Map_Show_Enemy", aliens)
		local radar_filter_id8 = RadarMap.Add_Filter("Radar_Map_Show_Neutral", aliens)
		
		Set_Next_State("State_ZM03_Act01")
	end
end

function State_ZM03_Act01(message)
	local i, marker, unit, structure, structure_health, list_bridges
	
	if message == OnEnter then
	
	   -- Masari Light Bridges
	   list_bridges = Find_All_Objects_Of_Type("HM03_MASARI_LIGHT_BRIDGE")
	   for i, structure in pairs (list_bridges) do
	      if TestValid(structure) then
	         structure.Make_Invulnerable(true)
	         structure.Set_Cannot_Be_Killed(true)
	      end
	   end
	   
		-- Orlok
		if TestValid(hero) then

   		-- Orlok 1200 from 2000 = -.4
		   hero.Add_Attribute_Modifier("Universal_Damage_Modifier", -.4)
		   
		   hero.Register_Signal_Handler(Callback_Orlok_Killed, "OBJECT_HEALTH_AT_ZERO")			
			if debug_orlok_invulnerable then
				hero.Make_Invulnerable(true)
			end

			-- Orlok's Starting Contingent
			--Create_Thread("Thread_Starting_Transport")
			-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
			alien_list = SpawnList(list_alien_starting_units, hero.Get_Position(), aliens, false, true, true)
			for i, unit in pairs (alien_list) do
				if TestValid(unit) then
					unit.Guard_Target(unit.Get_Position())
					unit.Hide(true)
				end
			end
		end
		
		-- Proximities
		Register_Prox(marker_conversation_01_prox, Prox_Conversation_01, distance_conversation_01_prox, aliens)
		Register_Prox(marker_conversation_02_prox, Prox_Conversation_02, distance_conversation_01_prox, aliens)
		Register_Prox(architect_start_marker, Prox_Conversation_03, distance_conversation_01_prox, aliens)
		for i, marker in pairs (list_act1_masari_guard_markers) do
			Register_Prox(marker, Prox_Approaching_Disciples, distance_approach_guards, aliens)
		end
		for i, marker in pairs (list_masari_enforcer_markers) do
			Register_Prox(marker, Prox_Approaching_Enforcer, distance_approach_guards, aliens)
		end
		Register_Prox(marker_new_conversation_prox, Prox_Conversation_01A, distance_approach_guards, aliens)
		
		-- Generators
		generator_01.Register_Signal_Handler(Callback_Generator01_Killed, "OBJECT_HEALTH_AT_ZERO")

      -- Ground Inspirations
      for i, structure in pairs (masari_ground_inspiration_list) do
         structure_health = structure.Get_Health_Value() * 0.75
         structure.Take_Damage(structure_health, "Damage_Default")
   		structure.Register_Signal_Handler(Callback_Ground_Inspiration_Killed, "OBJECT_HEALTH_AT_ZERO")
      end

		-- Elemental Mode
		masari.Set_Elemental_Mode("Ice")
		
		Create_Thread("Thread_Intro_Conversation")		
	end
end

function State_ZM03_Act02(message)
	if message == OnEnter then
	
		-- Drop the interior barriers here.
		
		-- Generator 01 Horde
		Create_Thread("Thread_Generator_Horde",marker_generator_01_horde)

      -- Regular Disciple Guards
      -- Create_Thread("Thread_Spawn_Disciples")

		-- Objectives
		Remove_Radar_Blip("blip_objective01")
		Objective_Complete(zm03_objective01)
		
		Create_Thread("ZM03_Act02")

		-- Proximities
		Register_Prox(marker_reinforcement_prox, Prox_Bring_Reinforcements, distance_prox_reinforcements, aliens)

		-- Generators
		generator_02.Register_Signal_Handler(Callback_Generator02_Killed, "OBJECT_HEALTH_AT_ZERO")
		generator_03.Register_Signal_Handler(Callback_Generator03_Killed, "OBJECT_HEALTH_AT_ZERO")
		
	end
end

function ZM03_Act02()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE03_OBJECTIVE_02_ADD"} )
	Sleep(time_objective_sleep)	
	zm03_objective03 = Add_Objective("TEXT_SP_MISSION_HIE03_OBJECTIVE_02")
	zm03_objective04 = Add_Objective("TEXT_SP_MISSION_HIE03_OBJECTIVE_03")
	Add_Radar_Blip(generator_marker_02, "DEFAULT", "blip_objective02")
	Add_Radar_Blip(generator_marker_03, "DEFAULT", "blip_objective03")
end

function State_ZM03_Act03(message)
	local i, marker
	
	if message == OnEnter then

		-- Spawn Markers
		for i, marker in pairs (list_act3_masari_guard_markers) do
			Register_Prox(marker, Prox_Approaching_Disciples, distance_approach_guards, aliens)
		end

		-- Retreat Marker Pre-Proximity (to ramp things up)
		Register_Prox(retreat_orlok_marker, Prox_Pre_Approaching_Retreat, distance_pre_approach_retreat, aliens)

		-- Elemental Mode
		masari.Set_Elemental_Mode("Fire")
		elemental_mode_fire = true
		
		Create_Thread("Thread_Spawn_Enforcers")
		Create_Thread("Thread_Ending_Transport")
		Create_Thread("Thread_Ending_Conversation")
	end
end

--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script

-- 6/19/2007 -- Some lua cinematic work done by Dan.


function Thread_Intro_Conversation()
	local nearest_defiler
	
	local intro_transport = Find_Hint("CINEMATIC_ALIEN_TRANSPORT","intro-transport")
	local camera_start = Find_Hint("MARKER_CAMERA","start-intro")
	hero.Hide(true)
		
	Point_Camera_At(camera_start)
   Lock_Controls(1)
   Fade_Screen_Out(0)
   nearrange, farrange = Set_Object_Fade_Range(4000, 5000)
   Sleep(1)
   Start_Cinematic_Camera()
   Letter_Box_In(0.1)
   Transition_Cinematic_Camera_Key(camera_start, 0, 600, 12.5, 140, 1, 0, 0, 0)
   Transition_Cinematic_Target_Key(intro_transport, 0, 0, 0, -30, 0, intro_transport, 0, 0)
   Fade_Screen_In(1)
   Transition_Cinematic_Camera_Key(camera_start, 10, 600, 12.5, 200, 1, 0, 0, 0)
   
   Sleep(9)
   Fade_Screen_Out(1) 
    
   Sleep(1)   
   Create_Thread("Thread_Starting_Transport")
   Sleep(2)  
   
   hero.Hide(false)
	for i, unit in pairs (alien_list) do
		if TestValid(unit) then
			unit.Hide(false)
		end
	end
   Transition_To_Tactical_Camera(0)  
   Letter_Box_Out(0)
   Fade_Screen_In(1)
   Lock_Controls(0)
   Set_Object_Fade_Range(nearrange, farrange)
   End_Cinematic_Camera()
   
   
   if TestValid(intro_transport) then	
		intro_transport.Despawn()
	end

	-- Intro Conversation
	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE02_01"))
	BlockOnCommand(Queue_Talking_Head(pip_science, "HIE03_SCENE02_02"))
	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE02_03"))
	BlockOnCommand(Queue_Talking_Head(pip_science, "HIE03_SCENE02_04"))
		
	Sleep(time_radar_sleep)

	-- Objectives
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE03_OBJECTIVE_01_ADD"} )
	Sleep(time_objective_sleep)	
	zm03_objective01 = Add_Objective("TEXT_SP_MISSION_HIE03_OBJECTIVE_01")

	Sleep(time_radar_sleep)
	Add_Radar_Blip(generator_marker_01, "DEFAULT", "blip_objective01")

	if TestValid(hero) then
		nearest_defiler = Find_Nearest(hero, object_type_defiler)
		if TestValid(nearest_defiler) then
			Add_Attached_Hint(nearest_defiler, HINT_BUILT_ALIEN_DEFILER)
		end
	end
end

function Thread_Ending_Conversation()
	
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE06_01"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE03_SCENE06_02"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE03_SCENE06_03"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE06_04"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE03_SCENE06_05"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE06_06"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE03_SCENE06_07"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE06_08"))
	end
	conversation_occuring = false
	
	Sleep(time_radar_sleep)
	
	-- Objectives
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE03_OBJECTIVE_04_ADD"} )
	Sleep(time_objective_sleep)	
	zm03_objective05 = Add_Objective("TEXT_SP_MISSION_HIE03_OBJECTIVE_04")
	Add_Radar_Blip(retreat_orlok_marker, "DEFAULT", "blip_objective04")
	
	Sleep(time_radar_sleep)
	if not mission_failure then
		Register_Prox(retreat_orlok_marker, Prox_Approaching_Retreat, distance_approach_retreat, aliens)
	end
	
	Sleep(10)
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE07_01"))
	end
	conversation_occuring = false	
end

function Thread_Generator_Horde(v_marker)
	local generator_horde, i, unit
	
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	generator_horde = SpawnList(list_generator_horde_01, v_marker.Get_Position(), masari, false, true, false)
	-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
	Hunt(generator_horde, "AntiDefault", true, false)
end

function Thread_Starting_Transport()
   local spawn_list
	
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
   spawn_list = SpawnList(list_single_alien_saucer, marker_transport_start, aliens, false, true, false)
	alien_saucer = spawn_list[1]
	alien_saucer.Hide(false)
	if TestValid(alien_saucer) then
		alien_saucer.Set_Selectable(false)
		alien_saucer.Make_Invulnerable(true)
	end
	Sleep(time_radar_sleep)
	if TestValid(alien_saucer) then
		BlockOnCommand(alien_saucer.Move_To(marker_transport_finish.Get_Position()))
		alien_saucer.Make_Invulnerable(false)		
		alien_saucer.Despawn()
	end
end

function Thread_Reinforcements()
	local alien_saucer, nearest_manipulator, reinforcements, i, unit, spawn_list

	if not mission_failure then
   	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
      spawn_list = SpawnList(list_single_alien_saucer, retreat_transport_marker, aliens, false, true, false)
		alien_saucer = spawn_list[1]
		if TestValid(alien_saucer) then
			alien_saucer.Set_Selectable(false)
			alien_saucer.Make_Invulnerable(true)
			
			BlockOnCommand(alien_saucer.Move_To(retreat_marker.Get_Position()))
     		Raise_Game_Event("Reinforcements_Arrived", aliens, retreat_marker.Get_Position())
			-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
			reinforcements = SpawnList(list_alien_starting_units, retreat_marker.Get_Position(), aliens, false, true, true)
			if TestValid(hero) then
				for i, unit in pairs(reinforcements) do
					if TestValid(unit) then
						unit.Attack_Move(hero.Get_Position())
					end
				end
			end
			BlockOnCommand(alien_saucer.Move_To(retreat_transport_marker.Get_Position()))
			alien_saucer.Make_Invulnerable(false)
			alien_saucer.Despawn()
		end
	end
end

function Thread_Ending_Transport()
	local alien_saucer, reinforcements, i, unit, spawn_list

	if not mission_failure then
   	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
   	spawn_list = SpawnList(list_single_alien_saucer, retreat_transport_marker, aliens, false, true, false)
		alien_saucer = spawn_list[1]
		if TestValid(alien_saucer) then
			alien_saucer.Set_Selectable(false)
			alien_saucer.Make_Invulnerable(true)

			BlockOnCommand(alien_saucer.Move_To(retreat_marker.Get_Position()))
			if not mission_failure then
        		Raise_Game_Event("Reinforcements_Arrived", aliens, retreat_marker.Get_Position())
				-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
				reinforcements = SpawnList(list_alien_starting_units, retreat_marker.Get_Position(), aliens, false, true, true)
				for i, unit in pairs (reinforcements) do
					unit.Guard_Target(unit.Get_Position())
				end
			end
		end
	end
end

function Thread_Spawn_Disciples()
	local i, unit, spawned_disciples
	
	while not mission_success and not mission_failure do
		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
		spawned_disciples = SpawnList(list_masari_disciple_guards, regulars_marker, masari, false, true, false)
		Hunt(spawned_disciples, "AntiDefault", true, false)
		
		Sleep (time_spawn_disciples)
	end
end

function Thread_Spawn_Enforcers()
	local i, unit, spawned_disciples
	
	while not mission_success and not mission_failure do
		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
		final_enforcer_list = SpawnList(list_masari_enforcers_02, enforcer_marker, masari, false, true, false)
		Hunt(final_enforcer_list, "AntiDefault", true, false)
		spawned_disciples = SpawnList(list_masari_disciples_02, enforcer_marker, masari, false, true, false)
		Hunt(spawned_disciples, "AntiDefault", true, false)
		
		Sleep (time_spawn_enforcers)
	end
end

function Thread_Construct_Enforcers()
	local i, structure
	
	while not mission_success and not mission_failure do
		for i,structure in pairs(masari_ground_inspiration_list) do
			if TestValid(structure) then
				if structure.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(structure, object_type_enforcer, 1, masari)
				end
			end
		end

		Sleep(time_construct_enforcers)
	
	end
end


--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script

function Story_On_Construction_Complete(obj)
	local nearest, obj_type
	
	if TestValid(obj) then
		obj_type = obj.Get_Type()
		if obj_type == object_type_enforcer or obj_type == object_type_enforcer_fire or obj_type == object_type_enforcer_ice then
      	Hunt(obj, "AntiDefault", true, false)
      end
   end
end

function Cache_Models()
	Find_Object_Type("Masari_Disciple").Load_Assets()
	Find_Object_Type("Masari_Enforcer").Load_Assets()
end

function Prox_Bring_Reinforcements(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Bring_Reinforcements)
  	Create_Thread("Thread_Prox_Bring_Reinforcements")	
end

function Thread_Prox_Bring_Reinforcements()
	local spawned_disciples, defiler
	
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then	
  		defiler = Find_First_Object("Alien_Defiler")
      if TestValid(defiler) then
		   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE04_01"))
      end
	end
	conversation_occuring = false
	
	Sleep(2)
	
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE03_SCENE04_02"))
	end
	conversation_occuring = false
	Create_Thread("Thread_Reinforcements")
	
	-- Spawn Flankers here, to reinforce the radiation event.
	spawned_disciples = SpawnList(list_masari_disciples_02, flankers_marker, masari, false, true, false)
	Hunt(spawned_disciples, "AntiDefault", true, false)
	
	-- Elemental Mode
	masari.Set_Elemental_Mode("Fire")
end

function Prox_Approaching_Enforcer(prox_obj, trigger_obj)
	local guard_list, i, unit
	
	prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Enforcer)
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	guard_list = SpawnList(list_masari_enforcers_01, prox_obj, masari, false, true, false)
	for i, unit in pairs (guard_list) do
		if TestValid(unit) then
         unit.Guard_Target(unit.Get_Position())
		end
	end
end

function Prox_Approaching_Disciples(prox_obj, trigger_obj)
	local guard_list, i, unit
	
	prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Disciples)
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	guard_list = SpawnList(list_masari_disciple_guards, prox_obj, masari, false, true, false)
	for i, unit in pairs (guard_list) do
		if TestValid(unit) then
			-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
			Hunt(unit, "AntiDefault", false, false)
		end
	end
end

function Prox_Conversation_01(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Conversation_01)
	Create_Thread("Thread_Prox_Conversation_01")
end

function Prox_Conversation_01A(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Conversation_01A)
	Create_Thread("Thread_Prox_Conversation_01A")
end

function Prox_Conversation_02(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Conversation_02)
	Create_Thread("Thread_Prox_Conversation_02")
end

function Prox_Conversation_03(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Conversation_03)
	Create_Thread("Thread_Prox_Conversation_03")
end

function Thread_Prox_Conversation_01()
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE03_01"))
	end
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE03_SCENE03_02"))
	end
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE03_03"))
	end
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE03_SCENE03_04"))
	end
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE03_05"))
	end
	conversation_occuring = false
end

function Thread_Prox_Conversation_01A()
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE08_01"))
	end
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE03_SCENE08_02"))
	end
	conversation_occuring = false
end

function Thread_Prox_Conversation_02()
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE04_06"))
	end
	conversation_occuring = false

	-- Elemental Mode
	masari.Set_Elemental_Mode("Ice")
end

function Thread_Prox_Conversation_03()
   local i, marker, architect_spawned, nearest_building, spawn_list

   -- Spawn Architects and Start Repairs
  	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
   spawn_list = SpawnList(list_single_masari_architect, marker_architect_01, masari, false, true, false)
  	architect_spawned = spawn_list[1]
   if TestValid(architect_spawned) then
      if TestValid(ground_inspiration_01) then
         architect_spawned.Activate_Ability("Masari_Architect_Assist_Structure_Ability", true, ground_inspiration_01)
			Register_Prox(architect_spawned, Prox_Approaching_Architect, distance_approach_architects, aliens)
      end
   end
   spawn_list = SpawnList(list_single_masari_architect, marker_architect_02, masari, false, true, false)
  	architect_spawned = spawn_list[1]
   if TestValid(architect_spawned) then
      if TestValid(ground_inspiration_02) then
         architect_spawned.Activate_Ability("Masari_Architect_Assist_Structure_Ability", true, ground_inspiration_02)
			Register_Prox(architect_spawned, Prox_Approaching_Architect, distance_approach_architects, aliens)
      end
   end

	fow_ground_inspiration01 = FogOfWar.Reveal(aliens, marker_architect_02, 300, 300)

	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE03_SCENE04_04"))
	end
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE04_03"))
	end
	conversation_occuring = false

   if not mission_failure then
      Sleep(time_radar_sleep)
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE03_OBJECTIVE_05_ADD"} )
	    Sleep(time_objective_sleep)
	   zm03_objective06 = Add_Objective("TEXT_SP_MISSION_HIE03_OBJECTIVE_05")

      Sleep(time_radar_sleep)
	   Add_Radar_Blip(marker_architect_02, "DEFAULT", "blip_objective06a")

      Sleep(time_enforcer_construction_delay)
      Create_Thread("Thread_Construct_Enforcers")
   	-- Elemental Mode
	   masari.Set_Elemental_Mode("Fire")
   end

  	Sleep(10)
   while conversation_occuring do
	   Sleep(1)
   end
   if not mission_failure and not zm03_objective06_complete then
   	conversation_occuring = true
     	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE04_11"))
   	conversation_occuring = false
   end

  	Sleep(15)
   while conversation_occuring do
	   Sleep(1)
   end
   if not mission_failure and not zm03_objective06_complete then
   	conversation_occuring = true
     	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE04_10"))
   	conversation_occuring = false
   end

  	Sleep(15)
   while conversation_occuring do
	   Sleep(1)
   end
   if not mission_failure and not zm03_objective06_complete then
   	conversation_occuring = true
     	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE04_09"))
   	conversation_occuring = false
   end

end

function Callback_Orlok_Killed()
	if not mission_success then
		Create_Thread("Thread_Mission_Failed")
	end
end

function Prox_Pre_Approaching_Retreat(prox_obj, trigger_obj)
	if trigger_obj == hero and not mission_failure then
		prox_obj.Cancel_Event_Object_In_Range(Prox_Pre_Approaching_Retreat)
		time_spawn_enforcers = 5
	end
end

function Prox_Approaching_Architect(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Architect)
	Create_Thread("Thread_Prox_Approaching_Architect",prox_obj)
end

function Thread_Prox_Approaching_Architect(obj)
   obj.Move_To(generator_marker_03.Get_Position())
   Sleep(10)
   if TestValid(obj) then
      obj.Take_Damage(10000)
   end
end

function Prox_Approaching_Retreat(prox_obj, trigger_obj)
	if trigger_obj == hero and not mission_failure then
		prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Retreat)
		Objective_Complete(zm03_objective05)
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE03_OBJECTIVE_04_COMPLETE"} )
		Remove_Radar_Blip("blip_objective04")
		Create_Thread("Thread_Mission_Success")
	end
end

function Callback_Generator01_Killed()
   Create_Thread("Thread_Callback_Generator01_Killed")
end

function Thread_Callback_Generator01_Killed()
   local list_masari_gates, i, gate, object
   
   list_masari_gates = Find_All_Objects_Of_Type("HM03_Masari_Gate")
   for i, gate in pairs(list_masari_gates) do
      if TestValid(gate) then
   	   -- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
   	   spawn_list = SpawnList(list_single_masari_gate_off, gate, neutral, false, true, false)
   	   object = spawn_list[1]
   	   if TestValid(object) then
      	   object.Teleport_And_Face(gate)
   	      gate.Despawn()
   	   end
      end
   end
   
   while conversation_occuring do
	   Sleep(1)
   end
   conversation_occuring = true
   if not mission_success and not mission_failure then		
	   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE08_03"))
   end
   if not mission_success and not mission_failure then		
	   BlockOnCommand(Queue_Talking_Head(pip_science, "HIE03_SCENE08_04"))
   end
   if not mission_success and not mission_failure then		
	   BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE03_SCENE08_05"))
   end
   conversation_occuring = false
   if not mission_success and not mission_failure then		
   	Set_Next_State("State_ZM03_Act02")
   end
end

function Callback_Generator02_Killed()
	local i, marker, unit
	
	if not mission_failure then
		Remove_Radar_Blip("blip_objective02")
		Objective_Complete(zm03_objective03)
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE03_OBJECTIVE_02_COMPLETE"} )
		if generator3_killed then
			Set_Next_State("State_ZM03_Act03")
		else
			generator2_killed = true
			Create_Thread("Thread_Generator_Horde",enforcer_marker)
			Create_Thread("Thread_Generator_Killed_Conversation")
		end
	end
end

function Callback_Ground_Inspiration_Killed()
   ground_inspiration_total = ground_inspiration_total - 1
   if ground_inspiration_total <= 0 then
      zm03_objective06_complete = true
      if not mission_failure then
  		   Remove_Radar_Blip("blip_objective06a")
			fow_ground_inspiration01.Undo_Reveal()
		   Objective_Complete(zm03_objective06)
		   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE03_OBJECTIVE_05_COMPLETE"} )
      end
   end
end

function Thread_Generator_Killed_Conversation()
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE03_SCENE05_01"))
	end
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE03_SCENE05_02"))
	end
	if not mission_success and not mission_failure then		
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE03_SCENE05_03"))
	end
	conversation_occuring = false
end

function Callback_Generator03_Killed()
	local i, marker, unit

	if not mission_failure then
		Remove_Radar_Blip("blip_objective03")
		Objective_Complete(zm03_objective04)
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE03_OBJECTIVE_03_COMPLETE"} )
		if generator2_killed then
			Set_Next_State("State_ZM03_Act03")
		else
			generator3_killed = true
			Create_Thread("Thread_Generator_Horde",enforcer_marker)
			Create_Thread("Thread_Generator_Killed_Conversation")
		end
	end
end

function Thread_Mission_Success()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
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
	Sleep(time_objective_sleep)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(0)
	Force_Victory(aliens)	
end

function Thread_Mission_Failed()
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
	Play_Music("Lose_To_Masari_Event")
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,30)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ORLOK"} )
	Sleep(time_objective_sleep)
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
   Fade_Screen_Out(2)
   Sleep(2)
   Lock_Controls(0)
	Force_Victory(masari)
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
	UI_Hide_Research_Button()
	UI_Hide_Sell_Button()
	Movie_Commands_Post_Load_Callback()
end
