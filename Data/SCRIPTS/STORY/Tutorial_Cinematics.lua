-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Tutorial_Cinematics.lua#4 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Tutorial_Cinematics.lua $
--
--    Original Author: Nader Akoury
--
--            $Author: Mike_Lytle $
--
--            $Change: 86719 $
--
--          $DateTime: 2007/10/25 16:10:00 $
--
--          $Revision: #4 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_Tutorial_1", State_Tutorial_1)
	Define_State("State_Tutorial_2", State_Tutorial_2)
	Define_State("State_Tutorial_3", State_Tutorial_3)
	Define_State("State_Tutorial_4", State_Tutorial_4)
	Define_State("State_Tutorial_5", State_Tutorial_5)
	Define_State("State_Tutorial_6", State_Tutorial_6)
	Define_State("State_Tutorial_7", State_Tutorial_7)
	Define_State("State_Tutorial_8", State_Tutorial_8)
	Define_State("State_Tutorial_9", State_Tutorial_9)
	Define_State("State_Tutorial_10", State_Tutorial_10)
	Define_State("State_Tutorial_11", State_Tutorial_11)
	Define_State("State_Tutorial_12", State_Tutorial_12)
	Define_State("State_Tutorial_13", State_Tutorial_13)
	Define_State("State_Tutorial_14", State_Tutorial_14)
	Define_State("State_Tutorial_15", State_Tutorial_15)
	Define_State("State_Tutorial_16", State_Tutorial_16)
	
	current_cine_thread=nil
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		Fade_Screen_Out(0)
		Letter_Box_In(0)
		Stop_All_Music()
		Lock_Controls(1)
		
		Register_Game_Scoring_Commands()

		local data_table = GameScoringManager.Get_Game_Script_Data_Table()
		if data_table == nil or data_table.Tutorial == nil then
			Quit_To_Main_Menu()
		else
			Set_Next_State(tostring(data_table.Tutorial))
			data_table.Tutorial = nil
			GameScoringManager.Set_Game_Script_Data_Table(data_table)
		end
	elseif message == OnUpdate then
	end
end

function State_Tutorial_1(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_1.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_2(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_2.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_3(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_3.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_4(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_4.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_5(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_5.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_6(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_6.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_7(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_7.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_8(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_8.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_9(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_9.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_10(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_10.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_11(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_11.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_12(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_12.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_13(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_13.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_14(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_14.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_15(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_15.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function State_Tutorial_16(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Tutorial_16.bik")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Quit_To_Main_Menu()
		end
	end
end

function Movie(file)
	--french and german need slower movie frame rates to
	--fit in the speech
	if Get_Speech_Language() == "FRENCH" then
		Play_Bink_Movie("blank.bik", false)
		Get_Game_Mode_GUI_Scene().full_screen_movie.Stop()
		Get_Game_Mode_GUI_Scene().full_screen_movie.Force_Frame_Rate(24)	
	elseif Get_Speech_Language() == "GERMAN" then
		Play_Bink_Movie("blank.bik", false)
		Get_Game_Mode_GUI_Scene().full_screen_movie.Stop()
		Get_Game_Mode_GUI_Scene().full_screen_movie.Force_Frame_Rate(15)
	end
    BlockOnCommand(Play_Bink_Movie(file,true))
    Get_Game_Mode_GUI_Scene().full_screen_movie.Reset_Frame_Rate()
    current_cine_thread=nil
end

function Quit_To_Main_Menu()
	Letter_Box_Out(0)
	Lock_Controls(0)
	_Quit_Game_Now()
end

--***************************************THREADS****************************************************************************************************

function Story_Handle_Esc()
	if not EscToStartState then
		if current_cine_thread then
			Thread.Kill(current_cine_thread)
			current_cine_thread=nil
		end
	end
end
