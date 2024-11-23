-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM02.lua#98 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM02.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Dan_Etter $
--
--            $Change: 90583 $
--
--          $DateTime: 2008/01/09 09:21:47 $
--
--          $Revision: #98 $
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
	Define_State("State_ZM02_Active", State_ZM02_Active)

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
--	military.Enable_Colorization(true, COLOR_GREEN)
	
	-- Object Types
	object_type_military_infantry = Find_Object_Type("Military_Team_Marines")
	object_type_military_tank = Find_Object_Type("Military_AbramsM2_Tank")
	object_type_military_hummer = Find_Object_Type("Military_Hummer")
	object_type_missile_destroyed = Find_Object_Type("HM02_Military_Missile_Death_Clone")
	
	object_type_robot = Find_Object_Type("Novus_Robotic_Infantry")
	object_type_antimatter_tank = Find_Object_Type("NOVUS_ANTIMATTER_TANK")
	
	object_type_glyph_carver = Find_Object_Type("Alien_Glyph_Carver")
	object_type_cylinder = Find_Object_Type("Alien_Cylinder")
	object_type_lost_one = Find_Object_Type("Alien_Lost_One")
	object_type_transport = Find_Object_Type("ALIEN_AIR_RETREAT_TRANSPORT")
	object_type_reaper = Find_Object_Type("Alien_Superweapon_Reaper_Turret")
	object_type_scan_drone = Find_Object_Type("Alien_Scan_Drone")
	object_type_grunt = Find_Object_Type("Alien_Grunt")
	object_type_habitat_walker = Find_Object_Type("Alien_Walker_Habitat")
	object_type_arrival_site = Find_Object_Type("Alien_Arrival_Site")
	object_type_spitter_turret = Find_Object_Type("Alien_Radiation_Spitter")
		
	-- Unit Lists
	list_alien_monoliths = {
		"Alien_Cylinder",
		"Alien_Cylinder",
		"Alien_Cylinder"
	}
	
	list_alien_starting_units = {
		"Alien_Glyph_Carver",
		"Alien_Glyph_Carver",
		"Alien_Lost_One",
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
		"Alien_Grunt"
	}
	
	list_basic_marines = {
		"Military_Team_Marines"
	}
	
	list_basic_rocketlaunchers = {
		"Military_Team_Rocketlauncher"
	}
		
	list_rocket_defenders = {
		"Military_Team_Rocketlauncher",
		"Military_Team_Rocketlauncher",
		"Military_Team_Rocketlauncher",
		"Military_Team_Marines",
		"Military_AbramsM2_Tank",
		"Novus_Antimatter_Tank",
		"Novus_Antimatter_Tank"
	}
	
	list_novus_amplifiers = {
		"Novus_Amplifier",
		"Novus_Amplifier",
		"Novus_Amplifier"
	}
	
	list_novus_dervish_jets = {
	   "Novus_Dervish_Jet",
	   "Novus_Dervish_Jet",
	   "Novus_Dervish_Jet",
	   "Novus_Dervish_Jet",
	   "Novus_Dervish_Jet",
	   "Novus_Dervish_Jet"
	}
		
	list_single_military_hummer = {
	   "Military_Hummer"
	}
	
	list_single_military_missile_destroyed = {
	   "HM02_Military_Missile_Death_Clone"
	}

	-- Fog of War Handles
	fow_rocket01 = nil
	fow_rocket02 = nil
	fow_rocket03 = nil
	
	fow_gantry01 = nil
	fow_gantry02 = nil
	fow_gantry03 = nil

	-- Variables
	mission_success = false
	mission_failure = false

	time_objective_sleep = 5
	time_radar_sleep = 2

	total_military_infantry = 0	
	maximum_military_infantry = 15
	time_build_infantry = 60
	
	total_military_tanks = 0
	maximum_military_tanks = 3
	time_build_tanks = 90
		
	total_novus_robots = 0
	maximum_novus_robots = 8
	time_spawn_novus_robots = 60

	total_novus_tanks = 0
	maximum_novus_tanks = 4
	time_spawn_novus_tanks = 60
	
	time_spawn_hummer_patrols = 10
	time_move_military_team = 60
	time_delay_guard_marine_move = 4
	time_patrols_active_sleep = 300
	patrols_active = false
	
	novus_active = false
	
	military_team_list_in_use = false
	list_military_team = {}
	military_team_size = 3

   time_rocket_02_explosion = 4.75
   time_rocket_03_explosion = 1.75
   time_despawn_first_rocket = 3.5
   time_delay_strike_team = 15
	
	distance_notice_wall = 800
	distance_approach_rocket = 700
	distance_marine_spawn = 300
	infantry_proximity_to_protector = 200
	distance_approach_cows = 500
	distance_virus_ability = 300
	distance_first_rocket_guards = 1600
	distance_crush_gantry = 100
	
	first_rocket_fired = false
	first_rocket_complete = false
	rocket02_killed = false
	rocket03_killed = false
	
	hummer_patrol_01 = nil
	hummer_patrol_02 = nil
	dervish_strike_team_target = nil
	
	conversation_occuring = false
	
	first_reaper_warning_given = false
	arrival_site_damage_notice = false
	first_objective_active = false
   built_reaper_drone = false
   objective_reaper_drone = false
	built_detection_drone = false
	objective_detection_drone = false
	built_spitter_turret = false
	objective_spitter_turret = false
	built_habitat_walker = false
	objective_habitat_walker = false
   
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
	local credits, credit_total
	
	if message == OnEnter then
		novus.Allow_Autonomous_AI_Goal_Activation(false)
		masari.Allow_Autonomous_AI_Goal_Activation(false)		

	   military.Allow_AI_Unit_Behavior(false)
	   novus.Allow_AI_Unit_Behavior(false)
	   masari.Allow_AI_Unit_Behavior(false)

   	Set_Active_Context("ZM02")
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
		
		_CustomScriptMessage("RickLog.txt", string.format("*********************************************Story_Campaign_Hierarchy_ZM02 START!"))

		Cache_Models()
		
		UI_Hide_Research_Button()
		--UI_Hide_Sell_Button()

		Fade_Screen_Out(0)

		-- Alliances
		military.Make_Ally(novus)
		novus.Make_Ally(military)
		
		-- Construction Locks/Unlocks
		aliens.Reset_Story_Locks()
		aliens.Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Retreat_From_Tactical_Ability", true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Brute_Mutator"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Terrain_Conditioner"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Foo_Chamber"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Arc_Trigger"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Range_Enhancer"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Brute"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Superweapon_Mass_Drop"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Gravitic_Manipulator"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Kamal_Rex"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Nufai"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Orlok"),true,STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Lost_One_Plasma_Bomb_Unit_Ability", false,STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Grey_Phase_Unit_Ability", false,STORY)
		aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("Alien_Grunt"), "Grunt_Grenade_Attack", false, STORY)

		-- Hint System Initialization
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		Register_Hint_Context_Scene(Get_Game_Mode_GUI_Scene())

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
		military.Give_Money(1000000)

		-- Central Processor Cleanup
		central_processor = Find_First_Object("NOVUS_CENTRAL_PROCESSOR")
		if TestValid(central_processor) then
			central_processor.Despawn()
		end

		-- Markers
		marker_arrival_site = Find_Hint("MARKER_GENERIC_GREEN","arrival-site")
		if not TestValid(marker_arrival_site) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_arrival_site!"))
		end
		wall_notice_01 = Find_Hint("MARKER_GENERIC_GREEN","wall-notice-01")
		if not TestValid(wall_notice_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find wall_notice_01!"))
		end
		wall_notice_02 = Find_Hint("MARKER_GENERIC_GREEN","wall-notice-02")
		if not TestValid(wall_notice_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find wall_notice_02!"))
		end
		wall_notice_03 = Find_Hint("MARKER_GENERIC_GREEN","wall-notice-03")
		if not TestValid(wall_notice_03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find wall_notice_03!"))
		end
		wall_notice_04 = Find_Hint("MARKER_GENERIC_GREEN","wall-notice-04")
		if not TestValid(wall_notice_04) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find wall_notice_04!"))
		end
		invading_prox = Find_Hint("MARKER_GENERIC_GREEN","invading")
		if not TestValid(invading_prox) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find invading_prox!"))
		end

		cows_highlight = Find_Hint("MARKER_GENERIC_GREEN","cows")
		if not TestValid(cows_highlight) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find cows_highlight!"))
		end
		radar01 = Find_Hint("MARKER_GENERIC_RED","radar01")
		if not TestValid(radar01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find radar01!"))
		end
		marker_transport = Find_Hint("MARKER_GENERIC_RED","transport-leave")
		if not TestValid(marker_transport) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_transport!"))
		end

		marker_rally_point = Find_Hint("MARKER_GENERIC_BLUE","rally-point")
		if not TestValid(marker_rally_point) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_rally_point!"))
		end

		marker_rocket_01_guards = Find_Hint("MARKER_GENERIC_GREEN","rocket01event")
		if not TestValid(marker_rocket_01_guards) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_rocket_01_guards!"))
		end
		marker_rocket_02_guards = Find_Hint("MARKER_GENERIC_GREEN","rocket02event")
		if not TestValid(marker_rocket_02_guards) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_rocket_02_guards!"))
		end
		marker_rocket_03_guards = Find_Hint("MARKER_GENERIC_GREEN","rocket03event")
		if not TestValid(marker_rocket_03_guards) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_rocket_03_guards!"))
		end

		marker_military_vehicle_patrol_01 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol01")
		if not TestValid(marker_military_vehicle_patrol_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_01!"))
		end
		marker_military_vehicle_patrol_02 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol02")
		if not TestValid(marker_military_vehicle_patrol_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_02!"))
		end
		marker_military_vehicle_patrol_03 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol03")
		if not TestValid(marker_military_vehicle_patrol_03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_03!"))
		end
		marker_military_vehicle_patrol_04 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol04")
		if not TestValid(marker_military_vehicle_patrol_04) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_04!"))
		end
		marker_military_vehicle_patrol_05 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol05")
		if not TestValid(marker_military_vehicle_patrol_05) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_05!"))
		end
		marker_military_vehicle_patrol_06 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol06")
		if not TestValid(marker_military_vehicle_patrol_06) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_06!"))
		end
		
		marker_military_vehicle_patrol_11 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol11")
		if not TestValid(marker_military_vehicle_patrol_11) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_11!"))
		end
		marker_military_vehicle_patrol_12 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol12")
		if not TestValid(marker_military_vehicle_patrol_12) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_12!"))
		end
		marker_military_vehicle_patrol_13 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol13")
		if not TestValid(marker_military_vehicle_patrol_13) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_13!"))
		end
		marker_military_vehicle_patrol_14 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol14")
		if not TestValid(marker_military_vehicle_patrol_14) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_14!"))
		end
		marker_military_vehicle_patrol_15 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol15")
		if not TestValid(marker_military_vehicle_patrol_15) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_15!"))
		end
		marker_military_vehicle_patrol_16 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol16")
		if not TestValid(marker_military_vehicle_patrol_16) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_16!"))
		end
		marker_military_vehicle_patrol_17 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol17")
		if not TestValid(marker_military_vehicle_patrol_17) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_17!"))
		end
		marker_military_vehicle_patrol_18 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol18")
		if not TestValid(marker_military_vehicle_patrol_18) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_18!"))
		end
		marker_military_vehicle_patrol_19 = Find_Hint("MARKER_GENERIC_RED","military-vehicle-patrol19")
		if not TestValid(marker_military_vehicle_patrol_19) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_vehicle_patrol_19!"))
		end

		marker_military_infantry_patrol_01 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol01")
		if not TestValid(marker_military_infantry_patrol_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_01!"))
		end
		marker_military_infantry_patrol_02 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol02")
		if not TestValid(marker_military_infantry_patrol_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_02!"))
		end
		marker_military_infantry_patrol_03 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol03")
		if not TestValid(marker_military_infantry_patrol_03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_03!"))
		end
		marker_military_infantry_patrol_04 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol04")
		if not TestValid(marker_military_infantry_patrol_04) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_04!"))
		end
		marker_military_infantry_patrol_05 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol05")
		if not TestValid(marker_military_infantry_patrol_05) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_05!"))
		end
		marker_military_infantry_patrol_06 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol06")
		if not TestValid(marker_military_infantry_patrol_06) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_06!"))
		end
		marker_military_infantry_patrol_07 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol07")
		if not TestValid(marker_military_infantry_patrol_07) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_07!"))
		end
		marker_military_infantry_patrol_08 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol08")
		if not TestValid(marker_military_infantry_patrol_08) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_08!"))
		end
		marker_military_infantry_patrol_09 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol09")
		if not TestValid(marker_military_infantry_patrol_09) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_09!"))
		end
		marker_military_infantry_patrol_10 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol10")
		if not TestValid(marker_military_infantry_patrol_10) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_10!"))
		end

		marker_military_infantry_patrol_11 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol11")
		if not TestValid(marker_military_infantry_patrol_11) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_11!"))
		end
		marker_military_infantry_patrol_12 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol12")
		if not TestValid(marker_military_infantry_patrol_12) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_12!"))
		end
		marker_military_infantry_patrol_13 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol13")
		if not TestValid(marker_military_infantry_patrol_13) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_13!"))
		end
		marker_military_infantry_patrol_14 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol14")
		if not TestValid(marker_military_infantry_patrol_14) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_14!"))
		end
		marker_military_infantry_patrol_15 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol15")
		if not TestValid(marker_military_infantry_patrol_15) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_15!"))
		end
		marker_military_infantry_patrol_16 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol16")
		if not TestValid(marker_military_infantry_patrol_16) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_16!"))
		end
		marker_military_infantry_patrol_17 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol17")
		if not TestValid(marker_military_infantry_patrol_17) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_17!"))
		end
		marker_military_infantry_patrol_18 = Find_Hint("MARKER_GENERIC_PURPLE","military-infantry-patrol18")
		if not TestValid(marker_military_infantry_patrol_18) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_military_infantry_patrol_18!"))
		end

		-- Military Structures
		list_structures_military_barracks = Find_All_Objects_Of_Type("MILITARY_BARRACKS")
		if table.getn(list_structures_military_barracks) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_structures_military_barracks!"))
		end
		list_structures_military_motor_pool = Find_All_Objects_Of_Type("MILITARY_MOTOR_POOL")
		if table.getn(list_structures_military_motor_pool) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_structures_military_motor_pool!"))
		end
		list_structures_military_aircraft_pad = Find_All_Objects_Of_Type("MILITARY_AIRCRAFT_PAD")
		if table.getn(list_structures_military_aircraft_pad) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_structures_military_aircraft_pad!"))
		end
		
		-- Novus Structures
		list_structures_novus_aircraft_assembly = Find_All_Objects_Of_Type("NOVUS_AIRCRAFT_ASSEMBLY")
		if table.getn(list_structures_novus_aircraft_assembly) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_structures_novus_aircraft_assembly!"))
		end
		list_structures_novus_robotic_assembly = Find_All_Objects_Of_Type("NOVUS_ROBOTIC_ASSEMBLY")
		if table.getn(list_structures_novus_robotic_assembly) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_structures_novus_robotic_assembly!"))
		end
		list_structures_novus_vehicle_assembly = Find_All_Objects_Of_Type("NOVUS_VEHICLE_ASSEMBLY")
		if table.getn(list_structures_novus_vehicle_assembly) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_structures_novus_vehicle_assembly!"))
		end

		-- Rockets
		rocket01 = Find_Hint("MARKER_GENERIC_GREEN","rocket01")
		if not TestValid(rocket01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find rocket01!"))
		end
		rocket02 = Find_Hint("MARKER_GENERIC_GREEN","rocket02")
		if not TestValid(rocket02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find rocket02!"))
		end
		rocket02_explode = Find_Hint("MARKER_GENERIC_GREEN","rocket02explode")
		if not TestValid(rocket02_explode) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find rocket02_explode!"))
		end
		rocket03_explode = Find_Hint("MARKER_GENERIC_GREEN","rocket03explosion")
		if not TestValid(rocket03_explode) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find rocket03_explode!"))
		end
		rocket03 = Find_Hint("MARKER_GENERIC_GREEN","rocket03")
		if not TestValid(rocket03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find rocket03!"))
		end
		realrocket01 = Find_Hint("HM02_Military_Launch_Gantry","realrocket01")
		if not TestValid(realrocket01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find realrocket01!"))
		end
		realrocket02 = Find_Hint("HM02_Military_Launch_Gantry","realrocket02")
		if not TestValid(realrocket02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find realrocket02!"))
		end
		realrocket03 = Find_Hint("HM02_Military_Launch_Gantry","realrocket03")
		if not TestValid(realrocket03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find realrocket03!"))
		end
		animrocket01 = Find_Hint("HM02_Military_Missile","missile1")
		if not TestValid(animrocket01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find animrocket01!"))
		end
		animrocket02 = Find_Hint("HM02_Military_Missile","missile2")
		if not TestValid(animrocket02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find animrocket02!"))
		end
		animrocket03 = Find_Hint("HM02_Military_Missile","missile3")
		if not TestValid(animrocket03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find animrocket03!"))
		end

		-- Orlok
		hero = Find_First_Object("Alien_Hero_Orlok")
		if not TestValid(hero) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find hero!"))
		end

		-- Infantry Patrols
		infantry_patrol_01 = Find_Hint("MARKER_GENERIC_BLUE","infantry-patrol01")
		if not TestValid(infantry_patrol_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find infantry_patrol_01!"))
		end
		infantry_patrol_02 = Find_Hint("MARKER_GENERIC_BLUE","infantry-patrol02")
		if not TestValid(infantry_patrol_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find infantry_patrol_02!"))
		end
		infantry_patrol_03 = Find_Hint("MARKER_GENERIC_BLUE","infantry-patrol03")
		if not TestValid(infantry_patrol_03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find infantry_patrol_03!"))
		end
		infantry_patrol_04 = Find_Hint("MARKER_GENERIC_BLUE","infantry-patrol04")
		if not TestValid(infantry_patrol_04) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find infantry_patrol_04!"))
		end
		infantry_patrol_05 = Find_Hint("MARKER_GENERIC_BLUE","infantry-patrol05")
		if not TestValid(infantry_patrol_05) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find infantry_patrol_05!"))
		end
		infantry_patrol_06 = Find_Hint("MARKER_GENERIC_BLUE","infantry-patrol06")
		if not TestValid(infantry_patrol_06) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find infantry_patrol_06!"))
		end
		infantry_patrol_07 = Find_Hint("MARKER_GENERIC_BLUE","infantry-patrol07")
		if not TestValid(infantry_patrol_07) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find infantry_patrol_07!"))
		end
		infantry_patrol_08 = Find_Hint("MARKER_GENERIC_BLUE","infantry-patrol08")
		if not TestValid(infantry_patrol_08) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find infantry_patrol_08!"))
		end
		infantry_patrol_09 = Find_Hint("MARKER_GENERIC_BLUE","infantry-patrol09")
		if not TestValid(infantry_patrol_09) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find infantry_patrol_09!"))
		end
		infantry_patrol_10 = Find_Hint("MARKER_GENERIC_BLUE","infantry-patrol10")
		if not TestValid(infantry_patrol_10) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find infantry_patrol_10!"))
		end

		list_walls = Find_All_Objects_With_Hint("wall")
		if table.getn(list_walls) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_walls!"))
		end
		
		-- Infantry Guards
		list_marine_guards = Find_All_Objects_With_Hint("marine-guard")
		if table.getn(list_marine_guards) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_marine_guards!"))
		end
		list_rocket_guards = Find_All_Objects_With_Hint("rocket-guard")
		if table.getn(list_rocket_guards) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_rocket_guards!"))
		end
				
		Create_Thread("Thread_Mission_Introduction")
		Set_Next_State("State_ZM02_Active")

	end
end

function State_ZM02_Active(message)
	local list_cylinders, i, j, unit, marker, alien_starting_forces, marines, unit_type, wall, spawn_list
	
	if message == OnEnter then
		   
		-- Rockets
		realrocket01.Register_Signal_Handler(Callback_Rocket01_Damaged, "OBJECT_DAMAGED")
		realrocket01.Register_Signal_Handler(Callback_Rocket01_Damaged, "OBJECT_HEALTH_AT_ZERO")
		
		realrocket02.Register_Signal_Handler(Callback_Rocket02_Damaged, "OBJECT_DAMAGED")
		realrocket02.Register_Signal_Handler(Callback_Rocket02_Damaged, "OBJECT_HEALTH_AT_ZERO")
		realrocket02.Make_Invulnerable(true)
		realrocket03.Register_Signal_Handler(Callback_Rocket03_Damaged, "OBJECT_DAMAGED")
		realrocket03.Register_Signal_Handler(Callback_Rocket03_Damaged, "OBJECT_HEALTH_AT_ZERO")
		realrocket03.Make_Invulnerable(true)
		animrocket01.Play_Animation("Anim_Idle", true, 0)
		animrocket02.Play_Animation("Anim_Idle", true, 0)
		animrocket03.Play_Animation("Anim_Idle", true, 0)
		fow_gantry01 = FogOfWar.Reveal(aliens, realrocket01, 30, 30)
		fow_gantry02 = FogOfWar.Reveal(aliens, realrocket02, 30, 30)
		fow_gantry03 = FogOfWar.Reveal(aliens, realrocket03, 30, 30)

		-- Proximities
		Register_Prox(cows_highlight, Prox_Approaching_Cows, distance_approach_cows, aliens)
		Register_Prox(rocket01, Prox_Approaching_Rocket_01, distance_approach_rocket, aliens)
		Register_Prox(rocket02, Prox_Approaching_Rocket_02, distance_approach_rocket, aliens)
		Register_Prox(rocket03, Prox_Approaching_Rocket_03, distance_approach_rocket, aliens)
		
		Register_Prox(marker_military_vehicle_patrol_01, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_02, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_03, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_04, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_05, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_06, Prox_Move_Military_Vehicle_Patrol, 50, military)

		Register_Prox(marker_military_vehicle_patrol_11, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_12, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_13, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_14, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_15, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_16, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_17, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_18, Prox_Move_Military_Vehicle_Patrol, 50, military)
		Register_Prox(marker_military_vehicle_patrol_19, Prox_Move_Military_Vehicle_Patrol, 50, military)

		-- Register_Prox(wall_notice_01, Prox_Wall_Notice, distance_notice_wall, aliens)
		-- Register_Prox(wall_notice_02, Prox_Wall_Notice, distance_notice_wall, aliens)
		-- Register_Prox(wall_notice_03, Prox_Wall_Notice, distance_notice_wall, aliens)
		-- Register_Prox(wall_notice_04, Prox_Wall_Notice, distance_notice_wall, aliens)

		Register_Prox(invading_prox, Prox_Invading, 500, aliens)

		-- Orlok
		if TestValid(hero) then
		
   		-- Orlok 1200 from 2000 = -.4
		   hero.Add_Attribute_Modifier("Universal_Damage_Modifier", -.4)

			hero.Register_Signal_Handler(Callback_Orlok_Killed, "OBJECT_HEALTH_AT_ZERO")
			if debug_orlok_invulnerable then
				hero.Make_Invulnerable(true)
			end

			-- Orlok's Starting Contingent
			-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
			alien_starting_forces = SpawnList(list_alien_starting_units, hero.Get_Position(), aliens, false, true, true)
			for i, unit in pairs(alien_starting_forces) do
				unit_type = unit.Get_Type()
				if unit_type == object_type_grunt or unit_type == object_type_lost_one then
					unit.Guard_Target(unit.Get_Position())
				elseif unit_type == object_type_glyph_carver then
				   unit.Highlight_Small(true)
				end
			end
			alien_starting_forces = SpawnList(list_alien_monoliths, marker_arrival_site.Get_Position(), aliens, false, true, true)
			for i, unit in pairs(alien_starting_forces) do
				unit.Guard_Target(unit.Get_Position())
			end
			
		end

		-- Enemy Marine Guards
		for i, marker in pairs(list_marine_guards) do
			Register_Prox(marker, Prox_Spawn_Guard_Marines, distance_marine_spawn, aliens)
		end
		
		-- Enemy Marine Rocketlaunchers
		for i, marker in pairs(list_rocket_guards) do
			-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
			marines = SpawnList(list_basic_rocketlaunchers, marker, military, false, true, false)
			for j, unit in pairs(marines) do
				unit.Guard_Target(unit.Get_Position())
			end
		end
		
		-- Enemy Construction Threads
		Create_Thread("Thread_Build_Infantry")
		Create_Thread("Thread_Build_Tanks")
		Create_Thread("Thread_Move_Military_Team")
		Create_Thread("Thread_Military_Sleep")
		Create_Thread("Thread_Construct_Novus_Robotic_Infantry")
		Create_Thread("Thread_Construct_Novus_Antimatter_Tanks")
		Create_Thread("Thread_Dervish_Strike_Team")
		
		-- Hummer and Infantry Patrols
		Create_Thread("Thread_Hummer_Patrols")
		Create_Thread("Thread_Infantry_Patrol",infantry_patrol_01)
		Create_Thread("Thread_Infantry_Patrol",infantry_patrol_02)
		Create_Thread("Thread_Infantry_Patrol",infantry_patrol_03)
		Create_Thread("Thread_Infantry_Patrol",infantry_patrol_04)
		Create_Thread("Thread_Infantry_Patrol",infantry_patrol_05)
		Create_Thread("Thread_Infantry_Patrol",infantry_patrol_06)
		Create_Thread("Thread_Infantry_Patrol",infantry_patrol_07)
		Create_Thread("Thread_Infantry_Patrol",infantry_patrol_08)
		Create_Thread("Thread_Infantry_Patrol",infantry_patrol_09)
		Create_Thread("Thread_Infantry_Patrol",infantry_patrol_10)
		
	end
end


--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script

function Thread_Dervish_Strike_Team()
   local strike_team, i, unit, distance
   strike_team = {}
   
	while not mission_success and not mission_failure do
	
      Sleep(time_delay_strike_team)
      -- Does the strike team have a valid target?
      if TestValid(dervish_strike_team_target) then
         -- There is a valid target. Is there a strike team?
         for i, unit in pairs(strike_team) do
            if not TestValid(unit) then
               table.remove(strike_team,i)
            end
         end
         if table.getn(strike_team) <= 0 then
         	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
         	strike_team = SpawnList(list_novus_dervish_jets, marker_military_infantry_patrol_18, novus, false, true, false)
         end
         for i, unit in pairs(strike_team) do
            if TestValid(unit) then
               unit.Attack_Move(dervish_strike_team_target)
            end
         end
      else
         -- There is no valid target. Time to remove the strike team.
         for i, unit in pairs (strike_team) do
            if TestValid(unit) then
               distance = unit.Get_Distance(marker_military_infantry_patrol_18)
               if distance > 200 then
                  unit.Move_To(marker_military_infantry_patrol_18.Get_Position())
               else
                  unit.Despawn()
               end
            end
         end
      end
   end
end

function Thread_Military_Sleep()
	Sleep(time_patrols_active_sleep)
	patrols_active = true
	time_build_aircraft = 60
end

function Thread_Move_Military_Team()
	while not mission_success and not mission_failure do
	
		Sleep (time_move_military_team)
		
		if table.getn(list_military_team) >= military_team_size then
			while military_team_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_military_team) then
				-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
				Hunt(list_military_team, "AntiDefault", true, false)
			end
			list_military_team = {}
		end
	end
end

function Thread_Build_Tanks()
	local i, structure
	
	while not mission_failure and not mission_success do
		if patrols_active then
			if total_military_tanks < maximum_military_tanks then
				for i, structure in pairs(list_structures_military_motor_pool) do
					if TestValid(structure) then
						if structure.Get_Hull() > 0 then
							Tactical_Enabler_Begin_Production(structure, object_type_military_tank, 1, military)
						end
					end
				end
			end
		end
		
		Sleep(time_build_tanks)
	end
end

function Thread_Build_Infantry()
	local i, structure
	
	while not mission_failure and not mission_success do
	
		Sleep(time_build_infantry)
		
		if total_military_infantry < maximum_military_infantry then
			for i, structure in pairs(list_structures_military_barracks) do
				if TestValid(structure) then
					if structure.Get_Hull() > 0 then
						Tactical_Enabler_Begin_Production(structure, object_type_military_infantry, 1, military)
					end
				end
			end
		end
	end
end

function Thread_Infantry_Patrol(obj)
	local patrol_point, patrollers
	
	if obj == infantry_patrol_01 then
		patrol_point = 1
	elseif obj == infantry_patrol_02 then
		patrol_point = 2
	elseif obj == infantry_patrol_03 then
		patrol_point = 4
	elseif obj == infantry_patrol_04 then
		patrol_point = 6
	elseif obj == infantry_patrol_05 then
		patrol_point = 8
	elseif obj == infantry_patrol_06 then
		patrol_point = 10
	elseif obj == infantry_patrol_07 then
		patrol_point = 12
	elseif obj == infantry_patrol_08 then
		patrol_point = 14
	elseif obj == infantry_patrol_09 then
		patrol_point = 16
	elseif obj == infantry_patrol_10 then
		patrol_point = 18
	end
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	patrollers = SpawnList(list_basic_marines, obj, military, false, true, false)
	while not mission_success and not mission_failure and patrol_point < 20 do
		if patrol_point == 1 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_01.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 2 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_02.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 3 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_03.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 4 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_04.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 5 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_05.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 6 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_06.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 7 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_07.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 8 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_08.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 9 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_09.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 10 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_10.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 11 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_11.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 12 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_12.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 13 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_13.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 14 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_14.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 15 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_15.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 16 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_16.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 17 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_17.Get_Position()))
			else
				patrol_point = 20
			end
		elseif patrol_point == 18 then
			if TestListValid(patrollers) then
				BlockOnCommand(Formation_Attack_Move(patrollers, marker_military_infantry_patrol_18.Get_Position()))
			else
				patrol_point = 20
			end
		end
		patrol_point = patrol_point + 1
		if patrol_point == 11 then
			patrol_point = 1
		elseif patrol_point == 19 then
			patrol_point = 11
		end
	end
end

function Thread_Hummer_Patrols()
   local spawn_list
   
	while not mission_success and not mission_failure do
	   if not rocket02_killed and not rocket03_killed then
			if not TestValid(hummer_patrol_01) then
   			-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
			   spawn_list = SpawnList(list_single_military_hummer, marker_military_vehicle_patrol_01, military, false, true, false)
				hummer_patrol_01 = spawn_list[1]
			end
			if not TestValid(hummer_patrol_02) then
			   spawn_list = SpawnList(list_single_military_hummer, marker_military_vehicle_patrol_11, military, false, true, false)
				hummer_patrol_02 = spawn_list[1]
			end
		end
	
		Sleep(time_spawn_hummer_patrols)
		
	end
end

function Thread_Mission_Introduction()
	local nearest_glyph_carver, nearest_monolith, arrival_site

   Point_Camera_At(hero)
   Lock_Controls(1)
   Fade_Screen_Out(0)
   Fade_Out_Music()
   Sleep(1)
   Start_Cinematic_Camera()
   Letter_Box_In(0.1)
   Transition_Cinematic_Target_Key(hero, 0, 0, 0, 0, 0, 0, 0, 0)
   Transition_Cinematic_Camera_Key(hero, 0, 200, 55, 65, 1, 0, 0, 0)
   Transition_To_Tactical_Camera(5)
   Fade_Screen_In(1) 
	Queue_Talking_Head(pip_orlok, "HIE02_SCENE02_01")
   Sleep(5)
   Letter_Box_Out(1)
   Sleep(1)
   Lock_Controls(0)
   End_Cinematic_Camera()

	while conversation_occuring do
		Sleep(1)
	end
	if TestValid(hero) then
   	conversation_occuring = true
   	Add_Radar_Blip(cows_highlight, "Default_Beacon_Placement", "blip_cows")
   	BlockOnCommand(Queue_Talking_Head(pip_science, "HIE02_SCENE03_01"))
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE03_02"))
		Sleep(time_radar_sleep)
		nearest_glyph_carver = Find_First_Object("Alien_Glyph_Carver")
		if TestValid(nearest_glyph_carver) then
			Add_Attached_Hint(nearest_glyph_carver, HINT_BUILT_ALIEN_GLYPH_CARVER)
		end
   	conversation_occuring = false
	end

	-- Objectives
	Create_Thread("Thread_Objective_Build_Reaper_Drone")

	Sleep(time_radar_sleep)
	while conversation_occuring do
		Sleep(1)
	end
	if not mission_success and not mission_failure then
		nearest_monolith = Find_First_Object("Alien_Cylinder")
		if TestValid(nearest_monolith) then
			Add_Attached_Hint(nearest_monolith, HINT_BUILT_ALIEN_CYLINDER)
		end
		conversation_occuring = true
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE03_08"))
		conversation_occuring = false
	end

	Sleep(time_radar_sleep)
	if not mission_failure then
		arrival_site = Find_First_Object("Alien_Arrival_Site")
		if TestValid(arrival_site) then
		   arrival_site.Register_Signal_Handler(Callback_Arrival_Site_Damaged, "OBJECT_DAMAGED")
		end
	end
end

function Thread_Objective_Build_Reaper_Drone()
   if not built_reaper_drone then 
      if not objective_reaper_drone then
	      objective_reaper_drone = true
	      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_04_ADD"} )
	      Sleep(time_objective_sleep)
         if not built_reaper_drone then 
	         zm02_objective04 = Add_Objective("TEXT_SP_MISSION_HIE02_OBJECTIVE_04")
	      else
      	   Create_Thread("Thread_Objective_Build_Detection_Drone")
	      end
	   end
	else
	   Create_Thread("Thread_Objective_Build_Detection_Drone")
	end
end

function Thread_Objective_Build_Detection_Drone()
   if objective_reaper_drone then
      if not mission_success and not mission_failure then
         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_04_COMPLETE"} )
         Objective_Complete(zm02_objective04)
         Sleep(time_objective_sleep)
      end
   end
   if not built_detection_drone then
      if not objective_detection_drone then
         objective_detection_drone = true
		   while conversation_occuring do
			   Sleep(1)
		   end
         if not built_detection_drone then
		      if not mission_success and not mission_failure then
			      conversation_occuring = true
			      BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE03_06"))
			      conversation_occuring = false
		         Sleep(time_radar_sleep)
               if not built_detection_drone then
	               Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_05_ADD"} )
		            Sleep(time_objective_sleep)
		         end
               if not built_detection_drone then
   	            zm02_objective05 = Add_Objective("TEXT_SP_MISSION_HIE02_OBJECTIVE_05")
	               Create_Thread("Thread_Detection_Drone_Reminder")
               else
	               Create_Thread("Thread_Objective_Build_Habitat_Walker")
	            end
	         end
         else
	         Create_Thread("Thread_Objective_Build_Habitat_Walker")	         
	      end
	   end
   else
	   Create_Thread("Thread_Objective_Build_Habitat_Walker")
   end
end

function Thread_Objective_Build_Spitter_Turret()
   if objective_habitat_walker then
      if not mission_success and not mission_failure then
         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_07_COMPLETE"} )
         Objective_Complete(zm02_objective07)
         Sleep(time_objective_sleep)
      end
   end
   if not built_spitter_turret then
      if not objective_spitter_turret then
         objective_spitter_turret = true
		   while conversation_occuring do
			   Sleep(1)
		   end
         if not built_spitter_turret then
		      if not mission_success and not mission_failure then
			      conversation_occuring = true
			      BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE03_09"))
			      conversation_occuring = false
		         Sleep(time_radar_sleep)
               if not built_spitter_turret then
	               Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_06_ADD"} )
   		         Sleep(time_objective_sleep)
	            end
               if not built_spitter_turret then
	               zm02_objective06 = Add_Objective("TEXT_SP_MISSION_HIE02_OBJECTIVE_06")
	            else
                  Create_Thread("Thread_Objective_Assault_First_Rocket")
	            end
	         end
	      else
            Create_Thread("Thread_Objective_Assault_First_Rocket")
	      end
	   end
	else
      Create_Thread("Thread_Objective_Assault_First_Rocket")
   end
end

function Thread_Objective_Build_Habitat_Walker()
   if objective_detection_drone then
      if not mission_success and not mission_failure then
         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_05_COMPLETE"} )
         Objective_Complete(zm02_objective05)
         Sleep(time_objective_sleep)
      end
   end
   if not built_habitat_walker then
      if not objective_habitat_walker then
         objective_habitat_walker = true
		   while conversation_occuring do
			   Sleep(1)
		   end
         if not built_habitat_walker then
		      if not mission_success and not mission_failure then
			      conversation_occuring = true
			      BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE03_12"))
			      conversation_occuring = false
		         Sleep(time_radar_sleep)
               if not built_habitat_walker then
	               Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_07_ADD"} )
		            Sleep(time_objective_sleep)
		         end
               if not built_habitat_walker then
   	            zm02_objective07 = Add_Objective("TEXT_SP_MISSION_HIE02_OBJECTIVE_07")
               else
                  Create_Thread("Thread_Objective_Build_Spitter_Turret")
   	         end
	         end
         else
            Create_Thread("Thread_Objective_Build_Spitter_Turret")
	      end
		end
   else
      Create_Thread("Thread_Objective_Build_Spitter_Turret")
   end
end

function Thread_Objective_Assault_First_Rocket()
   if objective_spitter_turret then
      if not mission_success and not mission_failure then
         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_06_COMPLETE"} )
         Objective_Complete(zm02_objective06)
         Sleep(time_objective_sleep)
      end
   end
   if not first_objective_active then
  	   first_objective_active = true
      if not mission_success and not mission_failure then
	      while conversation_occuring do
		      Sleep(1)
	      end
	      if not mission_success and not mission_failure then
		      conversation_occuring = true
		      BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE03_11"))
		      conversation_occuring = false
		      Sleep(time_radar_sleep)
	      end
	   	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_01_ADD"} )
		   Sleep(time_objective_sleep)
   		zm02_objective01 = Add_Objective("TEXT_SP_MISSION_HIE02_OBJECTIVE_01")
   	   Sleep(time_radar_sleep)
   		Add_Radar_Blip(rocket01, "DEFAULT", "blip_objective01")
   	end
   end
end

function Thread_Detection_Drone_Reminder()
   Sleep(60)
	while conversation_occuring do
		Sleep(1)
	end
	if not built_detection_drone then	
		if not mission_success and not mission_failure then
			conversation_occuring = true
			BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE03_07"))
			conversation_occuring = false
		end
   end
end

function Thread_Fire_First_Rocket()
	local list_rocket_military_defenders
	
	if not mission_failure then

      if not first_objective_active then
      	first_objective_active = true
      	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_01_ADD"} )
	      Sleep(time_objective_sleep)
         zm02_objective01 = Add_Objective("TEXT_SP_MISSION_HIE02_OBJECTIVE_01")
      	
      	Sleep(time_radar_sleep)
   		Add_Radar_Blip(rocket01, "DEFAULT", "blip_objective01")
      end
      Remove_Radar_Blip("blip_objective01")
   	Add_Radar_Blip(rocket01, "Default_Beacon_Placement", "blip_rocket")

		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
		list_rocket_military_defenders = SpawnList(list_rocket_defenders, marker_rocket_01_guards, military, false, true, false)
		Hunt(list_rocket_military_defenders, "AntiDefault", true, false, rocket01.Get_Position(), distance_first_rocket_guards)
				
		-- Display rocket being fired here.
   	animrocket01.Play_Animation("Anim_Cinematic", false, 0)
   	Create_Thread("Thread_Despawn_First_Rocket",animrocket01)
		-- Conversation
		while conversation_occuring do
			Sleep(1)
		end
		fow_rocket01 = FogOfWar.Reveal(aliens, radar01, 400, 400)
		conversation_occuring = true
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_science, "HIE02_SCENE04_01"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE02_SCENE04_02"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE04_03"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE02_SCENE04_04"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE04_05"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE02_SCENE04_06"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE04_07"))
		end
		conversation_occuring = false
		
		Sleep(time_radar_sleep)
		
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_02_ADD"} )
	   Sleep(time_objective_sleep)
		zm02_objective02 = Add_Objective("TEXT_SP_MISSION_HIE02_OBJECTIVE_03")
		Set_Objective_Text(zm02_objective01, "TEXT_SP_MISSION_HIE02_OBJECTIVE_02")

		Sleep(time_radar_sleep)

		Add_Radar_Blip(rocket02, "DEFAULT", "blip_objective02")
		Add_Radar_Blip(rocket03, "DEFAULT", "blip_objective03")
		
		first_rocket_complete = true
		fow_rocket01.Undo_Reveal()
		if TestValid(animrocket01) then
			animrocket01.Despawn()
		end
		realrocket02.Make_Invulnerable(false)
		realrocket03.Make_Invulnerable(false)
		
		if TestValid(realrocket01) then
			Register_Prox(realrocket01, Prox_Crush_Rocket_Gantry, distance_crush_gantry, aliens)
		end
		if TestValid(realrocket02) then
			Register_Prox(realrocket02, Prox_Crush_Rocket_Gantry, distance_crush_gantry, aliens)
		end
		if TestValid(realrocket03) then
			Register_Prox(realrocket03, Prox_Crush_Rocket_Gantry, distance_crush_gantry, aliens)
		end
		
		Sleep(time_objective_sleep)
	   while conversation_occuring do
		   Sleep(1)
	   end
	   conversation_occuring = true
	   if not mission_success and not mission_failure then
		   BlockOnCommand(Queue_Talking_Head(pip_science, "HIE02_SCENE02_02"))
	   end
	   if not mission_success and not mission_failure then
		   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE02_03"))
	   end
	   if not mission_success and not mission_failure then
		   BlockOnCommand(Queue_Talking_Head(pip_science, "HIE02_SCENE02_04"))
	   end
	   if not mission_success and not mission_failure then
		   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE02_05"))
	   end
	   if not mission_success and not mission_failure then
		   BlockOnCommand(Queue_Talking_Head(pip_science, "HIE02_SCENE02_06"))
	   end
	   conversation_occuring = false
	end
end

function Prox_Crush_Rocket_Gantry(prox_obj, trigger_obj)
   local nearest, distance, type
   
   if TestValid(prox_obj) and TestValid(trigger_obj) then
	   if prox_obj.Get_Hull() > 0.25 then
	      nearest = Find_Nearest(prox_obj, "Alien_Walker_Habitat")
	      if TestValid(nearest) then
	         distance = prox_obj.Get_Distance(nearest)
	         if distance <= distance_crush_gantry then
               prox_obj.Take_Damage(2800, "Damage_Default")
	            if prox_obj == realrocket02 then
                  Callback_Rocket02_Damaged()
               elseif prox_obj == realrocket03 then
                  Callback_Rocket03_Damaged()
               end
	         end
	      end
	   else
 			prox_obj.Cancel_Event_Object_In_Range(Prox_Crush_Rocket_Gantry)
	   end
   end
end

function Thread_Despawn_First_Rocket(obj)
   Sleep(time_despawn_first_rocket)
   obj.Despawn()
end

function Thread_Rocket_02_Events()
	local list_rocket_military_defenders
	
	-- Activate any rocket 02 area events here.
	novus_active = true
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	list_rocket_military_defenders = SpawnList(list_rocket_defenders, marker_rocket_02_guards, military, false, true, false)
	Hunt(list_rocket_military_defenders, "AntiDefault", true, false, rocket02.Get_Position(), distance_approach_rocket)
	list_rocket_military_defenders = SpawnList(list_novus_amplifiers, marker_rocket_02_guards, novus, false, true, false)
	Hunt(list_rocket_military_defenders, "AntiDefault", true, false, rocket02.Get_Position(), distance_approach_rocket)

	while not first_rocket_complete do
		Sleep(1)
	end
	Sleep(time_objective_sleep)
	
	-- Announce any rocket 02 area events here, after waiting for first rocket events to complete.

	fow_rocket02.Undo_Reveal()
	
end

function Thread_Rocket_03_Events()

	-- Activate any rocket 03 area events here.
	novus_active = true
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	list_rocket_military_defenders = SpawnList(list_rocket_defenders, marker_rocket_03_guards, military, false, true, false)
	Hunt(list_rocket_military_defenders, "AntiDefault", true, false, rocket03.Get_Position(), distance_approach_rocket)
	list_rocket_military_defenders = SpawnList(list_novus_amplifiers, marker_rocket_03_guards, novus, false, true, false)
	Hunt(list_rocket_military_defenders, "AntiDefault", true, false, rocket03.Get_Position(), distance_approach_rocket)
	
	while not first_rocket_complete do
		Sleep(1)
	end
	Sleep(time_objective_sleep)
	
	-- Announce any rocket 03 area events here, after waiting for first rocket events to complete.

	fow_rocket03.Undo_Reveal()
	
end

function Thread_Move_Staging_Units(obj)
	if TestValid(obj) then
		military_team_list_in_use = true
		table.insert(list_military_team, obj)
		military_team_list_in_use = false
		BlockOnCommand(obj.Attack_Move(marker_rally_point.Get_Position()))
	end
end

function Thread_Move_Guard_Marines(unit)
	local nearest_rocket, distance, nearest_turret
	
	Sleep(GameRandom(time_delay_guard_marine_move, (time_delay_guard_marine_move * 2)))
	
	nearest_rocket = Find_Nearest(unit, "Military_Team_Rocketlauncher")
	if TestValid(nearest_rocket) and TestValid(unit) then
		distance = unit.Get_Distance(nearest_rocket)
		if distance > infantry_proximity_to_protector then
			unit.Move_To(nearest_rocket.Get_Position())
			nearest_rocket.Attack_Move(unit.Get_Position())
		else
			nearest_turret = Find_Nearest(unit, "Military_Turret_Ground")
			if TestValid(nearest_turret) then
				distance = unit.Get_Distance(nearest_turret)
				if distance > infantry_proximity_to_protector then
					unit.Move_To(nearest_turret.Get_Position())
				end
			end
		end
	else
		nearest_turret = Find_Nearest(unit, "Military_Turret_Ground")
		if TestValid(nearest_turret) and TestValid(unit) then
			distance = unit.Get_Distance(nearest_turret)
			if distance > infantry_proximity_to_protector then
				unit.Move_To(nearest_turret.Get_Position())
			end
		end
	end
end

function Thread_Construct_Novus_Robotic_Infantry()
	local i, structure
	
	while not mission_success and not mission_failure do
		if novus_active then
			if total_novus_robots < maximum_novus_robots then
				for i,structure in pairs(list_structures_novus_robotic_assembly) do
					if TestValid(structure) then
						if structure.Get_Hull() > 0 then
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
		if novus_active then
			if total_novus_tanks < maximum_novus_tanks then
				for i,structure in pairs(list_structures_novus_vehicle_assembly) do
					if TestValid(structure) then
						if structure.Get_Hull() > 0 then
							Tactical_Enabler_Begin_Production(structure, object_type_antimatter_tank, 1, novus)
						end
					end
				end
			end
		end

		Sleep(time_spawn_novus_tanks)
	
	end
end

function Thread_Approaching_Cows()
	while conversation_occuring do
		Sleep(1)
	end
	if not mission_success and not mission_failure then
		conversation_occuring = true
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE03_05"))
		conversation_occuring = false
	end
end

function Thread_Callback_Reaper_Drone_Killed()
	while conversation_occuring do
		Sleep(1)
	end
	if not mission_success and not mission_failure then
		conversation_occuring = true
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE03_04"))
		conversation_occuring = false
	end
end

function Thread_Prox_Wall_Notice()
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE06_02"))
	end
	conversation_occuring = false
end

function Thread_Launch_Rocket_03()
   local rocket_03, spawn_list

   patrols_active = false
   if fow_rocket03 ~= nil then
	   fow_rocket03.Undo_Reveal()
   end
   
	animrocket03.Play_Animation("Anim_Cinematic", false, 2)
   Sleep(time_rocket_03_explosion)
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	spawn_list = SpawnList(list_single_military_missile_destroyed, rocket03_explode, civilian, false, true, false)
	rocket_03 = spawn_list[1]
	Sleep(0.1)
	if TestValid(animrocket03) then
		animrocket03.Despawn()
	end
	if TestValid(rocket_03) then
	   rocket_03.Despawn()
	end
   Remove_Radar_Blip("blip_objective03")
   Objective_Complete(zm02_objective02)
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_03_COMPLETE"} )
   if rocket02_killed then
	   Create_Thread("Thread_Mission_Success")
   else
	   Create_Thread("Thread_Announce_Rocket_Destruction")
   end
end

function Thread_Launch_Rocket_02()
   local rocket_02, spawn_list

   patrols_active = false
   if fow_rocket02 ~= nil then
	   fow_rocket02.Undo_Reveal()
   end
   
	animrocket02.Play_Animation("Anim_Cinematic", false, 1)
   Sleep(time_rocket_02_explosion)
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	spawn_list = SpawnList(list_single_military_missile_destroyed, rocket02_explode, civilian, false, true, false)
	rocket_02 = spawn_list[1]
	Sleep(0.1)
	if TestValid(animrocket02) then
		animrocket02.Despawn()
	end
	if TestValid(rocket_02) then
	   rocket_02.Despawn()
	end

   Remove_Radar_Blip("blip_objective02")
   Objective_Complete(zm02_objective01)
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE02_OBJECTIVE_02_COMPLETE"} )
   if rocket03_killed then
	   Create_Thread("Thread_Mission_Success")
   else
	   Create_Thread("Thread_Announce_Rocket_Destruction")
   end
end

function Thread_Announce_Rocket_Destruction()
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE05_01"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_nufai, "HIE02_SCENE05_02"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE05_03"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE05_04"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_nufai, "HIE02_SCENE05_05"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE05_06"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE05_07"))
	end
	conversation_occuring = false
end

function Thread_Callback_Arrival_Site_Damaged()
	while conversation_occuring do
		Sleep(1)
	end
	if not mission_success and not mission_failure then		
		conversation_occuring = true
		BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE02_SCENE03_10"))
		conversation_occuring = false
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

function Prox_Approaching_Cows(prox_obj, trigger_obj)
	local obj_type
	
	if TestValid(trigger_obj) then
		obj_type = trigger_obj.Get_Type()
		if obj_type == object_type_reaper then
			prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Cows)
			Create_Thread("Thread_Approaching_Cows")
		end
	end
end

function Prox_Move_Military_Vehicle_Patrol(prox_obj, trigger_obj)
	if TestValid(trigger_obj) then
		local obj_type = trigger_obj.Get_Type()
		if obj_type == object_type_military_hummer then
			if prox_obj == marker_military_vehicle_patrol_01 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_02.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_02 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_03.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_03 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_04.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_04 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_05.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_05 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_06.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_06 then
				trigger_obj.Teleport_And_Face(marker_military_vehicle_patrol_01)

			elseif prox_obj == marker_military_vehicle_patrol_11 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_12.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_12 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_13.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_13 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_14.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_14 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_15.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_15 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_16.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_16 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_17.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_17 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_18.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_18 then
				trigger_obj.Attack_Move(marker_military_vehicle_patrol_19.Get_Position())
			elseif prox_obj == marker_military_vehicle_patrol_19 then
				trigger_obj.Teleport_And_Face(marker_military_vehicle_patrol_11)
			end
		end
	end	
end

function Cache_Models()
	Find_Object_Type("Military_Team_Marines").Load_Assets()
	Find_Object_Type("Military_Team_Rocketlauncher").Load_Assets()
	Find_Object_Type("Military_AbramsM2_Tank").Load_Assets()
	Find_Object_Type("Military_Dragonfly_UAV").Load_Assets()
	Find_Object_Type("Novus_Corruptor").Load_Assets()
	Find_Object_Type("Novus_Robotic_Infantry").Load_Assets()
	Find_Object_Type("NOVUS_ANTIMATTER_TANK").Load_Assets()
	Find_Object_Type("Alien_Mutant_Slave").Load_Assets()
end

function Story_On_Construction_Complete(obj)
	local nearest, obj_type, glyph_carvers, i, unit
	
	if TestValid(obj) then
	   if obj.Get_Owner().Get_Faction_Name() == "ALIEN" then
	      glyph_carvers = Find_All_Objects_Of_Type("Alien_Glyph_Carver")
	      if table.getn(glyph_carvers) > 0 then
	         for i, unit in pairs (glyph_carvers) do
	            if TestValid(unit) then
	               unit.Highlight_Small(false)
	            end
	         end
	      end
	   end
	   
		obj_type = obj.Get_Type()
		if obj_type == object_type_military_infantry then
			Create_Thread("Thread_Move_Staging_Units", obj)
			total_military_infantry = total_military_infantry + 1
			obj.Register_Signal_Handler(Callback_Military_Infantry_Killed, "OBJECT_HEALTH_AT_ZERO")
		elseif obj_type == object_type_military_tank then
			Create_Thread("Thread_Move_Staging_Units", obj)
			total_military_tanks = total_military_tanks + 1
			obj.Register_Signal_Handler(Callback_Military_Tank_Killed, "OBJECT_HEALTH_AT_ZERO")
		 elseif obj_type == object_type_robot then
			if TestValid(realrocket03) then
				Hunt(obj, "AntiDefault", true, false, rocket03.Get_Position(), distance_approach_rocket)
			elseif TestValid(realrocket02) then
				Hunt(obj, "AntiDefault", true, false, rocket02.Get_Position(), distance_approach_rocket)
			end
			total_novus_robots = total_novus_robots + 1
			obj.Register_Signal_Handler(Callback_Novus_Robot_Killed, "OBJECT_HEALTH_AT_ZERO")
		 elseif obj_type == object_type_antimatter_tank then
			if TestValid(realrocket03) then
				Hunt(obj, "AntiDefault", true, false, rocket03.Get_Position(), distance_approach_rocket)
			elseif TestValid(realrocket02) then
				Hunt(obj, "AntiDefault", true, false, rocket02.Get_Position(), distance_approach_rocket)
			end
			total_novus_tanks = total_novus_tanks + 1
			obj.Register_Signal_Handler(Callback_Novus_Tank_Killed, "OBJECT_HEALTH_AT_ZERO")
			
		elseif obj_type == object_type_reaper then
		   if not built_reaper_drone then
	         built_reaper_drone = true
      	   Create_Thread("Thread_Objective_Build_Detection_Drone")
	      end
			obj.Register_Signal_Handler(Callback_Reaper_Drone_Killed, "OBJECT_HEALTH_AT_ZERO")
		elseif obj_type == object_type_scan_drone then
		   if not built_detection_drone then
			   built_detection_drone = true
		      Create_Thread("Thread_Objective_Build_Habitat_Walker")
			end
		elseif obj_type == object_type_spitter_turret then
		   if not built_spitter_turret then
		      built_spitter_turret = true
			   Create_Thread("Thread_Objective_Assault_First_Rocket")
		   end
		elseif obj_type == object_type_habitat_walker then
         obj.Override_Max_Speed(.6)
		   if not built_habitat_walker then
			   built_habitat_walker = true
			   Create_Thread("Thread_Objective_Build_Spitter_Turret")
			end
		end
	end
end

function Callback_Reaper_Drone_Killed()
	if not first_reaper_warning_given then
		first_reaper_warning_given = true
		Create_Thread("Thread_Callback_Reaper_Drone_Killed")
	end
end

function Callback_Military_Infantry_Killed()
	total_military_infantry = total_military_infantry - 1
end

function Callback_Military_Tank_Killed()
	total_military_tanks = total_military_tanks - 1
end

function Callback_Military_Aircraft_Killed()
	total_military_aircraft = total_military_aircraft - 1
end

function Callback_Novus_Corruptor_Killed()
	total_novus_corruptors = total_novus_corruptors - 1
end

function Callback_Novus_Robot_Killed()
	total_novus_robots = total_novus_robots - 1
end

function Callback_Novus_Tank_Killed()
	total_novus_tanks = total_novus_tanks - 1
end

function Prox_Spawn_Guard_Marines(prox_obj, trigger_obj)
	local obj_type, marines, j, unit
	
	prox_obj.Cancel_Event_Object_In_Range(Prox_Spawn_Guard_Marines)
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	marines = SpawnList(list_basic_marines, prox_obj, military, false, true, false)
	obj_type = trigger_obj.Get_Type()
	if obj_type == object_type_cylinder then
		for j, unit in pairs(marines) do
			Create_Thread("Thread_Move_Guard_Marines", unit)
		end
	else
		for j, unit in pairs(marines) do
			unit.Attack_Move(trigger_obj)
		end
	end
end

function Prox_Approaching_Rocket_01(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Rocket_01)
	if not first_rocket_fired then
		first_rocket_fired = true
		Create_Thread("Thread_Fire_First_Rocket")
	end
end

function Prox_Approaching_Rocket_02(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type ~= object_type_cylinder then
		prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Rocket_02)
		if not first_rocket_fired then
			first_rocket_fired = true
			Create_Thread("Thread_Fire_First_Rocket")
		else
			if fow_rocket01 ~= nil then
				fow_rocket01.Undo_Reveal()
			end
		end
		if not mission_failure then
			fow_rocket02 = FogOfWar.Reveal(aliens, prox_obj, 400, 400)
			Create_Thread("Thread_Rocket_02_Events")
		end
   else
      Create_Thread("Thread_Dervish_Strike_Monolith", trigger_obj)
	end
end

function Thread_Dervish_Strike_Monolith(obj)
   if not TestValid(dervish_strike_team_target) then
      dervish_strike_team_target = obj
   end
end

function Prox_Approaching_Rocket_03(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type ~= object_type_cylinder then
		prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Rocket_03)
		if not first_rocket_fired then
			first_rocket_fired = true
			Create_Thread("Thread_Fire_First_Rocket")
		else
			if fow_rocket01 ~= nil then
				fow_rocket01.Undo_Reveal()
			end
		end
		if not mission_failure then
			fow_rocket03 = FogOfWar.Reveal(aliens, prox_obj, 400, 400)
			Create_Thread("Thread_Rocket_03_Events")
   	end
   else
      Create_Thread("Thread_Dervish_Strike_Monolith", trigger_obj)
   end
end

function Prox_Invading(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type ~= object_type_cylinder then
		prox_obj.Cancel_Event_Object_In_Range(Prox_Invading)
		patrols_active = true
	end
end

function Prox_Wall_Notice(prox_obj, trigger_obj)
	local obj_type = trigger_obj.Get_Type()
	if obj_type ~= object_type_cylinder then
	   if first_rocket_complete then
		   patrols_active = true
		   wall_notice_01.Cancel_Event_Object_In_Range(Prox_Wall_Notice)
		   wall_notice_02.Cancel_Event_Object_In_Range(Prox_Wall_Notice)
		   wall_notice_03.Cancel_Event_Object_In_Range(Prox_Wall_Notice)
		   wall_notice_04.Cancel_Event_Object_In_Range(Prox_Wall_Notice)
   		Create_Thread("Thread_Prox_Wall_Notice")
      end
	end
end

function Callback_Rocket03_Damaged()
   local hull = 0
   
   if TestValid(realrocket03) then
      hull = realrocket03.Get_Hull()
   end
   
   if hull < 0.25 then
      if not mission_failure and not rocket03_killed then
         rocket03_killed = true
         Create_Thread("Thread_Launch_Rocket_03")
      end
   end
end

function Callback_Rocket01_Damaged()
   local hull = 0

   if TestValid(realrocket01) then
      hull = realrocket01.Get_Hull()
   end
   
   if hull < 1.0 then
		if not first_rocket_fired then
			first_rocket_fired = true
			Create_Thread("Thread_Fire_First_Rocket")
		end
	end
end


function Callback_Rocket02_Damaged()
   local hull = 0

   if TestValid(realrocket02) then
      hull = realrocket02.Get_Hull()
   end
   
   if hull < 0.25 then
	   if not mission_failure and not rocket02_killed then
         rocket02_killed = true
         Create_Thread("Thread_Launch_Rocket_02")
	   end
	end
end

function Callback_Orlok_Killed()
	if not mission_success then
		Create_Thread("Thread_Mission_Failed")
	end
end

function Callback_Arrival_Site_Damaged()
	if not arrival_site_damage_notice then
		arrival_site_damage_notice = true
		Create_Thread("Thread_Callback_Arrival_Site_Damaged")
	end
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
	Play_Music("Lose_To_Military_Event")
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,30)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ORLOK"} )
	Sleep(time_objective_sleep)
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
   Fade_Screen_Out(2)
   Sleep(2)
   Lock_Controls(0)
	Force_Victory(military)
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
	
	Fade_Out_Music()
	BlockOnCommand(Play_Bink_Movie("Hierarchy_M2_S4", true)) -- pulled from demo
	
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
	Movie_Commands_Post_Load_Callback()
end

