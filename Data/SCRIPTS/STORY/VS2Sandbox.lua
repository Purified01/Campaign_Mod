-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/VS2Sandbox.lua#1 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/VS2Sandbox.lua $
--
--    Original Author: Steve Copeland
--
--            $Author: Steve_Copeland $
--
--            $Change: 47626 $
--
--          $DateTime: 2006/06/30 08:57:39 $
--
--          $Revision: #1 $
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
	
	Define_State("State_Init", State_Init)

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


		-- Find starting set of alien units, then keep this updated by events that add units.
		-- Remove dead units before making use of the list.
		alien_units = Find_All_Parent_Units("Infantry | Vehicle | Air", player_alien)
		alien_walkers = Find_All_Parent_Units("Walker", player_alien)
		novus_units = Find_All_Parent_Units("Infantry | Vehicle | Air | Hero", player_novus)
		military_units = Find_All_Parent_Units("Infantry | Vehicle | Air | Hero", player_military)

		-- Ignore the dummy hero, who is necessary to trigger the invasion.
		alien_hero = Find_First_Object("Alien_Hero")
		if not TestValid(alien_hero) then
			MessageBox("invalid alien hero")			
		end
		alien_hero.Hide(true)

		-- Put all novus units on guard
		for i, unit in pairs(novus_units) do
			unit.Guard_Target(unit.Get_Position())
		end
		
		-- Put all military units on guard
		for i, unit in pairs(military_units) do
			unit.Guard_Target(unit.Get_Position())
		end

		
	end
end

---------------------------------------------------------------------------------------------------
------ GLOBAL EVENTS -------------------------------------------------------------------------------

function On_Construction_Complete(obj)

	-- Add constructed units to the running lists
	if obj.Get_Owner() == player_alien then
	
		if obj.Get_Type() == Find_Object_Type("Alien_Walker_Habitat") then
			table.insert(alien_walkers, obj)
		else
			table.insert(alien_units, obj)
		end
	end
end
