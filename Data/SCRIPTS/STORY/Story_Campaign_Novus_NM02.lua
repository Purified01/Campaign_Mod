-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM02.lua#74 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM02.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: James_Yarrow $
--
--            $Change: 86943 $
--
--          $DateTime: 2007/10/30 13:22:14 $
--
--          $Revision: #74 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGMoveUnits")
require("PGColors")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")
require("PGSpawnUnits")
require("PGAchievementAward")
require("PGHintSystemDefs")
require("PGHintSystem")
require("Story_Campaign_Hint_System")
require("RetryMission")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	alienstwo = Find_Player("Alien_ZM06_KamalRex")
	masari = Find_Player("Masari")
	novustwo = Find_Player("NovusTwo")

	PGColors_Init_Constants()
--	aliens.Enable_Colorization(true, COLOR_RED)
--	uea.Enable_Colorization(true, COLOR_GREEN)
--	novus.Enable_Colorization(true, COLOR_CYAN)
--	novustwo.Enable_Colorization(true, COLOR_BLUE)
		
	dialog_nov_comm = "NI_Comm_Officer_Pip_Head.alo"
	dialog_mirabel = "NH_Mirabel_Pip_Head.alo"
	dialog_viktor = "NH_Viktor_Pip_Head.alo"
	dialog_ohm_robot = "NI_Science_Officer_Pip_Head.alo"
	dialog_nov_science = "NI_Science_Officer_Pip_Head.alo"
	dialog_moore = "MH_Moore_pip_Head.alo"
	dialog_founder = "NH_founder_Pip_Head.alo"
	dialog_vertigo = "NH_Vertigo_Pip_Head.alo"

	novus.Reset_Story_Locks()
	Lock_Objects(true)
	
	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
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
		Register_Hint_Context_Scene(scene)			-- Set the scene to which independant hints will be attached.
		-- ***** HINT SYSTEM *****

		-- Radar Initialization
		local radar_filter_id1 = RadarMap.Add_Filter("Radar_Map_Enable", novus)
		local radar_filter_id2 = RadarMap.Add_Filter("Radar_Map_Allow_Mouse_Input", novus)
		local radar_filter_id3 = RadarMap.Add_Filter("Radar_Map_Show_Terrain", novus)
		local radar_filter_id4 = RadarMap.Add_Filter("Radar_Map_Show_FOW", novus)
		local radar_filter_id5 = RadarMap.Add_Filter("Radar_Map_Show_Owned", novus)
		local radar_filter_id6 = RadarMap.Add_Filter("Radar_Map_Show_Allied", novus)
		local radar_filter_id7 = RadarMap.Add_Filter("Radar_Map_Show_Enemy", novus)
		local radar_filter_id8 = RadarMap.Add_Filter("Radar_Map_Show_Neutral", novus)
		
	uea.Allow_AI_Unit_Behavior(false)
	aliens.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	novustwo.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
			
		Create_Thread("Thread_Mission_Start")
	elseif message == OnUpdate then
	end
end


--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script
function Thread_Mission_Start()
	aliens.Allow_Autonomous_AI_Goal_Activation(false)

	UI_Hide_Research_Button()
	UI_Hide_Sell_Button()
	
	failure_text="TEXT_SP_MISSION_MISSION_FAILED"
	
	hero=Find_Hint("NOVUS_HERO_MECH","mirabel")
	-- heroes nerfed late, so adding damage modifier, Mirabel old health(1800) / Mirabel new health(1000) - 1 = -.45
	--if TestValid(hero) then hero.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.45) end
	if TestValid(hero) then hero.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.65) end -- added a bit more for good measure
	
	Register_Death_Event(hero, Death_Hero)
	
	objective_a_completed=false;
	objective_b_completed=false;
	
	pen_1_opened=false
	pen_2_opened=false
	pen_3_opened=false
	
	midtro_cinematic_done=false;
	
	discovered_glyph=false;
	defilers_killed=false;
	hacked_scan_drone=false;
	civilians_lost=false
	
	civ_runto = Find_Hint("MARKER_GENERIC","civrunto")
	glyph_loc = Find_Hint("MARKER_GENERIC_BLUE","objective00")
	transport_spawn = Find_Hint("MARKER_GENERIC","transportspawn")
	scan_drone = Find_Hint("ALIEN_SCAN_DRONE","scandrone")
	scan_drone.Prevent_All_Fire(true)
	scan_drone.Set_Cannot_Be_Killed(true)
	scan_drone.Suspend_Locomotor(true)
	
	dialogue_found_glyph_done=false
	dialogue_pens_found=false
	dialogue_end_mission_done=false
	dialogue_disable_pens_done=false
		
	mission_success = false
	mission_failure = false
	time_objective_sleep = 5
	time_radar_sleep = 2
	
	uea.Make_Ally(novus)
	novus.Make_Ally(uea)
		
	uea.Make_Ally(novustwo)
	novus.Make_Ally(novustwo)
	aliens.Make_Ally(novustwo)
	aliens.Make_Enemy(civilian)
	alienstwo.Make_Ally(aliens)
	aliens.Make_Ally(alienstwo)
	alienstwo.Make_Ally(novus)
	alienstwo.Make_Enemy(novustwo)
	alienstwo.Make_Ally(uea)
	
	--set low civ population on large maps (esp single player)
	Set_Desired_Civilian_Population(0)
	
	Create_Thread("Setup_Traffic")
	Create_Thread("Setup_Guards")
	Create_Thread("Setup_Pen_Guards_1")
	Create_Thread("Setup_Pen_Guards_2")
	Create_Thread("Setup_Pen_Guards_3")
	Create_Thread("Maintain_Novus_Forces")
	Create_Thread("Setup_Suprise_Mutant_Spawns")
	
	if true then 
		Lock_Controls(1)
		Fade_Screen_Out(0)
		Point_Camera_At(hero)
		Sleep(1)
		Start_Cinematic_Camera()
		Letter_Box_In(0)
		
		Transition_Cinematic_Target_Key(hero, 0, 0, 0, 0, 0, 0, 0, 0)
		Transition_Cinematic_Camera_Key(hero, 0, 200, 55, 65, 1, 0, 0, 0)
		
		Fade_Screen_In(1)
		Transition_To_Tactical_Camera(5)
		Sleep(5)	
		Letter_Box_Out(1)
		Sleep(1)
		Lock_Controls(0)
		End_Cinematic_Camera()
	else
		Point_Camera_At(hero)
		Fade_Screen_In(0)
	end
	
	-- show mission objective a and wait for it to be triggered
	Sleep(1)
	Create_Thread("Dialogue_Investigate_Glyph")
	Show_Objective_A()
	
	while not(objective_a_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if discovered_glyph then
				Objective_Complete(nov02_objective_a)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS02_OBJECTIVE_A_COMPLETE"} )
				Create_Thread("Dialogue_Found_Glyph")
				while not dialogue_found_glyph_done do
					Sleep(1)
				end
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_a_completed=true;
			end
		end
	end
	
	Create_Thread("Midtro_Cinematic")
	while not midtro_cinematic_done do
		Sleep(1)
	end
	
	
	Create_Thread("Dialogue_Find_Source")
	while not dialogue_disable_pens_done do
		Sleep(1)
	end
	
	Create_Thread("Enemy_Shuttles")
	
	Show_Objective_B()
	
	while not(objective_b_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if civilians_freed then
				Objective_Complete(nov02_objective_b)
				--Objective_Complete(nov02_objective_b_civilians)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS02_OBJECTIVE_B_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_b_completed=true;
			end
			--if civilians_lost then
			--	failure_text="TEXT_SP_MISSION_NVS02_OBJECTIVE_B_CIVILIANS_FAIL"
			--	Create_Thread("Thread_Mission_Failed")
			--end
		end
	end
	
	Sleep(1)
	Create_Thread("Dialogue_Scan_Drone")
	Show_Objective_C()
	
	while not(objective_c_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if hacked_scan_drone then
				scan_drone.Highlight(false)
				Objective_Complete(nov02_objective_c)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS02_OBJECTIVE_C_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_c_completed=true;
			end
		end
	end
	
	Create_Thread("Dialogue_End_Mission")
	while not dialogue_end_mission_done do
		Sleep(1)
	end
	
	Create_Thread("Thread_Mission_Complete");
	
end

function Prox_Stop_Shuttle(prox_obj, trigger_obj)
	if trigger_obj.Get_Type()==Find_Object_Type("Alien_Air_Retreat_Transport") then
		trigger_obj.Stop()
		prox_obj.Cancel_Event_Object_In_Range(Prox_Stop_Shuttle)
	end
end

function Enemy_Shuttles()
	mothershipspawns=Find_All_Objects_With_Hint("mothershipspawn")
	mothershipspawnmax=table.getn(mothershipspawns)
	
	dropoffs1={"ALIEN_GRUNT","Alien_Recon_Tank","ALIEN_GRUNT"}
	dropoffs2={"ALIEN_LOST_ONE","ALIEN_BRUTE","ALIEN_LOST_ONE"}
	dropoffs3={"ALIEN_GRUNT","ALIEN_DEFILER","ALIEN_LOST_ONE"}
	
	while (TestValid(hero) and (not mission_complete) and (not mission_defeat) and (not objective_c_completed)) do
		if not alien_transport_enroute then
			mothership=Create_Generic_Object("Alien_Air_Retreat_Transport",mothershipspawns[GameRandom(1,mothershipspawnmax)],aliens)
			mothership.Override_Max_Speed(5)
			Register_Prox(hero, Prox_Stop_Shuttle, 200, aliens)
			--mothership.Set_Selectable(false)
			alien_transport_enroute=true
			while TestValid(mothership) do
				if TestValid(hero) then
					if TestValid(mothership) then
						if mothership.Get_Distance(hero)>400 then
							mothership.Move_To(hero)
						else
							if not objective_c_completed then 
								mothership.Stop()
								choose=GameRandom(1,3)
								if choose==1 then contained=dropoffs1 end
								if choose==2 then contained=dropoffs2 end
								if choose==3 then contained=dropoffs3 end
								
								for i=1,table.getn(contained) do
									object=Create_Generic_Object(Find_Object_Type(contained[i]),mothership,aliens)
									Sleep(.5)
									Hunt(object,"PrioritiesLikeOneWouldExpectThemToBe",false,false)
								end
								if TestValid(mothership) then
									BlockOnCommand(mothership.Move_To(mothershipspawns[GameRandom(1,mothershipspawnmax)]))
									if TestValid(mothership) then
										mothership.Despawn()
									end
								end
							end
						end
					end
				end
				Sleep(3)
			end
			alien_transport_enroute=false
		end
		Sleep(35)
		Sleep(GameRandom(1,5))
	end
end


function Maintain_Novus_Forces()
	transport_enroute=false
	while true do
		hackers=Find_All_Objects_Of_Type("NOVUS_HACKER")
		if not transport_enroute then
			if table.getn(hackers)<1 then
				transport_enroute=true
				Create_Thread("Reinforce_Shuttle",{"NOVUS_HACKER",2})
			end
		end
		variants=Find_All_Objects_Of_Type("NOVUS_VARIANT")
		if not transport_enroute then
			if table.getn(variants)<4 then
				transport_enroute=true
				Create_Thread("Reinforce_Shuttle",{"NOVUS_VARIANT",2})
			end
		end
		Sleep(5)
	end
end

function Reinforce_Shuttle(obj_list)
	obj_type,obj_num=obj_list[1],obj_list[2]
	transport=Create_Generic_Object("Novus_Air_Retreat_Transport",transport_spawn,novus)
	transport.Set_Selectable(false)
	Raise_Game_Event("Reinforcements_Arrived", novus, transport.Get_Position())
	local dropping_off=true
	while dropping_off do
		if TestValid(hero) and TestValid(transport) then
			if transport.Get_Distance(hero)>250 then
				BlockOnCommand(transport.Move_To(hero))
			else
				for i=1, obj_num do
					object=Create_Generic_Object(obj_type,transport,novus)
					Sleep(.5)
				end
				dropping_off=false
			end
		end
		Sleep(1)
	end
	
	if TestValid(transport) then
		BlockOnCommand(transport.Move_To(transport_spawn))
		if TestValid(transport) then
			transport.Despawn()
		end
		transport_enroute=false
	else
		transport_enroute=false
	end
end

function Setup_Traffic()
	if true then
		carpath_0_start = Find_Hint("MARKER_GENERIC_YELLOW","carpath0start")
		carpath_1_start = Find_Hint("MARKER_GENERIC_YELLOW","carpath1start")
		carpath_2_start = Find_Hint("MARKER_GENERIC_YELLOW","carpath2start")
		carpath_3_start = Find_Hint("MARKER_GENERIC_YELLOW","carpath3start")
		carpath_0_end = Find_Hint("MARKER_GENERIC_YELLOW","carpath0end")
		carpath_1_end = Find_Hint("MARKER_GENERIC_YELLOW","carpath1end")
		carpath_2_end = Find_Hint("MARKER_GENERIC_YELLOW","carpath2end")
		carpath_3_end = Find_Hint("MARKER_GENERIC_YELLOW","carpath3end")
		car_path_start_list = {}
		car_path_end_list = {}
		car_path_start_list [1] = carpath_0_start
		car_path_start_list [2] = carpath_1_start
		car_path_start_list [3] = carpath_2_start
		car_path_start_list [4] = carpath_3_start
		car_path_end_list [1] = carpath_0_end
		car_path_end_list [2] = carpath_1_end
		car_path_end_list [3] = carpath_2_end
		car_path_end_list [4] = carpath_3_end
	end
	while allow_act1_events do
		if current_car_population < total_car_population  then
			local vehicle_01_offset = GameRandom(1,4)
			if GameRandom(1,10) > 4 then
				civilian_vehicle_01 = Spawn_Unit(Find_Object_Type("Civilian_Pickup_Truck_01_Mobile"), car_path_start_list[vehicle_01_offset], civilian, false)
			else
				civilian_vehicle_01 = Spawn_Unit(Find_Object_Type("Civilian_Station_Wagon_01_Mobile"), car_path_start_list[vehicle_01_offset], civilian, false)
			end
			current_car_population = current_car_population + 1
			civilian_vehicle_01.Move_To(car_path_end_list [vehicle_01_offset])
			civilian_vehicle_01.Register_Signal_Handler(Callback_Civilian_Vehicle_At_Destination, "OBJECT_MOVEMENT_FINISHED")
		end
		Sleep(GameRandom(2,8))
	end
end

function Callback_Civilian_Vehicle_At_Destination(callback_obj)
	if TestValid(callback_obj) then
		current_car_population = current_car_population - 1
		callback_obj.Despawn()
	end
end

function Setup_Guards()
	guards=Find_All_Objects_With_Hint("guard")
	for i,unit in pairs(guards) do
		unit.Set_Service_Only_When_Rendered(true)
		Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", true, true, unit, 250)
	end
end

function Setup_Pen_Guards_1()
	defilers1={"ALIEN_DEFILER","ALIEN_DEFILER"}
	lostones1={"ALIEN_LOST_ONE","ALIEN_LOST_ONE"}
	
	penguard1=Find_Hint("MARKER_GENERIC_PURPLE","1")
	pen_trigger1=Find_Hint("MARKER_GENERIC_BLACK","1")

	defiler_list1=SpawnList(defilers1, penguard1, aliens, false, true, false)
	lostone_list1=SpawnList(lostones1, penguard1, aliens, false, true, false)

	pen_obj1=Find_Hint("NM02_CIVILIAN_PEN","1")
	targetb1=Find_Hint("MARKER_GENERIC_RED","1")
	targetc1=Find_Hint("MARKER_GENERIC_BLACK","1")
	
	defilers_max1=table.getn(defiler_list1)
	lostones_max1=table.getn(lostone_list1)
	Hunt(lostone_list1,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard1,100)
	Hunt(defiler_list1,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard1,200)
	
	while not objective_a_completed do -- unlocks the rest at the right time
		Sleep(1)
	end
	
	Register_Prox(pen_trigger1,Prox_Pen_Disable_1,60,novus)
	
	Add_Radar_Blip(pen_trigger1, "DEFAULT", "pen_one")
	pen_trigger1.Highlight(true)
	pen_trigger_area1=Create_Generic_Object(Find_Object_Type("Highlight_Area"), pen_trigger1, neutral)
	
	team_intact1=true
	
	while team_intact1 do
		defilers_num1=0
		lostones_num1=0
		for g, unit in pairs(defiler_list1) do
			if TestValid(unit) then
				defilers_num1=defilers_num1+1
			end
		end
		for g, unit in pairs(lostone_list1) do
			if TestValid(unit) then
				lostones_num1=lostones_num1+1
			end
		end
		if not TestValid(pen_obj1) then
			if lostones_num1<lostones_max1 then
				team_intact1=false
				for g, unit in pairs(defiler_list1) do
					Create_Thread("Defiler_Brutality",{unit,targetb1})
				end
				Hunt(lostone_list1,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard1,200)
			end
			if defilers_num1<defilers_max1 then
				team_intact1=false
				for g, unit in pairs(lostone_list1) do
					Create_Thread("Lost_One_Brutality",{unit,targetb1})
				end
				Hunt(defiler_list1,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard1,200)
			end
		end
		Sleep(GameRandom(1,3))
	end
end

function Prox_Pen_Disable_1(prox_obj, trigger_obj)
	if trigger_obj.Get_Type()==Find_Object_Type("NOVUS_HERO_MECH") then
		pen_trigger1.Highlight(false)
		if TestValid(pen_trigger_area1) then pen_trigger_area1.Despawn() end
		Remove_Radar_Blip("pen_one")
		Create_Thread("Turn_Off_Pen_1")
		prox_obj.Cancel_Event_Object_In_Range(Prox_Pen_Disable_1)
	end
end

function Turn_Off_Pen_1()
	pen_1_opened=true
	pen_obj1.Play_Animation("ANIM_SPECIAL_A", false, 0)
	--pen_obj1.Undo_Reveal()
	Create_Thread("Track_Pen_Civies", pen_obj1)
	Sleep(2)
	pen_off1 = Create_Generic_Object("NM02_CIVILIAN_PEN_OFF", pen_obj1, aliens)
	pen_off1.Teleport_And_Face(pen_obj1)
	pen_obj1.Despawn()
end

function Setup_Pen_Guards_2()
	defilers2={"ALIEN_DEFILER","ALIEN_DEFILER"}
	lostones2={"ALIEN_LOST_ONE","ALIEN_LOST_ONE"}
	
	penguard2=Find_Hint("MARKER_GENERIC_PURPLE","2")
	pen_trigger2=Find_Hint("MARKER_GENERIC_BLACK","2")

	defiler_list2=SpawnList(defilers2, penguard2, aliens, false, true, false)
	lostone_list2=SpawnList(lostones2, penguard2, aliens, false, true, false)

	pen_obj2=Find_Hint("NM02_CIVILIAN_PEN","2")
	targetb2=Find_Hint("MARKER_GENERIC_RED","2")
	targetc2=Find_Hint("MARKER_GENERIC_BLACK","2")
	
	defilers_max2=table.getn(defiler_list2)
	lostones_max2=table.getn(lostone_list2)
	Hunt(lostone_list2,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard2,100)
	Hunt(defiler_list2,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard2,200)
	
	while not objective_a_completed do -- unlocks the rest at the right time
		Sleep(1)
	end
	
	Register_Prox(pen_trigger2,Prox_Pen_Disable_2,60,novus)
	
	Add_Radar_Blip(pen_trigger2, "DEFAULT", "pen_two")
	pen_trigger2.Highlight(true)
	pen_trigger_area2=Create_Generic_Object(Find_Object_Type("Highlight_Area"), pen_trigger2, neutral)
	
	team_intact2=true
	
	while team_intact2 do
		defilers_num2=0
		lostones_num2=0
		for g, unit in pairs(defiler_list2) do
			if TestValid(unit) then
				defilers_num2=defilers_num2+1
			end
		end
		for g, unit in pairs(lostone_list2) do
			if TestValid(unit) then
				lostones_num2=lostones_num2+1
			end
		end
		if not TestValid(pen_obj2) then
			if lostones_num2<lostones_max2 then
				team_intact2=false
				for g, unit in pairs(defiler_list2) do
					Create_Thread("Defiler_Brutality",{unit,targetb2})
				end
				Hunt(lostone_list2,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard2,200)
			end
			if defilers_num2<defilers_max2 then
				team_intact2=false
				for g, unit in pairs(lostone_list2) do
					Create_Thread("Lost_One_Brutality",{unit,targetb2})
				end
				Hunt(defiler_list2,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard2,200)
			end
		end
		Sleep(GameRandom(1,3))
	end
end

function Prox_Pen_Disable_2(prox_obj, trigger_obj)
	if trigger_obj.Get_Type()==Find_Object_Type("NOVUS_HERO_MECH") then
		pen_trigger2.Highlight(false)
		if TestValid(pen_trigger_area2) then pen_trigger_area2.Despawn() end
		Remove_Radar_Blip("pen_two")
		Create_Thread("Turn_Off_Pen_2")
		prox_obj.Cancel_Event_Object_In_Range(Prox_Pen_Disable_2)
	end
end

function Turn_Off_Pen_2()
	pen_2_opened=true
	pen_obj2.Play_Animation("ANIM_SPECIAL_A", false, 0)
	--pen_obj2.Undo_Reveal()
	Create_Thread("Track_Pen_Civies", pen_obj2)
	Sleep(2)
	pen_off2 = Create_Generic_Object("NM02_CIVILIAN_PEN_OFF", pen_obj2, aliens)
	pen_off2.Teleport_And_Face(pen_obj2)
	pen_obj2.Despawn()
end

function Setup_Pen_Guards_3()
	defilers3={"ALIEN_DEFILER","ALIEN_DEFILER"}
	lostones3={"ALIEN_LOST_ONE","ALIEN_LOST_ONE"}
	
	penguard3=Find_Hint("MARKER_GENERIC_PURPLE","3")
	pen_trigger3=Find_Hint("MARKER_GENERIC_BLACK","3")

	defiler_list3=SpawnList(defilers3, penguard3, aliens, false, true, false)
	lostone_list3=SpawnList(lostones3, penguard3, aliens, false, true, false)

	pen_obj3=Find_Hint("NM02_CIVILIAN_PEN","3")
	targetb3=Find_Hint("MARKER_GENERIC_RED","3")
	targetc3=Find_Hint("MARKER_GENERIC_BLACK","3")
	
	defilers_max3=table.getn(defiler_list3)
	lostones_max3=table.getn(lostone_list3)
	Hunt(lostone_list3,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard3,100)
	Hunt(defiler_list3,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard3,200)
	
	while not objective_a_completed do -- unlocks the rest at the right time
		Sleep(1)
	end
	
	Register_Prox(pen_trigger3,Prox_Pen_Disable_3,60,novus)
	
	Add_Radar_Blip(pen_trigger3, "DEFAULT", "pen_three")
	pen_trigger3.Highlight(true)
	pen_trigger_area3=Create_Generic_Object(Find_Object_Type("Highlight_Area"), pen_trigger3, neutral)
	
	team_intact3=true
	
	while team_intact3 do
		defilers_num3=0
		lostones_num3=0
		for g, unit in pairs(defiler_list3) do
			if TestValid(unit) then
				defilers_num3=defilers_num3+1
			end
		end
		for g, unit in pairs(lostone_list3) do
			if TestValid(unit) then
				lostones_num3=lostones_num3+1
			end
		end
		if not TestValid(pen_obj3) then
			if lostones_num3<lostones_max3 then
				team_intact3=false
				for g, unit in pairs(defiler_list3) do
					Create_Thread("Defiler_Brutality",{unit,targetb3})
				end
				Hunt(lostone_list3,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard3,200)
			end
			if defilers_num3<defilers_max3 then
				team_intact3=false
				for g, unit in pairs(lostone_list3) do
					Create_Thread("Lost_One_Brutality",{unit,targetb3})
				end
				Hunt(defiler_list3,"PrioritiesLikeOneWouldExpectThemToBe",true,false,penguard3,200)
			end
		end
		Sleep(GameRandom(1,3))
	end
end

function Prox_Pen_Disable_3(prox_obj, trigger_obj)
	if trigger_obj.Get_Type()==Find_Object_Type("NOVUS_HERO_MECH") then
		pen_trigger3.Highlight(false)
		if TestValid(pen_trigger_area3) then pen_trigger_area3.Despawn() end
		Remove_Radar_Blip("pen_three")
		Create_Thread("Turn_Off_Pen_3")
		prox_obj.Cancel_Event_Object_In_Range(Prox_Pen_Disable_3)
	end
end

function Turn_Off_Pen_3()
	pen_3_opened=true
	pen_obj3.Play_Animation("ANIM_SPECIAL_A", false, 0)
	--pen_obj3.Undo_Reveal()
	Create_Thread("Track_Pen_Civies", pen_obj3)
	Sleep(2)
	pen_off3 = Create_Generic_Object("NM02_CIVILIAN_PEN_OFF", pen_obj3, aliens)
	pen_off3.Teleport_And_Face(pen_obj3)
	pen_obj3.Despawn()
end

function Track_Pen_Civies(pen_obj)
	local pen_civies=Find_All_Objects_Of_Type(pen_obj.Get_Position(),200,civilian)
	while TestValid(pen_obj) do Sleep(1) end
	if TestValid(pen_obj) then Make_Civilians_Panic(pen_obj,150) end
	Sleep(12) -- time it takes for a defiler or grey to intercept
	for k, unit in pairs(pen_civies) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(false)
			unit.Move_To(civ_runto)
		end
	end
end

function Defiler_Brutality(list)
	local unit,targetb=list[1],list[2]
	if TestValid(unit) then
		if TestValid(targetb) then
			if not unit.Is_Ability_Active("Defiler_Radiation_Bleed") then
				--BlockOnCommand(unit.Activate_Ability("Defiler_Radiation_Bleed", true))
				unit.Activate_Ability("Defiler_Radiation_Bleed", true)
			end
			Sleep(1)
			BlockOnCommand(unit.Move_To(targetb.Get_Position()))
		end
		Sleep(1)
		local pen_zombies=Find_All_Objects_Of_Type("ALIEN_MUTANT_SLAVE")
		Hunt(pen_zombies,"PrioritiesLikeOneWouldExpectThemToBe",false,false)
		local pen_zombies=Find_All_Objects_Of_Type("ALIEN_MUTANT_SLAVE_COW")
		Hunt(pen_zombies,"PrioritiesLikeOneWouldExpectThemToBe",false,false)
		local pen_zombies=Find_All_Objects_Of_Type("ALIEN_MUTANT_SLAVE_02")
		Hunt(pen_zombies,"PrioritiesLikeOneWouldExpectThemToBe",false,false)
		local pen_zombies=Find_All_Objects_Of_Type("ALIEN_MUTANT_SLAVE_03")
		Hunt(pen_zombies,"PrioritiesLikeOneWouldExpectThemToBe",false,false)
		if TestValid(unit) then Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",false,false) end
		
	end
end

function Lost_One_Brutality(list)
	local unit,targetb=list[1],list[2]
	if TestValid(unit) then
		if TestValid(targetb) then
			Sleep(GameRandom(0,3))
			if TestValid(unit) then unit.Activate_Ability("Grey_Phase_Unit_Ability",true) end
			if TestValid(unit) then	BlockOnCommand(unit.Move_To(targetb.Get_Position())) end
			if TestValid(unit) then unit.Activate_Ability("Grey_Phase_Unit_Ability",false) end
			Sleep(1)
			if TestValid(unit) then BlockOnCommand(unit.Activate_Ability("Lost_One_Plasma_Bomb_Unit_Ability",true, targetb.Get_Position(),true)) end
			Sleep(1)
		end
		if TestValid(unit) then	Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",false,false) end
	end
end

-- adds mission objective for objective A
function Show_Objective_A()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS02_OBJECTIVE_A_ADD"} )
	Sleep(time_objective_sleep)
	nov02_objective_a = Add_Objective("TEXT_SP_MISSION_NVS02_OBJECTIVE_A")
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Add_Radar_Blip(glyph_loc, "DEFAULT", "nov02_objective_a")
	Register_Prox(glyph_loc, Prox_Glyph, 280, novus)
end

function Prox_Glyph(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner()==novus then
		discovered_glyph=true
		Remove_Radar_Blip("nov02_objective_a")
		Create_Thread("Military_Attackers_Spawn")
		prox_obj.Cancel_Event_Object_In_Range(Prox_Glyph)
	end
end

function Midtro_Cinematic()
	Allow_Localized_SFX(false)
	SFXManager.Allow_Ambient_VO( false )
	Weather_Audio_Pause(true)
	Fade_Out_Music()
	
	--Lock the user out during the fade to prevent any input that could put
	--us in a strange state (e.g. battlecam)
	Lock_Controls(1)
	Fade_Screen_Out(2)
	Sleep(2)
	
	glyph=Find_All_Objects_With_Hint("glyph")
	glyph[1].Despawn()
	
	--Release the control lock so the movie can be skipped if necessary
	Lock_Controls(0)
	BlockOnCommand(Play_Bink_Movie("Novus_M2_S3",true)) 
	
	hero.Teleport_And_Face(glyph_loc)
	hackers=Find_All_Objects_Of_Type("NOVUS_HACKER")
	for i, unit in pairs(hackers) do
		if TestValid(unit) then
			unit.Teleport_And_Face(glyph_loc)
		end
	end
	xspawns=Find_All_Objects_With_Hint("xdef")
	for i, unit in pairs(xspawns) do
		if TestValid(unit) then
			def=Create_Generic_Object("ALIEN_DEFILER", unit, aliens)
			def.Attack_Target(hero)
		end
	end
	
	Fade_Screen_In(2)
	Sleep(1)
	Allow_Localized_SFX(true)
	SFXManager.Allow_Ambient_VO( true )
	Weather_Audio_Pause(false)
	midtro_cinematic_done=true
end

function Military_Attackers_Spawn()
	attackers={"MILITARY_TEAM_ROCKETLAUNCHER_SPAWNER", "Military_Team_Marines_Spawner", "Military_Team_Marines_Spawner"}
	spawns=Find_All_Objects_With_Hint("militaryspawn")
	
	spawnpoint=spawns[4]
	moore=Create_Generic_Object("MILITARY_HERO_GENERAL_RANDAL_MOORE",spawnpoint,uea)
	moore.Set_Cannot_Be_Killed(true) -- 
	Register_Death_Event(moore, Death_Hero)
	--Hunt(moore, "NM02_Military_Hunt_Group_Priorities", false, true, hero, 500)
	if TestValid(hero) then moore.Guard_Target(hero) end
	while true do
		the_military=Find_All_Objects_Of_Type(uea, "CanAttack")
		if table.getn(the_military)<5 then 
			for j, type in pairs(attackers) do
				if (GameRandom(1,2)<2) then
					spawnpoint=spawns[GameRandom(1,table.getn(spawns))]
					milunit=Create_Generic_Object(type,spawnpoint.Get_Position(),uea)
					Sleep(GameRandom(1,2))
				end
			end
		end
		the_military=Find_All_Objects_Of_Type(uea, "CanAttack")
		if dialogue_disable_pens_done then
			for ji, junit in pairs(the_military) do
				if not pen_3_opened then
					if TestValid(pen_obj3) and team_intact3 then junit.Attack_Move(hero.Get_Position()) end
				else 
					if not pen_2_opened then
						if TestValid(pen_obj2) and team_intact2 then junit.Attack_Move(hero.Get_Position()) end
					else
						if not pen_1_opened then
							if TestValid(pen_obj1) and team_intact1 then junit.Attack_Move(hero.Get_Position()) end
						else
							if TestValid(scan_drone) then junit.Attack_Move(scan_drone.Get_Position()) end
						end
					end
				end
			end
		end
		
		Sleep(GameRandom(5,20))
	end
end

-- adds mission objective for objective B
function Show_Objective_B()
	--nov02_objective_b_civilians = Add_Objective("TEXT_SP_MISSION_NVS02_OBJECTIVE_B_CIVILIANS")
	--Create_Thread("Track_Objective_B_Civilians")
	--Create_Thread("Setup_Civilian_Pens")
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS02_OBJECTIVE_B_ADD"} )
	Sleep(time_objective_sleep)
	nov02_objective_b = Add_Objective("TEXT_SP_MISSION_NVS02_OBJECTIVE_B")
	Create_Thread("Track_Objective_B")
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	
	penreveals=Find_All_Objects_Of_Type("NM02_CIVILIAN_PEN")
	for i, pen in pairs(penreveals) do
		civvies = FogOfWar.Reveal(novus, pen, 200, 200)
		pen.Add_Reveal_For_Player(novus)
	end
end

function Track_Objective_B()
	civilian_pens_max=table.getn(Find_All_Objects_Of_Type("NM02_CIVILIAN_PEN"))
	civilian_pens_last=civilian_pens_max+1
	while not objective_b_completed do
		civilian_pens_left=Find_All_Objects_Of_Type("NM02_CIVILIAN_PEN")
		if table.getn(civilian_pens_left) < civilian_pens_last then
			civilian_pens_freed=civilian_pens_max-table.getn(civilian_pens_left)
			civilian_pens_last=table.getn(civilian_pens_left)
			Out_string = Get_Game_Text("TEXT_SP_MISSION_NVS02_OBJECTIVE_B")
			Out_string = Replace_Token(Out_string, Get_Localized_Formatted_Number(civilian_pens_freed), 1)
			Out_string = Replace_Token(Out_string, Get_Localized_Formatted_Number(civilian_pens_max), 2)
			Set_Objective_Text(nov02_objective_b, Out_string)
		end
		if table.getn(civilian_pens_left)==0 then
			civilians_freed=true
		end
		Sleep(1)
	end
end



function Setup_Suprise_Mutant_Spawns()
	mutant_spawns=Find_All_Objects_With_Hint("mutantspawn")
	for f, spot in pairs(mutant_spawns) do
		if TestValid(spot) then
			Register_Prox(spot, Prox_Mutant_Spawn, 125, novus)
		end
	end
end

function Prox_Mutant_Spawn(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner()==novus then
		if not objective_c_completed then
			Create_Thread("Mutant_Spawn",prox_obj)
		end
	end
	prox_obj.Cancel_Event_Object_In_Range(Prox_Mutant_Spawn)
end

function Mutant_Spawn(spot)
	for m=1, 5 do
		mutant=Create_Generic_Object("ALIEN_MUTANT_SLAVE",spot,aliens)
		if TestValid(hero) then 
			mutant.Attack_Move(hero)
		end
		Sleep(1)
	end
end

-- adds mission objective for objective D
function Show_Objective_C()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS02_OBJECTIVE_C_ADD"} )
	Sleep(time_objective_sleep)
	nov02_objective_c = Add_Objective("TEXT_SP_MISSION_NVS02_OBJECTIVE_C")
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Add_Radar_Blip(scan_drone, "DEFAULT", "nov02_objective_c")
	scan_drone.Highlight(true)
	Register_Prox(scan_drone, Prox_Hacker_To_Scan_Drone, 150, novus)
end

function Prox_Hacker_To_Scan_Drone(prox_obj, trigger_obj)
	if trigger_obj.Get_Type() == Find_Object_Type("NOVUS_HACKER") then
		Remove_Radar_Blip("nov02_objective_c")
		trigger_obj.Stop()
		trigger_obj.Change_Owner(novustwo)
		trigger_obj.Make_Invulnerable(true)
		trigger_obj.Set_Selectable(false)
		if TestValid(prox_obj) then
			trigger_obj.Attack_Target(prox_obj)
		end
		hacked_scan_drone=true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Hacker_To_Scan_Drone)
	end
end



--on hero death, force defeat
function Death_Hero()
	Queue_Talking_Head(dialog_nov_comm, "NVS01_SCENE06_14")
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"
	Create_Thread("Thread_Mission_Failed")
end

--on hero death, force defeat
function Death_Moore()
	if TestValid(hero) then
		Queue_Talking_Head(dialog_mirabel, "NVS05_SCENE03_18")
		failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MOORE"
		Create_Thread("Thread_Mission_Failed")
	end
end

function Thread_Mission_Failed()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
			
   mission_failure = true --this flag is what I check to make sure no game logic continues when the mission is over
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
   Force_Victory(aliens) 
end

function Thread_Mission_Complete()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
			
      mission_success = true --this flag is what I check to make sure no game logic continues when the mission is over
      Letter_Box_In(1)
      --Lock_Controls(1)
      --Suspend_AI(1)
      Disable_Automatic_Tactical_Mode_Music()
-- this music is faction specific, 
-- use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
      Play_Music("Novus_Win_Tactical_Event")
      --Zoom_Camera.Set_Transition_Time(10)
      --Zoom_Camera(.3)
      Rotate_Camera_By(180,90)
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
      Sleep(time_objective_sleep)
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
      Fade_Screen_Out(2)
      Sleep(2)
      Lock_Controls(0)
      Force_Victory(novus)
end

-- below are the various functions used in this script
function Force_Victory(player)
		if player == novus then
			Lock_Objects(false)
			novus.Reset_Story_Locks()
			
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

-- here is where objects are locked or unlocked for the tactical game
function Lock_Objects(boolean)
		novus.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Viral_Bomb_Unit_Ability", boolean, STORY)
		
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
		
		novus.Lock_Object_Type(Find_Object_Type("Novus_Vehicle_Assembly_Inversion"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("Novus_Aircraft_Assembly_Scramjet"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("Novus_Science_Lab_Upgrade_Singularity_Processor"),boolean,STORY)
		
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Unit_Ability", false, STORY)
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Control_Turret_Area_Special_Ability", false, STORY)
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Special_Ability", false, STORY)
		novus.Lock_Unit_Ability("Novus_Robotic_Infantry", "Robotic_Infantry_Capture", true, STORY)
		novus.Lock_Generator("RoboticInfantryCaptureGenerator", true, STORY)
		
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Kamal_Rex"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Nufai"),boolean,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Hero_Orlok"),boolean,STORY)
		
		aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("ALIEN_LOST_ONE"), "Lost_One_Plasma_Bomb_Ability", false, STORY)
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Grey_Phase_Unit_Ability", false, STORY)
end




--************************************************************************************************************
--***************************************All Talking Head Dialog stuff****************************************
--************************************************************************************************************

--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
--=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+CONVERSATION 01+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

function Dialogue_Investigate_Glyph()
	--Novus Comm (NCO) -- Alert! We have detected sentient forces engaged with the Hierarchy ahead.
	BlockOnCommand(Queue_Talking_Head(dialog_nov_comm, "NVS02_SCENE04_01"))
	--Mirabel (MIR) -- Please highlight destination and provide more data if possible.
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE01_02"))
	--Novus Science (NSC) -- Destroy them.  Data indicates they are contagious, and emitting dangerous radiation.
	BlockOnCommand(Queue_Talking_Head(dialog_nov_science, "NVS02_SCENE03_03"))
	--Mirabel (MIR) -- But (resigned)  It's such a waste.
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE03_04"))
	--Mirabel (MIR) -- Stay alert, we don't want to be surprised by whatever lies ahead.
	--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE01_05"))
end

function Dialogue_Found_Glyph()
	--Mirabel (MIR) -- Hold your fire!  Comm, do we have a working translation yet?
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE04_02"))
	--Novus Comm (NCO) -- Partial algorithms established, but our orders are very clear-
	BlockOnCommand(Queue_Talking_Head(dialog_nov_comm, "NVS02_SCENE04_03"))
	--Mirabel (MIR) -- As field commander, I'm overriding those orders! They are being overwhelmed by contaminated sentients.
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE04_04"))
	dialogue_found_glyph_done=true
end

function Dialogue_Find_Source()
	--Mirabel (MIR) -- We need to find the source of the contamination.
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE03_06"))
	--Col. Moore (MOO) -- Our recon shows those alien bastards suckin' up the locals with some walking structure then spittin' them out in these pens.
	BlockOnCommand(Queue_Talking_Head(dialog_moore, "NVS02_SCENE06_01"))
	dialogue_disable_pens_done=true
	--Mirabel (MIR) -- We'll see what we can do.
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE06_05"))
end

function Dialogue_Found_Pen()
	--Ohm Robot (ROB) -- Sir, we're approaching another sentient holding pen.
	BlockOnCommand(Queue_Talking_Head(dialog_ohm_robot, "NVS02_SCENE05_01"))
	--Viktor (VIK) -- (Unintelligible)
	BlockOnCommand(Queue_Talking_Head(dialog_viktor, "NVS02_SCENE05_02"))
	--Mirabel (MIR) -- But these sentients are not contaminated yet.  We need to free them.
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE05_03"))
	--Mirabel (MIR) -- Destroy the cage before the hierarchy come back and infect them.
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE05_04"))
	Add_Independent_Hint(HINT_NM02_HACKER_FIREWALL)
end

function Dialogue_Scan_Drone()
	--Novus Comm (NCO) -- Sir, the Hierarchy base has been detected to the east of your current location.
	BlockOnCommand(Queue_Talking_Head(dialog_nov_comm, "NVS02_SCENE07_01"))
	--Mirabel (MIR) -- What kind of resistance are we looking at?
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE07_02"))
	--Novus Comm (NCO) -- It appears to be a fairly small outpost.  Our target is the Detection Drone.  Hacking into it should provide us with useful data on the Hierarchy's operations.
	BlockOnCommand(Queue_Talking_Head(dialog_nov_comm, "NVS02_SCENE07_03"))
	--Mirabel (MIR) -- Understood.  Hacker in transit to Detection Drone.
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE07_04"))
end

function Dialogue_End_Mission()
	location=Find_Hint("MARKER_GENERIC","endcamera")
	hero.Prevent_All_Fire(true)
	hero.Make_Invulnerable(true)
	hero.Move_To(location)

	militaryguys=Find_All_Objects_Of_Type(uea, "CanAttack")
	for j, unit in pairs(militaryguys) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(true)
		end
	end
	alienguys=Find_All_Objects_Of_Type(aliens, "CanAttack")
	for j, unit in pairs(alienguys) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(true)
		end
	end
	novusguys=Find_All_Objects_Of_Type(novus, "CanAttack")
	for j, unit in pairs(novusguys) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(true)
		end
	end
		
	Suspend_AI(1)
	Lock_Controls(1)
	--Letter_Box_In(1/2)
	Start_Cinematic_Camera()
	Point_Camera_At(location)
	Transition_To_Tactical_Camera(1)
	--Founder (FOU) -- Are the hackers in place?
	BlockOnCommand(Queue_Talking_Head(dialog_founder, "NVS02_SCENE08_01"))
	--Mirabel (MIR) -- They're downloading now.  The sentients proved a loyal ally.
    End_Cinematic_Camera()
    Zoom_Camera.Set_Transition_Time(20)
    Zoom_Camera(.3)
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE08_02"))
	--Founder (FOU) -- Their will to survive was never in question.  However, you cannot continue to let the sentient presence distract you.
	BlockOnCommand(Queue_Talking_Head(dialog_founder, "NVS02_SCENE08_03"))
	--Mirabel (MIR) -- I didn't have the heart to tell them. The Hierarchy's never been beaten.
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE08_04"))
	--Founder (FOU) -- Jerica, I'll not warn you again. When you come to recognize the faces on the tombs, you'll know why it is better to keep the sentients at a distance.
	BlockOnCommand(Queue_Talking_Head(dialog_founder, "NVS02_SCENE08_05"))
	--Viktor (VIK) -- (Unintelligible)
	BlockOnCommand(Queue_Talking_Head(dialog_viktor, "NVS02_SCENE08_06"))
	--Mirabel (MIR) -- Is that part of your programming too?
	BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE08_07"))
	--Founder (FOU) -- (ignores her)  Return to base.
	BlockOnCommand(Queue_Talking_Head(dialog_founder, "NVS02_SCENE08_08"))
	dialogue_end_mission_done=true
end

function Post_Load_Callback()
	UI_Hide_Research_Button()
	UI_Hide_Sell_Button()
	Movie_Commands_Post_Load_Callback()
end


--Novus Comm (NCO) -- Sir, we are detecting recent Hierarchy activity to the west of your current location.
--BlockOnCommand(Queue_Talking_Head(dialog_nov_comm, "NVS02_SCENE01_01"))

--Novus Comm (NCO) -- It appears to be a glyph of some sort.  Orders are to investigate the glyph to provide further data.
--BlockOnCommand(Queue_Talking_Head(dialog_nov_comm, "NVS02_SCENE01_03"))

--Mirabel (MIR) -- On my way.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE01_04"))
	
--Mirabel (MIR) -- When the sentients are safe, I'll have the hackers lock them down.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE04_10"))
	
--Ohm Robot (ROB) -- Sir, several Hierarchy units are still active at the glyph.
--BlockOnCommand(Queue_Talking_Head(dialog_ohm_robot, "NVS02_SCENE02_01"))

--Viktor (VIK) -- (Unintelligible)
--BlockOnCommand(Queue_Talking_Head(dialog_viktor, "NVS02_SCENE03_01"))

--Mirabel (MIR) -- Believe me Viktor, I have no intention of stepping outside.  (horrified)  What are they doing to these people?
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE03_02"))
	
--Mirabel (MIR) -- We need to move out or we will lose the element of surprise.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE01_06"))

--Novus Science (NSC) -- They appear to be reaper class harvesters.  They are most likely being used to harvest raw materials.
--BlockOnCommand(Queue_Talking_Head(dialog_nov_science, "NVS02_SCENE02_02"))

--Mirabel (MIR) -- Take them out, but be careful.  They will harvest anything in their path.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE02_03"))

--Mirabel (MIR) -- Those contaminated sentients need to be destroyed before they do too much damage.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE03_05"))

--Novus Comm (NCO) -- Statistical odds for success are unacceptable.  Reinforcements in transit to your location.
--BlockOnCommand(Queue_Talking_Head(dialog_nov_comm, "NVS02_SCENE04_05"))

--Novus Comm (NCO) -- Reinforcements have arrived.
--BlockOnCommand(Queue_Talking_Head(dialog_nov_comm, "NVS02_SCENE04_06"))

--Mirabel (MIR) -- Our hackers have been destroyed.  Requesting more at my location.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE04_07"))

--Mirabel (MIR) -- The Hierarchy are using Defilers to conatminate the local population to fight their battles for them.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE04_08"))

--Novus Science (NSC) -- You will need to destroy the nearby Hierarchy Defilers to stem the flow of contaminated sentients.
--BlockOnCommand(Queue_Talking_Head(dialog_nov_science, "NVS02_SCENE04_09"))

--Mirabel (MIR) -- We waited too long.  Put them out of their misery.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE05_05"))

--Viktor (VIK) -- (Unintelligible)
--BlockOnCommand(Queue_Talking_Head(dialog_viktor, "NVS02_SCENE06_02"))

--Mirabel (MIR) -- It's the Hiearchy way. The Reapers are creating an army by harvesting the sentients.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE06_03"))

--Col. Moore (MOO) -- If you help us by destroying those "Reapers", we'll help you assault that alien base.
--BlockOnCommand(Queue_Talking_Head(dialog_moore, "NVS02_SCENE06_04"))

--Novus Comm (NCO) -- We are detecting a city to the north with a sizeable sentient population.
--BlockOnCommand(Queue_Talking_Head(dialog_nov_comm, "NVS02_SCENE03_07"))

--Mirabel (MIR) -- That's probably the source.  We're on our way there now.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE03_08"))

--Col. Moore (MOO) -- These locals are dying over here!  We need help!
--BlockOnCommand(Queue_Talking_Head(dialog_moore, "NVS02_SCENE06_06"))

--Mirabel (MIR) -- We don't have all day!  Get the Hacker to that Detection Drone!
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE07_05"))

--Mirabel (MIR) -- We needed to hack into the Detection Drone, not destroy it.  This mission is over.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE07_06"))



-- cine dialogue only
--Mirabel (MIR) -- Are they locked down?
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE09_01"))
--Novus Comm (NCO) -- Affirmative.
--BlockOnCommand(Queue_Talking_Head(dialog_nov_comm, "NVS02_SCENE09_02"))
--Founder (FOU) -- Jerica, this is strictly against protocol.
--BlockOnCommand(Queue_Talking_Head(dialog_founder, "NVS02_SCENE09_03"))
--Mirabel (MIR) -- But it's worth a shot.  (to MOORE)  Brave sentients, can you hear me?
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE09_04"))
--Col. Moore (MOO) -- I hear you loud and clear. Maybe you can explain the day I'm having. So let's start with: who are you?
--BlockOnCommand(Queue_Talking_Head(dialog_moore, "NVS02_SCENE09_05"))
--Mirabel (MIR) -- We are Novus.  We are enemies of your oppressors, the Hierarchy.  We've been at war with them for some time.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE09_06"))
--Col. Moore (MOO) -- Then I'd appreciate you telling me how we beat these things short of throwing rocks at them.
--BlockOnCommand(Queue_Talking_Head(dialog_moore, "NVS02_SCENE09_07"))
--Mirabel (MIR) -- Listen to me - you need to get your people to safety!  There is a contagion that-
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE09_08"))
--Col. Moore (MOO) -- Contagion?
--BlockOnCommand(Queue_Talking_Head(dialog_moore, "NVS02_SCENE09_09"))
--Col. Moore (MOO) -- You don't say? Look, I've got some questions here.
--BlockOnCommand(Queue_Talking_Head(dialog_moore, "NVS02_SCENE09_10"))
--Mirabel (MIR) -- They'll have to wait. I have an important mission to finish. If we work together we may prevent the destruction of your planet.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE09_11"))
--Col. Moore (MOO) -- But
--BlockOnCommand(Queue_Talking_Head(dialog_moore, "NVS02_SCENE09_12"))
--Mirabel (MIR) -- I'm sorry. Time for your world is running out.
--BlockOnCommand(Queue_Talking_Head(dialog_mirabel, "NVS02_SCENE09_13"))

