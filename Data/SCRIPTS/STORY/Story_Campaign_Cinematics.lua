-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Cinematics.lua#2 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Cinematics.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Jeff_Stewart $
--
--            $Change: 72902 $
--
--          $DateTime: 2007/06/12 09:40:06 $
--
--          $Revision: #2 $
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
	Define_State("State_Cine_1", State_Cine_1)
	Define_State("State_Cine_2", State_Cine_2)
	Define_State("State_Cine_3", State_Cine_3)
	Define_State("State_Cine_4", State_Cine_4)
	Define_State("State_Cine_5", State_Cine_5)
	Define_State("State_Cine_6", State_Cine_6)
	Define_State("State_Cine_7", State_Cine_7)
	Define_State("State_Cine_8", State_Cine_8)
	Define_State("State_Cine_9", State_Cine_9)
	Define_State("State_Cine_10", State_Cine_10)
	Define_State("State_Cine_11", State_Cine_11)
	Define_State("State_Cine_12", State_Cine_12)
	Define_State("State_Cine_13", State_Cine_13)
	Define_State("State_Cine_14", State_Cine_14)
	Define_State("State_Cine_15", State_Cine_15)
	Define_State("State_Cine_16", State_Cine_16)
	Define_State("State_Cine_17", State_Cine_17)
	Define_State("State_Cine_18", State_Cine_18)
	Define_State("State_Cine_19", State_Cine_19)
	Define_State("State_Cine_20", State_Cine_20)
	Define_State("State_Cine_21", State_Cine_21)
	Define_State("State_Cine_Campaign_Over", State_Cine_Campaign_Over)
	
	current_cine_thread=nil
	JumpToNextCine=false
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		Fade_Screen_Out(0)
		Letter_Box_In(0)
		Stop_All_Music()
		Lock_Controls(1)
		Set_Next_State("State_Cine_1")
	elseif message == OnUpdate then
	end
end

function State_Cine_1(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Mission_1_Intro")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_2")
		end
	end
end

function State_Cine_2(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Mission_1_Outro")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_3")
		end
	end
end

function State_Cine_3(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Mission_2_Midtro")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_4")
		end
	end
end

function State_Cine_4(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Novus_M2_S3")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_5")
		end
	end
end

function State_Cine_5(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Novus_M3_S1")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_6")
		end
	end
end

function State_Cine_6(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Novus_M7_S1")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_7")
		end
	end
end

function State_Cine_7(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Novus_M7_S3")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_8")
		end
	end
end

function State_Cine_8(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Hierarchy_Intro")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_9")
		end
	end
end

function State_Cine_9(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Hierarchy_M1_S3")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_10")
		end
	end
end

function State_Cine_10(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Hierarchy_M1_S4")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_11")
		end
	end
end

function State_Cine_11(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Hierarchy_M2_S4")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_12")
		end
	end
end

function State_Cine_12(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Hierarchy_M4_S1")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_13")
		end
	end
end

function State_Cine_13(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Hierarchy_M4_S3")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_14")
		end
	end
end

function State_Cine_14(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Hierarchy_M5_S4")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_15")
		end
	end
end

function State_Cine_15(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Hierarchy_M6_S1")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_16")
		end
	end
end

function State_Cine_16(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Hierarchy_M6_S3")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_17")
		end
	end
end

function State_Cine_17(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Hierarchy_Campaign_Finale")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_18")
		end
	end
end

function State_Cine_18(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Masari_Campaign_Intro")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_19")
		end
	end
end

function State_Cine_19(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Masari_M1_S4")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_20")
		end
	end
end

function State_Cine_20(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","Masari_Campaign_Finale")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_21")
		end
	end
end

function State_Cine_21(message)
	if message == OnEnter then
		current_cine_thread=Create_Thread("Movie","CREDITS")
	elseif message == OnUpdate then
		if current_cine_thread==nil then
			Set_Next_State("State_Cine_Campaign_Over")
		end
	end
end

function Movie(file)
    BlockOnCommand(Play_Bink_Movie(file,true))
    current_cine_thread=nil
end

--detects the win of NM07 and then exits to main menu
function State_Cine_Campaign_Over(message)
	if message == OnEnter then
		Letter_Box_Out(0)
		Lock_Controls(0)
		Quit_Game_Now(novus, true, true, false)
	end
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

