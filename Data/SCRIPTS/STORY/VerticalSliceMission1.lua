-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/VerticalSliceMission1.lua#132 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/VerticalSliceMission1.lua $
--
--    Original Author: Steve Copeland
--
--            $Author: Maria_Teruel $
--
--            $Change: 45689 $
--
--          $DateTime: 2006/06/05 11:19:14 $
--
--          $Revision: #132 $
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
	--MessageBox("%s -- definitions", tostring(Script))
	
	Define_State("State_Init", State_Init)
	

end

function State_Init(message)
	if message == OnEnter then
		military = Find_Player("Military")
		aliens = Find_Player("Alien")
		global_script = Get_Game_Mode_Script("Strategic")
		
		alien_hero = Find_First_Object("Alien_Hero")
		Create_Thread("Thread_Monitor_Death_Alien_Hero")
	end
end

function Thread_Monitor_Death_Alien_Hero()
	while TestValid(alien_hero) do
		Sleep(1)
	end
	MessageBox("Alien Hero destroyed!")
	Mission_Over(military)
end

function Mission_Over(player)

	-- Was the UEA the winning player?
	Military_won = player == military

	-- Inform the campaign script of our victory.
	global_script.Call_Function("On_Mission_1_Over", Military_won)

	-- params: winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag
	Quit_Game_Now(player, not Military_won, false, false)
end

-- Handle the victory debug command
function Force_Victory(player)
	Mission_Over(player)
end