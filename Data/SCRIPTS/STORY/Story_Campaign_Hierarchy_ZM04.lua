-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM04.lua#51 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM04.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Rich_Donnelly $
--
--            $Change: 85895 $
--
--          $DateTime: 2007/10/15 11:49:01 $
--
--          $Revision: #51 $
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

   -- Debug Bools
	bool_testing = false --will put nufai, orlok, and the purifier into invulnerable mode
	
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_ZM04_Act01",State_ZM04_Act01)
	
	-- Object Types
   object_type_robotic_infantry = Find_Object_Type("Novus_Robotic_Infantry")
   object_type_reflex_trooper = Find_Object_Type("Novus_Reflex_Trooper")
	object_type_antimatter_tank = Find_Object_Type("Novus_Antimatter_Tank")
	object_type_amplifier = Find_Object_Type("Novus_Amplifier")
	object_type_field_inverter = Find_Object_Type("Novus_Field_Inverter")
	object_type_dervish_jet = Find_Object_Type("Novus_Dervish_Jet")
	object_type_corruptor = Find_Object_Type("Novus_Corruptor")
	
	-- Factions
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	military = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")
	aliens02 = Find_Player("Alien_ZM06_KamalRex")
	
	-- Pip Heads
	pip_orlok = "AH_Orlok_Pip_Head.alo"
	pip_kamal = "AH_Kamal_Rex_Pip_head.alo"
	pip_science = "AI_Science_officer_Pip_Head.alo"
	pip_comm = "AI_Comm_officer_Pip_head.alo"
	pip_nufai = "AH_Nufai_Pip_Head.alo"
	pip_mirabel = "NH_Mirabel_pip_head.alo"

	-- Variables
	time_objective_sleep = 5
	time_radar_sleep = 2

	bool_mission_success = false
	bool_mission_failure = false
	bool_opening_cine_finished = false
	bool_purifier_at_base = false
	bool_first_time_mirabel_attacked = true
	bool_nufai_has_reinforced = false
	bool_displaying_hero_under_attack_warning = false
	bool_first_time_gravbomb_base_revealed = true
	bool_show_gravbomb_base = false
	escort_complete = false
	
	scout_mission_overridden = false
	scout_mission_complete = false
	escort_objective_active = false
	bomb_objective_complete = false
	
	scout = nil -- tracking the guy player posts as scout

	sleep_timer_between_attack_warnings = 60

	fow_relocator = nil
	fow_grav_bomb_base = nil
	
	higlight_overlook_area = nil
	
	counter_weapon_crates = 0 --determines itself later
	counter_weapon_crates_destroyed = 0
	
	dialog_bridge_is_guarded = 0
	dialog_purifier_reached_base = 1
	dialog_mirabel_attacked = 2
	dialog_nufai_sends_reinforcements = 3
	dialog_take_out_the_novus_base_first = 4
	dialog_attack_those_weapon_crates = 5
	dialog_novus_is_stupid = 6
	dialog_weaponcrate_objective_complete = 7
	dialog_orlok_killed = 8
	dialog_nufai_killed = 9
	dialog_purifier_killed = 10
	dialog_intro_variants = 11

   total_novusbase_robotic_infantry = 0
   maximum_novusbase_robotic_infantry = 5
   total_novusbase_reflex_trooper = 0
   maximum_novusbase_reflex_trooper = 5
	novusbase_infantry_team_size = 5
	list_novusbase_infantry_team = {}

	total_novusbase_antimatter_tanks = 0
	maximum_novusbase_antimatter_tank= 2
	total_novusbase_amplifiers = 0
	maximum_novusbase_amplifier = 2
	total_novusbase_field_inverters = 0
	maximum_novusbase_field_inverters = 1
	novusbase_vehicle_team_size = 3
	list_novusbase_vehicle_team = {}

	total_novusbase_dervish_jets = 0
	maximum_novusbase_dervish_jets = 2
	total_novusbase_corruptors = 0
	maximum_novusbase_corruptors = 3
	novusbase_aircraft_team_size = 4
	list_novusbase_aircraft_team = {}
	
	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
end


function State_Init(message)
	if message == OnEnter then	
		novus.Allow_Autonomous_AI_Goal_Activation(false)
		masari.Allow_Autonomous_AI_Goal_Activation(false)		

	military.Allow_AI_Unit_Behavior(false)
	novus.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	aliens02.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
		
		_CustomScriptMessage("JoeLog.txt", string.format("\n\n\n\n\n\n\n\n\n\n*****************Story_Campaign_Hierarchy_ZM04 START!"))
		--this following OutputDebug puts a message in the logfile that lets me determine where mission relevent info starts...mainly using to determine what assets need
		--to be pre-cached.
		OutputDebug("\n\n\n#*#*#*#*#*#*#*#*#*#*#*#*#\njdg: Story_Campaign_Hierarchy_ZM04 START!\n#*#*#*#*#*#*#*#*#*#*#*#*#\n")
		
		Cache_Models()
		
		UI_Hide_Research_Button()
		UI_Hide_Sell_Button()
		
		novus.Reset_Story_Locks()
		aliens.Reset_Story_Locks()
		Lock_Out_Stuff(true)
		
		-- Hint System Initialization
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		Register_Hint_Context_Scene(Get_Game_Mode_GUI_Scene())

		-- Radar Initialization
		local radar_filter_id1 = RadarMap.Add_Filter("Radar_Map_Enable", aliens)
		local radar_filter_id2 = RadarMap.Add_Filter("Radar_Map_Allow_Mouse_Input", aliens)
		local radar_filter_id3 = RadarMap.Add_Filter("Radar_Map_Show_Terrain", aliens)
		local radar_filter_id4 = RadarMap.Add_Filter("Radar_Map_Show_FOW", aliens)
		local radar_filter_id5 = RadarMap.Add_Filter("Radar_Map_Show_Owned", aliens)
		local radar_filter_id6 = RadarMap.Add_Filter("Radar_Map_Show_Allied", aliens)
		local radar_filter_id7 = RadarMap.Add_Filter("Radar_Map_Show_Enemy", aliens)
		local radar_filter_id8 = RadarMap.Add_Filter("Radar_Map_Show_Neutral", aliens)

      -- Structures
	   novusbase_remote_terminal = Find_First_Object("NOVUS_REMOTE_TERMINAL")
	   if not TestValid(novusbase_remote_terminal) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find novusbase_remote_terminal!"))
	   end
  	   novusbase_robotic_assembly = Find_Hint("NOVUS_ROBOTIC_ASSEMBLY_WITH_INSTANCE_GENERATOR","novusbase")
	   if not TestValid(novusbase_robotic_assembly) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find novusbase_robotic_assembly!"))
	   end
	   novusbase_vehicle_assembly01 = Find_Hint("NOVUS_VEHICLE_ASSEMBLY_WITH_RESONATION_PROCESSOR","novusbase")
	   if not TestValid(novusbase_vehicle_assembly01) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find novusbase_vehicle_assembly01!"))
	   end
	   novusbase_vehicle_assembly02 = Find_Hint("NOVUS_VEHICLE_ASSEMBLY_WITH_INVERSION_PROCESSOR","novusbase")
	   if not TestValid(novusbase_vehicle_assembly02) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find novusbase_vehicle_assembly02!"))
	   end
   	novusbase_aircraft_assembly = Find_Hint("NOVUS_AIRCRAFT_ASSEMBLY_WITH_SCRAMJET_HANGAR","novusbase")
	   if not TestValid(novusbase_aircraft_assembly) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find novusbase_aircraft_assembly!"))
	   end
	   novusbase_flow_generator = Find_Hint("NOVUS_POWER_ROUTER","novusbase")
	   if not TestValid(novusbase_flow_generator) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find novusbase_flow_generator!"))
	   end
	   novusbase_science_center = Find_Hint("NOVUS_SCIENCE_LAB_WITH_SINGULARITY_COMPRESSOR","novusbase")
	   if not TestValid(novusbase_science_center) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find novusbase_science_center!"))
	   end

      -- Markers
	   alienbase_backdoor = Find_Hint("MARKER_GENERIC_RED","alienbase-backdoor")
	   if not TestValid(alienbase_backdoor) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find alienbase_backdoor!"))
	   end
	   alienbase_frontdoor = Find_Hint("MARKER_GENERIC_RED","alienbase-frontdoor")
	   if not TestValid(alienbase_frontdoor) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find alienbase_frontdoor!"))
	   end
	   mirabel_retreat_spot = Find_Hint("MARKER_GENERIC_RED","mirabel-retreat-spot")
	   if not TestValid(mirabel_retreat_spot) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find mirabel_retreat_spot!"))
	   end
   	transport_exit_location = Find_Hint("MARKER_GENERIC_GREEN","transport-exit")
	   if not TestValid(transport_exit_location) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find transport_exit_location!"))
	   end
	   proxflag_purifier_at_gravbomb_base = Find_Hint("MARKER_GENERIC_RED","proxflag-purifier-at-gravbomb-base")
	   if not TestValid(proxflag_purifier_at_gravbomb_base) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find proxflag_purifier_at_gravbomb_base!"))
		end
	   proxflag_show_gravbomb_base = Find_Hint("MARKER_GENERIC_RED","proxflag-show-gravbomb-base")
	   if not TestValid(proxflag_show_gravbomb_base) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find proxflag_show_gravbomb_base!"))
		end
	   list_proxflags_dont_show_gravbomb_base = Find_All_Objects_With_Hint("proxflag-dont-show-gravbomb-base")
	   if table.getn(list_proxflags_dont_show_gravbomb_base) <= 0 then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find list_proxflags_dont_show_gravbomb_base!"))
	   end
	   gravbomb_base_reveal_flag = Find_Hint("MARKER_GENERIC_RED","gravbomb-base-reveal-flag")
	   if not TestValid(gravbomb_base_reveal_flag) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find gravbomb_base_reveal_flag!"))
		end
	   proxflag_intro_variants = Find_Hint("MARKER_GENERIC_RED","proxflag-intro-variants")
	   if not TestValid(proxflag_intro_variants) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find proxflag_intro_variants!"))
		end
   	marker_novus_infanftry_rally_point = Find_Hint("MARKER_GENERIC_GREEN","novusbase-rallypoint-infantry")
	   if not TestValid(marker_novus_infanftry_rally_point) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find marker_novus_infanftry_rally_point!"))
		end
   	marker_novus_vehicle_rally_point = Find_Hint("MARKER_GENERIC_GREEN","novusbase-rallypoint-vehicles")
	   if not TestValid(marker_novus_vehicle_rally_point) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find marker_novus_vehicle_rally_point!"))
		end
   	marker_novus_aircraft_rally_point = Find_Hint("MARKER_GENERIC_GREEN","novusbase-rallypoint-aircraft")
	   if not TestValid(marker_novus_aircraft_rally_point) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find marker_novus_aircraft_rally_point!"))
		end
	   nufai_guard_spot = Find_Hint("MARKER_GENERIC_GREEN","nufai-guard-spot")
	   if not TestValid(nufai_guard_spot) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find nufai_guard_spot!"))
		end
	   orlok_start_spot = Find_Hint("MARKER_GENERIC_GREEN","orlok-start-spot")
	   if not TestValid(orlok_start_spot) then
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find orlok_start_spot!"))
		end

		Set_Next_State("State_ZM04_Act01")

	end
end

function State_ZM04_Act01(message)
	if message == OnEnter then

	   -- Initial Funds and Production Dependencies
	   local credit_total = 10000
	   credits = aliens.Get_Credits()
	   if credits > credit_total then
		   credits = (credits - credit_total) * -1
		   aliens.Give_Money(credits)
	   elseif credits < credit_total then
		   credits = credit_total - credits
		   aliens.Give_Money(credits)
	   end
	   aliens02.Give_Money(30000)
	   novus.Give_Money(20000)

      -- Faction Colors and Allegiances
	   PGColors_Init_Constants()
	   aliens02.Enable_Colorization(true, COLOR_DARK_RED)
--	   aliens.Enable_Colorization(true, COLOR_RED)
   	military.Make_Ally(novus)
   	novus.Make_Ally(military)
	   aliens.Make_Ally(aliens02)
	   aliens02.Make_Ally(aliens)
	   
	   -- AI Disabling
   	aliens02.Allow_Autonomous_AI_Goal_Activation(false)

      -- Orlok
	   orlok = Find_First_Object("ZM04_Alien_Hero_Orlok")
	   if TestValid(orlok) then
		   orlok.Teleport_And_Face(orlok_start_spot)
		   orlok.Move_To(orlok_start_spot.Get_Position()) 
		   orlok.Register_Signal_Handler(Callback_Orlok_Killed, "OBJECT_HEALTH_AT_ZERO")	
		   -- heroes nerfed late, so adding damage modifier, Orlok old health(2000) / Orlok new health(1200) - 1 = -.4
		   orlok.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.4)
	   else
		   MessageBox("ERROR - cannot find Orlok!")
	   end
	
      -- Proximities
		Register_Prox(proxflag_purifier_at_gravbomb_base, Prox_GravBombBase_Attacks_Purifier, 50, aliens)
		Register_Prox(proxflag_show_gravbomb_base, Prox_Show_Gravbomb_Base, 40, aliens)	
		Register_Prox(proxflag_intro_variants, Prox_Intro_Variants, 70, aliens)
		Register_Prox(proxflag_intro_variants, Prox_Bypass_Scout_Objective, 1100, aliens)
	   Register_Prox(nufai_guard_spot, Prox_Approaching_Hierarchy_Base_Far, 2000, aliens)

	   -- Player Starting Forces
	   list_player_starting_units = Find_All_Objects_Of_Type(aliens)
	   for i, player_starting_unit in pairs(list_player_starting_units) do
		   if TestValid(player_starting_unit) then
			   player_starting_unit.Prevent_AI_Usage(true)
		   end
	   end
	
	   players_reaper = Find_Hint("ALIEN_SUPERWEAPON_REAPER_TURRET","players-reaper")
	   if TestValid(players_reaper) then
		   players_reaper.Activate_Ability("Reaper_Auto_Gather_Resources ", false)
		   players_reaper.Prevent_AI_Usage(true)
		   players_reaper.Move_To(players_reaper.Get_Position())
		   players_reaper.Stop()
	   else
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - not TestValid(players_reaper)"))
		   MessageBox("not TestValid(players_reaper)")
	   end

	   -- Purifier
	   purifier = Find_First_Object("ZM04_Alien_Megaweapon_Purifier")
	   if TestValid(purifier) then
		   purifier.Register_Signal_Handler(Callback_Purifier_Attacked, "OBJECT_DAMAGED")
		   purifier.Register_Signal_Handler(Callback_Purifier_Killed, "OBJECT_HEALTH_AT_ZERO")		
	   else
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR: Cannot find purifier!!!"))
	   end

      -- Nufai	
	   nufai = Find_First_Object("ALIEN_HERO_NUFAI")
	   if TestValid(nufai) then
   		nufai.Teleport_And_Face(nufai_guard_spot)
		   nufai.Set_Selectable(false)
		   UI_Enable_For_Object(nufai, false) 
		   nufai.Register_Signal_Handler(Callback_Nufai_Killed, "OBJECT_HEALTH_AT_ZERO")
		   nufai.Change_Owner(aliens02)	
		   nufai.Add_Reveal_For_Player(aliens)
		   -- heroes nerfed late, so adding damage modifier, Nufai old health(1200) / Nufai new health(800) - 1 = -.34
		   nufai.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.34)
	   else
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - Cannot find nufai!"))
	   end

      -- Nufai's Reinforcements	
	   nufai_reinforcement_list = Find_All_Objects_With_Hint("nufai-reinforcement")
	   for i, nufai_reinforcement in pairs(nufai_reinforcement_list) do
		   if TestValid(nufai_reinforcement) then
			   nufai_reinforcement.Change_Owner(aliens02)	
		   end
	   end
		
	   -- Taking away player control of pre-placed base
	   alien_base_list = Find_All_Objects_With_Hint("alien-base")
	   for i, alien_base_object in pairs(alien_base_list) do
		   if TestValid(alien_base_object) then
			   alien_base_object.Change_Owner(aliens02)	
		   end
	   end
	   alien_base_guard_list = Find_All_Objects_With_Hint("alien-base-guard")
	   for i, alien_base_guard in pairs(alien_base_guard_list) do
		   if TestValid(alien_base_guard) then
			   alien_base_guard.Change_Owner(aliens02)	
		   end
	   end
	   --Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
	   Hunt(alien_base_guard_list, "AntiDefault", false, true, alienbase_backdoor, 350)	
	
	   -- Mirabel is currently chipping in to help guard pass01
	   mirabel = Find_First_Object("NOVUS_HERO_MECH")
	   if TestValid(mirabel) then
		   mirabel.Register_Signal_Handler(Callback_Mirabel_Attacked, "OBJECT_DAMAGED")	
		   mirabel.Set_Cannot_Be_Killed(true) -- no killing mirabel...once damaged to x% she exits stage left   		
		   -- heroes nerfed late, so adding damage modifier, Mirabel old health(1800) / Charos new health(1000) - 1 = -.45
		   mirabel.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.45)
	   else
		   _CustomScriptMessage("JoeLog.txt", string.format("!!!#*#*#*#*#!!!ERROR - Cannot find mirabel!"))
	   end
	
	   -- Hierarchy Structures
	   hierarchy_relocator = Find_First_Object("NM06_MATERIAL_CONDUIT")
	   if TestValid(hierarchy_relocator) then
		   hierarchy_relocator.Make_Invulnerable(true)
		   hierarchy_relocator.Set_Cannot_Be_Killed(true)
		   Register_Prox(hierarchy_relocator, Prox_Approaching_Hierarchy_Base, 400, aliens)
	   else
		   MessageBox("ERROR - cannot find hierarchy_relocator!")
		   _CustomScriptMessage("JoeLog.txt", string.format("ERROR - cannot find hierarchy_relocator!"))
	   end

      -- Assembly Walker
	   assembly_walker = Find_First_Object("Alien_Walker_Assembly")
	   if not TestValid(assembly_walker) then
		   MessageBox("ERROR - not TestValid(assembly_walker)")
	   else
		   assembly_walker.Change_Owner(aliens02)	
		   Create_Thread("Thread_Upgrade_Assembly_Walker")
	   end
	
	   -- Habitat Walker
	   habitat_walker = Find_First_Object("Alien_Walker_Habitat")
	   if not TestValid(habitat_walker) then
		   MessageBox("ERROR - not TestValid(habitat_walker)")
	   else
		   habitat_walker.Change_Owner(aliens02)	
		   Create_Thread("Thread_Upgrade_Habitat_Walker")
	   end
	
	   -- Purifier Attack Team
   	purifier_attackteam_01 = Find_All_Objects_With_Hint("purifier-attackteam01")
   	Hunt(purifier_attackteam_01, "AntiDefault", false, true, purifier_attackteam_01[1], 25)

      -- Set Service Only When Rendered for Novus, Civilians, Aliens, Military	
	   novus_unit_list = Find_All_Objects_Of_Type(novus)
	   civilian_unit_list = Find_All_Objects_Of_Type(civilian)
	   military_unit_list = Find_All_Objects_Of_Type(military)
	   alien_base_unit_list = Find_All_Objects_Of_Type(aliens02)
	   for i, novus_unit in pairs(novus_unit_list) do
		   if TestValid(novus_unit) then
			   novus_unit.Set_Service_Only_When_Rendered(true)
		   end
	   end   	
	   for i, civilian_unit in pairs(civilian_unit_list) do
		   if TestValid(civilian_unit) then
			   civilian_unit.Set_Service_Only_When_Rendered(true)
		   end
	   end
	   for i, military_unit in pairs(military_unit_list) do
		   if TestValid(military_unit) then
			   military_unit.Set_Service_Only_When_Rendered(true)
		   end
	   end
	   for i, alien_base_unit in pairs(alien_base_unit_list) do
		   if TestValid(alien_base_unit) then
			   alien_base_unit.Set_Service_Only_When_Rendered(true)
		   end
	   end

	   -- Gravbomb Base Vehicles
	   gravbomb_base_vehicle_list = Find_All_Objects_With_Hint("gravbomb-base-vehicle")
	   for i, gravbomb_base_vehicle in pairs(gravbomb_base_vehicle_list) do
		   if TestValid(gravbomb_base_vehicle) then
			   gravbomb_base_vehicle.Suspend_Locomotor(true)
		   end
	   end

	   gravbomb_base_inverter_shield01 = Find_Hint("NOVUS_FIELD_INVERTER","gravbomb-base-inverter-shield01")
	   if not TestValid(gravbomb_base_inverter_shield01) then
		   MessageBox("not TestValid(gravbomb_base_inverter_shield01) then")
		   _CustomScriptMessage("JoeLog.txt", string.format("not TestValid(gravbomb_base_inverter_shield01)"))
	   else
		   gravbomb_base_inverter_shield01.Activate_Ability("Novus_Inverter_Toggle_Shield_Mode", true)
	   end

	   gravbomb_base_inverter_guard01_list = Find_All_Objects_With_Hint("gravbomb-base-inverter-guard01")
	   Hunt(gravbomb_base_inverter_guard01_list, "AntiDefault", false, true, gravbomb_base_inverter_shield01, 10)	
	
	   gravbomb_base_inverter_shield02 = Find_Hint("NOVUS_FIELD_INVERTER","gravbomb-base-inverter-shield02")
	   if not TestValid(gravbomb_base_inverter_shield02) then
		   MessageBox("not TestValid(gravbomb_base_inverter_shield02) then")
		   _CustomScriptMessage("JoeLog.txt", string.format("not TestValid(gravbomb_base_inverter_shield02)"))
	   else
		   gravbomb_base_inverter_shield02.Activate_Ability("Novus_Inverter_Toggle_Shield_Mode", true)
	   end
	
	   gravbomb_base_inverter_guard02_list = Find_All_Objects_With_Hint("gravbomb-base-inverter-guard02")
	   Hunt(gravbomb_base_inverter_guard02_list, "AntiDefault", false, true, gravbomb_base_inverter_shield02, 10)	

      -- Novus Transports
	   gravbomb_transport01 = Find_Hint("ZM04_Novus_Transport","gravbomb-transport01")
	   gravbomb_transport02 = Find_Hint("ZM04_Novus_Transport","gravbomb-transport02")
	   gravbomb_transport03 = Find_Hint("ZM04_Novus_Transport","gravbomb-transport03")
	   if TestValid(gravbomb_transport01) then
		   gravbomb_transport01.Suspend_Locomotor(true)
	   end
	   if TestValid(gravbomb_transport02) then
		   gravbomb_transport02.Suspend_Locomotor(true)
	   end
	   if TestValid(gravbomb_transport03) then
		   gravbomb_transport03.Suspend_Locomotor(true)
	   end
	   
	   -- Novus Structures
	   if TestValid(novusbase_remote_terminal) then
	      novusbase_remote_terminal.Make_Invulnerable(true)
	   end
	   if TestValid(novusbase_robotic_assembly) then
	      novusbase_robotic_assembly.Make_Invulnerable(true)
	   end
	   if TestValid(novusbase_vehicle_assembly01) then
	      novusbase_vehicle_assembly01.Make_Invulnerable(true)
	   end
	   if TestValid(novusbase_vehicle_assembly02) then
	      novusbase_vehicle_assembly02.Make_Invulnerable(true)
	   end
	   if TestValid(novusbase_aircraft_assembly) then
	      novusbase_aircraft_assembly.Make_Invulnerable(true)
	   end
	   if TestValid(novusbase_flow_generator) then
	      novusbase_flow_generator.Make_Invulnerable(true)
	   end
	   if TestValid(novusbase_science_center) then
	      novusbase_science_center.Make_Invulnerable(true)
	   end
	   
	   -- Novus Hunt Groups
	   list_robot_hunt01 = Find_All_Objects_With_Hint("robot-hunt01")
	   list_robot_hunt02 = Find_All_Objects_With_Hint("robot-hunt02")
	   list_robot_hunt03 = Find_All_Objects_With_Hint("robot-hunt03")
	   list_robot_hunt04 = Find_All_Objects_With_Hint("robot-hunt04")
	   list_robot_hunt05 = Find_All_Objects_With_Hint("robot-hunt05")
	   list_robot_hunt06 = Find_All_Objects_With_Hint("robot-hunt06")
	   list_robot_hunt07 = Find_All_Objects_With_Hint("robot-hunt07")
	   list_novusbase_guard = Find_All_Objects_With_Hint("novusbase-guard")
	   list_novusbase_rushteam01 = Find_All_Objects_With_Hint("novusbase-rushteam01")
	   list_novusbase_rushteam02 = Find_All_Objects_With_Hint("novusbase-rushteam02")
	   Hunt(list_robot_hunt01, "ZM04_NovusHatesOrlock_Attack_Priorities", true, false, list_robot_hunt01[1], 35)	
	   Hunt(list_robot_hunt02, "ZM04_NovusHatesOrlock_Attack_Priorities", true, false, list_robot_hunt02[1], 35)	
	   Hunt(list_robot_hunt03, "ZM04_NovusHatesOrlock_Attack_Priorities", true, false, list_robot_hunt03[1], 35)	
	   Hunt(list_robot_hunt04, "ZM04_NovusHatesOrlock_Attack_Priorities", true, false, list_robot_hunt04[1], 50)	
	   Hunt(list_robot_hunt05, "ZM04_NovusHatesOrlock_Attack_Priorities", true, false, list_robot_hunt05[1], 50)	
	   Hunt(list_robot_hunt06, "ZM04_NovusHatesOrlock_Attack_Priorities", true, false, list_robot_hunt06[1], 50)	
	   Hunt(list_robot_hunt07, "ZM04_NovusHatesOrlock_Attack_Priorities", true, false, list_robot_hunt07[1], 50)	
	   Hunt(list_novusbase_guard, "AntiDefault", true, false, list_novusbase_guard[1], 250)   	
	   Hunt(list_novusbase_rushteam01, "AntiDefault", true, false, list_novusbase_rushteam01[1], 100)	
	   Hunt(list_novusbase_rushteam02, "AntiDefault", true, false, list_novusbase_rushteam02[1], 100)	

		if bool_testing then
			orlok.Set_Cannot_Be_Killed(true)
			purifier.Set_Cannot_Be_Killed(true)
			orlok.Make_Invulnerable(true)
			purifier.Make_Invulnerable(true)
			nufai.Make_Invulnerable(true)
			nufai.Make_Invulnerable(true)
		end

		Create_Thread("Thread_Mission_Introduction")
	end
end


--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script

function Thread_Mission_Introduction()
   Fade_Screen_Out(0)
   Lock_Controls(1)

   Fade_Out_Music()
	BlockOnCommand(Play_Bink_Movie("Hierarchy_M4_S1",true))
	bool_opening_cine_finished = true

	Point_Camera_At(orlok)
	Sleep(1)
	Start_Cinematic_Camera()
	Letter_Box_In(0.1)
	
	Transition_Cinematic_Target_Key(orlok, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(orlok, 0, 200, 55, 65, 1, 0, 0, 0)
	
	Fade_Screen_In(2) 
	Transition_To_Tactical_Camera(5)
	Sleep(5)
	
	Letter_Box_Out(1)
	Sleep(1)
	
	End_Cinematic_Camera()
	Lock_Controls(0)
	
	Sleep(2)
	Create_Thread("Thread_Dialog_Controller", dialog_take_out_the_novus_base_first) 

	Formation_Guard(nufai_reinforcement_list, nufai)
	
	Create_Thread("Thread_Novus_Base_Build_Infantry")
	Create_Thread("Thread_Novus_Base_Build_Vehicles")
	Create_Thread("Thread_Novus_Base_Build_Aircraft")
	
	Create_Thread("Thread_AttackWith_Novusbase_Infantry_Team")
	Create_Thread("Thread_AttackWith_Novusbase_Vehicle_Team")
end

function Thread_Upgrade_Assembly_Walker()
	Story_AI_Request_Build_Hard_Point(aliens02, Find_Object_Type("Alien_Walker_Assembly_HP_Face_Cap_Armor_Crown"), assembly_walker)
	Story_AI_Request_Build_Hard_Point(aliens02, Find_Object_Type("Alien_Walker_Assembly_HP_Defiler_Assembly_Pod"), assembly_walker)
	Story_AI_Request_Build_Hard_Point(aliens02, Find_Object_Type("Alien_Walker_Assembly_HP_Phase_Tank_Assembly_Pod"), assembly_walker)
	Story_AI_Request_Build_Hard_Point(aliens02, Find_Object_Type("Alien_Walker_Assembly_HP_Plasma_Cannon"), assembly_walker, 4)
end

function Thread_Upgrade_Habitat_Walker()
	Story_AI_Request_Build_Hard_Point(aliens02, Find_Object_Type("Alien_Walker_Habitat_HP_Lost_One_Mutator"), habitat_walker, 1)
	Story_AI_Request_Build_Hard_Point(aliens02, Find_Object_Type("Alien_Walker_Habitat_HP_Material_Optimizer"), habitat_walker, 1)
	Story_AI_Request_Build_Hard_Point(aliens02, Find_Object_Type("Alien_Walker_Habitat_HP_Armor_Crown"), habitat_walker, 1)
	Story_AI_Request_Build_Hard_Point(aliens02, Find_Object_Type("Alien_Walker_Habitat_HP_Plasma_Cannon"), habitat_walker, 4)
end

function Thread_Novus_Base_Build_Infantry()
	while not bool_mission_failure and not bool_mission_success do
		Sleep(5)
		if total_novusbase_robotic_infantry < maximum_novusbase_robotic_infantry then
			if TestValid(novusbase_robotic_assembly) then
				if novusbase_robotic_assembly.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(novusbase_robotic_assembly, object_type_robotic_infantry, 1, novus)
				end
			else
				break -- structure no longer exists...kill this thread
			end
		end
		
		if total_novusbase_reflex_trooper < maximum_novusbase_reflex_trooper then
			if TestValid(novusbase_robotic_assembly) then
				if novusbase_robotic_assembly.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(novusbase_robotic_assembly, object_type_reflex_trooper, 1, novus)
				end
			else
				break -- structure no longer exists...kill this thread
			end
		end
	end
end

function Thread_Novus_Base_Build_Vehicles()
	while not bool_mission_failure and not bool_mission_success do
		Sleep(5)
		if total_novusbase_antimatter_tanks < maximum_novusbase_antimatter_tank then
			while bool_novus_building_antimatter_tanks == true do
				Sleep(1)
			end
					
			if TestValid(novusbase_vehicle_assembly01) then
				if novusbase_vehicle_assembly01.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(novusbase_vehicle_assembly01, object_type_antimatter_tank, 1, novus)
					bool_novus_building_antimatter_tanks = true
				end
			else
				--break -- structure no longer exists...kill this thread
			end
		end
		
		if total_novusbase_amplifiers < maximum_novusbase_amplifier then
			while bool_novus_building_amplifier_tanks == true do
				Sleep(1)
			end
			
			if TestValid(novusbase_vehicle_assembly01) then
				if novusbase_vehicle_assembly01.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(novusbase_vehicle_assembly01, object_type_amplifier, 1, novus)
					bool_novus_building_amplifier_tanks = true
				end
			else
				--break -- structure no longer exists...kill this thread
			end
		end
		
		if total_novusbase_field_inverters < maximum_novusbase_field_inverters then
			while bool_novus_building_field_inverters == true do
				Sleep(1)
			end
		
			if TestValid(novusbase_vehicle_assembly02) then
				if novusbase_vehicle_assembly02.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(novusbase_vehicle_assembly02, object_type_field_inverter, 1, novus)
					bool_novus_building_field_inverters = true
				end
			else
				--break -- structure no longer exists...kill this thread
			end
		end
	end
end

function Thread_Novus_Base_Build_Aircraft()
	while not bool_mission_failure and not bool_mission_success do
		Sleep(5)
		if total_novusbase_dervish_jets < maximum_novusbase_dervish_jets then
			while bool_novus_building_dervish_jets == true do
				Sleep(1)
			end
					
			if TestValid(novusbase_aircraft_assembly) then
				if novusbase_aircraft_assembly.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(novusbase_aircraft_assembly, object_type_dervish_jet, 1, novus)
					bool_novus_building_dervish_jets = true
				end
			else
				break -- structure no longer exists...kill this thread
			end
		end
		
		if total_novusbase_corruptors < maximum_novusbase_corruptors then
			while bool_novus_building_corruptors == true do
				Sleep(1)
			end
			if TestValid(novusbase_aircraft_assembly) then
				if novusbase_aircraft_assembly.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(novusbase_aircraft_assembly, object_type_corruptor, 1, novus)
					bool_novus_building_corruptors = true 
				end
			else
				break -- structure no longer exists...kill this thread
			end
		end
	end
end

function Thread_Add_Objective_Scout_The_Base()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE04_OBJECTIVE_06_ADD"} )--New objective: Post a scout on the ridge.
	Sleep(time_objective_sleep)
	zm04_objective06 = Add_Objective("TEXT_SP_MISSION_HIE04_OBJECTIVE_06")--Post a scout on the ridge.
	Sleep(time_radar_sleep)
	if TestValid(proxflag_show_gravbomb_base) then
		proxflag_show_gravbomb_base.Highlight(true, -25)
		Add_Radar_Blip(proxflag_show_gravbomb_base, "DEFAULT", "blip_overlook")	
		higlight_overlook_area = Create_Generic_Object(Find_Object_Type("Highlight_Area"), proxflag_show_gravbomb_base, neutral)
	end
end

function Thread_Add_Objective_Destroy_The_WeaponCrates()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE04_OBJECTIVE_07_ADD"} )--New objective: Protect and escort the Purifier to the Relocator.
	Sleep(time_objective_sleep)
	zm04_objective07 = Add_Objective("TEXT_SP_MISSION_HIE04_OBJECTIVE_07")
	
	out_string = Get_Game_Text("TEXT_SP_MISSION_HIE04_OBJECTIVE_07")
	out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(counter_weapon_crates_destroyed), 1)
	Set_Objective_Text(zm04_objective07, out_string)
	
	list_novus_weapon_crates = Find_All_Objects_Of_Type("ZM04_NOVUS_GRAVBOMB_CONTAINER")
	
	for i, novus_weapon_crate in pairs(list_novus_weapon_crates) do
		if TestValid(novus_weapon_crate) then
			_CustomScriptMessage("JoeLog.txt", string.format("cyle %d: start", i))
			novus_weapon_crate.Highlight(true, -50)
			_CustomScriptMessage("JoeLog.txt", string.format("cyle %d: novus_weapon_crate.Highlight(true, -50)", i))
			Add_Radar_Blip(novus_weapon_crate, "Default_Beacon_Placement_Persistent", "blip_novus_weapon_crate_"..i)	
			_CustomScriptMessage("JoeLog.txt", string.format("cyle %d: Add_Radar_Blip", i))
			novus_weapon_crate.Register_Signal_Handler(Callback_Novus_WeaponCrate_Killed, "OBJECT_DELETE_PENDING")
			_CustomScriptMessage("JoeLog.txt", string.format("cyle %d: Register_Signal_Handler", i))
			counter_weapon_crates = counter_weapon_crates + 1
			_CustomScriptMessage("JoeLog.txt", string.format("counter_weapon_crates = %d", counter_weapon_crates))
		end
	end
end

function Thread_Show_Gravbomb_Base()
	while true do
		Sleep(1)
		if bool_show_gravbomb_base == true then
			fow_grav_bomb_base = FogOfWar.Reveal(aliens, gravbomb_base_reveal_flag, 600, 600)
		end
		while bool_show_gravbomb_base == true do
			Sleep(1)
		end
		if bool_show_gravbomb_base == false then
			if fow_grav_bomb_base ~= nil then
				fow_grav_bomb_base.Undo_Reveal()
			end
		end
		while bool_show_gravbomb_base == false do
			Sleep(1)
		end
	end
end

function Thread_Novus_Transports_Leave()
	if TestValid(gravbomb_transport01) then
		gravbomb_transport01.Suspend_Locomotor(false)
		Create_Thread("Thread_Novus_Transports_Leave_Real", gravbomb_transport01)
	end
	
	Sleep(2)
	if TestValid(gravbomb_transport02) then
		gravbomb_transport02.Suspend_Locomotor(false)
		Create_Thread("Thread_Novus_Transports_Leave_Real", gravbomb_transport02)
	end
	
	Sleep(2)
	if TestValid(gravbomb_transport03) then
		gravbomb_transport03.Suspend_Locomotor(false)
		Create_Thread("Thread_Novus_Transports_Leave_Real", gravbomb_transport03)
	end
end

function Thread_Novus_Transports_Leave_Real(transport)
	Sleep(3)
	if TestValid(transport) then
		BlockOnCommand(transport.Move_To(transport_exit_location.Get_Position()))
		if TestValid(transport) then
			transport.Despawn()
		end
	end
end

function Thread_GravBombBase_Attacks_Purifier()
	for i, gravbomb_base_vehicle in pairs(gravbomb_base_vehicle_list) do
		if TestValid(gravbomb_base_vehicle) then
			gravbomb_base_vehicle.Suspend_Locomotor(false)
			gravbomb_base_vehicle.Prevent_All_Fire(false)
		end
	end
	Formation_Attack_Move(gravbomb_base_vehicle_list, purifier)
end

function Thread_Novus_Attacks_Purifier()
	if TestValid(purifier) and not escort_complete then
		for i, purifier_attacker in pairs(purifier_attackteam_01) do
			if TestValid(purifier_attacker) then
				purifier_attacker.Set_Service_Only_When_Rendered(false)
				purifier_attacker.Attack_Move(purifier)
			end
		end
	end
end

function Thread_TurnOn_Escort_Objective()
   escort_objective_active = true
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE04_OBJECTIVE_01_ADD"} )--New objective: Protect and escort the Purifier to the Relocator.

   Sleep(time_objective_sleep)
	zm04_objective01 = Add_Objective("TEXT_SP_MISSION_HIE04_OBJECTIVE_01")--Protect and escort the Purifier to the Relocator.
	purifier_escort_complete = false

	Sleep(time_radar_sleep)
	if TestValid(hierarchy_relocator) then
		fow_relocator = FogOfWar.Reveal(aliens, hierarchy_relocator, 50, 50)
		hierarchy_relocator.Highlight(true)
		Add_Radar_Blip(hierarchy_relocator, "DEFAULT", "blip_objective01")	
	end
end

function Thread_Approaching_Hierarchy_Base()
	while bool_purifier_at_base == false do
		Sleep(1)
	end
	
	aliens02.Enable_Colorization(true, COLOR_RED)
	Remove_Radar_Blip("blip_purifier")
	Remove_Radar_Blip("blip_objective01")
	if TestValid(hierarchy_relocator) then
		hierarchy_relocator.Highlight(false)
	end
	if TestValid(purifier) then
		purifier.Highlight(false)
	end
	purifier_escort_complete = true
	Objective_Complete(zm04_objective01)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE04_OBJECTIVE_01_COMPLETE"})--Objective complete: Protect and escort the Purifier to the Relocator.	
	
	--now giving  player control of pre-placed base objects
	for i, alien_base_object in pairs(alien_base_list) do
		if TestValid(alien_base_object) then
			alien_base_object.Set_Service_Only_When_Rendered(false)
			alien_base_object.Change_Owner(aliens)
		end
	end
	for i, alien_base_guard in pairs(alien_base_guard_list) do
		if TestValid(alien_base_guard) then
			alien_base_guard.Set_Service_Only_When_Rendered(false)
			alien_base_guard.Change_Owner(aliens)		
		end
	end
	
	-- added by JGS 6/21/07 re-enabling sell button when base is given over to player
	UI_Show_Sell_Button()
	
	if TestValid(assembly_walker) then
		assembly_walker.Set_Service_Only_When_Rendered(false)
		assembly_walker.Change_Owner(aliens)		
		assembly_walker.Override_Max_Speed(.6)
	end
	
	if TestValid(habitat_walker) then
		habitat_walker.Set_Service_Only_When_Rendered(false)
		habitat_walker.Change_Owner(aliens)	
		habitat_walker.Override_Max_Speed(.6)
	end
	
	Hunt(list_novusbase_rushteam01, "AntiDefault", true, false, alienbase_backdoor, 100)	
	Hunt(gravbomb_base_vehicle_list, "AntiDefault", true, false, alienbase_frontdoor, 100)	

	Sleep(time_objective_sleep)
	if not bool_mission_failure then
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE04_OBJECTIVE_02_ADD"})--New objective: Defend the Purifier while Nufai activates the Relocator.
	   Sleep(time_objective_sleep)
		zm04_objective02 = Add_Objective("TEXT_SP_MISSION_HIE04_OBJECTIVE_02")--Defend the Purifier while Nufai activates the Relocator.
		
		Sleep(time_radar_sleep)
	   if not bool_mission_failure then
		   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE04_OBJECTIVE_05_ADD"})--New objective: Destroy the Novus base.
		   Sleep(time_objective_sleep)
		   zm04_objective03 = Add_Objective("TEXT_SP_MISSION_HIE04_OBJECTIVE_05")--Destroy the Novus base.
   		
   		-- Take Novus base off of render restrictions
		   for i, novus_unit in pairs(novus_unit_list) do
			   if TestValid(novus_unit) then
				   novus_unit.Set_Service_Only_When_Rendered(false)
			   end
		   end
   	
		   -- Add radar blip to Novus base
		   novus_base_location = novusbase_remote_terminal.Get_Position()
		   Add_Radar_Blip(novus_base_location, "DEFAULT", "blip_novus_base_location")

		   Create_Thread("Thread_Monitor_Win_Conditions")
	   end
	end
	
	Sleep(25)
	Hunt(list_novusbase_rushteam02, "AntiDefault", true, false, alienbase_frontdoor, 100)		
end

function Thread_Nufai_Sends_Reinforcements()

	Sleep(15)
	if TestValid(purifier) then
		Create_Thread("Thread_Dialog_Controller", dialog_nufai_sends_reinforcements) 
		for i, nufai_reinforcement in pairs(nufai_reinforcement_list) do
			if TestValid(nufai_reinforcement) then
				nufai_reinforcement.Set_Service_Only_When_Rendered(false)
				nufai_reinforcement.Change_Owner(aliens)	
				nufai_reinforcement.Override_Max_Speed(5)--yawn...over-riding multiplayer creep-balancing
				nufai_reinforcement.Guard_Target(purifier)
			end
		end
		if TestValid(nufai_reinforcement_list[1]) then
			Add_Radar_Blip(nufai_reinforcement_list[1], "Default_Beacon_Placement_Persistent", "blip_nufai_reinforcements")	
		end

		Sleep(20)
		Remove_Radar_Blip("blip_nufai_reinforcements")		
	end
end

function Thread_Monitor_Win_Conditions()
	if TestValid(novusbase_remote_terminal) then
	   novusbase_remote_terminal.Make_Invulnerable(false)
	end
	if TestValid(novusbase_robotic_assembly) then
	   novusbase_robotic_assembly.Make_Invulnerable(false)
	end
	if TestValid(novusbase_vehicle_assembly01) then
	   novusbase_vehicle_assembly01.Make_Invulnerable(false)
	end
	if TestValid(novusbase_vehicle_assembly02) then
	   novusbase_vehicle_assembly02.Make_Invulnerable(false)
	end
	if TestValid(novusbase_aircraft_assembly) then
	   novusbase_aircraft_assembly.Make_Invulnerable(false)
	end
	if TestValid(novusbase_flow_generator) then
	   novusbase_flow_generator.Make_Invulnerable(false)
	end
	if TestValid(novusbase_science_center) then
	   novusbase_science_center.Make_Invulnerable(false)
	end
	while TestValid(novusbase_remote_terminal) do
		Sleep(1)
	end
	while TestValid(novusbase_robotic_assembly) do
		Sleep(1)
	end
	while TestValid(novusbase_vehicle_assembly01) do
		Sleep(1)
	end
	while TestValid(novusbase_vehicle_assembly02) do
		Sleep(1)
	end
	while TestValid(novusbase_aircraft_assembly) do
		Sleep(1)
	end
	while TestValid(novusbase_flow_generator) do
		Sleep(1)
	end
	while TestValid(novusbase_science_center) do
		Sleep(1)
	end
	Remove_Radar_Blip("blip_novus_base_location")
   Objective_Complete(zm04_objective02)
	Objective_Complete(zm04_objective03)
	Create_Thread("Thread_Mission_Complete")
end

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
		Play_Music("Lose_To_Novus_Event")     
		Zoom_Camera.Set_Transition_Time(10)
      Zoom_Camera(.3)
      Rotate_Camera_By(180,30)
      -- the variable  failure_text  is set at the start of mission to contain the default string "TEXT_SP_MISSION_MISSION_FAILED"
      -- upon mission failure of an objective, or hero death, replace the string  failure_text  with the appropriate xls tag 
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {failure_text} )
      Sleep(5)
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
      Fade_Screen_Out(2)
      Sleep(2)
      Lock_Controls(0)
      Force_Victory(novus)
	end
end

function Thread_Mission_Complete()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
	if bool_mission_failure ~= true then
		bool_mission_success = true
      Letter_Box_In(1)
      Lock_Controls(1)
      Suspend_AI(1)
      Disable_Automatic_Tactical_Mode_Music()
      Play_Music("Alien_Win_Tactical_Event")
      Zoom_Camera.Set_Transition_Time(10)
      Zoom_Camera(.3)
      Rotate_Camera_By(180,90)
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
      Sleep(5)
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
      Fade_Screen_Out(2)
      Sleep(2)
		
		Fade_Out_Music()
		BlockOnCommand(Play_Bink_Movie("Hierarchy_M4_S3",true))
		
      Lock_Controls(0)
      Force_Victory(aliens)
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
				BlockOnCommand(Formation_Attack_Move(list_novusbase_infantry_team, alienbase_backdoor.Get_Position()))
				Hunt(list_novusbase_infantry_team, "AntiDefault", true, false, alienbase_backdoor, 100)
			end
			list_novusbase_infantry_team = {}
		end
	end
end

function Thread_AttackWith_Novusbase_Vehicle_Team()
	while not bool_mission_success and not bool_mission_failure do
		Sleep (10)
		if table.getn(list_novusbase_vehicle_team) >= novusbase_vehicle_team_size then
			while bool_novusbase_vehicle_team_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_novusbase_vehicle_team) then
				BlockOnCommand(Formation_Attack_Move(list_novusbase_vehicle_team, alienbase_frontdoor.Get_Position()))
				Hunt(list_novusbase_vehicle_team, "AntiDefault", true, false, alienbase_frontdoor, 100)
			end
			list_novusbase_vehicle_team = {}
		end
	end
end


function Thread_AttackWith_Novusbase_Aircraft_Team()
	while not bool_mission_success and not bool_mission_failure do
		Sleep (10)
		if table.getn(list_novusbase_aircraft_team) >= novusbase_aircraft_team_size then
			while bool_novusbase_aircraft_team_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_novusbase_aircraft_team) then
				BlockOnCommand(Formation_Attack_Move(list_novusbase_aircraft_team, alienbase_frontdoor.Get_Position()))
				Hunt(list_novusbase_aircraft_team, "AntiDefault", true, false, alienbase_frontdoor, 100)
			end
			list_novusbase_aircraft_team = {}
		end
	end
end


--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script

function Prox_GravBombBase_Attacks_Purifier(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == aliens then
		prox_obj.Cancel_Event_Object_In_Range(Prox_GravBombBase_Attacks_Purifier)
		Create_Thread("Thread_GravBombBase_Attacks_Purifier")
	end
end

function Prox_Show_Gravbomb_Base(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Show_Gravbomb_Base)
	if not scout_mission_overridden then
		Objective_Complete(zm04_objective06)
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE04_OBJECTIVE_06_COMPLETE"})--Objective complete: Protect and escort the Purifier to the Relocator.	
   	Function_Show_Gravbomb_Base(trigger_obj)
   end
end

function Function_Show_Gravbomb_Base(trigger_obj)
   scout_mission_complete = true
	scout = trigger_obj
	bool_show_gravbomb_base = true
	
	for i, proxflag_dont_show_gravbomb_base in pairs(list_proxflags_dont_show_gravbomb_base) do
		if TestValid(proxflag_dont_show_gravbomb_base) then
			Register_Prox(proxflag_dont_show_gravbomb_base, Prox_Dont_Show_Gravbomb_Base, 20, aliens)
		end
	end
	
	if bool_first_time_gravbomb_base_revealed then
		bool_first_time_gravbomb_base_revealed = false
		Create_Thread("Thread_Show_Gravbomb_Base")
		Create_Thread("Thread_Novus_Transports_Leave")

		if TestValid(proxflag_show_gravbomb_base) then
			proxflag_show_gravbomb_base.Highlight(false)
			Remove_Radar_Blip("blip_overlook")
			if TestValid(higlight_overlook_area) then
				higlight_overlook_area.Despawn()
			end
		end
		
		Create_Thread("Thread_Dialog_Controller", dialog_attack_those_weapon_crates) 
	end
end

function Prox_Dont_Show_Gravbomb_Base(prox_obj, trigger_obj)
	--if trigger_obj.Get_Owner() == aliens then
	
	if trigger_obj == scout then -- player has moved the guy off the scout position
		scout = nil
	
		--have to take into account the lost ones phase ability...apparantly they can traverse "Impassible" in this mode (for now)
		for i, proxflag_dont_show_gravbomb_base in pairs(list_proxflags_dont_show_gravbomb_base) do
			if TestValid(proxflag_dont_show_gravbomb_base) then
				proxflag_dont_show_gravbomb_base.Cancel_Event_Object_In_Range(Prox_Dont_Show_Gravbomb_Base)
			end
		end
		
		bool_show_gravbomb_base = false
		
		if TestValid(proxflag_show_gravbomb_base) then
			Register_Prox(proxflag_show_gravbomb_base, Prox_Show_Gravbomb_Base, 40, aliens)
		end
	end
end

function Prox_Intro_Variants(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == aliens then
		prox_obj.Cancel_Event_Object_In_Range(Prox_Intro_Variants)
		Create_Thread("Thread_Dialog_Controller", dialog_intro_variants) 
	end
end

function Prox_Bypass_Scout_Objective(prox_obj, trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Bypass_Scout_Objective)
   if not scout_mission_complete then
      scout_mission_overridden = true
		Delete_Objective(zm04_objective06)
		Function_Show_Gravbomb_Base(trigger_obj)
   end
end

function Prox_Approaching_Hierarchy_Base(prox_obj, trigger_obj)
	if trigger_obj == purifier and not bool_mission_failure then
		_CustomScriptMessage("JoeLog.txt", string.format("Prox_Approaching_Hierarchy_Base HIT!"))
		prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Hierarchy_Base)
		
		Create_Thread("Thread_Dialog_Controller", dialog_purifier_reached_base) 
		Create_Thread("Thread_Approaching_Hierarchy_Base")
		Create_Thread("Thread_AttackWith_Novusbase_Aircraft_Team")
	end
end

function Prox_Approaching_Hierarchy_Base_Far(prox_obj, trigger_obj)
	if trigger_obj == purifier and not escort_objective_active and not bool_mission_failure then
   	prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Hierarchy_Base_Far)
   	if not bomb_objective_complete then
   	   bomb_objective_complete = true
   	   Delete_Objective(zm04_objective07)
   	end
	   Create_Thread("Thread_TurnOn_Escort_Objective")
	end
end

function Callback_Novus_WeaponCrate_Killed()
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_Novus_WeaponCrate_Killed HIT!!"))
	
	counter_weapon_crates = counter_weapon_crates - 1
	counter_weapon_crates_destroyed = counter_weapon_crates_destroyed + 1
	if counter_weapon_crates < 0 then counter_weapon_crates = 0 end
	if counter_weapon_crates_destroyed > 4 then counter_weapon_crates_destroyed = 4 end
	_CustomScriptMessage("JoeLog.txt", string.format("counter_weapon_crates = %d", counter_weapon_crates))
	_CustomScriptMessage("JoeLog.txt", string.format("counter_weapon_crates_destroyed = %d", counter_weapon_crates_destroyed))
	
	out_string = Get_Game_Text("TEXT_SP_MISSION_HIE04_OBJECTIVE_07")
	out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(counter_weapon_crates_destroyed), 1)
	if not bomb_objective_complete then
	   Set_Objective_Text(zm04_objective07, out_string)
	end
	
	if counter_weapon_crates == 3 then
		Create_Thread("Thread_Dialog_Controller", dialog_novus_is_stupid) 
	elseif counter_weapon_crates == 0 then
	   if not bomb_objective_complete then
         bomb_objective_complete = true
		   Create_Thread("Thread_Dialog_Controller", dialog_weaponcrate_objective_complete) 
		   Objective_Complete(zm04_objective07)
		   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE04_OBJECTIVE_07_COMPLETE"})--Objective complete: Protect and escort the Purifier to the Relocator.	
		end
	   Create_Thread("Thread_Novus_Attacks_Purifier")
	end
end

function Callback_Purifier_Attacked(obj, attacker)
	if not bool_nufai_has_reinforced then
		if attacker.Get_Type() == Find_Object_Type("NOVUS_CORRUPTOR") then
			Create_Thread("Thread_Nufai_Sends_Reinforcements")
			bool_nufai_has_reinforced = true
		end
	end
	
	if not bool_mission_success and not bool_mission_failure and not bool_displaying_hero_under_attack_warning then
		bool_displaying_hero_under_attack_warning = true
		if purifier.Get_Hull() > 0 and purifier.Get_Hull() < 0.1  then
			Queue_Talking_Head(pip_orlok, "HIE04_SCENE03_04")--We're about to lose the Purifier!
		else
			local warning_number = GameRandom(1,2)
			if warning_number == 1 then
				Queue_Talking_Head(pip_orlok, "HIE04_SCENE03_03")--The Purifier is under attack, protect it at all costs!
			else
				Queue_Talking_Head(pip_orlok, "HIE04_SCENE03_08")--Don't separate the Purifier from our escort. We're the only defense it has.
			end
		end
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE04_WARNING_PURIFIER_UNDER_ATTACK"} )
		Create_Thread("Thread_Hero_Attack_Warning_TimeOut")
	end
end

function Thread_Hero_Attack_Warning_TimeOut() -- all this does is prevent spamming of attack warnings...timer is defined in definitions at top
	Sleep(sleep_timer_between_attack_warnings)
	bool_displaying_hero_under_attack_warning = false
end

function Callback_Orlok_Killed()
	if not bool_mission_success and not bool_mission_failure then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
	
		Create_Thread("Thread_Dialog_Controller", dialog_orlok_killed)
				
		bool_mission_failure = true
		failure_text = "TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ORLOK"
		Create_Thread("Thread_Mission_Failed")
	end
end

function Callback_Nufai_Killed()
	if not bool_mission_success and not bool_mission_failure then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
		
		Create_Thread("Thread_Dialog_Controller", dialog_nufai_killed)

		bool_mission_failure = true
		failure_text = "TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_NUFAI"
		Create_Thread("Thread_Mission_Failed")
	end
end

function Callback_Purifier_Killed()
	if not bool_mission_success and not bool_mission_failure then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
		
		Create_Thread("Thread_Dialog_Controller", dialog_purifier_killed)
		
		bool_mission_failure = true
		failure_text = "TEXT_SP_MISSION_HIE04_MISSION_FAILED_PURIFIER_DEAD" --Mission failed: The Purifier must survive.
		Create_Thread("Thread_Mission_Failed")
	end
end

function Cache_Models()
	Find_Object_Type("Novus_Robotic_Infantry").Load_Assets()
	Find_Object_Type("NOVUS_DERVISH_JET").Load_Assets()
	Find_Object_Type("NOVUS_ANTIMATTER_TANK").Load_Assets()
	Find_Object_Type("NOVUS_Corruptor").Load_Assets()
	Find_Object_Type("Novus_Reflex_Trooper").Load_Assets()
	Find_Object_Type("Novus_Variant").Load_Assets()
	Find_Object_Type("Alien_Walker_Habitat").Load_Assets()
	Find_Object_Type("Alien_Walker_Assembly").Load_Assets()
	Find_Object_Type("Alien_Walker_Science").Load_Assets()
	Find_Object_Type("Alien_Glyph_Carver").Load_Assets()
	Find_Object_Type("Alien_Cylinder").Load_Assets()
	Find_Object_Type("Alien_Foo_Core").Load_Assets()
	Find_Object_Type("Singularity").Load_Assets()
end

function Lock_Out_Stuff(bool)
	-- Construction Locks/Unlocks
	aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science"),bool, STORY)
	aliens.Lock_Object_Type(Find_Object_Type("Alien_Brute"),bool, STORY)
	aliens.Lock_Object_Type(Find_Object_Type("Alien_Recon_Tank"),bool, STORY)
	aliens.Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Retreat_From_Tactical_Ability", bool, STORY)
	
	if bool == true then
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Grey_Phase_Unit_Ability", false, STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Lost_One_Plasma_Bomb_Unit_Ability", false, STORY)
		aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("Alien_Grunt"), "Grunt_Grenade_Attack", false, STORY)
	else
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Grey_Phase_Unit_Ability", true, STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Lost_One_Plasma_Bomb_Unit_Ability", true, STORY)
		aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("Alien_Grunt"), "Grunt_Grenade_Attack", true, STORY)
	end
end

function Callback_Mirabel_Attacked()
	if bool_first_time_mirabel_attacked == true then
		bool_first_time_mirabel_attacked = false
		Create_Thread("Thread_Dialog_Controller", dialog_mirabel_attacked) 
	end
	
	-- Mirabel has been attacked...we dont want her to get killed, so check what her health is and force a retreat when she's under 25%
	local mirabel_health = mirabel.Get_Health()
	mirabel_health = mirabel_health*100
	_CustomScriptMessage("JoeLog.txt", string.format("Mirabel attacked....current health is %d", mirabel_health))
	if mirabel_health <= 25 then
		mirabel.Unregister_Signal_Handler(Callback_Mirabel_Attacked)
		Create_Thread("Thread_Mirabel_Retreats")
	else
		return
	end
end

function Thread_Mirabel_Retreats()
	--prevent further damage and combat
	mirabel.Make_Invulnerable(true)
	mirabel.Prevent_All_Fire(true)
	mirabel.Prevent_Opportunity_Fire(true) 
	_CustomScriptMessage("JoeLog.txt", string.format("START BlockOnCommand(mirabel.Move_To(mirabel_retreat_spot.Get_Position()))"))
	BlockOnCommand(mirabel.Move_To(mirabel_retreat_spot.Get_Position()))
	_CustomScriptMessage("JoeLog.txt", string.format("END BlockOnCommand(mirabel.Move_To(mirabel_retreat_spot.Get_Position()))"))
	if TestValid(mirabel) then
		-- should probably make her use her retreat function here (eventually)
		mirabel.Despawn()
	end	
end

function Thread_Dialog_Controller(conversation)
	if not bool_mission_failed and not bool_mission_success then
		if conversation == dialog_approaching_novus_main_base_firstwarning and bool_purifier_at_base ~= true then
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_orlok, "HIE04_SCENE03_05")--Orlok (ORL): The main route is heavily protected - bring the Purifier around to the east!
			end
		elseif conversation == dialog_approaching_novus_main_base_secondwarning and bool_purifier_at_base ~= true then
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_nufai, "HIE04_SCENE03_10")--Nufai (NUF): You're getting too close to their main base - keep the Purifier away from danger!
			end
		elseif conversation == dialog_purifier_reached_base then
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_orlok, "HIE04_SCENE04_01")--Orlok (ORL): Nufai, is the Uplink ready?
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_nufai, "HIE04_SCENE04_02")--Nufai (NUF): Soon! The altitude here gives us problems. 
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_orlok, "HIE04_SCENE04_03")--Orlok (ORL): Bigger problems are about to arrive on our door! We're running out of time.
			end
			if not bool_mission_failed and not bool_mission_success then
				local blocking_dialog = Queue_Talking_Head(pip_nufai, "HIE04_SCENE07_09")--Nufai (NUF): Nufai needs time to activate the uplink... I give control of the base to you now, Commander.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_comm, "HIE04_SCENE07_30")--Comm: Our sensors show a Novus base west of your position, Commander. They pose a direct threat.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_orlok, "HIE04_SCENE07_11")--Orlok (ORL): Then we must go on the offensive. Nufai, we'll summon an assault force and hold Novus off as long as we can!
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_nufai, "HIE04_SCENE07_10")--Nufai (NUF): Remember, Commander - our saucers can provide repairs. Use Assembly Walkers to build them.
				BlockOnCommand(blocking_dialog)
				bool_purifier_at_base = true
			end
		elseif conversation == dialog_mirabel_attacked then
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_nufai, "HIE04_SCENE07_08")--Nufai (NUF): We've spotted the Novus lieutenant known as Mirabel. Kill her and we can decapitate their leadership.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "HIE04_SCENE04_05")--Mirabel (MIR): I advise you to surrender now, Hierarchy slave. Machines are immortal.. but your flesh is not.
			end
		elseif conversation == dialog_nufai_sends_reinforcements then
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_nufai, "HIE04_SCENE03_11")--Nufai (NUF): Nufai sends reinforcements your way. Look for them.
			end
		elseif conversation == dialog_take_out_the_novus_base_first then
			--ping the radar here
			if not bool_mission_failed and not bool_mission_success then
				Add_Radar_Blip(gravbomb_base_reveal_flag.Get_Position(), "Game_Event_Info_High_Importance_Persistent", "blip_novus_gravbomb_base")
				Queue_Talking_Head(pip_comm, "HIE04_SCENE07_19") --We have detected a large Novus presence to the east that must be cleared.
			end
			Sleep(3)
			Remove_Radar_Blip("blip_novus_gravbomb_base")
			if not bool_mission_failed and not bool_mission_success then
				if not scout_mission_overridden then
   				local blocking_dialog = Queue_Talking_Head(pip_orlok, "HIE04_SCENE07_20") --Orlok (ORL): We'll post a unit on that ridge.  From that vantage point, we'll have a tactical view of Novus' movements.
	   			BlockOnCommand(blocking_dialog)
				   Create_Thread("Thread_Add_Objective_Scout_The_Base")
				end
			end
			Sleep(10)
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_orlok, "HIE04_SCENE07_25") --We should use the Reaper to gather resources as we go.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_comm, "HIE04_SCENE07_26") --We've detected large quantities of animal life in the area that should be suitable. 
			end
		elseif conversation == dialog_attack_those_weapon_crates then
			Sleep(5)
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_orlok, "HIE04_SCENE07_23") --Orlok (ORL): Novus appears to be guarding those crates for some reason.  They could be for weapon storage.
			end
			if not bool_mission_failed and not bool_mission_success then
				local blocking_dialog = Queue_Talking_Head(pip_orlok, "HIE04_SCENE07_24") --Orlok (ORL): We'll deploy a Lost One to infiltrate the base.  It can plant plasma bombs and destroy those weapons crates.
				BlockOnCommand(blocking_dialog)
			   Create_Thread("Thread_Add_Objective_Destroy_The_WeaponCrates")
			end
		elseif conversation == dialog_novus_is_stupid then
			Sleep(4)
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_orlok, "HIE04_SCENE07_18") --Orlok (ORL): I would expect a better war-plan from machines. Is that the best they can muster?
			end
		elseif conversation == dialog_weaponcrate_objective_complete then
			Sleep(3)
			if not bool_mission_failed and not bool_mission_success then
				BlockOnCommand(Queue_Talking_Head(pip_orlok, "HIE04_SCENE07_16")) --Orlok (ORL): These machines are obsolete.  They lack the programming for victory.
			end
			Sleep(1)
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_nufai, "HIE04_SCENE07_27")--Nufai (NUF): What is your status, Commander?
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_orlok, "HIE04_SCENE07_28")--The Purifier is still intact.  We've eliminated the Novus outpost and are heading your way.
			end
			if not escort_objective_active then
			   Create_Thread("Thread_TurnOn_Escort_Objective")
			end
		elseif conversation == dialog_orlok_killed then	
			if not bool_mission_failed and not bool_mission_success then
				bool_mission_failed = true
				Stop_All_Speech() -- stopping any other mission dialog that might be going on.
				Queue_Talking_Head(pip_nufai, "HIE04_SCENE07_15")--Nufai (NUF): Nufai is almost done, Commander. Commander Orlok? 
			end
		elseif conversation == dialog_nufai_killed then	
			if not bool_mission_failed and not bool_mission_success then
				bool_mission_failed = true
				Stop_All_Speech() -- stopping any other mission dialog that might be going on.
				Queue_Talking_Head(pip_orlok, "HIE04_SCENE07_14")--Orlok (ORL): Nufai, what is your status? Nufai? Are you there?
			end
		elseif conversation == dialog_purifier_killed then	
			if not bool_mission_failed and not bool_mission_success then
				bool_mission_failed = true
				Stop_All_Speech() -- stopping any other mission dialog that might be going on.
				Queue_Talking_Head(pip_nufai, "HIE04_SCENE07_12")--Nufai (NUF): Commander, we have failed our mission! Kamal will execute us!
			end
		elseif conversation == dialog_intro_variants then		
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_comm, "HIE04_SCENE07_29")--Novus has the ability to mimic their surroundings. Be alert to their trickery.
			end
		end
	end
end

function Story_On_Construction_Complete(obj, constructor)
	local obj_type
	
	if TestValid(obj) then
		obj_type = obj.Get_Type()
		if obj_type == object_type_robotic_infantry then
			Create_Thread("Thread_Move_Novusbase_Infantry_Staging_Units", obj)
			total_novusbase_robotic_infantry = total_novusbase_robotic_infantry + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Robotic_Infantry_Killed, "OBJECT_HEALTH_AT_ZERO")

		elseif obj_type == object_type_reflex_trooper then
			Create_Thread("Thread_Move_Novusbase_Infantry_Staging_Units", obj)
			total_novusbase_reflex_trooper = total_novusbase_reflex_trooper + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Reflex_Trooper_Killed, "OBJECT_HEALTH_AT_ZERO")

		elseif obj_type == object_type_antimatter_tank then
			Create_Thread("Thread_Move_Novusbase_Vehicle_Staging_Units", obj)
			total_novusbase_antimatter_tanks = total_novusbase_antimatter_tanks + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Antimatter_Tank_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_novus_building_antimatter_tanks = false

		elseif obj_type == object_type_amplifier then 
			Create_Thread("Thread_Move_Novusbase_Vehicle_Staging_Units", obj)
			total_novusbase_amplifiers = total_novusbase_amplifiers + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Amplifier_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_novus_building_amplifier_tanks = false
				
		elseif obj_type == object_type_field_inverter then 
			Create_Thread("Thread_Move_Novusbase_Vehicle_Staging_Units", obj)
			total_novusbase_field_inverters = total_novusbase_field_inverters + 1
			obj.Register_Signal_Handler(Callback_Novusbase_FieldInverter_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_novus_building_field_inverters = false
			
		elseif obj_type == object_type_dervish_jet then 
			Create_Thread("Thread_Move_Novusbase_Aircraft_Staging_Units", obj)
			total_novusbase_dervish_jets = total_novusbase_dervish_jets + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Dervish_Jet_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_novus_building_dervish_jets = false
			
		elseif obj_type == object_type_corruptor then 
			Create_Thread("Thread_Move_Novusbase_Aircraft_Staging_Units", obj)
			total_novusbase_corruptors = total_novusbase_corruptors + 1
			obj.Register_Signal_Handler(Callback_Novusbase_Corruptor_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_novus_building_corruptors = false 
		end
	end
end

function Thread_Move_Novusbase_Infantry_Staging_Units(obj)
	if TestValid(obj) then
		bool_novusbase_infanftry_team_list_in_use = true
		table.insert(list_novusbase_infantry_team, obj)
		bool_novusbase_infanftry_team_list_in_use = false
		BlockOnCommand(obj.Attack_Move(marker_novus_infanftry_rally_point.Get_Position()))
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

function Thread_Move_Novusbase_Aircraft_Staging_Units(obj)
	if TestValid(obj) then
		bool_novusbase_aircraft_team_list_in_use = true
		table.insert(list_novusbase_aircraft_team, obj)
		bool_novusbase_aircraft_team_list_in_use = false
		BlockOnCommand(obj.Attack_Move(marker_novus_aircraft_rally_point.Get_Position()))
	end
end

function Callback_Novusbase_Robotic_Infantry_Killed()
	total_novusbase_robotic_infantry = total_novusbase_robotic_infantry - 1
end

function Callback_Novusbase_Reflex_Trooper_Killed()
	total_novusbase_reflex_trooper = total_novusbase_reflex_trooper - 1
end

function Callback_Novusbase_Antimatter_Tank_Killed()
	total_novusbase_antimatter_tanks = total_novusbase_antimatter_tanks - 1
end

function Callback_Novusbase_Amplifier_Killed()
	total_novusbase_amplifiers = total_novusbase_amplifiers - 1
end

function Callback_Novusbase_FieldInverter_Killed()
	total_novusbase_field_inverters = total_novusbase_field_inverters - 1
end

function Callback_Novusbase_Dervish_Jet_Killed()
	total_novusbase_dervish_jets = total_novusbase_dervish_jets - 1
end

function Callback_Novusbase_Corruptor_Killed()
	total_novusbase_corruptors = total_novusbase_corruptors - 1
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

function Force_Victory(player)

	Lock_Out_Stuff(false)

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

	if purifier_escort_complete then
		UI_Show_Sell_Button()
	else
		UI_Hide_Sell_Button()
	end
	Movie_Commands_Post_Load_Callback()
end

