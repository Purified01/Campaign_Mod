-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Tutorial_Tut03.lua#31 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Tutorial_Tut03.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Brian_Hayes $
--
--            $Change: 87106 $
--
--          $DateTime: 2007/10/31 19:15:20 $
--
--          $Revision: #31 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGSpawnUnits")
require("PGMoveUnits")
require("PGAchievementAward")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")
require("RetryMission")
require("PGColors")

---------------------------------------------------------------------------------------------------

function Definitions()
	play_section_one=true
	play_section_two=true
	play_section_three=true

	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	
	hostile = Find_Player("Hostile")
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")

	PGColors_Init_Constants()
	--uea.Enable_Colorization(true, COLOR_GREEN)
	--aliens.Enable_Colorization(true, COLOR_RED)
	--novus.Enable_Colorization(true, COLOR_CYAN)
	--hostile.Enable_Colorization(true, COLOR_RED)

	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
	--Don't allow using the 'forfeit battle' option during this tutorial
	Script.Set_Async_Data("PreventForfeit", true)
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through
function State_Init(message)
	if message == OnEnter then
		-- ***** ACHIEVEMENT_AWARD *****
		PGAchievementAward_Init()
		-- ***** ACHIEVEMENT_AWARD *****

		-- ***** HINT SYSTEM *****
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		local scene = Get_Game_Mode_GUI_Scene()
		Register_Hint_Context_Scene(scene)			-- Set the scene to which independant hints   will be attached.
		-- ***** HINT SYSTEM *****

		-- Radar Initialization
		local radar_filter_id1 = RadarMap.Add_Filter("Radar_Map_Enable", aliens)
		local radar_filter_id2 = RadarMap.Add_Filter("Radar_Map_Allow_Mouse_Input", aliens)
		local radar_filter_id3 = RadarMap.Add_Filter("Radar_Map_Show_Terrain", aliens)
		local radar_filter_id4 = RadarMap.Add_Filter("Radar_Map_Show_FOW", aliens)
		local radar_filter_id5 = RadarMap.Add_Filter("Radar_Map_Show_Owned", aliens)
		local radar_filter_id6 = RadarMap.Add_Filter("Radar_Map_Show_Allied", aliens)
		local radar_filter_id7 = RadarMap.Add_Filter("Radar_Map_Show_Enemy", aliens)
		local radar_filter_id8 = RadarMap.Add_Filter("Radar_Map_Show_Neutral", aliens)
		
	novus.Allow_AI_Unit_Behavior(false)
	aliens.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	
		Fade_Screen_Out(0)
		Create_Thread("Thread_Mission_Start")
	
	elseif message == OnUpdate then
	end
end


--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script
function Thread_Mission_Start()
	aliens.Reset_Story_Locks()
			
	--UI_Hide_Research_Button()
	UI_Hide_Sell_Button()
	--UI_Display_Tooltip_Resources(false)
	--UI_Set_Display_Credits_Pop(false)
	
	cam_default_settings = Get_Camera_Settings()
	
	local_player = Find_Player("local")
	
	mission_start=Find_Hint("MARKER_GENERIC","missionstart")
	camera_boundary_a=Find_All_Objects_With_Hint("objabound")
	camera_boundary_e=Find_All_Objects_With_Hint("objebound")
	camera_boundary_f=Find_All_Objects_With_Hint("objfbound")
	
	objective_a_location=Find_Hint("MARKER_GENERIC","cam-a")
	objective_b_location=Find_Hint("MARKER_GENERIC","cam-b")
	objective_bsub_location=Find_Hint("MARKER_GENERIC","cam-bsub")
	objective_c_location=Find_Hint("MARKER_GENERIC","cam-c")
	objective_d_location=Find_Hint("MARKER_GENERIC","cam-d")
	objective_e_location=Find_Hint("MARKER_GENERIC","cam-e")
	objective_f_location=Find_Hint("MARKER_GENERIC","cam-f")
	objective_g_location=Find_Hint("MARKER_GENERIC","cam-g")
	objective_h_location=Find_Hint("MARKER_GENERIC","cam-h")
	objective_i_location=Find_Hint("MARKER_GENERIC","cam-i")
	objective_j_location=Find_Hint("MARKER_GENERIC","cam-j")
	objective_k_location=Find_Hint("MARKER_GENERIC","cam-k")
	objective_l_location=Find_Hint("MARKER_GENERIC","cam-l")
	objective_m_location=Find_Hint("MARKER_GENERIC","cam-m")
	objective_n_location=Find_Hint("MARKER_GENERIC","cam-n")
	objective_o_location=Find_Hint("MARKER_GENERIC","cam-o")
	objective_p_location=Find_Hint("MARKER_GENERIC","cam-p")
	objective_q_location=Find_Hint("MARKER_GENERIC","cam-q")
	objective_r_location=Find_Hint("MARKER_GENERIC","cam-r")
	objective_s_location=Find_Hint("MARKER_GENERIC","cam-s")
	objective_t_location=Find_Hint("MARKER_GENERIC","cam-t")
	objective_u_location=Find_Hint("MARKER_GENERIC","cam-u")
	objective_v_location=Find_Hint("MARKER_GENERIC","cam-v")
	objective_w_location=Find_Hint("MARKER_GENERIC","cam-w")
	objective_x_location=Find_Hint("MARKER_GENERIC","cam-x")
	
	objective_a_target=Find_All_Objects_With_Hint("target-a")
	for i, unit in pairs(objective_a_target) do
		unit.Set_Selectable(false)
		unit.Suspend_Locomotor(true)
	end
	objective_e_target=Find_Hint("MARKER_GENERIC_PURPLE","target-e")
	objective_e_target_b=Find_All_Objects_With_Hint("target-e-2")
	objective_e_target_c=Find_Hint("MARKER_GENERIC_PURPLE","target-e-3")
	for i, unit in pairs(objective_e_target_b) do
		unit.Prevent_All_Fire(true)
	end
	objective_f_target=Find_Hint("ALIEN_LOST_ONE","target-f")
	objective_f_target.Make_Invulnerable(true)
	objective_f_target.Set_Selectable(false)
	objective_f_target.Suspend_Locomotor(true)
	objective_g_target=Find_All_Objects_With_Hint("target-g")
	for i, unit in pairs(objective_g_target) do
		unit.Make_Invulnerable(true)
		unit.Suspend_Locomotor(true)
	end
	objective_h_target=Find_Hint("MARKER_GENERIC_PURPLE","target-h")
	objective_i_target=Find_Hint("TUT03_HUMMER_INSIGNIFICANT","target-i")
	objective_i_target.Set_Cannot_Be_Killed(true)
	objective_i_target_b=Find_Hint("MARKER_GENERIC_PURPLE","target-i-2")
	objective_j_target=Find_Hint("MARKER_GENERIC_PURPLE","target-j")
	objective_j_target_b=Find_All_Objects_With_Hint("target-j-2")
	objective_k_target=Find_Hint("MARKER_GENERIC_PURPLE","target-k")
	objective_k_target_b=Find_All_Objects_With_Hint("target-k-2")
	objective_l_target=Find_Hint("MARKER_GENERIC_PURPLE","target-l")
	objective_m_target=Find_Hint("ALIEN_GLYPH_CARVER","target-m")
	objective_m_target_b=Find_Hint("ALIEN_ARRIVAL_SITE","target-m-2")
	objective_m_target_b.Set_Selectable(false)
	objective_m_target_c=Find_Hint("MARKER_GENERIC_PURPLE","target-m-3")
	objective_n_target=Find_Hint("MARKER_GENERIC_PURPLE","target-n")

	objective_r_target=Find_Hint("MARKER_GENERIC_PURPLE","target-r")
	objective_s_target=Find_Hint("MARKER_GENERIC_PURPLE","target-s")
	--objective_v_target_b=Find_Hint("ALIEN_THEORY_CORE","target-v-2")
	--objective_v_target_b.Set_Selectable(false)
	objective_x_target=Find_Hint("MARKER_GENERIC_PURPLE","target-x")
	--objective_x_target_b=Find_Hint("MILITARY_HUMMER","target-x-2")
	--objective_x_target_b.Prevent_All_Fire(true)
	
	radar_map_left_clicked=false
	radar_map_right_clicked=false
	map_mouse_wheel_rotate=false
	map_mouse_wheel_clicked=false
	map_mouse_wheel_zoom_in=false
	map_mouse_wheel_zoom_out=false
	map_right_click_scroll=false

	objective_a_completed=false;
	objective_b_completed=false;
	objective_bsub_completed=false;
	objective_c_completed=false;
	objective_d_completed=false;
	objective_e_completed=false;
	objective_f_completed=false;
	objective_g_completed=false;
	objective_h_completed=false;
	objective_i_completed=false;
	objective_i_failed=false;
	objective_j_completed=false;
	objective_j_failed=false
	objective_k_completed=false;
	objective_k_failed=false
	objective_l_completed=false;
	objective_l_failed=false
	objective_m_completed=false;
	objective_n_completed=false;
	objective_o_completed=false;
	objective_p_completed=false;
	objective_q_completed=false;
	objective_r_completed=false;
	objective_s_completed=false;
	objective_t_completed=false;
	objective_u_completed=false;
	objective_v_completed=false;
	objective_w_completed=false;
	objective_x_completed=false;
	
	mission_success = false
	time_objective_sleep = 5
	time_dialogue_sleep=6
	time_obj_ready_sleep = 5.1
	time_radar_sleep = 2
	time_camera_reset = 1
	
	if play_section_one then
		-- short intro to the mission	
		Point_Camera_At(mission_start)
		Lock_Controls(1)
		Fade_Screen_Out(0)
		Start_Cinematic_Camera()
		Letter_Box_In(0)
		Transition_Cinematic_Target_Key(mission_start, 0, 0, 0, 0, 0, 0, 0, 0)
		Transition_Cinematic_Camera_Key(mission_start, 0, 200, 55, 65, 1, 0, 0, 0)
		Fade_Screen_In(1) 
		Transition_To_Tactical_Camera(5)
		Sleep(5)
		End_Cinematic_Camera()
		Letter_Box_Out(1)
		Lock_Controls(0)
	else
		Fade_Screen_In(0) 
		Sleep(1/2)
	end

	-- Needed to move this down a bit since the Player script will reset the blocked research state if we do it
	-- too soon after the start of a mission.  10/31/2007 6:53:45 PM -- BMH
	player_script = aliens.Get_Script()
	player_script.Call_Function("Block_Research_Branch","A",true,true)
	player_script.Call_Function("Block_Research_Branch","B",true,true)
	player_script.Call_Function("Block_Research_Branch","C",true,true)
	
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	
	if play_section_one then
	
		if true then
			Create_Thread("Move_Camera_To",objective_a_location)
			
			Queue_Speech_Event("TUT_VID01_SCENE01_01")
			map_right_click_scroll=false
			Create_Thread("Show_Objective_A")
			Sleep(time_obj_ready_sleep)
			

			while not objective_a_completed do
				Sleep(1)
				camera_oob=Check_Camera_Bounds_AE()
				if map_right_click_scroll then 
					objective_a_completed=true
				else
					if camera_oob then
						Create_Thread("Assume_Camera",objective_a_location)
						map_right_click_scroll=false
						Sleep(time_camera_reset)
						Create_Thread("Release_Camera",objective_a_location)
						Queue_Speech_Event("TUT_VID01_SCENE01_11")
					end
				end
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_A_COMPLETE"} )
			-- transition center screen text to objectives list
			Objective_Complete(objective_a)
			Sleep(time_objective_sleep)
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			--objective_a_location.Highlight(false)
		end
		
		if true then
			Create_Thread("Move_Camera_To",objective_b_location)

			Queue_Speech_Event("TUT_VID01_SCENE01_02")
			map_mouse_wheel_rotate=false
			Create_Thread("Show_Objective_B")
			Sleep(time_obj_ready_sleep)
			
			
			while not objective_b_completed do
				Sleep(1)
				camera_oob=Check_Camera_Bounds_AE()
				if map_mouse_wheel_rotate then 
					objective_b_completed=true
				else
					if camera_oob then
						Create_Thread("Assume_Camera",objective_b_location)
						map_mouse_wheel_rotate=false
						Sleep(time_camera_reset)
						Create_Thread("Release_Camera",objective_b_location)
						Queue_Speech_Event("TUT_VID01_SCENE01_12")
					end
				end
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_B_COMPLETE"} )
			-- transition center screen text to objectives list
			Objective_Complete(objective_b)
			Sleep(time_objective_sleep)
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			--objective_a_location.Highlight(false)
		end
		
		if true then
			Create_Thread("Move_Camera_To",objective_bsub_location)
			Queue_Speech_Event("TUT_VID01_SCENE01_20")
			map_mouse_wheel_clicked=false
			Create_Thread("Show_Objective_BSub")
			Sleep(time_obj_ready_sleep)
			
			
			while not objective_bsub_completed do
				Sleep(1)
				camera_oob=Check_Camera_Bounds_AE()
				if map_mouse_wheel_clicked then 
					objective_bsub_completed=true
				else
					if camera_oob then
						Create_Thread("Assume_Camera",objective_bsub_location)
						map_mouse_wheel_clicked=true
						Sleep(time_camera_reset)
						Create_Thread("Release_Camera",objective_bsub_location)
						Queue_Speech_Event("TUT_VID01_SCENE01_20")
					end
				end
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_BSUB_COMPLETE"} )
			-- transition center screen text to objectives list
			Objective_Complete(objective_bsub)
			Sleep(time_objective_sleep)
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			--objective_a_location.Highlight(false)
		end
		
		if true then
			Create_Thread("Move_Camera_To",objective_c_location)

			Queue_Speech_Event("TUT_VID01_SCENE01_03")
			Queue_Speech_Event("TUT_VID01_SCENE01_13")
			map_mouse_wheel_zoom_in=false
			map_mouse_wheel_zoom_out=false
			Create_Thread("Show_Objective_CD")
			Sleep(time_obj_ready_sleep)
			
			
			while not (objective_c_completed and objective_d_completed) do
				Sleep(1)
				camera_oob=Check_Camera_Bounds_AE()
				if map_mouse_wheel_zoom_in and not objective_c_completed then 
					objective_c_completed=true
					-- display objective center screen
					Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_C_COMPLETE"} )
					-- transition center screen text to objectives list
					Objective_Complete(objective_c)
					--Sleep(time_objective_sleep)
					Queue_Speech_Event("TUT_VID01_SCENE01_14")
				end
				if map_mouse_wheel_zoom_out and map_mouse_wheel_zoom_in then 
					if not (objective_c_completed and objective_d_completed) then
						objective_d_completed=true
						-- display objective center screen
						Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_D_COMPLETE"} )
						-- transition center screen text to objectives list
						Objective_Complete(objective_d)
						Sleep(time_objective_sleep)
					end
				end
				if camera_oob then
					if not objective_c_completed then
						if not objective_d_completed then
							Create_Thread("Assume_Camera",objective_c_location)
							Sleep(time_camera_reset)
							Create_Thread("Release_Camera",objective_c_location)
						end
					end
				end
			end
		end
		
	end
	
	if play_section_two then
	
		Queue_Speech_Event("TUT_VID01_SCENE01_04")
		Sleep(time_dialogue_sleep)
		for i, unit in pairs(objective_e_target_b) do
			if TestValid(unit) then
				unit.Move_To(objective_e_target_c)
			end
		end
		Queue_Speech_Event("TUT_VID01_SCENE01_05")
		Sleep(time_dialogue_sleep)
		Sleep(time_dialogue_sleep)
		
		if true then
			objective_f_target.Change_Owner(aliens)
			Create_Thread("Move_Camera_To",objective_e_location)

			Queue_Speech_Event("TUT_VID01_SCENE01_06")
			radar_map_left_clicked=false
			Create_Thread("Show_Objective_E")
			Sleep(time_obj_ready_sleep)
			
			
			while not objective_e_completed do
				Sleep(1)
				camera_oob=Check_Camera_Bounds_A()
				if Is_On_Screen(objective_e_target) and radar_map_left_clicked then 
					objective_e_completed=true
				else 
					if camera_oob then
						Create_Thread("Assume_Camera",objective_e_location)
						radar_map_left_clicked=false
						Sleep(time_camera_reset)
						Create_Thread("Release_Camera",objective_e_location)
						Queue_Speech_Event("TUT_VID01_SCENE01_15")
					end
				end
			end
			Stop_All_Speech()
			for i, unit in pairs(objective_a_target) do
				if TestValid(unit) then unit.Despawn() end
			end
			
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_E_COMPLETE"} )
			-- transition center screen text to objectives list
			Objective_Complete(objective_e)
			-- display highlights, radar blips, and ground decals associated with objective
			if TestValid(objective_e_area) then objective_e_area.Despawn() end
			Remove_Radar_Blip("blip_objective_e")
			objective_e_target.Highlight(false)
			Sleep(time_objective_sleep)
		end

		if true then
			Create_Thread("Move_Camera_To",objective_f_location)
			objective_f_target.Set_Selectable(true)
			Queue_Speech_Event("TUT_VID01_SCENE01_07")
			Create_Thread("Show_Objective_F")
			Sleep(time_obj_ready_sleep)
			
			while not objective_f_completed do
				Sleep(1)
				if objective_f_target.Is_Selected() then 
					objective_f_completed=true
				end
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_F_COMPLETE"} )
			-- transition center screen text to objectives list
			Objective_Complete(objective_f)
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			objective_f_target.Highlight_Small(false)
			Sleep(time_objective_sleep)
		end

		if true then
			for i, unit in pairs(objective_g_target) do
				if TestValid(unit) then 
					unit.Change_Owner(aliens)
					unit.Suspend_Locomotor(false)
					unit.Move_To(objective_f_target)
				end
			end
			
			Create_Thread("Move_Camera_To",objective_g_location)

			Queue_Speech_Event("TUT_VID01_SCENE01_08")
			Create_Thread("Show_Objective_G")
			
			Sleep(7) -- time it takes lost ones to come on screen
			
			for i, unit in pairs(objective_g_target) do
				if TestValid(unit) then 
					unit.Suspend_Locomotor(true)
				end
			end
			
			while not objective_g_completed do
				Sleep(1)
				local objective_g_count=0
				for i, unit in pairs(objective_g_target) do
					if unit.Is_Selected() then 
						objective_g_count=objective_g_count+1
					end
				end
				if objective_g_count==table.getn(objective_g_target) then
					if objective_f_target.Is_Selected() then
						objective_g_completed=true
					end
				end
				
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_G_COMPLETE"} )
			-- transition center screen text to objectives list
			Objective_Complete(objective_g)
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			objective_f_target.Highlight_Small(false)
			for i, unit in pairs(objective_g_target) do
				unit.Highlight_Small(false)
			end
			Sleep(time_objective_sleep)
		end
		
		if true then
			objective_f_target.Suspend_Locomotor(false)
			for i, unit in pairs(objective_g_target) do
				if TestValid(unit) then 
					unit.Change_Owner(aliens)
					unit.Suspend_Locomotor(false)
					unit.Move_To(objective_f_target)
				end
			end
			Create_Thread("Move_Camera_To",objective_h_location)

			Queue_Speech_Event("TUT_VID01_SCENE01_09")
			Create_Thread("Show_Objective_H")
			Sleep(time_obj_ready_sleep)
			
			while not objective_h_completed do
				Sleep(1)
			end
			
			objective_f_target.Move_To(objective_h_target)
			for i, unit in pairs(objective_g_target) do
				if TestValid(unit) then 
					unit.Move_To(objective_h_target)
				end
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_H_COMPLETE"} )
			-- transition center screen text to objectives list
			Objective_Complete(objective_h)
			-- display highlights, radar blips, and ground decals associated with objective
			if TestValid(objective_h_area) then objective_h_area.Despawn() end
			Remove_Radar_Blip("blip_objective_h")
			objective_h_target.Highlight(false)
			Sleep(time_objective_sleep)
		end
		
		if true then
			Create_Thread("Move_Camera_To",objective_i_location)

			Queue_Speech_Event("TUT_VID01_SCENE01_10")
			Create_Thread("Show_Objective_I")
			Sleep(time_obj_ready_sleep)
			
			while not objective_i_completed do
				Sleep(1)
				if objective_i_failed then 
					Create_Thread("Assume_Camera",objective_i_location)
					objective_f_target.Teleport_And_Face(objective_h_target)
					for i, unit in pairs(objective_g_target) do
						if TestValid(unit) then 
							unit.Teleport_And_Face(objective_h_target)
						end
					end
					objective_i_failed=false
					Sleep(time_camera_reset)
					Create_Thread("Release_Camera",objective_i_location)
					Queue_Speech_Event("TUT_VID01_SCENE01_19")
				end
				
			end
			Stop_All_Speech()
			Sleep(1)
			objective_i_target.Set_Cannot_Be_Killed(false)
			objective_i_target.Take_Damage(9999)
			
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_I_COMPLETE"} )
			-- transition center screen text to objectives list
			Objective_Complete(objective_i)
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			--objective_a_location.Highlight(false)
			Sleep(time_objective_sleep)
		end

		if true then
			if TestValid(objective_i_target) then 
				objective_i_target.Set_Cannot_Be_Killed(false)
				objective_i_target.Take_Damage(9999)
			end
			objective_f_target.Suspend_Locomotor(false)
			objective_f_target.Move_To(objective_i_target_b)
			for i, unit in pairs(objective_g_target) do
				if TestValid(unit) then 
					unit.Change_Owner(aliens)
					unit.Suspend_Locomotor(false)
					unit.Move_To(objective_i_target_b)
				end
			end
			local hummers={}
			for i, unit in pairs(objective_j_target_b) do
				if TestValid(unit) then 
					hummers[i] = Create_Generic_Object(Find_Object_Type("MILITARY_HUMMER"),unit,uea)
					hummers[i].Suspend_Locomotor(true)
				end
			end
			
			Create_Thread("Move_Camera_To",objective_j_location)

			Queue_Speech_Event("TUT_VID02_SCENE01_01")
			Queue_Speech_Event("TUT_VID02_SCENE01_02")
			Create_Thread("Show_Objective_J")
			Sleep(time_obj_ready_sleep)
			
			while not objective_j_completed do
				Sleep(1)
				if objective_j_failed then 
					Create_Thread("Assume_Camera",objective_j_location)
					objective_f_target.Teleport_And_Face(objective_i_target_b)
					for i, unit in pairs(objective_g_target) do
						if TestValid(unit) then 
							unit.Teleport_And_Face(objective_i_target_b)
							unit.Move_To(objective_i_target_b)
						end
					end
					Sleep(1)
					for i, unit in pairs(objective_j_target_b) do
						if TestValid(unit) then 
							if TestValid(hummers[i]) then hummers[i].Despawn() end
							hummers[i] = Create_Generic_Object(Find_Object_Type("MILITARY_HUMMER"),unit,uea)
							hummers[i].Suspend_Locomotor(true)
						end
					end
					objective_j_failed=false
					Sleep(time_camera_reset)
					Create_Thread("Release_Camera",objective_j_location)
					Queue_Speech_Event("TUT_VID02_SCENE01_08")
				end
				
			end
			Create_Thread("Move_Camera_To",objective_j_target)
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_J_COMPLETE"} )
			-- transition center screen text to objectives list
			Objective_Complete(objective_j)
			-- display highlights, radar blips, and ground decals associated with objective
			if TestValid(objective_j_area) then objective_j_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			objective_j_target.Highlight(false)
			Queue_Speech_Event("TUT_VID02_SCENE01_03")
			Sleep(time_dialogue_sleep)
			Sleep(time_dialogue_sleep)
			for i, unit in pairs(objective_j_target_b) do
				if TestValid(unit) then 
					if TestValid(hummers[i]) then hummers[i].Take_Damage(9999) end
				end
			end
		end

		if true then
			if TestValid(objective_i_target) then 
				objective_i_target.Set_Cannot_Be_Killed(false)
				objective_i_target.Take_Damage(9999)
			end
			objective_f_target.Move_To(objective_j_target)
			for i, unit in pairs(objective_g_target) do
				if TestValid(unit) then 
					unit.Move_To(objective_j_target)
				end
			end
			local hummers={}
			for i, unit in pairs(objective_k_target_b) do
				if TestValid(unit) then 
					hummers[i] = Create_Generic_Object(Find_Object_Type("MILITARY_HUMMER"),unit,uea)
					hummers[i].Suspend_Locomotor(true)
				end
			end
			
			Create_Thread("Move_Camera_To",objective_k_location)

			Queue_Speech_Event("TUT_VID02_SCENE01_04")
			Queue_Speech_Event("TUT_VID02_SCENE01_05")
			Create_Thread("Show_Objective_K")
			Sleep(time_obj_ready_sleep)
			
			while not objective_k_completed do
				Sleep(1)
				if objective_k_failed then 
					Create_Thread("Assume_Camera",objective_k_location)
					objective_f_target.Teleport_And_Face(objective_j_target)
					for i, unit in pairs(objective_g_target) do
						if TestValid(unit) then 
							unit.Teleport_And_Face(objective_j_target)
							unit.Move_To(objective_j_target)
						end
					end
					Sleep(1)
					for i, unit in pairs(objective_k_target_b) do
						if TestValid(unit) then 
							if TestValid(hummers[i]) then hummers[i].Despawn() end
							hummers[i] = Create_Generic_Object(Find_Object_Type("MILITARY_HUMMER"),unit,uea)
							hummers[i].Suspend_Locomotor(true)
						end
					end
					objective_k_failed=false
					Sleep(time_camera_reset)
					Create_Thread("Release_Camera",objective_k_location)
					Queue_Speech_Event("TUT_VID02_SCENE01_09")
				end
				
			end
			Create_Thread("Move_Camera_To",objective_k_target)
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_K_COMPLETE"} )
			-- transition center screen text to objectives list
			Objective_Complete(objective_k)
			-- display highlights, radar blips, and ground decals associated with objective
			if TestValid(objective_k_area) then objective_k_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			objective_k_target.Highlight(false)
			Queue_Speech_Event("TUT_VID02_SCENE01_06")
			Sleep(time_dialogue_sleep)
			Sleep(time_dialogue_sleep)
			for i, unit in pairs(objective_k_target_b) do
				if TestValid(unit) then 
					if TestValid(hummers[i]) then hummers[i].Take_Damage(9999) end
				end
			end
		end

		if true then
			radar_map_right_clicked=false
			if TestValid(objective_i_target) then 
				objective_i_target.Set_Cannot_Be_Killed(false)
				objective_i_target.Take_Damage(9999)
			end
			objective_f_target.Move_To(objective_k_target)
			for i, unit in pairs(objective_g_target) do
				if TestValid(unit) then 
					unit.Move_To(objective_k_target)
				end
			end
			
			Create_Thread("Move_Camera_To",objective_l_location)

			Queue_Speech_Event("TUT_VID02_SCENE01_07")
			Create_Thread("Show_Objective_L")
			Sleep(time_obj_ready_sleep)
			

			while not objective_l_completed do
				if objective_l_failed then
					Create_Thread("Assume_Camera",objective_l_location)
					objective_f_target.Teleport_And_Face(objective_k_target)
					for i, unit in pairs(objective_g_target) do
						if TestValid(unit) then 
							unit.Teleport_And_Face(objective_k_target)
						end
					end
					radar_map_right_clicked=false
					objective_l_failed=false
					Sleep(time_camera_reset)
					Create_Thread("Release_Camera",objective_l_location)
					Queue_Speech_Event("TUT_VID02_SCENE01_10")
				end
				Sleep(1)
			end
			Create_Thread("Move_Camera_To",objective_l_target)
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_L_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			if TestValid(objective_l_area) then objective_l_area.Despawn() end
			Remove_Radar_Blip("blip_objective_l")
			objective_l_target.Highlight(false)
			Objective_Complete(objective_l)
			Sleep(time_objective_sleep)
		end
	
	end

	if play_section_three then
	
		if true then
			for i, unit in pairs(objective_a_target) do
				if TestValid(unit) then unit.Despawn() end
			end
			if TestValid(objective_f_target) then objective_f_target.Despawn() end
			for i, unit in pairs(objective_g_target) do
				if TestValid(unit) then unit.Despawn() end
			end
			objective_m_target.Change_Owner(aliens)
			--aliens.Lock_Object_Type(Find_Object_Type("ALIEN_RADIATION_SPITTER"),true,STORY)
			--aliens.Lock_Object_Type(Find_Object_Type("Alien_Gravitic_Manipulator"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Arrival_Site"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Scan_Drone"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Superweapon_Reaper_Turret"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat"),false,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("ALIEN_GRUNT"),true,STORY)

			Create_Thread("Move_Camera_To",objective_m_location)

			Queue_Speech_Event("TUT_VID03_SCENE01_01")
			Sleep(time_dialogue_sleep)
			Queue_Speech_Event("TUT_VID03_SCENE01_02")
			Sleep(time_dialogue_sleep)
			Queue_Speech_Event("TUT_VID03_SCENE01_03")
			Create_Thread("Show_Objective_M")
			Sleep(time_obj_ready_sleep)
			
			while not objective_m_completed do
				Sleep(1)
				if objective_m_target.Is_Selected() then 
					objective_m_completed=true
				end
				
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_M_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			objective_m_target.Highlight(false)
			Objective_Complete(objective_m)
			Sleep(time_objective_sleep)
		end

		if true then
			money_amt=Find_Object_Type("ALIEN_WALKER_HABITAT").Get_Tactical_Build_Cost()
			aliens.Give_Money(money_amt)
		
			Create_Thread("Move_Camera_To",objective_n_location)

			Queue_Speech_Event("TUT_VID03_SCENE01_04")
			Create_Thread("Show_Objective_N")
			Sleep(time_obj_ready_sleep)
			
			while not objective_n_completed do
				Sleep(1)
				beacon=Find_First_Object("Alien_Walker_Habitat_Glyph_Beacon")
				if TestValid(beacon) then
					if beacon.Get_Distance(objective_n_target)>200 then
						beacon.Sell()
						--money_amt=Find_Object_Type("ALIEN_WALKER_HABITAT").Get_Tactical_Build_Cost()
						--aliens.Give_Money(money_amt)
					end
				end
				glyph=Find_First_Object("Alien_Walker_Habitat_Glyph")
				if TestValid(glyph) then 
					glyph.Add_Attribute_Modifier( "Structure_Speed_Build", 99 )
				end
				walker=Find_First_Object("Alien_Walker_Habitat")
				if TestValid(walker) then 
					objective_n_completed=true
					walker.Suspend_Locomotor(true)
					walker.Override_Max_Speed(0)
					aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat"),true,STORY)
				end
			end
			Stop_All_Speech()
			objective_m_target.Change_Owner(neutral)
			objective_m_target.Move_To(objective_m_target_c)
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_N_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			if TestValid(objective_n_area) then objective_n_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			objective_n_target.Highlight(false)
			Objective_Complete(objective_n)
			Sleep(time_objective_sleep)
		end

		if true then
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Armor_Leg"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Foo_Chamber"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Material_Optimizer"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Teleport_Accelerator_Leg"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Plasma_Cannon"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Arc_Trigger"),true,STORY)
			
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Brute_Mutator"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Terrain_Conditioner"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Armor_Crown"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Heat_Sink"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Range_Enhancer"),true,STORY)
			aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Lost_One_Mutator"),false,STORY)
			
			Create_Thread("Move_Camera_To",objective_o_location)

			Queue_Speech_Event("TUT_VID03_SCENE01_05")
			Create_Thread("Show_Objective_O")
			Sleep(time_obj_ready_sleep)
			
			while not objective_o_completed do
				Sleep(1)
				walker=Find_First_Object("Alien_Walker_Habitat")
				if TestValid(walker) then 
					if walker.Is_Selected() then
						objective_o_completed=true
					end
				end
				
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_O_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			--objective_a_location.Highlight(false)
			Objective_Complete(objective_o)
			Sleep(time_objective_sleep)
		end

		Queue_Speech_Event("TUT_VID03_SCENE01_06")
		Sleep(time_dialogue_sleep)
		
		if true then
			money_amt=Find_Object_Type("Alien_Walker_Habitat_HP_Lost_One_Mutator").Get_Tactical_Build_Cost()
			aliens.Give_Money(money_amt)
			Create_Thread("Move_Camera_To",objective_p_location)

			Queue_Speech_Event("TUT_VID03_SCENE01_07")
			Create_Thread("Show_Objective_P")
			Sleep(time_obj_ready_sleep)
			
			while not objective_p_completed do
				Sleep(1)
				pod=Find_First_Object("Alien_Walker_Habitat_HP_Lost_One_Mutator_Under_Construction")
				if TestValid(pod) then 
					hp_objs=walker.Get_All_Hard_Points()
					for i,unit in pairs(hp_objs) do
						unit.Add_Attribute_Modifier( "Unit_Build_Rate_Multiplier", 99 )
						unit.Add_Attribute_Modifier( "Structure_Speed_Build", 99 )
					end
					pod.Add_Attribute_Modifier( "Unit_Build_Rate_Multiplier", 99 )
					pod.Add_Attribute_Modifier( "Structure_Speed_Build", 99 )
					objective_p_completed=true
					Create_Thread("Pod_Build_Check") -- this func makes sure no other hps can be built so players don't waste money
					--aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Lost_One_Mutator"),true,STORY)
				end
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_P_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_p_area) then objective_p_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			hp_obj.Highlight(false)
			Objective_Complete(objective_p)
			Sleep(time_objective_sleep)
		end

		Queue_Speech_Event("TUT_VID03_SCENE01_08")
		Sleep(time_dialogue_sleep)
		
		if true then
			walker.Set_Selectable(true)
			Create_Thread("Move_Camera_To",objective_q_location)

			Queue_Speech_Event("TUT_VID03_SCENE01_09")
			Create_Thread("Show_Objective_Q")
			Sleep(time_obj_ready_sleep)
			
			hp_objs=walker.Get_All_Hard_Points()
			for i,unit in pairs(hp_objs) do
				unit.Add_Attribute_Modifier( "Unit_Build_Rate_Multiplier", 99 )
				unit.Add_Attribute_Modifier( "Structure_Speed_Build", 99 )
			end
			while not objective_q_completed do
				Sleep(1)
				if TestValid(walker) then 
					if walker.Is_Selected() then
						objective_q_completed=true
					end
				end
				
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_Q_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			--objective_a_location.Highlight(false)
			Objective_Complete(objective_q)
			Sleep(time_objective_sleep)
		end

		if true then
			money_amt=Find_Object_Type("ALIEN_LOST_ONE").Get_Tactical_Build_Cost()
			aliens.Give_Money(money_amt)
			Create_Thread("Move_Camera_To",objective_r_location)

			Queue_Speech_Event("TUT_VID03_SCENE01_10")
			Create_Thread("Show_Objective_R")
			Sleep(time_obj_ready_sleep)
			
			while not objective_r_completed do
				Sleep(1)
				lostone=Find_First_Object("ALIEN_LOST_ONE")
				if TestValid(lostone) then 
					objective_r_completed=true
					walker.Change_Owner(neutral)
					walker.Override_Max_Speed(.6)
					walker.Suspend_Locomotor(false)
					walker.Move_To(objective_r_target)
					aliens.Lock_Object_Type(Find_Object_Type("ALIEN_LOST_ONE"),true,STORY)
					lostone.Prevent_All_Fire(true)
					--objective_x_target_b.Set_Cannot_Be_Killed(true)
					--objective_x_target_b.Make_Invulnerable(true)
				end
			end
			Create_Thread("Move_Camera_To",objective_s_location)
			lostone.Move_To(objective_s_target)
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_R_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			--objective_a_location.Highlight(false)
			Objective_Complete(objective_r)
			Queue_Speech_Event("TUT_VID03_SCENE01_11")
			Sleep(time_objective_sleep)
		end

		Queue_Speech_Event("TUT_VID03_SCENE01_12")
		Sleep(time_dialogue_sleep)
		
		if true then
			aliens.Lock_Unit_Ability("Alien_Lost_One", "Lost_One_Plasma_Bomb_Unit_Ability", false,STORY)
			--lostone.Move_To(objective_s_target)
			objective_s_target_b=lostone
			--Create_Thread("Move_Camera_To",objective_s_location)

			Queue_Speech_Event("TUT_VID04_SCENE01_01")
			Create_Thread("Show_Objective_S")
			Sleep(time_obj_ready_sleep)
			
			while not objective_s_completed do
				Sleep(1)
				if objective_s_target_b.Is_Selected() then 
					objective_s_completed=true
				end
				
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_S_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			objective_s_target_b.Highlight_Small(false)
			Objective_Complete(objective_s)
			Sleep(time_objective_sleep)
		end

		if true then
			Create_Thread("Move_Camera_To",objective_s_target_b)
			objective_s_target_b.Prevent_All_Fire(false)

			Queue_Speech_Event("TUT_VID04_SCENE01_02")
			Queue_Speech_Event("TUT_VID04_SCENE01_03")
			Create_Thread("Show_Objective_T")
			Sleep(time_obj_ready_sleep)
			
			while not objective_t_completed do
				Sleep(1)
				bomb=Find_First_Object("Lost_One_Plasma_Bomb")
				if TestValid(bomb) then 
					objective_t_completed=true
				end
				
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_T_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			--objective_a_location.Highlight(false)
			Objective_Complete(objective_t)
			Queue_Speech_Event("TUT_VID04_SCENE01_04")
			Sleep(time_objective_sleep)
			Sleep(time_objective_sleep)
		end

		if true then
			Create_Thread("Move_Camera_To",objective_s_target_b)

			Queue_Speech_Event("TUT_VID04_SCENE01_05")
			Sleep(time_obj_ready_sleep)
			Queue_Speech_Event("TUT_VID04_SCENE01_12")
			Create_Thread("Show_Objective_V")
			Sleep(time_obj_ready_sleep)
			
			--while not objective_v_completed do
				--Sleep(1)
				--if true then 
					--objective_v_completed=true
				--end
				
			--end
			--Stop_All_Speech()
			-- display objective center screen
			--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_V_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			--objective_a_location.Highlight(false)
			--Objective_Complete(objective_v)
			Queue_Speech_Event("TUT_VID04_SCENE01_06")
			Sleep(time_objective_sleep)
		end

		if true then
			Find_Player("local").Get_Script().Call_Function("Set_Research_Time_Modifier", .01)
			aliens.Give_Money(1000)
			player_script = aliens.Get_Script()
			player_script.Call_Function("Block_Research_Branch","C",false,true)
			Create_Thread("Move_Camera_To",objective_s_target_b)

			Queue_Speech_Event("TUT_VID04_SCENE01_13")
			Create_Thread("Show_Objective_W")
			Sleep(time_obj_ready_sleep)
			
			while not objective_w_completed do
				Sleep(1)
				local player_script = local_player.Get_Script()
				if player_script then
					local research_node_data = player_script.Call_Function("Retrieve_Node_Data", "C", 1)
					if research_node_data ~= nil and research_node_data.Completed then
						objective_w_completed=true
					else
						if local_player.Get_Credits() < 1000 then
							aliens.Give_Money(1000)
						end
					end
				end
			end
			player_script.Call_Function("Block_Research_Branch","C",true,true)
			UI_Hide_Research_Button()
			aliens.Lock_Unit_Ability("Alien_Lost_One", "Grey_Phase_Unit_Ability", false, STORY)
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_W_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			--objective_a_location.Highlight(false)
			Objective_Complete(objective_v)
			Objective_Complete(objective_w)
			Queue_Speech_Event("TUT_VID04_SCENE01_07")
			Sleep(time_objective_sleep)
		end

		if true then
			--aliens.Lock_Unit_Ability("Alien_Lost_One", "Grey_Phase_Unit_Ability", false,STORY)
			Create_Thread("Move_Camera_To",objective_s_target_b)

			Queue_Speech_Event("TUT_VID04_SCENE01_14")
			Create_Thread("Show_Objective_X")
			Sleep(time_obj_ready_sleep)
			
			while not objective_x_completed do
				Sleep(1)
				if objective_s_target_b.Is_Ability_Active("Grey_Phase_Unit_Ability") then 
					objective_x_completed=true
					objective_s_target_b.Stop()
					objective_s_target_b.Set_Selectable(false)
					Create_Thread("Objective_X_Animation")
				end
				
			end
			Stop_All_Speech()
			-- display objective center screen
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_X_COMPLETE"} )
			-- transition center screen text to objectives list
			-- display highlights, radar blips, and ground decals associated with objective
			--if TestValid(objective_a_area) then objective_a_area.Despawn() end
			--Remove_Radar_Blip("blip_objective_a")
			--objective_a_location.Highlight(false)
			Objective_Complete(objective_x)
			Sleep(time_objective_sleep)
		end
		
	end
	
	Queue_Speech_Event("TUT_VID04_SCENE01_08")
	Sleep(time_dialogue_sleep)
	Sleep(time_dialogue_sleep)
	
	aliens.Reset_Story_Locks()
	Create_Thread("Thread_Mission_Complete");
	
end

function Pod_Build_Check()
	while true do
		local pods=Find_All_Objects_Of_Type("Alien_Walker_Habitat_HP_Lost_One_Mutator")
		if table.getn(pods)>1 then
			pods[1].Take_Damage(9999)
			aliens.Give_Money(Find_Object_Type("Alien_Walker_Habitat_HP_Lost_One_Mutator").Get_Tactical_Build_Cost())
		end
		Sleep(1/2)
	end
end

	
function Radar_Map_Left_Clicked()
	radar_map_left_clicked=true
end

function Radar_Map_Right_Clicked()
	radar_map_right_clicked=true
end

function Map_Mouse_Wheel_Press()
	map_mouse_wheel_clicked=true
end

function Map_Mouse_Wheel_Rotate()
	map_mouse_wheel_rotate=true
end

function Map_Mouse_Wheel_Zoom(zoom_in)
	if zoom_in then
		map_mouse_wheel_zoom_in=true
	else
		map_mouse_wheel_zoom_out=true
	end
end

function Map_Right_Click_Scroll()
	map_right_click_scroll=true
end

function Objective_X_Animation()
	--BlockOnCommand(objective_x_target_b.Move_To(objective_s_target_b))
	--BlockOnCommand(objective_x_target_b.Move_To(objective_x_target))
end

function Assume_Camera(location)
	Lock_Controls(1)
	Fade_Screen_Out(1/2)
	Sleep(1/2)
	Apply_Camera_Settings(cam_default_settings)
	Point_Camera_At(location)
	Transition_To_Tactical_Camera(0)
	Fade_Screen_In(1/2)
	Sleep(1/2)
end

function Release_Camera(location)
	Point_Camera_At(location)
	Transition_To_Tactical_Camera(0)
	Lock_Controls(0)
end

function Move_Camera_To(location)
	Lock_Controls(1)
	Start_Cinematic_Camera()
	Point_Camera_At(location)
	Transition_To_Tactical_Camera(1)
	Sleep(1)
	End_Cinematic_Camera()
	Lock_Controls(0)
	--Point_Camera_At(location)
end

function Check_Camera_Bounds_AE()
	for i, marker in pairs(camera_boundary_a) do
		if TestValid(marker) then
			if Is_On_Screen(marker) then
				return true
			end
		end
	end
	for i, marker in pairs(camera_boundary_e) do
		if TestValid(marker) then
			if Is_On_Screen(marker) then
				return true
			end
		end
	end
	return false
end

function Check_Camera_Bounds_AF()
	for i, marker in pairs(camera_boundary_a) do
		if TestValid(marker) then
			if Is_On_Screen(marker) then
				return true
			end
		end
	end
	for i, marker in pairs(camera_boundary_f) do
		if TestValid(marker) then
			if Is_On_Screen(marker) then
				return true
			end
		end
	end
	return false
end

function Check_Camera_Bounds_A()
	for i, marker in pairs(camera_boundary_a) do
		if TestValid(marker) then
			if Is_On_Screen(marker) then
				return true
			end
		end
	end
	return false
end

-- adds mission objective
function Show_Objective_A()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_A_ADD"} )
	-- transition center screen text to objectives list
	Sleep(time_objective_sleep)
	objective_a = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_A")
end

-- adds mission objective
function Show_Objective_B()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_B_ADD"} )
	-- transition center screen text to objectives list
	Sleep(time_objective_sleep)
	objective_b = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_B")
end

-- adds mission objective
function Show_Objective_BSub()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_BSUB_ADD"} )
	-- transition center screen text to objectives list
	Sleep(time_objective_sleep)
	objective_bsub = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_BSUB")
end

-- adds mission objective
function Show_Objective_CD()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_CD_ADD"} )
	-- transition center screen text to objectives list
	Sleep(time_objective_sleep)
	objective_c = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_C")
	objective_d = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_D")
end

-- adds mission objective
function Show_Objective_E()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_E_ADD"} )
	-- transition center screen text to objectives list
	objective_e_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_e_target, neutral)
	Add_Radar_Blip(objective_e_target, "DEFAULT", "blip_objective_e")
	objective_e_target.Highlight(true)
	Sleep(time_objective_sleep)
	objective_e = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_E")
end

-- adds mission objective
function Show_Objective_F()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_F_ADD"} )
	-- transition center screen text to objectives list
	objective_f_target.Highlight_Small(true)
	Sleep(time_objective_sleep)
	objective_f = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_F")
end

-- adds mission objective
function Show_Objective_G()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_G_ADD"} )
	-- transition center screen text to objectives list
	objective_f_target.Highlight_Small(true)
	for i, unit in pairs(objective_g_target) do
		unit.Highlight_Small(true)
	end
	Sleep(time_objective_sleep)
	objective_g = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_G")
end

-- adds mission objective
function Show_Objective_H()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_H_ADD"} )
	-- transition center screen text to objectives list
	objective_h_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_h_target, neutral)
	Add_Radar_Blip(objective_h_target, "DEFAULT", "blip_objective_h")
	objective_h_target.Highlight(true)
	Sleep(time_objective_sleep)
	objective_h = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_H")
	Register_Prox(objective_h_target, Prox_Objective_H, 50, aliens)
end

function Prox_Objective_H(prox_obj,trigger_obj)
	-- Check to make sure the object is alive and not a hardpoint
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Type()==Find_Object_Type("ALIEN_LOST_ONE") then
			objective_h_completed=true
			prox_obj.Cancel_Event_Object_In_Range(Prox_Objective_H)
		end
	end
end

-- adds mission objective
function Show_Objective_I()
	objective_i_target.Add_Reveal_For_Player(aliens)
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_I_ADD"} )
	-- transition center screen text to objectives list
	Add_Radar_Blip(objective_i_target, "DEFAULT", "blip_objective_i")
	objective_i_target.Highlight_Small(true)
	Sleep(time_objective_sleep)
	objective_i = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_I")
	Register_Prox(objective_i_target, Prox_Objective_I, 200, aliens)
end

function Prox_Objective_I(prox_obj,trigger_obj)
	-- Check to make sure the object is alive and not a hardpoint
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Type()==Find_Object_Type("ALIEN_LOST_ONE") then
			if trigger_obj.Has_Attack_Target() then
				if trigger_obj.Get_Attack_Target().Get_Type()==Find_Object_Type("TUT03_HUMMER_INSIGNIFICANT") then
					objective_i_completed=true
					prox_obj.Cancel_Event_Object_In_Range(Prox_Objective_I)
				end
			else
				objective_i_failed=true
			end
		end
	end
end

-- adds mission objective
function Show_Objective_J()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_J_ADD"} )
	-- transition center screen text to objectives list
	objective_j_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_j_target, neutral)
	objective_j_target.Highlight(true)
	Sleep(time_objective_sleep)
	objective_j = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_J")
	Register_Prox(objective_j_target, Prox_Objective_J, 50, aliens)
end

function Prox_Objective_J(prox_obj,trigger_obj)
	-- Check to make sure the object is alive and not a hardpoint
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Type()==Find_Object_Type("ALIEN_LOST_ONE") then
			if trigger_obj.Is_Moving() then
				if not trigger_obj.Is_Moving_Using_Flag("No_Formup") then
					objective_j_completed=true
					prox_obj.Cancel_Event_Object_In_Range(Prox_Objective_J)
				else
					objective_j_failed=true
				end
			else
				objective_j_failed=true
			end
		end
	end
end

-- adds mission objective
function Show_Objective_K()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_K_ADD"} )
	-- transition center screen text to objectives list
	objective_k_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_k_target, neutral)
	objective_k_target.Highlight(true)
	Sleep(time_objective_sleep)
	objective_k = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_K")
	Register_Prox(objective_k_target, Prox_Objective_K, 50, aliens)
end

function Prox_Objective_K(prox_obj,trigger_obj)
	-- Check to make sure the object is alive and not a hardpoint
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Type()==Find_Object_Type("ALIEN_LOST_ONE") then
			if trigger_obj.Is_Moving() then
				if trigger_obj.Is_Moving_Using_Flag("No_Formup") then
					objective_k_completed=true
					prox_obj.Cancel_Event_Object_In_Range(Prox_Objective_K)
				else
					objective_k_failed=true
				end
			else
				objective_k_failed=true
			end
		end
	end
end

-- adds mission objective
function Show_Objective_L()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_L_ADD"} )
	-- transition center screen text to objectives list
	objective_l_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_l_target, neutral)
	Add_Radar_Blip(objective_l_target, "DEFAULT", "blip_objective_l")
	objective_l_target.Highlight(true)
	Sleep(time_objective_sleep)
	objective_l = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_L")
	Register_Prox(objective_l_target, Prox_Objective_L, 75, aliens)
end

function Prox_Objective_L(prox_obj,trigger_obj)
	-- Check to make sure the object is alive and not a hardpoint
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Type()==Find_Object_Type("ALIEN_LOST_ONE") then
			if radar_map_right_clicked then 
				objective_l_completed=true
				prox_obj.Cancel_Event_Object_In_Range(Prox_Objective_L)
			else
				objective_l_failed=true
				radar_map_right_clicked=false
			end
		end
	end
end

-- adds mission objective
function Show_Objective_M()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_M_ADD"} )
	-- transition center screen text to objectives list
	objective_m_target.Highlight(true,-30)
	Sleep(time_objective_sleep)
	objective_m = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_M")
end

-- adds mission objective
function Show_Objective_N()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_N_ADD"} )
	-- transition center screen text to objectives list
	-- display highlights, radar blips, and ground decals associated with objective
	objective_n_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_n_target, neutral)
	--Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	objective_n_target.Highlight(true)
	UI_Start_Flash_Queue_Buttons("ALIEN_WALKER_HABITAT")
	Sleep(time_objective_sleep)
	objective_n = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_N")
end

-- adds mission objective
function Show_Objective_O()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_O_ADD"} )
	-- transition center screen text to objectives list
	-- display highlights, radar blips, and ground decals associated with objective
	--objective_a_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_a_location, neutral)
	--Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	--objective_a_location.Highlight(true)
	Sleep(time_objective_sleep)
	objective_o = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_O")
end

-- adds mission objective
function Show_Objective_P()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_P_ADD"} )
	-- transition center screen text to objectives list
	-- display highlights, radar blips, and ground decals associated with objective
	--objective_a_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_a_location, neutral)
	--Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	hp_obj=Find_First_Object("Alien_Walker_Habitat_BACK_HP00")
	--hardpoint=hp_obj.Get_Bone_Position("HP_Side_00")
	hp_obj.Highlight(true,"HP_Side_00",-60)
	UI_Start_Flash_Queue_Buttons("Alien_Walker_Habitat_HP_Lost_One_Mutator")
	Sleep(time_objective_sleep)
	objective_p = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_P")
end

-- adds mission objective
function Show_Objective_Q()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_Q_ADD"} )
	-- transition center screen text to objectives list
	-- display highlights, radar blips, and ground decals associated with objective
	--objective_a_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_a_location, neutral)
	--Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	--objective_a_location.Highlight(true)
	Sleep(time_objective_sleep)
	objective_q = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_Q")
end

-- adds mission objective
function Show_Objective_R()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_R_ADD"} )
	-- transition center screen text to objectives list
	-- display highlights, radar blips, and ground decals associated with objective
	--objective_a_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_a_location, neutral)
	--Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	--objective_a_location.Highlight(true)
	UI_Start_Flash_Queue_Buttons("ALIEN_LOST_ONE")
	Sleep(time_objective_sleep)
	objective_r = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_R")
end

-- adds mission objective
function Show_Objective_S()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_S_ADD"} )
	-- transition center screen text to objectives list
	-- display highlights, radar blips, and ground decals associated with objective
	--objective_a_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_a_location, neutral)
	--Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	objective_s_target_b.Highlight_Small(true)
	UI_Start_Flash_Queue_Buttons("Lost_One_Plasma_Bomb_Unit_Ability")
	Sleep(time_objective_sleep)
	objective_s = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_S")
end

-- adds mission objective
function Show_Objective_T()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_T_ADD"} )
	-- transition center screen text to objectives list
	-- display highlights, radar blips, and ground decals associated with objective
	--objective_a_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_a_location, neutral)
	--Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	--objective_a_location.Highlight(true)
	Sleep(time_objective_sleep)
	objective_t = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_T")
end

-- adds mission objective
function Show_Objective_U()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_U_ADD"} )
	-- transition center screen text to objectives list
	-- display highlights, radar blips, and ground decals associated with objective
	--objective_a_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_a_location, neutral)
	--Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	--objective_a_location.Highlight(true)
	Sleep(time_objective_sleep)
	objective_u = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_U")
end

-- adds mission objective
function Show_Objective_V()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_V_ADD"} )
	-- transition center screen text to objectives list
	-- display highlights, radar blips, and ground decals associated with objective
	--objective_a_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_a_location, neutral)
	--Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	--objective_a_location.Highlight(true)
	Sleep(time_objective_sleep)
	objective_v = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_V")
end

-- adds mission objective
function Show_Objective_W()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_W_ADD"} )
	-- transition center screen text to objectives list
	-- display highlights, radar blips, and ground decals associated with objective
	--objective_a_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_a_location, neutral)
	--Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	--objective_a_location.Highlight(true)
	Sleep(time_objective_sleep)
	objective_w = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_W")
end

-- adds mission objective
function Show_Objective_X()
	-- display objective center screen
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT03_OBJECTIVE_X_ADD"} )
	-- transition center screen text to objectives list
	-- display highlights, radar blips, and ground decals associated with objective
	--objective_a_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_a_location, neutral)
	--Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	--objective_a_location.Highlight(true)
	UI_Start_Flash_Queue_Buttons("Grey_Phase_Unit_Ability")
	Sleep(time_objective_sleep)
	objective_x = Add_Objective("TEXT_SP_MISSION_TUT03_OBJECTIVE_X")
end


--*************************************** END MISSION FUNCTIONS **************************************************************

function Thread_Mission_Complete()
	mission_success = true --this flag is what I check to make sure no game logic continues when the mission is over
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
	Play_Music("Alien_Win_Tactical_Event") -- this music is faction specific, use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,90)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
	Sleep(time_objective_sleep)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(0)
	Force_Victory(aliens)
end

function Force_Victory(player)
	if player == aliens then
		-- Inform the campaign script of our victory.
		global_script.Call_Function("Alien_Tactical_Mission_Over", true) -- true == player wins/false == player loses
		--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
		Quit_Game_Now(player, false, true, false)
	else
		Quit_Game_Now(player, false, true, false)
	end
end

function Post_Load_Callback()
	UI_Hide_Sell_Button()
end

