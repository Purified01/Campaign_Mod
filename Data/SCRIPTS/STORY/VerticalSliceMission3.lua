-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/VerticalSliceMission3.lua#103 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/VerticalSliceMission3.lua $
--
--    Original Author: Steve Copeland
--
--            $Author: Maria_Teruel $
--
--            $Change: 45689 $
--
--          $DateTime: 2006/06/05 11:19:14 $
--
--          $Revision: #103 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")
require("PGSpawnUnits")
require("PGMoveUnits")
require("PGMovieCommands")
require("UIControl")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()

	Define_State("State_Init", State_Init)
	Define_State("State_Opening_Cinematic", State_Opening_Cinematic)
	Define_State("State_Place_Structures", State_Place_Structures)
	Define_State("State_Engage_Alien_Walker", State_Engage_Alien_Walker)
	Define_State("State_Destroy_Missile_Jammers", State_Destroy_Missile_Jammers)
	Define_State("State_Destroy_Flyers", State_Destroy_Flyers)
	Define_State("State_Destroy_Armor", State_Destroy_Armor)
	Define_State("State_Kill_Walker", State_Kill_Walker)
	Define_State("State_Outro_Dialog", State_Outro_Dialog)
	
	alien_assault_wave_list =
	{
		"Alien_Grunt",		
		"Alien_Team_Science"
	}
	
	alien_tank_wave_list = 
	{
		"Alien_Recon_Tank",
		"Alien_Recon_Tank",
		"Alien_Recon_Tank"
	}
	
	dragoon_spawn_list = 
	{
		"Military_Dragoon_MTRV",
		"Military_Dragoon_MTRV",
		"Military_Team_Flamethrower",
		"Military_Team_Flamethrower",
		"Military_Team_Flamethrower",
		"Military_Team_Rocketlauncher",
		"Military_Team_Rocketlauncher",
		"Military_Team_Rocketlauncher"
	}
	
	dragoon_spawn_list2 = 
	{
		"Military_Dragoon_MTRV",
		"Military_Dragoon_MTRV",
		"Military_Dragoon_MTRV",
		"Military_Dragoon_MTRV"
	}
	objective_repeat_delay = 120
	civilian_spawn_timer = 1
	civilian_delete_distance = 5
	walker_movement_position = 1
	structures_placed = 0
	alien_clear_distance = 500
	alien_tanks_minimum_count = 4
	alien_walker_min_heat_controllers = 2
	alien_flank_arrival_distance = 200
	
	structure_barracks_placed = false
	structure_motor_pool_placed = false
	structure_aircraft_pad_placed = false
	dragoons_have_arrived = false
	aliens_too_near = true
	alien_walker_attacked = false
	intro_cinematic_complete = false
	introduction_complete = false
	start_outro_dialog = false
	mission_active = true
	zenzo_health_warning = false
	walker_is_dead = false
	debug_destroyed_walker_legs = false
	debug_spawned_dragoons = false
			
	Num_Shields_Destroyed = 0
	Num_Armor_Destroyed = 0
	Num_Coolants_Destroyed = 0
	
--	SkipHeroMovies = true  -- DEVELOPMENT SHORT CUT
--	DebugSkipToOutro = true -- DEVELOPMENT SHORT CUT
end

---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then

		if not DebugSkipToOutro then
			Fade_Screen_Out(0)
		end

		Cache_Models()
		
		alien_grunt_obj = Find_Object_Type("Alien_Grunt")
		alien_science_obj = Find_Object_Type("Alien_Team_Science_Greys")
		alien_tank_obj = Find_Object_Type("Alien_Recon_Tank")
		dragoon_type = Find_Object_Type("Military_Dragoon_MTRV")
		dragoon_missile_type = Find_Object_Type("Proj_Dynamic_Scanner_Fixed_Weapon")
		
		uea = Find_Player("UEA")
		alien = Find_Player("Alien")
		civilian = Find_Player("Civilian")
		
		fog_id = FogOfWar.Reveal_All(uea)
		
		-- Find things
		hero_tank = Find_First_Object("Military_Hero_Tank")
		if TestValid(hero_tank) then
			hero_tank.Set_Cannot_Be_Killed(true)
		else
			hero_tank = Find_First_Object("Military_Hero_Tank")
			if TestValid(hero_tank) then
				hero_tank.Set_Cannot_Be_Killed(true)
			else
				MessageBox("CANNOT FIND HERO TANK")
			end
		end
		
		hero_comm_officer = Find_First_Object("Military_Hero_Comm_Officer_PIP_Only")
		hero_chief_scientist = Find_First_Object("Military_Hero_Chief_Scientist_PIP_Only")
		alien_walker = Find_First_Object("Alien_Walker_Habitat")

		if not TestValid(hero_comm_officer) then
			MessageBox("CANNOT FIND HERO COMM OFFICER")
		end
		if not TestValid(hero_chief_scientist) then
			MessageBox("CANNOT FIND HERO CHIEF SCIENTIST")
		end

		if not TestValid(alien_walker) then
			MessageBox("CANNOT FIND ALIEN WALKER")
		end
		
		alien_walker.Register_Signal_Handler(On_Walker_Shields_Hit, "OBJECT_SHIELDS_HIT")

		-------- Walker Puzzle Callbacks  -------------------------------------		
		walker_script = alien_walker.Get_Script()
		if walker_script~=nil then
			walker_shield_hp_type = Find_Object_Type("ALIEN_WALKER_HABITAT_SHIELD_HP")
			walker_script.Call_Function("Register_For_HP_Destroyed_Callback", walker_shield_hp_type, Script, "On_Walker_Shield_Destroyed")
			
			walker_armor_00_type = Find_Object_Type("Alien_Walker_Habitat_Back_HP00")
			walker_armor_01_type = Find_Object_Type("Alien_Walker_Habitat_Back_HP01")
			walker_armor_02_type = Find_Object_Type("Alien_Walker_Habitat_Back_HP02")
			walker_armor_03_type = Find_Object_Type("Alien_Walker_Habitat_Back_HP03")

			walker_script.Call_Function("Register_For_HP_Destroyed_Callback", walker_armor_00_type, Script,  "On_Walker_Armor_Destroyed")
			walker_script.Call_Function("Register_For_HP_Destroyed_Callback", walker_armor_01_type, Script,  "On_Walker_Armor_Destroyed")
			walker_script.Call_Function("Register_For_HP_Destroyed_Callback", walker_armor_02_type, Script,  "On_Walker_Armor_Destroyed")
			walker_script.Call_Function("Register_For_HP_Destroyed_Callback", walker_armor_03_type, Script,  "On_Walker_Armor_Destroyed")
			
			walker_coolant_00_type = Find_Object_Type("Alien_Walker_Habitat_Cooling_HP00")
			walker_coolant_01_type = Find_Object_Type("Alien_Walker_Habitat_Cooling_HP01")
			walker_coolant_02_type = Find_Object_Type("Alien_Walker_Habitat_Cooling_HP02")
			walker_coolant_03_type = Find_Object_Type("Alien_Walker_Habitat_Cooling_HP03")
			
			walker_script.Call_Function("Register_For_HP_Destroyed_Callback", walker_coolant_00_type, Script, "On_Walker_Coolant_Destroyed")
			walker_script.Call_Function("Register_For_HP_Destroyed_Callback", walker_coolant_01_type, Script, "On_Walker_Coolant_Destroyed")
			walker_script.Call_Function("Register_For_HP_Destroyed_Callback", walker_coolant_02_type, Script, "On_Walker_Coolant_Destroyed")
			walker_script.Call_Function("Register_For_HP_Destroyed_Callback", walker_coolant_03_type, Script, "On_Walker_Coolant_Destroyed")
		end
		-------- Walker Puzzle Callbacks  -------------------------------------
		
		debug_1 = Find_Hint("CAR_SPORT","debug1")
		debug_2 = Find_Hint("CAR_SPORT","debug2")
		
		invader_creation_position = Find_First_Object("MARKER_INVADER_CREATION_POSITION")
		base_location = Find_Hint("Marker_Generic", "base")
		
		if not TestValid(base_location) then
			MessageBox("CANNOT FIND MARKER base")
		end

		dragoon_spawn = Find_Hint("Marker_Generic", "dragoon")
		dragoon_move = Find_Hint("Marker_Generic", "dragoon-m")

		if not TestValid(dragoon_spawn) then
			MessageBox("CANNOT FIND MARKER dragoon")
		end
		if not TestValid(dragoon_move) then
			MessageBox("CANNOT FIND MARKER dragoon-m")
		end
		
		walker_move_01 = Find_Hint("Marker_Generic", "walker-01")
		walker_move_02 = Find_Hint("Marker_Generic", "walker-02")
		walker_move_03 = Find_Hint("Marker_Generic", "walker-03")

		if not TestValid(walker_move_01) then
			MessageBox("CANNOT FIND MARKER walker-01")
		end
		if not TestValid(walker_move_02) then
			MessageBox("CANNOT FIND MARKER walker-02")
		end
		if not TestValid(walker_move_03) then
			MessageBox("CANNOT FIND MARKER walker-03")
		end
		
		alien_tank_spawn = Find_Hint("Marker_Generic", "alientank")

		if not TestValid(alien_tank_spawn) then
			MessageBox("CANNOT FIND MARKER alientank")
		end
	
		marker_alien_spawn_01 = Find_Hint("Marker_Generic", "civ-01")
		marker_alien_spawn_02 = Find_Hint("Marker_Generic", "civ-02")
		marker_alien_spawn_03 = Find_Hint("Marker_Generic", "civ-03")

		if not TestValid(marker_alien_spawn_01) then
			MessageBox("CANNOT FIND MARKER civ-01")
		end
		if not TestValid(marker_alien_spawn_02) then
			MessageBox("CANNOT FIND MARKER civ-02")
		end
		if not TestValid(marker_alien_spawn_03) then
			MessageBox("CANNOT FIND MARKER civ-03")
		end
		
		marker_alien_arrival_00 = Find_Hint("Marker_Generic", "civ-04")
		marker_alien_arrival_01 = Find_Hint("Marker_Generic", "civ-06")

		if not TestValid(marker_alien_arrival_00) then
			MessageBox("CANNOT FIND MARKER civ-05")
		end
		if not TestValid(marker_alien_arrival_01) then
			MessageBox("CANNOT FIND MARKER civ-06")
		end

		-- Cinematic Values
		introcine_position = Find_Hint("MARKER_GENERIC","introcine")
		intro_camera_position_01 = Find_Hint("MARKER_CAMERA","intro-cam00")
		intro_camera_position_02 = Find_Hint("MARKER_CAMERA","intro-cam01")
		intro_camera_position_03 = Find_Hint("MARKER_CAMERA","intro-cam02")
		intro_target_position_01 = Find_Hint("MARKER_CAMERA","intro-targ00")
		intro_target_position_02 = Find_Hint("MARKER_CAMERA","intro-targ01")

		if not TestValid(intro_camera_position_01) then
			MessageBox("CANNOT FIND MARKER intro-cam00")
		end
		if not TestValid(intro_camera_position_02) then
			MessageBox("CANNOT FIND MARKER intro-cam01")
		end
		if not TestValid(intro_camera_position_03) then
			MessageBox("CANNOT FIND MARKER intro-cam02")
		end
		if not TestValid(intro_target_position_01) then
			MessageBox("CANNOT FIND MARKER intro-targ00")
		end
		if not TestValid(intro_target_position_02) then
			MessageBox("CANNOT FIND MARKER intro-targ01")
		end

		-- Pointer Camera Values: Base
		pointer_camera_base_02 = Find_Hint("MARKER_CAMERA","ptc-cam02")

		if not TestValid(pointer_camera_base_02) then
			MessageBox("CANNOT FIND MARKER ptc-cam02")
		end

		-- Pointer Camera Values: Dragoons
		pointer_camera_dragoon_02 = Find_Hint("MARKER_CAMERA","ptc-dragoons")

		if not TestValid(pointer_camera_dragoon_02) then
			MessageBox("CANNOT FIND MARKER ptc-dragoons")
		end

		-- Pointer Camera Values: Alien Tanks
		pointer_camera_alientank_01 = Find_Hint("MARKER_CAMERA","ptc-alientank")

		if not TestValid(pointer_camera_alientank_01) then
			MessageBox("CANNOT FIND MARKER ptc-alientank")
		end

		-- Find all the UEA units which have arrived from global mode.
		uea_dragonfly_list = Find_All_Objects_Of_Type("Military_Dragonfly_UAV")
		uea_marines_list = Find_All_Objects_Of_Type("Military_Marine")
		uea_rocket_list = Find_All_Objects_Of_Type("Military_Rocketlauncher")
		uea_science_list = Find_All_Objects_Of_Type("Military_Science_Officer")
		uea_dragoon_list = Find_All_Objects_Of_Type("Military_Dragoon_MTRV")
		uea_tank_list = Find_All_Objects_Of_Type("Military_AbramsM2_Tank")
		uea_flame_list = Find_All_Objects_Of_Type("Military_Flamethrower")

		Act03_Hide_Units(uea_dragonfly_list)		
		Act03_Hide_Units(uea_marines_list)		
		Act03_Hide_Units(uea_rocket_list)		
		Act03_Hide_Units(uea_science_list)		
		Act03_Hide_Units(uea_dragoon_list)		
		Act03_Hide_Units(uea_tank_list)
		Act03_Hide_Units(uea_flame_list)
		hero_tank.Hide(true)
		
		-- Set the proximities for removing civilians
		Register_Prox(marker_alien_arrival_00, Prox_Redirect_Aliens, alien_flank_arrival_distance, alien)
		Register_Prox(marker_alien_arrival_01, Prox_Redirect_Aliens, alien_flank_arrival_distance, alien)
		
		-- Tell the Alien Walker to start marching around between points.
		Create_Thread("Thread_Act03_Walker_Movement")		

		-- Begin monitoring the critical units.
		Create_Thread("Thread_Act03_Story_Mode_Service")
	
        -- Proceed with the scenario if initialization occurred successfully
        if DebugSkipToOutro then
			Set_Next_State("State_Kill_Walker")
        else       
			Set_Next_State("State_Opening_Cinematic")
		end
	end
end

---------------------------------------------------------------------------------------------------

function On_Walker_Coolant_Destroyed( source_hp )
	Num_Coolants_Destroyed = Num_Coolants_Destroyed+1
end

---------------------------------------------------------------------------------------------------

function On_Walker_Armor_Destroyed( source_hp )
	Num_Armor_Destroyed = Num_Armor_Destroyed+1
end

---------------------------------------------------------------------------------------------------

function On_Walker_Shield_Destroyed( source_hp )
	Num_Shields_Destroyed = Num_Shields_Destroyed+1
	
	-- Handle the case where the player doesn't advance the mission by following the instructions
	-- to attack the walker with dragoons.  See if they've destroyed all the shields when not yet in the state instructing them to do so.
	local current_state = Get_Current_State()
	if ((current_state == "State_Engage_Alien_Walker") or (current_state == "State_Place_Structures")) and (Num_Shields_Destroyed >= 4) then
		Skip_Base_Objectives()
		Set_Next_State("State_Destroy_Flyers")
	end
end

---------------------------------------------------------------------------------------------------

function State_Opening_Cinematic(message)

	if message == OnEnter then
		
		Create_Thread("Thread_Intro_Cinematic")
		Sleep(5)
		local blowbuilding = Find_Hint("CIV_SKYSCRAPER_D", "blowupthis")
		if TestValid(blowbuilding) then
			blowbuilding.Take_Damage(100000)
		end

	elseif message == OnUpdate then
	
		if intro_cinematic_complete then
			if not introduction_complete then
			
				-- Hilight the area that has to be cleared of enemies for the structure
				Sleep(1)
				BlockOnCommand(Start_Hero_Movie(hero_comm_officer, "MIVS_COM0300_ENG")) 	-- COMM. OFF.: This clearing is large enough to support our base, sir. But it's teeming with alien activity.
				if TestValid (hero_tank) then
					BlockOnCommand(Start_Hero_Movie(hero_tank, "MIVS_ZEN0301_ENG")) 			-- ZENZO: Secure the area, and get those production facilities on-line!
				end
				Sleep(1)
				introduction_complete = true
				-- Add formal objectives.
				objective_hero_tank = Add_Objective("Zenzo must survive.")				
			end
			Set_Next_State("State_Place_Structures")		
		end
	end
end

---------------------------------------------------------------------------------------------------

function State_Place_Structures(message)
	if message == OnEnter then

		objective_place_armory = Add_Objective("Build an Armory.")
		objective_place_motor_pool = Add_Objective("Build a Motor Pool.")
		objective_place_aircraft_pad = Add_Objective("Build an Aircraft Pad.")

		-- Give the player feedback on how to initiate construction.
		Update_Build_UI_Flash()
						
	elseif message == OnUpdate then
		
		if structures_placed > 2 then
			Set_Next_State("State_Engage_Alien_Walker")
		end
		
	end
end

function Update_Build_UI_Flash()
	
	if not structure_aircraft_pad_placed then
		UI_Start_Flash_Construct_Building("Military_Aircraft_Pad_Construction")
	end
	if not structure_barracks_placed then
		UI_Start_Flash_Construct_Building("Military_Barracks_Construction")
	end
	if not structure_motor_pool_placed then
		UI_Start_Flash_Construct_Building("Military_Motor_Pool_Construction")
	end
end

---------------------------------------------------------------------------------------------------

function State_Engage_Alien_Walker(message)

	if message == OnEnter then
				
		BlockOnCommand(Start_Hero_Movie(hero_comm_officer, "MIVS_COM0306_ENG"))				-- Comm. Off:  Base is on-line.  We can resupply units when needed.  Dragoons are already inbound to assist.
		if TestValid(hero_tank) then
			BlockOnCommand(Start_Hero_Movie(hero_tank, "MIVS_ZEN0307_ENG"))						-- Zenzo:  Dragoons?
		end
		
		Fade_Screen_Out(0)
		
		-- Bring in the Dragoons here if they are not already forced into scene.
		if not dragoons_have_arrived then
			dragoons_have_arrived = true
			Act03_Dragoon_Spawn()
			if TestValid(transport) then
				transport.Despawn()
			end
			transport = Spawn_Unit(Find_Object_Type("MOV_ACT_3_Intro_Cinematic_00"), dragoon_spawn, uea)
			if TestValid(transport) then
				transport.Teleport_And_Face(marker_alien_arrival_01)
				transport.Play_Animation("Anim_Cinematic", false, 1)
			end
			
			-- Cinemotion_Indicate_Object(target_object,camera_position_01_object,skip_letterbox_setup)
			if TestValid(dragoon_squad[1]) then
				Cinemotion_Indicate_Object(dragoon_squad[1],pointer_camera_dragoon_02,0)

				-- Temp hack to make Dragoons buildable.
				UI_Temp_Enable_Build_Item(Find_Object_Type("MILITARY_DRAGOON_MTRV"))			
			end
		end
		
		Sleep(2)
		
		Start_Hero_Movie(hero_chief_scientist, "MIVS_CSI0308_ENG")		-- CHIEF SCIENTIST: The MTRV "Dragoon" is a multi-target rocket vehicle. Should cut right through that walker's defenses. Of course, before you use it-
		if TestValid(hero_tank) then
			Sleep(2)
			Start_Hero_Movie(hero_tank, "MIVS_ZEN0309_ENG")					-- ZENZO: Thank you, Doctor. We'll put them to the test.
		end
		
		objective_engage_walker = Add_Objective("Engage the alien walker with Dragoon MTRVs.")

		-- Make all the current alien grunts assault in a rush.

		alien_assault_list = Find_All_Objects_Of_Type("ALIEN_GRUNT")
		for i, unit in pairs (alien_assault_list) do
			if TestValid(unit) then
				local closest_enemy = Find_Nearest(unit, uea, true)
				if TestValid(closest_enemy) then
					unit.Attack_Move(closest_enemy)
				end
			end
		end
		
		-- Create the wave assaults and attack the hero's position.
		-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario)		
		spawned_aliens = SpawnList(alien_assault_wave_list, marker_alien_spawn_01, alien, false, true)
		if table.getn(spawned_aliens) then
			for i, unit in pairs (spawned_aliens) do
				if TestValid(unit) then
					local closest_enemy = Find_Nearest(unit, uea, true)
					if TestValid(closest_enemy) then
						unit.Attack_Move(closest_enemy)
					end
				end
			end
		end
		spawned_aliens = SpawnList(alien_assault_wave_list, marker_alien_spawn_02, alien, false, true)
		if table.getn(spawned_aliens) then
			for i, unit in pairs (spawned_aliens) do
				if TestValid(unit) then
					local closest_enemy = Find_Nearest(unit, uea, true)
					if TestValid(closest_enemy) then
						unit.Attack_Move(closest_enemy)
					end
				end
			end
		end
		spawned_aliens = SpawnList(alien_assault_wave_list, marker_alien_spawn_03, alien, false, true)
		if table.getn(spawned_aliens) and TestValid(hero_tank) then
			for i, unit in pairs (spawned_aliens) do
				if TestValid(unit) then
					local closest_enemy = Find_Nearest(unit, uea, true)
					if TestValid(closest_enemy) then
						unit.Attack_Move(closest_enemy)
					end
				end
			end
		end

	end
end

---------------------------------------------------------------------------------------------------

function State_Destroy_Missile_Jammers(message)

	if message == OnEnter then

		if TestValid(hero_tank) then
			BlockOnCommand(Start_Hero_Movie(hero_tank, "MIVS_ZEN0310_ENG"))				-- ZENZO: Our missiles aren't hitting, Doctor!
		end
		
		Create_Thread("Thread_Midtro_Cinematic_Walker")
		
		BlockOnCommand(Start_Hero_Movie(hero_chief_scientist, "MIVS_CSI0311_ENG")) 	-- CHIEF SCIENTIST: I tried to warn you earlier, sir. See those pods on the walker's legs? Theyre shield enhancers. Knock them out and youll open a window for our dragoons.
		objective_destroy_jammers = Add_Objective("Assault the pods on the walkers legs.")

	elseif message == OnUpdate then

		-- See if the missile jammers are destroyed.
		if Num_Shields_Destroyed >= 2 then
			-- at least one jammers destroyed
			Set_Next_State("State_Destroy_Flyers")
			
		elseif Num_Shields_Destroyed >= 1 then
			-- 1 or 2 jammers destroyed - repeat the objective
			if not objective_continue_assault then
				BlockOnCommand(Start_Hero_Movie(hero_chief_scientist, "MIVS_CSI0329_ENG")) 					-- Chief Scientist: The alien jamming signal has dropped significantly!
				Objective_Complete(objective_destroy_jammers)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Complete: Assault the pods on the walker's legs."} )
				objective_continue_assault = Add_Objective("Focus fire on the walker's defenses.")
			end
		end	
	end
end

---------------------------------------------------------------------------------------------------

function State_Destroy_Flyers(message)

	if message == OnEnter then

		if TestValid(hero_tank) then		
			BlockOnCommand(Start_Hero_Movie(hero_tank, "MIVS_ZEN0313_ENG")) 					-- Zenzo:  That it didn't like!
		end

		-- Spawn some alien tanks off-map and have them start attacking.

		if not debug_spawned_dragoons and not debug_destroyed_walker_legs then
			spawned_alien_tanks = SpawnList(alien_tank_wave_list, alien_tank_spawn, alien, false, true)
			if TestValid(alien_walker) then
				Create_Thread("Alien_Tank_Act3_Movements")			
				BlockOnCommand(Start_Hero_Movie(hero_comm_officer, "MIVS_COM0314_ENG")) 			-- Comm. Off.: Detecting incoming craft, sir!
			end
		end

		if TestValid(hero_tank) then
			Register_Timer(Delayed_Zenzo_Line, 10)			-- ZENZO: Why is that thing still standing?! Close ranks!
		end
		
	elseif message == OnUpdate then
	
		if Num_Armor_Destroyed >= 1 then
			-- at least 1 armor hp is destroyed
			Set_Next_State("State_Kill_Walker")					
		end
				
	end
end

---------------------------------------------------------------------------------------------------

function State_Kill_Walker(message)

	if message == OnEnter then
	
		if TestValid(hero_tank) and not DebugSkipToOutro then
			BlockOnCommand(Start_Hero_Movie(hero_chief_scientist, "MIVS_CSI0316_ENG"))	-- CHIEF SCIENTIST: Commander! Those nodes appear to regulate the walker's exhaust. Destroy enough of them and you may be able overload its reactor!
		end
		if objective_continue_assault then
			Objective_Complete(objective_continue_assault)
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Complete: Focus fire on the walker's defenses."} )
		end
		objective_destroy_heat_nodes = Add_Objective("Destroy at least two of the walker's coolant nodes to defeat it.")
	elseif message == OnUpdate then
	
		-- Have two heat controllers been destroyed?
		if Num_Coolants_Destroyed >= 2 or DebugSkipToOutro then
			if objective_destroy_heat_nodes then
				Objective_Complete(objective_destroy_heat_nodes)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Complete: Destroy at least two of the walker's coolant nodes to defeat it."} )
			end
            -- Set up the independent camera thread.
			Create_Thread("Thread_Outro_Cinematic")
			Sleep(1)
			Set_Next_State("State_Outro_Dialog")
		end
		
	end
end

---------------------------------------------------------------------------------------------------

function State_Outro_Dialog(message)

	if message == OnUpdate then
	
		if start_outro_dialog then
			if TestValid(hero_tank) then
				BlockOnCommand(Start_Hero_Movie(hero_comm_officer, "MIVS_COM0320_ENG")) 		-- Comm. Off.:  The alien forces are retreating!  We've driven them off!
				BlockOnCommand(Start_Hero_Movie(hero_tank, "MIVS_ZEN0321_ENG"))
			end
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"YOU ARE VICTORIOUS"} )
			
			Sleep(5)
			
			-- UEA wins, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag
			Quit_Game_Now(uea, true, true, false, true)
		end
	end
	
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- INTRO CINEMATIC HERE

function Thread_Intro_Cinematic()

	nearrange, farrange = Set_Object_Fade_Range(1200, 1600)
	oldnear, oldfar = Set_Fog_Range(550, 2000)

	Point_Camera_At(walker_move_03)
	Suspend_AI(1)
	Lock_Controls(1)
	Letter_Box_In(0)

	Sleep(0.5)
	
	Start_Cinematic_Camera()

	Transition_Cinematic_Camera_Key(intro_camera_position_01.Get_Position(), 0, 0, 0, 50, 0, 0, 0, 0)
	Transition_Cinematic_Target_Key(intro_target_position_01.Get_Position(), 0, 0, 0, 0, 0, 0, 0, 0)
	
	Fade_Screen_In(2)	
	
	Sleep(4)
	Transition_Cinematic_Camera_Key(intro_camera_position_02.Get_Position(), 8, 0, 0, 100, 0, 0, 0, 0)
	Transition_Cinematic_Target_Key(intro_target_position_02.Get_Position(), 8, 0, 0, 0, 0, 0, 0, 0)
	
	transport = Find_First_Object("MOV_ACT_3_Intro_Cinematic_00")
	transport.Play_Animation("Anim_Cinematic", false, 0)
	
	Sleep(6)
	
	transport.Hide(false)	
	
	Sleep(2)
	
	Fade_Screen_Out(1)
	
	Sleep(1)

	-- Spawn the takeoff transport here.
	transport.Despawn()
	transport = Spawn_Unit(Find_Object_Type("MOV_ACT_3_Intro_Cinematic_00"), dragoon_spawn, uea)
	transport.Teleport_And_Face(base_location)
	hero_tank.Teleport_And_Face(walker_move_03)
	transport.Play_Animation("Anim_Cinematic", false, 1)
	
	Act03_Unhide_Units(uea_dragonfly_list)
	Act03_Unhide_Units(uea_marines_list)
	Act03_Unhide_Units(uea_rocket_list)
	Act03_Unhide_Units(uea_science_list)
	Act03_Unhide_Units(uea_dragoon_list)
	Act03_Unhide_Units(uea_tank_list)
	Act03_Unhide_Units(uea_flame_list)
	hero_tank.Hide(false)

	Set_Fog_Range(oldnear, oldfar)
	Set_Object_Fade_Range(nearrange, farrange)
	
	Create_Thread("Thread_Act03_Alien_Governor")
	
	-- Tell the script it can continue to operate, the cinematic has passed the initial point.
	intro_cinematic_complete = true

	Transition_To_Tactical_Camera(0)
	Fade_Screen_In(1)
	Sleep(1)
	Letter_Box_Out(1)
	
	End_Cinematic_Camera()
	Lock_Controls(0)
	Suspend_AI(0)

end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- OUTRO CINEMATIC HERE

function Thread_Outro_Cinematic()

	if TestValid(alien_walker) and TestValid(hero_tank) then
		
		walker_is_dead = true
		alien_walker.Move_To(alien_walker.Get_Position())
		
		alien_science_team_list = Find_All_Objects_Of_Type("Alien_Team_Science")
		alien_grunt_list = Find_All_Objects_Of_Type("Alien_Grunt")

		for i,unit in pairs (alien_science_team_list) do
			if TestValid(unit) then
				unit.Take_Damage(100000)
			end
		end
		for i,unit in pairs (alien_grunt_list) do
			if TestValid(unit) then
				unit.Take_Damage(100000)
			end
		end
		
		hero_tank.Make_Invulnerable(true)
		hero_tank.Set_Cannot_Be_Killed(true)
		
		Suspend_AI(1)
		Lock_Controls(1)
		Letter_Box_In(0)

		Start_Cinematic_Camera()

		-- Set_Cinematic_Camera_Key(target_pos, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
		Set_Cinematic_Camera_Key(alien_walker, 450, 16, 180, 1, alien_walker, 0, 0)
		-- Set_Cinematic_Camera_Key(target_pos, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
		Set_Cinematic_Target_Key(alien_walker, 0, 0, 0, 0, alien_walker, 0, 0) 
		-- Transition_Cinematic_Camera_Key(target_pos, time, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
		Transition_Cinematic_Camera_Key(alien_walker, 20, 650, 35, 80, 1, alien_walker, 0, 0)

		Sleep(5)
		
		start_outro_dialog = true
	
		Sleep(30)

		Fade_Screen_Out(2)
		End_Cinematic_Camera()
		Lock_Controls(0)
		Suspend_AI(0)
		
	end
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

function Thread_Midtro_Cinematic_Walker()
	walker_shield_hardpoint_midtro = Find_First_Object("Alien_Walker_Habitat_Shield_HP")
	if TestValid(walker_shield_hardpoint_midtro) then

		Suspend_AI(1)
		Lock_Controls(1)
		Fade_Screen_Out(1)
			
		Start_Cinematic_Camera()

		Sleep(1)
		Letter_Box_In(0)

		Transition_Cinematic_Camera_Key(walker_shield_hardpoint_midtro, 0, 0, -150, 150, 0, walker_shield_hardpoint_midtro, 0, 0)
		Transition_Cinematic_Target_Key(walker_shield_hardpoint_midtro, 0, 0, 0, 0, 0, walker_shield_hardpoint_midtro, 0, 0)
		walker_parent_object_highlight = walker_shield_hardpoint_midtro.Get_Hard_Point_Parent()
		if TestValid(walker_parent_object_highlight) then
			walker_parent_object_highlight.Start_Light_Effect_Pulse(0, 10, 60)
			walker_shield_hardpoint_midtro.Highlight_Small(true)
		end
		
		Fade_Screen_In(1)
		
		Sleep(3)
		
		Letter_Box_Out(1)
		Transition_To_Tactical_Camera(1)
		Sleep(1)
		End_Cinematic_Camera()
		Lock_Controls(0)
		Suspend_AI(0)
		if TestValid(walker_parent_object_highlight) then
			walker_parent_object_highlight.Stop_Light_Effect()	
			walker_shield_hardpoint_midtro.Highlight_Small(false)
		end
	end
end

---------------------------------------------------------------------------------------------------
------ GLOBAL EVENTS -------------------------------------------------------------------------------

function On_Construction_Complete(obj)
	structure_needed1 = Find_Object_Type("Military_Aircraft_Pad")
	structure_needed2 = Find_Object_Type("Military_Barracks")
	structure_needed3 = Find_Object_Type("Military_Motor_Pool")
	unit_needed = Find_Object_Type("Military_Dragonfly_UAV")
	if obj.Get_Type() == structure_needed1 then
		if not structure_aircraft_pad_placed then
			Objective_Complete(objective_place_aircraft_pad)
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Complete: Build an Aircraft Pad."} )
			structure_aircraft_pad_placed = true
			structures_placed = structures_placed + 1
		end
	elseif obj.Get_Type() == structure_needed2 then
		if not structure_barracks_placed then
			Objective_Complete(objective_place_armory)
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Complete: Build an Armory."} )
			structure_barracks_placed = true
			structures_placed = structures_placed + 1
		end
	elseif obj.Get_Type() == structure_needed3 then
		if not structure_motor_pool_placed then
			Objective_Complete(objective_place_motor_pool)
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Complete: Build a Motor Pool."} )
			structure_motor_pool_placed = true
			structures_placed = structures_placed + 1
		end
	elseif obj.Get_Type() == unit_needed then
		unit_purchased = true
	end

end


function Skip_Base_Objectives()
	if objective_clear_area then
		Delete_Objective(objective_clear_area)
	end
	if objective_place_armory then
		Delete_Objective(objective_place_armory)
	end
	if objective_place_motor_pool then
		Delete_Objective(objective_place_motor_pool)
	end
	if objective_place_aircraft_pad then
		Delete_Objective(objective_place_aircraft_pad)
	end
end

-- Handle the event of the walker's shields being activated.
function On_Walker_Shields_Hit(source_obj, trigger_obj)


	-- We only care about this during one state.
	if not (Get_Current_State() == "State_Engage_Alien_Walker") then
		return
	end
	
	trigger_obj = Get_Last_Tactical_Parent(trigger_obj)
	trigger_obj_type = trigger_obj.Get_Type()

	-- See if dragoons or their missiles triggered the shields.
	if (trigger_obj_type == dragoon_type) or (trigger_obj_type == dragoon_missile_type) then
	
			-- Clean up obsolete objectives.
			Skip_Base_Objectives()
			
			-- Objective complete!
			if objective_engage_walker then
				Objective_Complete(objective_engage_walker)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Complete: Engage the alien walker with Dragoon MTRVs."} )
			end

			-- Advance the state, provided we're not cheating.
			if not debug_spawned_dragoons and not debug_destroyed_walker_legs then
				Set_Next_State("State_Destroy_Missile_Jammers")
			end
			
	end
end

function Thread_Act03_Story_Mode_Service()
	
	while mission_active do
	
		Sleep(1)
	
		-- Check if Zenzo has been destroyed. If so, the mission should end.
		
		if not TestValid(hero_tank) then
			Mission_Over_Camera_UI()
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"YOU HAVE BEEN DEFEATED"})
			Sleep(5)
			Mission_Over(alien)
		end
		
		-- Check if the red debug car has been destroyed. Kill the walker's leg hardpoints if so.
		
		if not TestValid(debug_1) and not debug_destroyed_walker_legs then
			leg_object_list = Find_All_Objects_Of_Type("Alien_Walker_Habitat_Shield_HP")
			if table.getn(leg_object_list) then
				debug_destroyed_walker_legs = true
				for m,legobj in pairs (leg_object_list) do
					legobj.Take_Damage(100000)
				end
			end
		end
		
		-- Check if the blue debug car has been destroyed. Spawn additional Dragoons on the beach if so.
		
		if not TestValid(debug_2) and not debug_spawned_dragoons then
			dragoon_squad = SpawnList(dragoon_spawn_list2, marker_alien_arrival_01, uea, false, true)
			dragoon_squad2 = SpawnList(dragoon_spawn_list2, marker_alien_spawn_02, uea, false, true)
			if table.getn(dragoon_squad2) then
				debug_spawned_dragoons = true
				dragoons_have_arrived = true				
			end
		end
		
	end
end

function Cache_Models()
	-- precache the models we expect to spawn from script here so they load faster.
	Find_Object_Type("Alien_Team_Science_Greys").Load_Assets()
	Find_Object_Type("Alien_Recon_Tank").Load_Assets()
	Find_Object_Type("MOV_ACT_3_Intro_Cinematic_00").Load_Assets()
	Find_Object_Type("Alien_Grunt").Load_Assets()
	Find_Object_Type("Military_Dragoon_MTRV").Load_Assets()
	Find_Object_Type("Military_Team_Flamethrower").Load_Assets()
	Find_Object_Type("Military_Team_Rocketlauncher").Load_Assets()	
end

------ UTILS ---------------------------------------------------------------------------------------------

function Thread_Act03_Walker_Movement()
	while (true) do
	
		Sleep(1)

		if not walker_is_dead then
			if TestValid(alien_walker) then
				if walker_movement_position == 1 then
					BlockOnCommand(alien_walker.Move_To(walker_move_01.Get_Position()))
					walker_movement_position = walker_movement_position + 1
				elseif walker_movement_position == 2 then
					BlockOnCommand(alien_walker.Move_To(walker_move_02.Get_Position()))
					walker_movement_position = walker_movement_position + 1
				elseif walker_movement_position == 3 then
					BlockOnCommand(alien_walker.Move_To(walker_move_03.Get_Position()))
					walker_movement_position = walker_movement_position + 1
				else
					local walker_move_random = GameRandom(1,4)
					if walker_move_random == 1 then
						BlockOnCommand(alien_walker.Move_To(invader_creation_position.Get_Position()))					
					elseif walker_move_random == 2 then
						BlockOnCommand(alien_walker.Move_To(walker_move_03.Get_Position()))			
					elseif walker_move_random == 3 then
						BlockOnCommand(alien_walker.Move_To(marker_alien_arrival_01.Get_Position()))					
					else
						BlockOnCommand(alien_walker.Move_To(base_location.Get_Position()))					
					end
				end
			end
		end
	end
end

function Act03_Dragoon_Spawn()
	dragoon_squad = SpawnList(dragoon_spawn_list, marker_alien_arrival_01, uea, false, true)
	if table.getn(dragoon_squad) then
		for k,dragoons in pairs (dragoon_squad) do
			dragoons.Move_To(base_location)
		end
	end
end

function Act03_Hide_Units(obj_list)
	for i,unit in pairs(obj_list) do
		if TestValid(unit) then
			unit.Hide(true)
		end
	end
end

function Act03_Unhide_Units(obj_list)
	for i,unit in pairs(obj_list) do
		if TestValid(unit) then
			unit.Hide(false)
			local parent = unit.Get_Parent_Object()
			if parent and TestValid(hero_tank) then
				if parent.Has_Behavior(BEHAVIOR_TEAM) then
					parent.Move_To(hero_tank.Get_Position())
				else
					unit.Move_To(hero_tank.Get_Position())
				end
			end
		end
	end
end

function Feedback(message, duration)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Stub_Text", nil, {message} )
	if duration then
		Register_Timer(Clear_Feedback, duration)
	end
end

function Clear_Feedback()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Stub_Text", nil, {} )
end

function Repeat_Hero_Movie(params)

	-- Play the bink movie, fire and forget (no blocking)
	hero = params[1]
	bink_filename = params[2]
    Start_Hero_Movie(hero, bink_filename)
	
	-- Repeat until we issue a Cancel_Timer on this funciton
	Register_Timer(Repeat_Hero_Movie, objective_repeat_delay, params)
end

function Delayed_Zenzo_Line()
	Start_Hero_Movie(hero_tank, "MIVS_ZEN0315_ENG") -- ZENZO: Why is that thing still standing?! Close ranks!
	if not debug_spawned_dragoons and not debug_destroyed_walker_legs then
		spawned_alien_tanks = SpawnList(alien_tank_wave_list, alien_tank_spawn, alien, false, true)
		Create_Thread("Thread_Spawn_More_Tanks")
	end
end

function Thread_Spawn_More_Tanks()
	Sleep(10)
	spawned_alien_tanks = SpawnList(alien_tank_wave_list, alien_tank_spawn, alien, false, true)
end

function Mission_Over_Camera_UI()
	Rotate_Camera_By(180,30)
	--Letter_Box_In(0)
	Suspend_AI(1)
	Lock_Controls(1)
end

function Mission_Over(player)
	-- params: winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag
	Quit_Game_Now(player, true, false, false, true)
end

function Force_Victory(player)
	Mission_Over(player)
end

function Alien_Tank_Act3_Movements()

	alien_tank_attack_flyer = false
	
	while mission_active do
	
		alien_tank_list = Find_All_Objects_Of_Type("Alien_Recon_Tank")
	
		dragonfly_found = Find_First_Object("Military_Dragonfly_UAV")
		for i, unit in pairs (alien_tank_list) do
			if TestValid(unit) and alien_tank_attack_flyer then
				if TestValid(dragonfly_found) then
					unit.Activate_Ability("SWITCH_TYPE", true)
					unit.Move_To(dragonfly_found)
					alien_tank_attack_flyer = false
				else
					local closest_enemy = Find_Nearest(unit, uea, true)
					if TestValid(closest_enemy) then
						unit.Activate_Ability("SWITCH_TYPE", false)
						unit.Move_To(closest_enemy)
						alien_tank_attack_flyer = true
					end
				end
			else
				local closest_enemy = Find_Nearest(unit, uea, true)
				if TestValid(closest_enemy) then
					unit.Activate_Ability("SWITCH_TYPE", false)
					unit.Move_To(closest_enemy)
					alien_tank_attack_flyer = true
				end			
			end
		end
		
		Sleep(10)
		
	end
end

function Prox_Redirect_Aliens(prox_obj,trigger_obj)
	-- Check to make sure the object is alive and not a hardpoint
	if TestValid(trigger_obj) and (trigger_obj.Has_Behavior(BEHAVIOR_HARD_POINT) == false) and (trigger_obj ~= alien_walker) then
		local closest_enemy = Find_Nearest(trigger_obj, uea, true)
		if TestValid(closest_enemy) then
			trigger_obj.Attack_Move(closest_enemy)
		end
	end
end

function Thread_Act03_Alien_Governor()

	intro_civilian_list = Find_All_Objects_Of_Type("American_Civilian_Urban_01_Map_Loiterer")
	intro_alien_orders_loop = 0
	intro_alien_base_guard_toggle = false
		
	for i,unit in pairs (intro_civilian_list) do
		intro_alien_orders_loop = intro_alien_orders_loop + 1
		spawned_aliens = SpawnList(alien_assault_wave_list, unit.Get_Position(), alien, false, true)
		for j,alienspawn in pairs (spawned_aliens) do
			if intro_alien_orders_loop == 1 then
			
				-- Guard The Walker
				if TestValid(alien_walker) and TestValid (alienspawn) then
					alienspawn.Guard_Target(alien_walker)
				end
				
			elseif intro_alien_orders_loop > 1 and intro_alien_orders_loop < 3 then
				if intro_alien_base_guard_toggle then

					-- Guard The Base
					if TestValid(alienspawn) then
						alienspawn.Guard_Target(base_location.Get_Position())
					end
					intro_alien_base_guard_toggle = false
				else
				
					-- Flank Right
					if TestValid(alienspawn) then
						alienspawn.Attack_Move(marker_alien_arrival_00.Get_Position())
					end						
					intro_alien_base_guard_toggle = true
				end
				
			elseif intro_alien_orders_loop > 2 and intro_alien_orders_loop < 5 then

				-- Flank Left
				if TestValid(alienspawn) then
					alienspawn.Attack_Move(marker_alien_arrival_01.Get_Position())
				end
				
			elseif intro_alien_orders_loop > 4 and intro_alien_orders_loop < 8 then
			
				-- Flank Right
				if TestValid(alienspawn) then
					alienspawn.Attack_Move(marker_alien_arrival_00.Get_Position())
				end
				
			else
			
				-- Direct Assault
				local closest_enemy = Find_Nearest(alienspawn, uea, true)
				if TestValid(closest_enemy) then
					alienspawn.Attack_Move(closest_enemy)
				end
				
				intro_alien_orders_loop = 0
			end
		end
	end
end
