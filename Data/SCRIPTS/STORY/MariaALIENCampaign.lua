-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/MariaALIENCampaign.lua#2 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/MariaALIENCampaign.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Maria_Teruel $
--
--            $Change: 57949 $
--
--          $DateTime: 2006/11/13 12:52:33 $
--
--          $Revision: #2 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require('PGDebug')
require("PGStateMachine")


require("PGStateMachine")
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

---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then
		-- Spawn a non-gameplay scientist object to reserve a hero icon and PIP
		region = Find_First_Object("Region25")
		aliens = Find_Player("Alien")
		chief_scientist_type = Find_Object_Type("ALIEN_Hero_Chief_Scientist_PIP_Only")
		hero_chief_scientist = Create_Generic_Object(chief_scientist_type, Create_Position(), aliens)
	elseif message == OnUpdate then
	end
end


function Force_Victory(player)
	-- params: winning_player, quit_to_main_menu, destroy_loser_forces, build_temporary_command_center, VerticalSliceTriggerVictorySplashFlag
	-- Maria 05.31.2006 -- testing!
	--Quit_Game_Now(player, false, true, true)
	Quit_Game_Now(player, false, false, false)
end

