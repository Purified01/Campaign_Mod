-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Masari_MM01.lua#58 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Masari_MM01.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Jeff_Stewart $
--
--            $Change: 87139 $
--
--          $DateTime: 2007/11/01 13:14:41 $
--
--          $Revision: #58 $
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
	Define_State("State_MM01_Act01", State_MM01_Act01)
	Define_State("State_MM01_Act02", State_MM01_Act02)
	Define_State("State_MM01_Act03", State_MM01_Act03)
	Define_State("State_MM01_Act04", State_MM01_Act04)

	-- Debug Bools
	debug_zessus_invulnerable = false
	
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
--	military.Enable_Colorization(true, COLOR_GREEN)
	
	-- Pip Heads
	pip_zessus = "ZH_Zessus_pip_head.alo"
	pip_moore = "MH_Moore_pip_Head.alo"
	pip_disciple = "ZI_Disciple_pip_head.alo"
	pip_architect = "ZI_Architect_Pip_head.alo"
	
	-- Object Types
	object_type_zessus = Find_Object_Type("Masari_Hero_Zessus")
	object_type_zessus_fire = Find_Object_Type("Masari_Hero_Zessus_Fire")
	object_type_zessus_ice = Find_Object_Type("Masari_Hero_Zessus_Ice")
	
	object_type_disciple = Find_Object_Type("Masari_Disciple")
	object_type_disciple_fire = Find_Object_Type("Masari_Disciple_Fire")
	object_type_disciple_ice = Find_Object_Type("Masari_Disciple_Ice")

	object_type_architect = Find_Object_Type("Masari_Architect")
	
	object_type_conqueror = Find_Object_Type("Masari_Enforcer")
	object_type_conqueror_ice = Find_Object_Type("Masari_Enforcer_Ice")
	object_type_conqueror_fire = Find_Object_Type("Masari_Enforcer_Fire")
	
	object_type_inquisitor = Find_Object_Type("Masari_Seeker")
	object_type_inquisitor_ice = Find_Object_Type("Masari_Seeker_Ice")
	object_type_inquisitor_fire = Find_Object_Type("Masari_Seeker_Fire")
	
	object_type_knowledge_vault = Find_Object_Type("Masari_Inventors_Lab")
	object_type_knowledge_vault_ice = Find_Object_Type("Masari_Inventors_Lab_Ice")
	object_type_knowledge_vault_fire = Find_Object_Type("Masari_Inventors_Lab_Fire")

   object_type_adepts_lab = Find_Object_Type("Masari_Adepts_Lab_Upgrade_HP")
   
   object_type_sky_guardian = Find_Object_Type("Masari_Sky_Guardian")
   object_type_sky_guardian_fire = Find_Object_Type("Masari_Sky_Guardian_Fire")
   object_type_sky_guardian_ice = Find_Object_Type("Masari_Sky_Guardian_Ice")
   
   object_type_flight_machina = Find_Object_Type("Masari_Air_Inspiration")
   object_type_flight_machina_fire = Find_Object_Type("Masari_Air_Inspiration_Fire")
   object_type_flight_machina_ice = Find_Object_Type("Masari_Air_Inspiration_Ice")
	
	object_type_matter_sifter = Find_Object_Type("Masari_Matter_Engine_Matter_Sifter")
	
	object_type_alien_grunt = Find_Object_Type("Alien_Grunt")
	object_type_gravitic_controller = Find_Object_Type("Alien_Gravitic_Manipulator_HP_Gravitic_Controller")
	object_type_alien_saucer = Find_Object_Type("Alien_Foo_Core")
	
	object_type_matter_engine = Find_Object_Type("Masari_Elemental_Collector")
	object_type_matter_engine_fire = Find_Object_Type("Masari_Elemental_Collector_Fire")
	object_type_matter_engine_ice = Find_Object_Type("Masari_Elemental_Collector_Ice")
	
	-- Unit Lists
	list_single_masari_disciple = {
	   "Masari_Disciple"
	}
	
	list_single_masari_architect = {
	   "Masari_Architect"
	}
	
	list_single_alien_pen_off = {
	   "NM02_CIVILIAN_PEN_OFF"
	}
	
	list_single_alien_grunt = {
	   "Alien_Grunt"
	}
		
	list_single_alien_reaper_drone = {
	   "Alien_Superweapon_Reaper_Turret"
	}
	
	list_single_alien_troop_walker = {
	   "TM02_CUSTOM_HABITAT_WALKER"
	}
	
   list_single_alien_assembly_walker = {
      "NM06_Custom_Assembly_Walker"
   }	
	
	list_spawn_alien_saucers = {
	   "Alien_Foo_Core",
	   "Alien_Foo_Core",
	   "Alien_Foo_Core",
	   "Alien_Foo_Core",
	   "Alien_Foo_Core",
	   "Alien_Foo_Core",
	   "Alien_Foo_Core",
	   "Alien_Foo_Core",
	   "Alien_Foo_Core",
	   "Alien_Foo_Core"
	}
	
	list_alien_base_defenders = {
	   "Alien_Grunt",
	   "Alien_Grunt",
	   "Alien_Grunt",
	   "Alien_Brute",
	   "Alien_Brute",
	   "Alien_Recon_Tank",
	   "Alien_Recon_Tank",
	   "Alien_Defiler",
	   "Alien_Defiler"
	}
	
	list_single_military_hero_moore = {
	   "Military_Hero_Randal_Moore"
	}
	
	list_single_military_marines = {
	   "Military_Team_Marines"
	}
	
	list_single_military_rocket = {
	   "Military_Team_Rocketlauncher"
	}
	
	-- Variables
	mission_success = false
	mission_failure = false
	conversation_occuring = false
	time_objective_sleep = 5
	time_radar_sleep = 2
	
	distance_approach_act01_reveal = 100
	distance_act01_fow01 = 150
	distance_approach_act01_terminal = 100
	distance_act01_disciple_hunt = 300
	distance_approach_act02_start = 150
	distance_grunt_assault = 600
	distance_alien_base_defense = 500
	distance_act02_air_warning = 700
	distance_act02_masari_destruction = 800
	distance_act03_begin = 400
	distance_act03_fow01 = 150
	distance_act04_begin = 100
	distance_act04_hunt = 1400
	distance_act04_fow01 = 200
	distance_reaper_to_destination = 100
	distance_approach_guard = 240
	
	time_saucer_orders = 5
	time_delay_saucer_strikes = 45
	time_saucer_announcement_delay = 10
	time_delay_grunt_assault = 120
	time_move_reaper_drone = 0.25
	
	time_move_alien_grunts = 30
	time_spawn_alien_grunts = 10
	total_alien_grunts = 0
	maximum_alien_grunts = 12
	grunt_team_list_in_use = false
	grunt_team_size = 3
	
	prox_act01_guards01_active = false
	prox_act01_guards02_active = false
	act01_first_gate_opened = false
	zessus_has_escaped = false
	player_notified_of_infantry_approach = false
	player_notified_of_anti_air = false
	knowledge_vault_built = false
	matter_engine_built = false
	adepts_lab_built = false
	guardian_built = false
	flight_machina_built = false
	matter_sifter_built = false
	rescue_objective_given = false
	saucers_retreating = false
	saucer_strike_delay = false
	architect_highlight_disabled = false
	act04_started = false
	announced_gate_terminal = false
	act02_disciple_invulnerable = false
	
	act01_disciple = nil
	act02_disciple = nil
	act01_architect = nil
	act02_troop_walker = nil
	
	mm01_objective03 = nil
	mm01_objective04 = nil
	mm01_objective05 = nil
	mm01_objective06 = nil
	mm01_objective07 = nil
	mm01_objective08 = nil
	
	moore = nil
	
	-- Fog of War Reveals
	act01_fow01 = nil
	act01_fow02 = nil
	
	list_act01_disciples = {}
	list_act03_disciples = {}
	list_act03_marines = {}
	list_alien_saucers = {}
	list_attack_grunts = {}
	
	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")

	show_sell_button = false
	
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through
function State_Init(message)
   local list_comm_terminals, terminal

	if message == OnEnter then

	military.Allow_AI_Unit_Behavior(false)
	novus.Allow_AI_Unit_Behavior(false)
	aliens.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
		
		Cache_Models()

		UI_Hide_Research_Button()
		UI_Hide_Sell_Button()
		
	   -- Object and Ability Locks
	   masari.Reset_Story_Locks()
	   aliens.Reset_Story_Locks()
		masari.Lock_Unit_Ability("Masari_Hero_Zessus", "Masari_Zessus_Retreat_From_Tactical_Unit_Ability", true, STORY)
		masari.Lock_Unit_Ability("Masari_Hero_Zessus", "Masari_Zessus_Teleport_Ability", true, STORY)
		masari.Lock_Unit_Ability("Masari_Hero_Zessus", "Masari_Zessus_Explode_Ability", true, STORY)
		masari.Lock_Unit_Ability("Masari_Hero_Zessus", "Masari_Zessus_Blizzard_Ability", true, STORY)
		masari.Lock_Unit_Ability("Masari_Hero_Zessus", "Masari_Zessus_Teleportation_Unit_Ability", true, STORY)
		masari.Lock_Unit_Ability("Masari_Hero_Zessus", "Masari_Zessus_Explode_Unit_Ability", true, STORY)
		masari.Lock_Unit_Ability("Masari_Hero_Zessus", "Masari_Zessus_Blizzard_Unit_Ability", true, STORY)
	   masari.Lock_Object_Type(Find_Object_Type("Masari_Hero_Zessus"), true, STORY)
	   masari.Lock_Object_Type(Find_Object_Type("Masari_Hero_Charos"), true, STORY)
	   masari.Lock_Object_Type(Find_Object_Type("Masari_Hero_Alatea"), true, STORY)
	   masari.Lock_Object_Type(Find_Object_Type("Masari_Sentry"), true, STORY)
	   masari.Lock_Object_Type(Find_Object_Type("Masari_Figment"), true, STORY)
	   masari.Lock_Object_Type(Find_Object_Type("Masari_Peacebringer"), true, STORY)
	   masari.Lock_Object_Type(Find_Object_Type("Masari_Figment"), true, STORY)
	   masari.Lock_Object_Type(Find_Object_Type("Masari_Skylord"), true, STORY)
	   masari.Lock_Object_Type(Find_Object_Type("Masari_Seer"), true, STORY)
	   masari.Lock_Object_Type(Find_Object_Type("Masari_Elemental_Controller"), true, STORY)

      player_script = aliens.Get_Script()

		-- Hint System Initialization
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		Register_Hint_Context_Scene(Get_Game_Mode_GUI_Scene())
		
		-- Comm Terminal Invunerability
		list_comm_terminals = Find_All_Objects_Of_Type("NM06_COMM_TERMINAL")
		if table.getn(list_comm_terminals) > 0 then
		   terminal = list_comm_terminals[1]
		   if TestValid(terminal) then
		      terminal.Make_Invulnerable(true)
		   end
		end

      -- Markers
		marker_list_act01_guards = Find_All_Objects_With_Hint("act01-guard")
		if table.getn(marker_list_act01_guards) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_list_act01_guards!"))
		end
		marker_list_act03_guards = Find_All_Objects_With_Hint("act03-guard")
		if table.getn(marker_list_act03_guards) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_list_act03_guards!"))
		end

		marker_act01_fow01 = Find_Hint("MARKER_GENERIC_BLUE","act01-fow01")
		if not TestValid(marker_act01_fow01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act01_fow01!"))
		end
		marker_act01_fow02 = Find_Hint("MARKER_GENERIC_BLUE","act01-fow02")
		if not TestValid(marker_act01_fow02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act01_fow02!"))
		end
		marker_act03_fow01 = Find_Hint("MARKER_GENERIC_BLUE","act03-fow01")
		if not TestValid(marker_act03_fow01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act03_fow01!"))
		end

		marker_act01_start_disciple = Find_Hint("MARKER_GENERIC_YELLOW","act01-start-disciple")
		if not TestValid(marker_act01_start_disciple) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act01_start_disciple!"))
		end
		marker_act01_start_architect = Find_Hint("MARKER_GENERIC_YELLOW","act01-start-architect")
		if not TestValid(marker_act01_start_architect) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act01_start_architect!"))
		end
		marker_act01_start_disciple_destination = Find_Hint("MARKER_GENERIC_YELLOW","act01-start-disciple-dest")
		if not TestValid(marker_act01_start_disciple_destination) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act01_start_disciple_destination!"))
		end

		marker_list_act01_disciples = Find_All_Objects_With_Hint("act01-disciple")
		if table.getn(marker_list_act01_disciples) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_list_act01_disciples!"))
		end

		marker_list_act02_reapers = Find_All_Objects_With_Hint("act02-reaper")
		if table.getn(marker_list_act02_reapers) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_list_act02_reapers!"))
		end
		marker_act02_reaper_destination = Find_Hint("MARKER_GENERIC_GREEN","act02-reaper-dest")
		if not TestValid(marker_act02_reaper_destination) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act02_reaper_destination!"))
		end
		marker_act02_saucer_entry = Find_Hint("MARKER_GENERIC_GREEN","act02-saucer-entry")
		if not TestValid(marker_act02_saucer_entry) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act02_saucer_entry!"))
		end
		marker_act02_troop_walker = Find_Hint("MARKER_GENERIC_GREEN","act02-troop-walker")
		if not TestValid(marker_act02_troop_walker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act02_troop_walker!"))
		end
		marker_act02_grunt_gather = Find_Hint("MARKER_GENERIC_GREEN","act02-grunt-gather")
		if not TestValid(marker_act02_grunt_gather) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act02_grunt_gather!"))
		end
		marker_act02_hunt_center = Find_Hint("MARKER_GENERIC_GREEN","act02-hunt-center")
		if not TestValid(marker_act02_hunt_center) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act02_hunt_center!"))
		end
		marker_act02_grunt_assault = Find_Hint("MARKER_GENERIC_GREEN","act02-grunt-assault")
		if not TestValid(marker_act02_grunt_assault) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act02_grunt_assault!"))
		end
		marker_act04_walker = Find_Hint("MARKER_GENERIC_GREEN","act04-walker")
		if not TestValid(marker_act04_walker) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act04_walker!"))
		end

		marker_act02_prox01 = Find_Hint("MARKER_GENERIC_RED","act02-prox01")
		if not TestValid(marker_act02_prox01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act02_prox01!"))
		end
		marker_act03_prox01 = Find_Hint("MARKER_GENERIC_RED","act03-prox01")
		if not TestValid(marker_act03_prox01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act03_prox01!"))
		end
		marker_act02_air_warning = Find_Hint("MARKER_GENERIC_RED","act02-air-warning")
		if not TestValid(marker_act02_air_warning) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act02_air_warning!"))
		end
		marker_act02_death = Find_Hint("MARKER_GENERIC_RED","act02-death")
		if not TestValid(marker_act02_death) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act02_death!"))
		end
				
		marker_act03_moore = Find_Hint("MARKER_GENERIC_PURPLE","act03-moore")
		if not TestValid(marker_act03_moore) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act03_moore!"))
		end
		marker_act04_marine_hunt = Find_Hint("MARKER_GENERIC_PURPLE","act04-marine-hunt")
		if not TestValid(marker_act04_marine_hunt) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_act04_marine_hunt!"))
		end
		marker_list_act03_marines = Find_All_Objects_With_Hint("act03-marines")
		if table.getn(marker_list_act03_marines) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_list_act03_marines!"))
		end
		marker_list_act03_rocket = Find_All_Objects_With_Hint("act03-rocket")
		if table.getn(marker_list_act03_rocket) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find marker_list_act03_rocket!"))
		end

		-- Pens
		pen_zessus = Find_Hint("NM02_CIVILIAN_PEN","pen-zessus")
		if not TestValid(pen_zessus) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find pen_zessus!"))
		end
		pen_act01_disciples = Find_Hint("NM02_CIVILIAN_PEN","pen-act01-disciples")
		if not TestValid(pen_act01_disciples) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find pen_act01_disciples!"))
		end
		pen_act01_gate = Find_Hint("NM02_CIVILIAN_PEN","pen-act01-gate")
		if not TestValid(pen_act01_gate) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find pen_act01_gate!"))
		end
		pen_act02_gate = Find_Hint("NM02_CIVILIAN_PEN","pen-act02-gate")
		if not TestValid(pen_act02_gate) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find pen_act02_gate!"))
		end
		pen_act03_marine01 = Find_Hint("NM02_CIVILIAN_PEN","pen-act03-marine01")
		if not TestValid(pen_act03_marine01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find pen_act03_marine01!"))
		end
		pen_act03_marine02 = Find_Hint("NM02_CIVILIAN_PEN","pen-act03-marine02")
		if not TestValid(pen_act03_marine02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find pen_act03_marine02!"))
		end
		
		-- Masari Structures
		list_masari_matter_engines = PG_Find_All_Objects_Of_Type("Masari_Elemental_Collector")
		if table.getn(list_masari_matter_engines) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_masari_matter_engines!"))
		end
		list_masari_skirmisher_portals = PG_Find_All_Objects_Of_Type("Masari_Infantry_Inspiration")
		if table.getn(list_masari_skirmisher_portals) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_masari_skirmisher_portals!"))
		end
		list_masari_machinae = PG_Find_All_Objects_Of_Type("Masari_Ground_Inspiration")
		if table.getn(list_masari_machinae) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_masari_machinae!"))
		end
		list_masari_interpreters = PG_Find_All_Objects_Of_Type("Masari_Natural_Interpreter")
		if table.getn(list_masari_interpreters) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_masari_interpreters!"))
		end
		masari_foundation = Find_Hint("Masari_Foundation","masari-foundation")
		if not TestValid(masari_foundation) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find masari_foundation!"))
		end
		saucer_target_01 = Find_Hint("Masari_Natural_Interpreter", "saucer-target01")
		if not TestValid(saucer_target_01) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find saucer_target_01!"))
		end
		saucer_target_02 = Find_Hint("Masari_Elemental_Collector", "saucer-target02")
		if not TestValid(saucer_target_02) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find saucer_target_02!"))
		end
		saucer_target_03 = Find_Hint("Masari_Infantry_Inspiration", "saucer-target03")
		if not TestValid(saucer_target_03) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find saucer_target_03!"))
		end
		saucer_target_04 = Find_Hint("Masari_Ground_Inspiration", "saucer-target04")
		if not TestValid(saucer_target_04) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find saucer_target_04!"))
		end
		masari_hint_matter_engine = Find_Hint("Masari_Elemental_Collector","hint-collector")
		if not TestValid(masari_hint_matter_engine) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find masari_hint_matter_engine!"))
		end
		masari_hint_interpreter = Find_Hint("Masari_Natural_Interpreter","hint-interpreter")
		if not TestValid(masari_hint_interpreter) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find masari_hint_interpreter!"))
		end
		masari_hint_skirmisher = Find_Hint("Masari_Infantry_Inspiration","hint-infantry")
		if not TestValid(masari_hint_skirmisher) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find masari_hint_skirmisher!"))
		end
		masari_hint_machina = Find_Hint("Masari_Ground_Inspiration","hint-ground")
		if not TestValid(masari_hint_machina) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find masari_hint_machina!"))
		end
		
		-- Alien Structures
		list_gravitic_turrets = Find_All_Objects_With_Hint("gravitic")
		if table.getn(list_gravitic_turrets) <= 0 then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find list_gravitic_turrets!"))
		end
		act03_spitter = Find_Hint("Alien_Radiation_Spitter","act03-spitter")
		if not TestValid(act03_spitter) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find act03_spitter!"))
		end
		
      -- Masari Hero Zessus
		hero = Find_First_Object("Masari_Hero_Zessus")
		if not TestValid(hero) then
			_CustomScriptMessage("RickLog.txt", string.format("ERROR - Cannot find hero!"))
		else
		   if debug_zessus_invulnerable then
		      hero.Make_Invulnerable(true)
		   end
		end
		
		Set_Next_State("State_MM01_Act01")
	end
end

function State_MM01_Act01(message)
   local spawn_list, i, marker, unit, structure, structure_health, credit_total, credits
   
   if message == OnEnter then
   
      -- Zessus
		hero.Register_Signal_Handler(Callback_Zessus_Killed, "OBJECT_HEALTH_AT_ZERO")
		
		-- Zessus 800 from 2500 = -.68
	   hero.Add_Attribute_Modifier("Universal_Damage_Modifier", -.68)	   

		-- Initial Starting Credits
		credit_total = 1000
		credits = masari.Get_Credits()
      if credits > credit_total then
         credits = (credits - credit_total) * -1
         masari.Give_Money(credits)
      elseif credits < credit_total then
         credits = credit_total - credits
         masari.Give_Money(credits)
      end
		aliens.Give_Money(1000000)

      -- Initial Starting Units
		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
		spawn_list = SpawnList(list_single_masari_architect, marker_act01_start_architect, masari, false, true, true)
   	act01_architect = spawn_list[1]
   	if TestValid(act01_architect) then
         act01_architect.Teleport_And_Face(marker_act01_start_architect)
         act01_architect.Set_Selectable(false)
         act01_architect.Prevent_All_Fire(true)
         act01_architect.Make_Invulnerable(true)
      end
      
		spawn_list = SpawnList(list_single_masari_disciple, marker_act01_start_disciple, masari, false, true, true)
      act01_disciple = spawn_list[1]
		
      for i, marker in pairs (marker_list_act01_disciples) do
         spawn_list = SpawnList(list_single_masari_disciple, marker, masari, false, true, true)
         unit = spawn_list[1]
         if TestValid(unit) then
            unit.Teleport_And_Face(marker)
            unit.Set_Selectable(false)
            unit.Prevent_All_Fire(true)
            unit.Make_Invulnerable(true)
            table.insert(list_act01_disciples, unit)
         end
      end
      
      -- Act01 Guards
      for i, marker in pairs (marker_list_act01_guards) do
         spawn_list = SpawnList(list_single_alien_grunt, marker, aliens, false, true, false)
         unit = spawn_list[1]
         if TestValid(unit) then
            unit.Teleport_And_Face(marker)
            unit.Guard_Target(unit.Get_Position())
            Register_Prox(unit, Prox_Attack_Move_Guard, distance_approach_guard, masari)
         end
      end
      
      -- Proximities
		Register_Prox(marker_act01_fow01, Prox_Act01_Guards01, distance_approach_act01_terminal, aliens)
		Register_Prox(marker_act01_fow02, Prox_Act01_Guards02, distance_approach_act01_terminal, aliens)
		Register_Prox(marker_act01_fow01, Prox_Act01_Zessus01, distance_approach_act01_terminal, masari)
		Register_Prox(marker_act01_fow02, Prox_Act01_Zessus02, distance_approach_act01_terminal, masari)
		Register_Prox(marker_act02_prox01, Prox_Act02_Start, distance_approach_act02_start, masari)
      
      -- Masari Structures
      for i, structure in pairs(list_masari_matter_engines) do
         if TestValid(structure) then
            structure_health = structure.Get_Health_Value() * 0.75
            structure.Take_Damage(structure_health, "Damage_Unconditional")
            structure.Change_Owner(neutral)
         end
      end
      for i, structure in pairs(list_masari_skirmisher_portals) do
         if TestValid(structure) then
            structure_health = structure.Get_Health_Value() * 0.75
            structure.Take_Damage(structure_health, "Damage_Unconditional")
            structure.Change_Owner(neutral)
         end
      end
      for i, structure in pairs(list_masari_machinae) do
         if TestValid(structure) then
            structure_health = structure.Get_Health_Value() * 0.75
            structure.Take_Damage(structure_health, "Damage_Unconditional")
            structure.Change_Owner(neutral)
         end
      end
      for i, structure in pairs(list_masari_interpreters) do
         if TestValid(structure) then
            structure_health = structure.Get_Health_Value() * 0.75
            structure.Take_Damage(structure_health, "Damage_Unconditional")
            structure.Change_Owner(neutral)
         end
      end
      if TestValid(masari_foundation) then
         structure_health = masari_foundation.Get_Health_Value() * 0.5
         masari_foundation.Take_Damage(structure_health, "Damage_Unconditional")
         masari_foundation.Change_Owner(neutral)
      end
      Fade_Out_Music()   
      Create_Thread("Thread_Intro_Conversation")
   end
end

function State_MM01_Act02(message)
   local spawn_list, i, marker, unit, reaper_drone
   
   if message == OnEnter then
      
      -- Reaper Drones
     	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
     	for i, marker in pairs (marker_list_act02_reapers) do
        	spawn_list = SpawnList(list_single_alien_reaper_drone, marker, aliens, false, true, false)
        	reaper_drone = spawn_list[1]
        	if TestValid(reaper_drone) then
        	   Create_Thread("Thread_Move_Reaper_Drone",reaper_drone)
        	end
     	end
     	      
      -- Proximities
		Register_Prox(marker_act02_air_warning, Prox_Act02_Air_Warning, distance_act02_air_warning, aliens)
		Register_Prox(marker_act02_death, Prox_Act02_Death, distance_act02_masari_destruction, masari)
	
	   --added by JGS 6/21/07 re-enables the sell button after the base changes ownership	
	   UI_Show_Sell_Button()
		show_sell_button = true
	
      Create_Thread("Thread_Act02_Conversation")
   end
end

function State_MM01_Act03(message)
   if message == OnEnter then

      -- Alliegiances
		military.Make_Ally(masari)
		masari.Make_Ally(military)

      -- Proximities
   	Register_Prox(marker_act03_fow01, Prox_Act03_Terminal, distance_approach_act01_terminal, masari)
      
      -- Masari Disciple Prisoners
      for i, marker in pairs(marker_list_act03_marines) do
         spawn_list = SpawnList(list_single_masari_disciple, marker, masari, false, true, false)
         unit = spawn_list[1]
         if TestValid(unit) then
            unit.Make_Invulnerable(true)
            unit.Prevent_All_Fire(true)
            unit.Prevent_Opportunity_Fire(true)
            unit.Set_Selectable(false)
            table.insert(list_act03_disciples, unit)
         end
      end
      for i, marker in pairs(marker_list_act03_rocket) do
         spawn_list = SpawnList(list_single_masari_disciple, marker, masari, false, true, false)
         unit = spawn_list[1]
         if TestValid(unit) then
            unit.Make_Invulnerable(true)
            unit.Prevent_All_Fire(true)
            unit.Prevent_Opportunity_Fire(true)
            unit.Set_Selectable(false)
            table.insert(list_act03_disciples, unit)
         end
      end
      Create_Thread("Thread_Act03_Conversation")
   end
end

function State_MM01_Act04(message)
   local i, unit
   
   if message == OnEnter then
      
      -- Marines
      if TestValid(moore) then
         moore.Make_Invulnerable(false)
         moore.Prevent_All_Fire(false)
         moore.Prevent_Opportunity_Fire(false)
         moore.Set_Cannot_Be_Killed(true)
      end
      for i, unit in pairs(list_act03_marines) do
         if TestValid(unit) then
            unit.Make_Invulnerable(false)
            unit.Prevent_All_Fire(false)
            unit.Prevent_Opportunity_Fire(false)
         end
      end
      table.insert(list_act03_marines, moore)
      for i, unit in pairs(list_act03_disciples) do
         if TestValid(unit) then
            unit.Make_Invulnerable(false)
            unit.Prevent_All_Fire(false)
            unit.Prevent_Opportunity_Fire(false)
            unit.Set_Selectable(true)
         end
      end
      for i, unit in pairs (list_gravitic_turrets) do
         if TestValid(unit) then
            unit.Take_Damage(10000)
         end
      end
      
      Create_Thread("Thread_Act04_Conversation")
   end
end


--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script

function Thread_Intro_Conversation()
	
	Fade_Out_Music()
   Fade_Screen_Out(0)
   Lock_Controls(1)
   BlockOnCommand(Play_Bink_Movie("Masari_Campaign_Intro",true))

   local spawn_list, object
   
	Point_Camera_At(hero)
   Sleep(1)
   Start_Cinematic_Camera()
   Letter_Box_In(0.1)
   Transition_Cinematic_Target_Key(hero, 0, 0, 0, 0, 0, 0, 0, 0)
   Transition_Cinematic_Camera_Key(hero, 0, 200, 55, 65, 1, 0, 0, 0)
   Transition_To_Tactical_Camera(5)
   Fade_Screen_In(1)
   
   -- Disciple shuts off barrier and approaches Zessus.
   if TestValid(act01_disciple) then
      BlockOnCommand(act01_disciple.Move_To(marker_act01_start_disciple_destination.Get_Position()))
   end
	if TestValid(pen_zessus) then
   	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
   	spawn_list = SpawnList(list_single_alien_pen_off, pen_zessus, neutral, false, true, false)
   	object = spawn_list[1]
   	object.Teleport_And_Face(pen_zessus)
   	pen_zessus.Despawn()
   	pen_zessus = object
	end
   
   -- Zessus Disciple Starting Conversation
	BlockOnCommand(Queue_Talking_Head(pip_disciple, "MAS01_SCENE02_06"))
	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE02_01"))
	BlockOnCommand(Queue_Talking_Head(pip_disciple, "MAS01_SCENE02_02"))
   Letter_Box_Out(1)
   Lock_Controls(0)
   End_Cinematic_Camera()
   act01_fow02 = FogOfWar.Reveal(masari, marker_act01_fow02, distance_act01_fow01, distance_act01_fow01)
	BlockOnCommand(Queue_Talking_Head(pip_disciple, "MAS01_SCENE02_07"))
	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE02_03"))
	BlockOnCommand(Queue_Talking_Head(pip_disciple, "MAS01_SCENE02_04"))
	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE02_05"))
   
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_01_NEW"} )
   Sleep(time_objective_sleep)
   mm01_objective01 = Add_Objective("TEXT_SP_MISSION_MAS01_OBJECTIVE_01")
   Sleep(time_radar_sleep)
  	Add_Radar_Blip(marker_act01_fow02, "DEFAULT", "blip-terminal2")
	marker_act01_fow02.Highlight(true)
	marker_act01_fow02_ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), marker_act01_fow02, neutral)
  	
   Sleep(time_radar_sleep)
   -- Add_Independent_Hint(HINT_MM01_MODES)
   Add_Attached_GUI_Hint(PG_GUI_HINT_ELEMENTAL_MODE_ICON, false, HINT_MM01_MODES)
end

function Thread_Construct_Grunts()
	local i
	
	Sleep(time_delay_grunt_assault)
	
	while not mission_success and not mission_failure do
		if total_alien_grunts < maximum_alien_grunts then
			if TestValid(act02_troop_walker) then
				if act02_troop_walker.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(act02_troop_walker, object_type_alien_grunt, 1, aliens)
				end
			end
		end
		
		Sleep(time_spawn_alien_grunts)
		
	end
end

function Thread_Act02_Conversation()
   local i, structure, unit, spawn_list

   -- Objectives
   Objective_Complete(mm01_objective01)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_01_COMPLETE"} )

   -- Masari Foundation and Matter Engines
   if TestValid(masari_foundation) then
      masari_foundation.Change_Owner(masari)
   end
   for i, structure in pairs(list_masari_matter_engines) do
      if TestValid(structure) then
         structure.Change_Owner(masari)
      end
   end

   -- Architect and Disciple Fixup
   zessus_has_escaped = true
   if TestValid(act01_architect) then
      act01_architect.Set_Selectable(true)
      act01_architect.Set_Cannot_Be_Killed(false)
      unit = act01_architect
   	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
      spawn_list = SpawnList(list_single_masari_architect, act01_architect, masari, false, true, true)
      act01_architect = spawn_list[1]
      if TestValid(act01_architect) then
         act01_architect.Teleport_And_Face(unit)
         act01_architect.Highlight_Small(true)
         act01_architect.Move_To(marker_act02_prox01.Get_Position())
      end
      unit.Despawn()
   end
   if TestValid(act02_disciple) then
      act02_disciple_invulnerable = true
      act02_disciple.Make_Invulnerable(false)
      act02_disciple.Set_Cannot_Be_Killed(false)
   end
   
   BlockOnCommand(Queue_Talking_Head(pip_disciple, "MAS01_SCENE05_01"))
   
   -- Masari Skirmisher Portals
   for i, structure in pairs(list_masari_skirmisher_portals) do
      if TestValid(structure) then
         structure.Change_Owner(masari)
      end
   end
   
  	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE05_04"))

   -- Masari Machinae
   for i, structure in pairs(list_masari_machinae) do
      if TestValid(structure) then
         structure.Change_Owner(masari)
      end
   end
  	
  	BlockOnCommand(Queue_Talking_Head(pip_architect, "MAS01_SCENE05_03"))
   
   -- Masari Natural Interpeters
   for i, structure in pairs(list_masari_interpreters) do
      if TestValid(structure) then
         structure.Change_Owner(masari)
      end
   end

   -- Objectives
   if not rescue_objective_given then
	   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_02_NEW"} )
      Sleep(time_objective_sleep)
      mm01_objective02 = Add_Objective("TEXT_SP_MISSION_MAS01_OBJECTIVE_02")
   end

  	--Sleep(time_objective_sleep)
  	
	if not mission_success and not mission_failure then
     	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE06_05"))
   end
   
	Create_Thread("Thread_Alien_Saucer_Team")
	Create_Thread("Thread_Toggle_Alien_Saucer_Strike")
   
  	Sleep(time_objective_sleep)
  	
	if not mission_success and not mission_failure then
     	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE06_08"))
   end

  	-- Troop Walker
  	spawn_list = SpawnList(list_single_alien_troop_walker, marker_act02_troop_walker, aliens, false, true, false)
  	act02_troop_walker = spawn_list[1]
  	if TestValid(act02_troop_walker) then
  	   act02_troop_walker.Teleport_And_Face(marker_act02_troop_walker)
     	act02_troop_walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Callback_Act02_Troop_Walker_Killed") 
     	Create_Thread("Thread_Construct_Grunts")
     	Create_Thread("Thread_Move_Alien_Grunts")
  	end
	
	Sleep(time_objective_sleep)
	
	if TestValid(act01_architect) then
	   Add_Attached_Hint(act01_architect, HINT_BUILT_MASARI_ARCHITECT)
	end

   Sleep(time_objective_sleep)
   
  	-- Alien Base Defenders
  	-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
  	spawn_list = SpawnList(list_alien_base_defenders, marker_act02_hunt_center, aliens, false, true, false)
  	Hunt(spawn_list, "AntiDefault", true, true, marker_act02_hunt_center, distance_alien_base_defense)
  	spawn_list = SpawnList(list_alien_base_defenders, marker_act02_hunt_center, aliens, false, true, false)
  	Hunt(spawn_list, "AntiDefault", true, true, marker_act02_hunt_center, distance_alien_base_defense)

   Sleep(time_objective_sleep)

   -- Military Forces and Disciple Allies
   spawn_list = SpawnList(list_single_military_hero_moore, marker_act03_moore, military, false, true, false)
   moore = spawn_list[1]
   if TestValid(moore) then
      moore.Make_Invulnerable(true)
      moore.Prevent_All_Fire(true)
      moore.Prevent_Opportunity_Fire(true)
      moore.Teleport_And_Face(marker_act03_moore)
   end
   for i, marker in pairs(marker_list_act03_marines) do
      spawn_list = SpawnList(list_single_military_marines, marker, military, false, true, false)
      unit = spawn_list[1]
      if TestValid(unit) then
         unit.Make_Invulnerable(true)
         unit.Prevent_All_Fire(true)
         unit.Prevent_Opportunity_Fire(true)
         table.insert(list_act03_marines, unit)
      end
   end

   Sleep(time_objective_sleep)
   
   for i, marker in pairs(marker_list_act03_rocket) do
      spawn_list = SpawnList(list_single_military_rocket, marker, military, false, true, false)
      unit = spawn_list[1]
      if TestValid(unit) then
         unit.Make_Invulnerable(true)
         unit.Prevent_All_Fire(true)
         unit.Prevent_Opportunity_Fire(true)
         table.insert(list_act03_marines, unit)
      end
   end      
	
end

function Thread_Act03_Conversation()
   act03_fow01 = FogOfWar.Reveal(masari, marker_act03_fow01, distance_act03_fow01, distance_act03_fow01)
   marker_act03_fow01.Highlight(true)
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
      BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE06_14"))
   end
	conversation_occuring = false
   if not rescue_objective_given then
	   if not mission_success and not mission_failure then
         rescue_objective_given = true
         Create_Thread("Thread_Give_Rescue_Objective")
      end
   end
end

function Thread_Act04_Conversation()
   local spawn_list, unit, walker
   
   Objective_Complete(mm01_objective08)
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_08_COMPLETE"} )
   Remove_Radar_Blip("blip_objective08")
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
      BlockOnCommand(Queue_Talking_Head(pip_moore, "MAS01_SCENE07_01"))
   end
	if not mission_success and not mission_failure then
      BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE07_02"))
   end
	if not mission_success and not mission_failure then
      BlockOnCommand(Queue_Talking_Head(pip_moore, "MAS01_SCENE07_03"))
   end
	if not mission_success and not mission_failure then
      BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE07_04"))
   end
	if not mission_success and not mission_failure then
      BlockOnCommand(Queue_Talking_Head(pip_moore, "MAS01_SCENE07_05"))
   end
	conversation_occuring = false
	
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	spawn_list = SpawnList(list_single_alien_assembly_walker, marker_act04_walker, aliens, false, true, false)
	walker = spawn_list[1]
	if TestValid(walker) then
     	walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Callback_Act04_Assembly_Walker_Killed") 
     	-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
     	Hunt(spawn_list, "AntiDefault", true, false, marker_act04_marine_hunt, distance_act04_hunt)
	end 
	spawn_list = SpawnList(list_spawn_alien_saucers, marker_act04_walker, aliens, false, true, false)
  	Hunt(spawn_list, "AntiDefault", true, false, marker_act04_marine_hunt, distance_act04_hunt)
  	spawn_list = SpawnList(list_alien_base_defenders, marker_act04_walker, aliens, false, true, false)
  	Hunt(spawn_list, "AntiDefault", true, false, marker_act04_marine_hunt, distance_act04_hunt)
  	
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
      BlockOnCommand(Queue_Talking_Head(pip_disciple, "MAS01_SCENE07_07"))
   end
  	if TestValid(walker) then
      act01_fow01 = FogOfWar.Reveal(masari, walker, distance_act04_fow01, distance_act04_fow01)
      walker.Highlight(true)
   end
	if not mission_success and not mission_failure then
      BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE07_08"))
   end
	if not mission_success and not mission_failure then
      BlockOnCommand(Queue_Talking_Head(pip_moore, "MAS01_SCENE07_09"))
   end
	conversation_occuring = false
  	Hunt(list_act03_marines, "AntiDefault", true, false, marker_act04_marine_hunt, distance_act04_hunt)
	
	Sleep(time_radar_sleep)
   if not mission_success and not mission_failure then
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_09_NEW"} )
	   Sleep(time_objective_sleep)
      mm01_objective09 = Add_Objective("TEXT_SP_MISSION_MAS01_OBJECTIVE_09")
   end
   Sleep(time_radar_sleep)
   if TestValid(walker) then
	   Add_Radar_Blip(walker, "DEFAULT", "blip_final_walker")
	end
end

function Thread_Toggle_Alien_Saucer_Strike()
   Sleep(time_saucer_orders)
   while not mission_success and not mission_failure do
      Sleep(time_delay_saucer_strikes)
      if saucer_strike_delay then
         saucer_strike_delay = false
      else
         saucer_strike_delay = true
      end
   end
end

function Thread_Move_Reaper_Drone(obj)
   local movement_complete = false
   local distance
   
   while not movement_complete do
      if TestValid(obj) then
         distance = obj.Get_Distance(marker_act02_reaper_destination)
         if distance > distance_reaper_to_destination then
            obj.Move_To(marker_act02_reaper_destination.Get_Position())
         else
            movement_complete = true
         end
      else
         movement_complete = true
      end
      Sleep(time_move_reaper_drone)
   end
end

function Thread_Alien_Saucer_Team()
   local i, unit, spawn_list, saucer_target
   
   while not mission_success and not mission_failure do
   
      Sleep(time_saucer_orders)
      
      if table.getn(list_alien_saucers) > 0 then
         for i, unit in pairs (list_alien_saucers) do
            if not TestValid(unit) then
               table.remove(list_alien_saucers, i)
            end
         end
      end
      
      if table.getn(list_alien_saucers) > 0 then
         -- Find the remaining target building if there is one.
         if TestValid(saucer_target_01) then
            saucer_target = saucer_target_01
         elseif TestValid(saucer_target_02) then
            saucer_target = saucer_target_02
         elseif TestValid(saucer_target_03) then
            saucer_target = saucer_target_03
         elseif TestValid(saucer_target_04) then
            saucer_target = saucer_target_04
         else
            saucers_retreating = true
            saucer_target = nil
         end
         for i, unit in pairs (list_alien_saucers) do
            if TestValid(unit) then
               if saucers_retreating then
                  Create_Thread("Thread_Final_Strike_Saucer_Movement",unit)
               else
                  if not saucer_strike_delay then
                     unit.Attack_Move(saucer_target)
                  else
                     unit.Move_To(marker_act02_saucer_entry.Get_Position())
                  end
               end
            end
         end
      else
         -- There are no saucers currently. Delay until the next strike time, then spawn some more.
         Sleep(time_delay_saucer_strikes)
      	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
      	list_alien_saucers = SpawnList(list_spawn_alien_saucers, marker_act02_saucer_entry, aliens, false, true, false)
      end
   end
end

function Prox_Act02_Air_Warning(prox_obj, trigger_obj)
   local obj_type
   
   obj_type = trigger_obj.Get_Type()
   if obj_type == object_type_alien_saucer then
  	   prox_obj.Cancel_Event_Object_In_Range(Prox_Act02_Air_Warning)
      Create_Thread("Thread_Announce_Saucer_Attack")
   end
end

function Prox_Act02_Death(prox_obj, trigger_obj)
   Create_Thread("Thread_Act02_Death",trigger_obj)
end

function Thread_Act02_Death(obj)
   Sleep(time_objective_sleep)
   if TestValid(obj) then
      obj.Take_Damage(9999)
   end
end

function Thread_Announce_Saucer_Attack()
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_disciple, "MAS01_SCENE06_09"))
   end	
	if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE06_10"))
  	end
	conversation_occuring = false
end

function Prox_Act03_Terminal(prox_obj, trigger_obj)
   prox_obj.Cancel_Event_Object_In_Range(Prox_Act03_Terminal)
   Create_Thread("Thread_Prox_Act03_Terminal")
end

function Thread_Prox_Act03_Terminal(prox_obj)
   local i, unit, spawn_list, object
   
  	if TestValid(pen_act03_marine01) then
    	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
 	   spawn_list = SpawnList(list_single_alien_pen_off, pen_act03_marine01, neutral, false, true, false)
  	   object = spawn_list[1]
  	   object.Teleport_And_Face(pen_act03_marine01)
  	   pen_act03_marine01.Despawn()
  	   pen_act03_marine01 = object
   end
  	if TestValid(pen_act03_marine02) then
    	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
 	   spawn_list = SpawnList(list_single_alien_pen_off, pen_act03_marine02, neutral, false, true, false)
  	   object = spawn_list[1]
  	   object.Teleport_And_Face(pen_act03_marine02)
  	   pen_act03_marine02.Despawn()
  	   pen_act03_marine02 = object
   end
   act03_fow01.Undo_Reveal()
   marker_act03_fow01.Highlight(false)
   if not act04_started then
      act04_started = true
  	   Set_Next_State("State_MM01_Act04")
   end
end

function Thread_Final_Strike_Saucer_Movement(obj)
   if TestValid(obj) then
      BlockOnCommand(obj.Move_To(marker_act02_saucer_entry.Get_Position()))
   end
   
   Sleep(time_delay_saucer_strikes)
   if TestValid(obj) then
      obj.Despawn()
   end
end

function Thread_Notify_Of_Infantry_Approach()
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
     	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE06_04"))
   end
	conversation_occuring = false
end

function Thread_Notify_Of_Anti_Air()
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
     	BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE06_03"))
   end
   conversation_occuring = false
end

function Thread_Complete_Matter_Engine_Objective(obj)
   if not mission_success and not mission_failure then
      Objective_Complete(mm01_objective02)
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_02_COMPLETE"} )
      Sleep(time_objective_sleep)
      if not mission_success and not mission_failure and not knowledge_vault_built and not rescue_objective_given then
  	      BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE06_06"))
  	   end
      if not mission_success and not mission_failure and not knowledge_vault_built and not rescue_objective_given then
   	   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_03_NEW"} )
  	      Sleep(time_objective_sleep)
  	   end
      if not mission_success and not mission_failure and not knowledge_vault_built and not rescue_objective_given then
         mm01_objective03 = Add_Objective("TEXT_SP_MISSION_MAS01_OBJECTIVE_03")
   	end
   end
end

function Thread_Complete_Knowledge_Vault_Objective(obj)
   if mm01_objective03 ~= nil then
   	if not mission_success and not mission_failure then
         Objective_Complete(mm01_objective03)
         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_03_COMPLETE"} )
         Sleep(time_objective_sleep)
      	if not mission_success and not mission_failure and not adepts_lab_built and not rescue_objective_given then
	         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_04_NEW"} )
	  	      Sleep(time_objective_sleep)
	  	   end
      	if not mission_success and not mission_failure and not adepts_lab_built and not rescue_objective_given then
            mm01_objective04 = Add_Objective("TEXT_SP_MISSION_MAS01_OBJECTIVE_04")
   	      if TestValid(obj) then
        	      Add_Radar_Blip(obj, "Default_Beacon_Placement", "blip-act02-vault")
   	         obj.Highlight(true)
   	         Sleep(time_objective_sleep)
   	         if TestValid(obj) then
   	            obj.Highlight(false)
   	         end
   	      end
   	   end
   	end
   else
      if not rescue_objective_given then
      	if not mission_success and not mission_failure then
            rescue_objective_given = true
            Create_Thread("Thread_Give_Rescue_Objective")
         end
      end
  	end
end

function Thread_Complete_Adepts_Lab_Objective()
   if mm01_objective04 ~= nil then
	   if not mission_success and not mission_failure then
         Objective_Complete(mm01_objective04)
         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_04_COMPLETE"} )
	      while conversation_occuring do
		      Sleep(1)
	      end
   	   if not mission_success and not mission_failure and not guardian_built and not rescue_objective_given then
	         conversation_occuring = true
     	      BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE06_07"))
     	      conversation_occuring = false
     	   end
   	   if not mission_success and not mission_failure and not guardian_built and not rescue_objective_given then
            Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_05_NEW_ALT"} )
	  	      Sleep(time_objective_sleep)
	  	   end
   	   if not mission_success and not mission_failure and not guardian_built and not rescue_objective_given then
            mm01_objective05 = Add_Objective("TEXT_SP_MISSION_MAS01_OBJECTIVE_05_ALT")
	      end
	   end
   else
      if not rescue_objective_given then
   	   if not mission_success and not mission_failure then
            rescue_objective_given = true
            Create_Thread("Thread_Give_Rescue_Objective")
         end
      end
   end
end

function Thread_Complete_Guardian_Objective()
   if mm01_objective05 ~= nil then
	   if not mission_success and not mission_failure then
         Objective_Complete(mm01_objective05)
         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_05_COMPLETE_ALT"} )
         Sleep(time_objective_sleep)
	      while conversation_occuring do
		      Sleep(1)
	      end
   	   if not mission_success and not mission_failure and not flight_machina_built and not rescue_objective_given then
	         conversation_occuring = true
  	         BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE06_11"))
	         conversation_occuring = false
	      end
   	   if not mission_success and not mission_failure and not flight_machina_built and not rescue_objective_given then
	         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_06_NEW"} )
	  	      Sleep(time_objective_sleep)
	  	   end
   	   if not mission_success and not mission_failure and not flight_machina_built and not rescue_objective_given then
            mm01_objective06 = Add_Objective("TEXT_SP_MISSION_MAS01_OBJECTIVE_06")
	      end
	   end
	else
      if not rescue_objective_given then
   	   if not mission_success and not mission_failure then
            rescue_objective_given = true
            Create_Thread("Thread_Give_Rescue_Objective")
         end
      end
   end
end

function Thread_Complete_Flight_Machina_Objective()
   if mm01_objective06 ~= nil then
	   if not mission_success and not mission_failure then
         Objective_Complete(mm01_objective06)
         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_06_COMPLETE"} )
         Sleep(time_objective_sleep)
	      while conversation_occuring do
		      Sleep(1)
	      end
   	   if not mission_success and not mission_failure and not matter_sifter_built and not rescue_objective_given then
	         conversation_occuring = true
  	         BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE06_12"))
	         conversation_occuring = false
	      end
   	   if not mission_success and not mission_failure and not matter_sifter_built and not rescue_objective_given then
	         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_07_NEW"} )
	         Sleep(time_objective_sleep)
	      end
   	   if not mission_success and not mission_failure and not matter_sifter_built and not rescue_objective_given then
            mm01_objective07 = Add_Objective("TEXT_SP_MISSION_MAS01_OBJECTIVE_07")
	      end
	   end
   else
      if not rescue_objective_given then
   	   if not mission_success and not mission_failure then
            rescue_objective_given = true
            Create_Thread("Thread_Give_Rescue_Objective")
         end
      end
   end
end

function Thread_Complete_Matter_Sifter_Objective()
   if mm01_objective07 ~= nil then
  	   if not mission_success and not mission_failure then
         Objective_Complete(mm01_objective07)
         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_07_COMPLETE"} )
         Sleep(time_objective_sleep)
      end
   end
   if not rescue_objective_given then
  	   if not mission_success and not mission_failure then
         rescue_objective_given = true
         Create_Thread("Thread_Give_Rescue_Objective")
      end
   end
end

function Thread_Give_Rescue_Objective()
   while conversation_occuring do
      Sleep(1)
   end
   if not mission_success and not mission_failure then
      conversation_occuring = true
      BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE06_13"))
      conversation_occuring = false
   end
   if not mission_success and not mission_failure then
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_08_NEW"} )
         Sleep(time_objective_sleep)
      mm01_objective08 = Add_Objective("TEXT_SP_MISSION_MAS01_OBJECTIVE_08")
	   Add_Radar_Blip(marker_act03_fow01, "DEFAULT", "blip_objective08")
   end
end


--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script

function Story_On_Construction_Complete(obj)
   local obj_type
   
   if TestValid(obj) then
      if obj.Get_Owner().Get_Faction_Name()=="MASARI" then
         if not architect_highlight_disabled then
            architect_highlight_disabled = true
            act01_architect.Highlight_Small(false)
         end
      end
      obj_type = obj.Get_Type()
      if obj_type == object_type_conqueror or obj_type == object_type_conqueror_fire or obj_type == object_type_conqueror_ice then
         if not player_notified_of_infantry_approach then
            player_notified_of_infantry_approach = true
            Create_Thread("Thread_Notify_Of_Infantry_Approach")
         end
      elseif obj_type == object_type_inquisitor or obj_type == object_type_inquisitor_fire or obj_type == object_type_inquisitor_ice then
         if not player_notified_of_anti_air then
            player_notified_of_anti_air = true
            Create_Thread("Thread_Notify_Of_Anti_Air")
         end
      elseif obj_type == object_type_knowledge_vault or obj_type == object_type_knowledge_vault_ice or obj_type == object_type_knowledge_vault_fire then
         if not knowledge_vault_built then
            knowledge_vault_built = true
            Create_Thread("Thread_Complete_Knowledge_Vault_Objective",obj)
         end
      elseif obj_type == object_type_matter_engine or obj_type == object_type_matter_engine_fire or obj_type == object_type_matter_engine_ice then
         if not matter_engine_built then
            matter_engine_built = true
            Create_Thread("Thread_Complete_Matter_Engine_Objective",obj)
         end
      elseif obj_type == object_type_adepts_lab then
         if not adepts_lab_built then
            adepts_lab_built = true
            Create_Thread("Thread_Complete_Adepts_Lab_Objective")
         end
      elseif obj_type == object_type_sky_guardian or obj_type == object_type_sky_guardian_ice or obj_type == object_type_sky_guardian_fire then
         if not guardian_built then
            guardian_built = true
            Create_Thread("Thread_Complete_Guardian_Objective")
         end
      elseif obj_type == object_type_flight_machina or obj_type == object_type_flight_machina_fire or obj_type == object_type_flight_machina_ice then
         if not flight_machina_built then
            flight_machina_built = true
            Create_Thread("Thread_Complete_Flight_Machina_Objective")
         end
      elseif obj_type == object_type_matter_sifter then
         if not matter_sifter_built then
            matter_sifter_built = true
            Create_Thread("Thread_Complete_Matter_Sifter_Objective")
         end
      elseif obj_type == object_type_alien_grunt then
			Create_Thread("Thread_Group_Alien_Grunts", obj)
			total_alien_grunts = total_alien_grunts + 1
			obj.Register_Signal_Handler(Callback_Alien_Grunt_Killed, "OBJECT_HEALTH_AT_ZERO")
      end
   end
end

function Prox_Act03_Begin(prox_obj, trigger_obj)
  	prox_obj.Cancel_Event_Object_In_Range(Prox_Act03_Begin)
  	Set_Next_State("State_MM01_Act03")
end

function Prox_Attack_Move_Guard(prox_obj, trigger_obj)
  	prox_obj.Cancel_Event_Object_In_Range(Prox_Attack_Move_Guard)
  	prox_obj.Attack_Move(trigger_obj)
end

function Thread_Group_Alien_Grunts(obj)
	if TestValid(obj) then
		obj.Attack_Move(marker_act02_grunt_gather.Get_Position())
		grunt_team_list_in_use = true
		table.insert(list_attack_grunts, obj)
		grunt_team_list_in_use = false
	end
end

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

function Thread_Move_Alien_Grunts()
	while not mission_success and not mission_failure do
	
		Sleep (time_move_alien_grunts)
		
		if table.getn(list_attack_grunts) >= grunt_team_size then
			while grunt_team_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_attack_grunts) then
           	-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
           	Hunt(list_attack_grunts, "AntiDefault", true, true, marker_act02_grunt_assault.Get_Position(), distance_grunt_assault)
			end
			list_attack_grunts = {}
		end
	end
end

function Callback_Alien_Grunt_Killed()
   total_alien_grunts = total_alien_grunts - 1
end

function Callback_Act02_Troop_Walker_Killed()
   local spawn_list, object, i, marker, unit

   marker_act02_death.Cancel_Event_Object_In_Range(Prox_Act02_Death)
   
  	if TestValid(pen_act02_gate) then
     	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
  	   spawn_list = SpawnList(list_single_alien_pen_off, pen_act01_gate, neutral, false, true, false)
      object = spawn_list[1]
      object.Teleport_And_Face(pen_act02_gate)
  	   pen_act02_gate.Despawn()
  	   pen_act02_gate = object
  	end

   -- Act03 Proximities
	Register_Prox(marker_act03_prox01, Prox_Act03_Begin, distance_act03_begin, masari)
   
   -- Act03 Guards
   for i, marker in pairs (marker_list_act03_guards) do
      spawn_list = SpawnList(list_single_alien_grunt, marker, aliens, false, true, false)
      unit = spawn_list[1]
      if TestValid(unit) then
         unit.Teleport_And_Face(marker)
         unit.Guard_Target(unit.Get_Position())
      end
   end

end

function Prox_Act02_Start(prox_obj, trigger_obj)
  	prox_obj.Cancel_Event_Object_In_Range(Prox_Act02_Start)
  	Set_Next_State("State_MM01_Act02")
end

function Prox_Act01_Guards01(prox_obj, trigger_obj)
   prox_act01_guards01_active = true
end

function Prox_Act01_Guards02(prox_obj, trigger_obj)
   prox_act01_guards02_active = true
end

function Prox_Act01_Zessus02(prox_obj, trigger_obj)
   local spawn_list, object
  	prox_obj.Cancel_Event_Object_In_Range(Prox_Act01_Zessus02)
   Create_Thread("Thread_Prox_Act01_Zessus02",prox_obj)
end

function Thread_Prox_Act01_Zessus02(prox_obj)
   local i, unit, spawn_list, object
   
   prox_act01_guards02_active = false
   Sleep(0.2)
   if not prox_act01_guards02_active then
   	if TestValid(pen_act01_disciples) then
        	prox_obj.Cancel_Event_Object_In_Range(Prox_Act01_Guards02)
      	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
   	   spawn_list = SpawnList(list_single_alien_pen_off, pen_act01_disciples, neutral, false, true, false)
   	   object = spawn_list[1]
   	   object.Teleport_And_Face(pen_act01_disciples)
   	   pen_act01_disciples.Despawn()
   	   pen_act01_disciples = object
   	   
         act01_fow02.Undo_Reveal()
     	   marker_act01_fow02.Highlight(false)
     	   Remove_Radar_Blip("blip-terminal2")
     	   if TestValid(marker_act01_fow02_ground_highlight) then
     	      marker_act01_fow02_ground_highlight.Despawn()
     	   end
	      
     	   marker_act01_fow01.Highlight(true)
        	Add_Radar_Blip(marker_act01_fow01, "DEFAULT", "blip-terminal1")
      	marker_act01_fow01_ground_highlight = Create_Generic_Object(Find_Object_Type("Highlight_Area"), marker_act01_fow01, neutral)
        	
        	for i, unit in pairs(list_act01_disciples) do
   	      unit.Set_Selectable(true)
            unit.Prevent_All_Fire(false)
            unit.Make_Invulnerable(false)
   	      masari.Select_Object(unit)
        	end
        	act01_first_gate_opened = true
        	-- Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
        	Hunt(list_act01_disciples, "AntiDefault", true, true, marker_act01_fow01, distance_act01_disciple_hunt)
        	act02_disciple = list_act01_disciples[1]
        	if TestValid(act02_disciple) then
      		act02_disciple.Register_Signal_Handler(Callback_Act02_Disciple_Attacked, "OBJECT_DAMAGED")
      		act02_disciple.Set_Cannot_Be_Killed(true)
        	end
     	   BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE04_04"))
      else
   		Register_Prox(marker_act01_fow02, Prox_Act01_Zessus02, distance_approach_act01_terminal, masari)
	   end
	else
		Register_Prox(marker_act01_fow02, Prox_Act01_Zessus02, distance_approach_act01_terminal, masari)
   end
end

function Callback_Act02_Disciple_Attacked()
   local health
   
   if not act02_disciple_invulnerable then
      if TestValid(act02_disciple) then
         health = act02_disciple.Get_Hull()
         if health < 0.33 then
            act02_disciple_invulnerable = true
            act02_disciple.Make_Invulnerable(true)
         end
      end
   end
end

function Prox_Act01_Zessus01(prox_obj, trigger_obj)
   local spawn_list, object
  	prox_obj.Cancel_Event_Object_In_Range(Prox_Act01_Zessus01)
   Create_Thread("Thread_Prox_Act01_Zessus01",prox_obj)
end

function Thread_Prox_Act01_Zessus01(prox_obj)
   if not announced_gate_terminal then
      announced_gate_terminal = true
  	   BlockOnCommand(Queue_Talking_Head(pip_disciple, "MAS01_SCENE04_05"))
   end
   prox_act01_guards01_active = false
   Sleep(0.2)
   if not prox_act01_guards01_active then
   	if TestValid(pen_act01_gate) and act01_first_gate_opened then
        	prox_obj.Cancel_Event_Object_In_Range(Prox_Act01_Guards01)
      	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
   	   spawn_list = SpawnList(list_single_alien_pen_off, pen_act01_gate, neutral, false, true, false)
   	   object = spawn_list[1]
   	   object.Teleport_And_Face(pen_act01_gate)
   	   pen_act01_gate.Despawn()
   	   pen_act01_gate = object
         
     	   marker_act01_fow01.Highlight(false)
     	   Remove_Radar_Blip("blip-terminal1")
     	   if TestValid(marker_act01_fow01_ground_highlight) then
     	      marker_act01_fow01_ground_highlight.Despawn()
     	   end     	   
      else
   		Register_Prox(marker_act01_fow01, Prox_Act01_Zessus01, distance_approach_act01_terminal, masari)
	   end
	else
		Register_Prox(marker_act01_fow01, Prox_Act01_Zessus01, distance_approach_act01_terminal, masari)
   end   
end

function Callback_Zessus_Killed()
	if not mission_success and not mission_failure then
		Create_Thread("Thread_Mission_Failed","TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ZESSUS")
	end
end

function Callback_Act04_Assembly_Walker_Killed()
   Create_Thread("Thread_Mission_End_Conversation")
end

function Thread_Mission_End_Conversation()
   Objective_Complete(mm01_objective09)
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS01_OBJECTIVE_09_COMPLETE"} )
   if TestValid(hero) then
      hero.Make_Invulnerable(true)
   end
	while conversation_occuring do
		Sleep(1)
	end
	conversation_occuring = true
	if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_zessus, "MAS01_SCENE08_01"))
   end	
	if not mission_success and not mission_failure then
  	   BlockOnCommand(Queue_Talking_Head(pip_moore, "MAS01_SCENE08_02"))
  	   BlockOnCommand(Queue_Talking_Head(pip_moore, "MAS01_SCENE08_03"))
  	end
	conversation_occuring = false
	Create_Thread("Thread_Mission_Complete")
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
		
	mission_success = true
   Stop_All_Speech()
   Flush_PIP_Queue()
   Letter_Box_In(1)
   Lock_Controls(1)
   Suspend_AI(1)
   Disable_Automatic_Tactical_Mode_Music()
   Play_Music("Masari_Win_Tactical_Event")
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
   BlockOnCommand(Play_Bink_Movie("Masari_M1_S4",true))

	Force_Victory(masari)
end

function Force_Victory(player)
   Fade_Out_Music()	
   
   --Reset lock state at mission end so that the global segment behaves normally
   masari.Reset_Story_Locks()
   aliens.Reset_Story_Locks()
	military.Allow_AI_Unit_Behavior(true)
	novus.Allow_AI_Unit_Behavior(true)
	aliens.Allow_AI_Unit_Behavior(true)
	if player == masari then
	   
		-- Inform the campaign script of our victory.
		global_script.Call_Function("Masari_Tactical_Mission_Over", true) -- true == player wins/false == player loses
		--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
		Quit_Game_Now(player, false, true, false)
	else
      Show_Retry_Dialog()
	end
end

function Cache_Models()
	Find_Object_Type("Alien_Superweapon_Reaper_Turret").Load_Assets()
	Find_Object_Type("TM02_CUSTOM_HABITAT_WALKER").Load_Assets()
	Find_Object_Type("NM06_Custom_Assembly_Walker").Load_Assets()
	Find_Object_Type("Alien_Foo_Core").Load_Assets()
	Find_Object_Type("Alien_Brute").Load_Assets()
	Find_Object_Type("Alien_Recon_Tank").Load_Assets()
	Find_Object_Type("Alien_Defiler").Load_Assets()
	Find_Object_Type("Military_Hero_Randal_Moore").Load_Assets()
	Find_Object_Type("Military_Team_Marines").Load_Assets()
	Find_Object_Type("Military_Team_Rocketlauncher").Load_Assets()
end

function Post_Load_Callback()
	UI_Hide_Research_Button()
	if show_sell_button then
		UI_Show_Sell_Button()
	else
		UI_Hide_Sell_Button()
	end
	Movie_Commands_Post_Load_Callback()
end
