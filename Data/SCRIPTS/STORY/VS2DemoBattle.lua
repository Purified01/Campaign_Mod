-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/VS2DemoBattle.lua#15 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/VS2DemoBattle.lua $
--
--    Original Author: Steve Copeland
--
--            $Author: Steve_Copeland $
--
--            $Change: 48834 $
--
--          $DateTime: 2006/07/14 10:59:39 $
--
--          $Revision: #15 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")
require("PGSpawnUnits")
require("PGMoveUnits")
require("UIControl")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")


---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	
	-- Maria 07.11.2006 - Needed for support of the ESC key
	ClosedHuds = false
	
	Define_State("State_Init", State_Init)
	Define_State("State_Air_Attack_One", State_Air_Attack_One)
	Define_State("State_Air_Attack_Two", State_Air_Attack_Two)
	Define_State("State_Mixed_Ground_Attack", State_Mixed_Ground_Attack)

	num_grunts_for_air_attack = 8
	
	uav_type_list = {
		"Military_Dragonfly_UAV"
		,"Military_Dragonfly_UAV"
		,"Military_Dragonfly_UAV"
		,"Military_Dragonfly_UAV"
	}

	jet_type_list = {
		"Novus_Dervish_Jet"
		,"Novus_Dervish_Jet"
	}

end



-- ---------------------------------------
-- Maria 07.11.2006
-- Support for the ESC key 
-- ---------------------------------------
function Close_All_Huds(were_huds_open)
	ClosedHuds = were_huds_open[1]
end


---------------------------------------------------------------------------------------------------
------ STATES	    -------------------------------------------------------------------------------



function State_Init(message)
	if message == OnEnter then
	
		-- Initialize various aspects of the scenario.
		--DebugBreak()

		state_start_time = GetCurrentTime()
		
		player_alien = Find_Player("Alien")
		player_novus = Find_Player("Novus")
		player_military = Find_Player("Military")
		
		FogOfWar.Reveal_All(player_alien)
		FogOfWar.Reveal_All(player_novus)
		FogOfWar.Reveal_All(player_military)
		

		--Set_Active_Context("vs2demo")

		-- Find various markers for spawning and pathing air units
		air_one_marker = Find_Hint("Marker_Generic", "air-one")
		if air_one_marker == nil then
			MessageBox("didn't find air_one_marker")
		end
		air_two_marker = Find_Hint("Marker_Generic", "air-two")
		if air_two_marker == nil then
			MessageBox("didn't find air_two_marker")
		end
		air_three_marker = Find_Hint("Marker_Generic", "air-three")
		if air_three_marker == nil then
			MessageBox("didn't find air_three_marker")
		end
        
		-- Find various markers for spawning and pathing ground units
		mixed_ground_units_marker_one = Find_Hint("Marker_Generic", "mixed-ground-one")
		if mixed_ground_units_marker_one == nil then
			MessageBox("didn't find mixed_ground_units_marker")
		end
		mixed_ground_units_marker_two = Find_Hint("Marker_Generic", "mixed-ground-two")
		if mixed_ground_units_marker_two == nil then
			MessageBox("didn't find mixed_ground_units_marker_two")
		end
		mixed_ground_units_marker_three = Find_Hint("Marker_Generic", "mixed-ground-three")
		if mixed_ground_units_marker_three == nil then
			MessageBox("didn't find mixed_ground_units_marker_three")
		end
		
		mech = Find_First_Object("Novus_Hero_Mech", player_novus)
		if mech == nil then
			MessageBox("didn't find mech")
		end

		Cache_Models()

		-- Find starting set of alien units, then keep this updated by events that add units.
		-- Remove dead units before making use of the list.
		alien_units = Find_All_Parent_Units("Infantry | Vehicle | Air", player_alien)
		alien_walkers = Find_All_Parent_Units("Walker", player_alien)
		alien_grunts = {}
		
		-- Ignore the dummy hero, who is necessary to trigger the invasion.
		alien_hero = Find_First_Object("Alien_Hero", player_alien)
		if not TestValid(alien_hero) then
			MessageBox("didn't find alien_hero")
		else			
			alien_hero.Hide(true)  				-- Can't be seen
			alien_hero.Set_Selectable(false)	-- Can't be selected
			alien_hero.Set_In_Limbo(true)		-- Can't be attacked by enemies
		end
		
		-- Tell the defense units to guard their current position.
		novus_units = Find_All_Parent_Units("Infantry | Vehicle | Hero", player_novus)
		for i, unit in pairs(novus_units) do
			unit.Guard_Target(unit.Get_Position())
		end
		
		-- The mech's default weapon should be used continuously and the special attack (missiles) should autofire when available.	
		mech.Set_All_Abilities_Autofire(true)

		-- DEBUG SKIP
		--Set_Next_State("State_Mixed_Ground_Attack")

	elseif message == OnUpdate then
	
		-- Move to the next state if the player has eno`ugh units 
		Remove_Invalid_Objects(alien_grunts)
		if (alien_grunts and table.getn(alien_grunts) >= num_grunts_for_air_attack) then
			Set_Next_State("State_Air_Attack_One")
		end

	elseif message == OnExit then


	end
end


function Cache_Models()
	Find_Object_Type("Alien_Team_Science_Greys").Load_Assets()
	Find_Object_Type("Alien_Recon_Tank").Load_Assets()
	Find_Object_Type("Alien_Grunt").Load_Assets()
	Find_Object_Type("Alien_Brute").Load_Assets()
	Find_Object_Type("Military_Dragonfly_UAV").Load_Assets()
	Find_Object_Type("Novus_Dervish_Jet").Load_Assets()
end

---------------------------------------------------------------------------------------------------



function State_Air_Attack_One(message)
	if message == OnEnter then
	
		-- Jets attack the first walker.
		novus_jets = SpawnList(jet_type_list, air_one_marker, player_novus)
		Concat_Indexed_Tables(novus_jets, SpawnList(jet_type_list, air_two_marker, player_novus))
		Concat_Indexed_Tables(novus_jets, SpawnList(jet_type_list, air_three_marker, player_novus))
		for i, unit in pairs(novus_jets) do
			unit.Attack_Target(alien_walkers[1])
		end

		-- UAVs attack everything the alien player has that's not a walker.
		military_uav = SpawnList(uav_type_list, air_one_marker, player_novus)
		Concat_Indexed_Tables(military_uav, SpawnList(uav_type_list, air_two_marker, player_novus))
		Concat_Indexed_Tables(military_uav, SpawnList(uav_type_list, air_three_marker, player_novus))
		Attack_All(military_uav, alien_units)
		
		-- Jets return independently, without blocking
		-- (there is a bug with their formation move where it doesn't finish blocking)
		Remove_Invalid_Objects(novus_jets)
		for i, unit in pairs(novus_jets) do
			unit.Move_To(air_one_marker)
		end

		-- UAVs run away.
		Formation_Move(military_uav, air_one_marker)

		-- One time (non blocking) guard order to the UAVs.
		Remove_Invalid_Objects(military_uav)
		for i, unit in pairs(military_uav) do
			unit.Guard_Target(air_one_marker)
		end

	elseif message == OnUpdate then
	
		-- Move to the next state if enough anti-air hardpoints are configured or if enough time has elapsed.
		local aa_count = Get_Hardpoint_Count(alien_walkers, Find_Object_Type("Alien_Walker_Habitat_Lightning_Turret"))
		if (aa_count >= 2) then
			Set_Next_State("State_Air_Attack_Two")
		end

	end
	
end





---------------------------------------------------------------------------------------------------



function State_Air_Attack_Two(message)
	if message == OnEnter then
	
		state_start_time = GetCurrentTime()

		-- Have jets attack a walker, non blocking
		-- Formation_Move for jets is bugged.
		Remove_Invalid_Objects(novus_jets)
		Remove_Invalid_Objects(alien_walkers)
		if alien_walkers[1] ~= nil then
			for i, unit in pairs(novus_jets) do
				unit.Attack_Target(alien_walkers[1])
			end
		end
		
		-- Attack everything the alien player has, sequentially.
		Attack_All(military_uav, alien_units)
		Attack_Move_All(military_uav, alien_walkers)

	elseif message == OnUpdate then
	
		-- Move to the next state if enough anti-vehicle hardpoints are configured or if enough time has elapsed.
		local av_count = Get_Hardpoint_Count(alien_walkers, Find_Object_Type("Alien_Walker_Habitat_Back_Plasma_Turret"))
		if (av_count >= 1) then
			Set_Next_State("State_Mixed_Ground_Attack")
			return
		end

		allow_reset_to_first_state = true
	end
end


---------------------------------------------------------------------------------------------------



function State_Mixed_Ground_Attack(message)
	if message == OnEnter then
	
		state_start_time = GetCurrentTime()
		
		-- Attack the player with mixed novus units.  Each attack blocks, so run in separate threads for staggered attack control.
		Create_Thread("Gound_Attack_One")
		Sleep(10)
		Create_Thread("Ground_Attack_Two")
		Sleep(15)
		Create_Thread("Ground_Attack_Three")
		
		-- Indefinately search for new walkers.
		Create_Thread("Hunt_Walkers")
	end
end

function Gound_Attack_One()
	local recruit_radius = 300
	-- TODO: attack with vehicles, have infantry guard the vehicles.
	novus_mixed_ground_one = Find_All_Parent_Units("Infantry | Vehicle | Hero", player_novus, mixed_ground_units_marker_one, recruit_radius)
	Attack_Move_All(novus_mixed_ground_one, alien_walkers)
end

function Ground_Attack_Two()
	local recruit_radius = 300
	novus_mixed_ground_two = Find_All_Parent_Units("Infantry | Vehicle | Hero", player_novus, mixed_ground_units_marker_two, recruit_radius)
	Attack_Move_All(novus_mixed_ground_two, alien_walkers)
end

function Ground_Attack_Three()
	local recruit_radius = 300
	novus_mixed_ground_three = Find_All_Parent_Units("Infantry | Vehicle | Hero", player_novus, mixed_ground_units_marker_three, recruit_radius)
	Attack_Move_All(novus_mixed_ground_three, alien_walkers)
	
	-- Just put all of the units on guard again.
	Remove_Invalid_Objects(novus_units)
	for i, unit in pairs(novus_units) do
		unit.Guard_Target(unit.Get_Position())
	end	
end

function Hunt_Walkers()
	while true do
		Attack_Move_All(novus_units, alien_walkers)
		Sleep(1)
	end
end


---------------------------------------------------------------------------------------------------
------ UTILITIES -------------------------------------------------------------------------------


-- Move to library?
function Remove_Type_From_List(unit_list, type)
	for i, unit in pairs(unit_list) do
		if unit.Get_Type() == type then
			table.remove(unit_list, i)
			
			-- Can't continue to iterate a mutated list, so recurse.
			Remove_Type_From_List(unit_list, type)
			return
		end
	end
end


-- BLOCKING Attack move to all victims, one at a time, in an arbitrary order.
function Attack_Move_All(attacker_list, victim_list)

	if victim_list then
		for i=1, table.getn(victim_list) do
			Remove_Invalid_Objects(attacker_list)
			if TestValid(victim_list[i]) then
				Formation_Attack_Move(attacker_list, victim_list[i])
			end
		end
	
		Remove_Invalid_Objects(victim_list)
	end
end


-- BLOCKING Attack all victims, one at a time, in an arbitrary order.
function Attack_All(attacker_list, victim_list)

	if victim_list then
		for i=1, table.getn(victim_list) do
			Remove_Invalid_Objects(attacker_list)
			if TestValid(victim_list[i]) then
				Formation_Attack(attacker_list, victim_list[i])
			end
		end
	
		Remove_Invalid_Objects(victim_list)
	end
end

-- Move to library?
function Remove_Hardpoints_From_List(obj_list)
	for i, obj in pairs(obj_list) do
		if obj.Has_Behavior(BEHAVIOR_HARD_POINT) then
			table.remove(obj_list, i)
			
			-- Can't continue to iterate a mutated list, so recurse.
			Remove_Type_From_List(obj_list)
			return
		end
	end
end

-- Insert table 2 elements to the end of table 1 (table.concat returns a string and isn't useful).
function Concat_Indexed_Tables(table1, table2)
	for i, entry in pairs(table2) do
		table.insert(table1, entry)
	end
end



function Get_Hardpoint_Count(unit_list, hp_type)

	Remove_Invalid_Objects(unit_list)
	
	local count = 0
	for i, unit in pairs(unit_list) do
		if unit.Has_Behavior(BEHAVIOR_HARD_POINT_MANAGER) then
			hp_list = unit.Find_All_Hard_Points_Of_Type(hp_type)
			if hp_list ~= nil then
				count = count + table.getn(hp_list)
			end
		else
			ScriptError("Count_Hardpoints received a non-walker")
		end
	end
	
	return count
end

-- Each member of an attacker list will find the nearest enemy and attack it.
-- Non blocking script.  Issue repeatedly to clear a map of enemies.
function Attack_Nearest_Enemy_All(attacker_list)

	Remove_Invalid_Objects(attacker_list)
	
	if attacker_list then
		local owner_player = attacker_list[1].Get_Owner()
		for i, attacker in pairs(attacker_list) do

			if TestValid(attacker) and not attacker.Has_Active_Orders() then
				nearest_enemy = Find_Nearest(attacker, "Infantry | Vehicle | Walker", owner_player, false)
				if TestValid(nearest_enemy) then
					attacker.Attack_Target(nearest_enemy)
				end
			end
		end
	end
end



---------------------------------------------------------------------------------------------------
------ GLOBAL EVENTS -------------------------------------------------------------------------------

function On_Construction_Complete(obj)

	-- Add constructed units to the running lists
	if obj.Get_Owner() == player_alien then

		local obj_type =  obj.Get_Type()  
		if obj_type == Find_Object_Type("Alien_Walker_Habitat") then
			table.insert(alien_walkers, obj)
		else
			table.insert(alien_units, obj)
			if obj_type == Find_Object_Type("Alien_Grunt") then
				table.insert(alien_grunts, obj)
				
				-- During Air_Attack_Two's update, the player can reset to state one by building a grunt.
				if allow_reset_to_first_state then
					local aa_count = Get_Hardpoint_Count(alien_walkers, Find_Object_Type("Alien_Walker_Habitat_Lightning_Turret"))
					if aa_count == 0 then
						allow_reset_to_first_state = false
						Set_Next_State("State_Air_Attack_One")
					end
				end
			end
		end
	end
end


