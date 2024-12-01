-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM06.lua#60 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM06.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Rich_Donnelly $
--
--            $Change: 84816 $
--
--          $DateTime: 2007/09/25 17:02:25 $
--
--          $Revision: #60 $
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
require("PGStoryMode")
require("RetryMission")
require("PGColors")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_ZM06_Act01", State_ZM06_Act01)
   Define_State("State_ZM06_Act02", State_ZM06_Act02)
   Define_State("State_ZM06_Act03", State_ZM06_Act03)
	
	-- Debug Bools
	debug_orlok_invulnerable = false

   -- Object Types
	object_type_glyph_carver = Find_Object_Type("Alien_Glyph_Carver")
	object_type_lost_one = Find_Object_Type("Alien_Lost_One")
	object_type_grunt = Find_Object_Type("Alien_Grunt")
   object_type_brute = Find_Object_Type("Alien_Brute")
	object_type_arrival_site = Find_Object_Type("Alien_Arrival_Site")
   object_type_science_walker = Find_Object_Type("Alien_Walker_Science")
   object_type_assembly_walker = Find_Object_Type("Alien_Walker_Assembly")
   object_type_troop_walker = Find_Object_Type("Alien_Walker_Habitat")
	object_type_transport = Find_Object_Type("ALIEN_AIR_RETREAT_TRANSPORT")
   object_type_spitter_turret = Find_Object_Type("Alien_Radiation_Spitter")
   object_type_monolith = Find_Object_Type("Alien_Cylinder")
   object_type_mutant_slave = Find_Object_Type("Alien_Mutant_Slave")
   object_type_defiler = Find_Object_Type("Alien_Defiler")
   object_type_saucer = Find_Object_Type("Alien_Foo_Core")
   object_type_scan_drone = Find_Object_Type("Alien_Scan_Drone")
   object_type_phase_tank = Find_Object_Type("Alien_Recon_Tank")
   object_type_kamal_troop_walker = Find_Object_Type("HM06_Kamal_Habitat_Walker")
   object_type_kamal_assembly_walker = Find_Object_Type("HM06_Kamal_Assembly_Walker")
   object_type_kamal_science_walker = Find_Object_Type("HM06_Kamal_Science_Walker")
   object_type_zessus = Find_Object_Type("Masari_Hero_Zessus")
   object_type_orlok = Find_Object_Type("Alien_Hero_Orlok")
   object_type_orlok_base = Find_Object_Type("Alien_Hero_Orlok_Base")
   object_type_orlok_siege = Find_Object_Type("Alien_Hero_Orlok_Siege_Mode")
   object_type_orlok_endure = Find_Object_Type("Alien_Hero_Orlok_Endure_Mode")
   
	list_kamal_starting_units = {
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Recon_Tank",
      "Alien_Recon_Tank"
	}

   list_kamal_initial_engagement_units = {
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
      "Alien_Brute",
      "Alien_Brute",
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
		"Alien_Grunt",
      "Alien_Brute",
      "Alien_Brute",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Lost_One"
   }

   list_kamal_dish_assault_units = {
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Brute",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Recon_Tank",
      "Alien_Recon_Tank"
   }
   
   list_kamal_base_assault_units_01 = {
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Lost_One"
   }
   
   list_kamal_base_assault_units_02 = {
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Recon_Tank",
      "Alien_Recon_Tank"
   }

   list_kamal_base_assault_units_03 = {
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Defiler",
      "Alien_Defiler"
   }

   list_kamal_final_units_05 = {
      "Alien_Grunt",
      "Alien_Lost_One",
      "Alien_Foo_Core",
      "Alien_Recon_Tank",
      "Alien_Brute"
   }
   
   list_kamal_final_units_10 = {
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Foo_Core",
      "Alien_Recon_Tank",
      "Alien_Recon_Tank",
      "Alien_Brute",
      "Alien_Brute"
   }

   list_kamal_final_units_15 = {
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Foo_Core",
      "Alien_Foo_Core",
      "Alien_Recon_Tank",
      "Alien_Recon_Tank",
      "Alien_Recon_Tank",
      "Alien_Brute",
      "Alien_Brute"
   }

   list_kamal_final_units_20 = {
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Grunt",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Lost_One",
      "Alien_Foo_Core",
      "Alien_Foo_Core",
      "Alien_Foo_Core",
      "Alien_Recon_Tank",
      "Alien_Recon_Tank",
      "Alien_Recon_Tank",
      "Alien_Brute",
      "Alien_Brute",
      "Alien_Brute",
      "Alien_Brute"
   }
   
   list_kamal_saucer_squadron = {
      "Alien_Foo_Core",
      "Alien_Foo_Core",
      "Alien_Foo_Core",
      "Alien_Foo_Core"
   }
   
   list_kamal_reapers = {
      "Alien_Superweapon_Reaper_Turret",
      "Alien_Superweapon_Reaper_Turret"
   }
   
   list_single_alien_grunt = {
      "Alien_Grunt"
   }
   
   list_single_alien_lost_one = {
      "Alien_Lost_One"
   }
   
   list_single_alien_brute = {
      "Alien_Brute"
   }
   
   list_single_zessus = {
      "Masari_Hero_Zessus"
   }
   
   list_single_alien_saucer = {
      "Alien_Air_Retreat_Transport"
   }
   
   list_single_masari_transport = {
      "Masari_Air_Retreat_Transport"
   }
   
   list_single_kamal_rex = {
      "Alien_Hero_Kamal_Rex"
   }
   
   list_masari_disciples = {
      "Masari_Disciple",
      "Masari_Disciple",
      "Masari_Disciple",
      "Masari_Disciple",
      "Masari_Disciple"
   }
   
   list_single_habitat_walker = {
      "HM06_Kamal_Habitat_Walker"
   }
   
   list_single_assembly_walker = {
      "HM06_Kamal_Assembly_Walker"
   }
   
   list_single_science_walker = {
      "HM06_Kamal_Science_Walker"
   }
   
   list_single_glyph_carver = {
      "Alien_Glyph_Carver"
   }

	-- Factions
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	military = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")
	kamals_aliens = Find_Player("Alien_ZM06_KamalRex")
	
	-- Variables
	mission_success = false
	mission_failure = false
	
	time_objective_sleep = 5
	time_radar_sleep = 2
   conversation_active = false

   time_clear_orlok_base = 60
   time_spawn_base_defenders = 10
   time_spawn_attackers = 30
   time_zessus_ai_cycle = 5
   time_zessus_arrival = 180
   
   time_delay_kamal_base_attack_01 = 120
   time_delay_kamal_base_attack_02 = 180
   time_delay_kamal_base_attack_03 = 240
   
   time_saucer_attack = 60

   distance_approach_kamals_base = 1200
   distance_inside_kamals_base = 400
   distance_base_patrol = 800
   distance_zessus_safety = 100
   distance_approach_zessus = 50
   distance_orlok_to_enemy_base = 2000
   distance_teleport_trap = 250
   distance_approach_zessus_reinforcement = 75
   distance_zessus_arrive_at_reinforcement = 100
   distance_zessus_teleport_maximum = 2000
   distance_orlok_to_arrival_site = 900
   distance_orlok_approach_transmitter = 50
   distance_orlok_approach_transmitter_far = 800
   distance_orlok_to_transmitter = 200
   distance_zessus_approach_reinforcement_point = 200
   
   minimum_attackers = 15
   minimum_kamal_base_guards = 11

   orlok_habitat_walker = nil
   kamal_habitat_walker = nil
   kamal_assembly_walker = nil
   marker_arrival_site = nil
   orlok_arrival_site = nil

   zessus = nil
   zessus_ai_spotted_infantry = false
   zessus_ai_spotted_enemy = false
   zessus_ai_informed_player = false
   zessus_ai_spitter_01 = nil
   zessus_ai_spitter_02 = nil
   zessus_ai_spitter_03 = nil
   zessus_ai_reinforcements_active = false
   masari_transport = nil

   list_kamal_guards = {}
   list_kamal_attackers = {}
   list_kamal_initial_units = {}
   list_current_disciples = {}

   arrival_site_built = false
   switched_to_act_02 = false
   orlok_left_transmitter = false
   kamal_has_arrived = false
   moved_final_orlok_troop_walker = false
   moved_final_orlok_assembly_walker = false
   moved_final_orlok_science_walker = false
   moved_final_kamal_troop_walker = false
   moved_final_kamal_assembly_walker = false
   moved_final_kamal_science_walker = false
   misson_complete_called = false
   transmitter_objective_issued = false
   
   kamal_rex = nil
   transmitter_effect_obj = nil
   
	-- Pip Heads
	pip_orlok = "AH_Orlok_Pip_Head.alo"
	pip_kamal = "AH_Kamal_Rex_Pip_head.alo"
	pip_science = "AI_Science_officer_Pip_Head.alo"
	pip_comm = "AI_Comm_officer_Pip_head.alo"
	pip_nufai = "AH_Nufai_Pip_Head.alo"
	pip_zessus = "ZH_Zessus_pip_head.alo"
	
	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
end


--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	local i, structure, credits, credit_total, list_comm_terminals, terminal
	
	if message == OnEnter then
		novus.Allow_Autonomous_AI_Goal_Activation(false)
		masari.Allow_Autonomous_AI_Goal_Activation(false)		
		kamals_aliens.Allow_Autonomous_AI_Goal_Activation(false)		

	military.Allow_AI_Unit_Behavior(false)
	novus.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	kamals_aliens.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
		
		_CustomScriptMessage("RickLog.txt", string.format("*********************************************Story_Campaign_Hierarchy_ZM06 START!"))

		Cache_Models()

		UI_Hide_Research_Button()
		--UI_Hide_Sell_Button()

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
		
		-- Comm Terminal Invunerability
		list_comm_terminals = Find_All_Objects_Of_Type("NM06_COMM_TERMINAL")
		if table.getn(list_comm_terminals) > 0 then
		   terminal = list_comm_terminals[1]
		   if TestValid(terminal) then
		      terminal.Make_Invulnerable(true)
		   end
		end
		
		-- House Colors
		PGColors_Init_Constants()
--		aliens.Enable_Colorization(true, COLOR_RED)
	   kamals_aliens.Enable_Colorization(true, COLOR_DARK_BLUE)
--	   masari.Enable_Colorization(true, COLOR_DARK_GREEN)

      -- Alliegiances
		aliens.Make_Ally(masari)
		masari.Make_Ally(aliens)
		aliens.Make_Enemy(kamals_aliens)
		kamals_aliens.Make_Enemy(aliens)
		masari.Make_Enemy(kamals_aliens)
		kamals_aliens.Make_Enemy(masari)

		-- Construction Locks/Unlocks
		aliens.Reset_Story_Locks()
		aliens.Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Retreat_From_Tactical_Ability",true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Superweapon_Mass_Drop"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Radiation_Wake"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Range_Enhancer"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_AI_Magnet"),false,STORY)
		
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Kamal_Rex"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Nufai"),true,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Orlok"),true,STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Lost_One_Plasma_Bomb_Unit_Ability", false,STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Grey_Phase_Unit_Ability", false,STORY)
		aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("Alien_Grunt"), "Grunt_Grenade_Attack", false, STORY)

		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly_HP_Defiler_Assembly_Pod"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly_HP_Phase_Tank_Assembly_Pod"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly_HP_Foo_Chamber"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Lost_One_Mutator"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Brute_Mutator"),false,STORY)

		-- Hint System Initialization
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		Register_Hint_Context_Scene(Get_Game_Mode_GUI_Scene())

		-- Markers
		marker_transmitter_effect = Find_Hint("MARKER_GENERIC_BLUE","transmitter-effect")
		if not TestValid(marker_transmitter_effect) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_transmitter_effect!"))
		end
		
		marker_kamal_reapers = Find_Hint("MARKER_GENERIC_RED","kamal-reapers")
		if not TestValid(marker_kamal_reapers) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_reapers!"))
		end
		marker_kamal_base_attacker_drop = Find_Hint("MARKER_GENERIC_RED","kamal-base-attacker-drop")
		if not TestValid(marker_kamal_base_attacker_drop) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_base_attacker_drop!"))
		end
		marker_kamal_base_attacker_saucer = Find_Hint("MARKER_GENERIC_RED","kamal-base-attacker-saucer")
		if not TestValid(marker_kamal_base_attacker_saucer) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_base_attacker_saucer!"))
		end
		marker_kamal_base_01 = Find_Hint("MARKER_GENERIC_RED","kamal-base-01")
		if not TestValid(marker_kamal_base_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_base_01!"))
		end
		marker_kamal_habitat_walker = Find_Hint("MARKER_GENERIC_RED","kamal-walker1")
		if not TestValid(marker_kamal_habitat_walker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_habitat_walker!"))
		end
		marker_kamal_assembly_walker = Find_Hint("MARKER_GENERIC_RED","kamal-walker2")
		if not TestValid(marker_kamal_assembly_walker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_assembly_walker!"))
		end
		marker_kamal_walker_defense_01 = Find_Hint("MARKER_GENERIC_RED","kamal-walker-defense1")
		if not TestValid(marker_kamal_walker_defense_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_walker_defense_01!"))
		end
		marker_kamal_walker_defense_02 = Find_Hint("MARKER_GENERIC_RED","kamal-walker-defense2")
		if not TestValid(marker_kamal_walker_defense_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_walker_defense_02!"))
		end
		marker_kamal_forces = Find_Hint("MARKER_GENERIC_RED","kamal-forces")
		if not TestValid(marker_kamal_forces) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_forces!"))
		end
		marker_kamal_saucer = Find_Hint("MARKER_GENERIC_RED","kamal-saucer")
		if not TestValid(marker_kamal_saucer) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_saucer!"))
		end
		marker_kamal_reinforcement = Find_Hint("MARKER_GENERIC_RED","kamal-reinforcement")
		if not TestValid(marker_kamal_reinforcement) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_reinforcement!"))
		end
		marker_kamal_saucer_base = Find_Hint("MARKER_GENERIC_RED","kamal-saucer-base")
		if not TestValid(marker_kamal_saucer_base) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_saucer_base!"))
		end
		marker_kamal_reinforcement_base = Find_Hint("MARKER_GENERIC_RED","kamal-reinforcement-base")
		if not TestValid(marker_kamal_reinforcement_base) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_reinforcement_base!"))
		end
		marker_kamal_walker_science = Find_Hint("MARKER_GENERIC_RED","kamal-walker-science")
		if not TestValid(marker_kamal_walker_science) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_kamal_walker_science!"))
		end
		marker_final_kamal = Find_Hint("MARKER_GENERIC_RED","final-kamal")
		if not TestValid(marker_final_kamal) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_final_kamal!"))
		end
		marker_final_kamal_units = Find_Hint("MARKER_GENERIC_RED","final-kamal-units")
		if not TestValid(marker_final_kamal_units) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_final_kamal_units!"))
		end

		marker_list_orlok_grunts = Find_All_Objects_With_Hint("orlok-grunt")
		if table.getn(marker_list_orlok_grunts) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_list_orlok_grunts!"))
		end
		marker_list_orlok_lostones = Find_All_Objects_With_Hint("orlok-lostone")
		if table.getn(marker_list_orlok_lostones) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_list_orlok_lostones!"))
		end
		marker_list_orlok_brutes = Find_All_Objects_With_Hint("orlok-brute")
		if table.getn(marker_list_orlok_brutes) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_list_orlok_brutes!"))
		end
		marker_orlok_habitat_walker = Find_Hint("MARKER_GENERIC_GREEN","orlok-walker")
		if not TestValid(marker_orlok_habitat_walker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_orlok_habitat_walker!"))
		end
		marker_orlok_arrival_site = Find_Hint("MARKER_GENERIC_GREEN","orlok-arrivalsite")
		if not TestValid(marker_orlok_arrival_site) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_orlok_arrival_site!"))
		end
		marker_transmitter = Find_Hint("MARKER_GENERIC_GREEN","transmitter")
		if not TestValid(marker_transmitter) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_transmitter!"))
		end
		marker_final_orlok_units = Find_Hint("MARKER_GENERIC_GREEN","final-orlok-units")
		if not TestValid(marker_final_orlok_units) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_final_orlok_units!"))
		end
		marker_final_orlok_troop_walker = Find_Hint("MARKER_GENERIC_GREEN","final-orlok-troop-walker")
		if not TestValid(marker_final_orlok_troop_walker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_final_orlok_troop_walker!"))
		end
		marker_final_orlok_assembly_walker = Find_Hint("MARKER_GENERIC_GREEN","final-orlok-assembly-walker")
		if not TestValid(marker_final_orlok_assembly_walker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_final_orlok_assembly_walker!"))
		end
		marker_final_orlok_science_walker = Find_Hint("MARKER_GENERIC_GREEN","final-orlok-science-walker")
		if not TestValid(marker_final_orlok_science_walker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_final_orlok_science_walker!"))
		end
		marker_final_orlok = Find_Hint("MARKER_GENERIC_GREEN","final-orlok")
		if not TestValid(marker_final_orlok) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_final_orlok!"))
		end

		marker_zessus_arrive = Find_Hint("MARKER_GENERIC_YELLOW","zessus-arrive")
		if not TestValid(marker_zessus_arrive) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_zessus_arrive!"))
		end
		marker_zessus_transport_drop = Find_Hint("MARKER_GENERIC_YELLOW","zessus-transport-drop")
		if not TestValid(marker_zessus_transport_drop) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_zessus_transport_drop!"))
		end
		marker_zessus_reinforcement = Find_Hint("MARKER_GENERIC_YELLOW","zessus-reinforcement")
		if not TestValid(marker_zessus_reinforcement) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_zessus_reinforcement!"))
		end
		marker_final_zessus = Find_Hint("MARKER_GENERIC_YELLOW","final-zessus")
		if not TestValid(marker_final_zessus) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_final_zessus!"))
		end

		-- Orlok
		hero = Find_First_Object("Alien_Hero_Orlok")
		if not TestValid(hero) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find hero!"))
		end

		Set_Next_State("State_ZM06_Act01")
	end
end

function State_ZM06_Act01(message)
	local i, j, marker, unit, spawn_list
	
	if message == OnEnter then

      Fade_Screen_Out(0)
      Lock_Controls(1)
      Fade_Out_Music()
      BlockOnCommand(Play_Bink_Movie("Hierarchy_M6_S1",true))

      -- Masari Mode
		masari.Set_Elemental_Mode("Fire")

      -- Proximities
		Register_Prox(marker_kamal_base_01, Prox_Approaching_Kamals_Base, distance_approach_kamals_base, aliens)
		Register_Prox(marker_kamal_base_01, Prox_Inside_Kamals_Base, distance_inside_kamals_base, aliens)
		Register_Prox(marker_zessus_reinforcement, Prox_Approaching_Zessus_Reinforcement, distance_approach_zessus_reinforcement, aliens)
		Register_Prox(marker_transmitter, Prox_Orlok_Approaching_Transmitter, distance_orlok_approach_transmitter, aliens)
		Register_Prox(marker_transmitter, Prox_Orlok_Approaching_Transmitter_Far, distance_orlok_approach_transmitter_far, aliens)

		-- Orlok
		if TestValid(hero) then
			hero.Register_Signal_Handler(Callback_Orlok_Killed, "OBJECT_HEALTH_AT_ZERO")

   		-- Orlok 1200 from 2000 = -.4
		   hero.Add_Attribute_Modifier("Universal_Damage_Modifier", -.4)

			if debug_orlok_invulnerable then
				hero.Make_Invulnerable(true)
			end
		end
	
		-- Orlok and Kamal's starting forces
	   orlok_habitat_walker = Create_Generic_Object(Find_Object_Type("HM06_Orlok_Habitat_Walker"),marker_orlok_habitat_walker.Get_Position(), aliens)
      if TestValid(orlok_habitat_walker) then
         orlok_habitat_walker.Teleport_And_Face(marker_orlok_habitat_walker)
      	orlok_habitat_walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Callback_Orlok_Habitat_Walker_Killed") 
      end
		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)

		list_kamal_guards = SpawnList(list_kamal_starting_units, marker_kamal_base_01, kamals_aliens, false, true, true)
		for i, unit in pairs(list_kamal_guards) do
		   unit.Set_Service_Only_When_Rendered(true)
		end

  		list_kamal_initial_units = SpawnList(list_kamal_initial_engagement_units, marker_kamal_forces, kamals_aliens, false, true, true)
		-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
		Hunt(list_kamal_initial_units, "AntiDefault", true, false, marker_orlok_habitat_walker.Get_Position(), 300)

		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
		spawn_list = SpawnList(list_single_habitat_walker, marker_kamal_habitat_walker, kamals_aliens, false, true, false)
      kamal_habitat_walker = spawn_list[1]
      if TestValid(kamal_habitat_walker) then
         kamal_habitat_walker.Teleport_And_Face(marker_kamal_habitat_walker)
         if TestValid(orlok_habitat_walker) then
            kamal_habitat_walker.Attack_Move(orlok_habitat_walker)
         end
      end
		spawn_list = SpawnList(list_single_assembly_walker, marker_kamal_assembly_walker, kamals_aliens, false, true, false)
      kamal_assembly_walker = spawn_list[1]
      if TestValid(kamal_assembly_walker) then
         kamal_assembly_walker.Teleport_And_Face(marker_kamal_assembly_walker)
         if TestValid(orlok_habitat_walker) then
            kamal_assembly_walker.Attack_Move(orlok_habitat_walker)
            orlok_habitat_walker.Attack_Move(kamal_assembly_walker)
         end
      end

  		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
      for i, marker in pairs (marker_list_orlok_grunts) do
         spawn_list = SpawnList(list_single_alien_grunt, marker, aliens, false, true, true)
   		unit = spawn_list[1]
         if TestValid(unit) then
            unit.Attack_Move(kamal_assembly_walker)
         end
      end
      for i, marker in pairs (marker_list_orlok_lostones) do
         spawn_list = SpawnList(list_single_alien_lost_one, marker, aliens, false, true, true)
   		unit = spawn_list[1]
         if TestValid(unit) then
            unit.Attack_Move(kamal_assembly_walker)
         end
      end
      for i, marker in pairs (marker_list_orlok_brutes) do
         spawn_list = SpawnList(list_single_alien_brute, marker, aliens, false, true, true)
   		unit = spawn_list[1]
         if TestValid(unit) then
            unit.Attack_Move(kamal_assembly_walker)
         end
      end
      
		spawn_list = SpawnList(list_kamal_reapers, marker_kamal_base_attacker_drop, kamals_aliens, false, true, false)
		for i, unit in pairs(spawn_list) do
		   if TestValid(unit) then
		      unit.Move_To(marker_kamal_reapers.Get_Position())
		   end
		end
		
		spawn_list = SpawnList(list_single_glyph_carver, marker_orlok_arrival_site, aliens, false, true, true)
		
		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
		spawn_list = SpawnList(list_single_science_walker, marker_kamal_reinforcement, kamals_aliens, false, true, false)
      kamal_science_walker = spawn_list[1]
      if TestValid(kamal_science_walker) then
         kamal_science_walker.Attack_Move(marker_kamal_walker_science.Get_Position())
      end

		Create_Thread("Thread_Mission_Introduction")
		Create_Thread("Thread_Act01_Progression")
	end
end

function State_ZM06_Act02(message)
   if message == OnEnter then
      -- Zessus Arrives
      Create_Thread("Thread_Zessus_Arrives")
   end
end

function State_ZM06_Act03(message)
   if message == OnEnter then
      Create_Thread("Thread_Kamal_Arrives")
   end
end


--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script

function Thread_Mission_Introduction()
   local list_hardpoints, i, hardpoint, owner

   Point_Camera_At(hero)
   Fade_Screen_Out(0)
   Sleep(1)
   Start_Cinematic_Camera()
   Letter_Box_In(0.1)
   Transition_Cinematic_Target_Key(hero, 0, 0, 0, 0, 0, 0, 0, 0)
   Transition_Cinematic_Camera_Key(hero, 0, 200, 55, 65, 1, 0, 0, 0)
   Transition_To_Tactical_Camera(5)
   Fade_Screen_In(1) 
   Create_Thread("Thread_Intro_Conversation")
   Sleep(5)
   Letter_Box_Out(1)
   Sleep(1)
   Lock_Controls(0)
   End_Cinematic_Camera()

	Sleep(time_radar_sleep)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE06_OBJECTIVE_04_ADD"} )
   Sleep(time_objective_sleep)
   zm06_objective04 = Add_Objective("TEXT_SP_MISSION_HIE06_OBJECTIVE_04")

	Sleep(time_radar_sleep)
   Add_Radar_Blip(marker_orlok_arrival_site, "DEFAULT", "blip_arrival_site")
   
   Sleep(time_objective_sleep)
   list_hardpoints = Find_All_Objects_Of_Type("Alien_Walker_Habitat_BACK_HP00")
   for i, hardpoint in pairs(list_hardpoints) do
      if TestValid(hardpoint) then
         if hardpoint.Get_Owner() == aliens then
            hardpoint.Take_Damage(10000)
         end
      end
   end
   list_hardpoints = Find_All_Objects_Of_Type("Alien_Walker_Habitat_BACK_HP01")
   for i, hardpoint in pairs(list_hardpoints) do
      if TestValid(hardpoint) then
         if hardpoint.Get_Owner() == aliens then
            hardpoint.Take_Damage(10000)
         end
      end
   end
   
   Sleep(time_objective_sleep)
   list_hardpoints = Find_All_Objects_Of_Type("ALIEN_WALKER_HABITAT_COOLING_HP00")
   for i, hardpoint in pairs(list_hardpoints) do
      if TestValid(hardpoint) then
         if hardpoint.Get_Owner() == aliens then
            hardpoint.Take_Damage(10000)
         end
      end
   end
   list_hardpoints = Find_All_Objects_Of_Type("ALIEN_WALKER_HABITAT_COOLING_HP01")
   for i, hardpoint in pairs(list_hardpoints) do
      if TestValid(hardpoint) then
         if hardpoint.Get_Owner() == aliens then
            hardpoint.Take_Damage(10000)
         end
      end
   end
end

function Thread_Intro_Conversation()
	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE02_01"))
	BlockOnCommand(Queue_Talking_Head(pip_comm, "HIE06_SCENE02_02"))

   Sleep(time_objective_sleep)
  	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE07_01"))
end

function Thread_Act01_Progression()
   Sleep(time_zessus_arrival)
	Set_Next_State("State_ZM06_Act02")
	
	Sleep(time_delay_kamal_base_attack_01)
	Call_Base_Assault_Saucer(list_kamal_base_assault_units_01)

	Sleep(time_delay_kamal_base_attack_02)
	Call_Base_Assault_Saucer(list_kamal_base_assault_units_02)
   
   Sleep(time_delay_kamal_base_attack_03)
   Create_Thread("Thread_Kamal_Saucer_Squadron")
   while not mission_success and not mission_failure and not kamal_has_arrived do
	   Call_Base_Assault_Saucer(list_kamal_base_assault_units_03)
	   Sleep(time_delay_kamal_base_attack_03)
	end
end

function Thread_Kamal_Saucer_Squadron()
    
   local spawn_list = {}
   local saucer_destination = 0
   local i, unit
   
   -- 0 = Orlok's Base, 1 = Dish.
   
   Sleep(time_delay_kamal_base_attack_03)
   while not mission_success and not mission_failure do
      for i, unit in pairs(spawn_list) do
         if not TestValid(unit) then
            table.remove(spawn_list, i)
         end
      end
      if table.getn(spawn_list) <= 0 then
    		spawn_list = SpawnList(list_kamal_saucer_squadron, marker_kamal_base_attacker_saucer, kamals_aliens, false, true, false)
      else
         if saucer_destination == 0 then
            saucer_destination = 1
        		-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
        		Hunt(spawn_list, "AntiDefault", true, true, marker_orlok_arrival_site.Get_Position(), distance_base_patrol)
         else
            saucer_destination = 0
        		-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
        		Hunt(spawn_list, "AntiDefault", true, true, marker_transmitter.Get_Position(), distance_base_patrol)
         end
      end
      Sleep(time_saucer_attack)
   end
end

function Call_Base_Assault_Saucer(list_attackers)
   local spawn_list, alien_saucer, alien_base_assault_group
   
   if not mission_success and not mission_failure then
  		spawn_list = SpawnList(list_single_alien_saucer, marker_kamal_base_attacker_saucer, kamals_aliens, false, true, false)
		alien_saucer = spawn_list[1]
		if TestValid(alien_saucer) then
			alien_saucer.Make_Invulnerable(true)
			alien_saucer.Change_Owner(neutral)
			BlockOnCommand(alien_saucer.Move_To(marker_kamal_base_attacker_drop.Get_Position()))
			-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
		   alien_base_assault_group = SpawnList(list_attackers, marker_kamal_base_attacker_drop.Get_Position(), kamals_aliens, false, true, false)
     		-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
         Hunt(alien_base_assault_group, "AntiDefault", true, true, marker_orlok_arrival_site.Get_Position(), distance_base_patrol)
			if TestValid(alien_saucer) then
				BlockOnCommand(alien_saucer.Move_To(marker_kamal_base_attacker_saucer.Get_Position()))
				if TestValid(alien_saucer) then
					alien_saucer.Make_Invulnerable(false)
					alien_saucer.Despawn()
				end
			end
	   end
   end
end

function Thread_Kamal_Arrives()
   local player_object_list, i, unit, type, orlok_unit_list, orlok_unit_spawn_list, kamal_object_list, kamal_unit_list, kamal_unit_spawn_list, spawn_list, size

   if TestValid(hero) then
      hero.Make_Invulnerable(true)
      hero.Set_Cannot_Be_Killed(true)
   end
   
   Lock_Controls(1)
   Fade_Screen_Out(1)
   Sleep(1)
   
   -- Play the midtro cinematic.
   Fade_Out_Music()
   BlockOnCommand(Play_Bink_Movie("Hierarchy_M6_S3",true))
   
   -- Move Player Forces
   player_object_list = Find_All_Objects_Of_Type(aliens)
   orlok_unit_list = {}
   
   for i, unit in pairs(player_object_list) do
      if TestValid(unit) then
         type = unit.Get_Type()
         
         -- Non-Conflict Units (move to respective bases):
         if type == object_type_glyph_carver or type == object_type_scan_drone then
            unit.Teleport(marker_orlok_arrival_site.Get_Position())
            unit.Stop()
            
         -- Basic Conflict Units (put types in a list, delete, spawnlist at appropriate location):
         elseif type == object_type_monolith or type == object_type_lost_one or type == object_type_grunt or type == object_type_brute or type == object_type_mutant_slave or type == object_type_defiler or type == object_type_saucer or type == object_type_phase_tank then
            table.insert(orlok_unit_list, type)
            unit.Despawn()
            
         -- Walkers (teleport the first to the dish, move any others):
         elseif type == object_type_troop_walker then
            if not moved_final_orlok_troop_walker then
               moved_final_orlok_troop_walker = true
               unit.Teleport_And_Face(marker_final_orlok_troop_walker)
               unit.Guard_Target(unit.Get_Position())
            else
               unit.Attack_Move(marker_final_orlok_troop_walker.Get_Position())
            end
         elseif type == object_type_assembly_walker then
            if not moved_final_orlok_assembly_walker then
               moved_final_orlok_assembly_walker = true
               unit.Teleport_And_Face(marker_final_orlok_assembly_walker)
               unit.Guard_Target(unit.Get_Position())
            else
               unit.Attack_Move(marker_final_orlok_assembly_walker.Get_Position())
            end
         elseif type == object_type_science_walker then
            if not moved_final_orlok_science_walker then
               moved_final_orlok_science_walker = true
               unit.Teleport_And_Face(marker_final_orlok_science_walker)
               unit.Guard_Target(unit.Get_Position())
            else
               unit.Attack_Move(marker_final_orlok_science_walker.Get_Position())
            end
         elseif type == object_type_orlok or type == object_type_orlok_base or type == object_type_orlok_siege or type == object_type_orlok_endure then
            unit.Teleport_And_Face(marker_final_orlok)
         end
      end
   end
   if table.getn(orlok_unit_list) > 0 then
	   -- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
      orlok_unit_spawn_list = SpawnList(orlok_unit_list, marker_final_orlok_units, aliens, false, true, true)
      for i, unit in pairs(orlok_unit_spawn_list) do
         if TestValid(unit) then
            unit.Guard_Target(unit.Get_Position())
         end
      end
   end

   -- Move Kamal Rex Forces
   kamal_object_list = Find_All_Objects_Of_Type(kamals_aliens)
   kamal_unit_list = {}
   
   for i, unit in pairs(kamal_object_list) do
      if TestValid(unit) then
         type = unit.Get_Type()
         
         -- Non-Conflict Units (move to respective bases):
         if type == object_type_glyph_carver or type == object_type_scan_drone then
            unit.Despawn()
            
         -- Basic Conflict Units (put types in a list, delete, spawnlist at appropriate location):
         elseif type == object_type_monolith or type == object_type_lost_one or type == object_type_grunt or type == object_type_brute or type == object_type_mutant_slave or type == object_type_defiler or type == object_type_saucer or type == object_type_phase_tank then
            table.insert(kamal_unit_list, type)
            unit.Despawn()
            
         -- Walkers (teleport the first to the dish, move any others):
         elseif type == object_type_troop_walker or type == object_type_kamal_troop_walker then
            if not moved_final_kamal_troop_walker then
               moved_final_kamal_troop_walker = true
               unit.Teleport_And_Face(marker_kamal_walker_defense_01)
               unit.Guard_Target(unit.Get_Position())
            else
               unit.Attack_Move(marker_kamal_walker_defense_01.Get_Position())
            end
         elseif type == object_type_assembly_walker or type == object_type_kamal_assembly_walker then
            if not moved_final_kamal_assembly_walker then
               moved_final_kamal_assembly_walker = true
               unit.Teleport_And_Face(marker_kamal_walker_defense_02)
               unit.Guard_Target(unit.Get_Position())
            else
               unit.Attack_Move(marker_kamal_walker_defense_02.Get_Position())
            end
         elseif type == object_type_science_walker or type == object_type_kamal_science_walker then
            if not moved_final_kamal_science_walker then
               moved_final_kamal_science_walker = true
               unit.Teleport_And_Face(marker_kamal_walker_science)
               unit.Guard_Target(unit.Get_Position())
            else
               unit.Attack_Move(marker_kamal_walker_science.Get_Position())
            end
         end
      end
   end
   
   -- If we don't have any walkers for Kamal, give him more.
   if not moved_final_kamal_troop_walker then
      moved_final_kamal_troop_walker = true
		spawn_list = SpawnList(list_single_habitat_walker, marker_kamal_walker_defense_01, kamals_aliens, false, true, false)
      kamal_habitat_walker = spawn_list[1]
      if TestValid(kamal_habitat_walker) then
         kamal_habitat_walker.Teleport_And_Face(marker_kamal_walker_defense_01)
         kamal_habitat_walker.Guard_Target(kamal_habitat_walker.Get_Position())
      end
   end
   if not moved_final_kamal_assembly_walker then
      moved_final_kamal_assembly_walker = true
		spawn_list = SpawnList(list_single_assembly_walker, marker_kamal_walker_defense_02, kamals_aliens, false, true, false)
      kamal_assembly_walker = spawn_list[1]
      if TestValid(kamal_assembly_walker) then
         kamal_assembly_walker.Teleport_And_Face(marker_kamal_walker_defense_02)
         kamal_assembly_walker.Guard_Target(kamal_assembly_walker.Get_Position())
      end
   end
   if not moved_final_kamal_science_walker then
      moved_final_kamal_science_walker = true
		spawn_list = SpawnList(list_single_science_walker, marker_kamal_walker_science, kamals_aliens, false, true, false)
      kamal_science_walker = spawn_list[1]
      if TestValid(kamal_science_walker) then
         kamal_science_walker.Teleport_And_Face(marker_kamal_walker_science)
         kamal_science_walker.Guard_Target(kamal_science_walker.Get_Position())
      end
   end
   if table.getn(kamal_unit_list) > 0 then
	   -- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
      kamal_unit_spawn_list = SpawnList(kamal_unit_list, marker_final_kamal_units, kamals_aliens, true, true, true)
      for i, unit in pairs(kamal_unit_spawn_list) do
         if TestValid(unit) then
            unit.Guard_Target(unit.Get_Position())
         end
      end
   end
   
   -- Spawn Kamal Rex
   spawn_list = SpawnList(list_single_kamal_rex, marker_final_kamal, kamals_aliens, true, true, false)
   kamal_rex = spawn_list[1]
   if TestValid(kamal_rex) then
   
		-- Kamal 900 from 1500 = -.4
	   kamal_rex.Add_Attribute_Modifier("Universal_Damage_Modifier", -.6)

      kamal_rex.Register_Signal_Handler(Callback_Kamal_Rex_Damaged, "OBJECT_DAMAGED")
      kamal_rex.Set_Cannot_Be_Killed(true)
   	-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
	   Hunt(spawn_list, "AntiDefault", true, true, marker_final_kamal_units.Get_Position(), 400)   
   end
   
   -- Teleport_And_Face Zessus
   if TestValid(zessus) then
      zessus.Teleport_And_Face(marker_final_zessus)
      zessus.Guard_Target(zessus.Get_Position())
   end
   
   -- Spawn Supplimentary Kamal Rex Forces (using kamal_unit_list)
   -- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
   size = table.getn(kamal_unit_list)
   if size <= 5 then
      spawn_list = SpawnList(list_kamal_final_units_20, marker_final_kamal_units, kamals_aliens, true, true, false)
   elseif size <= 10 then
      spawn_list = SpawnList(list_kamal_final_units_15, marker_final_kamal_units, kamals_aliens, true, true, false)
   elseif size <= 15 then
      spawn_list = SpawnList(list_kamal_final_units_10, marker_final_kamal_units, kamals_aliens, true, true, false)
   elseif size <= 20 then
      spawn_list = SpawnList(list_kamal_final_units_05, marker_final_kamal_units, kamals_aliens, true, true, false)
   end
	-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
	Hunt(spawn_list, "AntiDefault", true, true, marker_transmitter.Get_Position(), 800)   
   
   kamal_has_arrived = true
   
   if TestValid(hero) then
      Point_Camera_At(hero)
      if not debug_orlok_invulnerable then
         hero.Make_Invulnerable(false)
      end
      hero.Set_Cannot_Be_Killed(false)
   end
   Fade_Screen_In(1)
   Sleep(1)
   Lock_Controls(0)
   Create_Thread("Thread_Final_Conversation")
end

function Thread_Final_Conversation()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE06_OBJECTIVE_03_ADD"} )
   Sleep(time_objective_sleep)
   zm06_objective02 = Add_Objective("TEXT_SP_MISSION_HIE06_OBJECTIVE_03")

	Sleep(time_radar_sleep)
   if TestValid(kamal_rex) then
	   Add_Radar_Blip(kamal_rex, "DEFAULT", "blip_kamal_rex")
	   kamal_rex.Highlight(true, -50)
   end
   
   conversation_active = true
   if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE06_SCENE05_01"))
  	end
   conversation_active = false
  	
  	Sleep(time_objective_sleep)
   conversation_active = true
   if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE06_SCENE05_02"))
  	end
   if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE05_03"))
  	end
   if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_comm, "HIE06_SCENE05_04"))
  	end
   if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE05_05"))
  	end
   if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE06_SCENE05_06"))
  	end
   if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE05_07"))
  	end
   if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_kamal, "HIE06_SCENE05_08"))
  	end
   conversation_active = false
end

function Thread_Kamal_Base_Defenders()
	local alien_saucer, i, alien_reinforcements, unit, spawn_list

	while not mission_success and not mission_failure do

      for i, unit in pairs(list_kamal_guards) do
         if not TestValid(unit) then
            table.remove(list_kamal_guards, i)
         end
      end

      -- Base Defense Squad
		if table.getn(list_kamal_guards) < minimum_kamal_base_guards then
     		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
     		spawn_list = SpawnList(list_single_alien_saucer, marker_kamal_saucer_base, kamals_aliens, false, true, false)
			alien_saucer = spawn_list[1]
			if TestValid(alien_saucer) then
				alien_saucer.Make_Invulnerable(true)
   			alien_saucer.Change_Owner(neutral)
				BlockOnCommand(alien_saucer.Move_To(marker_kamal_reinforcement_base.Get_Position()))
				-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
				alien_reinforcements = SpawnList(list_kamal_starting_units, marker_kamal_reinforcement_base.Get_Position(), kamals_aliens, false, true, true)
      		-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
            Hunt(alien_reinforcements, "AntiDefault", true, true, marker_kamal_base_01.Get_Position(), distance_base_patrol)
            for i, unit in pairs(alien_reinforcements) do
               table.insert(list_kamal_guards, unit)
            end
				if TestValid(alien_saucer) then
					BlockOnCommand(alien_saucer.Move_To(marker_kamal_saucer_base.Get_Position()))
					if TestValid(alien_saucer) then
						alien_saucer.Make_Invulnerable(false)
						alien_saucer.Despawn()
					end
				end
			end
		end

		Sleep(time_spawn_base_defenders)
		
	end
end

function Thread_Kamal_Attackers()
	local alien_saucer, i, alien_reinforcements, unit, spawn_list

	while not mission_success and not mission_failure and not kamal_has_arrived do

      -- Transmitter Assault Squad
      for i, unit in pairs(list_kamal_attackers) do
         if not TestValid(unit) then
            table.remove(list_kamal_attackers, i)
         end
      end
		if table.getn(list_kamal_attackers) < minimum_attackers then
     		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
     		spawn_list = SpawnList(list_single_alien_saucer, marker_kamal_saucer, kamals_aliens, false, true, false)
			alien_saucer = spawn_list[1]
			if TestValid(alien_saucer) then
				alien_saucer.Make_Invulnerable(true)
   			alien_saucer.Change_Owner(neutral)
				BlockOnCommand(alien_saucer.Move_To(marker_kamal_reinforcement.Get_Position()))
				-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
				alien_reinforcements = SpawnList(list_kamal_dish_assault_units, marker_kamal_reinforcement.Get_Position(), kamals_aliens, false, true, true)
      		-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
            Hunt(alien_reinforcements, "AntiDefault", true, true, marker_transmitter.Get_Position(), 800)
            for i, unit in pairs(alien_reinforcements) do
               table.insert(list_kamal_attackers, unit)
            end
				if TestValid(alien_saucer) then
					BlockOnCommand(alien_saucer.Move_To(marker_kamal_saucer.Get_Position()))
					if TestValid(alien_saucer) then
						alien_saucer.Make_Invulnerable(false)
						alien_saucer.Despawn()
					end
				end
			end
		end
		
		Sleep(time_spawn_attackers)

	end
end

function Thread_Zessus_Arrives()
   local spawn_list
   
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	spawn_list = SpawnList(list_single_masari_transport, marker_zessus_arrive, masari, false, true, false)
	masari_transport = spawn_list[1]
	if TestValid(masari_transport) then
  		masari_transport.Make_Invulnerable(true)
    	masari_transport.Set_Selectable(false)

      while conversation_active do
         Sleep(1)
      end
      if not mission_success and not mission_failure then
         conversation_active = true
  	      BlockOnCommand(Queue_Talking_Head(pip_comm, "HIE06_SCENE07_13"))
         conversation_active = false
      end

      BlockOnCommand(masari_transport.Move_To(marker_zessus_transport_drop.Get_Position()))
      spawn_list = SpawnList(list_single_zessus, marker_zessus_transport_drop, masari, false, true, false)
      zessus = spawn_list[1]
      list_current_disciples = SpawnList(list_masari_disciples, marker_zessus_transport_drop, masari, false, true, false)
      if TestValid(zessus) then
      
   		-- Zessus 800 from 2500 = -.68
		   zessus.Add_Attribute_Modifier("Universal_Damage_Modifier", -.68)	   

         zessus.Set_Cannot_Be_Killed(true)
         zessus.Add_Attribute_Modifier("Teleportation_Recharge_Mult",3)
         Create_Thread("Thread_Zessus_AI",zessus)
   		Register_Prox(zessus, Prox_Approaching_Zessus, distance_approach_zessus, kamals_aliens)
   		Create_Thread("Thread_Zessus_Arrival_Conversation")
      end
   	Add_Radar_Blip(marker_zessus_transport_drop, "Default_Beacon_Placement", "blip_zessus")
   	if TestValid(masari_transport) then
         BlockOnCommand(masari_transport.Move_To(marker_zessus_arrive.Get_Position()))
	      if TestValid(masari_transport) then
		      masari_transport.Make_Invulnerable(false)
		      masari_transport.Despawn()
	      end
   	end
  	end
end

function Thread_Zessus_Arrival_Conversation()
   while conversation_active do
      Sleep(1)
   end
   if not mission_success and not mission_failure then
      conversation_active = true
  	   BlockOnCommand(Queue_Talking_Head(pip_zessus, "HIE06_SCENE03_01"))
	   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE03_02"))
      conversation_active = false
   end

   Sleep(15)
   while conversation_active do
      Sleep(1)
   end
   if not mission_success and not mission_failure then
      conversation_active = true
  	   BlockOnCommand(Queue_Talking_Head(pip_zessus, "HIE06_SCENE07_10"))
  	   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE07_11"))
      conversation_active = false
   	Create_Thread("Thread_Repeat_Zessus_Radar_Blip")
   	marker_zessus_reinforcement.Highlight(true)
   	zessus_reinforcement_area = Create_Generic_Object(Find_Object_Type("Highlight_Area"), marker_zessus_reinforcement, neutral)
   	
      zessus_ai_informed_player = true
   end
   
   Sleep(30)
   while conversation_active do
      Sleep(1)
   end
   if not mission_success and not mission_failure then
      conversation_active = true
  	   BlockOnCommand(Queue_Talking_Head(pip_zessus, "HIE06_SCENE07_04"))
  	   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE07_05"))
      conversation_active = false
   end
end

function Thread_Repeat_Zessus_Radar_Blip()
   while not mission_success and not mission_failure do
      Add_Radar_Blip(marker_zessus_reinforcement, "Default_Beacon_Placement", "blip_arrival_site")
      Sleep(10)
   end
end

function Thread_More_Disciples()
   -- Wait until the current transport is gone.
   while TestValid(masari_transport) do
      Sleep(1)
   end

	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	spawn_list = SpawnList(list_single_masari_transport, marker_zessus_arrive, masari, false, true, false)
	masari_transport = spawn_list[1]
	if TestValid(masari_transport) then
  		masari_transport.Make_Invulnerable(true)
    	masari_transport.Set_Selectable(false)
      BlockOnCommand(masari_transport.Move_To(marker_zessus_transport_drop.Get_Position()))
      list_current_disciples = SpawnList(list_masari_disciples, marker_zessus_transport_drop, masari, false, true, false)
   	if TestValid(masari_transport) then
         BlockOnCommand(masari_transport.Move_To(marker_zessus_arrive.Get_Position()))
	      if TestValid(masari_transport) then
		      masari_transport.Make_Invulnerable(false)
		      masari_transport.Despawn()
	      end
   	end
  	end
end

function Thread_Zessus_AI(obj)
   local health, destination_obj, distance, i, unit

   while not mission_success and not mission_failure do
            
      -- Check Zessus
      zessus_ai_spotted_infantry = false
      zessus_ai_spotted_enemy = false
      zessus_ai_reinforcements_active = false

      Sleep(1)

      -- Check if my health is too low. If so, I need to be moving to a safer location.
      health = obj.Get_Hull()
      if health < 0.1 then
         
         -- My health is too low, am I close enough to the retreat location?
         if TestValid(orlok_arrival_site) then
            destination_obj = orlok_arrival_site
         else
            destination_obj = marker_orlok_arrival_site
         end
         distance = obj.Get_Distance(destination_obj)
         if distance < distance_zessus_safety then
            obj.Guard_Target(obj.Get_Position())
         else
            obj.Move_To(destination_obj.Get_Position())
         end
      else         
         
         -- Has the player been informed of my actions?
         if not zessus_ai_informed_player then
            
            -- The player has not been informed. Go assist Orlok if he's not too far away.
            Zessus_Assist_Orlok(obj)
         else

            -- The player has been informed. Are there enemies nearby?
            if zessus_ai_spotted_enemy or zessus_ai_spotted_infantry then
               
               -- There are enemies nearby. Is my explode ability ready?
               if obj.Is_Ability_Ready("Masari_Zessus_Explode_Unit_Ability") then
						BlockOnCommand(obj.Activate_Ability("Masari_Zessus_Explode_Unit_Ability", true))
               else

                  -- The explode ability isn't active. Has the player setup spitters?
                  if TestValid(zessus_ai_spitter_01) and TestValid(zessus_ai_spitter_02) and TestValid(zessus_ai_spitter_03) then

                     -- The player has a trap set up. Is my teleport ability ready?
                     if obj.Is_Ability_Ready("Masari_Zessus_Teleportation_Unit_Ability") then

                        -- The ability is ready. Ensure there are only infantry around me.
                        if not zessus_ai_spotted_enemy then
                           
                           -- Ensure Zessus is close enough to the spitter to teleport.
                           distance = obj.Get_Distance(zessus_ai_spitter_01)
                           if distance < distance_zessus_teleport_maximum then
      						      obj.Activate_Ability("Masari_Zessus_Teleportation_Unit_Ability", true, zessus_ai_spitter_01.Get_Position(), true)
      						   else
                              Zessus_Assist_Orlok(obj)
      						   end
                        else
                           Zessus_Assist_Orlok(obj)
                        end
                     else
                        Zessus_Assist_Orlok(obj)
                     end
                  else
                     Zessus_Assist_Orlok(obj)
                  end
               end
            else

               -- No enemies are nearby. Has the player gathered any units at the reinforcement point?
               if zessus_ai_reinforcements_active then
            
                  -- There are active reinforcements. Am I close enough to that location?
                  distance = obj.Get_Distance(marker_zessus_reinforcement)
                  if distance < distance_zessus_arrive_at_reinforcement then
         
                     -- I'm close enough. Is my teleport ability ready?
                     if obj.Is_Ability_Ready("Masari_Zessus_Teleportation_Unit_Ability") then
                     
                        -- My teleport ability is ready. Teleport to the transmitter.
  						      obj.Activate_Ability("Masari_Zessus_Teleportation_Unit_Ability", true, marker_final_orlok_units.Get_Position(), true)
                     end
                  else
                     -- I'm not close enough. Move to the reinforcement position.
                     obj.Attack_Move(marker_zessus_reinforcement.Get_Position())
                  end
               else

                  -- There are no active reinforcements waiting. I'm attacking normally.
                  Zessus_Assist_Orlok(obj)
               end
            end
         end
      end

      -- Check Disciples
      for i, unit in pairs(list_current_disciples) do
         if not TestValid(unit) then
            table.remove(list_current_disciples, i)
         end
      end
      if table.getn(list_current_disciples) > 0 then
         if TestValid(zessus) then
		      -- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
		      Hunt(list_current_disciples, "AntiDefault", true, true, zessus.Get_Position(), 100)
		   end
      else
         -- Disciple list is empty, time to bring in new ones.
         Create_Thread("Thread_More_Disciples")
      end

      Sleep (time_zessus_ai_cycle)
   end
end

function Zessus_Assist_Orlok(obj)
   local distance, health

   if TestValid(hero) then

      distance = obj.Get_Distance(hero)
      if distance < distance_approach_zessus and not kamal_has_arrived then
               
         -- Orlok is nearby. Check his health.
         health = hero.Get_Hull()
         if health < 0.15 then
            
            -- Orlok is wounded. Am I close enough to the drop point to teleport him to safety?
            distance = obj.Get_Distance(marker_zessus_reinforcement)
            if distance < distance_zessus_teleport_maximum then
               
               -- I'm close enough. Is my teleport ability ready?
               if obj.Is_Ability_Ready("Masari_Zessus_Teleportation_Unit_Ability") then
                  
                  -- My ability is ready. How close am I to the reinforcement point?
                  distance = obj.Get_Distance(marker_zessus_reinforcement)
                  if distance < distance_zessus_approach_reinforcement_point then
                     
                     -- I'm too close to the reinforcement point. Teleport to the base instead.
					      obj.Activate_Ability("Masari_Zessus_Teleportation_Unit_Ability", true, marker_orlok_arrival_site.Get_Position(), true)
                  else
                  
                     -- Teleport to the reinforcement point.
					      obj.Activate_Ability("Masari_Zessus_Teleportation_Unit_Ability", true, marker_zessus_reinforcement.Get_Position(), true)
                  end
               else
                  distance = hero.Get_Distance(marker_kamal_base_01)
                  if distance > distance_orlok_to_enemy_base then
                     obj.Attack_Move(hero.Get_Position())
                  end
               end
            else
               distance = hero.Get_Distance(marker_kamal_base_01)
               if distance > distance_orlok_to_enemy_base then
                  obj.Attack_Move(hero.Get_Position())
               end
            end
         else
            distance = hero.Get_Distance(marker_kamal_base_01)
            if distance > distance_orlok_to_enemy_base then
               obj.Attack_Move(hero.Get_Position())
            end
         end
      else
         distance = hero.Get_Distance(marker_kamal_base_01)
         if distance > distance_orlok_to_enemy_base then
            obj.Attack_Move(hero.Get_Position())
         end
      end
   end
end


--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script

function Callback_Kamal_Rex_Damaged(tf, walker, attacker, projectile_type, hard_point, deliberate)
   local health
   
   health = kamal_rex.Get_Hull()
   if health < 0.1 then
      if not misson_complete_called then
         misson_complete_called = true
         Create_Thread("Thread_Mission_Complete")
      end
   else
      Use_Kamal_Rex_Abilities(attacker)
   end
end

function Use_Kamal_Rex_Abilities(attacker)
   local type
   
   if TestValid(attacker) then
      if kamal.Is_Ability_Ready("Kamal_Rex_Abduction_Unit_Ability") then
         type = attacker.Get_Type()
         if type == object_type_glyph_carver or type == object_type_lost_one or type == object_type_grunt or type == object_type_brute or type == object_type_phase_tank then
            kamal.Activate_Ability("Kamal_Rex_Abduction_Unit_Ability", true, attacker.Get_Position())
         else
            if kamal.Is_Ability_Ready("Kamal_Rex_Force_Wall_Unit_Ability") then
               kamal.Activate_Ability("Kamal_Rex_Force_Wall_Unit_Ability", true, kamal.Get_Position())
            end
         end
      else
         if kamal.Is_Ability_Ready("Kamal_Rex_Force_Wall_Unit_Ability") then
            kamal.Activate_Ability("Kamal_Rex_Force_Wall_Unit_Ability", true, kamal.Get_Position())
         end
      end
   end
end

function Prox_Inside_Kamals_Base(prox_obj, trigger_obj)
   local type
   
   type = trigger_obj.Get_Type()
   if type ~= object_type_monolith then
   	prox_obj.Cancel_Event_Object_In_Range(Prox_Inside_Kamals_Base)
   	Create_Thread("Thread_Inside_Kamals_Base")
   end
end

function Thread_Inside_Kamals_Base()
   while conversation_active do
      Sleep(1)
   end
   if not mission_success and not mission_failure and not kamal_has_arrived then
      conversation_active = true
     	BlockOnCommand(Queue_Talking_Head(pip_comm, "HIE06_SCENE07_06"))
     	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE07_07"))
      conversation_active = false
   end
end

function Prox_Orlok_Approaching_Transmitter_Far(prox_obj, trigger_obj)
   local type
   
   type = trigger_obj.Get_Type()
   if type == object_type_orlok or type == object_type_orlok_base or type == object_type_orlok_siege or type == object_type_orlok_endure then
   	prox_obj.Cancel_Event_Object_In_Range(Prox_Orlok_Approaching_Transmitter_Far)
   	Create_Thread("Thread_Prox_Orlok_Approaching_Transmitter_Far")
   end
end

function Thread_Prox_Orlok_Approaching_Transmitter_Far()
   if not transmitter_objective_issued then
      transmitter_objective_issued = true
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE06_OBJECTIVE_01_ADD"} )
	   Sleep(time_objective_sleep)
      zm06_objective01 = Add_Objective("TEXT_SP_MISSION_HIE06_OBJECTIVE_01")
      Sleep(time_radar_sleep)
      Add_Radar_Blip(marker_transmitter, "DEFAULT", "blip_transmitter")
   end
end

function Prox_Orlok_Approaching_Transmitter(prox_obj, trigger_obj)
   local type
   
   type = trigger_obj.Get_Type()
   if type == object_type_orlok or type == object_type_orlok_base or type == object_type_orlok_siege or type == object_type_orlok_endure then
   	prox_obj.Cancel_Event_Object_In_Range(Prox_Orlok_Approaching_Transmitter)
   	Create_Thread("Thread_Approaching_Transmitter")
   end
end

function Thread_Approaching_Transmitter()
	transmitter_effect_obj = Create_Generic_Object(Find_Object_Type("HM06_Arecibo_Transmitter_Effect"), marker_transmitter_effect.Get_Position(), neutral)
   if TestValid(transmitter_effect_obj) then
      transmitter_effect_obj.Teleport_And_Face(marker_transmitter_effect)
   end
   
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE06_OBJECTIVE_01_COMPLETE"} )
   
   -- DEBUG turn the transmitter on here. Turn it off when Orlok fails it, and turn it off for the finale.
   
   Sleep(time_objective_sleep)   
   Create_Thread("Thread_Monitor_Objective02_Timer")
   
   Sleep(time_objective_sleep)   
   if not switched_to_act_02 then
      switched_to_act_02 = true
      Set_Next_State("State_ZM06_Act02")
	end   

end

function Thread_Monitor_Objective02_Timer()
   local out_string, distance
   
	local time_left_minutes = 2
	local time_left_seconds = 0
	local time_left = 120

   if not mission_success and not mission_failure then
      conversation_active = true
      BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE05_09"))
      conversation_active = false
   end
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE06_OBJECTIVE_02_ADD"} )
	   Sleep(time_objective_sleep)
   
	Set_Objective_Text(zm06_objective01, "TEXT_SP_MISSION_HIE06_OBJECTIVE_02A")
	out_string = Get_Game_Text("TEXT_SP_MISSION_HIE06_OBJECTIVE_02A")
	out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_minutes), 1)
	out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_seconds), 2)
	Set_Objective_Text(zm06_objective01, out_string)
	
	Sleep(1)
	
	while (time_left >= 0) and not orlok_left_transmitter and not mission_success and not mission_failure do
		
		if time_left == 119 then
			time_left_minutes = 1
			time_left_seconds = 59
		elseif time_left == 59 then
			time_left_minutes = 0
			time_left_seconds = 59
		end
		
		if time_left_seconds < 10 then --this is a variant of the objective that allows me to put a zero in-front of any seconds less than 10 (eg. 09, 08...)
			out_string = Get_Game_Text("TEXT_SP_MISSION_HIE06_OBJECTIVE_02A")
			out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_minutes), 1)
			out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_seconds), 2)
			Set_Objective_Text(zm06_objective01, out_string)
		else
			out_string = Get_Game_Text("TEXT_SP_MISSION_HIE06_OBJECTIVE_02")
			out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_minutes), 1)
			out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_seconds), 2)
			Set_Objective_Text(zm06_objective01, out_string)
		end
		time_left = time_left - 1
		time_left_seconds = time_left_seconds - 1

		Sleep(1)
		
		if TestValid(hero) then
		   distance = hero.Get_Distance(marker_transmitter)
		   if distance > distance_orlok_to_transmitter then
		      orlok_left_transmitter = true
		   end
	   end
		
	end

   if not mission_success and not mission_failure then
      if orlok_left_transmitter then
         if TestValid(transmitter_effect_obj) then
            transmitter_effect_obj.Despawn()
         end      
      	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE06_OBJECTIVE_02_FAILED"} )
         orlok_left_transmitter = false
      	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE06_OBJECTIVE_01_ADD"} )
      	Sleep(time_objective_sleep)
      	Set_Objective_Text(zm06_objective01, "TEXT_SP_MISSION_HIE06_OBJECTIVE_01")
   		Register_Prox(marker_transmitter, Prox_Orlok_Approaching_Transmitter, distance_orlok_approach_transmitter, aliens)
      else
      	Set_Objective_Text(zm06_objective01, "TEXT_SP_MISSION_HIE06_OBJECTIVE_01")
      	Remove_Radar_Blip("blip_transmitter")
         Objective_Complete(zm06_objective01)
      	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE06_OBJECTIVE_02_COMPLETE"} )
         while conversation_active do
            Sleep(1)
         end
      	Sleep(time_radar_sleep)
         if not mission_success and not mission_failure then
            Set_Next_State("State_ZM06_Act03")
         end
      end
   end
end

function Prox_Approaching_Zessus(prox_obj, trigger_obj)
   local type

   type = trigger_obj.Get_Type()
   if type == object_type_grunt or type == object_type_lost_one then
      zessus_ai_spotted_infantry = true
   else
      zessus_ai_spotted_enemy = true
   end
end

function Prox_Approaching_Zessus_Reinforcement(prox_obj, trigger_obj)
   if trigger_obj ~= hero then
      zessus_ai_reinforcements_active = true
   end
end

function Zessus_Spitter_Trap_Identification(obj)
   local distance

   -- The player has just built a Spitter Turret. Check for an open slot, and distance to previously existing spitters.
   if TestValid(zessus_ai_spitter_01) then
      if TestValid(zessus_ai_spitter_02) then
         if TestValid(zessus_ai_spitter_03) then
            -- We've already got a trap set up. No need to check for another combination.
         else
            -- Spitter 03 doesn't exist, this could be it. Check distance to the other two spitters.
            distance = obj.Get_Distance(zessus_ai_spitter_01)
            if distance < distance_teleport_trap then
               distance = obj.Get_Distance(zessus_ai_spitter_02)
               if distance < distance_teleport_trap then
                  -- The other two spitters are close enough.
                  zessus_ai_spitter_03 = obj
               end
            end
         end
      else
         -- Spitter 02 doesn't exist, this could be it. Check distance to the other spitter.
         distance = obj.Get_Distance(zessus_ai_spitter_01)
         if distance < distance_teleport_trap then
            zessus_ai_spitter_02 = obj
         end
      end
   else
      zessus_ai_spitter_01 = obj
   end
end

function Cache_Models()
	Find_Object_Type("Alien_Walker_Science").Load_Assets()
	Find_Object_Type("Alien_Walker_Assembly").Load_Assets()
	Find_Object_Type("Alien_Walker_Habitat").Load_Assets()
	Find_Object_Type("HM06_Kamal_Habitat_Walker").Load_Assets()
	Find_Object_Type("HM06_Kamal_Assembly_Walker").Load_Assets()
	Find_Object_Type("HM06_Kamal_Science_Walker").Load_Assets()
	Find_Object_Type("Alien_Cylinder").Load_Assets()
	Find_Object_Type("Alien_Defiler").Load_Assets()
	Find_Object_Type("Alien_Foo_Core").Load_Assets()
	Find_Object_Type("Alien_Recon_Tank").Load_Assets()
	Find_Object_Type("Masari_Hero_Zessus").Load_Assets()
	Find_Object_Type("Masari_Disciple").Load_Assets()
	Find_Object_Type("HM06_Arecibo_Transmitter_Effect").Load_Assets()
end

function Thread_Complete_First_Objective()
   Objective_Complete(zm06_objective04)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE06_OBJECTIVE_04_COMPLETE"} )
   Remove_Radar_Blip("blip_arrival_site")
   
   while conversation_active do
      Sleep(1)
   end
   if not mission_success and not mission_failure then
      conversation_active = true
     	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE07_12"))
      conversation_active = false
   end
   
   Sleep(time_radar_sleep)
   Create_Thread("Thread_Prox_Orlok_Approaching_Transmitter_Far")
end

function Story_On_Construction_Complete(obj)

	if obj_type == object_type_arrival_site then
      orlok_arrival_site = obj
      if not arrival_site_built then
		   arrival_site_built = true	
		   Create_Thread("Thread_Complete_First_Objective")	   
		end
   elseif obj_type == object_type_spitter_turret then
      Zessus_Spitter_Trap_Identification(obj)
   elseif obj_type == object_type_assembly_walker or obj_type == object_type_habitat_walker or obj_type == object_type_science_walker then
      obj.Override_Max_Speed(.6)
	end
end

function Prox_Approaching_Kamals_Base(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Kamals_Base)
   Create_Thread("Thread_Prox_Approaching_Kamals_Base")
end

function Thread_Prox_Approaching_Kamals_Base()
   while conversation_active do
      Sleep(1)
   end
   if not mission_success and not mission_failure and not kamal_has_arrived then
      conversation_active = true
      if not arrival_site_built then
   	   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE05_11"))
      else
   	   BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE02_04"))
      end
      conversation_active = false
   end
end

function Callback_Orlok_Killed()
	if not mission_success then
		Create_Thread("Thread_Mission_Failed")
	end
end

function Callback_Orlok_Habitat_Walker_Killed()
   local kamals_units, distance, i, unit

   Create_Thread("Thread_Force_Move_Walker_01")
   Create_Thread("Thread_Force_Move_Walker_02")
   Create_Thread("Thread_Kamal_Base_Defenders")
   Create_Thread("Thread_Kamal_Attackers")
   for i, unit in pairs(list_kamal_initial_units) do
      if not TestValid(unit) then
         table.remove(list_kamal_initial_units, i)
      end
   end
   -- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
	Hunt(list_kamal_initial_units, "AntiDefault", true, true, marker_kamal_walker_science.Get_Position(), 800)
   Create_Thread("Thread_Conversation_Walkers_Retreating")
end

function Thread_Conversation_Walkers_Retreating()
   Sleep(time_objective_sleep)

   while conversation_active do
      Sleep(1)
   end
   if not mission_success and not mission_failure then
      conversation_active = true
     	BlockOnCommand(Queue_Talking_Head(pip_comm, "HIE06_SCENE07_02"))
     	BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE06_SCENE07_03"))
      conversation_active = false
   end
end

function Thread_Force_Move_Walker_01()
   if TestValid(kamal_habitat_walker) then   
      BlockOnCommand(kamal_habitat_walker.Move_To(marker_kamal_walker_defense_01.Get_Position()))
      if TestValid(kamal_habitat_walker) then
         kamal_habitat_walker.Guard_Target(marker_kamal_walker_defense_01.Get_Position())
      end
   end
end

function Thread_Force_Move_Walker_02()
   if TestValid(kamal_assembly_walker) then   
      BlockOnCommand(kamal_assembly_walker.Move_To(marker_kamal_walker_defense_02.Get_Position()))
      if TestValid(kamal_assembly_walker) then
         kamal_assembly_walker.Guard_Target(marker_kamal_walker_defense_02.Get_Position())
      end
   end
end

function Thread_Mission_Complete()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
	mission_success = true
   Stop_All_Speech()
   Flush_PIP_Queue()
	Remove_Radar_Blip("blip_kamal_rex")
   Objective_Complete(zm06_objective02)
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
	BlockOnCommand(Play_Bink_Movie("Hierarchy_Campaign_Finale",true))

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
	Play_Music("Lose_To_Alien_Event")
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,30)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ORLOK"} )
	Sleep(time_objective_sleep)
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
   Fade_Screen_Out(2)
   Sleep(2)
   Lock_Controls(0)

	Force_Victory(novus)
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

