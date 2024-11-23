-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM05.lua#44 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hierarchy_ZM05.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Dan_Etter $
--
--            $Change: 90434 $
--
--          $DateTime: 2008/01/07 16:47:00 $
--
--          $Revision: #44 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGMoveUnits")
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
	
	-- States
	Define_State("State_Init", State_Init)
	Define_State("State_ZM05_Act01",State_ZM05_Act01)
	
	-- Factions
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	military = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")
	player_faction = Find_Player("Alien")

--	PGColors_Init_Constants()
--	aliens.Enable_Colorization(true, COLOR_RED)
--	masari.Enable_Colorization(true, COLOR_DARK_GREEN)
	
	-- Pip head objects
	dialog_hie_comm = "AI_Comm_Officer_Pip_Head.alo"
	dialog_kamal = "AH_Kamal_Rex_Pip_Head.alo"
	dialog_orlok = "AH_Orlok_Pip_Head.alo"
	dialog_hie_science = "AI_Science_Officer_Pip_Head.alo"
	dialog_nufai = "AH_Nufai_Pip_Head.alo"
	dialog_zessus = "ZH_Zessus_pip_head.alo"

	-- Unit Lists
	
	list_grunt_reinforcements = {
	   "Alien_Grunt",
	   "Alien_Grunt",
	   "Alien_Grunt",
	   "Alien_Grunt",
	   "Alien_Grunt",
	   "Alien_Grunt",
	   "Alien_Grunt",
	   "Alien_Grunt",
	   "Alien_Brute",
	   "Alien_Brute"
	}
	
	list_brute_reinforcements = {
	   "Alien_Brute",
	   "Alien_Brute"
	}
	
	-- Variables
   bridge_2_destroyed = false
	civ_spawner_off = false
	mission_success = false
	mission_failure = false
	found_village = false
	found_entrance = false
	found_hangar = false
	brute_inside_hangar = false
	zombie_distraction = false
	objective_modified = false
	hm05_objective_00_given = false
	hm05_objective_00_completed = false
	hm05_objective_01_given = false
	hm05_objective_01_completed = false
	hm05_objective_02_given = false
	hm05_objective_02_completed = false
	hm05_objective_03_given = false
	hm05_objective_03_completed = false
	hm05_objective_04_given = false
	hm05_objective_04_completed = false
	hm05_objective_05_given = false
	hm05_objective_05_completed = false
	hm05_objective_06_given = false
	hm05_objective_06_completed = false
	
	zessus_intro_conversation_complete = false
	zessus_explode_taunt_given = false
	
	time_objective_sleep = 5
	time_radar_sleep = 2
	
	time_delay_brute_check = 10
	
	total_alien_forces = 2
	total_slaves = 0
	slave_counter = 0
	pat_0_counter = 0
	pat_1_counter = 0
	pat_2_counter = 0
	pat_3_counter = 0
	pat_5_counter = 0
	jump_turrets_killed = 0
	defiler_counter = 2
	reinforce_state = 0
	zessus_teleport_busy = false
	teleport00_made = false
	teleport01_made = false
	teleport02_made = false
	
	objective = {}
	objective_text = {}
	objective_add = {}
	objective_completed = {}
	
	-- Object Types
	object_type_zombie = Find_Object_Type("ALIEN_MUTANT_SLAVE")
	
	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		novus.Allow_Autonomous_AI_Goal_Activation(false)
		masari.Allow_Autonomous_AI_Goal_Activation(false)		
	
	military.Allow_AI_Unit_Behavior(false)
	novus.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
		
		_CustomScriptMessage("RickLog.txt", string.format("*********************************************Story_Campaign_Hierarchy_ZM05 START!"))
		
		Lock_Objects(true)

		UI_Hide_Research_Button()
		UI_Hide_Sell_Button()
		
		-- ***** ACHIEVEMENT_AWARD *****
		PGAchievementAward_Init()
		-- ***** ACHIEVEMENT_AWARD *****
		
		-- ***** HINT SYSTEM *****
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		local scene = Get_Game_Mode_GUI_Scene()
		Register_Hint_Context_Scene(scene)			-- Set the scene to which independant hints will be attached.
		-- ***** HINT SYSTEM *****
		
		Set_Active_Context("ZM05")
		
		masari.Set_Elemental_Mode("Ice")
		
		--Various Units
		bridgebuilding_1 = Find_Hint("HM05_GATEWAY_INHIBITOR","bridge1building")
		bridgebuilding_1.Register_Signal_Handler(Callback_bridge1building_Killed, "OBJECT_HEALTH_AT_ZERO")
		bridgebuilding_2 = Find_Hint("HM05_GATEWAY_INHIBITOR","bridge2building")
		bridgebuilding_2.Register_Signal_Handler(Callback_bridge2building_Killed, "OBJECT_HEALTH_AT_ZERO")
		
		-- Markers
--		bridge1_1_flag = Find_Hint("MARKER_GENERIC_RED","bridge1-1")
--		bridge1_2_flag = Find_Hint("MARKER_GENERIC_RED","bridge1-2")
--		bridge1_3_flag = Find_Hint("MARKER_GENERIC_RED","bridge1-3")
--		bridge1_4_flag = Find_Hint("MARKER_GENERIC_RED","bridge1-4")
--		bridge2_1_flag = Find_Hint("MARKER_GENERIC_RED","bridge2-1")
--		bridge2_2_flag = Find_Hint("MARKER_GENERIC_RED","bridge2-2")
--		bridge2_3_flag = Find_Hint("MARKER_GENERIC_RED","bridge2-3")
--		bridge2_4_flag = Find_Hint("MARKER_GENERIC_RED","bridge2-4")
      bridge1 = Find_Hint("HM05_Masari_Light_Bridge_Middle","bridge1")
      if TestValid(bridge1) then
         bridge1.Make_Invulnerable(true)
      end
      bridge2 = Find_Hint("HM05_Masari_Light_Bridge_Middle","bridge2")
      if TestValid(bridge2) then
         bridge2.Make_Invulnerable(true)
      end
		village = Find_Hint("MARKER_GENERIC_YELLOW","village")
		obj_d_prox = Find_Hint("MARKER_GENERIC","objdprox")
		obj_e_prox = Find_Hint("MARKER_GENERIC","objeprox")
		outpost_prox = Find_Hint("MARKER_GENERIC","outpostprox")
		island_blip = Find_Hint("MARKER_GENERIC","islandblip")
		village_1 = Find_Hint("MARKER_GENERIC_YELLOW","village1")
		village_2 = Find_Hint("MARKER_GENERIC_YELLOW","village2")
		zessus_teleport_00 = Find_Hint("MARKER_GENERIC_BLUE","zessustport00")
		zessus_teleport_01 = Find_Hint("MARKER_GENERIC_BLUE","zessustport01")
		zessus_teleport_02 = Find_Hint("MARKER_GENERIC_BLUE","zessustport02")
		zessus_home = Find_Hint("MARKER_GENERIC_BLUE","zessushome")
		transport_spawn = Find_Hint("MARKER_GENERIC_YELLOW","transportspawn")
		foo_0_spawn = Find_Hint("MARKER_GENERIC_YELLOW","foo0spawn")
		foo_1_spawn = Find_Hint("MARKER_GENERIC_YELLOW","foo1spawn")
		foo_0_goto = Find_Hint("MARKER_GENERIC_GREEN","foo0goto")
		foo_1_goto = Find_Hint("MARKER_GENERIC_GREEN","foo1goto")
		orlok_spawn = Find_Hint("MARKER_GENERIC_GREEN","orlokspawn")
		brute0_spawn = Find_Hint("MARKER_GENERIC_GREEN","brutespawn0")
		brute1_spawn = Find_Hint("MARKER_GENERIC_GREEN","brutespawn1")
		transport_spawn_1 = Find_Hint("MARKER_GENERIC_YELLOW","transportspawn1")
		grunt0_spawn = Find_Hint("MARKER_GENERIC_GREEN","gruntspawn0")
		grunt1_spawn = Find_Hint("MARKER_GENERIC_GREEN","gruntspawn1")
		grunt2_spawn = Find_Hint("MARKER_GENERIC_GREEN","gruntspawn2")
		grunt3_spawn = Find_Hint("MARKER_GENERIC_GREEN","gruntspawn3")
		obj_4_blip_a = Find_Hint("MARKER_GENERIC","obj4blipa")
		obj_4_blip_b = Find_Hint("MARKER_GENERIC","obj4blipb")
		
		--Object Stuff
		asian_hut_1_list = Find_All_Objects_Of_Type("ASIAN_HUT_01")
		for i, building in pairs(asian_hut_1_list) do
			if TestValid(building) then
				building.Make_Invulnerable(true)
			end
		end
		asian_hut_2_list = Find_All_Objects_Of_Type("ASIAN_HUT_02")
		for i, building in pairs(asian_hut_2_list) do
			if TestValid(building) then
				building.Make_Invulnerable(true)
			end
		end
		asian_hut_3_list = Find_All_Objects_Of_Type("ASIAN_HUT_03")
		for i, building in pairs(asian_hut_3_list) do
			if TestValid(building) then
				building.Make_Invulnerable(true)
			end
		end
		asian_hut_4_list = Find_All_Objects_Of_Type("ASIAN_HUT_04")
		for i, building in pairs(asian_hut_4_list) do
			if TestValid(building) then
				building.Make_Invulnerable(true)
			end
		end
		
		
		jump_turret_0 = Find_Hint("MASARI_GUARDIAN","jumpturret0")
		jump_turret_0.Register_Signal_Handler(Callback_Jump_Turrets_Killed, "OBJECT_DELETE_PENDING")
		jump_turret_1 = Find_Hint("MASARI_GUARDIAN","jumpturret1")
		jump_turret_1.Register_Signal_Handler(Callback_Jump_Turrets_Killed, "OBJECT_DELETE_PENDING")
		jump_turret_2 = Find_Hint("MASARI_GUARDIAN","jumpturret2")
		jump_turret_2.Register_Signal_Handler(Callback_Jump_Turrets_Killed, "OBJECT_DELETE_PENDING")
		jump_turret_3 = Find_Hint("MASARI_GUARDIAN","jumpturret3")
		jump_turret_3.Register_Signal_Handler(Callback_Jump_Turrets_Killed, "OBJECT_DELETE_PENDING")
		
		--Starting Defiler
		defiler0 = Find_Hint("ALIEN_DEFILER","startingdefiler0")
		defiler1 = Find_Hint("ALIEN_DEFILER","startingdefiler1")
		if not TestValid(defiler0) then
			MessageBox("Story_Campaign_Hierarchy_ZM05 cannot find the Starting Defiler 0!")
		end	
		if not TestValid(defiler1) then
			MessageBox("Story_Campaign_Hierarchy_ZM05 cannot find the Starting Defiler 1!")
		end
		
		-- Orlok
		hero = Find_First_Object("Alien_Hero_Orlok")
		if TestValid(hero) then
		
   		-- Orlok 1200 from 2000 = -.4
		   hero.Add_Attribute_Modifier("Universal_Damage_Modifier", -.4)
		   
		   hero.Register_Signal_Handler(Callback_Orlok_Killed, "OBJECT_DELETE_PENDING")
			hero.Set_Object_Context_ID("hide_me")
		else
			--MessageBox("Story_Campaign_Hierarchy_ZM05 cannot find Orlok!")
			hero = Spawn_Unit(Find_Object_Type("Alien_Hero_Orlok"), defiler0, aliens)

   		-- Orlok 1200 from 2000 = -.4
		   hero.Add_Attribute_Modifier("Universal_Damage_Modifier", -.4)

			hero.Register_Signal_Handler(Callback_Orlok_Killed, "OBJECT_DELETE_PENDING")
			hero.Set_Object_Context_ID("hide_me")
		end
		
		-- Zessus
		zessus = Find_First_Object("Masari_Hero_Zessus")
		if not TestValid(zessus) then
			MessageBox("Story_Campaign_Hierarchy_ZM05 cannot find Zessus!")
	   else
   		-- Zessus 800 from 2500 = -.68
		   zessus.Add_Attribute_Modifier("Universal_Damage_Modifier", -.68)	   
		end
		Create_Thread("Establishing_Shot", defiler0)		
		
		civ_spawn_list_0 = Find_All_Objects_With_Hint("village0spawn")
		for i, marker in pairs(civ_spawn_list_0) do
			if TestValid(marker) then
				marker.Set_In_Limbo(true)	
			end
		end
		civ_spawn_list_1 = Find_All_Objects_With_Hint("village1spawn")
		for i, marker in pairs(civ_spawn_list_1) do
			if TestValid(marker) then
				marker.Set_In_Limbo(true)	
			end
		end
		civ_spawn_list_2 = Find_All_Objects_With_Hint("village2spawn")
		for i, marker in pairs(civ_spawn_list_2) do
			if TestValid(marker) then
				marker.Set_In_Limbo(true)	
			end
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
		
		Set_Next_State("State_ZM05_Act01")
				
	end
end

function Lock_Objects(boolean)
		
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Kamal_Rex"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Nufai"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Orlok"),boolean,STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Grey_Phase_Unit_Ability", false,STORY)
		aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("Alien_Grunt"), "Grunt_Grenade_Attack", false, STORY)
		aliens.Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Retreat_From_Tactical_Ability", true,STORY)
end

function State_ZM05_Act01(message)
	if message == OnEnter then
		
		--Starting Defiler
		defiler0.Register_Signal_Handler(Callback_Defiler_Killed, "OBJECT_HEALTH_AT_ZERO")
		defiler1.Register_Signal_Handler(Callback_Defiler_Killed, "OBJECT_HEALTH_AT_ZERO")
		
		-- Zessus
		zessus.Make_Invulnerable(true)
		zessus.Register_Signal_Handler(Callback_Zessus_Killed, "OBJECT_HEALTH_AT_ZERO")
		zessus.Add_Attribute_Modifier("Teleportation_Recharge_Mult",3)
		
		-- Hunt Groups
		--Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
		patrol_0 = Find_All_Objects_With_Hint("pat0")
		for i, unit in pairs(patrol_0) do
			pat_0_counter = pat_0_counter + 1
			unit.Register_Signal_Handler(Callback_Patrol_0_Handler, "OBJECT_DELETE_PENDING")
		end
		Hunt(patrol_0, "PrioritiesLikeOneWouldExpectThemToBe", false, true, patrol_0[1], 50)
		
		patrol_1 = Find_All_Objects_With_Hint("pat1")
		for i, unit in pairs(patrol_1) do
			pat_1_counter = pat_1_counter + 1
			unit.Register_Signal_Handler(Callback_Patrol_1_Handler, "OBJECT_DELETE_PENDING")
		end
		Hunt(patrol_1, "PrioritiesLikeOneWouldExpectThemToBe", true, true, patrol_1[1], 100)
		
		patrol_2 = Find_All_Objects_With_Hint("pat2")
		for i, unit in pairs(patrol_2) do
			pat_2_counter = pat_2_counter + 1
			unit.Register_Signal_Handler(Callback_Patrol_2_Handler, "OBJECT_DELETE_PENDING")
		end
		Hunt(patrol_2, "PrioritiesLikeOneWouldExpectThemToBe", true, true, patrol_2[1], 100)
		
		patrol_3 = Find_All_Objects_With_Hint("pat3")
		for i, unit in pairs(patrol_3) do
			pat_3_counter = pat_3_counter + 1
			unit.Register_Signal_Handler(Callback_Patrol_3_Handler, "OBJECT_DELETE_PENDING")
		end
		Hunt(patrol_3, "PrioritiesLikeOneWouldExpectThemToBe", true, true, patrol_3[1], 100)
		
		patrol_4 = Find_All_Objects_With_Hint("pat4")
		Hunt(patrol_4, "PrioritiesLikeOneWouldExpectThemToBe", true, true, patrol_4[1], 100)
		
		patrol_5 = Find_All_Objects_With_Hint("pat5")
		Hunt(patrol_5, "PrioritiesLikeOneWouldExpectThemToBe", false, true, patrol_5[1], 50)
		for i, unit in pairs(patrol_5) do
			pat_5_counter = pat_5_counter + 1
			unit.Register_Signal_Handler(Callback_Patrol_5_Handler, "OBJECT_DELETE_PENDING")
		end
		
		-- Turning on civilian spawners
		Spawn_Civilians_Automatically(true)
		Set_Desired_Civilian_Population(50)
		
		-- Proximities
		Register_Prox(village, Prox_Approaching_Village, 300, aliens)
		Register_Prox(zessus, Prox_Zessus_Boss_Battle, 300, aliens)
		Register_Prox(bridgebuilding_1, Prox_Bridge_Building_1, 200, aliens)
		Register_Prox(obj_d_prox, Prox_Trigger_Objective_D, 900, aliens)
		Register_Prox(obj_e_prox, Prox_Trigger_Objective_E, 250, aliens)
		Register_Prox(island_blip, Prox_Complete_Objective_E, 250, aliens)
		Register_Prox(outpost_prox, Prox_Outpost_Message, 250, aliens)
		
		Create_Thread("Dialog_HM05_02_01")
		
	end
end

--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script
function Thread_Add_Objective(objective_num)
   local objective_1_delay = false
   
	if objective_num == 0 and not hm05_objective_00_given then
		hm05_objective_00_given = true
		objective_text[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_A"
		objective_add[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_A_ADD"
		objective_modified = true
	end
	if objective_num == 1 and not hm05_objective_01_given then
		objective_text[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_B"
		objective_add[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_B_ADD"
		Add_Radar_Blip(village, "DEFAULT", "blip_objective_1")
		objective_modified = true
		objective_1_delay = true
	end
	if objective_num == 2 and not hm05_objective_02_given then
		hm05_objective_02_given = true
		objective_text[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_C"
		objective_add[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_C_ADD"
		Add_Radar_Blip(bridgebuilding_1, "DEFAULT", "blip_objective_2")
		objective_modified = true
	end
	if objective_num == 3 and not hm05_objective_03_given then
		hm05_objective_03_given = true
		objective_text[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_D"
		objective_add[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_D_ADD"
		Add_Radar_Blip(orlok_spawn, "DEFAULT", "blip_objective_3")
		objective_modified = true
	end
	if objective_num == 4 and not hm05_objective_04_given then
		hm05_objective_04_given = true
		objective_text[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_E"
		objective_add[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_E_ADD"
		Add_Radar_Blip(obj_4_blip_a, "DEFAULT", "blip_objective_4_a")		
		Add_Radar_Blip(obj_4_blip_b, "DEFAULT", "blip_objective_4_b")
		jump_turret_0.Highlight(true, -50)
		jump_turret_0.Add_Reveal_For_Player(player_faction)
		jump_turret_1.Highlight(true, -50)
		jump_turret_1.Add_Reveal_For_Player(player_faction)
		jump_turret_2.Highlight(true, -50)
		jump_turret_2.Add_Reveal_For_Player(player_faction)
		jump_turret_3.Highlight(true, -50)
		jump_turret_3.Add_Reveal_For_Player(player_faction)
		objective_modified = true
	end
	if objective_num == 5 and not hm05_objective_05_given then
		hm05_objective_05_given = true
		objective_text[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_F"
		objective_add[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_F_ADD"
		objective_modified = true
	end
	if objective_num == 6 and not hm05_objective_06_given then
		hm05_objective_06_given = true
		objective_text[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_G"
		objective_add[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_G_ADD"
		objective_modified = true
		Add_Radar_Blip(patrol_0[1].Get_Position(), "DEFAULT", "blip_objective_6")
		for i, unit in pairs(patrol_0) do
			if TestValid(unit) then
				unit.Add_Reveal_For_Player(player_faction)
			end
		end
	end
	
	if objective_modified then
		objective_modified = false
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {objective_add[objective_num]} )
	    Sleep(time_objective_sleep)
		objective[objective_num] = Add_Objective(objective_text[objective_num])
	else
		--MessageBox("Add Objective called, but no objective was modified!")
	end
	
	if objective_1_delay then
	   Sleep(3)
   	hm05_objective_01_given = true
   end
end

function Thread_Complete_Objective(objective_num)
	if objective_num == 0 and not hm05_objective_00_completed then
		hm05_objective_00_completed = true
		objective_completed[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_A_COMPLETE"
		objective_modified = true
	end
	if objective_num == 1 and not hm05_objective_01_completed then
		hm05_objective_01_completed = true
		objective_completed[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_B_COMPLETE"
		Remove_Radar_Blip("blip_objective_1")
		objective_modified = true
	end
	if objective_num == 2 and not hm05_objective_02_completed then
		hm05_objective_02_completed = true
		objective_completed[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_C_COMPLETE"
		Remove_Radar_Blip("blip_objective_2")
		objective_modified = true
	end
	if objective_num == 3 and not hm05_objective_03_completed then
		hm05_objective_03_completed = true
		objective_completed[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_D_COMPLETE"
		Remove_Radar_Blip("blip_objective_3")
		objective_modified = true
	end
	if objective_num == 4 and not hm05_objective_04_completed then
		hm05_objective_04_completed = true
		objective_completed[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_E_COMPLETE"
		objective_modified = true
	end
	if objective_num == 5 and not hm05_objective_05_completed then
		hm05_objective_05_completed = true
		objective_completed[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_F_COMPLETE"
		objective_modified = true
	end
	if objective_num == 6 and not hm05_objective_06_completed then
		hm05_objective_06_completed = true
		objective_completed[objective_num] = "TEXT_SP_MISSION_HIE05_OBJECTIVE_G_COMPLETE"
		Remove_Radar_Blip("blip_objective_6")
		objective_modified = true
	end
	
	if objective_modified then
		objective_modified = false
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {objective_completed[objective_num]} )
		Objective_Complete(objective[objective_num])
	else
		--MessageBox("Complete Objective called, but no objective was modified!")
	end
end

function Thread_Mission_Failed()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
   mission_failure = true --this flag is what I check to make sure no game logic continues when the mission is over
   Stop_All_Speech()
   Flush_PIP_Queue()
   Letter_Box_In(1)
   Lock_Controls(1)
   Suspend_AI(1)
   Disable_Automatic_Tactical_Mode_Music()
-- this music is faction specific, 
-- use: UEA_Lose_Tactical_Event Alien_Lose_Tactical_Event Novus_Lose_Tactical_Event Masari_Lose_Tactical_Event
   Play_Music("Lose_To_Masari_Event")     
	Zoom_Camera.Set_Transition_Time(10)
   Zoom_Camera(.3)
   Rotate_Camera_By(180,30)
   -- the variable  failure_text  is set at the start of mission to contain the default string "TEXT_SP_MISSION_MISSION_FAILED"
   -- upon mission failure of an objective, or hero death, replace the string  failure_text  with the appropriate xls tag 
   Sleep(time_objective_sleep)
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
   Fade_Screen_Out(2)
   Sleep(2)
   Lock_Controls(0)
   Force_Victory(masari)
end

function Thread_Village_1_Cleared()
	
	current_civ_list = Find_All_Objects_Of_Type(civilian, "Insignificant", "Organic")
	for i, unit in pairs(current_civ_list) do
		if TestValid(unit) and not unit.Has_Behavior(BEHAVIOR_DEATH) then
			_CustomScriptMessage("_DanLog.txt", string.format("Forcing %s to Paniced State.", tostring(unit)))
			--unit.Set_Civilian_State(CIVILIAN_STATE_PANIC)	
		else
			_CustomScriptMessage("_DanLog.txt", string.format("=====> %s does not qualify and is being weeded out.", tostring(unit)))
		end
	end
	
	Create_Thread("Dialog_HM05_07_04")
end

function Thread_Reinforce_Grunts()
   local spawn_list, i, unit
   
	local grunt_transport = Spawn_Unit(Find_Object_Type("ALIEN_AIR_RETREAT_TRANSPORT"), transport_spawn_1, aliens)
	grunt_transport.Set_Selectable(false)
	grunt_transport.Make_Invulnerable(true)
	BlockOnCommand(grunt_transport.Move_To(grunt0_spawn))
	
   -- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
   spawn_list = SpawnList(list_grunt_reinforcements, grunt0_spawn, aliens, false, true, false)
   for i, unit in pairs(spawn_list) do
      if TestValid(unit) then
         unit.Register_Signal_Handler(Callback_Grunt_Killed, "OBJECT_HEALTH_AT_ZERO")
      end
   end
   total_alien_forces = total_alien_forces + 10
   
	Create_Thread("Dialog_HM05_07_01")	

	BlockOnCommand(grunt_transport.Move_To(transport_spawn_1))
	grunt_transport.Make_Invulnerable(false)
	grunt_transport.Despawn()
	unit = Find_First_Object("Alien_Brute")
	if TestValid(unit) then
      Add_Attached_Hint(unit, HINT_BUILT_ALIEN_BRUTE)
   end
end

function Thread_Reinforce_Orlok()
	local foo_0 = Spawn_Unit(Find_Object_Type("ALIEN_FOO_CORE"), foo_0_spawn, aliens)
	if TestValid(foo_0) then
	   foo_0.Activate_Ability("Unit_Ability_Foo_Core_Heal_Attack_Toggle", true)
   	foo_0.Move_To(foo_0_goto)
      Add_Attached_Hint(foo_0, HINT_BUILT_ALIEN_SAUCER)
   end
	local foo_1 = Spawn_Unit(Find_Object_Type("ALIEN_FOO_CORE"), foo_1_spawn, aliens)
	foo_1.Activate_Ability("Unit_Ability_Foo_Core_Heal_Attack_Toggle", true)
	foo_1.Move_To(foo_1_goto)
	local orlok_transport = Spawn_Unit(Find_Object_Type("ALIEN_AIR_RETREAT_TRANSPORT"), transport_spawn, aliens)
	orlok_transport.Set_Selectable(false)
	orlok_transport.Make_Invulnerable(true)
	BlockOnCommand(orlok_transport.Move_To(orlok_spawn))
		hero.Set_Object_Context_ID("ZM05")
		total_alien_forces = total_alien_forces + 1
		hero.Teleport_And_Face(orlok_spawn)
		Sleep(1)
		Create_Thread("Dialog_HM05_03_01")
	BlockOnCommand(orlok_transport.Move_To(transport_spawn))
	orlok_transport.Make_Invulnerable(false)
	orlok_transport.Despawn()
end

function Thread_Reinforce_Brutes()
   local spawn_list, i, unit
	local brute_transport = Spawn_Unit(Find_Object_Type("ALIEN_AIR_RETREAT_TRANSPORT"), transport_spawn, aliens)
	brute_transport.Set_Selectable(false)
	brute_transport.Make_Invulnerable(true)
	BlockOnCommand(brute_transport.Move_To(brute0_spawn))
   -- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	spawn_list = SpawnList(list_brute_reinforcements, brute0_spawn, aliens, false, true, false)
	for i, unit in pairs(spawn_list) do
	   if TestValid(unit) and TestValid(hero) then
	      unit.Attack_Move(hero.Get_Position())
	   end
	end
	BlockOnCommand(brute_transport.Move_To(transport_spawn))
	brute_transport.Make_Invulnerable(false)
	brute_transport.Despawn()
	Create_Thread("Thread_Monitor_Brutes")
end

function Thread_Monitor_Brutes()
   local brute_list = {}
   local brutes_active = true
   local i, unit, brute_alive
   
   brute_list = Find_All_Objects_Of_Type("ALIEN_BRUTE")
   while brutes_active and not bridge_2_destroyed do
      Sleep(time_delay_brute_check)
      brute_alive = false
      for i, unit in pairs(brute_list) do
         if TestValid(unit) then
            brute_alive = true
         end
      end
      if not brute_alive and not bridge_2_destroyed then
         brutes_active = false
         Create_Thread("Thread_Reinforce_Brutes")
      end
   end
end

function Thread_Zessus_Battle_Handler()
	if not teleport00_made then
		teleport_loc = zessus_teleport_00
		if TestValid(zessus) and TestValid(hero) then
			zessus_distance = zessus.Get_Distance(hero)
			zessus.Move_To(hero)
			while zessus_distance >= 60 do
				_CustomScriptMessage("_DanLog.txt", string.format("Zessus not close enough!  Current distance: %d", zessus_distance))
				zessus.Move_To(hero)
				Sleep(1)
				zessus_distance = zessus.Get_Distance(hero)
			end
			--MessageBox("Activating Teleport.")
			BlockOnCommand(zessus.Activate_Ability("Masari_Zessus_Teleportation_Unit_Ability", true, teleport_loc, true))
			Sleep(0.5)
			Point_Camera_At(hero)
			teleport00_made = true
			Create_Thread("Dialog_HM05_08_04")
			Sleep(2)
			--BlockOnCommand(zessus.Activate_Ability("Masari_Zessus_Explode_Unit_Ability", true))
			BlockOnCommand(zessus.Move_To(zessus_home))
			zessus_teleport_busy = false
		end
	elseif not teleport01_made then
		teleport_loc = zessus_teleport_01
		if TestValid(zessus) and TestValid(hero) then
			zessus_distance = zessus.Get_Distance(hero)
			zessus.Move_To(hero)
			while zessus_distance >= 60 do
				_CustomScriptMessage("_DanLog.txt", string.format("Zessus not close enough!  Current distance: %d", zessus_distance))
				zessus.Move_To(hero)
				Sleep(1)
				zessus_distance = zessus.Get_Distance(hero)
			end
			--MessageBox("Activating Teleport.")
			BlockOnCommand(zessus.Activate_Ability("Masari_Zessus_Teleportation_Unit_Ability", true, teleport_loc, true))
			Sleep(0.5)
			Point_Camera_At(hero)
			teleport01_made = true
			Create_Thread("Dialog_HM05_08_05")
			Sleep(2)
			--BlockOnCommand(zessus.Activate_Ability("Masari_Zessus_Explode_Unit_Ability", true))
			BlockOnCommand(zessus.Move_To(zessus_home))
			zessus_teleport_busy = false
		end
	elseif not teleport02_made then
		teleport_loc = zessus_teleport_02
		if TestValid(zessus) and TestValid(hero) then
			zessus_distance = zessus.Get_Distance(hero)
			zessus.Move_To(hero)
			while zessus_distance >= 60 do
				_CustomScriptMessage("_DanLog.txt", string.format("Zessus not close enough!  Current distance: %d", zessus_distance))
				zessus.Move_To(hero)
				Sleep(1)
				zessus_distance = zessus.Get_Distance(hero)
			end
			--MessageBox("Activating Teleport.")
			BlockOnCommand(zessus.Activate_Ability("Masari_Zessus_Teleportation_Unit_Ability", true, teleport_loc, true))
			Sleep(0.5)
			Point_Camera_At(hero)
			teleport02_made = true
			zessus.Make_Invulnerable(false)
			Create_Thread("Dialog_HM05_08_06")
			Sleep(2)
			BlockOnCommand(zessus.Move_To(zessus_home))
			zessus_teleport_busy = false
		end
	else
		if TestValid(zessus) and TestValid(hero) then
			zessus_distance = zessus.Get_Distance(hero)
			zessus.Move_To(hero)
			while zessus_distance >= 60 do
				_CustomScriptMessage("_DanLog.txt", string.format("Zessus not close enough!  Current distance: %d", zessus_distance))
				zessus.Move_To(hero)
				Sleep(1)
				if TestValid(zessus) and TestValid(hero) then
					zessus_distance = zessus.Get_Distance(hero)
				end
			end
			--MessageBox("Activating Explode!")
			zessus.Activate_Ability("Masari_Zessus_Explode_Unit_Ability", true)
			if not zessus_explode_taunt_given then
			   zessus_explode_taunt_given = true
			   Create_Thread("Dialog_HM05_08_07")
			end
		end
	end
end

--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script

function On_Death_Spawn(dying_obj, spawned_obj)
	if TestValid(spawned_obj) and spawned_obj.Get_Type() == Find_Object_Type("ALIEN_MUTANT_SLAVE") then
		total_alien_forces = total_alien_forces + 1
		if not hm05_objective_01_completed and hm05_objective_01_given then
			Create_Thread("Thread_Complete_Objective", 1)
		end
		if TestValid(bridgebuilding_1) then
			spawned_obj.Attack_Move(bridgebuilding_1.Get_Position())
		end
		spawned_obj.Register_Signal_Handler(Callback_Slave_Killed, "OBJECT_DELETE_PENDING")
		total_slaves = total_slaves + 1
		if total_slaves >= 30 and not civ_spawner_off then
			civ_spawner_off = true			
			_CustomScriptMessage("_DanLog.txt", string.format("Turning civ spawner off"))
			Spawn_Civilians_Automatically(false)			
		end
		
	end
end

function Callback_Grunt_Killed(callback_obj)
	total_alien_forces = total_alien_forces - 1
	if total_alien_forces <= 0 then
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_FAILED"} )
		Create_Thread("Thread_Mission_Failed")
	end
end

function Callback_Slave_Killed(callback_obj)

	total_slaves = total_slaves - 1
	total_alien_forces = total_alien_forces - 1
	if total_alien_forces <= 0 then
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_FAILED"} )
		Create_Thread("Thread_Mission_Failed")
	end
	if total_slaves <= 15 and civ_spawner_off then
		civ_spawner_off = false
		_CustomScriptMessage("_DanLog.txt", string.format("Turning civ spawner back on"))
		Spawn_Civilians_Automatically(true)			
	end
end

function Prox_Approaching_Village(prox_obj,trigger_obj)
	found_village = true
	prox_obj.Cancel_Event_Object_In_Range(Prox_Approaching_Village)
	for i, marker in pairs(civ_spawn_list_0) do
		if TestValid(marker) then
			marker.Set_In_Limbo(false)	
		end
	end
end

function Prox_Bridge_Building_1(prox_obj,trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Bridge_Building_1)
	Create_Thread("Dialog_HM05_02_02")
end

function Prox_Trigger_Objective_D(prox_obj,trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Trigger_Objective_D)
	
	Create_Thread("Thread_Village_1_Cleared")
	
	for i, marker in pairs(civ_spawn_list_1) do
		if TestValid(marker) then
			marker.Set_In_Limbo(true)	
		end
	end
	for i, marker in pairs(civ_spawn_list_2) do
		if TestValid(marker) then
			marker.Set_In_Limbo(false)	
		end
	end
end

function Prox_Trigger_Objective_E(prox_obj,trigger_obj)
   local nearest_enemy, distance
   
   nearest_enemy = Find_Nearest(prox_obj, masari, true)
   if TestValid(nearest_enemy) then
      distance = nearest_enemy.Get_Distance(prox_obj)
      if distance > 150 then
         prox_obj.Cancel_Event_Object_In_Range(Prox_Trigger_Objective_E)
         Create_Thread("Dialog_HM05_07_02")
      end
   else
      prox_obj.Cancel_Event_Object_In_Range(Prox_Trigger_Objective_E)
      Create_Thread("Dialog_HM05_07_02")
   end
end

function Prox_Complete_Objective_E(prox_obj,trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Complete_Objective_E)
		
	for i, marker in pairs(civ_spawn_list_2) do
		if TestValid(marker) then
			marker.Set_In_Limbo(true)	
		end
	end
end

function Prox_Outpost_Message(prox_obj,trigger_obj)
	prox_obj.Cancel_Event_Object_In_Range(Prox_Outpost_Message)
	Create_Thread("Dialog_HM05_07_03")
end

function Prox_Zessus_Boss_Battle(prox_obj,trigger_obj)
   if not zessus_intro_conversation_complete then
      zessus_intro_conversation_complete = true
      Create_Thread("Dialog_HM05_08_01")
   end
   if not zessus_teleport_busy then
   	zessus_teleport_busy = true
   	Create_Thread("Thread_Zessus_Battle_Handler")
   end
end

function Callback_Patrol_0_Handler()
	pat_0_counter = pat_0_counter - 1
	if pat_0_counter <= 0 then
		Create_Thread("Thread_Complete_Objective", 6)
		current_civ_list = Find_All_Objects_Of_Type(civilian, "Resource_INST", "Insignificant", "Organic")
		for i, unit in pairs(current_civ_list) do
			if TestValid(unit) and not unit.Has_Behavior(BEHAVIOR_DEATH) then
				_CustomScriptMessage("_DanLog.txt", string.format("Forcing %s to Paniced State.", tostring(unit)))
				--unit.Set_Civilian_State(CIVILIAN_STATE_PANIC)	
			else
				_CustomScriptMessage("_DanLog.txt", string.format("=====> %s does not qualify and is being weeded out.", tostring(unit)))
			end
		end
		for i, marker in pairs(civ_spawn_list_0) do
			if TestValid(marker) then
				marker.Set_In_Limbo(true)	
			end
		end
		for i, marker in pairs(civ_spawn_list_1) do
			if TestValid(marker) then
				marker.Set_In_Limbo(false)	
			end
		end
	end
end

function Callback_Patrol_1_Handler()
	pat_1_counter = pat_1_counter - 1
	if pat_1_counter <= 0 then
		--MessageBox("Pat 1 dead")
	end
end

function Callback_Patrol_2_Handler()
	pat_2_counter = pat_2_counter - 1
	if pat_2_counter <= 0 then
		--MessageBox("Pat 2 dead")
	end
end

function Callback_Patrol_3_Handler()
	pat_3_counter = pat_3_counter - 1
	if pat_3_counter <= 0 then	
		--Create_Thread("Thread_Village_1_Cleared")
	end
end

function Callback_Patrol_5_Handler()
	pat_5_counter = pat_5_counter - 1
	if pat_5_counter <= 0 then
		masari.Set_Elemental_Mode("Fire")
		Create_Thread("Thread_Complete_Objective", 3)
		Create_Thread("Thread_Reinforce_Orlok")
	end
end

function Callback_Jump_Turrets_Killed(callback_obj)
	jump_turrets_killed = jump_turrets_killed + 1
	if callback_obj == jump_turret_0 and not TestValid(jump_turret_1) then
		Remove_Radar_Blip("blip_objective_4_a")
	end
	if callback_obj == jump_turret_1 and not TestValid(jump_turret_0) then
		Remove_Radar_Blip("blip_objective_4_a")
	end
	if callback_obj == jump_turret_2 and not TestValid(jump_turret_3) then
		Remove_Radar_Blip("blip_objective_4_b")
	end
	if callback_obj == jump_turret_3 and not TestValid(jump_turret_2) then
		Remove_Radar_Blip("blip_objective_4_b")
	end
	if jump_turrets_killed >= 4 then
		Create_Thread("Thread_Complete_Objective", 4)
	end
end

function Callback_bridge1building_Killed()
   bridge1.Make_Invulnerable(false)
	bridge1.Take_Damage(9999999999, "Damage_Default")
	Create_Thread("Thread_Callback_bridge1building_Killed")
end

function Thread_Callback_bridge1building_Killed()
	Create_Thread("Thread_Complete_Objective", 2)
	Sleep(time_objective_sleep)
	Create_Thread("Thread_Add_Objective", 0)
end

function Callback_bridge2building_Killed()
   bridge2.Make_Invulnerable(false)
	bridge2.Take_Damage(9999999999, "Damage_Default")
	bridge_2_destroyed = true
end

function Callback_Orlok_Killed()
	if not mission_success then
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_ORLOK"} )
		Create_Thread("Thread_Mission_Failed")
	end
end

function Callback_Defiler_Killed()
	total_alien_forces = total_alien_forces - 1
	if total_alien_forces <= 0 then
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_FAILED"} )
		Create_Thread("Thread_Mission_Failed")
	end
	if defiler_counter > 0 then
		defiler_counter = defiler_counter - 1
	end
	if defiler_counter == 0 and not mission_success then
		--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_FAILED"} )
		--Create_Thread("Thread_Mission_Failed")
	end
end

function Callback_Zessus_Killed()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_HIE05_OBJECTIVE_F_COMPLETE"} )
	Create_Thread("Thread_Mission_Complete")
end

function Thread_Mission_Complete()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
	mission_success = true --this flag is what I check to make sure no game logic continues when the mission is over
   Stop_All_Speech()
   Flush_PIP_Queue()
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
	-- this music is faction specific, 
	-- use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
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
	BlockOnCommand(Play_Bink_Movie("Hierarchy_M5_S4",true))
	Force_Victory(aliens)
end

function Force_Victory(player)
   Fade_Out_Music()			
	if player == aliens then
		-- ***** ACHIEVEMENT_AWARD *****
		if (Player_Earned_Offline_Achievements()) then
			--Supply Novus as the player here - the parameter is only used to determine which version of the *_Tactical_Mission_Over
			--function we call, and as with the no achievements case below the Novus campaign is the one we want to move forward.
			-- Create_Thread("Show_Earned_Achievements_Thread", {Get_Game_Mode_GUI_Scene(), novus})
		else
			
			-- Inform the campaign script of our victory.
			global_script.Call_Function("Hierarchy_Tactical_Mission_Over", true) -- true == player wins/false == player loses
			--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
			Quit_Game_Now(player, false, true, false)
		end
	else
		Show_Retry_Dialog()
	end	
end


--***************************************TEMP CINEMATICS****************************************************************************************************
-- below are temporary cinematics to be replaced later
function Establishing_Shot(hero)
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
   Sleep(5)
   Letter_Box_Out(1)
   Sleep(1.5)
   Lock_Controls(0)
   End_Cinematic_Camera()
		
	--Create_Thread("Thread_Mission_Start")
	
end



--************************************************************************************************************
--***************************************All Talking Head Dialog stuff****************************************
--************************************************************************************************************

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 01+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Kamal Rex (KAM) -- For once a job well done, Commander. Now then...
function Dialog_HM05_01_01()
	Queue_Talking_Head(dialog_kamal, "HIE05_SCENE01_01")
	Create_Thread("Dialog_HM05_01_02")
end

--Kamal Rex (KAM) -- ...the Masari have come to life. They have begun engaging Novus units across this region, at the same time they fight our own. 
function Dialog_HM05_01_02()
	Queue_Talking_Head(dialog_kamal, "HIE05_SCENE01_02")
	Create_Thread("Dialog_HM05_01_03")
end

--Orlok (ORL) -- We have awakened an angry giant.
function Dialog_HM05_01_03()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE01_03")
	Create_Thread("Dialog_HM05_01_04")
end

--Kamal Rex (KAM) -- Not if we cut off its head. I've given your plan more thought - according to myth, a Masari queen is said to rule over their race. I can think of no greater prize to deliver to the Overseers. They will beg me to be their lord.
function Dialog_HM05_01_04()
	Queue_Talking_Head(dialog_kamal, "HIE05_SCENE01_04")
	Create_Thread("Dialog_HM05_01_05")
end

--Orlok (ORL) -- If we can find her.
function Dialog_HM05_01_05()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE01_05")
	Create_Thread("Dialog_HM05_01_06")
end

--Hierarchy Comm (HCO) -- Sir, we've detected increased Masari communications here, in this region, where a large number of Masari ships were flying escort for someone.
function Dialog_HM05_01_06()
	Queue_Talking_Head(dialog_hie_comm, "HIE05_SCENE01_06")
	Create_Thread("Dialog_HM05_01_07")
end

--Orlok (ORL) -- It could be a leader.
function Dialog_HM05_01_07()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE01_07")
	Create_Thread("Dialog_HM05_01_08")
end

--Kamal Rex (KAM) -- I've already sent Defilers down to soften up the resistance. When they're finished, bring me back the head of a queen.
function Dialog_HM05_01_08()
	Queue_Talking_Head(dialog_kamal, "HIE05_SCENE01_08")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 02+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Orlok (ORL) -- Squad, I'm en route to your location now. Engage Masari forces as needed, but keep watch for their queen. We must capture her alive.
function Dialog_HM05_02_01()
	BlockOnCommand(Queue_Talking_Head(dialog_orlok, "HIE05_SCENE02_01"))
	Create_Thread("Dialog_HM05_06_02")
end

--Hierarchy Science (HSC) -- We've been analyzing the Masari technology. To cross the river, you need to destroy that Barricade force generator. It should release a bridge.
function Dialog_HM05_02_02()
	Queue_Talking_Head(dialog_hie_science, "HIE05_SCENE02_02")
	Sleep(2)
	Create_Thread("Thread_Add_Objective", 2)
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 03+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Orlok (ORL) -- Nufai, is this channel secure?
function Dialog_HM05_03_01()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE03_01")
	Create_Thread("Dialog_HM05_03_02")
end

--Nufai (NUF) -- Affirmative.  
function Dialog_HM05_03_02()
	Queue_Talking_Head(dialog_nufai, "HIE05_SCENE03_02")
	Create_Thread("Dialog_HM05_03_03")
end

--Orlok (ORL) -- The time for change is coming. I've convinced Kamal to let me seek out the Masari queen. If they are as wise as legends say, peace will win out over war.
function Dialog_HM05_03_03()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE03_03")
	Create_Thread("Dialog_HM05_03_04")
end

--Nufai (NUF) -- Many others in the army are ready for peace too, sir.
function Dialog_HM05_03_04()
	Queue_Talking_Head(dialog_nufai, "HIE05_SCENE03_04")
	Create_Thread("Dialog_HM05_03_05")
end

--Orlok (ORL) -- Good, their bravery will be needed.
function Dialog_HM05_03_05()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE03_05")
	Sleep(1)
	Create_Thread("Dialog_HM05_07_06")
end

--Orlok (ORL) -- Squad, let's move out.
function Dialog_HM05_07_06()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE07_06")
	Create_Thread("Dialog_HM05_07_07")
end

--Orlok (ORL) -- We'll use our saucers' repair mode to keep units healthy.
function Dialog_HM05_07_07()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE07_07")
end


--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 05+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Zessus (ZES) -- Hierarchy grunt - who are you that you would dare defy one of your gods?
function Dialog_HM05_05_01()
	Queue_Talking_Head(dialog_zessus, "HIE05_SCENE05_01")
	Create_Thread("Dialog_HM05_05_02")
end

--Orlok (ORL) -- I am Orlok, Commander of the Hierarchy battalions, general of the galactic fleet, annihilator of a thousand worlds... and you are no longer a god of mine.
function Dialog_HM05_05_02()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE05_02")
	Create_Thread("Dialog_HM05_05_03")
end

--Zessus (ZES) -- Your blasphemy will end today!
function Dialog_HM05_05_03()
	Queue_Talking_Head(dialog_zessus, "HIE05_SCENE05_03")
	Create_Thread("Dialog_HM05_05_04")
end

--Orlok (ORL) -- No. Today I offer a truce.
function Dialog_HM05_05_04()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE05_04")
	Create_Thread("Dialog_HM05_05_05")
end

--Zessus (ZES) -- A Hierarchy general yearning for peace? What strange day have we awoken to?
function Dialog_HM05_05_05()
	Queue_Talking_Head(dialog_zessus, "HIE05_SCENE05_05")
	Create_Thread("Dialog_HM05_05_06")
end

--Orlok (ORL) -- It is a day when soldiers grow weary of dying for distant masters. If you will help me turn against them, this world may yet be spared.
function Dialog_HM05_05_06()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE05_06")
	Create_Thread("Dialog_HM05_05_07")
end

--Zessus (ZES) -- What do you propose, Commander?
function Dialog_HM05_05_07()
	Queue_Talking_Head(dialog_zessus, "HIE05_SCENE05_07")
	Create_Thread("Dialog_HM05_05_08")
end

--Orlok (ORL) -- There is a transmission site here on this world.  It can be used to broadcast a surrender signal across the planet. If we seize it, then Hierarchy forces loyal to the Overseers can be disabled. Together you and I will defeat them.
function Dialog_HM05_05_08()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE05_08")
	Create_Thread("Dialog_HM05_05_09")
end

--Zessus (ZES) -- Failure would mean certain death for you.
function Dialog_HM05_05_09()
	Queue_Talking_Head(dialog_zessus, "HIE05_SCENE05_09")
	Create_Thread("Dialog_HM05_05_10")
end

--Orlok (ORL) -- I would welcome it. I already walk among ghosts.
function Dialog_HM05_05_10()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE05_10")
	Create_Thread("Dialog_HM05_05_11")
end

--Zessus (ZES) -- We will test this truce. I will meet you at the transmission site and we will discover if old enemies can become new allies.
function Dialog_HM05_05_11()
	Queue_Talking_Head(dialog_zessus, "HIE05_SCENE05_11")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 06+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Hierarchy Comm (HCO) -- Our recon shows that our defilers are vastly outnumbered.  The key to this operation will be to enslave the local population to fight our battle for us.
function Dialog_HM05_06_01()
	BlockOnCommand(Queue_Talking_Head(dialog_hie_comm, "HIE05_SCENE06_01"))
	Create_Thread("Dialog_HM05_06_03")
end

--Hierarchy Comm (HCO) -- Our scans are reporting masari resistance to the east of our current location.  They are likely guarding a path across the river.
function Dialog_HM05_06_02()
	BlockOnCommand(Queue_Talking_Head(dialog_hie_comm, "HIE05_SCENE06_02"))
	Create_Thread("Thread_Add_Objective", 6)
	Create_Thread("Dialog_HM05_06_01")
end

--Hierarchy Comm (HCO) -- We must protect our defilers at all costs.  They won't last long against that Masari squad.  Recruit some slaves from the nearby village.
function Dialog_HM05_06_03()
	BlockOnCommand(Queue_Talking_Head(dialog_hie_comm, "HIE05_SCENE06_03"))
	Create_Thread("Thread_Add_Objective", 1)
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 07+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Hierarchy Comm (HCO) -- Commander Orlok is nearing your location.  We are highlighting his landing location for you now.  Secure it before he arrives.
function Dialog_HM05_07_01()
	BlockOnCommand(Queue_Talking_Head(dialog_hie_comm, "HIE05_SCENE07_01"))
	Create_Thread("Thread_Add_Objective", 3)
end

--Orlok (ORL) -- We have arrived at a dead end.  There appears to be a Masari bridge, but it is not activatable from this side of the river.  One of the brutes should be able to jump across.
function Dialog_HM05_07_02()
	Create_Thread("Thread_Reinforce_Brutes")
	BlockOnCommand(Queue_Talking_Head(dialog_orlok, "HIE05_SCENE07_02"))
end

--Orlok (ORL) -- We've arrived at the Masari outpost.  Zessus must be nearby.
function Dialog_HM05_07_03()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE07_03")
end

--Hierarchy Comm (HCO) --Grunts are being dispatched to your location from a nearby territory.  Use them wiesly.
function Dialog_HM05_07_04()
	BlockOnCommand(Queue_Talking_Head(dialog_hie_comm, "HIE05_SCENE07_04"))
	Create_Thread("Thread_Reinforce_Grunts")
	Sleep(8)
 	Create_Thread("Dialog_HM05_07_05")
end

--Hierarchy Comm (HCO) --Those turrets are inaccessable to most of our troops.  Fortunately, our Brutes have the ability to jump up there and take them out.
function Dialog_HM05_07_05()
	BlockOnCommand(Queue_Talking_Head(dialog_hie_comm, "HIE05_SCENE07_05"))
	Create_Thread("Thread_Add_Objective", 4)
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 08+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Zessus (ZES) -- Hierarchy grunt! Turn back now or face my wrath!
function Dialog_HM05_08_01()
	Queue_Talking_Head(dialog_zessus, "HIE05_SCENE08_01")
	Create_Thread("Dialog_HM05_08_02")
end

--Orlok (ORL) -- We seek an audience with your queen.
function Dialog_HM05_08_02()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE08_02")
	Create_Thread("Dialog_HM05_08_03")
end

--Zessus (ZES) -- And you have found her son instead.
function Dialog_HM05_08_03()
	Queue_Talking_Head(dialog_zessus, "HIE05_SCENE08_03")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Orlok (ORL) -- This Masari prince has powers of teleportation. We must be cautious!
function Dialog_HM05_08_04()
	Queue_Talking_Head(dialog_orlok, "HIE05_SCENE08_04")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Zessus (ZES) -- You are a brave one, Hierarchy minion. None have challenged me and lived to tell the tale..
function Dialog_HM05_08_05()
	Queue_Talking_Head(dialog_zessus, "HIE05_SCENE08_05")
end

--Zessus (ZES) -- I am a god! Reality bends to my will. What chance do you have against me?
function Dialog_HM05_08_06()
	Queue_Talking_Head(dialog_zessus, "HIE05_SCENE08_06")
end

--Zessus (ZES) -- You will die for your foolishness.
function Dialog_HM05_08_07()
	Queue_Talking_Head(dialog_zessus, "HIE05_SCENE08_07")
end

function Post_Load_Callback()
	UI_Hide_Research_Button()
	UI_Hide_Sell_Button()
	Movie_Commands_Post_Load_Callback()
end

