-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Masari_MM07.lua#32 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Masari_MM07.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Keith_Brors $
--
--            $Change: 90607 $
--
--          $DateTime: 2008/01/09 11:56:44 $
--
--          $Revision: #32 $
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

	-- only service once a second
	ServiceRate = 1

	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")

	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_MM07_Act01", State_MM07_Act01)
	
	-- Testing Bools
	bool_testing = false
	bool_testing_mutant_routine = false
	bool_make_purifier_not_killable = false
	bool_make_player_heroes_invulnerable = false
	
	-- Pip Heads
	pip_altea = "ZH_Altea_Pip_head.alo"
	pip_charos = "ZH_Charos_pip_Head.alo" --PLACEHOLDER
	pip_zessus = "ZH_Zessus_Pip_head.alo"
	pip_masari_comm = "MH_Moore_pip_Head.alo" --PLACEHOLDER
	pip_moore = "MH_Moore_pip_Head.alo"
	pip_mirabel = "NH_Mirabel_pip_head.alo"
	pip_kamal = "AH_Kamal_Rex_pip_head.alo"
	
   -- Factions
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")
   hostile = Find_Player("Hostile")

   -- Object Types
	object_type_alien_transport = Find_Object_Type("ALIEN_AIR_INVASION_TRANSPORT")
	object_type_mutant = Find_Object_Type("ALIEN_MUTANT_SLAVE")
	object_type_novus_transport = Find_Object_Type("NOVUS_AIR_INVASION_TRANSPORT")		
	object_type_alien_walker_assembly = Find_Object_Type("Alien_Walker_Assembly")
	object_type_alien_walker_habitat = Find_Object_Type("Alien_Walker_Habitat")
	object_type_alien_defiler_hardpoint = Find_Object_Type("Alien_Walker_Assembly_HP_Defiler_Assembly_Pod")
	object_type_alien_phasetank_hardpoint = Find_Object_Type("Alien_Walker_Assembly_HP_Phase_Tank_Assembly_Pod")
	object_type_alien_lostone_hardpoint = Find_Object_Type("Alien_Walker_Habitat_HP_Lost_One_Mutator")
	object_type_alien_brute_hardpoint = Find_Object_Type("Alien_Walker_Habitat_HP_Brute_Mutator")
	object_type_alien_grunt = Find_Object_Type("ALIEN_GRUNT")
	object_type_alien_lostone = Find_Object_Type("ALIEN_LOST_ONE")
	object_type_alien_brute = Find_Object_Type("ALIEN_BRUTE")
	object_type_alien_defiler = Find_Object_Type("ALIEN_DEFILER")
	object_type_alien_recontank = Find_Object_Type("ALIEN_RECON_TANK")
	object_type_alien_foo = Find_Object_Type("ALIEN_FOO_CORE")
	object_type_alien_cylinder = Find_Object_Type("ALIEN_CYLINDER")

	object_type_novus_robotic_assembly = Find_Object_Type("NOVUS_ROBOTIC_ASSEMBLY")
	object_type_novus_robotic_assembly_upgrade = Find_Object_Type("Novus_Robotic_Assembly_Instance_Generator")
	object_type_novus_vehicle_assembly = Find_Object_Type("NOVUS_VEHICLE_ASSEMBLY")
	object_type_novus_vehicle_assembly_upgrade = Find_Object_Type("Novus_Vehicle_Assembly_Inversion")
	object_type_novus_aircraft_assembly = Find_Object_Type("NOVUS_AIRCRAFT_ASSEMBLY")
	object_type_novus_aircraft_assembly_upgrade = Find_Object_Type("Novus_Aircraft_Assembly_Scramjet")
	object_type_novus_science_lab = Find_Object_Type("NOVUS_SCIENCE_LAB")
	object_type_novus_emp_superweapon = Find_Object_Type("NOVUS_SUPERWEAPON_EMP")
	object_type_novus_reflex_trooper = Find_Object_Type("NOVUS_REFLEX_TROOPER")
	object_type_novus_robotic_infantry = Find_Object_Type("NOVUS_ROBOTIC_INFANTRY")
	object_type_novus_antimatter_tank = Find_Object_Type("NOVUS_ANTIMATTER_TANK")
	object_type_novus_field_inverter = Find_Object_Type("NOVUS_FIELD_INVERTER")
	object_type_novus_variant = Find_Object_Type("NOVUS_VARIANT")
	object_type_novus_corruptor = Find_Object_Type("NOVUS_CORRUPTOR")
	object_type_novus_dervish_jet = Find_Object_Type("NOVUS_DERVISH_JET")

   object_type_pen_on = Find_Object_Type("NM02_CIVILIAN_PEN")

	-- Unit Lists
	list_novus_and_uea_units = {}
	list_kamal_units = {}
	
	list_alien_reinforcement_units = { 	
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Grunt",
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Lost_One",
		"Alien_Brute",
		"Alien_Defiler"
	}

	list_kamalrex_reinforcement_units = { 
		"Alien_Hero_Kamal_Rex"
	}
	
	list_civilian_captives = {
		"American_Civilian_Urban_01_Map_Loiterer",
		"American_Civilian_Urban_02_Map_Loiterer",
		"American_Civilian_Urban_03_Map_Loiterer",
		"American_Civilian_Urban_04_Map_Loiterer", 
		"American_Civilian_Urban_05_Map_Loiterer",
		"American_Civilian_Urban_06_Map_Loiterer",
		"American_Civilian_Urban_07_Map_Loiterer",
		"American_Civilian_Urban_08_Map_Loiterer",
		"American_Civilian_Urban_09_Map_Loiterer",
		"American_Civilian_Urban_10_Map_Loiterer",
		"American_Civilian_Urban_11_Map_Loiterer"
	}
	
	list_novus_builder_team = {
		"NOVUS_CONSTRUCTOR",
		"NOVUS_CONSTRUCTOR",
		"NOVUS_CONSTRUCTOR"
	}

   -- Variables
	failure_text = nil

	time_objective_sleep = 5
	
	kamal_rex = nil
	time_find_kamal = 10
	
	dialog_mission_start = 0
	dialog_purifier_retreats = 1
	dialog_enter_uea_and_novus = 2
	dialog_intro_science_walkers = 3
	dialog_mirabel_falls_back = 4
	dialog_intro_mutant_slaves = 5
	dialog_intro_masari_superweapons = 6
	dialog_kamal_rex_taunt_01 = 7
	dialog_kamal_rex_taunt_02 = 8
	dialog_intro_kamal_rex = 9
	
	bool_opening_dialog_finished = false
	bool_kamal_first_taunt_played = false
	bool_kamal_second_taunt_played = false
	bool_kamal_rex_dead = false
	bool_purifier_dead = false
	bool_novus_units_defined = false
	bool_uea_units_defined = false
	bool_alien_radiation_cascade_ready = false
	bool_starting_walkers_dead = false
	science_walkers_revealed = false
	
	counter_uea_units_mindcontrolled = 0	
	counter_new_assembly_walkers = 1
	counter_new_habitat_walkers = 1

	new_assembly_walker = nil
	new_habitat_walker = nil
	
	fieldinverter_gift01 = nil
	fieldinverter_gift02 = nil
	fieldinverter_gift03 = nil

	novus_robotic_assembly = nil
	novus_vehicle_assembly = nil
	novus_aircraft_assembly = nil
	novus_science_lab = nil
	novus_emp_superweapon = nil

	pen01 = 1
   bool_pen01_awaiting_delivery = true
   pen01_civilian_captives = {}
   pen01_mutant_list = {}
	
	--COUNTERS AND LIMITERS: USED IN TEAM CONSTRUCTION ROUTINES
	--INFANTRY:
	counter_current_reflex_troopers = 0
	counter_max_allowed_reflex_troopers = 2
	counter_current_robotic_infantry = 0
	counter_max_allowed_robotic_infantry = 2
	
	bool_novusbase_infanftry_team_list_in_use = false
	list_novusbase_infantry_team = {}
	novusbase_infantry_team_size = 3
	
	--VEHICLES:
	counter_current_antimatter_tanks = 0
	counter_max_allowed_antimatter_tanks = 1
	counter_current_field_inverters = 0
	counter_max_allowed_field_inverters = 1
	counter_current_variants = 0
	counter_max_allowed_variants = 1
	
	bool_novus_building_antimatter_tanks = false
	bool_novus_building_variants = false
	bool_novus_building_field_inverters = false
	
	bool_novusbase_vehicle_team_list_in_use = false
	list_novusbase_vehicle_team = {}
	novusbase_vehicle_team_size = 2
	
	--AIRCRAFT:
	counter_current_novus_corruptors = 0
	counter_max_allowed_novus_corruptors = 2
	counter_current_dervish_jets = 0
	counter_max_allowed_dervish_jets = 1
	
	bool_novusbase_aircraft_team_list_in_use = false
	list_novusbase_aircraft_team = {}
	novusbase_aircraft_team_size = 2
	
	bool_mission_success = false 
	bool_mission_failure = false
	bool_displaying_hero_under_attack_warning = false
	bool_first_time_purifier_attacked = true
	
	sleep_timer_between_attack_warnings = 30

	--COUNTERS AND LIMITERS: USED IN TEAM CONSTRUCTION ROUTINES
	--INFANTRY:
	counter_current_grunts = 0
	counter_max_allowed_grunts = 3
	counter_current_lostones = 0
	counter_max_allowed_lostones = 3
	counter_current_brutes = 0
	counter_max_allowed_brutes = 2
	
	bool_aliens_building_grunts = false
	bool_aliens_building_lostones = false
	bool_aliens_building_brutes = false

	--VEHICLES:
	counter_current_defilers = 0
	counter_max_allowed_defilers = 2
	counter_current_recontanks = 0
	counter_max_allowed_recontanks = 2
	
	bool_aliens_building_defilers= false
	bool_aliens_building_recontanks = false
	
	--AIRCRAFT:
	counter_current_cylinders = 0
	counter_max_allowed_cylinders= 1
	counter_current_foos = 0
	counter_max_allowed_foos = 3
	
	bool_aliens_building_cylinders= false
	bool_aliens_building_foos = false
	
	--alien teams x2
	bool_alienbase_team01_list_in_use = false
	list_alienbase_team01_team = {}
	
	bool_alienbase_team02_list_in_use= false
	list_alienbase_team02_team = {}
	
	desired_alienbase_team01_team_size = 3
	bool_alienbase_team01_ready_to_go = false

	desired_alienbase_team02_team_size = 3
	bool_alienbase_team02_ready_to_go = false
	
end


--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
   local credits, i, unit, uea_strikeforce, novus_strikeforce
   
	if message == OnEnter then
	uea.Allow_AI_Unit_Behavior(false)
	novus.Allow_AI_Unit_Behavior(false)
	aliens.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
		
		_CustomScriptMessage("JoeLog.txt", string.format("\n\n\n\n\n\n\n\n\n\nStory_Campaign_Novus_MM07 START!"))
		--this following OutputDebug puts a message in the logfile that lets me determine where mission relevent info starts...mainly using to determine what assets need
		--to be pre-cached.
		OutputDebug("\n\n\n#*#*#*#*#*#*#*#*#*#*#*#*#\njdg: Story_Campaign_Novus_MM07 START!\n#*#*#*#*#*#*#*#*#*#*#*#*#\n")
		
		-- Allegiances
		novus.Make_Enemy(aliens)
		uea.Make_Enemy(aliens)
		aliens.Make_Enemy(novus)
		aliens.Make_Enemy(uea)
		
		masari.Make_Ally(novus)
		masari.Make_Ally(uea)
		novus.Make_Ally(masari)
		novus.Make_Ally(uea)
		uea.Make_Ally(novus)
		uea.Make_Ally(masari)		

      -- Faction Colors
--	   PGColors_Init_Constants()
--	   masari.Enable_Colorization(true, COLOR_DARK_GREEN)
--	   novus.Enable_Colorization(true, COLOR_CYAN)
--	   uea.Enable_Colorization(true, COLOR_GREEN)
--	   aliens.Enable_Colorization(true, COLOR_RED)
				
		-- Hint System Definition
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		local scene = Get_Game_Mode_GUI_Scene()
		Register_Hint_Context_Scene(scene)			-- Set the scene to which independant hints will be attached.

      -- Resources      
	   credits = masari.Get_Credits()
	   credits = 1000 - credits
	   if credits > 0 then
		   masari.Give_Money(credits)
	   end
   	aliens.Give_Money(50000)

      -- Locks	
		novus.Reset_Story_Locks()
		aliens.Reset_Story_Locks()
		masari.Reset_Story_Locks()
		Lock_Out_Stuff(true)
   	aliens.Allow_Autonomous_AI_Goal_Activation(false)
   		
	   -- Altea
	   altea = Find_First_Object("MASARI_HERO_ALATEA")
	   if not TestValid(altea) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find altea...exiting scripts...tell Joe G immediately!"))
		   ScriptExit()
	   else
		   -- heroes nerfed late, so adding damage modifier, Altea old health(600) / Altea new health(2000) - 1 = -.7
		   altea.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.7)
		   altea.Register_Signal_Handler(Callback_Atlatea_Destroyed, "OBJECT_HEALTH_AT_ZERO")
	   end
	   
	   -- Zessus
	   zessus = Find_First_Object("MASARI_HERO_ZESSUS")
	   if not TestValid(zessus) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find zessus...exiting scripts...tell Joe G immediately!"))
		   ScriptExit()
	   else
		   -- heroes nerfed late, so adding damage modifier, zessus old health(800 ) / zessus new health(2500) - 1 = -.68
		   zessus.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.68)
		   zessus.Register_Signal_Handler(Callback_Zessus_Destroyed, "OBJECT_HEALTH_AT_ZERO")
	   end
	   
	   -- Charos
	   charos = Find_First_Object("MASARI_HERO_CHAROS")
	   if not TestValid(charos) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find charos...exiting scripts...tell Joe G immediately!"))
		   ScriptExit()
	   else
		   -- heroes nerfed late, so adding damage modifier, Charos old health(3000) / Charos new health(1000) - 1 = -.67
		   charos.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.67)
		   charos.Register_Signal_Handler(Callback_Charos_Destroyed, "OBJECT_HEALTH_AT_ZERO")
	   end
	   if bool_make_player_heroes_invulnerable then --test/debug bool
		   altea.Make_Invulnerable(true)
		   zessus.Make_Invulnerable(true)
		   charos.Make_Invulnerable(true)
		   altea.Set_Cannot_Be_Killed(true)
		   zessus.Set_Cannot_Be_Killed(true)
		   charos.Set_Cannot_Be_Killed(true)
	   end

      -- Hierarchy Purifier
	   purifier = Find_First_Object("MM07_ALIEN_MEGAWEAPON_PURIFIER")
	   if not TestValid(purifier) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find the purifier...exiting scripts...tell Joe G immediately!"))
		   ScriptExit()
	   else
		   purifier.Prevent_AI_Usage(true)
		   purifier.Suspend_Locomotor(true)
		   purifier.Set_Service_Only_When_Rendered(false)
		   purifier.Register_Signal_Handler(Callback_Purifier_Attacked, "OBJECT_DAMAGED")	
		   purifier.Register_Signal_Handler(Callback_Purifier_Destroyed, "OBJECT_HEALTH_AT_ZERO")	
	   end
	   if bool_make_purifier_not_killable then -- testing stuff
		   purifier.Set_Cannot_Be_Killed(true)
	   end

      -- Purifier Guards	
	   list_purifier_guards = Find_All_Objects_With_Hint("purifier-guard")	
	   for i,purifier_guard in pairs(list_purifier_guards) do
		   if TestValid(purifier_guard) then
			   purifier_guard.Set_Service_Only_When_Rendered(false)
			   purifier_guard.Guard_Target(purifier)
		   end
	   end
	
	   -- Markers
	   purifier_fallback_spot01 = Find_Hint("MARKER_GENERIC_GREEN","purifier-fallback-spot01")
	   if not TestValid(purifier_fallback_spot01) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find purifier_fallback_spot01!"))
	   end
      kamal_reinforcement_end_location_list = Find_All_Objects_With_Hint("kamal-reinforcement-end-location")	
	   if table.getn(kamal_reinforcement_end_location_list) == 0 then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! kamal_reinforcement_end_location_list == 0 "))
	   end
	   kamal_reinforcement_start_location_list = Find_All_Objects_With_Hint("kamal-reinforcement-start-location")	
	   if table.getn(kamal_reinforcement_start_location_list) == 0 then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! counter_kamal_reinforcement_start_location_list == 0 "))
	   end
	
	   player_base = Find_Hint("MARKER_GENERIC_GREEN","player-base")
	   if not TestValid(player_base) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find player_base!"))
	   end
	   playerbase_frontdoor = Find_Hint("MARKER_GENERIC_RED","playerbase-frontdoor")
	   if not TestValid(playerbase_frontdoor) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find playerbase_frontdoor!"))
	   end
	   playerbase_backdoor = Find_Hint("MARKER_GENERIC_RED","playerbase-backdoor")
	   if not TestValid(playerbase_backdoor) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find playerbase_backdoor!"))
	   end
	
	   entryflag_novus_buildteam = Find_Hint("MARKER_GENERIC_PURPLE","entryflag-novus-buildteam")
	   if not TestValid(entryflag_novus_buildteam) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find entryflag_novus_buildteam!"))
	   end
	   spawnflag_novus_buildteam = Find_Hint("MARKER_GENERIC_PURPLE","spawnflag-novus-buildteam")
	   if not TestValid(spawnflag_novus_buildteam) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find spawnflag_novus_buildteam!"))
	   end
	
	   marker_novus_base = Find_Hint("MARKER_GENERIC_GREEN","novus-base")
	   if not TestValid(marker_novus_base) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find marker_novus_base!"))
	   end
	   marker_novus_infantry_rally_point = Find_Hint("MARKER_GENERIC_GREEN","novusbase-rallypoint-infantry")
	   if not TestValid(marker_novus_infantry_rally_point) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find marker_novus_infantry_rally_point!"))
	   end
	   marker_novus_vehicle_rally_point = Find_Hint("MARKER_GENERIC_GREEN","novusbase-rallypoint-vehicles")
	   if not TestValid(marker_novus_vehicle_rally_point) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find marker_novus_vehicle_rally_point!"))
	   end
	   marker_novus_aircraft_rally_point = Find_Hint("MARKER_GENERIC_GREEN","novusbase-rallypoint-aircraft")
	   if not TestValid(marker_novus_aircraft_rally_point) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find marker_novus_aircraft_rally_point!"))
	   end
	
   	marker_novus_rallypoint_mirabel = Find_Hint("MARKER_GENERIC_GREEN","novusbase-rallypoint-mirabel")
	   if not TestValid(marker_novus_rallypoint_mirabel) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find marker_novus_rallypoint_mirabel!"))
	   end
	
	   alienbase_rallypoint01 = Find_Hint("MARKER_GENERIC_RED","alienbase-rallypoint01")
	   if not TestValid(alienbase_rallypoint01) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find alienbase_rallypoint01!"))
	   end
	   alienbase_rallypoint02 = Find_Hint("MARKER_GENERIC_RED","alienbase-rallypoint02")
	   if not TestValid(alienbase_rallypoint02) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find alienbase_rallypoint02!"))
	   end

	   inverter01_goto = Find_Hint("MARKER_GENERIC_YELLOW","inverter01-goto")
	   if not TestValid(inverter01_goto) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find inverter01_goto!"))
	   end
	   inverter02_goto = Find_Hint("MARKER_GENERIC_YELLOW","inverter02-goto")
	   if not TestValid(inverter02_goto) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find inverter02_goto!"))
	   end
	   inverter03_goto = Find_Hint("MARKER_GENERIC_YELLOW","inverter03-goto")
	   if not TestValid(inverter03_goto) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find inverter03_goto!"))
	   end

	   uea_rallypoint = Find_Hint("MARKER_GENERIC_YELLOW","uea-rallypoint")
	   if not TestValid(uea_rallypoint) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find uea_rallypoint!"))
	   end
	   uea_rallypoint02 = Find_Hint("MARKER_GENERIC_YELLOW","uea-rallypoint02")
	   if not TestValid(uea_rallypoint02) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find uea_rallypoint02!"))
	   end

	   pen01_delivery_spot = Find_Hint("MARKER_GENERIC_BLACK","pen01")
	   if not TestValid(pen01_delivery_spot) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find pen01_delivery_spot!"))
	   end
	   pen01_fake_delivery_spot = Find_Hint("MARKER_GENERIC_BLACK","pen01-fake")
	   if not TestValid(pen01_fake_delivery_spot) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find pen01_fake_delivery_spot!"))
	   end
   	pen01_transport_spawnflag = Find_Hint("MARKER_GENERIC_PURPLE","pen01")
	   if not TestValid(pen01_transport_spawnflag) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find pen01_transport_spawnflag!"))
	   end

      -- Military Strike Force	
	   list_uea_strikeforce = Find_All_Objects_With_Hint("uea-strikeforce")
	   for i,uea_strikeforce in pairs(list_uea_strikeforce) do
		   if TestValid(uea_strikeforce) then
			   uea_strikeforce.Set_Object_Context_ID("hide_me")
		   end
	   end
   	
	   list_novus_strikeforce = Find_All_Objects_With_Hint("novus-strikeforce")
	   for i,novus_strikeforce in pairs(list_novus_strikeforce) do
		   if TestValid(novus_strikeforce) then
			   novus_strikeforce.Set_Object_Context_ID("hide_me")
		   end
	   end 
	
	   -- Hierarchy Civilian Pens
   	pen01_on = Find_Hint("NM02_CIVILIAN_PEN","pen01")
	   pen01_off = Find_Hint("NM02_CIVILIAN_PEN_OFF","pen01")
	   if TestValid(pen01_on) then	
		   bool_pen01_valid = true
		   if TestValid(pen01_off) then
			   bool_pen01_off_valid = true
			   pen01_off.Teleport_And_Face(pen01_on)
			   pen01_off.Hide(true)
		   else 
   		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find pen01_off!"))
		   end
	   else 
  		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find pen01_on!"))
	   end
	   pen01_defiler = Find_Hint("ALIEN_DEFILER","pen01")
	   if TestValid(pen01_defiler) then
		   bool_pen01_defiler_valid = true
		   pen01_defiler.Suspend_Locomotor(true)
		   pen01_defiler.Prevent_All_Fire(true)
	   else 
  		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find pen01_defiler!"))
	   end
	
	   -- Hierarchy Walkers
	   local alien_science_walker01_list = Find_All_Objects_With_Hint("science-walker01")	
	   alien_science_walker01 = alien_science_walker01_list[1]
	   if not TestValid(alien_science_walker01) then
  		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find alien_science_walker01!"))
	   end
	
      local alien_science_walker02_list = Find_All_Objects_With_Hint("science-walker02")	
	   alien_science_walker02 = alien_science_walker02_list[1]
	   if not TestValid(alien_science_walker02) then
	      _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find alien_science_walker02!"))
      end
	
	   local alien_team02_habitat_walker_list = Find_All_Objects_With_Hint("habitat-walker-brutes")	
	   alien_team02_habitat_walker = alien_team02_habitat_walker_list[1]
	   if not TestValid(alien_team02_habitat_walker) then
	      _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find alien_team02_habitat_walker!"))
	   end
	
	   local alien_team01_habitat_walker_list = Find_All_Objects_With_Hint("habitat-walker-lostones")	
	   alien_team01_habitat_walker = alien_team01_habitat_walker_list[1]
	   if not TestValid(alien_team01_habitat_walker) then
	      _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find alien_team01_habitat_walker!"))
	   end
	
	   local alien_team02_assembly_walker_list = Find_All_Objects_With_Hint("assembly-walker-defilers")	
	   alien_team02_assembly_walker = alien_team02_assembly_walker_list[1]
	   if not TestValid(alien_team02_assembly_walker) then
         _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find alien_team02_assembly_walker!"))
	   end
	
	   local alien_team01_assembly_walker_list = Find_All_Objects_With_Hint("assembly-walker-phasetanks")	
	   alien_team01_assembly_walker = alien_team01_assembly_walker_list[1]
	   alien_team01_assembly_walker = alien_team01_assembly_walker
	   if not TestValid(alien_team01_assembly_walker) then
         _CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! MM07 cannot find alien_team01_assembly_walker!"))
	   end
	
	   -- Hierarchy Hunt Groups
	   alien_huntpack_01 = Find_All_Objects_With_Hint("alien-huntpack-01")
	   for i, unit in pairs(alien_huntpack_01) do
		   if TestValid(unit) then
			   unit.Set_Service_Only_When_Rendered(true)
		   end
	   end
	   alien_huntpack_02 = Find_All_Objects_With_Hint("alien-huntpack-02")	
	   for i, unit in pairs(alien_huntpack_02) do
		   if TestValid(unit) then
			   unit.Set_Service_Only_When_Rendered(true)
		   end
	   end
			
		Set_Next_State("State_MM07_Act01")      
	end
end

function State_MM07_Act01(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("*******State Change: State_MM07_Act01"))

      -- Hierarchy Civilian Pens
	   if bool_pen01_valid and bool_pen01_off_valid and bool_pen01_defiler_valid then
		   Create_Thread("Thread_Deliver_Captive_Civs_Routine", pen01)
	   else
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR! Something wrong with pen01 setup"))
	   end
		
		-- Hierarchy Science Walker Guards
		if TestValid(alien_science_walker01) then
	      alien_science_walker01_guard_list = Find_All_Objects_With_Hint("science-walker01-guard")	
	      for i,alien_science_walker01_guard in pairs(alien_science_walker01_guard_list) do
		      if TestValid(alien_science_walker01_guard) then
			      alien_science_walker01_guard.Guard_Target(alien_science_walker01)
			      alien_science_walker01_guard.Set_Service_Only_When_Rendered(true)
		      end
		   end
	   end
	   if TestValid(alien_science_walker02) then
	      alien_science_walker02_guard_list = Find_All_Objects_With_Hint("science-walker02-guard")	
	      for i,alien_science_walker02_guard in pairs(alien_science_walker02_guard_list) do
		      if TestValid(alien_science_walker02_guard) then
			      alien_science_walker02_guard.Guard_Target(alien_science_walker02)
			      alien_science_walker02_guard.Set_Service_Only_When_Rendered(true)
		      end
	      end
	   end
	   
	   -- Hierarchy Hunt Groups
   	Hunt(alien_huntpack_01, "AntiDefault", true, false, alien_huntpack_01[1], 50)
   	Hunt(alien_huntpack_02, "AntiDefault", true, false, alien_huntpack_02[1], 50)
	   
		Create_Thread("Thread_State_MM07_Act01")
	end
end

function Thread_State_MM07_Act01()

	Fade_Screen_Out(0)
	Lock_Controls(1)
	Letter_Box_In(0)

	if bool_testing_mutant_routine then
		Point_Camera_At(pen03_defiler)
	else
		Point_Camera_At(altea)
	end

	Sleep(1)
	Start_Cinematic_Camera()
	
	Create_Thread("Thread_Dialog_Controller", dialog_mission_start) 

	Transition_Cinematic_Target_Key(altea, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(altea, 0, 200, 55, 65, 1, 0, 0, 0)

	Fade_Screen_In(1) 

	Transition_To_Tactical_Camera(5)
	Sleep(5)

	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()
	
   --TEXT_SP_MISSION_MAS07_OBJECTIVE_01: Atlatea, Zessus and Charos must survive.
   --TEXT_SP_MISSION_MAS07_OBJECTIVE_02: Destroy the Hierarchy Purifier.
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS07_OBJECTIVE_01_ADD"} )
	mas07_objective01 = Add_Objective("TEXT_SP_MISSION_MAS07_OBJECTIVE_01")--Atlatea, Zessus and Charos must survive.
	
	while bool_opening_dialog_finished == false do
		Sleep(1)
	end
	
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS07_OBJECTIVE_02_ADD"} )
	Sleep(time_objective_sleep)
	mas07_objective02 = Add_Objective("TEXT_SP_MISSION_MAS07_OBJECTIVE_02")--Destroy the Hierarchy Purifier.
	
	Sleep(2)
	
	if TestValid(purifier) then
		Add_Radar_Blip(purifier, "DEFAULT", "blip_purifier")
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!Thread_Add_Starting_Objectives cannot find the purifier"))
	end
	
	Sleep(30)
	
	Create_Thread("Thread_UEA_Attacks")
	Create_Thread("Thread_Novus_Attacks")
	Create_Thread("Thread_Alien_Base_Build_Infantry")
	Create_Thread("Thread_Alien_Base_Build_Vehicles")

   Sleep(10)
   
   -- Setup Revealed Callbacks
	if not TestValid(alien_science_walker01) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! Cannot find alien_science_walker01"))
	else
   	Register_Prox(alien_science_walker01, Callback_ScienceWalker_Revealed, 300, novus)
	end
	if not TestValid(alien_science_walker02) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! Cannot find alien_science_walker02"))
	else
   	Register_Prox(alien_science_walker02, Callback_ScienceWalker_Revealed, 300, novus)
	end
	if TestValid(pen01_defiler) then
		pen01_defiler.Register_Signal_Handler(Callback_MutantPens_Revealed, "OBJECT_REVEALED")
	else 
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! Cannot find pen01_defiler"))
	end
		
	Sleep(230)
	
	Create_Thread("Thread_Dialog_Controller", dialog_intro_masari_superweapons) 
end

function Thread_UEA_Attacks()
   local i, uea_strikeforce
   
	for i,uea_strikeforce in pairs(list_uea_strikeforce) do
		if TestValid(uea_strikeforce) then
			uea_strikeforce.Set_Object_Context_ID("StoryCampaign_MM07")
			uea_strikeforce.Add_Reveal_For_Player(masari)
			uea_strikeforce.Register_Signal_Handler(Callback_UEAStrikeforce_MindControlled, "OBJECT_EFFECT_APPLIED")
			table.insert(list_novus_and_uea_units, uea_strikeforce)
		end
	end
	
	gen_moore = Find_First_Object("MILITARY_HERO_GENERAL_RANDAL_MOORE")
	if not TestValid(gen_moore) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! not TestValid(gen_moore) "))
	else
		gen_moore.Set_Cannot_Be_Killed(true)
		gen_moore.Register_Signal_Handler(Callback_GenMoore_Killed, "OBJECT_HEALTH_AT_ZERO")	
		Add_Radar_Blip(gen_moore, "Default_Beacon_Placement", "blip_moore_entry")	
	end
	
	Create_Thread("Thread_Dialog_Controller", dialog_enter_uea_and_novus) 
	
	bool_uea_units_defined = true
	
	while not bool_novus_units_defined == true or not bool_uea_units_defined == true do
		Sleep(1)
	end
	Register_Prox(uea_rallypoint02, Prox_Field_Inverter_Invert, 150, novus)
	Formation_Guard(list_novus_and_uea_units, purifier)
end

function Thread_Novus_Attacks()
   local i, novus_strikeforce
	local field_inverter = nil
	for i,novus_strikeforce in pairs(list_novus_strikeforce) do
		if TestValid(novus_strikeforce) then
			novus_strikeforce.Set_Object_Context_ID("StoryCampaign_MM07")
			novus_strikeforce.Add_Reveal_For_Player(masari)
			novus_strikeforce.Register_Signal_Handler(Callback_UEAStrikeforce_MindControlled, "OBJECT_EFFECT_APPLIED")
			if novus_strikeforce.Get_Type() == object_type_novus_field_inverter then
				field_inverter = novus_strikeforce
			end			
			table.insert(list_novus_and_uea_units, novus_strikeforce)
		end
	end
	
	mirabel = Find_First_Object("NOVUS_HERO_MECH")
	if not TestValid(mirabel) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! not TestValid(mirabel) "))
	else
		mirabel.Set_Cannot_Be_Killed(true)
		mirabel.Register_Signal_Handler(Callback_Mirabel_Killed, "OBJECT_HEALTH_AT_ZERO")	
		Add_Radar_Blip(mirabel, "Default_Beacon_Placement", "blip_mirabel_entry")	
		
		-- heroes nerfed late, so adding damage modifier, Mirabel old health(1800) / Charos new health(1000) - 1 = -.45
		mirabel.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.45)		
	end
	
	bool_novus_units_defined = true	
end


--***************************************THREADS****************************************************************************************************

function Thread_Add_KamalRex_Objective() --TEXT_SP_MISSION_MAS07_OBJECTIVE_03: Defeat Kamal Rex.
   Sleep(1)
	kamal_rex = Find_First_Object("Alien_Hero_Kamal_Rex")
	if TestValid(kamal_rex) then
	
		-- Kamal 900 from 1500 = -.4
	   kamal_rex.Add_Attribute_Modifier("Universal_Damage_Modifier", -.6)
	   
      kamal_rex.Register_Signal_Handler(Callback_Kamal_Rex_Damaged, "OBJECT_DAMAGED")
	   kamal_rex.Register_Signal_Handler(Callback_KamalRex_Destroyed, "OBJECT_HEALTH_AT_ZERO")
	   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS07_OBJECTIVE_03_ADD"} )
	   Sleep(time_objective_sleep)
	   mas07_objective03 = Add_Objective("TEXT_SP_MISSION_MAS07_OBJECTIVE_03")--Defeat Kamal Rex.
   	
	   Sleep(2)
	   if TestValid(kamal_rex) then
		   Add_Radar_Blip(kamal_rex, "DEFAULT", "blip_kamal_rex")
		   kamal_rex.Highlight(true, -50)
	   end
	else
	   Callback_KamalRex_Destroyed()
	end
end

function Callback_Kamal_Rex_Damaged(tf, walker, attacker, projectile_type, hard_point, deliberate)
   if TestValid(kamal_rex) then
      Use_Kamal_Rex_Abilities(attacker)
   end
end

function Use_Kamal_Rex_Abilities(attacker)
   if TestValid(attacker) then
      if kamal_rex.Is_Ability_Ready("Kamal_Rex_Abduction_Unit_Ability") then
         kamal_rex.Activate_Ability("Kamal_Rex_Abduction_Unit_Ability", true, attacker.Get_Position())
      else
         if kamal_rex.Is_Ability_Ready("Kamal_Rex_Force_Wall_Unit_Ability") then
            kamal_rex.Activate_Ability("Kamal_Rex_Force_Wall_Unit_Ability", true, kamal_rex.Get_Position())
         end
      end
   end
end

function Thread_Novus_Sets_Up_Base()
	--give them some cash
	novus.Give_Money(20000)
	-- allow Novus to build a base using the AI system, we need to set this as on retry this is set to false
	novus.Allow_AI_Unit_Behavior( true )
	
	--send in the trasport
	if not bool_mission_success and not bool_mission_failure then 

		if TestValid(entryflag_novus_buildteam) then
			local nouvs_transport = Spawn_Unit(object_type_novus_transport, entryflag_novus_buildteam, novus, false)
			if TestValid(nouvs_transport) then
				--Add_Radar_Blip(nouvs_transport, "Default_Beacon_Placement", "blip_reinforcement")

				nouvs_transport.Set_Selectable(false)
				nouvs_transport.Make_Invulnerable(true)
				local blip_reinforcement = nil
				BlockOnCommand(nouvs_transport.Move_To(spawnflag_novus_buildteam.Get_Position()))
				
				-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
				novus_buildteam = SpawnList(list_novus_builder_team, spawnflag_novus_buildteam.Get_Position(), novus, true, true, true)
				novus.Allow_Autonomous_AI_Goal_Activation(false)
				Maintain_Base(novus, "MM07_Novus_Base")
					
				Sleep(5)
				--Remove_Radar_Blip("blip_reinforcement")

				if TestValid(nouvs_transport) then
					BlockOnCommand(nouvs_transport.Move_To(entryflag_novus_buildteam.Get_Position()))
					if TestValid(nouvs_transport) then
						nouvs_transport.Make_Invulnerable(false)
						nouvs_transport.Despawn()
					end
				end
			end
		end
	end
end


--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script

function Callback_KamalRex_Destroyed() --TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ATLATEA
	if not bool_mission_success and not bool_mission_failure then
		Objective_Complete(mas07_objective03) --Defeat Kamal Rex.
		bool_kamal_rex_dead = true
		if bool_kamal_rex_dead and bool_purifier_dead then
			Create_Thread("Thread_Mission_Complete")
		end
	end
end	

function Callback_Atlatea_Destroyed() --TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ATLATEA
	if not bool_mission_success and not bool_mission_failure then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
		bool_mission_failure = true
		failure_text = "TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ATLATEA"
		Create_Thread("Thread_Mission_Failed")
	end
end	

function Callback_Zessus_Destroyed() --TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ZESSUS
	if not bool_mission_success and not bool_mission_failure then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
		bool_mission_failure = true
		failure_text = "TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ZESSUS"
		Create_Thread("Thread_Mission_Failed")
	end
end	

function Callback_Charos_Destroyed() --TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_CHAROS
	if not bool_mission_success and not bool_mission_failure then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
		bool_mission_failure = true
		failure_text = "TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_CHAROS"
		Create_Thread("Thread_Mission_Failed")
	end
end	

function Callback_Mirabel_Killed() --TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL
	if not bool_mission_success and not bool_mission_failure then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
		bool_mission_failure = true
		failure_text = "TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"
		Create_Thread("Thread_Mission_Failed")
	end
end	

function Callback_GenMoore_Killed() --TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MOORE
	if not bool_mission_success and not bool_mission_failure then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
		bool_mission_failure = true
		failure_text = "TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MOORE"
		Create_Thread("Thread_Mission_Failed")
	end
end

function Thread_Mirabel_Retreats()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Mirabel_Retreats HIT!"))

	if TestValid(mirabel) then
		mirabel.Prevent_AI_Usage(true)
		mirabel.Make_Invulnerable(true)
		mirabel.Prevent_All_Fire(true)
		mirabel.Prevent_Opportunity_Fire(true) 
	end
	
	BlockOnCommand(mirabel.Move_To(marker_novus_rallypoint_mirabel.Get_Position()))
	bool_mirabel_at_base = true
	_CustomScriptMessage("JoeLog.txt", string.format("bool_mirabel_at_base = true!"))
	
	if TestValid(mirabel) then
		mirabel.Make_Invulnerable(false)
		mirabel.Prevent_All_Fire(false)
		mirabel.Prevent_Opportunity_Fire(false) 
		--mirabel.Set_Cannot_Be_Killed(false)
		mirabel.Guard_Target(mirabel.Get_Position())
	end

	Create_Thread("Thread_Novus_Sets_Up_Base")
end

function Thread_GenMoore_Retreats()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_GenMoore_Retreats HIT!"))
	
	if TestValid(gen_moore) then
		gen_moore.Prevent_AI_Usage(true)
		gen_moore.Make_Invulnerable(true)
		gen_moore.Prevent_All_Fire(true)
		gen_moore.Prevent_Opportunity_Fire(true) 
	else
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_GenMoore_Retreats NOT TestValid(gen_moore) !"))
	end
	
	BlockOnCommand(gen_moore.Move_To(marker_novus_rallypoint_mirabel.Get_Position()))
	bool_moore_at_base = true
	_CustomScriptMessage("JoeLog.txt", string.format("bool_moore_at_base = true!"))
	
	if TestValid(gen_moore) then
		gen_moore.Make_Invulnerable(false)
		gen_moore.Prevent_All_Fire(false)
		gen_moore.Prevent_Opportunity_Fire(false) 
		gen_moore.Guard_Target(mirabel)
	end
end

function Thread_Add_Protect_Novus_Objective()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS07_OBJECTIVE_04_ADD"} )--New objective: Protect Mirabel and General Moore while Novus sets up its base.
	Sleep(time_objective_sleep)
	mas07_objective04 = Add_Objective("TEXT_SP_MISSION_MAS07_OBJECTIVE_04")--Protect Mirabel and General Moore while Novus sets up its base.
	
	Sleep(2)
	
	if TestValid(mirabel) then
		Add_Radar_Blip(mirabel, "Default_Beacon_Placement_Persistent", "blip_mirabel")	
	end
	
	if TestValid(gen_moore) then
		Add_Radar_Blip(gen_moore, "Default_Beacon_Placement_Persistent", "blip_gen_moore")	
	end
	
	--while TestValid(alien_science_walker02) do
	--	Sleep(5)
	--end
	
	--jdg testing
	Sleep(180)
	
	--send the aliens in now to wipe out this base
	Create_Thread("Thread_Aliens_Attack_NovusBase")
end

function Thread_Aliens_Attack_NovusBase()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Aliens_Attack_NovusBase HIT!! Novus base should now be in peril!!"))
	aliens.Make_Enemy(novus)
	
	if TestValid(alien_team02_habitat_walker) then
		alien_team02_habitat_walker.Override_Max_Speed(.6)
		Hunt(alien_team02_habitat_walker, "MM07_Walker_Priorities", true, false, marker_novus_base, 300)
	end
	
	Sleep(45)
	
	if TestValid(alien_team02_assembly_walker) then
		alien_team02_assembly_walker.Override_Max_Speed(.6)
		Hunt(alien_team02_assembly_walker, "MM07_Walker_Priorities", true, false, marker_novus_base, 300)
	end
		
	while TestValid(alien_team02_habitat_walker) or TestValid(alien_team02_assembly_walker) do
		Sleep(1)
	end
	
	Objective_Complete(mas07_objective04) --Protect Mirabel and General Moore while Novus sets up its base.
	
	Remove_Radar_Blip("blip_mirabel")
	Remove_Radar_Blip("blip_gen_moore")
	
	if TestValid(alien_team01_assembly_walker) then
		Hunt(alien_team01_assembly_walker, "MM07_Walker_Priorities", true, false, player_base, 300)
	end
	
	if TestValid(alien_team01_habitat_walker) then
		Hunt(alien_team01_habitat_walker, "MM07_Walker_Priorities", true, false, player_base, 300)
	end
	
	while TestValid(alien_team01_assembly_walker) or TestValid(alien_team01_habitat_walker) do
		Sleep(10)
	end
	
	--aliens.Allow_Autonomous_AI_Goal_Activation(false)
	bool_starting_walkers_dead = true
	
	list_alien_glyph_carvers = Find_All_Objects_Of_Type("ALIEN_GLYPH_CARVER")
	for i,alien_glyph_carver in pairs(list_alien_glyph_carvers) do
		if TestValid(alien_glyph_carver) then
			alien_glyph_carver.Prevent_AI_Usage(false)
		end
	end
	Maintain_Base(aliens, "MM07_Alien_Base")
	
end

function Callback_Purifier_Attacked()
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_Purifier_Attacked Hit!"))
	if TestValid(purifier) and bool_first_time_purifier_attacked then
		bool_first_time_purifier_attacked = false
		
		
		purifier.Suspend_Locomotor(false) -- player has found and attcked the purifier...let him move and make him retreat back.
		Create_Thread("Thread_Purifier_Attacked")
		Create_Thread("Thread_Dialog_Controller", dialog_purifier_retreats) 
	end
	
	local purifier_health = purifier.Get_Health()
	purifier_health = purifier_health*100
		
	if purifier_health < 75 and bool_kamal_first_taunt_played == false then
		bool_kamal_first_taunt_played = true
		Create_Thread("Thread_Dialog_Controller", dialog_kamal_rex_taunt_01) 
	end
	
	if purifier_health < 50 and bool_kamal_second_taunt_played == false then
		bool_kamal_second_taunt_played = true
		Create_Thread("Thread_Dialog_Controller", dialog_kamal_rex_taunt_02) 
		purifier.Unregister_Signal_Handler(Callback_Purifier_Attacked)
		Create_Thread("Thread_KamalRex_Enters")
		_CustomScriptMessage("JoeLog.txt", string.format("Create_Thread(Thread_KamalRex_Enters)"))
	end
end

function Thread_Purifier_Attacked()
	if TestValid(purifier) then
		purifier.Suspend_Locomotor(false) -- player has found and attcked the purifier...let him move and make him retreat back.
		BlockOnCommand(purifier.Move_To(purifier_fallback_spot01.Get_Position()))
	end
end

function Callback_Purifier_Destroyed()
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_Purifier_Destroyed Hit!"))
	bool_purifier_dead = true
	Create_Thread("Thread_Purifier_Destroyed")
	
	Create_Thread("Thread_Dialog_Controller", dialog_intro_kamal_rex) 
	
	for i,purifier_guard in pairs(list_purifier_guards) do
		if TestValid(purifier_guard) then
			purifier_guard.Prevent_AI_Usage(false)
		end
	end
end

function Thread_Purifier_Destroyed()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MAS07_OBJECTIVE_02_COMPLETE"})--Objective complete: Destroy the Hierarchy Purifier.
	Sleep(2)
	Objective_Complete(mas07_objective02)
end

function Prox_Field_Inverter_Invert(prox_obj, trigger_obj)
	if trigger_obj.Get_Type() == object_type_novus_field_inverter then
		prox_obj.Cancel_Event_Object_In_Range(Prox_Field_Inverter_Invert)
		trigger_obj.Activate_Ability("Novus_Inverter_Toggle_Shield_Mode", true)
	end
end

function Callback_UEAStrikeforce_MindControlled(object, effect)
	if effect == "AlienWalkerMindMagnetEffect" then
		local object_type_name = object.Get_Type().Get_Name()
		_CustomScriptMessage("JoeLog.txt", string.format("Callback_UEAStrikeforce_MindControlled: %s now under AlienWalkerMindMagnetEffect",  tostring(object_type_name)))
		object.Unregister_Signal_Handler(Callback_UEAStrikeforce_MindControlled)
		Create_Thread("Thread_Follow_The_Science_Walker", object)
	end
end

function Thread_Follow_The_Science_Walker(controlled_dude)	
	if not TestValid(controlled_dude) then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Follow_The_Science_Walker: not TestValid(controlled_dude)"))
	else
		controlled_dude.Override_Max_Speed(1)
		while TestValid(controlled_dude) and TestValid(alien_science_walker02) do
			controlled_dude.Move_To(alien_science_walker02.Get_Position())
			Sleep(1)
		end
		
		if TestValid(controlled_dude) and not TestValid(alien_science_walker02) then
			controlled_dude.Guard_Target(mirabel)
		end
	end
end

function Thread_KamalRex_Enters()
	for i=1,table.getn(kamal_reinforcement_end_location_list) do -- creates a spawn event for each ending-spawn-location
		if TestValid(kamal_reinforcement_end_location_list[i]) then
			Create_Thread("Thread_Alien_Reinforcements", i)
		else
			 _CustomScriptMessage("JoeLog.txt", string.format("WARNING!!! Something is wrong with Thread_KamalRex_Enters"))
		end
	end
end

function Thread_Alien_Reinforcements(i)
   local reinforcement_spawn_point = kamal_reinforcement_end_location_list[i]
	local transport_spawn_location = kamal_reinforcement_start_location_list[i]

	Sleep(i * 3) -- variation for incoming reinforcements

	if not bool_mission_success and not bool_mission_failure then 

		if TestValid(transport_spawn_location) then
			local alien_saucer = Spawn_Unit(object_type_alien_transport, transport_spawn_location, aliens, false)
			if TestValid(alien_saucer) then
				--Add_Radar_Blip(alien_saucer, "Default_Beacon_Placement_Persistent", "blip_reinforcement")

				alien_saucer.Set_Selectable(false)
				alien_saucer.Make_Invulnerable(true)
   			alien_saucer.Change_Owner(neutral)
				local blip_reinforcement = nil
				BlockOnCommand(alien_saucer.Move_To(reinforcement_spawn_point.Get_Position()))
				
				if reinforcement_spawn_point == kamal_reinforcement_end_location_list[1] then --drops kamal off at first dropoff location
					alien_reinforcements = SpawnList(list_kamalrex_reinforcement_units, reinforcement_spawn_point.Get_Position(), aliens, false, true, true)
					Create_Thread("Thread_Add_KamalRex_Objective")
				else
				   -- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
					alien_reinforcements = SpawnList(list_alien_reinforcement_units, reinforcement_spawn_point.Get_Position(), aliens, false, true, true)
				end
					
				Sleep(5)
				Remove_Radar_Blip("blip_reinforcement")
				Hunt(alien_reinforcements, "AntiDefault", true, false)

				if TestValid(alien_saucer) then
					BlockOnCommand(alien_saucer.Move_To(transport_spawn_location.Get_Position()))
					if TestValid(alien_saucer) then
						alien_saucer.Make_Invulnerable(false)
						alien_saucer.Despawn()
					end
				end
			end
		end
	end
end

function Callback_ScienceWalker_Revealed(prox_obj, trigger_obj)
   prox_obj.Cancel_Event_Object_In_Range(Callback_ScienceWalker_Revealed)
   if not science_walkers_revealed then
      science_walkers_revealed = true
	   if TestValid(alien_science_walker01) then
		   alien_science_walker01.Override_Max_Speed(.6)
	   end
	   if TestValid(alien_science_walker02) then
		   alien_science_walker02.Override_Max_Speed(.6)
	   end
	   Create_Thread("Thread_Dialog_Controller", dialog_intro_science_walkers) 
	end
end

function Callback_MutantPens_Revealed()
	if TestValid(pen01_defiler) then
		pen01_defiler.Unregister_Signal_Handler(Callback_MutantPens_Revealed)
	end
	
	Create_Thread("Thread_Dialog_Controller", dialog_intro_mutant_slaves) 
end

function Thread_Deliver_Captive_Civs_Routine(pen_number)
	if pen_number == pen01 then
		while true do
			Sleep(GameRandom(30, 60))
			if bool_pen01_awaiting_delivery then
				if TestValid(pen01_transport_spawnflag) then
					local alien_saucer = Spawn_Unit(object_type_alien_transport, pen01_transport_spawnflag, aliens, false)
					if TestValid(alien_saucer) then
						--Add_Radar_Blip(alien_saucer, "Default_Beacon_Placement_Persistent", "blip_reinforcement")
						alien_saucer.Set_Selectable(false)
						alien_saucer.Make_Invulnerable(true)
         			alien_saucer.Change_Owner(neutral)
						
						BlockOnCommand(alien_saucer.Move_To(pen01_delivery_spot.Get_Position()))
						
						if TestValid(alien_saucer) then
							-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
							pen01_civilian_captives = SpawnList(list_civilian_captives, pen01_fake_delivery_spot.Get_Position(), civilian, false, true, true)
							bool_pen01_awaiting_delivery = false
						end
						
						for i,civilian_captive in pairs(pen01_civilian_captives) do
							if TestValid(civilian_captive) and TestValid(pen01_delivery_spot) then
								civilian_captive.Teleport_And_Face(pen01_delivery_spot)
								civilian_captive.Make_Invulnerable(true)
							end
						end
						
						Sleep(2)
						Create_Thread("Thread_MutantSlave_Routine", pen01)

						if TestValid(alien_saucer) then
							BlockOnCommand(alien_saucer.Move_To(pen01_transport_spawnflag.Get_Position()))
							if TestValid(alien_saucer) then
								alien_saucer.Make_Invulnerable(false)
								alien_saucer.Despawn()
							end
						end
					end
				end
			end
		end
	end
end

function Thread_MutantSlave_Routine(pen_number)
	if pen_number == pen01 then
		if TestValid(pen01_defiler) then 
			pen01_defiler.Prevent_All_Fire(false)
			pen01_defiler.Activate_Ability("Defiler_Radiation_Bleed", true)
			
			Sleep(1)
			for i,civilian_captive in pairs(pen01_civilian_captives) do
				if TestValid(civilian_captive) then
					local spawned_mutant = Spawn_Unit(object_type_mutant, civilian_captive, aliens, false) 
					if TestValid(spawned_mutant) then
						spawned_mutant.Teleport_And_Face(civilian_captive)
						table.insert(pen01_mutant_list, spawned_mutant)
						spawned_mutant.Prevent_AI_Usage(true)						
					else
						MessageBox("ERROR! spawned_mutant coming back as not valid")
					end
					civilian_captive.Despawn()
				end
			end

			Sleep(1)
			if TestValid(pen01_on) then
				BlockOnCommand(pen01_on.Play_Animation("ANIM_SPECIAL_A", false, 0))
			end
			
			Sleep(1)
			if TestValid(pen01_off) then
				pen01_off.Hide(false)
				if TestValid(pen01_on) then
					pen01_on.Despawn()
				end
			end
			
			if TestListValid(pen01_mutant_list) then
				Hunt(pen01_mutant_list, "AntiDefault", true, false, player_base, 150)
			end
			
			if TestValid(pen01_defiler) then
				pen01_defiler.Activate_Ability("Defiler_Radiation_Bleed", false)
			end
			
			pen01_mutant_list = {}
			
			Sleep(10)
			pen01_on = Spawn_Unit(object_type_pen_on, pen01_off, aliens, false) 
			if TestValid(pen01_on) then
				pen01_on.Teleport_And_Face(pen01_off)
			end
			
			if TestValid(pen01_off) then
				pen01_off.Hide(true)
			end
			
			Sleep(5)
			bool_pen01_awaiting_delivery = true
		end
	end
end

function Lock_Out_Stuff(bool)
	masari.Lock_Unit_Ability("Masari_Hero_Zessus", "Masari_Zessus_Retreat_From_Tactical_Unit_Ability", bool, STORY)
	masari.Lock_Unit_Ability("Masari_Hero_Charos", "Masari_Charos_Retreat_From_Tactical_Ability", bool, STORY)
	masari.Lock_Unit_Ability("Masari_Hero_Alatea", "Masari_Alatea_Retreat_From_Tactical_Ability", bool, STORY)
	
	novus.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", bool, STORY)
		
	if bool == true then
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Radiation_Wake"),false,STORY) 
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Arc_Trigger"),false,STORY) 
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Range_Enhancer"),false,STORY) 
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Foo_Chamber"),false,STORY) 
		
		masari.Lock_Effect("Masari_Seer_Cloaking_Effect", false, STORY)
		masari.Lock_Generator("DMAStructureRegenGenerator", false, STORY)
		
		masari.Lock_Unit_Ability("Masari_Architect", "Masari_Rebuild_Unit_Ability", false, STORY)
		masari.Lock_Unit_Ability("Masari_Peacebringer", "Masari_Peacebringer_Disintegrate_Unit_Ability", false, STORY)
		masari.Lock_Unit_Ability("Masari_Figment", "Masary_Figment_Deploy_Mine_Ability", false, STORY)
		masari.Lock_Unit_Ability("Masari_Seeker", "Inquisitor_Destabilize_Unit_Ability", false, STORY)
		masari.Lock_Unit_Ability("Masari_Enforcer", "Masari_Enforcer_Fire_Vortex_Ability", false, STORY)
		
	else
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Radiation_Wake"),true,STORY) 
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Arc_Trigger"),true,STORY) 
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Range_Enhancer"),true,STORY) 
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Foo_Chamber"),true,STORY) 
		
		masari.Lock_Effect("Masari_Seer_Cloaking_Effect", true, STORY)
		masari.Lock_Generator("DMAStructureRegenGenerator", true, STORY)
		
		masari.Lock_Unit_Ability("Masari_Architect", "Masari_Rebuild_Unit_Ability", true, STORY)
		masari.Lock_Unit_Ability("Masari_Peacebringer", "Masari_Peacebringer_Disintegrate_Unit_Ability", true, STORY)
		masari.Lock_Unit_Ability("Masari_Figment", "Masary_Figment_Deploy_Mine_Ability", true, STORY)
		masari.Lock_Unit_Ability("Masari_Seeker", "Inquisitor_Destabilize_Unit_Ability", true, STORY)
		masari.Lock_Unit_Ability("Masari_Enforcer", "Masari_Enforcer_Fire_Vortex_Ability", true, STORY)
	end

end


--***************************************WIN/LOSS STUFF****************************************************************************************************

function Thread_Mission_Failed()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
	if bool_mission_success ~= true then
		bool_mission_failure = true
		Letter_Box_In(1)
      Lock_Controls(1)
      Suspend_AI(1)
      Disable_Automatic_Tactical_Mode_Music()
		
		Play_Music("Lose_To_Alien_Event")     
		Zoom_Camera.Set_Transition_Time(10)
      Zoom_Camera(.3)
      Rotate_Camera_By(180,30)
		
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {failure_text} )
		Sleep(5)
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
		
		Fade_Screen_Out(2)
      Sleep(2)
      Lock_Controls(0)

		Force_Victory(aliens)
	end
end

function Thread_Mission_Complete()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
	if bool_mission_failure ~= true then
		bool_mission_success = true
		if mas07_objective01 ~= nil then
			Objective_Complete(mas07_objective01) 
		end
		
		Letter_Box_In(1)
      Lock_Controls(1)
      Suspend_AI(1)
      Disable_Automatic_Tactical_Mode_Music()

		Play_Music("Masari_Win_Tactical_Event")
      Zoom_Camera.Set_Transition_Time(10)
      Zoom_Camera(.3)
      Rotate_Camera_By(180,90)

		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
		Sleep(5)
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
		Fade_Screen_Out(2)
      Sleep(2)
      Lock_Controls(0)

      Fade_Out_Music()
      BlockOnCommand(Play_Bink_Movie("Masari_Campaign_Finale",true))

		Force_Victory(masari)
	end
end

function Force_Victory(player)
	novus.Reset_Story_Locks()
	aliens.Reset_Story_Locks()
	masari.Reset_Story_Locks()
		
	uea.Allow_AI_Unit_Behavior(true)
	novus.Allow_AI_Unit_Behavior(true)
	aliens.Allow_AI_Unit_Behavior(true)
	
	if player == masari then
		-- Inform the campaign script of our victory.
		global_script.Call_Function("Masari_Tactical_Mission_Over", true) -- true == player wins
		--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
		Quit_Game_Now(player, false, true, false)
	else
      Show_Retry_Dialog()
	end
end


--***************************************DIALOG CONTROLLER****************************************************************************************************
--pip_altea = "ZH_Altea_Pip_head.alo"
--pip_charos
--pip_zessus = "ZH_Zessus_Pip_head.alo"
--pip_masari_comm = 
--pip_moore = "MH_Moore_pip_Head.alo"
--pip_mirabel = "NH_Mirabel_pip_head.alo"
--pip_kamal = "AH_Kamal_Rex_pip_head.alo"

function Thread_Dialog_Controller(conversation)
	if not bool_mission_failed and not bool_mission_success then
		if conversation == dialog_mission_start then
			Queue_Talking_Head(pip_altea, "MAS07_SCENE01_01")--Altea: Charos.. Zessus.. we must destroy the Purifier and end this nightmare.
			--Queue_Talking_Head(pip_masari_comm, "MAS07_SCENE01_02")--Masari Comm Officer: My queen, we have detected the Purifier's signature northeast of your location.
			Queue_Speech_Event("MAS07_SCENE01_02") -- Masari Comm Officer: My queen, we have detected the Purifier's signature northeast of your location.
			local blocking_dialog = Queue_Talking_Head(pip_altea, "MAS07_SCENE01_03")--Altea: Then let us purge this cancer from the world
			BlockOnCommand(blocking_dialog)
			
			bool_opening_dialog_finished = true
		elseif conversation == dialog_purifier_retreats then
			Sleep(3)
			Queue_Talking_Head(pip_charos, "MAS07_SCENE01_04")--Charos (CHA): We have found the Purifier, but they are re-deploying it to the rear.
			Queue_Talking_Head(pip_altea, "MAS07_SCENE01_05")--Altea: Do not let it escape. We must seize the opportunity to destroy it.
		elseif conversation == dialog_enter_uea_and_novus then
			Queue_Talking_Head(pip_moore, "MAS07_SCENE01_06")--General Moore: Somebody call the cavalry? General Randall Moore reporting for duty!
			Queue_Talking_Head(pip_mirabel, "MAS07_SCENE01_07")--Mirabel (MIR): The forces of Novus stand with you as well!
			Queue_Talking_Head(pip_altea, "MAS07_SCENE01_08")--Altea: Then together we shall press the attack.  Engage our enemy!
		elseif conversation == dialog_intro_science_walkers then
			Sleep(6)
			local blockingdialog = Queue_Talking_Head(pip_mirabel, "MAS07_SCENE01_09")--Mirabel (MIR): They have walkers with mind-control capabilities. It's too much.
			-- local blockingdialog = Queue_Talking_Head(pip_moore, "MAS07_SCENE01_10")--General Moore: Another one is emitting radiation.  We can't get past that!
			BlockOnCommand(blockingdialog)
			
			Sleep(2)
			
			Queue_Talking_Head(pip_mirabel, "MAS07_SCENE01_11")--Mirabel (MIR): I'm pulling back.  We'll have to construct a base and strengthen our forces.
			Queue_Talking_Head(pip_moore, "MAS07_SCENE01_12")--General Moore: I'll watch your back.
			local blockingdialog02 = Queue_Talking_Head(pip_altea, "MAS07_SCENE01_13")--Altea: Charos.. Zessus.. we should defend Novus while they fortify their position.
			
			Create_Thread("Thread_Mirabel_Retreats")
			Create_Thread("Thread_GenMoore_Retreats")
			
			BlockOnCommand(blockingdialog02)
			Create_Thread("Thread_Add_Protect_Novus_Objective")
						
			--delaying alien hunt teams unti first science walker is destroyed
			--while TestValid(alien_science_walker02) do
			--	Sleep(1)
			--end
			
			--jdg testing
			Sleep(180)
			
			Create_Thread("Thread_AttackWith_Alienbase_Team01")
			Create_Thread("Thread_AttackWith_Alienbase_Team02")
			Create_Thread("Thread_Main_Alien_Attack_Controller")
			
			if TestValid(alien_science_walker01) then
				alien_science_walker01_guard_spot =  Find_Hint("MARKER_GENERIC_GREEN","radiation-walker-guardspot")
				if not TestValid(alien_science_walker01_guard_spot) then
					_CustomScriptMessage("JoeLog.txt", string.format("ERROR! not TestValid(alien_science_walker01_guard_spot) "))
				else
					alien_science_walker01.Guard_Target(alien_science_walker01_guard_spot.Get_Position())
					_CustomScriptMessage("JoeLog.txt", string.format("alien_science_walker01.Guard_Target(alien_science_walker01_guard_spot.Get_Position())"))
				end
			end
		elseif conversation == dialog_intro_mutant_slaves then
			Queue_Talking_Head(pip_charos, "MAS07_SCENE01_14")--Charos (CHA): The Hierarchy are mutating the human population.  We're being overwhelmed by their numbers.
			Queue_Talking_Head(pip_altea, "MAS07_SCENE01_15")--Altea: Destroy those Defiler units and put an end to this abomination.
		elseif conversation == dialog_intro_masari_superweapons then
			Queue_Talking_Head(pip_charos, "MAS07_SCENE01_16")--Charos (CHA): We should employ the Matter Controller, my queen.  Light mode allows precise beams of damage. Dark mode creates a matter storm to rain down destruction across an area.
		elseif conversation == dialog_kamal_rex_taunt_01 then
			Queue_Talking_Head(pip_kamal, "MAS07_SCENE01_17")--Kamal Rex (KAM): We have conquered a thousand worlds before this one, and a thousand more shall follow! Your efforts are meaningless!
		elseif conversation == dialog_kamal_rex_taunt_02 then
			Queue_Talking_Head(pip_kamal, "MAS07_SCENE01_18")--Kamal Rex (KAM): We fought you once before Masari Queen, and you ran from our victory like the cowards that you are. Today, history will repeat.
		elseif conversation == dialog_intro_kamal_rex then
			Queue_Talking_Head(pip_zessus, "MAS07_SCENE01_20")--Zessus (ZES): We have done it, mother! The Purifier has been destroyed!
			
			if TestValid(kamal_rex) then
				local blockingdialog = Queue_Talking_Head(pip_kamal, "MAS07_SCENE01_19")--Kamal Rex (KAM): There is no army in the universe that can defeat me - your doom is my destiny!
				BlockOnCommand(blockingdialog)

				Sleep(5)
				Queue_Talking_Head(pip_altea, "MAS07_SCENE01_21")--Altea: Do not relent - Kamal Rex still threatens the peace! Stop him!
			else
				--else purifier and kamal are dead...player wins
				if bool_kamal_rex_dead and bool_purifier_dead then
					Create_Thread("Thread_Mission_Complete")
				end
			end
		end
	end
end

function Thread_New_HabitatWalker_Orders(walker_de_habitat)
	if not TestValid(walker_de_habitat) then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_New_HabitatWalker_Orders not TestValid(walker_de_habitat)!!"))
		return
	end
	
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_New_HabitatWalker_Orders HIT!!"))
	
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Habitat_HP_Heat_Sink"), walker_de_habitat, 2)
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Habitat_HP_Lost_One_Mutator"), walker_de_habitat)
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Habitat_HP_Brute_Mutator"), walker_de_habitat)
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Habitat_HP_Plasma_Cannon"), walker_de_habitat, 2)
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Habitat_HP_Arc_Trigger"), walker_de_habitat, 2)
	
	counter_new_habitat_walkers = counter_new_habitat_walkers + 1
	if counter_new_habitat_walkers > 1 then
		counter_new_habitat_walkers = 0
	end
	
	if counter_new_habitat_walkers == 0 then
		Hunt(walker_de_habitat, "MM07_Walker_Priorities", true, false, player_base, 300)
	else
		Hunt(walker_de_habitat, "MM07_Walker_Priorities", true, false, marker_novus_base, 300)
	end
end

function Thread_New_AssemblyWalker_Orders(walker_de_assembly)
	if not TestValid(walker_de_assembly) then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_New_AssemblyWalker_Orders not TestValid(walker_de_assembly)!!"))
		return
	end
	
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_New_AssemblyWalker_Orders HIT!!"))
	
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Assembly_HP_Face_Cap_Armor_Crown"), walker_de_assembly)
	Sleep(3)
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Assembly_HP_Defiler_Assembly_Pod"), walker_de_assembly)
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Assembly_HP_Phase_Tank_Assembly_Pod"), walker_de_assembly)
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Assembly_HP_Plasma_Cannon"), walker_de_assembly, 4)
	
	counter_new_assembly_walkers = counter_new_assembly_walkers + 1
	if counter_new_assembly_walkers > 1 then
		counter_new_assembly_walkers = 0
	end
	
	if counter_new_assembly_walkers == 0 then
		Hunt(walker_de_assembly, "MM07_Walker_Priorities", true, false, player_base, 300)
	else
		Hunt(walker_de_assembly, "MM07_Walker_Priorities", true, false, marker_novus_base, 300)
	end
	
end

function Story_On_Construction_Complete(obj, constructor)

	local obj_type

	if TestValid(obj) then
		obj_type = obj.Get_Type()
		if obj_type == object_type_novus_robotic_assembly then
			novus_robotic_assembly = obj
			if TestValid(novus_robotic_assembly) then
				_CustomScriptMessage("JoeLog.txt", string.format("novus_robotic_assembly detected and defined...requesting upgrade"))
				Story_AI_Request_Build_Hard_Point(novus, object_type_novus_robotic_assembly_upgrade, novus_robotic_assembly)
			end
		elseif obj_type == object_type_novus_robotic_assembly_upgrade then
			_CustomScriptMessage("JoeLog.txt", string.format("novus_robotic_assembly upgraded...starting build routine"))
			Create_Thread("Thread_Novus_Base_Build_Infantry")
			Create_Thread("Thread_AttackWith_Novusbase_Infantry_Team")
		elseif obj_type == object_type_novus_vehicle_assembly then
			novus_vehicle_assembly = obj
			if TestValid(novus_vehicle_assembly) then
				_CustomScriptMessage("JoeLog.txt", string.format("novus_vehicle_assembly detected and defined...requesting upgrade"))
				Story_AI_Request_Build_Hard_Point(novus, object_type_novus_vehicle_assembly_upgrade, novus_vehicle_assembly)
			end
		elseif obj_type== object_type_novus_vehicle_assembly_upgrade then	
			_CustomScriptMessage("JoeLog.txt", string.format("novus_vehicle_assembly upgraded...starting build routine"))
			Create_Thread("Thread_Novus_Base_Build_Vehicles")
			Create_Thread("Thread_AttackWith_Novusbase_Vehicle_Team")
		elseif obj_type== object_type_novus_aircraft_assembly then
			novus_aircraft_assembly = obj
			if TestValid(novus_aircraft_assembly) then
				_CustomScriptMessage("JoeLog.txt", string.format("object_type_novus_aircraft_assembly detected ...requesting novus_aircraft_assembly_upgrade"))
				Story_AI_Request_Build_Hard_Point(novus, object_type_novus_aircraft_assembly_upgrade, novus_aircraft_assembly)
			end
		elseif obj_type == object_type_novus_aircraft_assembly_upgrade then	
			_CustomScriptMessage("JoeLog.txt", string.format("novus_aircraft_assembly upgraded...starting build routine"))
			Create_Thread("Thread_Novus_Base_Build_Aircraft")
			Create_Thread("Thread_AttackWith_Novusbase_Aircraft_Team")
			Create_Thread("Thread_Main_Novus_Attack_Controller")
		elseif obj_type == object_type_novus_science_lab then
			novus_science_lab = obj
			if TestValid(novus_science_lab) then
				_CustomScriptMessage("JoeLog.txt", string.format("novus_science_lab detected and defined"))
			end
		elseif obj_type == object_type_novus_emp_superweapon then
			novus_emp_superweapon = obj
			if TestValid(novus_emp_superweapon) then
				_CustomScriptMessage("JoeLog.txt", string.format("novus_emp_superweapon detected and defined"))
			end
			
		--unit production callbacks
		--NOVUS INFANTRY
		elseif obj_type == object_type_novus_robotic_infantry then
			Create_Thread("Thread_Move_Novusbase_Infantry_Staging_Units", obj)
			counter_current_robotic_infantry = counter_current_robotic_infantry + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Robotic_Infantry_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_novus_building_robotic_infantry = false
		elseif obj_type == object_type_novus_reflex_trooper then
			Create_Thread("Thread_Move_Novusbase_Infantry_Staging_Units", obj)
			counter_current_reflex_troopers = counter_current_reflex_troopers + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Reflex_Trooper_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_novus_building_reflex_trooper = false
			
		--NOVUS VEHICLES
		elseif obj_type == object_type_novus_antimatter_tank then
			Create_Thread("Thread_Move_Novusbase_Vehicle_Staging_Units", obj)
			counter_current_antimatter_tanks = counter_current_antimatter_tanks + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Antimatter_Tank_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_novus_building_antimatter_tanks = false
		elseif obj_type == object_type_novus_field_inverter then
			if fieldinverter_gift01 == nil then
				_CustomScriptMessage("JoeLog.txt", string.format("fieldinverter_gift01 detected"))				
				fieldinverter_gift01 = obj
				obj.Prevent_AI_Usage(true)
				Create_Thread("Thread_Novusbase_Gives_Inverter_Gift", fieldinverter_gift01)
				bool_novus_building_field_inverters = false
			elseif fieldinverter_gift02 == nil then
				_CustomScriptMessage("JoeLog.txt", string.format("fieldinverter_gift02 detected"))		
				fieldinverter_gift02 = obj
				obj.Prevent_AI_Usage(true)
				Create_Thread("Thread_Novusbase_Gives_Inverter_Gift", fieldinverter_gift02)
				bool_novus_building_field_inverters = false
			elseif fieldinverter_gift03 == nil then
				_CustomScriptMessage("JoeLog.txt", string.format("fieldinverter_gift03 detected"))		
				fieldinverter_gift03 = obj
				obj.Prevent_AI_Usage(true)
				Create_Thread("Thread_Novusbase_Gives_Inverter_Gift", fieldinverter_gift03)
				bool_novus_building_field_inverters = false
			else
				Create_Thread("Thread_Move_Novusbase_Vehicle_Staging_Units", obj)
				counter_current_field_inverters = counter_current_field_inverters + 1
				obj.Register_Signal_Handler(Callback_Novusbase_FieldInverter_Killed, "OBJECT_HEALTH_AT_ZERO")
				bool_novus_building_field_inverters = false
			end

		elseif obj_type == object_type_novus_variant then
			Create_Thread("Thread_Move_Novusbase_Vehicle_Staging_Units", obj)
			counter_current_variants = counter_current_variants + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Variant_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_novus_building_variants = false
			
	--NOVUS AIRCRAFT
		elseif obj_type == object_type_novus_dervish_jet then
			Create_Thread("Thread_Move_Novusbase_Aircraft_Staging_Units", obj)
			counter_current_dervish_jets = counter_current_dervish_jets + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Dervish_Jet_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_novus_building_dervish_jets = false
		elseif obj_type == object_type_novus_corruptor then
			Create_Thread("Thread_Move_Novusbase_Aircraft_Staging_Units", obj)
			counter_current_novus_corruptors = counter_current_novus_corruptors + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Corruptor_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_novus_building_corruptors = false 
			
	--ALIEN STRUCTURES
		elseif obj_type == object_type_alien_walker_assembly then 	
			if bool_starting_walkers_dead == true then
				new_assembly_walker = obj
				Create_Thread("Thread_New_AssemblyWalker_Orders", obj)
			end
		
		elseif obj_type == object_type_alien_walker_habitat then 	
			if bool_starting_walkers_dead == true then
				new_habitat_walker = obj
				Create_Thread("Thread_New_HabitatWalker_Orders", obj)
			end
			
	--ALIEN INFANTRY
		elseif obj_type == object_type_alien_grunt then 
			if bool_starting_walkers_dead == true then
				_CustomScriptMessage("JoeLog.txt", string.format("bool_starting_walkers_dead: object_type_alien_grunt built"))
				obj.Prevent_AI_Usage(true)
				obj.Register_Signal_Handler(Callback_HunterGrunt_Killed, "OBJECT_HEALTH_AT_ZERO")
				Hunt(obj, "AntiDefault", true, false)
			else
				obj.Prevent_AI_Usage(true)
				if constructor == alien_team01_habitat_walker then
					_CustomScriptMessage("JoeLog.txt", string.format("object_type_alien_grunt constructor == alien_team01_habitat_walker"))
					Create_Thread("Thread_Move_Alienbase_Team01_Staging_Units", obj)
				else
					_CustomScriptMessage("JoeLog.txt", string.format("object_type_alien_grunt constructor == alien_team02_habitat_walker"))
					Create_Thread("Thread_Move_Alienbase_Team02_Staging_Units", obj)
				end
				
				bool_aliens_building_grunts = false
				counter_current_grunts = counter_current_grunts + 1
				obj.Register_Signal_Handler(Callback_Alien_Grunt_Killed, "OBJECT_HEALTH_AT_ZERO")
			end
		elseif obj_type == object_type_alien_lostone then--only from team01 habitat walker
			if bool_starting_walkers_dead == true then
				_CustomScriptMessage("JoeLog.txt", string.format("bool_starting_walkers_dead: object_type_alien_lostone built"))
				obj.Prevent_AI_Usage(true)
				obj.Register_Signal_Handler(Callback_HunterLostOne_Killed, "OBJECT_HEALTH_AT_ZERO")
				Hunt(obj, "AntiDefault", true, false)
			else
				obj.Prevent_AI_Usage(true)
				_CustomScriptMessage("JoeLog.txt", string.format("object_type_alien_lostone occ detected"))
				Create_Thread("Thread_Move_Alienbase_Team01_Staging_Units", obj)
				bool_aliens_building_lostones = false
				counter_current_lostones = counter_current_lostones + 1
				obj.Register_Signal_Handler(Callback_Alien_LostOne_Killed, "OBJECT_HEALTH_AT_ZERO")
			end
		elseif obj_type == object_type_alien_brute then--only from team02 habitat walker
			if bool_starting_walkers_dead == true then
				_CustomScriptMessage("JoeLog.txt", string.format("bool_starting_walkers_dead: object_type_alien_brute built"))
				obj.Prevent_AI_Usage(true)
				obj.Register_Signal_Handler(Callback_HunterBrute_Killed, "OBJECT_HEALTH_AT_ZERO")
				Hunt(obj, "AntiDefault", true, false)
			else
				_CustomScriptMessage("JoeLog.txt", string.format("object_type_alien_brute occ detected"))
				obj.Prevent_AI_Usage(true)
				Create_Thread("Thread_Move_Alienbase_Team02_Staging_Units", obj)
				bool_aliens_building_brutes = false
				counter_current_brutes = counter_current_brutes + 1
				obj.Register_Signal_Handler(Callback_Alien_Brute_Killed, "OBJECT_HEALTH_AT_ZERO")
			end
		
	--ALIEN VEHICLES	
		elseif obj_type == object_type_alien_defiler then--only from team02 assembly walker
			if bool_starting_walkers_dead == true then
				_CustomScriptMessage("JoeLog.txt", string.format("bool_starting_walkers_dead: object_type_alien_defiler built"))
				obj.Prevent_AI_Usage(true)
				obj.Register_Signal_Handler(Callback_HunterDefiler_Killed, "OBJECT_HEALTH_AT_ZERO")
				Hunt(obj, "AntiDefault", true, false)
			else
				obj.Prevent_AI_Usage(true)
				Create_Thread("Thread_Move_Alienbase_Team02_Staging_Units", obj)
				bool_aliens_building_defilers = false
				counter_current_defilers = counter_current_defilers + 1
				obj.Register_Signal_Handler(Callback_Alien_Defiler_Killed, "OBJECT_HEALTH_AT_ZERO")
			end
		elseif obj_type == object_type_alien_recontank then--only from team01 assembly walker
			if bool_starting_walkers_dead == true then
				_CustomScriptMessage("JoeLog.txt", string.format("bool_starting_walkers_dead: object_type_alien_recontank built"))
				obj.Prevent_AI_Usage(true)
				obj.Register_Signal_Handler(Callback_HunterPhaseTank_Killed, "OBJECT_HEALTH_AT_ZERO")
				Hunt(obj, "AntiDefault", true, false)
			else
				obj.Prevent_AI_Usage(true)
				Create_Thread("Thread_Move_Alienbase_Team01_Staging_Units", obj)
				bool_aliens_building_recontanks = false
				counter_current_recontanks = counter_current_recontanks + 1
				obj.Register_Signal_Handler(Callback_Alien_ReconTank_Killed, "OBJECT_HEALTH_AT_ZERO")
			end
		
		
	--ALIEN AIRCRAFT		
		elseif obj_type == object_type_alien_cylinder then
			obj.Prevent_AI_Usage(true)
			bool_aliens_building_cylinders= false
			counter_current_cylinders = counter_current_cylinders + 1
			obj.Register_Signal_Handler(Callback_Alien_Cylinder_Killed, "OBJECT_HEALTH_AT_ZERO")
		elseif obj_type == object_type_alien_foo then
			obj.Prevent_AI_Usage(true)
			if constructor == alien_team01_assembly_walker then
				Create_Thread("Thread_Move_Alienbase_Team01_Staging_Units", obj)
			else
				Create_Thread("Thread_Move_Alienbase_Team02_Staging_Units", obj)
			end
			bool_aliens_building_foos = false
			counter_current_foos = counter_current_foos + 1
			obj.Register_Signal_Handler(Callback_Alien_Foo_Killed, "OBJECT_HEALTH_AT_ZERO")
		
	--ALIEN WALKER HARDPOINTS 
		elseif obj_type == object_type_alien_defiler_hardpoint then
			if bool_starting_walkers_dead == true then
				if TestValid(new_assembly_walker) then
					_CustomScriptMessage("JoeLog.txt", string.format("object_type_alien_defiler_hardpoint detected: requesting object_type_alien_defiler"))
					Tactical_Enabler_Begin_Production(new_assembly_walker, object_type_alien_defiler, 1, aliens)
				end
			end
		elseif obj_type == object_type_alien_phasetank_hardpoint then
			if bool_starting_walkers_dead == true then
				if TestValid(new_assembly_walker) then
					Tactical_Enabler_Begin_Production(new_assembly_walker, object_type_alien_recontank, 1, aliens)
				end
			end
		elseif obj_type == object_type_alien_lostone_hardpoint then
			if bool_starting_walkers_dead == true then
				if TestValid(new_habitat_walker) then
					Tactical_Enabler_Begin_Production(new_habitat_walker, object_type_alien_lostone, 1, aliens)
					Tactical_Enabler_Begin_Production(new_habitat_walker, object_type_alien_lostone, 1, aliens)
					Tactical_Enabler_Begin_Production(new_habitat_walker, object_type_alien_lostone, 1, aliens)
				end
			end
		elseif obj_type == object_type_alien_brute_hardpoint then
			if bool_starting_walkers_dead == true then
				if TestValid(new_habitat_walker) then
					Tactical_Enabler_Begin_Production(new_habitat_walker, object_type_alien_brute, 1, aliens)
					Tactical_Enabler_Begin_Production(new_habitat_walker, object_type_alien_grunt, 1, aliens)
				end
			end
		end
	end
end

function Callback_HunterGrunt_Killed()
	if TestValid(new_habitat_walker) then
		Tactical_Enabler_Begin_Production(new_habitat_walker, object_type_alien_grunt, 1, aliens)
	end
end

function Callback_HunterLostOne_Killed()
	if TestValid(new_habitat_walker) then
		Tactical_Enabler_Begin_Production(new_habitat_walker, object_type_alien_lostone, 1, aliens)
	end
end

function Callback_HunterBrute_Killed()
	if TestValid(new_habitat_walker) then
		Tactical_Enabler_Begin_Production(new_habitat_walker, object_type_alien_brute, 1, aliens)
	end
end

function Callback_HunterDefiler_Killed()
	if TestValid(new_assembly_walker) then
		Tactical_Enabler_Begin_Production(new_assembly_walker, object_type_alien_defiler, 1, aliens)
	end
end

function Callback_HunterPhaseTank_Killed()
	if TestValid(new_assembly_walker) then
		Tactical_Enabler_Begin_Production(new_assembly_walker, object_type_alien_recontank, 1, aliens)
	end
end

function Thread_Novusbase_Gives_Inverter_Gift(inverter)
	if not TestValid(inverter) then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Novusbase_Gives_Inverter_Gift: not TestValid(inverter) "))
		return
	end
	
	if inverter == fieldinverter_gift01 then
		_CustomScriptMessage("JoeLog.txt", string.format("BlockOnCommand(inverter.Move_To(inverter01_goto.Get_Position()))"))
		BlockOnCommand(inverter.Move_To(inverter01_goto.Get_Position()))
	elseif inverter == fieldinverter_gift02 then
		_CustomScriptMessage("JoeLog.txt", string.format("BlockOnCommand(inverter.Move_To(inverter02_goto.Get_Position()))"))
		BlockOnCommand(inverter.Move_To(inverter02_goto.Get_Position()))
	elseif inverter == fieldinverter_gift03 then
		_CustomScriptMessage("JoeLog.txt", string.format("BlockOnCommand(inverter.Move_To(inverter03_goto.Get_Position()))"))
		BlockOnCommand(inverter.Move_To(inverter03_goto.Get_Position()))
	else
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Novusbase_Gives_Inverter_Gift: unrecognized inverter...giving to ai"))
		inverter.Prevent_AI_Usage(false)
	end
	
	inverter.Activate_Ability("Novus_Inverter_Toggle_Shield_Mode", true)
	inverter.Change_Owner(masari)
end

--NOVUS INFANTRY BUILD ROUTINE STUFF
function Thread_Novus_Base_Build_Infantry()
	while not bool_mission_failure and not bool_mission_success do
		Sleep(5)
		if counter_current_robotic_infantry < counter_max_allowed_robotic_infantry then
			while bool_novus_building_robotic_infantry == true do
				Sleep(1)
			end
			if counter_current_robotic_infantry < counter_max_allowed_robotic_infantry then
				if TestValid(novus_robotic_assembly) then
					if novus_robotic_assembly.Get_Hull() > 0 then
						Tactical_Enabler_Begin_Production(novus_robotic_assembly, object_type_novus_robotic_infantry, 1, novus)
						bool_novus_building_robotic_infantry = true
					end
				else
					break -- structure no longer exists...kill this thread
				end
			end
		end
		
		if counter_current_reflex_troopers < counter_max_allowed_robotic_infantry then
			while bool_novus_building_reflex_trooper == true do
				Sleep(1)
			end
			if counter_current_reflex_troopers < counter_max_allowed_robotic_infantry then	
				if TestValid(novus_robotic_assembly) then
					if novus_robotic_assembly.Get_Hull() > 0 then
						Tactical_Enabler_Begin_Production(novus_robotic_assembly, object_type_novus_reflex_trooper, 1, novus)
						bool_novus_building_reflex_trooper = true
					end
				else
					break -- structure no longer exists...kill this thread
				end
			end
		end
	end
end

function Thread_Move_Novusbase_Infantry_Staging_Units(obj)
	if TestValid(obj) then
		bool_novusbase_infanftry_team_list_in_use = true
		table.insert(list_novusbase_infantry_team, obj)
		bool_novusbase_infanftry_team_list_in_use = false
		BlockOnCommand(obj.Attack_Move(marker_novus_infantry_rally_point.Get_Position()))
	end
end

function Thread_AttackWith_Novusbase_Infantry_Team()
	while not bool_mission_success and not bool_mission_failure do
		Sleep (10)
		if table.getn(list_novusbase_infantry_team) >= novusbase_infantry_team_size then
			while bool_novusbase_infanftry_team_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_novusbase_infantry_team) then
				bool_infantry_team_ready_to_go = true
			end
		end
	end
end

--NOVUS VEHICLE BUILD ROUTINE STUFF
function Thread_Novus_Base_Build_Vehicles()
	while not bool_mission_failure and not bool_mission_success do
		Sleep(5)
		if counter_current_antimatter_tanks < counter_max_allowed_antimatter_tanks then
			while bool_novus_building_antimatter_tanks == true do
				Sleep(1)
			end
			if counter_current_antimatter_tanks < counter_max_allowed_antimatter_tanks then		
				if TestValid(novus_vehicle_assembly) then
					if novus_vehicle_assembly.Get_Hull() > 0 then
						Tactical_Enabler_Begin_Production(novus_vehicle_assembly, object_type_novus_antimatter_tank, 1, novus)
						bool_novus_building_antimatter_tanks = true
					end
				else
					break -- structure no longer exists...kill this thread
				end
			end
		end
		
		if counter_current_variants < counter_max_allowed_variants then
			while bool_novus_building_amplifier_tanks == true do
				Sleep(1)
			end
			if counter_current_variants < counter_max_allowed_variants then
				if TestValid(novus_vehicle_assembly) then
					if novus_vehicle_assembly.Get_Hull() > 0 then
						Tactical_Enabler_Begin_Production(novus_vehicle_assembly, object_type_novus_variant, 1, novus)
						bool_novus_building_variants = true
					end
				else
					break -- structure no longer exists...kill this thread
				end
			end
		end
		
		if counter_current_field_inverters < counter_max_allowed_field_inverters then
			while bool_novus_building_field_inverters == true do
				Sleep(1)
			end
			if counter_current_field_inverters < counter_max_allowed_field_inverters then
				if TestValid(novus_vehicle_assembly) then
					if novus_vehicle_assembly.Get_Hull() > 0 then
						Tactical_Enabler_Begin_Production(novus_vehicle_assembly, object_type_novus_field_inverter, 1, novus)
						bool_novus_building_field_inverters = true
					end
				else
					break -- structure no longer exists...kill this thread
				end
			end
		end
	end
end

function Thread_Move_Novusbase_Vehicle_Staging_Units(obj)
	if TestValid(obj) then
		bool_novusbase_vehicle_team_list_in_use = true
		table.insert(list_novusbase_vehicle_team, obj)
		bool_novusbase_vehicle_team_list_in_use = false
		BlockOnCommand(obj.Attack_Move(marker_novus_vehicle_rally_point.Get_Position()))
	end
end

function Thread_AttackWith_Novusbase_Vehicle_Team()
	while not bool_mission_success and not bool_mission_failure do
		Sleep (120)
		if table.getn(list_novusbase_vehicle_team) >= novusbase_vehicle_team_size then
			while bool_novusbase_vehicle_team_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_novusbase_vehicle_team) then
				bool_vehicle_team_ready_to_go = true
			end
		end
	end
end
	
--NOVUS AIRCRAFT BUILD ROUTINE STUFF
function Thread_Novus_Base_Build_Aircraft()
	while not bool_mission_failure and not bool_mission_success do
		Sleep(5)
		if counter_current_dervish_jets < counter_max_allowed_dervish_jets then
			while bool_novus_building_dervish_jets == true do
				Sleep(1)
			end
			
			if counter_current_dervish_jets < counter_max_allowed_dervish_jets then
				if TestValid(novus_aircraft_assembly) then
					if novus_aircraft_assembly.Get_Hull() > 0 then
						Tactical_Enabler_Begin_Production(novus_aircraft_assembly, object_type_novus_dervish_jet, 1, novus)
						bool_novus_building_dervish_jets = true
					end
				else
					break -- structure no longer exists...kill this thread
				end
			end
		end
		
		if counter_current_novus_corruptors < counter_max_allowed_novus_corruptors then
			while bool_novus_building_corruptors == true do
				Sleep(1)
			end
			if counter_current_novus_corruptors < counter_max_allowed_novus_corruptors then
				if TestValid(novus_aircraft_assembly) then
					if novus_aircraft_assembly.Get_Hull() > 0 then
						Tactical_Enabler_Begin_Production(novus_aircraft_assembly, object_type_novus_corruptor, 1, novus)
						bool_novus_building_corruptors = true 
					end
				else
					break -- structure no longer exists...kill this thread
				end
			end
		end
	end
end

function Thread_Move_Novusbase_Aircraft_Staging_Units(obj)
	if TestValid(obj) then
		bool_novusbase_aircraft_team_list_in_use = true
		table.insert(list_novusbase_aircraft_team, obj)
		bool_novusbase_aircraft_team_list_in_use = false
		if not TestValid(obj) then
			MessageBox("Thread_Move_Novusbase_Aircraft_Staging_Units: not TestValid(obj)")
		end
		
		if not TestValid(marker_novus_aircraft_rally_point) then
			MessageBox("Thread_Move_Novusbase_Aircraft_Staging_Units: not TestValid(marker_novus_aircraft_rally_point)")
		end
		
		BlockOnCommand(obj.Attack_Move(marker_novus_aircraft_rally_point.Get_Position()))
	end
end

function Thread_AttackWith_Novusbase_Aircraft_Team()
	while not bool_mission_success and not bool_mission_failure do
		Sleep (180)
		if table.getn(list_novusbase_aircraft_team) >= novusbase_aircraft_team_size then
			while bool_novusbase_aircraft_team_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_novusbase_aircraft_team) then
				--Hunt(list_novusbase_aircraft_team, "AntiDefault", true, false)
				bool_aircraft_team_ready_to_go = true
			end
			--list_novusbase_aircraft_team = {}
		end
	end
end

function Thread_Main_Novus_Attack_Controller()
	while not bool_mission_success and not bool_mission_failure do
		Sleep(5)
		
		if not TestValid(novus_robotic_assembly) then
			bool_infantry_team_ready_to_go = true --dont want to clog this thread if a production structure is dead
		end
		if not TestValid(novus_vehicle_assembly) then
			bool_vehicle_team_ready_to_go = true
		end 
		if not TestValid(novus_aircraft_assembly) then
			bool_aircraft_team_ready_to_go = true
		end
		
		if bool_infantry_team_ready_to_go == true and bool_vehicle_team_ready_to_go == true and bool_aircraft_team_ready_to_go == true then
			--MessageBox("Thread_Main_Novus_Attack_Controller should be sending out an attack force now")
			bool_infantry_team_ready_to_go = false
			bool_vehicle_team_ready_to_go = false
			bool_aircraft_team_ready_to_go = false
			list_novus_attack_team = {}
			
			for i, unit in pairs(list_novusbase_infantry_team) do
				if TestValid(unit) then
					table.insert(list_novus_attack_team, unit)
				end
			end
			
			for i, unit in pairs(list_novusbase_vehicle_team) do
				if TestValid(unit) then
					table.insert(list_novus_attack_team, unit)
				end
			end
			
			for i, unit in pairs(list_novusbase_aircraft_team) do
				if TestValid(unit) then
					table.insert(list_novus_attack_team, unit)
				end
			end
			
			if TestListValid(list_novus_attack_team) then
				Hunt(list_novus_attack_team, "AntiDefault", true, false)
			end
			
			list_novusbase_infantry_team = {}
			list_novusbase_vehicle_team = {}
			list_novusbase_aircraft_team = {}
			
			if not TestValid(novus_robotic_assembly) and not TestValid(novus_vehicle_assembly) and not TestValid(novus_aircraft_assembly) then
				--all production structures are dead...kill this thread
				return
			end
			
		end
		
	end
end

function Callback_Novusbase_Robotic_Infantry_Killed()
	counter_current_robotic_infantry = counter_current_robotic_infantry - 1
end

function Callback_Novusbase_Reflex_Trooper_Killed()
	counter_current_reflex_troopers = counter_current_reflex_troopers - 1
end

function Callback_Novusbase_Antimatter_Tank_Killed()
	counter_current_antimatter_tanks = counter_current_antimatter_tanks - 1
end

function Callback_Novusbase_FieldInverter_Killed()
	counter_current_field_inverters = counter_current_field_inverters - 1
end

function Callback_Novusbase_Variant_Killed()
	counter_current_variants = counter_current_variants - 1
end

function Callback_Novusbase_Dervish_Jet_Killed()
	counter_current_dervish_jets = counter_current_dervish_jets - 1
end

function Callback_Novusbase_Corruptor_Killed()
	counter_current_novus_corruptors = counter_current_novus_corruptors - 1
end

--**********************************************************************************************
--**********ALIEN TEAM CREATION STUFF****************************************************
--**********************************************************************************************

--ALIEN INFANTRY BUILD ROUTINE STUFF
function Thread_Alien_Base_Build_Infantry()
	while not bool_mission_failure and not bool_mission_success do
		Sleep(5)
		if counter_current_grunts < counter_max_allowed_grunts then
			while bool_aliens_building_grunts == true do
				Sleep(1)
			end
			if counter_current_grunts < counter_max_allowed_grunts then
				--pick a factory to build from 
				local factory_number = GameRandom(1,2)
				if factory_number == 1 then
					if TestValid(alien_team01_habitat_walker) then
						Tactical_Enabler_Begin_Production(alien_team01_habitat_walker, object_type_alien_grunt, 1, aliens)
						bool_aliens_building_grunts = true
					elseif TestValid(alien_team02_habitat_walker) then
						Tactical_Enabler_Begin_Production(alien_team02_habitat_walker, object_type_alien_grunt, 1, aliens)
						bool_aliens_building_grunts = true
					else
						--both factories are dead...kill this thread
						return
					end
				else
					if TestValid(alien_team02_habitat_walker) then
						Tactical_Enabler_Begin_Production(alien_team02_habitat_walker, object_type_alien_grunt, 1, aliens)
						bool_aliens_building_grunts = true
					elseif TestValid(alien_team01_habitat_walker) then
						Tactical_Enabler_Begin_Production(alien_team01_habitat_walker, object_type_alien_grunt, 1, aliens)
						bool_aliens_building_grunts = true
					else
						--both factories are dead...kill this thread
						return
					end
				end
			end
		end
		
		--LOST ONES
		if counter_current_lostones < counter_max_allowed_lostones then 
			while bool_aliens_building_lostones == true do
				Sleep(1)
			end
			if counter_current_lostones < counter_max_allowed_lostones then
				if TestValid(alien_team01_habitat_walker) then
					Tactical_Enabler_Begin_Production(alien_team01_habitat_walker, object_type_alien_lostone, 1, aliens)
					bool_aliens_building_lostones = true
				end
			end
		end
		
		--BRUTES
		if counter_current_brutes < counter_max_allowed_brutes then 
			while bool_aliens_building_brutes == true do
				Sleep(1)
			end
			if counter_current_brutes < counter_max_allowed_brutes then
				if TestValid(alien_team02_habitat_walker) then
					Tactical_Enabler_Begin_Production(alien_team02_habitat_walker, object_type_alien_brute, 1, aliens)
					bool_aliens_building_brutes = true
				end
			end
		end
	end
end

--ALIEN VEHICLES BUILD ROUTINE STUFF
function Thread_Alien_Base_Build_Vehicles()
	while not bool_mission_failure and not bool_mission_success do
		Sleep(5)
		if counter_current_defilers < counter_max_allowed_defilers then
			while bool_aliens_building_defilers == true do
				Sleep(1)
			end
			if counter_current_defilers < counter_max_allowed_defilers then
				if TestValid(alien_team02_assembly_walker) then
					Tactical_Enabler_Begin_Production(alien_team02_assembly_walker, object_type_alien_defiler, 1, aliens)
					bool_aliens_building_defilers = true
				end
			end
		end
		
		--RECON TANKS
		if counter_current_recontanks < counter_max_allowed_recontanks then 
			while bool_aliens_building_recontanks == true do
				Sleep(1)
			end
			if counter_current_recontanks < counter_max_allowed_recontanks then
				if TestValid(alien_team01_assembly_walker) then
					Tactical_Enabler_Begin_Production(alien_team01_assembly_walker, object_type_alien_recontank, 1, aliens)
					bool_aliens_building_recontanks = true
				end
			end
		end
		
		--FOOS
		if counter_current_foos < counter_max_allowed_foos then
			while bool_aliens_building_foos == true do
				Sleep(1)
			end
			if counter_current_foos < counter_max_allowed_foos then
				--pick a factory to build from 
				local factory_number = GameRandom(1,2)
				if factory_number == 1 then
					if TestValid(alien_team01_assembly_walker) then
						Tactical_Enabler_Begin_Production(alien_team01_assembly_walker, object_type_alien_foo, 1, aliens)
						bool_aliens_building_foos = true
					elseif TestValid(alien_team02_assembly_walker) then
						Tactical_Enabler_Begin_Production(alien_team02_assembly_walker, object_type_alien_foo, 1, aliens)
						bool_aliens_building_foos = true
					end
				else
					if TestValid(alien_team02_assembly_walker) then
						Tactical_Enabler_Begin_Production(alien_team02_assembly_walker, object_type_alien_foo, 1, aliens)
						bool_aliens_building_foos = true
					elseif TestValid(alien_team01_assembly_walker) then
						Tactical_Enabler_Begin_Production(alien_team01_assembly_walker, object_type_alien_foo, 1, aliens)
						bool_aliens_building_foos = true
					end
				end
			end
		end
	end
end

function Thread_Move_Alienbase_Team01_Staging_Units(obj)
	BlockOnCommand(obj.Attack_Move(alienbase_rallypoint01.Get_Position()))
	
	if TestValid(obj) then
		bool_alienbase_team01_list_in_use = true 
		table.insert(list_alienbase_team01_team, obj) 
		bool_alienbase_team01_list_in_use = false
	end
end

function Thread_Move_Alienbase_Team02_Staging_Units(obj)
	BlockOnCommand(obj.Attack_Move(alienbase_rallypoint02.Get_Position()))
	
	if TestValid(obj) then
		bool_alienbase_team02_list_in_use = true 
		table.insert(list_alienbase_team02_team, obj) 
		bool_alienbase_team02_list_in_use = false
	end
end

function Thread_AttackWith_Alienbase_Team01()
	while not bool_mission_success and not bool_mission_failure do
		Sleep (10)
		if table.getn(list_alienbase_team01_team) >= desired_alienbase_team01_team_size then
			while bool_alienbase_team01_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_alienbase_team01_team) then
				bool_alienbase_team01_ready_to_go = true
			end
			--list_novusbase_infantry_team = {}
		end
	end
end

function Thread_AttackWith_Alienbase_Team02()
	while not bool_mission_success and not bool_mission_failure do
		Sleep (10)
		if table.getn(list_alienbase_team02_team) >= desired_alienbase_team02_team_size then
			while bool_alienbase_team02_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_alienbase_team02_team) then
				bool_alienbase_team02_ready_to_go = true
			end
			--list_novusbase_infantry_team = {}
		end
	end
end

function Thread_Main_Alien_Attack_Controller()
	while not bool_mission_success and not bool_mission_failure do
		Sleep(GameRandom(60,120))--1 - 2 min minimum time between attacks 
		
		if bool_alienbase_team01_ready_to_go == true and bool_alienbase_team02_ready_to_go == true then
			--MessageBox("Thread_Main_Novus_Attack_Controller should be sending out an attack force now")
			bool_alienbase_team01_ready_to_go = false
			bool_alienbase_team02_ready_to_go = false

			list_alien_attack_team = {}
			
			for i, unit in pairs(list_alienbase_team01_team) do
				if TestValid(unit) then
					table.insert(list_alien_attack_team, unit)
				end
			end
			
			for i, unit in pairs(list_alienbase_team02_team) do
				if TestValid(unit) then
					table.insert(list_alien_attack_team, unit)
				end
			end
			
			if TestListValid(list_alien_attack_team) then
				Hunt(list_alien_attack_team, "AntiDefault", true, false)
			end
			
			list_alienbase_team01_team = {}
			list_alienbase_team02_team = {}

			if not TestValid(alien_team01_habitat_walker) and not TestValid(alien_team02_habitat_walker) and not TestValid(alien_team01_assembly_walker) and not TestValid(alien_team02_assembly_walker)  then
				--all production structures are dead...kill this thread
				return
			end
		end
	end
end
	
function Callback_Alien_Grunt_Killed()
	counter_current_grunts = counter_current_grunts - 1
end

function Callback_Alien_LostOne_Killed()
	counter_current_lostones = counter_current_lostones - 1
end

function Callback_Alien_Brute_Killed()
	counter_current_brutes = counter_current_brutes - 1
end

function Callback_Alien_Defiler_Killed()
	counter_current_defilers = counter_current_defilers - 1
end

function Callback_Alien_ReconTank_Killed()
	counter_current_recontanks = counter_current_recontanks - 1
end

function Callback_Alien_Cylinder_Killed()
	counter_current_cylinders = counter_current_cylinders - 1
end

function Callback_Alien_Foo_Killed()
	counter_current_foos = counter_current_foos - 1
end
	
function TestListValid(list)
	local i, unit, valid
	
	valid = false
	for i, unit in pairs(list) do
		if TestValid(unit) then
			valid = true
			i = table.getn(list)
		end
	end
	return valid
end

function Post_Load_Callback()
	Movie_Commands_Post_Load_Callback()
end
