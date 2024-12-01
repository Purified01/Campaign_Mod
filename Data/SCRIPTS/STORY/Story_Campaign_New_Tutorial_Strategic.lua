-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_New_Tutorial_Strategic.lua#9 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_New_Tutorial_Strategic.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Brian_Hayes $
--
--            $Change: 85705 $
--
--          $DateTime: 2007/10/08 14:21:22 $
--
--          $Revision: #9 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("RetryMission")
require("PGColors")
require("PGPlayerProfile")
require("PGFactions")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")
ScriptPoolCount = 0

---------------------------------------------------------------------------------------------------

function Definitions()
	Define_State("State_Init", State_Init)
	Define_State("State_Start_Tut03", State_Start_Tut03) 
	Define_State("State_Tutorial_Campaign_Over", State_Tutorial_Campaign_Over) 
	
	-- Oksana: mark as tutorial so scoring manager knows what to expect
	IsTutorialCampaign = true;
	
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")

	PGFactions_Init()
	PGColors_Init_Constants()
	PGPlayerProfile_Init_Constants()
	--aliens.Enable_Colorization(true, COLOR_RED)
	--novus.Enable_Colorization(true, COLOR_CYAN)
	--uea.Enable_Colorization(true, COLOR_GREEN)
	--masari.Enable_Colorization(true, COLOR_DARK_GREEN)
	
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		Force_Default_Game_Speed()
		Register_Game_Scoring_Commands()
		Fade_Screen_Out(0)
		
		Set_Next_State("State_Start_Tut03")
	end
end

function State_Start_Tut03(message)
	if message == OnEnter then
		Fade_Screen_Out(0)
		
		UI_Set_Loading_Screen_Faction_ID(PG_FACTION_ALIEN)
		UI_Set_Loading_Screen_Background("Splash_Alien.tga")
		UI_Set_Loading_Screen_Mission_Text("TEXT_SP_MISSION_TUT03_LOAD_SCREEN_TEXT")
		
		Force_Land_Invasion(Find_First_Object("Region27"), novus, aliens, false)
	end
end

function State_Tutorial_Campaign_Over(message)
	if message == OnEnter then
		Fade_Screen_Out(0)
		Quit_Game_Now(aliens, true, false, false)
	end
end

--***************************************EVENT HANDLERS****************************************************************************************************
--this is used to overwrite the "Sandbox" map lineup and force which maps+scripts to use
function On_Land_Invasion()
	if CurrentState == "State_Start_Tut03" then 
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/TUT_03_Tutorial_City.ted"
		InvasionInfo.TacticalScript = "Story_Campaign_Tutorial_Tut03"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = false
		InvasionInfo.StartingContext = "StoryCampaign"
		InvasionInfo.NightMission = false
	end
end



--***************************************FUNCTIONS****************************************************************************************************
-- This is the "global" win/lose function triggered in the Novus "TACTICAL" mission scripts 
function Alien_Tactical_Mission_Over(victorious)
	if CurrentState == "State_Start_Tut03" then 
		if victorious then 
			-- Oksana: Notify achievements
			GameScoringManager.Notify_Achievement_System_Of_Campaign_Completion("Tutorial")

			Set_Next_State("State_Tutorial_Campaign_Over")
			
		end
	end
end

function Post_Load_Callback()
	--Make sure that we can still call Game Scoring commands after a load
	Register_Game_Scoring_Commands()
	Movie_Commands_Post_Load_Callback()
end

