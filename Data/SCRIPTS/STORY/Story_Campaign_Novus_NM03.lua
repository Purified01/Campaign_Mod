  -- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM03.lua#64 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM03.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Dan_Etter $
--
--            $Change: 90267 $
--
--          $DateTime: 2008/01/03 16:44:06 $
--
--          $Revision: #64 $
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
	Define_State("State_Init", State_Init)
	
	--Set_Active_Context("StoryCampaign") -- TRY REMOVING
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")
	
	PGColors_Init_Constants()
--	aliens.Enable_Colorization(true, COLOR_RED)
--	novus.Enable_Colorization(true, COLOR_CYAN)
	
   player_faction = novus

	failure_text = "TEXT_SP_MISSION_MISSION_FAILED"
	
	--State Bools go here!
	bool_skip_intro = false
	construction_objective_01_given = false
	construction_objective_01_complete = false
	construction_objective_02_given = false
	construction_objective_02_complete = false
	construction_objective_03_given = false
	construction_objective_03_complete = false
	construction_objective_04_given = false
	construction_objective_04_complete = false
	construction_objective_05_given = false
	construction_objective_05_complete = false
	construction_objective_06_given = false
	construction_objective_06_complete = false
	construction_objective_07_given = false
	construction_objective_07_complete = false
	download_hint_given = false
   piece_1_prox_played = false
   piece_3_prox_played = false
   piece_5_prox_played = false
	mission_success = false
	mission_failure = false
	mission_started = false
	mission_complete = false
	piece06_deposited = false
	piece07_deposited = false
	gatherer_06_killed = false
	gatherer_07_killed = false
	
	reinforcements_allowed=false
	
	--Gereric Variables go here!
	constructors_built = 0
	time_objective_sleep = 5
	piece_offset = 1
	pieces_collected = 0
	walkers_killed = 0
	patrol_offset1 = 0
	patrol_offset2 = 0
	patrol_offset3 = 0
	
	--Alien Unit Counts:
	nm03_glyph_carvers = 2
	nm03_lost_ones = 10
	nm03_grunts = 10
	nm03_monoliths = 3
	nm03_brutes = 5
	unit_death_counter = 0
	unit_deaths_before_using_controller = 5
	
	
	--List Inits go here!
	walker_list = {}
	patrol_interrupted = {}
	walker_spawn_loc = {}
	walker_goto = {}
	portal_piece = {}
	piece_loc = {}
	pieces_at_base = {false, false, false, false, false, false, false}
	--piece_type = {
	--	"NOVUS_PORTAL_PIECE_01",
	--	"NOVUS_PORTAL_PIECE_01",
	--	"NOVUS_PORTAL_PIECE_01",
	--	"NOVUS_PORTAL_PIECE_01",
	--	"NOVUS_PORTAL_PIECE_01",
	--	"NOVUS_PORTAL_PIECE_01",
	--	"NOVUS_PORTAL_PIECE_01"
	--}
	
	dialog_nov_comm = "NI_Comm_Officer_Pip_Head.alo"
	dialog_mirabel = "NH_Mirabel_Pip_Head.alo"
	dialog_viktor = "NH_Viktor_Pip_Head.alo"
	dialog_nov_science = "NI_Science_Officer_Pip_Head.alo"
	dialog_founder = "NH_founder_Pip_Head.alo"
	dialog_vertigo = "NH_Vertigo_Pip_Head.alo"
	dialog_dervish = "NH_Vertigo_Pip_Head.alo"
	
	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
	--jdg must nil out fow references for save/load to work
	portal_fow = nil
	cin_reveal = nil
	
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through
function State_Init(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("*********************************************Story_Campaign_Novus_NM03 START!"))
		
		Cache_Models()
		
		Lock_Objects(true)
		
		--AI Base maintenance stuff.
		aliens.Allow_Autonomous_AI_Goal_Activation(true)
		Maintain_Base(aliens, "NM03_AI_Layout")
		
		player_script = aliens.Get_Script()
	
	uea.Allow_AI_Unit_Behavior(false)
	aliens.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	
		-- ***** ACHIEVEMENT_AWARD *****
		PGAchievementAward_Init()
		-- ***** ACHIEVEMENT_AWARD *****
		
		-- ***** HINT SYSTEM *****
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		local scene = Get_Game_Mode_GUI_Scene()
		Register_Hint_Context_Scene(scene)			-- Set the scene to which independant hints will be attached.
		-- ***** HINT SYSTEM *****
		
		-- Initial Starting Credits		
		credits = novus.Get_Credits()
		novus.Give_Money(10000)
		if credits > 10000 then
			credits = (credits - 10000) * -1
			novus.Give_Money(credits)
		end		
		alien_credits = aliens.Get_Credits()
		aliens.Give_Money(10000)
		if alien_credits > 10000 then
			alien_credits = (credits - 10000) * -1
			aliens.Give_Money(alien_credits)
		end
		
		foo_list = Find_All_Objects_Of_Type("Alien_Foo_Core")
		for i, unit in pairs(foo_list) do
			if TestValid(unit) then
				unit.Prevent_AI_Usage(true)
			end
		end
		
		mirabel_loc = Find_Hint("MARKER_GENERIC_YELLOW","mirabelloc")
		
		mirabel = Find_First_Object("Novus_Hero_Mech")
		-- heroes nerfed late, so adding damage modifier, Mirabel old health(1800) / Mirabel new health(1000) - 1 = -.45
		if TestValid(mirabel) then mirabel.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.45) end
		if TestValid(mirabel) then
			mirabel.Teleport_And_Face(mirabel_loc)
		   mirabel.Register_Signal_Handler(Callback_Mirabel_Killed, "OBJECT_HEALTH_AT_ZERO")
			Point_Camera_At(mirabel)
		else
			--MessageBox("Story_Campaign_Novus_NM03 cannot find Mirabel, Creating one!")
			mirabel = Spawn_Unit(Find_Object_Type("NOVUS_HERO_MECH"), mirabel_loc, novus)
			mirabel.Teleport_And_Face(mirabel_loc)
		   mirabel.Register_Signal_Handler(Callback_Mirabel_Killed, "OBJECT_HEALTH_AT_ZERO")
			Point_Camera_At(mirabel)
		end
		
		vertigo = Find_First_Object("Novus_Hero_Vertigo")
		-- heroes nerfed late, so adding damage modifier, Mirabel old health(1000) / Mirabel new health(700) - 1 = -.3
		if TestValid(vertigo) then vertigo.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.3) end
		if TestValid(vertigo) then		   
		   Register_Prox(vertigo, PROX_Vertigo_Piece, 200)
		   vertigo.Register_Signal_Handler(Callback_Object_Downloaded, "OBJECT_EFFECT_APPLIED")
		   vertigo.Register_Signal_Handler(Callback_Vertigo_Killed, "OBJECT_HEALTH_AT_ZERO")
		end
		
		piece_dropoff = Find_First_Object("Novus_Portal_Transport")
		UI_Enable_For_Object(piece_dropoff, false)--turning off odd button on this unit
		piece_dropoff.Register_Signal_Handler(Callback_Transport_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
		
		Register_Prox(piece_dropoff, PROX_Portal_Piece, 183) --182.61
		
		vertigo_way_1 = Find_Hint("MARKER_GENERIC_BLUE","vertigoway1")
		vertigo_way_2 = Find_Hint("MARKER_GENERIC_BLUE","vertigoway2")
		
		cin_resource = Find_Hint("RESOURCE_PILE_DUMMY_OBJECT","cinresource")
		
		piece_loc[1] = Find_Hint("MARKER_GENERIC_PURPLE","piece01spawn")
		piece_loc[2] = Find_Hint("MARKER_GENERIC_PURPLE","piece02spawn")
		piece_loc[3] = Find_Hint("MARKER_GENERIC_PURPLE","piece03spawn")
		piece_loc[4] = Find_Hint("MARKER_GENERIC_PURPLE","piece04spawn")
		piece_loc[5] = Find_Hint("MARKER_GENERIC_PURPLE","piece05spawn")
		piece_loc[6] = Find_Hint("MARKER_GENERIC_PURPLE","piece06spawn")
		piece_loc[7] = Find_Hint("MARKER_GENERIC_PURPLE","piece07spawn")
		
		dervish_spawn_location = Find_Hint("MARKER_GENERIC", "dervishspawnloc")
		dervish_goto_location = Find_Hint("MARKER_GENERIC", "dervishgotoloc")
		
		portal1=Find_Hint("MOV_NOVUS_PORTAL","portal1")
		portal2=Find_Hint("MOV_NOVUS_PORTAL","portal2")
		portal3=Find_Hint("MOV_NOVUS_PORTAL","portal3")
		portal4=Find_Hint("MOV_NOVUS_PORTAL","portal4")
		portal5=Find_Hint("MOV_NOVUS_PORTAL","portal5")
		portal6=Find_Hint("MOV_NOVUS_PORTAL","portal6")
		portal7=Find_Hint("MOV_NOVUS_PORTAL","portal7")
		portal1_orig_loc = portal1.Get_Position()
		portal2_orig_loc = portal2.Get_Position()
		portal3_orig_loc = portal3.Get_Position()
		portal4_orig_loc = portal4.Get_Position()
		portal5_orig_loc = portal5.Get_Position()
		portal6_orig_loc = portal6.Get_Position()
		portal7_orig_loc = portal7.Get_Position()
		portal1.Teleport(dervish_spawn_location.Get_Position())
		portal2.Teleport(dervish_spawn_location.Get_Position())
		portal3.Teleport(dervish_spawn_location.Get_Position())
		portal4.Teleport(dervish_spawn_location.Get_Position())
		portal5.Teleport(dervish_spawn_location.Get_Position())
		portal6.Teleport(dervish_spawn_location.Get_Position())
		portal7.Teleport(dervish_spawn_location.Get_Position())
		portal1.Set_Object_Context_ID("Cinematic_Intro")
		portal2.Set_Object_Context_ID("Cinematic_Intro")
		portal3.Set_Object_Context_ID("Cinematic_Intro")
		portal4.Set_Object_Context_ID("Cinematic_Intro")
		portal5.Set_Object_Context_ID("Cinematic_Intro")
		portal6.Set_Object_Context_ID("Cinematic_Intro")
		portal7.Set_Object_Context_ID("Cinematic_Intro")
		
		walker_1=Find_Hint("NM03_CUSTOM_HABITAT_WALKER","walker1")
		walker_1.Prevent_AI_Usage(true)
		walker_2=Find_Hint("NM03_CUSTOM_HABITAT_WALKER","walker2")
		walker_2.Prevent_AI_Usage(true)
		walker_3=Find_Hint("NM03_CUSTOM_HABITAT_WALKER","walker3")
		walker_3.Prevent_AI_Usage(true)

		walker_spawn_loc[1] = Find_Hint("MARKER_GENERIC_PURPLE","walkerloc01")
		walker_spawn_loc[2] = Find_Hint("MARKER_GENERIC_PURPLE","walkerloc02")
		walker_spawn_loc[3] = Find_Hint("MARKER_GENERIC_PURPLE","walkerloc03")
		
		walker_goto[1] = Find_Hint("MARKER_GENERIC_YELLOW","walkergoto01")
		walker_goto[2] = Find_Hint("MARKER_GENERIC_YELLOW","walkergoto02")
		walker_goto[3] = Find_Hint("MARKER_GENERIC_YELLOW","walkergoto03")
		
		gatherer_loc_00 = Find_Hint("MARKER_GENERIC_PURPLE","gathererloc00")
		alien_base_loc = Find_Hint("MARKER_GENERIC_BLUE","alienbaseloc")
		piece_06_goto = Find_Hint("MARKER_GENERIC_PURPLE","piece06goto")
		piece_06_temp_loc = Find_Hint("MARKER_GENERIC_PURPLE","piece06temploc")
		piece_07_goto = Find_Hint("MARKER_GENERIC_PURPLE","piece07goto")
		piece_07_temp_loc = Find_Hint("MARKER_GENERIC_PURPLE","piece07temploc")
		
		patrol_1 = {}
		patrol_1[1] = Find_Hint("MARKER_GENERIC", "pat1-1")
		patrol_1[2] = Find_Hint("MARKER_GENERIC", "pat1-2")
		patrol_1[3] = Find_Hint("MARKER_GENERIC", "pat1-3")
		patrol_1[4] = Find_Hint("MARKER_GENERIC", "pat1-4")
		patrol_1[5] = Find_Hint("MARKER_GENERIC", "pat1-5")
		patrol_1[6] = Find_Hint("MARKER_GENERIC", "pat1-6")
		patrol_2 = {}
		patrol_2[1] = Find_Hint("MARKER_GENERIC", "pat2-1")
		patrol_2[2] = Find_Hint("MARKER_GENERIC", "pat2-2")
		patrol_2[3] = Find_Hint("MARKER_GENERIC", "pat2-3")
		patrol_2[4] = Find_Hint("MARKER_GENERIC", "pat2-4")
		patrol_2[5] = Find_Hint("MARKER_GENERIC", "pat2-5")
		patrol_2[6] = Find_Hint("MARKER_GENERIC", "pat2-6")
		
		foospawn=Find_Hint("MARKER_GENERIC","foospawners")
	
		ohm_1 = Find_Hint("NOVUS_ROBOTIC_INFANTRY", "ohm1")
		Create_Thread("Patrol_Ohm", ohm_1)
		ohm_2 = Find_Hint("NOVUS_ROBOTIC_INFANTRY", "ohm2")
		Create_Thread("Reverse_Patrol_Ohm", ohm_2)
		ohm_3 = Find_Hint("NOVUS_ROBOTIC_INFANTRY", "ohm3")
		Create_Thread("Patrol2_Ohm", ohm_3)
            
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
			
      Create_Thread("Thread_Mission_Start_Bink")
	elseif message == OnUpdate then
	end
end

function Story_Mode_Service()
	if mission_started and not mission_complete and pieces_collected == 7 then
	
		Create_Thread("Dialog_NM03_10_02")
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS03_OBJECTIVE_A_COMPLETE"} )
		Objective_Complete(nov03_objective00)

		mission_complete = true
		--All Pieces Collected!  Mission over!
		Create_Thread("Thread_Mission_Complete")
	end
end

function Thread_Foo_Kiters()
	novus_base_loc=Find_Hint("MARKER_GENERIC","novusbase")
	alien_base_loc=Find_Hint("MARKER_GENERIC","alienbase")
	foolist={"ALIEN_FOO_CORE","ALIEN_FOO_CORE"}
	fookiters={}
	while pieces_collected<6 do
		numfoos=0
		hurtfoos=0
		
		for i, foos in pairs(fookiters) do
			if TestValid(foos) then
				numfoos=numfoos+1
				if foos.Get_Hull()<.75 then
					if not foos.Is_Ability_Active("Unit_Ability_Foo_Core_Heal_Attack_Toggle") then
						foos.Activate_Ability("Unit_Ability_Foo_Core_Heal_Attack_Toggle", true)
					end
					hurtfoos=hurtfoos+1
				end
			end
		end
		if numfoos==0 then
			Sleep(GameRandom(30,60))
			fookiters=SpawnList(foolist, foospawn, aliens, false, true, true)
		end
		if hurtfoos==0 then
			for i, foos in pairs(fookiters) do
				if TestValid(foos) then
					Hunt(foos, "PrioritiesLikeOneWouldExpectThemToBe", true, true, novus_base_loc, 200)
				end
			end
		end
		if hurtfoos>0 then
			for i, foos in pairs(fookiters) do
				if TestValid(foos) then
					Hunt(foos, "PrioritiesLikeOneWouldExpectThemToBe", true, true, alien_base_loc, 200)
				end
			end
			reinforcements_allowed=true
		end
		
		choice=GameRandom(1,3)
		if choice==1 then foolist={"ALIEN_FOO_CORE"} end
		if choice==2 then foolist={"ALIEN_FOO_CORE","ALIEN_FOO_CORE"} end
		if choice==3 then foolist={"ALIEN_FOO_CORE","ALIEN_FOO_CORE","ALIEN_FOO_CORE"} end
		
		Sleep(1)
	end
	for i, foos in pairs(fookiters) do
		if TestValid(foos) then
			Hunt(foos, "PrioritiesLikeOneWouldExpectThemToBe", true, true, novus_base_loc, 500)
		end
	end
end

--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script
function Thread_Mission_Start_Bink()
	_CustomScriptMessage("_DanLog.txt", string.format("Playing Mission 3 intro"))
	if not bool_skip_intro then
		Fade_Screen_Out(0)
		Fade_Out_Music()
	   BlockOnCommand(Play_Bink_Movie("Novus_M3_S1",true))
   end
	_CustomScriptMessage("_DanLog.txt", string.format("Done Playing Mission 3 intro"))
   Create_Thread("Establishing_Shot", mirabel)
	Create_Thread("Thread_Move_Vert_To_Start")
end

function Thread_Move_Vert_To_Start()
	if TestValid(vertigo) then
		BlockOnCommand(vertigo.Move_To(vertigo_way_1))
	end
	if TestValid(vertigo) then
		BlockOnCommand(vertigo.Move_To(vertigo_way_2))
	end
end

function Thread_Mission_Start()
	UI_Hide_Research_Button()
	--UI_Hide_Sell_Button()
	failure_text="TEXT_SP_MISSION_MISSION_FAILED"
	
	Create_Thread("Thread_Alien_Unit_Controller")
	Sleep(2)
	mission_started = true
	--display first objective
	Create_Thread("Dialog_NM03_01_01")
	
	Create_Hunt_Groups()
	Create_Thread("Reinforcements_Handler")
	Lock_Objects(true)
end

function Thread_Build_Base_Objectives(obj_num)
	--if obj_num == 0 then
	--	if not TestValid(Find_First_Object("Novus_Remote_Terminal")) then
	--		construction_objective_01_given = true
	--		nov03_build_objective_01 = Add_Objective("TEXT_SP_MISSION_NVS03_OBJECTIVE_B")
	--	else
	--		obj_num = 1
	--	end
	--end
	--if obj_num == 1 then
	--	if construction_objective_01_given then
	--		Objective_Complete(nov03_build_objective_01)
	--		Sleep(5)
	--	end
	--	if not TestValid(Find_First_Object("Novus_Power_Router")) then
	--		construction_objective_02_given = true
	--		nov03_build_objective_02 = Add_Objective("TEXT_SP_MISSION_NVS03_OBJECTIVE_C")
	--	else
	--		obj_num = 2
	--	end
	--end
	--if obj_num == 2 then
	--	if construction_objective_02_given then
	--		Objective_Complete(nov03_build_objective_02)
	--		Sleep(5)
	--	end
	--	constructor_list = Find_All_Objects_Of_Type("Novus_Constructor")
	--	constructor_total = table.getn(constructor_list)
	--	if not construction_objective_03_given and constructor_total <= 2 then
	--		construction_objective_03_given = true
	--		nov03_build_objective_03 = Add_Objective("TEXT_SP_MISSION_NVS03_OBJECTIVE_D")
	--		Out_string = Get_Game_Text("TEXT_SP_MISSION_NVS03_OBJECTIVE_D")
	--		Out_string = Replace_Token(Out_string, Get_Localized_Formatted_Number(constructors_built), 1)
	--		Set_Objective_Text(nov03_build_objective_03, Out_string)
	--	else
	--		obj_num = 3
	--	end
	--end
	if obj_num == 3 then	
		--if construction_objective_03_given then	
		--	Objective_Complete(nov03_build_objective_03)
		--	Sleep(5)
		--end 
		if not TestValid(Find_First_Object("Novus_Input_Station")) and not TestValid(Find_First_Object("Novus_Input_Station_Construction")) then
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS03_OBJECTIVE_E_ADD"} )
			Sleep(time_objective_sleep)
			Create_Thread("Dialog_NM03_01_09")
			construction_objective_04_given = true
			nov03_build_objective_04 = Add_Objective("TEXT_SP_MISSION_NVS03_OBJECTIVE_E")
			Create_Thread("Thread_Foo_Kiters")
		else
			obj_num = 4
		end		
	end
	if obj_num == 4 then
		if construction_objective_04_given then
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS03_OBJECTIVE_E_COMPLETE"} )
			Objective_Complete(nov03_build_objective_04)
			Sleep(time_objective_sleep)
		end
		--if not TestValid(Find_First_Object("Novus_Signal_Tower")) then
			--Create_Thread("Dialog_NM03_12_09")
			--construction_objective_05_given = true
			--nov03_build_objective_05 = Add_Objective("TEXT_SP_MISSION_NVS03_OBJECTIVE_F")
		--else
			obj_num = 6 -- jgs changed to skip science lab objective
		--end
	end
	--if obj_num == 5 then
	--	if construction_objective_05_given then
	--		Objective_Complete(nov03_build_objective_05)
	--		Sleep(5)
	--	end
	--	if not TestValid(Find_First_Object("Novus_Science_Lab")) then
	--		construction_objective_06_given = true
	--		nov03_build_objective_06 = Add_Objective("TEXT_SP_MISSION_NVS03_OBJECTIVE_G")
	--	else
	--		obj_num = 6
	--	end
	--end
	if obj_num == 6 then
		--if construction_objective_06_given then
		--	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS03_OBJECTIVE_A_ADD"} )
		--	Objective_Complete(nov03_build_objective_06)
		--	Sleep(time_objective_sleep)
		--end
		if not TestValid(Find_First_Object("Novus_Aircraft_Assembly")) and not TestValid(Find_First_Object("Novus_Aircraft_Assembly_Construction")) then
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS03_OBJECTIVE_H_ADD"} )
			Sleep(time_objective_sleep)
			Create_Thread("Dialog_NM03_12_13")
			construction_objective_07_given = true
			nov03_build_objective_07 = Add_Objective("TEXT_SP_MISSION_NVS03_OBJECTIVE_H")
			Add_Independent_Hint(HINT_NM03_VIRUS_EXPLOIT)
		else
			obj_num = 7
		end
	end
	if obj_num == 7 then
		if construction_objective_07_given then
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS03_OBJECTIVE_H_COMPLETE"} )
			Objective_Complete(nov03_build_objective_07)
			Sleep(time_objective_sleep)
		end
		Create_Thread("Thread_Piece_Handler")
	end
end

function Thread_Spawn_Piece_1()
	Hunt(foo_list, true, false, piece_loc[piece_offset], 200)
	Create_Thread("Thread_Spawn_Portal_Piece", (piece_loc[piece_offset]))
	
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS03_OBJECTIVE_A_ADD"} )
	Sleep(time_objective_sleep)
	nov03_objective00 = Add_Objective("TEXT_SP_MISSION_NVS03_OBJECTIVE_A")
	Out_string = Get_Game_Text("TEXT_SP_MISSION_NVS03_OBJECTIVE_A")
	Out_string = Replace_Token(Out_string, Get_Localized_Formatted_Number(pieces_collected), 1)
	Set_Objective_Text(nov03_objective00, Out_string)
	
	if TestValid(vertigo) then
		novus.Select_Object(vertigo)
		Add_Attached_GUI_Hint(PG_GUI_HINT_SPECIAL_ABILITY_ICON, "TEXT_ABILITY_NOVUS_UPLOAD", HINT_NM02_VERTIGO_UPLOAD)        -- JOE: To attach to a special ability, pass it's TextID.
	end
end

function Thread_Mission_Complete()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
			
	Sleep(time_objective_sleep)
	mission_success = true --this flag is what I check to make sure no game logic continues when the mission is over
	Flush_PIP_Queue()
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
	-- this music is faction specific, 
	-- use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
	Play_Music("Novus_Win_Tactical_Event")
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,90)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
	Sleep(time_objective_sleep)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(0)
		player_script = aliens.Get_Script()
		
	Force_Victory(novus)
end

function Force_Victory(player)
			
	Lock_Objects(false)
	if player == novus then
		-- ***** ACHIEVEMENT_AWARD *****
		--if (Player_Earned_Offline_Achievements()) then
			--Supply Novus as the player here - the parameter is only used to determine which version of the *_Tactical_Mission_Over
			--function we call, and as with the no achievements case below the Novus campaign is the one we want to move forward.
		--	Create_Thread("Show_Earned_Achievements_Thread", {Get_Game_Mode_GUI_Scene(), novus})
		--else
			
			-- Inform the campaign script of our victory.
			global_script.Call_Function("Novus_Tactical_Mission_Over", true) -- true == player wins/false == player loses
			--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
			Quit_Game_Now(player, false, true, false)
		--end
	else
		Show_Retry_Dialog()
	end	
end

-- ***** ACHIEVEMENT_AWARD *****
function Show_Earned_Achievements_Thread(map)
	local dialog = Show_Earned_Offline_Achievements(map[1])
	while (dialog.Is_Showing()) do
		Sleep(1)
	end
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Cleanup_Hint_System", nil, {})
	Process_Tactical_Mission_Over(map[2])
end

function Thread_Mission_Failed()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
			
   mission_failure = true --this flag is what I check to make sure no game logic continues when the mission is over
   Flush_PIP_Queue()
   Letter_Box_In(1)
   Lock_Controls(1)
   Suspend_AI(1)
   Disable_Automatic_Tactical_Mode_Music()
-- this music is faction specific, 
-- use: UEA_Lose_Tactical_Event Alien_Lose_Tactical_Event Novus_Lose_Tactical_Event Masari_Lose_Tactical_Event
   Play_Music("Lose_To_Alien_Event")     
	Zoom_Camera.Set_Transition_Time(10)
   Zoom_Camera(.3)
   Rotate_Camera_By(180,30)
   -- the variable  failure_text  is set at the start of mission to contain the default string "TEXT_SP_MISSION_MISSION_FAILED"
   -- upon mission failure of an objective, or hero death, replace the string  failure_text  with the appropriate xls tag 
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {failure_text} )
   Sleep(time_objective_sleep)
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
   Fade_Screen_Out(2)
   Sleep(2)
   Lock_Controls(0)
		player_script = aliens.Get_Script()
		
   Force_Victory(aliens)
end

function Thread_Spawn_Portal_Piece(piece_loc)	
		Register_Prox(piece_loc, Prox_Clear_Piece_Area_Novus, 30, novus)
		Register_Prox(piece_loc, Prox_Clear_Piece_Area_Alien, 30, aliens)
		Sleep(1)
		--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"A NEW PORTAL PIECE HAS BEEN DETECTED!"} )
		
		if piece_offset==1 then 
			portal1.Set_Object_Context_ID("StoryCampaign")
			portal1.Teleport(portal1_orig_loc)
			portal1.Play_Animation("Anim_Build", true, 0)
			Sleep(3)
			portal1.Play_Animation("Anim_Idle", true, 0)
			Add_Radar_Blip(piece_loc, "DEFAULT", "blip_portal_piece_1")
		end
		if piece_offset==2 then
			portal2.Set_Object_Context_ID("StoryCampaign")
			portal2.Teleport(portal2_orig_loc)
			portal2.Play_Animation("Anim_Build", true, 0)
			Sleep(3)
			portal2.Play_Animation("Anim_Idle", true, 0)
			Add_Radar_Blip(piece_loc, "DEFAULT", "blip_portal_piece_2")
		end
		if piece_offset==3 then 
			portal3.Set_Object_Context_ID("StoryCampaign")
			portal3.Teleport(portal3_orig_loc)
			portal3.Play_Animation("Anim_Build", true, 0)
			Sleep(3)
			portal3.Play_Animation("Anim_Idle", true, 0)
			Add_Radar_Blip(piece_loc, "DEFAULT", "blip_portal_piece_3")
		end
		if piece_offset==4 then 
			portal4.Set_Object_Context_ID("StoryCampaign")
			portal4.Teleport(portal4_orig_loc)
			portal4.Play_Animation("Anim_Build", true, 0)
			Sleep(3)
			portal4.Play_Animation("Anim_Idle", true, 0)
			Add_Radar_Blip(piece_loc, "DEFAULT", "blip_portal_piece_4")
			Create_Thread("Midtro")
		end
		if piece_offset==5 then 
			portal5.Set_Object_Context_ID("StoryCampaign")
			portal5.Teleport(portal5_orig_loc)
			portal5.Play_Animation("Anim_Build", true, 0)
			Sleep(3)
			portal5.Play_Animation("Anim_Idle", true, 0)
			Add_Radar_Blip(piece_loc, "DEFAULT", "blip_portal_piece_5")
		end
		if piece_offset==6 then 
			portal6.Set_Object_Context_ID("StoryCampaign")
			portal6.Teleport(portal6_orig_loc)
			portal6.Play_Animation("Anim_Build", true, 0)
			Sleep(3)
			portal6.Play_Animation("Anim_Idle", true, 0)
			Add_Radar_Blip(piece_loc, "DEFAULT", "blip_portal_piece_6")
		end
		if piece_offset==7 then 
			portal7.Set_Object_Context_ID("StoryCampaign")
			portal7.Teleport(portal7_orig_loc)
			portal7.Play_Animation("Anim_Build", true, 0)
			Sleep(3)
			portal7.Play_Animation("Anim_Idle", true, 0)
			Add_Radar_Blip(piece_loc, "DEFAULT", "blip_portal_piece_7")
		end
		
		Sleep(1.5)
		portal_piece[piece_offset] = Spawn_Unit(Find_Object_Type("NOVUS_PORTAL_PIECE_01"), piece_loc, novus)
		portal_piece[piece_offset].Make_Invulnerable(true)
		portal_piece[piece_offset].Teleport_And_Face(piece_loc)
		portal_piece[piece_offset].Prevent_All_Fire(true)
		
		portal_piece[piece_offset].Register_Signal_Handler(Callback_Piece_Uploaded, "OBJECT_EFFECT_APPLIED")
		
		portal_piece[piece_offset].Highlight(true, -50)
		Sleep(1)
		if piece_offset==1 then 
			portal1.Play_Animation("Anim_Die", true, 0)
			Sleep(1.5)
			portal1.Hide(true)
		end
		if piece_offset==2 then 
			portal2.Play_Animation("Anim_Die", true, 0)
			Sleep(1.5)
			portal2.Hide(true)
		end
		if piece_offset==3 then 
			portal3.Play_Animation("Anim_Die", true, 0)
			Sleep(1.5)
			portal3.Hide(true)
		end
		if piece_offset==4 then 
			portal4.Play_Animation("Anim_Die", true, 0)
			Sleep(1.5)
			portal4.Hide(true)
		end
		if piece_offset==5 then 
			portal5.Play_Animation("Anim_Die", true, 0)
			Sleep(1.5)
			portal5.Hide(true)
		end
		if piece_offset==6 then 
			portal6.Play_Animation("Anim_Die", true, 0)
			Sleep(1.5)
			portal6.Hide(true)
		end
		if piece_offset==7 then 
			portal7.Play_Animation("Anim_Die", true, 0)
			Sleep(1.5)
			portal7.Hide(true)
		end
		
	piece_loc.Cancel_Event_Object_In_Range(Prox_Clear_Piece_Area_Novus)
	piece_loc.Cancel_Event_Object_In_Range(Prox_Clear_Piece_Area_Alien)
	
	piece_offset = piece_offset + 1
end

function Prox_Clear_Piece_Area_Novus(prox_obj, trigger_obj)
	if TestValid(trigger_obj) then
		if (trigger_obj.Get_Type() ~= Find_Object_Type("NOVUS_PORTAL_PIECE_01")) and (trigger_obj.Get_Type() ~= Find_Object_Type("MOV_NOVUS_PORTAL")) and (trigger_obj.Get_Type() ~= Find_Object_Type("MARKER_GENERIC_PURPLE")) then
			MessageBox("Killing object on portal piece loc")
			trigger_obj.Take_Damage(1000000)
		end
	end
end

function Prox_Clear_Piece_Area_Alien(prox_obj, trigger_obj)
	if TestValid(trigger_obj) then
		if (trigger_obj.Get_Type() ~= Find_Object_Type("NOVUS_PORTAL_PIECE_01")) and (trigger_obj.Get_Type() ~= Find_Object_Type("MOV_NOVUS_PORTAL")) and (trigger_obj.Get_Type() ~= Find_Object_Type("MARKER_GENERIC_PURPLE")) then
			MessageBox("Killing object on portal piece loc")
			trigger_obj.Take_Damage(1000000)
		end
	end
end

function Thread_Piece_Handler()
	if piece_offset == 2 then
		Sleep(10)
		Create_Thread("Thread_Spawn_Portal_Piece", (piece_loc[piece_offset]))
		--Thread_Spawn_Portal_Piece(piece_loc[piece_offset + 1])
		Create_Thread("Dialog_NM03_02_01")
	elseif piece_offset == 3 then
		Sleep(10)
		Create_Thread("Thread_Spawn_Portal_Piece", (piece_loc[piece_offset]))
		--Thread_Spawn_Portal_Piece(piece_loc[piece_offset + 1])
		Create_Thread("Dialog_NM03_03_01")
	elseif piece_offset == 4 then
		Sleep(10)
		Create_Thread("Thread_Spawn_Portal_Piece", (piece_loc[piece_offset]))
		--Thread_Spawn_Portal_Piece(piece_loc[piece_offset + 1])
	elseif piece_offset == 5 then
		Create_Thread("Thread_Walker_Spawn")
		Sleep(10)
		Create_Thread("Thread_Spawn_Portal_Piece", (piece_loc[piece_offset]))
		--Thread_Spawn_Portal_Piece(piece_loc[piece_offset + 1])
		Create_Thread("Dialog_NM03_06_01")
	elseif piece_offset == 6 then		
		Sleep(10)
		Create_Thread("Thread_Spawn_Portal_Piece", (piece_loc[piece_offset]))
		--Thread_Spawn_Portal_Piece(piece_loc[piece_offset + 1])
		Create_Thread("Dialog_NM03_07_01")
	elseif piece_offset == 7 then
		Sleep(10)
		Create_Thread("Thread_Spawn_Portal_Piece", (piece_loc[piece_offset]))
		--Thread_Spawn_Portal_Piece(piece_loc[piece_offset + 1])
		Create_Thread("Dialog_NM03_08_01")
	end
end

function Thread_Walker_Spawn()
	walker_list[1] = walker_1
	walker_list[2] = walker_2
	walker_list[3] = walker_3
	Create_Thread("Thread_Walker_Handler", 1)
	Sleep(15)
	Create_Thread("Thread_Walker_Handler", 2)
	Sleep(15)
	Create_Thread("Thread_Walker_Handler", 3)
	Create_Thread("Thread_Habitat_Walker_Produced_Hunt")
	Register_Prox(walker_list[1], PROX_Found_Walker, 300, novus)
	Register_Prox(walker_list[2], PROX_Found_Walker, 300, novus)
	Register_Prox(walker_list[3], PROX_Found_Walker, 300, novus)
end

function Thread_Walker_Handler(variant)
	walker_list[variant].Teleport_And_Face(walker_spawn_loc[variant])
	walker_list[variant].Register_Signal_Handler(Callback_Walker_Killed, "OBJECT_HEALTH_AT_ZERO")
	walker_list[variant].Move_To(walker_goto[variant])
	Sleep(2)
	Create_Thread("Thread_Habitat_Walker_Produce",{walker_list[variant],3})
end

function Thread_Habitat_Walker_Produce(params)
	local walker_obj,number = params[1],params[2]
	local prod_unit=Find_Object_Type("ALIEN_GRUNT")
	local prod_num=4
	local built={}
	local inqueue={}
	local queued=0
	local build=0
	while TestValid(walker_obj) do
		queued=0
		built=Find_All_Objects_Of_Type(prod_unit)
		inqueue=walker_obj.Tactical_Enabler_Get_Queued_Objects()
		if inqueue then
			for i, unit in pairs(inqueue) do
				if TestValid(unit) then
					if unit.Get_Type()==prod_unit then
						queued=queued+1
					end
				end
			end
		end
		if table.getn(built)>0 then 
			build=table.getn(built)/2
		else
			build=0
		end
		if (queued+build)<prod_num then
			Tactical_Enabler_Begin_Production(walker_obj, prod_unit, 1, aliens)
			Sleep(5)
		else
			Sleep(GameRandom(180,360))
		end
	end
end

function Thread_Habitat_Walker_Produced_Hunt()
	while not walkera_alldead do
		grunts=Find_All_Objects_Of_Type("ALIEN_GRUNT")
		for i, unit in pairs(grunts) do
			if not unit.Has_Attack_Target() then
				if TestValid(mirabel) then 
					Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",false,false,mirabel,300)
				end
			end
			unit.Prevent_AI_Usage(true)
		end
		Sleep(GameRandom(5,6))
	end
end

function Thread_Gatherer_06_Return()
	if TestValid(piece06_gatherer) then
		BlockOnCommand(piece06_gatherer.Move_To(piece_06_goto))
		
		piece06_deposited = true
		
		if not gatherer_06_killed then
			portal_piece[6].Teleport_And_Face(piece_06_goto)
			--Remove_Radar_Blip("blip_gatherer_06")
			--piece06_gatherer.Highlight(false)
			--Add_Radar_Blip(portal_piece[6], "DEFAULT", "blip_portal_piece")
			--portal_piece[6].Highlight(true, -50)
		end	

		--Create_Thread("Thread_Piece_Handler") --??
	end
end

function Thread_Gatherer_07_Return()
	if TestValid(piece07_gatherer) then
		BlockOnCommand(piece07_gatherer.Move_To(piece_07_goto))
		
		piece07_deposited = true
		
		if not gatherer_07_killed then
			portal_piece[7].Teleport_And_Face(piece_07_goto)
			--Remove_Radar_Blip("blip_gatherer_07")
			--piece07_gatherer.Highlight(false)
			--Add_Radar_Blip(portal_piece[7], "DEFAULT", "blip_portal_piece")
			--portal_piece[7].Highlight(true, -50)
		end
	end
end

function Thread_Objective00_Handler()
	Sleep(1)
	pieces_collected = 0
	
	for i, pieces in pairs(pieces_at_base) do
		if pieces then
			pieces_collected = pieces_collected + 1
			Remove_Radar_Blip("blip_piece_dropoff")
			piece_dropoff.Highlight(false)
			--MessageBox("A piece is in range of the base.  Setting Pieces Collected to %d.", pieces_collected)
		end
	end
	
	Out_string = Get_Game_Text("TEXT_SP_MISSION_NVS03_OBJECTIVE_A")
	Out_string = Replace_Token(Out_string, Get_Localized_Formatted_Number(pieces_collected), 1)
	Set_Objective_Text(nov03_objective00, Out_string)
	--Set_Objective_Text(nov03_objective00, "Use Vertigo to bring all 7 portal pieces back to the base. (%d/7)", pieces_collected)
	if pieces_collected == 4 then
		Create_Thread("Dialog_NM03_07_04")
	end
	if piece_offset == 2 and pieces_collected == 1 and not construction_objective_01_given then
		Create_Thread("Thread_Build_Base_Objectives", 3) -- jgs changed to start on base obj 2
	end
	if piece_offset >=3 and piece_offset <= 8 then
		Create_Thread("Thread_Piece_Handler")
	end
end

function Thread_Alien_Unit_Controller()
	current_carvers_list = Find_All_Objects_Of_Type("Alien_Glyph_Carver")
	current_lost_one_list = Find_All_Objects_Of_Type("Alien_Lost_One")
	current_grunt_list = Find_All_Objects_Of_Type("Alien_Grunt")
	current_monolith_list = Find_All_Objects_Of_Type("Alien_Cylinder")
	current_brute_list = Find_All_Objects_Of_Type("Alien_Brute")
	
	counter_carvers = table.getn(current_carvers_list)
	counter_lost_ones = table.getn(current_lost_one_list)
	counter_grunts = table.getn(current_grunt_list)
	counter_monoliths = table.getn(current_monolith_list)
	counter_brutes = table.getn(current_brute_list)
	
	if counter_carvers < nm03_glyph_carvers then
		local carvers_needed = (nm03_glyph_carvers - counter_carvers)
		Story_AI_Request_Build_Units(aliens, Find_Object_Type("Alien_Glyph_Carver"), carvers_needed)
	end
	if counter_lost_ones < nm03_lost_ones then
		local lost_ones_needed = (nm03_lost_ones - counter_lost_ones)
		Story_AI_Request_Build_Units(aliens, Find_Object_Type("Alien_Lost_One"), lost_ones_needed)
	end
	if counter_grunts < nm03_grunts then
		local grunts_needed = (nm03_grunts - counter_grunts)
		--Story_AI_Request_Build_Units(aliens, Find_Object_Type("Alien_Grunt"), grunts_needed) -- grunts now build from walkers
	end
	if counter_monoliths < nm03_monoliths then
		local monoliths_needed = (nm03_monoliths - counter_monoliths)
		Story_AI_Request_Build_Units(aliens, Find_Object_Type("Alien_Cylinder"), monoliths_needed)
	end
	if counter_brutes < nm03_brutes then
		local brutes_needed = (nm03_brutes - counter_brutes)
		Story_AI_Request_Build_Units(aliens, Find_Object_Type("Alien_Brute"), brutes_needed)
	end
end

--for callbacks once units or structures get created
function Story_On_Construction_Complete(obj)
   if obj.Get_Type() == Find_Object_Type("Alien_Glyph_Carver") or
		obj.Get_Type() == Find_Object_Type("Alien_Lost_One") or
		obj.Get_Type() == Find_Object_Type("Alien_Grunt") or
		obj.Get_Type() == Find_Object_Type("Alien_Cylinder") or
		obj.Get_Type() == Find_Object_Type("Alien_Brute") then
			obj.Register_Signal_Handler(Callback_Unit_Build_Monitor, "OBJECT_DELETE_PENDING")
   end
   if obj.Get_Type() == Find_Object_Type("Alien_Scan_Drone") or obj.Get_Type() == Find_Object_Type("Alien_Walker_Habitat") then
		obj.Prevent_AI_Usage(true)
   end
   --Trigger when Command Core is Built
   --if obj.Get_Type() == Find_Object_Type("Novus_Remote_Terminal") then
	--if construction_objective_01_given and not construction_objective_01_complete then
	--		construction_objective_01_complete = true
	--		Create_Thread("Thread_Build_Base_Objectives", 1)
	--	end
   --end
   --Trigger when Power Nexus is Built
   --if obj.Get_Type() == Find_Object_Type("Novus_Power_Router") then
	--	if construction_objective_02_given and not construction_objective_02_complete then
	--		construction_objective_02_complete = true
	--		Create_Thread("Thread_Build_Base_Objectives", 2)
	--	end
   --end
   --Trigger when 2 Constructors are Built
   --if obj.Get_Type() == Find_Object_Type("Novus_Constructor") then
	--	if construction_objective_03_given and not construction_objective_03_complete then
	--		constructors_built = constructors_built + 1
	--		Out_string = Get_Game_Text("TEXT_SP_MISSION_NVS03_OBJECTIVE_D")
	--		Out_string = Replace_Token(Out_string, Get_Localized_Formatted_Number(constructors_built), 1)
	--		Set_Objective_Text(nov03_build_objective_03, Out_string)
	--		if constructors_built >= 2 then
	--			construction_objective_03_complete = true
	--			Create_Thread("Thread_Build_Base_Objectives", 3)
	--		end
	--	end
   --end
   --Trigger when Input Station is Built
   if obj.Get_Type() == Find_Object_Type("Novus_Input_Station") or TestValid(Find_First_Object("Novus_Input_Station")) then
		if construction_objective_04_given and not construction_objective_04_complete then
			construction_objective_04_complete = true
			Create_Thread("Thread_Build_Base_Objectives", 4)
		end
   end
   --Trigger when Signal Tower is Built
   --if obj.Get_Type() == Find_Object_Type("Novus_Signal_Tower") then
	--	if construction_objective_05_given and not construction_objective_05_complete then
	--		construction_objective_05_complete = true
	--		Create_Thread("Thread_Build_Base_Objectives", 5)
	--	end
   --end
   --Trigger when Science Lab is Built
   --if obj.Get_Type() == Find_Object_Type("Novus_Science_Lab") then
	--	if construction_objective_06_given and not construction_objective_06_complete then
	--		construction_objective_06_complete = true
	--		Create_Thread("Thread_Build_Base_Objectives", 6)
	--	end
   --end
   --Trigger when Vehicle Assembly is Built
   if obj.Get_Type() == Find_Object_Type("Novus_Aircraft_Assembly")  or TestValid(Find_First_Object("Novus_Aircraft_Assembly")) then
		if construction_objective_07_given and not construction_objective_07_complete then
			construction_objective_07_complete = true
			Create_Thread("Thread_Build_Base_Objectives", 7)
		end
   end
end

function Callback_Unit_Build_Monitor(callback_obj)
	unit_death_counter = unit_death_counter + 1
	if unit_death_counter >= unit_deaths_before_using_controller then
		Create_Thread("Thread_Alien_Unit_Controller")
	end
end


--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script

function Lock_Objects(boolean)
		
		novus.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Vertigo", "Novus_Vertigo_Retreat_From_Tactical_Ability", boolean, STORY)
		
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_MEGAWEAPON"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_SUPERWEAPON_EMP"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_SUPERWEAPON_GRAVITY_BOMB"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NM04_Novus_Portal"),boolean,STORY)
		
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_HERO_FOUNDER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_HERO_VERTIGO"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_HERO_MECH"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_DERVISH_JET"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_FIELD_INVERTER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_VARIANT"),boolean,STORY)
		
		novus.Lock_Object_Type(Find_Object_Type("Novus_Vehicle_Assembly"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("Novus_Science_Lab"),boolean,STORY)
		
		novus.Lock_Object_Type(Find_Object_Type("Novus_Vehicle_Assembly_Inversion"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("Novus_Aircraft_Assembly_Scramjet"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("Novus_Science_Lab_Upgrade_Singularity_Processor"),boolean,STORY)
		
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Unit_Ability", false, STORY)
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Control_Turret_Area_Special_Ability", false, STORY)
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Special_Ability", false, STORY)
		
		novus.Lock_Unit_Ability("Novus_Robotic_Infantry", "Robotic_Infantry_Capture", true, STORY)
		novus.Lock_Generator("RoboticInfantryCaptureGenerator", true, STORY)
		
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Kamal_Rex"),boolean,STORY)
		--aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Nufai"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Orlok"),boolean,STORY)
		
		--aliens.Lock_Generator("CylinderOnDeathExplosionGenerator", true)
		aliens.Lock_Generator("DefilerOnDeathExplosionGenerator", true)
		--aliens.Lock_Generator("CylinderOnDeathExplosionGenerator", true)
		aliens.Lock_Generator("ReaperOnDeathExplosionGenerator", true)
		aliens.Lock_Generator("ScanDroneOnDeathExplosionGenerator", true)
		aliens.Lock_Generator("AssemblyOnDeathExplosionGenerator", true)
		aliens.Lock_Generator("HabitatOnDeathExplosionGenerator", true)
		aliens.Lock_Generator("ScienceWalkerOnDeathExplosionGenerator", true)
		--aliens.Lock_Generator("FooCoreOnDeathExplosionGenerator", true)
		
		novus.Lock_Generator("VirusInfectAuraGenerator", false)
		novus.Lock_Generator("NovusResearchAdvancedFlowEffectGenerator", false )
end

function Create_Hunt_Groups()
	hunt_unit_in_group = {}
	hunt_group_inclusion_radius = 150
	hunt_group_total = 0
	hunt_allunit_list = Find_All_Objects_With_Hint("hunt")
	for i, unit in pairs (hunt_allunit_list) do
		if TestValid(unit) then
			hunt_unit_in_group[unit] = false
		end
	end
	for i, unit in pairs (hunt_allunit_list) do
		if not hunt_unit_in_group[unit] then
			if TestValid(unit) then
				hunt_group_list = Find_All_Objects_Of_Type(unit.Get_Position(), hunt_group_inclusion_radius, "CanAttack")
				for j, hunter in pairs (hunt_group_list) do
					if hunter.Is_Category("HardPoint") or hunter.Is_Category("Stationary") then
						table.remove(hunt_group_list, j)
					else
						hunt_unit_in_group[hunter] = true
					end
				end
				Hunt(hunt_group_list, true, false, hunt_group_list[1], 400)
				hunt_group_total = hunt_group_total + 1
				_CustomScriptMessage("_DanLog.txt", string.format("Creating Hunt group #%d!", hunt_group_total))
			end
		end
	end
end

function Cache_Models()
	Find_Object_Type("ALIEN_WALKER_HABITAT").Load_Assets()
end

-- below are PROX functions needed for this script

function PROX_Vertigo_Piece(prox_obj, trigger_obj)
   if trigger_obj == portal_piece[1] and not piece_1_prox_played then
      piece_1_prox_played = true
      Create_Thread("Dialog_NM03_01_04")
   end
   if trigger_obj == portal_piece[3] and not piece_3_prox_played then
      piece_3_prox_played = true
      Create_Thread("Dialog_NM03_03_04")
   end
   if trigger_obj == portal_piece[5] and not piece_5_prox_played then
      piece_5_prox_played = true
      --Create_Thread("Dialog_NM03_06_03")
   end   
end

function PROX_Found_Walker(prox_obj, trigger_obj)
	if trigger_obj == vertigo then
		if not prox_walker_played then
			Create_Thread("Dialog_NM03_06_03")
			prox_walker_played=true
		end
		prox_obj.Cancel_Event_Object_In_Range(PROX_Found_Walker)
	end
end


function PROX_Portal_Piece(prox_obj, trigger_obj)
	if trigger_obj == portal_piece[1] then
		pieces_at_base[1] = true
		portal_piece[1].Highlight(false)
		portal_piece[1].Make_Invulnerable(false)
	end
	if trigger_obj == portal_piece[2] then
		pieces_at_base[2] = true
		portal_piece[2].Highlight(false)
		portal_piece[2].Make_Invulnerable(false)
	end	
	if trigger_obj == portal_piece[3] then
		pieces_at_base[3] = true
		portal_piece[3].Highlight(false)
		portal_piece[3].Make_Invulnerable(false)
	end
	if trigger_obj == portal_piece[4] then
		pieces_at_base[4] = true
		portal_piece[4].Highlight(false)
		portal_piece[4].Make_Invulnerable(false)
	end
	if trigger_obj == portal_piece[5] then
		pieces_at_base[5] = true
		portal_piece[5].Highlight(false)
		portal_piece[5].Make_Invulnerable(false)
	end
	if trigger_obj == portal_piece[6] then
		pieces_at_base[6] = true
		portal_piece[6].Highlight(false)
		portal_piece[6].Make_Invulnerable(false)
	end
	if trigger_obj == portal_piece[7] then
		pieces_at_base[7] = true
		portal_piece[7].Highlight(false)
		portal_piece[7].Make_Invulnerable(false)
	end
end

function PROX_Piece_06(prox_obj, trigger_obj)
	if trigger_obj == piece06_gatherer then
		prox_obj.Cancel_Event_Object_In_Range(PROX_Piece_06)
		--Remove_Radar_Blip("blip_portal_piece")
		--prox_obj.Highlight(false)
		--Add_Radar_Blip(trigger_obj, "DEFAULT", "blip_gatherer_06")
		--trigger_obj.Highlight(true, -50)
		portal_piece[6].Teleport_And_Face(piece_06_temp_loc)
		trigger_obj.Register_Signal_Handler(Callback_Gatherer_06_Killed, "OBJECT_HEALTH_AT_ZERO")
		Create_Thread("Thread_Gatherer_06_Return")
	end
end

function PROX_Piece_07(prox_obj, trigger_obj)
	if trigger_obj == piece07_gatherer then
		prox_obj.Cancel_Event_Object_In_Range(PROX_Piece_07)
		--Remove_Radar_Blip("blip_portal_piece")
		--prox_obj.Highlight(false)
		--Add_Radar_Blip(trigger_obj, "DEFAULT", "blip_gatherer_07")
		--trigger_obj.Highlight(true, -50)
		portal_piece[7].Teleport_And_Face(piece_07_temp_loc)
		trigger_obj.Register_Signal_Handler(Callback_Gatherer_07_Killed, "OBJECT_HEALTH_AT_ZERO")
		Create_Thread("Thread_Gatherer_07_Return")
	end
end

-- Callbacks go here:
function Callback_Mirabel_Killed()
	if not mission_success then
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"} )
   	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"
		Create_Thread("Thread_Mission_Failed")
	end
end

function Callback_Vertigo_Killed()
	if not mission_success then
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_VERTIGO"} )
   	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_VERTIGO"
		Create_Thread("Thread_Mission_Failed")
	end
end

function Patrol_Ohm(patrolling_obj)
	if TestValid(patrolling_obj) and not patrol_interrupted[patrolling_obj] then
		patrol_offset1 = patrol_offset1 + 1
		if patrol_offset1 > 6 then
			patrol_offset1 = 1
		end
		if TestValid(patrol_1[patrol_offset1]) then
			BlockOnCommand(patrolling_obj.Move_To(patrol_1[patrol_offset1].Get_Position()))
			if (TestValid(patrolling_obj) and TestValid(patrol_1[patrol_offset1])) then
				local distance = patrolling_obj.Get_Distance(patrol_1[patrol_offset1])
				if distance < 10 then
					Create_Thread("Patrol_Ohm", patrolling_obj)
				end
			end
		end
	end
end

function Patrol2_Ohm(patrolling_obj)
	if TestValid(patrolling_obj) and not patrol_interrupted[patrolling_obj] then
		patrol_offset2 = patrol_offset2 + 1
		if patrol_offset2 > 6 then
			patrol_offset2 = 1
		end
		if TestValid(patrol_2[patrol_offset2]) then
			BlockOnCommand(patrolling_obj.Move_To(patrol_2[patrol_offset2].Get_Position()))
			if (TestValid(patrolling_obj) and TestValid(patrol_2[patrol_offset2])) then
				local distance = patrolling_obj.Get_Distance(patrol_2[patrol_offset2])
				if distance < 10 then
					Create_Thread("Patrol2_Ohm", patrolling_obj)
				end
			end
		end
	end
end

function Reverse_Patrol_Ohm(patrolling_obj)
	if TestValid(patrolling_obj) and not patrol_interrupted[patrolling_obj] then
		patrol_offset3 = patrol_offset3 - 1
		if patrol_offset3 < 1 then
			patrol_offset3 = 6
		end
		if TestValid(patrol_1[patrol_offset3]) then
			BlockOnCommand(patrolling_obj.Move_To(patrol_1[patrol_offset3].Get_Position()))
			if (TestValid(patrolling_obj) and TestValid(patrol_1[patrol_offset3])) then
				local distance = patrolling_obj.Get_Distance(patrol_1[patrol_offset3])
				if distance < 10 then
					Create_Thread("Reverse_Patrol_Ohm", patrolling_obj)
				end
			end
		end
	end
end

function Callback_Piece_Uploaded(callback_obj, effect, is_target, source_obj)
	--MessageBox("Callback Object: %s \nEffect: %s \nIs Target: %s \nSource Object: %s", tostring(callback_obj), tostring(effect), tostring(is_target), tostring(source_obj))
	if effect == "Upload_Effect" then
		--MessageBox("Object Uploaded!!!")
		for i, unit in pairs (portal_piece) do
			if callback_obj == unit then
				Add_Radar_Blip(piece_dropoff, "DEFAULT", "blip_piece_dropoff")
				piece_dropoff.Highlight(true, -35)
			end
		end
		if callback_obj == portal_piece[1] and not download_hint_given then 
			download_hint_given = true
		   Create_Thread("Dialog_NM03_01_07")			
			Add_Attached_GUI_Hint(PG_GUI_HINT_SPECIAL_ABILITY_ICON, "TEXT_ABILITY_NOVUS_DOWNLOAD", HINT_NM02_VERTIGO_DOWNLOAD)        -- JOE: To attach to a special ability, pass it's TextID.
		end
		if callback_obj == portal_piece[1] then
			Remove_Radar_Blip("blip_portal_piece_1")
		end
		if callback_obj == portal_piece[2] then
			Remove_Radar_Blip("blip_portal_piece_2")
		end
		if callback_obj == portal_piece[3] then
			Remove_Radar_Blip("blip_portal_piece_3")
		end
		if callback_obj == portal_piece[4] then
			Remove_Radar_Blip("blip_portal_piece_4")
		end
		if callback_obj == portal_piece[5] then
			Remove_Radar_Blip("blip_portal_piece_5")
		end
		if callback_obj == portal_piece[6] then
			Remove_Radar_Blip("blip_portal_piece_6")
		end
		if callback_obj == portal_piece[7] then
			Remove_Radar_Blip("blip_portal_piece_7")
		end
	end
end

function Callback_Object_Downloaded(callback_obj, effect, is_target, source_obj)
	--MessageBox("Callback Object: %s \nEffect: %s \nIs Target: %s \nSource Object: %s", tostring(callback_obj), tostring(effect), tostring(is_target), tostring(source_obj))
	if effect == "Download_Effect" then
		--MessageBox("Object Downloaded!!!")
		if callback_obj == portal_piece[1] then
		   --Create_Thread("Dialog_NM03_01_05")
		end
		
		Create_Thread("Thread_Objective00_Handler")
	end
end

function Callback_Walker_Killed()
	walkers_killed = walkers_killed + 1
	if walkers_killed == 1 then
		--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"Good work!  One walker down!"} )
	elseif walkers_killed == 2 then
		--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"That's two!  If we can kill that last one, we should put a serious dent in the ZRH operations."} )
	elseif walkers_killed == 3 then
		--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"We killed all the passing walkers!  Excellent work!"} )
		--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS03_OBJECTIVE_I_COMPLETE"} )
		--nov03_objective100 = Add_Objective("TEXT_SP_MISSION_NVS03_OBJECTIVE_I")
		--Objective_Complete(nov03_objective100)
	end	
end

function Callback_Gatherer_06_Killed(callback_obj)
	gatherer_06_killed = true
	if not piece06_deposited then
		portal_piece[6].Teleport(callback_obj.Get_Position())
		--Add_Radar_Blip(portal_piece[6], "DEFAULT", "blip_portal_piece")
		--portal_piece[6].Highlight(true, -50)
	end
end

function Callback_Gatherer_07_Killed(callback_obj)
	gatherer_07_killed = true
	if not piece07_deposited then
		portal_piece[7].Teleport(callback_obj.Get_Position())
		--Add_Radar_Blip(portal_piece[7], "DEFAULT", "blip_portal_piece")
		--portal_piece[7].Highlight(true, -50)
	end
end

function Callback_Transport_Destroyed()
	Create_Thread("Thread_Mission_Failed")
end

function Reinforcements_Handler()
	Sleep(10)
	more_reinforcements=false
	dervish_list = { "NOVUS_DERVISH_JET", "NOVUS_DERVISH_JET" }
	while true do
		while not more_reinforcements do
			if reinforcements_allowed then
				dervishes=Find_All_Objects_Of_Type("NOVUS_DERVISH_JET")
				if table.getn(dervishes)<=1 then
					Raise_Game_Event("Reinforcements_Arrived", novus, dervish_spawn_location.Get_Position())
					more_reinforcements=true 
					dervishes = SpawnList(dervish_list, dervish_spawn_location, novus, false, true, false)
					for i, unit in pairs (dervishes) do
						if TestValid(unit) then
							unit.Move_To(dervish_goto_location)
						end
					end
				end
			end
			Sleep(3)
		end
		while more_reinforcements do
			dervishes=Find_All_Objects_Of_Type("NOVUS_DERVISH_JET")
			if table.getn(dervishes)<=1 then
				Sleep(45)
				more_reinforcements=false
			end
			Sleep(3)
		end
	end
end


--***************************************TEMP CINEMATICS****************************************************************************************************
-- below are temporary cinematics to be replaced later
function Establishing_Shot(hero)
	Point_Camera_At(hero)
	Lock_Controls(1)
	--Fade_Screen_Out(0)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	Sleep(1)
	
	Transition_Cinematic_Target_Key(hero, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(hero, 0, 200, 55, 65, 1, 0, 0, 0)
	
	Fade_Screen_In(1)
	
	
	Transition_To_Tactical_Camera(5)
	
	Sleep(5)	
	
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()
		
	Create_Thread("Thread_Mission_Start")
	
end


function Midtro()
	Lock_Controls(1)
	Start_Cinematic_Camera()
	Fade_Screen_Out(1)
	--portal4.Hide(false)
	--portal4.Play_Animation("Anim_Build", true, 0)
	Sleep(1)
	cin_piece=Find_Hint("MARKER_GENERIC_PURPLE","cine4spawn")
	fow_portal_04 = FogOfWar.Reveal(novus, cin_piece, 400, 400)
	cin_gatherer = Spawn_Unit(Find_Object_Type("ALIEN_SUPERWEAPON_REAPER_TURRET"), gatherer_loc_00, aliens)
	cin_gatherer.Prevent_AI_Usage(true)
	cin_gatherer.Suspend_Locomotor(true)
	if TestValid(cin_resource) then
		cin_gatherer.Attack_Target(cin_resource)
	end
		
	Transition_Cinematic_Target_Key(cin_piece, 0, 0, 0, 15, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(cin_piece, 0, 500, 40, -130, 1, 0, 0, 0)
	Letter_Box_In(0)
	Fade_Screen_In(1)
	
	Sleep(2)
	--portal4.Play_Animation("Anim_Idle", true, 0)
		
	cin_portal_piece = Spawn_Unit(Find_Object_Type("Novus_Portal_Piece_03_Resource"), cin_piece, novus)
	cin_portal_piece.Teleport_And_Face(cin_piece)
	
	cin_gatherer.Attack_Target(cin_portal_piece)
	
	--portal_piece[piece_offset] = Spawn_Unit(Find_Object_Type(piece_type[piece_offset]), alien_base_loc, novus)
	--portal_piece[piece_offset].Teleport_And_Face(alien_base_loc)
	--portal_piece[piece_offset].Prevent_All_Fire(true)
	
	--portal4.Play_Animation("Anim_Die", true, 0)
	Sleep(1.5)
	--portal4.Hide(true)
	
	--cin_gatherer.Move_To(piece_loc[4])
	
	Sleep(3)
	
	if TestValid(cin_portal_piece) then
		cin_portal_piece.Despawn()		
	end
		
	cin_gatherer.Suspend_Locomotor(false)
	cin_gatherer.Move_To(alien_base_loc)
	Sleep(2)
	
	Fade_Screen_Out(1)
	Sleep(1)	
	Letter_Box_Out(0)
	fow_portal_04.Undo_Reveal()
	End_Cinematic_Camera()
	Lock_Controls(0)
	Fade_Screen_In(1)
		
	Create_Thread("Dialog_NM03_04_01")
	
	cin_gatherer.Teleport_And_Face(alien_base_loc)
	--Add_Radar_Blip(portal_piece[piece_offset], "DEFAULT", "blip_portal_piece_4")
	--portal_piece[piece_offset].Highlight(true, -50)
	
	Create_Thread("Thread_Piece_Handler")

end



--************************************************************************************************************
--***************************************All Talking Head Dialog stuff****************************************
--************************************************************************************************************

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 01+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Novus Comm (NCO)	The first portal section has arrived.  We are highlighting its location on your tactical map.
function Dialog_NM03_01_01()
	Queue_Talking_Head(dialog_nov_comm, "NVS03_SCENE01_01")
	Create_Thread("Dialog_NM03_01_02")
end

--Mirabel (MIR)	Vertigo, I need you to collect these portal pieces as they arrive.  Go upload that piece and bring it back to the portal transport in our base.
function Dialog_NM03_01_02()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE01_02")
	Create_Thread("Dialog_NM03_01_03")
end

--Vertigo (VER)	On my way.
function Dialog_NM03_01_03()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE01_03")
	Create_Thread("Thread_Spawn_Piece_1")
end

--Vertigo (VER)	I've arrived at the portal section.
function Dialog_NM03_01_04()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE01_04")
	Create_Thread("Dialog_NM03_01_05")
end

--Mirabel (MIR)	Good. Now use your upload ability to bring it back here.
function Dialog_NM03_01_05()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE01_05")
end

--Mirabel (MIR)	We need to get to that portal section before the Hierarchy does.  Move out!
--********OBJECTIVE PROMPT*************
function Dialog_NM03_01_06()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE01_06")
end

--Mirabel (MIR)   To keep the pieces safe, I want you to download them to the portal transport in our base.  I'm highlighting it on the radar for you now.
function Dialog_NM03_01_07()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE01_07")
end

--Vertigo (VER)   Affirmative.
function Dialog_NM03_01_08()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE01_08")
end

--Mirabel (MIR)   While we're waiting for the next portal piece to arrive, we should construct a Recycling Center.
function Dialog_NM03_01_09()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE01_09")
end


--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 02+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Novus Comm (NCO)	Sir, the second portal section is arriving near your current location.  It is being highlighted for you.
function Dialog_NM03_02_01()
	Queue_Talking_Head(dialog_nov_comm, "NVS03_SCENE02_01")
	Create_Thread("Dialog_NM03_02_02")
end

--Mirabel (MIR)	Vertigo, you heard the man.
function Dialog_NM03_02_02()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE02_02")
	Create_Thread("Dialog_NM03_02_03")
end

--Vertigo (VER)	Confirmed.  Moving to destination.
function Dialog_NM03_02_03()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE02_03")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 03+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Novus Comm (NCO)	The third secton has been detected.  Highlighting location.
function Dialog_NM03_03_01()
	Queue_Talking_Head(dialog_nov_comm, "NVS03_SCENE03_01")
	Create_Thread("Dialog_NM03_03_02")
end

--Mirabel (MIR)	Well, this certainly is easier than expected.  Vertigo, you know what to do.
function Dialog_NM03_03_02()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE03_02")
	Create_Thread("Dialog_NM03_03_03")
end

--Vertigo (VER)	We've collected less than half of the sections.  This mission is far from over.
function Dialog_NM03_03_03()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE03_03")
end

--Vertigo (VER)	Minor Hierarchy resistance encountered.  Requesting additional support.
function Dialog_NM03_03_04()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE03_04")
end

--Vertigo (VER)	I'm pinned down here!  I need help now!
--********OBJECTIVE PROMPT*************
function Dialog_NM03_03_05()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE03_05")
end

--Mirabel (MIR)	We'll need to clear them out before we can get at that section.  I'm on my way.
function Dialog_NM03_03_06()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE03_06")
end

--Mirabel (MIR)	This area looks like a good place to set up shop.  Vertigo, bring any pieces you collect back here so we can protect them.
function Dialog_NM03_03_07()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE03_07")
	Create_Thread("Dialog_NM03_03_08")
end

--Vertigo (VER)	Affirmative.
function Dialog_NM03_03_08()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE03_08")
	Create_Thread("Dialog_NM03_03_09")
end

--Mirabel (MIR)	We'll need to set up some defenses.  I have a feeling things may get rougher from here on out.
function Dialog_NM03_03_09()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE03_09")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 04+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Novus Comm (NCO)	Global alert! Hierarchy forces have captured a portal section!
function Dialog_NM03_04_01()
	Queue_Talking_Head(dialog_nov_comm, "NVS03_SCENE04_01")
	Create_Thread("Dialog_NM03_04_02")
end

--Mirabel (MIR)	Looks like the Hierarchy got to it before we could.  They must have another base nearby.
function Dialog_NM03_04_02()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE04_02")
	Create_Thread("Dialog_NM03_04_03")
end

--Novus Science (NSC)	Be advised our return home is now statistically impossible!
function Dialog_NM03_04_03()
	Queue_Talking_Head(dialog_nov_science, "NVS03_SCENE04_03")
	Create_Thread("Dialog_NM03_04_04")
end

--Mirabel (MIR)	Then I guess we'll just have to go in there and get it back, won't we?
function Dialog_NM03_04_04()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE04_04")
	Create_Thread("Dialog_NM03_04_05")
end

--Viktor (VIK)	(Unintelligible)
function Dialog_NM03_04_05()
	Queue_Talking_Head(dialog_viktor, "NVS03_SCENE04_05")
	Create_Thread("Dialog_NM03_04_06")
end

--Mirabel (MIR)	No Viktor, I'll tell you when it's a suicide mission.
function Dialog_NM03_04_06()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE04_06")
	Sleep(5)
	Create_Thread("Dialog_NM03_05_06")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 05+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Mirabel (MIR)	We need to know what we're up against.  Get some dervish jets airborn and find that Hierarchy base.
function Dialog_NM03_05_01()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE05_01")
end

--Mirabel (MIR)	We need to get those dirvishes out.  The Hierarchy could attack at any time.
--********OBJECTIVE PROMPT*************
function Dialog_NM03_05_02()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE05_02")
end

--Mirabel (MIR)	Good.  Now use the dirvishes to scout for that Hierarchy base.
function Dialog_NM03_05_03()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE05_03")
end

--Dervish Pilot (DER)	Sir, we've discovered the local hierarchy base.  We can't get too close, those gravitic turrets will rip apart any aircraft that get close.
function Dialog_NM03_05_04()
	Queue_Talking_Head(dialog_dervish, "NVS03_SCENE05_04")
	Create_Thread("Dialog_NM03_05_05")
end

--Mirabel (MIR)	Understood.  Return to base.
function Dialog_NM03_05_05()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE05_05")
end

--Mirabel (MIR)	We don't want to make the same mistake the sentients did.  The Hierarchy has deployed gravitic turrets so we can't get our air units near them or they’ll be ripped apart.
function Dialog_NM03_05_06()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE05_06")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 06+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Novus Comm (NCO)	Portal section five has arrived at the location highlighted.  There appears to be interference surrounding its signal.
function Dialog_NM03_06_01()
	Queue_Talking_Head(dialog_nov_comm, "NVS03_SCENE06_01")
	Create_Thread("Dialog_NM03_06_02")
end

--Mirabel (MIR)	Be careful, Vertigo.  There could be a surprise waiting for you.
function Dialog_NM03_06_02()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE06_02")
end

--Vertigo (VER)	I have a visual on several Troop Walkers moving across the area.
function Dialog_NM03_06_03()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE06_03")
	Create_Thread("Dialog_NM03_06_04")
end

--Mirabel (MIR)	Engage at your own discretion. The portal pieces remain our priority.
function Dialog_NM03_06_04()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE06_04")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 07+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Novus Comm (NCO)	Another portal signature has been detected.  It is very close to the Hierarchy base.
function Dialog_NM03_07_01()
	Queue_Talking_Head(dialog_nov_comm, "NVS03_SCENE07_01")
	Create_Thread("Dialog_NM03_07_02")
end

--Mirabel (MIR)	If we move quick, we might prevent another portal section from being taken by the Hierarchy.
function Dialog_NM03_07_02()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE07_02")
end

--Vertigo (VER)	Looks like we didn't react quick enough.  Chalk one more up for the Hierarchy.
function Dialog_NM03_07_03()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE07_03")
end

--Mirabel (MIR)	Good work, Vertigo.  Only two portal pieces remain.
function Dialog_NM03_07_04()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE07_04")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 08+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Novus Comm (NCO)	Sir, the last section is inbound.  Tracking its location now…
function Dialog_NM03_08_01()
	Queue_Talking_Head(dialog_nov_comm, "NVS03_SCENE08_01")
	Create_Thread("Dialog_NM03_08_02")
end

--Novus Comm (NCO)	Location confirmed.  Highlighting it for you now.
function Dialog_NM03_08_02()
	Queue_Talking_Head(dialog_nov_comm, "NVS03_SCENE08_02")
	Create_Thread("Dialog_NM03_08_03")
end

--Mirabel (MIR)	Move out, Vertigo.  The Hierarchy definitely know we're here and I'm sure they're already on their way to the last piece.
function Dialog_NM03_08_03()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE08_03")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 09+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Vertigo (VER)	That's all of the easy pieces.  Looks like we'll have to get into the Hierarchy base to get the rest.
function Dialog_NM03_09_01()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE09_01")
end

--Mirabel (MIR)	It's ok, Vertigo.  Come back to base.  We're preparing for our invasion of the Hierarchy base.
function Dialog_NM03_09_02()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE09_02")
end

--Mirabel (MIR)	Remember - the gravitic turrets are lethal to our air units. This is going to require a ground assault.
function Dialog_NM03_09_03()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE09_03")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 10+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Mirabel (MIR)	It looks like their first line of defenses are Gravitic turrets.  We'll need to take these out with land based units.
function Dialog_NM03_10_01()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE10_01")
end

--Mirabel (MIR)	We've collected all the Portal pieces.  Good work!
function Dialog_NM03_10_02()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE10_02")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 11+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Mirabel (MIR)	Remember, the pieces can appear anywhere, so spread out.  What's the situation, Vertigo?
function Dialog_NM03_11_01()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE11_01")
	Create_Thread("Dialog_NM03_11_02")
end

--Vertigo (VER)	The sentient presence attempted an aerial assault on the Hierarchy base only a moment ago.
function Dialog_NM03_11_02()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE11_02")
	Create_Thread("Dialog_NM03_11_03")
end

--Mirabel (MIR)	What do you mean 'attempted'?
function Dialog_NM03_11_03()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE11_03")
	Create_Thread("Dialog_NM03_11_04")
end

--Vertigo (VER)	Casualties are projected at 85%.
function Dialog_NM03_11_04()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE11_04")
	Create_Thread("Dialog_NM03_11_05")
end

--Mirabel (MIR)	They die bravely, don't they?
function Dialog_NM03_11_05()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE11_05")
	Create_Thread("Dialog_NM03_11_06")
end

--Viktor (VIK)	(Unintelligible)
function Dialog_NM03_11_06()
	Queue_Talking_Head(dialog_viktor, "NVS03_SCENE11_06")
	Create_Thread("Dialog_NM03_11_07")
end

--Vertigo (VER)	And needlessly.
function Dialog_NM03_11_07()
	Queue_Talking_Head(dialog_vertigo, "NVS03_SCENE11_07")
	Create_Thread("Dialog_NM03_11_08")
end

--Mirabel (MIR)	Yeah.
function Dialog_NM03_11_08()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE11_08")
end

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 12+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

--Mirabel (MIR)	Building a base and defenses will greatly increase the chances for success of this mission.
function Dialog_NM03_12_01()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_01")
	Create_Thread("Dialog_NM03_12_02")
end

--Mirabel (MIR)	Before we can build any sub structures, we need to build the Command Core.  The Command Core houses all of our raw materials that will be used to construct structures and units.  The Command Core can also build additional constructors to help with production.
function Dialog_NM03_12_02()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_02")
	Create_Thread("Dialog_NM03_12_03")
end

--Mirabel (MIR)	Build a Command Core with your constructor.
function Dialog_NM03_12_03()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_03")
end

--Mirabel (MIR)	Constructors work collaberatively to finish structures.  The more constructors you have working on a structure, the faster it will build.
function Dialog_NM03_12_04()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_04")
	Create_Thread("Dialog_NM03_12_05")
end

--Mirabel (MIR)	Build two more constructors from your Command Core.
function Dialog_NM03_12_05()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_05")
end

--Mirabel (MIR)	Good.  Construction times should improve greatly now.
function Dialog_NM03_12_06()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_06")
	Create_Thread("Dialog_NM03_12_07")
end

--Mirabel (MIR)	The heart of any Novus base is the Power Core.  Structures built near it will be completely powered as long as it remains standing.
function Dialog_NM03_12_07()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_07")
	Create_Thread("Dialog_NM03_12_08")
end

--Mirabel (MIR)	Build a Power Core to expand the power grid.
function Dialog_NM03_12_08()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_08")
end

--Mirabel (MIR)	To expand our base past the Power Core, we will need to build Signal Towers.  Signal Towers transfer power from the Power Core to nearby structures or other Signal Towers.
function Dialog_NM03_12_09()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_09")
end

--Mirabel (MIR)	That structure is currently unpowered.  Build a Signal Tower near it to connect it to the power grid.
function Dialog_NM03_12_10()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_10")
end

--Mirabel (MIR)	To continue building our base, we will need more raw materials.  To collect these, we will need to construct a Recycler Station.
function Dialog_NM03_12_11()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_11")
	Create_Thread("Dialog_NM03_12_12")
end

--Mirabel (MIR)	We have located a cache of raw materials nearby.   Build the Recycler Station near these raw materials to collect them.
function Dialog_NM03_12_12()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_12")
end

--Mirabel (MIR)	We should also construct an Aircraft Assembly.  Then we can build Corruptors to infect Hierarchy units with computer viruses. That should slow them down and give us feedback on their positions.
function Dialog_NM03_12_13()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_13")
end

--Mirabel (MIR)	To replenish our infantry, we will first need to build a Robotic Assembly.
function Dialog_NM03_12_14()
	Queue_Talking_Head(dialog_mirabel, "NVS03_SCENE12_14")
end

function Post_Load_Callback()
	UI_Hide_Research_Button()
	Movie_Commands_Post_Load_Callback()
end

