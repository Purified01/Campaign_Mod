-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM01.lua#108 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM01.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Mike_Lytle $
--
--            $Change: 86588 $
--
--          $DateTime: 2007/10/24 16:28:46 $
--
--          $Revision: #108 $
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
	Define_State("State_ZM01_Act01", State_ZM01_Act01)
	Define_State("State_ZM01_Act02", State_ZM01_Act02)

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
--	novus.Enable_Colorization(true, COLOR_CYAN)
	
	-- Object Types
	object_type_robot = Find_Object_Type("Novus_Robotic_Infantry")
	object_type_antimatter_tank = Find_Object_Type("NOVUS_ANTIMATTER_TANK")
	
	object_type_civilian_pickup_truck = Find_Object_Type("Civilian_Pickup_Truck_01_Mobile")
	object_type_civilian_station_wagon = Find_Object_Type("Civilian_Station_Wagon_01_Mobile")
	
	object_type_transport = Find_Object_Type("ALIEN_AIR_RETREAT_TRANSPORT")
	object_type_alien_walker_habitat = Find_Object_Type("Alien_Walker_Habitat")
	object_type_alien_grunt = Find_Object_Type("Alien_Grunt")

	-- Unit Lists
	list_alien_reinforcement_units = {
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt"
	}
	
	list_robots = {
		"Novus_Robotic_Infantry",
		"Novus_Robotic_Infantry"
	}
	
	list_civilians = {
	   "American_Civilian_Urban_01_Map_Pedestrian",
	   "American_Civilian_Urban_01_Map_Pedestrian",
	   "American_Civilian_Urban_01_Map_Pedestrian"
	}
	
	list_single_grunt = {
	   "Alien_Grunt"
	}
	
	list_single_habitat_walker = {
	   "Alien_Walker_Habitat"
	}
	
	list_single_alien_transport = {
	   "ALIEN_AIR_RETREAT_TRANSPORT"
	}
	
	list_single_civilian_truck = {
	   "Civilian_Pickup_Truck_01_Mobile"
	}
	
	list_single_civilian_station_wagon = {
	   "Civilian_Station_Wagon_01_Mobile"
	}
	
	-- Variables
	mission_success = false
	mission_failure = false
	conversation_occuring = false
	time_objective_sleep = 5
	time_radar_sleep = 2

   reinforcements_allowed = false
	time_spawn_reinforcements = 10
	minimum_grunts = 10

	first_base_approach_distance = 250
	second_base_approach_distance = 2300
	act1_approach_distance = 1700
	act2_approach_distance = 400
	
	distance_spawn_guards = 400
   distance_defense_mode = 700
   distance_fow_reveal_power_core = 100
   distance_spawn_civilians = 300
   distance_reflex_trooper_guard = 400
   
	build_quantity = 1
	
	total_novus_robots = 0
	maximum_novus_robots = 12
	time_spawn_novus_robots = 20
	robot_team_list_in_use = false
	time_move_novus_robots = 10
	robot_team_size = 3
	
	total_novus_tanks = 0
	maximum_novus_tanks = 3
	time_spawn_novus_tanks = 40
	
	total_novus_jets = 0
	maximum_novus_jets = 1
	time_spawn_novus_jets = 60
		
	allow_act1_events = true
	civilian_vehicle_01 = nil
	civilian_vehicle_02 = nil
	civilian_vehicle_03 = nil
	
	habitat_walker = nil

	list_robots_01 = {}
	list_robots_02 = {}
	list_robots_03 = {}
	list_robot_gather_points = {}
	
	total_novus_structures = 0
	
	alien_actual_reinforcement_drop_start = nil
	alien_actual_reinforcement_drop_end = nil
	
	radar_marker_1_on = false
	radar_marker_2_on = false
	radar_marker_3_on = false
	
	orlok_damaged_hint = false

   fow_power_core_revealed = false
   
	-- Fog of War Handles
	fow_power_core_01 = nil
	
	-- Pip Heads
	pip_orlok = "AH_Orlok_Pip_Head.alo"
	pip_kamal = "AH_Kamal_Rex_Pip_head.alo"
	pip_science = "AI_Science_Officer_Pip_Head.alo"
	pip_comm = "AI_Comm_Officer_Pip_Head.alo"
	pip_grunt = "AI_Grunt_Pip_Head.alo"
	
	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
end


--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	local credits, credit_total, i, marker, radar_filter_id1
	
	if message == OnEnter then
		novus.Allow_Autonomous_AI_Goal_Activation(false)
		masari.Allow_Autonomous_AI_Goal_Activation(false)		
	
	military.Allow_AI_Unit_Behavior(false)
	novus.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
		
		_CustomScriptMessage("RickLog.txt", string.format("*********************************************Story_Campaign_Hierarchy_ZM01 START!"))

		Cache_Models()
		
		UI_Hide_Research_Button()
		UI_Hide_Sell_Button()

		-- Construction Locks/Unlocks
		aliens.Reset_Story_Locks()
		aliens.Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Retreat_From_Tactical_Ability", true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Glyph_Carver"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Brute_Mutator"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Terrain_Conditioner"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Foo_Chamber"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Arc_Trigger"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Range_Enhancer"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Brute"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Grunt"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Lost_One"),false,STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Lost_One_Plasma_Bomb_Unit_Ability", false,STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Grey_Phase_Unit_Ability", false,STORY)
		aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("Alien_Grunt"), "Grunt_Grenade_Attack", false, STORY)

		-- Initial Starting Credits
		credit_total = 10000
		credits = aliens.Get_Credits()
      if credits > credit_total then
         credits = (credits - credit_total) * -1
         aliens.Give_Money(credits)
      elseif credits < credit_total then
         credits = credit_total - credits
         aliens.Give_Money(credits)
      end
		novus.Give_Money(1000000)
		
		-- Radar Initialization
		local radar_filter_id1 = RadarMap.Add_Filter("Radar_Map_Enable", aliens)
		local radar_filter_id2 = RadarMap.Add_Filter("Radar_Map_Allow_Mouse_Input", aliens)
		local radar_filter_id3 = RadarMap.Add_Filter("Radar_Map_Show_Terrain", aliens)
		local radar_filter_id4 = RadarMap.Add_Filter("Radar_Map_Show_FOW", aliens)
		local radar_filter_id5 = RadarMap.Add_Filter("Radar_Map_Show_Owned", aliens)
		local radar_filter_id6 = RadarMap.Add_Filter("Radar_Map_Show_Allied", aliens)
		local radar_filter_id7 = RadarMap.Add_Filter("Radar_Map_Show_Enemy", aliens)
		local radar_filter_id8 = RadarMap.Add_Filter("Radar_Map_Show_Neutral", aliens)
		
		-- Hint System Initialization
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		Register_Hint_Context_Scene(Get_Game_Mode_GUI_Scene())
      
      
		-- Central Processor Cleanup
		central_processor = Find_First_Object("NOVUS_CENTRAL_PROCESSOR")
		if TestValid(central_processor) then
			central_processor.Despawn()
		end
		
		-- Markers
		list_starting_grunt_markers = Find_All_Objects_With_Hint("start-grunt")
		if table.getn(list_starting_grunt_markers) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_starting_grunt_markers!"))
		end
		list_robot_runup = Find_All_Objects_With_Hint("runup")
		if table.getn(list_robot_runup) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_robot_runup!"))
		end
		list_guard_markers = Find_All_Objects_With_Hint("guards")
		if table.getn(list_guard_markers) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_guard_markers!"))
		end

		list_spawn_civilian_markers = Find_All_Objects_With_Hint("spawn-civilians")
		if table.getn(list_spawn_civilian_markers) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_spawn_civilian_markers!"))
		end

		marker_camera_start = Find_Hint("MARKER_GENERIC_BLUE","start-camera")
		if not TestValid(marker_camera_start) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_camera_start!"))
		end

		marker_base_01 = Find_Hint("MARKER_GENERIC_BLUE","novus-base-marker1")
		if not TestValid(marker_base_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_base_01!"))
		end
		marker_base_02 = Find_Hint("MARKER_GENERIC_BLUE","novus-base-marker2")
		if not TestValid(marker_base_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_base_02!"))
		end
		marker_base_03 = Find_Hint("MARKER_GENERIC_BLUE","novus-base-marker3")
		if not TestValid(marker_base_03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_base_03!"))
		end

		marker_orlok_start_facing_01 = Find_Hint("MARKER_GENERIC_BLUE","orlok-start-facing-01")
		if not TestValid(marker_orlok_start_facing_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_orlok_start_facing_01!"))
		end

		marker_robot_gather_01 = Find_Hint("MARKER_GENERIC_BLACK","gather01")
		if not TestValid(marker_robot_gather_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_robot_gather_01!"))
		else
			table.insert(list_robot_gather_points, marker_robot_gather_01)
		end
		marker_robot_gather_02 = Find_Hint("MARKER_GENERIC_BLACK","gather02")
		if not TestValid(marker_robot_gather_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_robot_gather_02!"))
		else
			table.insert(list_robot_gather_points, marker_robot_gather_02)
		end
		marker_robot_gather_03 = Find_Hint("MARKER_GENERIC_BLACK","gather03")
		if not TestValid(marker_robot_gather_03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_robot_gather_03!"))
		else
			table.insert(list_robot_gather_points, marker_robot_gather_03)
		end
		
		marker_transport_spawn = Find_Hint("MARKER_GENERIC_BLUE","transport-spawn")
		if not TestValid(marker_transport_spawn) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_transport_spawn!"))
		end
		marker_prox_orlok = Find_Hint("MARKER_GENERIC_BLUE","zm01-prox-orlok")
		if not TestValid(marker_prox_orlok) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_prox_orlok!"))
		end
		marker_prox_walker = Find_Hint("MARKER_GENERIC_BLUE","zm01-prox-walker")
		if not TestValid(marker_prox_walker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_prox_walker!"))
		end
		marker_walker_spawn = Find_Hint("MARKER_GENERIC_BLUE","walker-spawn")
		if not TestValid(marker_walker_spawn) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_walker_spawn!"))
		end
		marker_orlok_start = Find_Hint("MARKER_GENERIC_BLUE","zm01-orlok-start")
		if not TestValid(marker_orlok_start) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_orlok_start!"))
		end
		marker_alien_reinforcement = Find_Hint("MARKER_GENERIC_BLUE","alien-reinforcement")
		if not TestValid(marker_alien_reinforcement) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_alien_reinforcement!"))
		else
			alien_actual_reinforcement_drop_start = marker_alien_reinforcement
		end
		marker_alien_reinforcement_drop = Find_Hint("MARKER_GENERIC_BLUE","alien-reinforcement-drop")
		if not TestValid(marker_alien_reinforcement_drop) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_alien_reinforcement_drop!"))
		else
			alien_actual_reinforcement_drop_end = marker_alien_reinforcement_drop
		end
		marker_alien_reinforcement2 = Find_Hint("MARKER_GENERIC_BLUE","alien-reinforcement2")
		if not TestValid(marker_alien_reinforcement2) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_alien_reinforcement2!"))
		end
		marker_alien_reinforcement_drop2 = Find_Hint("MARKER_GENERIC_BLUE","alien-reinforcement-drop2")
		if not TestValid(marker_alien_reinforcement_drop2) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_alien_reinforcement_drop2!"))
		end
		marker_carpath01 = Find_Hint("MARKER_GENERIC_GREEN","carpath01")
		if not TestValid(marker_carpath01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_carpath01!"))
		end
		marker_carpath02 = Find_Hint("MARKER_GENERIC_GREEN","carpath02")
		if not TestValid(marker_carpath02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_carpath02!"))
		end
		marker_carpath03 = Find_Hint("MARKER_GENERIC_GREEN","carpath03")
		if not TestValid(marker_carpath03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_carpath03!"))
		end
		marker_carpath04 = Find_Hint("MARKER_GENERIC_GREEN","carpath04")
		if not TestValid(marker_carpath04) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_carpath04!"))
		end
		marker_carpath05 = Find_Hint("MARKER_GENERIC_GREEN","carpath05")
		if not TestValid(marker_carpath05) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_carpath05!"))
		end
		marker_carpath06 = Find_Hint("MARKER_GENERIC_GREEN","carpath06")
		if not TestValid(marker_carpath06) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_carpath06!"))
		end
		
		-- Novus Structures
		list_structures_novus_robotic_assembly = Find_All_Objects_Of_Type("NOVUS_ROBOTIC_ASSEMBLY")
		if table.getn(list_structures_novus_robotic_assembly) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_structures_novus_robotic_assembly!"))
		end
		list_structures_novus_vehicle_assembly = Find_All_Objects_Of_Type("NOVUS_VEHICLE_ASSEMBLY")
		if table.getn(list_structures_novus_vehicle_assembly) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_structures_novus_vehicle_assembly!"))
		end
		list_structures_novus_aircraft_assembly = Find_All_Objects_Of_Type("NOVUS_AIRCRAFT_ASSEMBLY_WITH_SCRAMJET_HANGAR")
		if table.getn(list_structures_novus_aircraft_assembly) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_structures_novus_aircraft_assembly!"))
		end
		list_novus_base_buildings_01 = Find_All_Objects_With_Hint("novus-base1")
		total_novus_base_buildings_01 = table.getn(list_novus_base_buildings_01)
		if total_novus_base_buildings_01 <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_novus_base_buildings_01!"))
		end
      novus_power_core = Find_Hint("NOVUS_POWER_ROUTER", "power-core")
		if not TestValid(novus_power_core) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find novus_power_core!"))
		else
		   total_novus_base_buildings_01 = total_novus_base_buildings_01 + 1
		end
		list_novus_base_buildings_02 = Find_All_Objects_With_Hint("novus-base2")
		total_novus_base_buildings_02 = table.getn(list_novus_base_buildings_02)
		if total_novus_base_buildings_02 <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_novus_base_buildings_02!"))
		end
		list_novus_base_buildings_03 = Find_All_Objects_With_Hint("novus-base3")
		total_novus_base_buildings_03 = table.getn(list_novus_base_buildings_03)
		if total_novus_base_buildings_03 <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_novus_base_buildings_03!"))
		end
   	total_novus_structures = total_novus_base_buildings_01 + total_novus_base_buildings_02 + total_novus_base_buildings_03
      
		-- Orlok
		hero = Find_First_Object("Alien_Hero_Orlok")
		if not TestValid(hero) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find hero!"))
		end
		
		Set_Next_State("State_ZM01_Act01")
	end
end

function State_ZM01_Act01(message)
	local i, unit, structure, marker, list_reflex_troopers, alien_grunt_list
	
	if message == OnEnter then

      -- Intro Cinematic
      Fade_Out_Music()
      Fade_Screen_Out(0)
      BlockOnCommand(Play_Bink_Movie("Hierarchy_Intro",true))
	
		-- Orlok:
		if TestValid(hero) then
		
   		-- Orlok 1200 from 2000 = -.4
		   hero.Add_Attribute_Modifier("Universal_Damage_Modifier", -.4)
		   
			hero.Register_Signal_Handler(Callback_Orlok_Killed, "OBJECT_HEALTH_AT_ZERO")
			hero.Register_Signal_Handler(Callback_Orlok_Damaged, "OBJECT_DAMAGED")
			hero_health_critical = hero.Get_Health() * 0.25
			if debug_orlok_invulnerable then
				hero.Make_Invulnerable(true)
			end
		end

		-- Orlok's Contingent and Reinforcements
		Create_Thread("Thread_Alien_Reinforcements")
		Create_Thread("Thread_Departing_Transport")
		for i, marker in pairs (list_starting_grunt_markers) do
			-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	      alien_grunt_list = SpawnList(list_single_grunt, marker, aliens, false, true, true)
	      if TestValid(alien_grunt_list[1]) then
				alien_grunt_list[1].Teleport_And_Face(marker)
	      end
		end
		
		-- Proximities
		Register_Prox(marker_prox_orlok, Prox_Approaching_Pyramid, act1_approach_distance, aliens)
		Register_Prox(marker_base_01, Prox_Approaching_Base, first_base_approach_distance, aliens)
		Register_Prox(marker_prox_orlok, Prox_Approaching_Second_Base, second_base_approach_distance, aliens)
		Register_Prox(marker_carpath01, Prox_Move_Civilian_Vehicles, 200, civilian)
		Register_Prox(marker_carpath02, Prox_Move_Civilian_Vehicles, 50, civilian)
		Register_Prox(marker_carpath03, Prox_Move_Civilian_Vehicles, 50, civilian)
		Register_Prox(marker_carpath04, Prox_Move_Civilian_Vehicles, 50, civilian)
		Register_Prox(marker_carpath05, Prox_Move_Civilian_Vehicles, 50, civilian)
		Register_Prox(marker_carpath06, Prox_Move_Civilian_Vehicles, 50, civilian)
		for i, marker in pairs (list_spawn_civilian_markers) do
   		Register_Prox(marker, Prox_Spawn_Civilians, distance_spawn_civilians, aliens)
		end
		
		-- Novus Guards
		for i, marker in pairs (list_guard_markers) do
			Register_Prox(marker, Prox_Spawn_Guards, distance_spawn_guards, aliens)
		end
		list_reflex_troopers = Find_All_Objects_Of_Type("Novus_Reflex_Trooper")
		if table.getn(list_reflex_troopers) > 0 then
        	-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
        	Hunt(list_reflex_troopers, "AntiDefault", false, true, list_reflex_troopers[1].Get_Position(), distance_reflex_trooper_guard)
		end

		-- Novus Structures
		novus_power_core.Register_Signal_Handler(Callback_Base1_Building_Killed, "OBJECT_HEALTH_AT_ZERO")
		for i, structure in pairs (list_novus_base_buildings_01) do
			structure.Register_Signal_Handler(Callback_Base1_Building_Killed, "OBJECT_HEALTH_AT_ZERO")
		end
		for i, structure in pairs (list_novus_base_buildings_02) do
			structure.Register_Signal_Handler(Callback_Base2_Building_Killed, "OBJECT_HEALTH_AT_ZERO")
		end
		for i, structure in pairs (list_novus_base_buildings_03) do
			structure.Register_Signal_Handler(Callback_Base3_Building_Killed, "OBJECT_HEALTH_AT_ZERO")
		end
		
		Create_Thread("Thread_Intro_Conversation")				
	end
end

function State_ZM01_Act02(message)
   local spawned_walker
   
	if message == OnEnter then
	
		-- Reinforcement Location
		alien_actual_reinforcement_drop_start = marker_alien_reinforcement2
		alien_actual_reinforcement_drop_end = marker_alien_reinforcement_drop2
		
		-- Proximities
		Register_Prox(marker_prox_walker, Prox_Approaching_Final_Base, act2_approach_distance, aliens)
		
		-- Habitat Walker Arrival
		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
		spawned_walker = SpawnList(list_single_habitat_walker, marker_walker_spawn, aliens, false, true, false)
      if TestValid(spawned_walker[1]) then
         habitat_walker = spawned_walker[1]
     		Raise_Game_Event("Reinforcements_Arrived", aliens, habitat_walker.Get_Position())
			Create_Thread("Thread_Walker_Hints")
      	habitat_walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Callback_Walker_Killed") 
         habitat_walker.Override_Max_Speed(.6)
      end
		
		Create_Thread("Thread_Act2_Objectives")
	
		-- Variables
		allow_act1_events = false
		build_quantity = 2
		
	end
end


--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script

function Thread_Act2_Objectives()
   Create_Thread("Thread_Start_Objective_03")
   zm01_objective04 = Add_Objective("TEXT_SP_MISSION_HIE01_OBJECTIVE_04")
   
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE05_02"))
	end
	conversation_occuring = false
	
	Sleep(15)
	
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE05_03"))
	end
	conversation_occuring = false
	
	Sleep(15)

	conversation_occuring = true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE05_05"))
	end
	conversation_occuring = false
end

function Thread_Walker_Hints()
   local leg_hp0, leg_hp1, leg_hp2, leg_hp3, back_hp0, back_hp1, back_hp2, back_hp3
	Add_Independent_Hint(HINT_HM01_WALKER_HARDPOINTS)
	   
   leg_hp0 = Find_All_Objects_Of_Type("Alien_Walker_Habitat_LEG_HP00")
   if TestValid(leg_hp0[1]) then
      leg_hp0[1].Highlight_Small(true)
   end
   leg_hp1 = Find_All_Objects_Of_Type("Alien_Walker_Habitat_LEG_HP01")
   if TestValid(leg_hp1[1]) then
      leg_hp1[1].Highlight_Small(true)
   end
   leg_hp2 = Find_All_Objects_Of_Type("Alien_Walker_Habitat_LEG_HP02")
   if TestValid(leg_hp2[1]) then
      leg_hp2[1].Highlight_Small(true)
   end
   leg_hp3 = Find_All_Objects_Of_Type("Alien_Walker_Habitat_LEG_HP03")
   if TestValid(leg_hp3[1]) then
      leg_hp3[1].Highlight_Small(true)
   end
   back_hp0 = Find_All_Objects_Of_Type("Alien_Walker_Habitat_Back_HP00")
   if TestValid(back_hp0[1]) then
      back_hp0[1].Highlight_Small(true,"HP_Side_00")
   end
   back_hp1 = Find_All_Objects_Of_Type("Alien_Walker_Habitat_Back_HP01")
   if TestValid(back_hp1[1]) then
      back_hp1[1].Highlight_Small(true,"HP_Side_01")
   end
   back_hp2 = Find_All_Objects_Of_Type("Alien_Walker_Habitat_Back_HP02")
   if TestValid(back_hp2[1]) then
      back_hp2[1].Highlight_Small(true,"HP_Side_02")
   end
   back_hp3 = Find_All_Objects_Of_Type("Alien_Walker_Habitat_Back_HP03")
   if TestValid(back_hp3[1]) then
      back_hp3[1].Highlight_Small(true,"HP_Side_03")
   end
   
   Sleep(2)
   if TestValid(leg_hp0[1]) then
      leg_hp0[1].Highlight_Small(false)
   end
   if TestValid(leg_hp1[1]) then
      leg_hp1[1].Highlight_Small(false)
   end
   if TestValid(leg_hp2[1]) then
      leg_hp2[1].Highlight_Small(false)
   end
   if TestValid(leg_hp3[1]) then
      leg_hp3[1].Highlight_Small(false)
   end
   if TestValid(back_hp0[1]) then
      back_hp0[1].Highlight_Small(false)
   end
   if TestValid(back_hp1[1]) then
      back_hp1[1].Highlight_Small(false)
   end
   if TestValid(back_hp2[1]) then
      back_hp2[1].Highlight_Small(false)
   end
   if TestValid(back_hp3[1]) then
      back_hp3[1].Highlight_Small(false)
   end

   Sleep(0.5)
   if TestValid(leg_hp0[1]) then
      leg_hp0[1].Highlight_Small(true)
   end
   if TestValid(leg_hp1[1]) then
      leg_hp1[1].Highlight_Small(true)
   end
   if TestValid(leg_hp2[1]) then
      leg_hp2[1].Highlight_Small(true)
   end
   if TestValid(leg_hp3[1]) then
      leg_hp3[1].Highlight_Small(true)
   end
   if TestValid(back_hp0[1]) then
      back_hp0[1].Highlight_Small(true,"HP_Side_00")
   end
   if TestValid(back_hp1[1]) then
      back_hp1[1].Highlight_Small(true,"HP_Side_01")
   end
   if TestValid(back_hp2[1]) then
      back_hp2[1].Highlight_Small(true,"HP_Side_02")
   end
   if TestValid(back_hp3[1]) then
      back_hp3[1].Highlight_Small(true,"HP_Side_03")
   end

   Sleep(2)
   if TestValid(leg_hp0[1]) then
      leg_hp0[1].Highlight_Small(false)
   end
   if TestValid(leg_hp1[1]) then
      leg_hp1[1].Highlight_Small(false)
   end
   if TestValid(leg_hp2[1]) then
      leg_hp2[1].Highlight_Small(false)
   end
   if TestValid(leg_hp3[1]) then
      leg_hp3[1].Highlight_Small(false)
   end
   if TestValid(back_hp0[1]) then
      back_hp0[1].Highlight_Small(false)
   end
   if TestValid(back_hp1[1]) then
      back_hp1[1].Highlight_Small(false)
   end
   if TestValid(back_hp2[1]) then
      back_hp2[1].Highlight_Small(false)
   end
   if TestValid(back_hp3[1]) then
      back_hp3[1].Highlight_Small(false)
   end

   Sleep(0.5)
   if TestValid(leg_hp0[1]) then
      leg_hp0[1].Highlight_Small(true)
   end
   if TestValid(leg_hp1[1]) then
      leg_hp1[1].Highlight_Small(true)
   end
   if TestValid(leg_hp2[1]) then
      leg_hp2[1].Highlight_Small(true)
   end
   if TestValid(leg_hp3[1]) then
      leg_hp3[1].Highlight_Small(true)
   end
   if TestValid(back_hp0[1]) then
      back_hp0[1].Highlight_Small(true,"HP_Side_00")
   end
   if TestValid(back_hp1[1]) then
      back_hp1[1].Highlight_Small(true,"HP_Side_01")
   end
   if TestValid(back_hp2[1]) then
      back_hp2[1].Highlight_Small(true,"HP_Side_02")
   end
   if TestValid(back_hp3[1]) then
      back_hp3[1].Highlight_Small(true,"HP_Side_03")
   end
   
   Sleep(2)
   if TestValid(leg_hp0[1]) then
      leg_hp0[1].Highlight_Small(false)
   end
   if TestValid(leg_hp1[1]) then
      leg_hp1[1].Highlight_Small(false)
   end
   if TestValid(leg_hp2[1]) then
      leg_hp2[1].Highlight_Small(false)
   end
   if TestValid(leg_hp3[1]) then
      leg_hp3[1].Highlight_Small(false)
   end
   if TestValid(back_hp0[1]) then
      back_hp0[1].Highlight_Small(false)
   end
   if TestValid(back_hp1[1]) then
      back_hp1[1].Highlight_Small(false)
   end
   if TestValid(back_hp2[1]) then
      back_hp2[1].Highlight_Small(false)
   end
   if TestValid(back_hp3[1]) then
      back_hp3[1].Highlight_Small(false)
   end

   Sleep(0.5)
   if TestValid(leg_hp0[1]) then
      leg_hp0[1].Highlight_Small(true)
   end
   if TestValid(leg_hp1[1]) then
      leg_hp1[1].Highlight_Small(true)
   end
   if TestValid(leg_hp2[1]) then
      leg_hp2[1].Highlight_Small(true)
   end
   if TestValid(leg_hp3[1]) then
      leg_hp3[1].Highlight_Small(true)
   end
   if TestValid(back_hp0[1]) then
      back_hp0[1].Highlight_Small(true,"HP_Side_00")
   end
   if TestValid(back_hp1[1]) then
      back_hp1[1].Highlight_Small(true,"HP_Side_01")
   end
   if TestValid(back_hp2[1]) then
      back_hp2[1].Highlight_Small(true,"HP_Side_02")
   end
   if TestValid(back_hp3[1]) then
      back_hp3[1].Highlight_Small(true,"HP_Side_03")
   end
   
   Sleep(2)
   if TestValid(leg_hp0[1]) then
      leg_hp0[1].Highlight_Small(false)
   end
   if TestValid(leg_hp1[1]) then
      leg_hp1[1].Highlight_Small(false)
   end
   if TestValid(leg_hp2[1]) then
      leg_hp2[1].Highlight_Small(false)
   end
   if TestValid(leg_hp3[1]) then
      leg_hp3[1].Highlight_Small(false)
   end
   if TestValid(back_hp0[1]) then
      back_hp0[1].Highlight_Small(false)
   end
   if TestValid(back_hp1[1]) then
      back_hp1[1].Highlight_Small(false)
   end
   if TestValid(back_hp2[1]) then
      back_hp2[1].Highlight_Small(false)
   end
   if TestValid(back_hp3[1]) then
      back_hp3[1].Highlight_Small(false)
   end

   Sleep(0.5)
   if TestValid(leg_hp0[1]) then
      leg_hp0[1].Highlight_Small(true)
   end
   if TestValid(leg_hp1[1]) then
      leg_hp1[1].Highlight_Small(true)
   end
   if TestValid(leg_hp2[1]) then
      leg_hp2[1].Highlight_Small(true)
   end
   if TestValid(leg_hp3[1]) then
      leg_hp3[1].Highlight_Small(true)
   end
   if TestValid(back_hp0[1]) then
      back_hp0[1].Highlight_Small(true,"HP_Side_00")
   end
   if TestValid(back_hp1[1]) then
      back_hp1[1].Highlight_Small(true,"HP_Side_01")
   end
   if TestValid(back_hp2[1]) then
      back_hp2[1].Highlight_Small(true,"HP_Side_02")
   end
   if TestValid(back_hp3[1]) then
      back_hp3[1].Highlight_Small(true,"HP_Side_03")
   end
   
   Sleep(2)
   if TestValid(leg_hp0[1]) then
      leg_hp0[1].Highlight_Small(false)
   end
   if TestValid(leg_hp1[1]) then
      leg_hp1[1].Highlight_Small(false)
   end
   if TestValid(leg_hp2[1]) then
      leg_hp2[1].Highlight_Small(false)
   end
   if TestValid(leg_hp3[1]) then
      leg_hp3[1].Highlight_Small(false)
   end
   if TestValid(back_hp0[1]) then
      back_hp0[1].Highlight_Small(false)
   end
   if TestValid(back_hp1[1]) then
      back_hp1[1].Highlight_Small(false)
   end
   if TestValid(back_hp2[1]) then
      back_hp2[1].Highlight_Small(false)
   end
   if TestValid(back_hp3[1]) then
      back_hp3[1].Highlight_Small(false)
   end
end

function Thread_Intro_Conversation()
	local object, alien_grunt_list, i, unit

	Point_Camera_At(marker_camera_start)
   Fade_Screen_Out(0)
   Lock_Controls(1)
   Sleep(1)
   Start_Cinematic_Camera()
   Letter_Box_In(0.1)
   Transition_Cinematic_Target_Key(marker_camera_start, 0, 0, 0, 0, 0, 0, 0, 0)
   Transition_Cinematic_Camera_Key(marker_camera_start, 0, 200, 55, 65, 1, 0, 0, 0)
   Transition_To_Tactical_Camera(10)
   Fade_Screen_In(1) 

	-- Orlok/Kamal Starting Conversation
	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE02_01"))
	BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE01_SCENE02_02"))

	hero.Attack_Move(marker_orlok_start.Get_Position())
   Letter_Box_Out(1)

	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE02_03"))
   End_Cinematic_Camera()
	Queue_Talking_Head(pip_orlok, "HIE01_SCENE02_04")
	
	-- Move alien units to the first engagement, start the mission.
	alien_grunt_list = Find_All_Objects_Of_Type("ALIEN_GRUNT")
	for i, unit in pairs (alien_grunt_list) do
		if TestValid(unit) then
			unit.Attack_Move(marker_orlok_start.Get_Position())
		end
	end

   Lock_Controls(0)
   	
	-- Novus Construction Threads
	Create_Thread("Thread_Construct_Novus_Robotic_Infantry")
	Create_Thread("Thread_Construct_Novus_Antimatter_Tanks")
	Create_Thread("Thread_Move_Novus_Robots")
		
	-- Civilian Vehicles
	Create_Thread("Thread_Civilian_Vehicles")
		
	-- Initial Assault Robots
	Hunt(list_robot_runup, "AntiDefault", true, false)

	-- Objectives
	
	Sleep(time_radar_sleep)

	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE01_OBJECTIVE_01_ADD"} )
	Sleep(time_objective_sleep)
	zm01_objective01 = Add_Objective("TEXT_SP_MISSION_HIE01_OBJECTIVE_01")
	
	Sleep(time_radar_sleep)

	Add_Radar_Blip(marker_base_01, "DEFAULT", "blip_base_01")
	radar_marker_1_on = true
	
	Sleep(time_objective_sleep)

   if TestValid(hero) then
		Queue_Talking_Head(pip_orlok, "HIE01_SCENE03_02")
	end
end

function Thread_Departing_Transport()
   local transport_leaving, transport_list
   
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	transport_list = SpawnList(list_single_alien_transport, marker_transport_spawn, aliens, false, true, false)
	if TestValid(transport_list[1]) then
	   transport_leaving = transport_list[1]
		transport_leaving.Make_Invulnerable(true)
		transport_leaving.Set_Selectable(false)
		BlockOnCommand(transport_leaving.Move_To(marker_alien_reinforcement.Get_Position()))
	end
	if TestValid(transport_leaving) then
		transport_leaving.Make_Invulnerable(false)
		transport_leaving.Despawn()
	end
end

function Thread_Civilian_Vehicles()
   local spawn_list
   
	while allow_act1_events do
	
		if not TestValid(civilian_vehicle_01) then
			if GameRandom(1,10) > 4 then
	         -- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	         spawn_list = SpawnList(list_single_civilian_truck, marker_carpath01, civilian, false, true, false)
				civilian_vehicle_01 = spawn_list[1]
			else
			   spawn_list = SpawnList(list_single_civilian_station_wagon, marker_carpath01, civilian, false, true, false)
				civilian_vehicle_01 = spawn_list[1]
			end
		end
		
		Sleep(GameRandom(1,20))
		
		if not TestValid(civilian_vehicle_02) then
			if GameRandom(1,10) > 4 then
	         spawn_list = SpawnList(list_single_civilian_truck, marker_carpath01, civilian, false, true, false)
				civilian_vehicle_02 = spawn_list[1]
			else
			   spawn_list = SpawnList(list_single_civilian_station_wagon, marker_carpath01, civilian, false, true, false)
				civilian_vehicle_02 = spawn_list[1]
			end
		end

		Sleep(GameRandom(1,10))

		if not TestValid(civilian_vehicle_03) then
			if GameRandom(1,10) > 4 then
	         spawn_list = SpawnList(list_single_civilian_truck, marker_carpath01, civilian, false, true, false)
				civilian_vehicle_03 = spawn_list[1]
			else
			   spawn_list = SpawnList(list_single_civilian_station_wagon, marker_carpath01, civilian, false, true, false)
				civilian_vehicle_03 = spawn_list[1]
			end
		end
		
		Sleep(10)
		
	end
end

function Thread_Alien_Reinforcements()
	local append_count, alien_grunt_list, i, alien_reinforcements, unit, spawn_list, alien_saucer
	
	while not mission_success and not mission_failure do
		alien_grunt_list = Find_All_Objects_Of_Type("ALIEN_GRUNT")
		if table.getn(alien_grunt_list) < minimum_grunts and reinforcements_allowed then
		   spawn_list = SpawnList(list_single_alien_transport, alien_actual_reinforcement_drop_start, aliens, false, true, false)
		   alien_saucer = spawn_list[1]
			if TestValid(alien_saucer) then
				Create_Thread("Thread_Alien_Reinforcements_Conversation")
				alien_saucer.Set_Selectable(false)
				alien_saucer.Make_Invulnerable(true)
				BlockOnCommand(alien_saucer.Move_To(alien_actual_reinforcement_drop_end.Get_Position()))
      		Raise_Game_Event("Reinforcements_Arrived", aliens, alien_actual_reinforcement_drop_end.Get_Position())
				-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
				alien_reinforcements = SpawnList(list_alien_reinforcement_units, alien_actual_reinforcement_drop_end.Get_Position(), aliens, false, true, true)
				if TestValid(hero) then
					for i, unit in pairs (alien_reinforcements) do
						if TestValid(unit) then
							unit.Attack_Move(hero.Get_Position())
						end
					end
				end
				if TestValid(alien_saucer) then
					BlockOnCommand(alien_saucer.Move_To(alien_actual_reinforcement_drop_start.Get_Position()))
					if TestValid(alien_saucer) then
						alien_saucer.Make_Invulnerable(false)
						alien_saucer.Despawn()
					end
				end
			end
		end
	
		Sleep(time_spawn_reinforcements)		
		
	end
end

function Thread_Alien_Reinforcements_Conversation()
	while conversation_occuring do
		Sleep(1)
	end
	
	conversation_occuring = true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_comm, "HIE01_SCENE03_01"))
	end
	conversation_occuring = false
end

function Thread_Construct_Novus_Robotic_Infantry()
	local i, structure, j
	
	while not mission_success and not mission_failure do
		if total_novus_robots < maximum_novus_robots then
			for i,structure in pairs(list_structures_novus_robotic_assembly) do
				if TestValid(structure) then
					if structure.Get_Hull() > 0 then
						for j = 1, build_quantity do
							Tactical_Enabler_Begin_Production(structure, object_type_robot, 1, novus)
						end
					end
				end
			end
		end
		
		Sleep(time_spawn_novus_robots)
		
	end
end

function Thread_Construct_Novus_Antimatter_Tanks()
	local i, structure
	
	while not mission_success and not mission_failure do
		
		Sleep(time_spawn_novus_tanks)
		
		if total_novus_tanks < maximum_novus_tanks then
			for i,structure in pairs(list_structures_novus_vehicle_assembly) do
				if TestValid(structure) then
					if structure.Get_Hull() > 0 then
						for j = 1, build_quantity do
							Tactical_Enabler_Begin_Production(structure, object_type_antimatter_tank, 1, novus)
						end
					end
				end
			end
		end
	end
end

function Thread_Group_Novus_Robots(obj)
	local i, marker, closest_marker, marker_distance, hint
	
	closest_marker = nil
	marker_distance = 999999
	for i, marker in pairs (list_robot_gather_points) do
		if TestValid(obj) then
			distance = marker.Get_Distance(obj)
			if distance < marker_distance then
				marker_distance = distance
				closest_marker = marker
			end
		end
	end
	if TestValid(closest_marker) and TestValid(obj) then
		obj.Attack_Move(closest_marker.Get_Position())
		hint = closest_marker.Get_Hint()
		if hint == "gather01" then
			robot_team_list_in_use = true
			table.insert(list_robots_01, obj)
			robot_team_list_in_use = false
		elseif hint == "gather02" then
			robot_team_list_in_use = true
			table.insert(list_robots_02, obj)
			robot_team_list_in_use = false
		elseif hint == "gather03" then
			robot_team_list_in_use = true
			table.insert(list_robots_03, obj)
			robot_team_list_in_use = false
		end
	end
end

function Thread_Move_Novus_Robots()
	while not mission_success and not mission_failure do
	
		Sleep (time_move_novus_robots)
		
		if table.getn(list_robots_01) >= robot_team_size then
			while robot_team_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_robots_01) then
			   if allow_act1_events then
				   Hunt(list_robots_01, "AntiDefault", true, false)
				else
            	Hunt(list_robots_01, "AntiDefault", true, true, list_robots_01[1].Get_Position(), distance_defense_mode)
				end
			end
			list_robots_01 = {}
		end
		if table.getn(list_robots_02) >= robot_team_size then
			while robot_team_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_robots_02) then
			   if allow_act1_events then
				   Hunt(list_robots_02, "AntiDefault", true, false)
				else
            	Hunt(list_robots_02, "AntiDefault", true, true, list_robots_02[1].Get_Position(), distance_defense_mode)
				end
			end
			list_robots_02 = {}
		end
		if table.getn(list_robots_03) >= robot_team_size then
			while robot_team_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_robots_03) then
			   if allow_act1_events then
				   Hunt(list_robots_03, "AntiDefault", true, false)
				else
            	Hunt(list_robots_03, "AntiDefault", true, true, list_robots_03[1].Get_Position(), distance_defense_mode)
				end
			end
			list_robots_03 = {}
		end
	end
end

function Thread_Conversation_Second_Base()
	while conversation_occuring do
		Sleep(1)
	end
		
	if not mission_success and not mission_failure then
		conversation_occuring = true
		if total_novus_structures > 12 then
			BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE05_01"))
		else
			BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE03_04"))
		end
		conversation_occuring = false
	end
	reinforcements_allowed = true
   Create_Thread("Thread_Start_Objective_02")

	while conversation_occuring do
		Sleep(1)
	end
	if not mission_success and not mission_failure then
		conversation_occuring = true
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE02_05"))
		BlockOnCommand(Queue_Talking_Head(pip_science, "HIE01_SCENE02_06"))
		conversation_occuring = false
	end
end

function Thread_Prox_Approaching_Pyramid()
	while conversation_occuring do
		Sleep(1)
	end
	
	conversation_occuring = true
	if not mission_failure and not mission_success then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE01_SCENE04_01"))
	end
	if not mission_failure and not mission_success then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE04_02"))
	end
	if not mission_failure and not mission_success then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE01_SCENE04_03"))
	end
	if not mission_failure and not mission_success then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE04_04"))
	end
	if not mission_failure and not mission_success then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE01_SCENE04_05"))
	end
	Sleep(1)
	if not mission_failure and not mission_success then
		BlockOnCommand(Queue_Talking_Head(pip_grunt, "HIE01_SCENE04_06"))
	end
	if not mission_failure and not mission_success then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE04_07"))
	end
	if not mission_failure and not mission_success then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE04_08"))
	end
	conversation_occuring = false
	Set_Next_State("State_ZM01_Act02")
end

function Thread_Prox_Approaching_Base()
	while conversation_occuring do
		Sleep(1)
	end
	
	conversation_occuring = true
	if not mission_failure and not mission_success then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE03_03"))
	end
	conversation_occuring = false
end

function Thread_Callback_Orlok_Damaged_Conversation()
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_failure and not mission_success then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE01_SCENE03_05"))
	end
	conversation_occuring = false
end

function Thread_Start_Objective_02()
   if not radar_marker_2_on then
	   radar_marker_2_on = true
	   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE01_OBJECTIVE_02_ADD"} )
      Sleep(time_objective_sleep)
	   zm01_objective02 = Add_Objective("TEXT_SP_MISSION_HIE01_OBJECTIVE_02")
   	
      Sleep(time_radar_sleep)
	   Add_Radar_Blip(marker_base_02, "DEFAULT", "blip_base_02")
	end
end

function Thread_Start_Objective_03()
   if not radar_marker_3_on then
      radar_marker_3_on = true
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE01_OBJECTIVE_03_ADD"} )
      Sleep(time_objective_sleep)
      zm01_objective03 = Add_Objective("TEXT_SP_MISSION_HIE01_OBJECTIVE_03")

      Sleep(time_radar_sleep)
	   Add_Radar_Blip(marker_base_03, "DEFAULT", "blip_base_03")
   end
end


--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script

function TestListValid(list)
	local i, unit, valid
	
	valid = true
	for i, unit in pairs(list) do
		if not TestValid(unit) then
			valid = false
			i = table.getn(list)
		end
	end
	return valid
end

function Cache_Models()
	Find_Object_Type("Novus_Robotic_Infantry").Load_Assets()
	Find_Object_Type("NOVUS_DERVISH_JET").Load_Assets()
	Find_Object_Type("NOVUS_ANTIMATTER_TANK").Load_Assets()
	Find_Object_Type("Civilian_Pickup_Truck_01_Mobile").Load_Assets()
	Find_Object_Type("Civilian_Station_Wagon_01_Mobile").Load_Assets()
	Find_Object_Type("Alien_Walker_Habitat").Load_Assets()
end

function Story_On_Construction_Complete(obj)
	local obj_type
	
	if TestValid(obj) then
		if obj.Get_Owner().Get_Faction_Name() == "NOVUS" then
			obj_type = obj.Get_Type()
			if obj_type == object_type_robot then
				Create_Thread("Thread_Group_Novus_Robots", obj)
				total_novus_robots = total_novus_robots + 1
				obj.Register_Signal_Handler(Callback_Novus_Robot_Killed, "OBJECT_HEALTH_AT_ZERO")
			elseif obj_type == object_type_antimatter_tank then
				total_novus_tanks = total_novus_tanks + 1
				obj.Register_Signal_Handler(Callback_Novus_Tank_Killed, "OBJECT_HEALTH_AT_ZERO")
				if allow_act1_events then
				   Hunt(obj, "AntiDefault", true, false)
				else
            	-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
            	Hunt(obj, "AntiDefault", true, true, obj.Get_Position(), distance_defense_mode)
				end
			end
		end
	end
end

function Callback_Novus_Robot_Killed()
	total_novus_robots = total_novus_robots - 1
end

function Callback_Novus_Tank_Killed()
	total_novus_tanks = total_novus_tanks - 1
end

function Callback_Novus_Jet_Killed()
	total_novus_jets = total_novus_jets - 1
end

function Prox_Spawn_Guards(prox_obj, trigger_obj)
	local robot_list, i, unit
	
	prox_obj.Cancel_Event_Object_In_Range(Prox_Spawn_Guards)
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	robot_list = SpawnList(list_robots, prox_obj, novus, false, true, false)
	if table.getn(robot_list) > 0 then
		for i, unit in pairs (robot_list) do
			unit.Guard_Target(unit.Get_Position())
		end
	end
end

function Prox_Move_Civilian_Vehicles(prox_obj, trigger_obj)
	if TestValid(trigger_obj) then
		local obj_type = trigger_obj.Get_Type()
		if obj_type == object_type_civilian_pickup_truck or obj_type == object_type_civilian_station_wagon then
			if prox_obj == marker_carpath01 then
				trigger_obj.Move_To(marker_carpath02.Get_Position())
			elseif prox_obj == marker_carpath02 then
				trigger_obj.Move_To(marker_carpath03.Get_Position())
			elseif prox_obj == marker_carpath03 then
				trigger_obj.Move_To(marker_carpath04.Get_Position())
			elseif prox_obj == marker_carpath04 then
				trigger_obj.Move_To(marker_carpath05.Get_Position())
			elseif prox_obj == marker_carpath05 then
				trigger_obj.Move_To(marker_carpath06.Get_Position())
			else
				trigger_obj.Despawn()
			end
		end
	end	
end

function Prox_Approaching_Second_Base(prox_obj, trigger_obj)
	if trigger_obj.Get_Type() ~= object_type_transport then
		prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Second_Base)
		Create_Thread("Thread_Conversation_Second_Base")
	end
end

function Prox_Spawn_Civilians(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Spawn_Civilians)
   -- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
   SpawnList(list_civilians, prox_obj.Get_Position(), civilian, false, true, false)
end

function Prox_Approaching_Pyramid(prox_obj, trigger_obj)
	if trigger_obj.Get_Type() ~= object_type_transport then
		prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Pyramid)
		if not mission_failure then
			Create_Thread("Thread_Prox_Approaching_Pyramid")
		end
	end
end

function Prox_Approaching_Final_Base(prox_obj, trigger_obj)
	if not mission_success and not mission_failure then
		if total_novus_structures <= 3 then
			prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Final_Base)
   		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE01_OBJECTIVE_03_COMPLETE"} )
			Create_Thread("Thread_Mission_Complete")
		end
	else
		prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Final_Base)
	end
end

function Prox_Approaching_Base(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Base)
	
	if TestValid(hero) then
      if TestValid(novus_power_core) then
	   	Add_Attached_Hint(hero, HINT_HM01_ORLOK_SIEGE_ABILITY)
		   Create_Thread("Thread_Prox_Approaching_Base")
   	   fow_power_core_01 = FogOfWar.Reveal(aliens, novus_power_core, distance_fow_reveal_power_core, distance_fow_reveal_power_core)
      	novus_power_core.Highlight(true)
	      fow_power_core_revealed = true
	   end
	end
end

function Callback_Orlok_Killed()
	if not mission_success and not mission_failure then
		Create_Thread("Thread_Mission_Failed","TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ORLOK")
	end
end

function Callback_Walker_Killed()
	if not mission_success and not mission_failure then
		Create_Thread("Thread_Mission_Failed","TEXT_SP_MISSION_HIE01_OBJECTIVE_04_FAILED")
	end
end

function Callback_Base1_Building_Killed()

   if fow_power_core_revealed then
	   fow_power_core_01.Undo_Reveal()
	end   

	total_novus_structures = total_novus_structures - 1
	if total_novus_structures <= 0 then
		if not mission_success and not mission_failure then
   		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE01_OBJECTIVE_01_COMPLETE"} )
			Create_Thread("Thread_Mission_Complete")
		end
   else
      total_novus_base_buildings_01 = total_novus_base_buildings_01 - 1
      if total_novus_base_buildings_01 <= 0 then
		   if radar_marker_1_on then
			   Remove_Radar_Blip("blip_base_01")
   		   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE01_OBJECTIVE_01_COMPLETE"} )
      	   Objective_Complete(zm01_objective01)
      	   Create_Thread("Thread_Start_Objective_02")
		   end
		end
   end
end

function Callback_Base2_Building_Killed()
	total_novus_structures = total_novus_structures - 1
	if total_novus_structures <= 0 then
		if not mission_success and not mission_failure then
   		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE01_OBJECTIVE_02_COMPLETE"} )
			Create_Thread("Thread_Mission_Complete")
		end
   else
      total_novus_base_buildings_02 = total_novus_base_buildings_02 - 1
      if total_novus_base_buildings_02 <= 0 then
		   if radar_marker_2_on then
			   Remove_Radar_Blip("blip_base_02")
   		   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE01_OBJECTIVE_02_COMPLETE"} )
      	   Objective_Complete(zm01_objective02)
            Create_Thread("Thread_Start_Objective_03")
		   end
		end
   end
end

function Callback_Base3_Building_Killed()
	total_novus_structures = total_novus_structures - 1
	if total_novus_structures <= 0 then
		if not mission_success and not mission_failure then
   		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE01_OBJECTIVE_03_COMPLETE"} )
			Create_Thread("Thread_Mission_Complete")
		end
   else
      total_novus_base_buildings_03 = total_novus_base_buildings_03 - 1
      if total_novus_base_buildings_03 <= 0 then
		   if radar_marker_3_on then
			   Remove_Radar_Blip("blip_base_03")
   		   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE01_OBJECTIVE_03_COMPLETE"} )
      	   Objective_Complete(zm01_objective03)
		   end
		end
   end
end

function Callback_Orlok_Damaged()
	local obj_health
	
	if TestValid(hero) then
		if not mission_success and not mission_failure and not orlok_damaged_hint then
			obj_health = hero.Get_Health()
			if obj_health < hero_health_critical then
				orlok_damaged_hint = true
				Create_Thread("Thread_Callback_Orlok_Damaged_Conversation")
			end
		end
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
	Play_Music("Lose_To_Novus_Event")
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,30)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {mission_failed_text} )
	Sleep(time_objective_sleep)
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
   if TestValid(hero) then
      hero.Set_Cannot_Be_Killed(true)
   end
   if radar_marker_1_on then
	   Remove_Radar_Blip("blip_base_01")
	   Objective_Complete(zm01_objective01)
	end
   if radar_marker_2_on then
	   Remove_Radar_Blip("blip_base_02")
	   Objective_Complete(zm01_objective02)
	end
	if radar_marker_3_on then
	   Remove_Radar_Blip("blip_base_03")
   	Objective_Complete(zm01_objective03)
	end
   
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

   Fade_Out_Music()
	BlockOnCommand(Play_Bink_Movie("Hierarchy_M1_S3",true))		
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
	UI_Hide_Research_Button()
	UI_Hide_Sell_Button()
	Movie_Commands_Post_Load_Callback()
end