-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_Tut02.lua#103 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_Tut02.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Chris_Rubyor $
--
--            $Change: 88916 $
--
--          $DateTime: 2007/12/03 18:03:46 $
--
--          $Revision: #103 $
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
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	
	hostile = Find_Player("Hostile")
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	ueatwo = Find_Player("MilitaryTwo")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")

	PGColors_Init_Constants()
--	uea.Enable_Colorization(true, COLOR_GREEN)
--	ueatwo.Enable_Colorization(true, COLOR_DARK_GREEN)
--	aliens.Enable_Colorization(true, COLOR_RED)
--	novus.Enable_Colorization(true, COLOR_CYAN)
--	hostile.Enable_Colorization(true, COLOR_RED)

	pip_moore = "MH_Moore_pip_Head.alo"
	pip_comm = "mi_comm_officer_pip_head.alo"
	pip_woolard = "Mi_Wollard_pip_head.alo"
	pip_marine = "Mi_marine_pip_head.alo"

	pip_viktor = "NH_Viktor_pip_Head.alo"
	pip_mirabel = "NH_Mirabel_pip_Head.alo"
	pip_vertigo = "NH_Vertigo_pip_Head.alo"
	pip_founder = "NH_Founder_pip_Head.alo"
	pip_novscience = "NI_Science_Officer_pip_Head.alo"
	pip_novcomm = "NI_Comm_Officer_pip_Head.alo"
	
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
		Register_Hint_Context_Scene(scene)			-- Set the scene to which independant hints   will be attached.
		-- ***** HINT SYSTEM *****

		Fade_Screen_Out(0)

	novus.Allow_AI_Unit_Behavior(false)
	aliens.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	
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
	UI_Display_Tooltip_Resources(false)
	UI_Set_Display_Credits_Pop(false)
	
	--Prepare the Novus HUD so we can switche fast later.
	Preload_Scene("Novus_Tactical_Command_Bar")

	failure_text="TEXT_SP_MISSION_MISSION_FAILED"

	-- should be able to remove this later
	--Change_Local_Faction("Military")
	uea.Give_Money(7500)
	
	--Stop_All_Music() 
	Disable_Automatic_Tactical_Mode_Music()
	Play_Music("Music_On_Edge")
	
		hero = Find_Hint("Military_Hero_General_Randal_Moore","part1")
		if not TestValid(hero) then
			MessageBox("Story_Campaign_Novus_Tut02 cannot find General Moore'!")
		end
		
	prox_choppers=Find_Hint("MARKER_GENERIC", "proxchoppers")
	fort_mcnair=Find_Hint("MARKER_GENERIC", "thefort")
	president_reached_fort=false;
	president=Find_Hint("TM02_PRESIDENTIAL_AMBULANCE", "president")
	walker=Find_Hint("TM02_CUSTOM_HABITAT_WALKER", "bigwalker")
	--walker.Get_Script().Call_Function("Walker_Set_Invulnerable", true)
	spawn_woolard=Find_Hint("MARKER_GENERIC", "woolardspawn")
	spawn_walker=Find_Hint("MARKER_GENERIC", "walkerspawner")
	woolard_reached_fort=false;
	woolard_helped_out=false;
	president_goto=Find_Hint("MARKER_GENERIC", "presgoto")
	president_escaped=false;
	
	bombers=Find_All_Objects_With_Hint("bombers")
	guerillas=Find_All_Objects_With_Hint("guerillas")
	woolard_ambushes=Find_All_Objects_With_Hint("wambush")
	
	bombersgoto=Find_Hint("MARKER_GENERIC", "bombersgoto")
	motorpool=Find_Hint("MILITARY_MOTOR_POOL", "motorpool")
	barracks=Find_Hint("MILITARY_BARRACKS", "barracks")
	airfield=Find_Hint("MILITARY_AIRCRAFT_PAD", "airfield")
	turrets=Find_All_Objects_Of_Type("MILITARY_TURRET_GROUND")
	freeunits=Find_All_Objects_With_Hint("freeunits")
	invasion_spawns=Find_All_Objects_With_Hint("invadespawn")
	fort_defended=false;
	military_retreating=false;
	
	obja_flag=Find_Hint("MARKER_GENERIC", "objaflag")
	
	mission_start=Find_Hint("MARKER_GENERIC", "missionstart")
	
	walker_goto1=Find_Hint("MARKER_GENERIC", "walkergoto1")
	walker_goto2=Find_Hint("MARKER_GENERIC", "walkergoto2")
	walker_goto3=Find_Hint("MARKER_GENERIC", "walkergoto3")
	
	--walker_building1=Find_Hint("_SKYSCRAPER_02", "shootme1a")
	--walker_target1=Find_Hint("NEUTRAL_PURIFIER_TARGET_OBJECT", "shootme1b")
	--walker_building2=Find_Hint("_SKYSCRAPER_01", "shootme2a")
	--walker_target2=Find_Hint("NEUTRAL_PURIFIER_TARGET_OBJECT", "shootme2b")
	--walker_building3=Find_Hint("_SKYSCRAPER_01", "shootme3a")
	--walker_target3=Find_Hint("NEUTRAL_PURIFIER_TARGET_OBJECT", "shootme3b")
	--walker_building4=Find_Hint("_SKYSCRAPER_01", "shootme4a")
	--walker_target4=Find_Hint("NEUTRAL_PURIFIER_TARGET_OBJECT", "shootme4b")
	--walker_building5=Find_Hint("_SKYSCRAPER_02", "shootme5a")
	--walker_target5=Find_Hint("NEUTRAL_PURIFIER_TARGET_OBJECT", "shootme5b")
	--walker_building1.Register_Signal_Handler(Death_Building1, "OBJECT_DAMAGED")
	--walker_building2.Register_Signal_Handler(Death_Building2, "OBJECT_DAMAGED")
	--walker_building3.Register_Signal_Handler(Death_Building3, "OBJECT_DAMAGED")
	--walker_building4.Register_Signal_Handler(Death_Building4, "OBJECT_DAMAGED")
	--walker_building5.Register_Signal_Handler(Death_Building5, "OBJECT_DAMAGED")
	--walker_building1.Set_Cannot_Be_Killed(true)
	--walker_building2.Set_Cannot_Be_Killed(true)
	--walker_building3.Set_Cannot_Be_Killed(true)
	--walker_building4.Set_Cannot_Be_Killed(true)
	--walker_building5.Set_Cannot_Be_Killed(true)
	
	novus_appeared=false;
	intro_mission_done=false;
	audio_reached_base_done=false;
	
	objective_a_completed=false;
	objective_b_completed=false;
	objective_c_completed=false;
	objective_d_completed=false;
	
	mission_success = false
	mission_failure = false
	time_objective_sleep = 5
	time_radar_sleep = 2
	
	Register_Death_Event(hero, Death_Hero)
	Register_Death_Event(president, Death_President)
	
	-- setting up faction relationships so no one acts out of character
	--aliens.Make_Ally(civilian)
	--civilian.Make_Ally(aliens)
	
	novus.Make_Ally(civilian)
	civilian.Make_Ally(novus)
	novus.Make_Ally(uea)
	uea.Make_Ally(novus)
	uea.Make_Ally(civilian)
	civilian.Make_Ally(uea)
	aliens.Make_Enemy(ueatwo)
	ueatwo.Make_Ally(aliens)
	uea.Make_Ally(ueatwo)

	-- this is to make sure that choppers don't shoot at the buildings
	--uea.Make_Ally(hostile)
	--ueatwo.Make_Ally(hostile)
	
	--set low civ population on large maps (esp single player)
	Spawn_Civilians_Automatically(true)
	Set_Desired_Civilian_Population(200)
	--Make_Civilians_Panic(fort_mcnair, 10000)
	Create_Thread("Setup_Civilians")
	
	Setup_Ambushes()
	Setup_Guerillas()
	Setup_Bombers()
	Setup_Choppers()

	-- Radar Initialization
	Register_Prox(obja_flag, Prox_Reached_Fort_Obj_A, 550, uea)

	-- short intro to the mission	
	Point_Camera_At(mission_start)
	Lock_Controls(1)
	Fade_Screen_Out(0)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	
	Transition_Cinematic_Target_Key(mission_start, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(mission_start, 0, 200, 55, 65, 1, 0, 0, 0)
	
	units1=Find_Hint("MILITARY_TEAM_MARINES", "units1")
	units2=Find_Hint("MILITARY_TEAM_MARINES", "units2")
	units3=Find_Hint("MILITARY_TEAM_MARINES", "units3")
	units4=Find_Hint("MILITARY_TEAM_ROCKETLAUNCHER", "units4")
	units5=Find_Hint("MILITARY_TEAM_MARINES", "units5")
	units6=Find_Hint("MILITARY_TEAM_MARINES", "units6")
	unitsgoto1=Find_Hint("MARKER_GENERIC", "unitsgoto1")
	unitsgoto2=Find_Hint("MARKER_GENERIC", "unitsgoto2")
	unitsgoto3=Find_Hint("MARKER_GENERIC", "unitsgoto3")
	unitsgoto4=Find_Hint("MARKER_GENERIC", "unitsgoto4")
	unitsgoto5=Find_Hint("MARKER_GENERIC", "unitsgoto5")
	unitsgoto6=Find_Hint("MARKER_GENERIC", "unitsgoto6")
	unitsgoto7=Find_Hint("MARKER_GENERIC", "unitsgoto7")
	unitsgoto8=Find_Hint("MARKER_GENERIC", "unitsgoto8")
	
	president.Move_To(unitsgoto8)
	hero.Move_To(unitsgoto7)
	units1.Move_To(unitsgoto1)
	units2.Move_To(unitsgoto2)
	units3.Move_To(unitsgoto3)
	units4.Move_To(unitsgoto4)
	units5.Move_To(unitsgoto5)
	units6.Move_To(unitsgoto6)
	
	Create_Thread("Setup_Fuel_Tankers")
	
	Fade_Screen_In(1) 
	Transition_To_Tactical_Camera(5)
	Sleep(1)
	Create_Thread("Audio_Mission_Start")
	Sleep(4)
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()
	
	Sleep(1)
	
	--used to skip to novus section of the mission
  if true then
	
	-- show mission objective a and wait for it to be triggered
	Show_Objective_A()
	--Add_Independent_Hint(HINT_SYSTEM_SCROLLING_02)
	--Add_Independent_Hint(HINT_SYSTEM_ROTATE_VIEW)

	Create_Thread("President_Health_Tracker")
	
	while not objective_a_completed do
		Sleep(1)
		if not mission_success and not mission_failure then
			if president_reached_fort then
				Remove_Radar_Blip("blip_objective_a")
				obja_flag.Highlight(false)
				Set_Objective_Text(tut02_objective_a, "TEXT_SP_MISSION_TUT02_OBJECTIVE_A")
				Objective_Complete(tut02_objective_a)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT02_OBJECTIVE_A_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_a_completed=true;
				president.Highlight_Small(false)
				president.Set_Cannot_Be_Killed(true)
			end
		end
	end
	
	--remove this later (testing victory conds)
	--Create_Thread("Thread_Mission_Complete")
	
	UI_Set_Display_Credits_Pop(true)
	Create_Thread("Audio_Reached_Base")
	Create_Thread("Activate_Fort")
	Create_Thread("President_Leave")
	Play_Music("Music_Impending_Doom")
	while not audio_reached_base_done do
		Sleep(1)
	end
	Create_Thread("Audio_Woolard_Come_Home")
	Create_Thread("Spawn_Woolard")
	Show_Objective_B()
	--Add_Independent_Hint(HINT_SYSTEM_CONSTRUCTING_UNITS)
	--Add_Independent_Hint(HINT_SYSTEM_RALLY_POINTS)
	
	while not objective_b_completed do
		Sleep(1)
		if not mission_success and not mission_failure then
			if woolard_reached_fort then
				Remove_Radar_Blip("blip_objective_b")
				Set_Objective_Text(tut02_objective_b, "TEXT_SP_MISSION_TUT02_OBJECTIVE_B")
				Objective_Complete(tut02_objective_b)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT02_OBJECTIVE_B_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				obja_flag.Highlight(false)
				woolard.Highlight_Small(false, -30)
				objective_b_completed=true;
			end
		end
	end

	Create_Thread("Audio_Woolard_Walker")
	Sleep(1)
	
	Register_Prox(fort_mcnair, Prox_Fort_Defense, 150, aliens)
	
	fort_defend_time = 120
	Show_Objective_C()
	
	Play_Music("Music_Prepare_For_Oblivion")
	
	while not objective_c_completed do
		Sleep(1)
		fort_defend_time = fort_defend_time - 1
		Set_Objective_Text(tut02_objective_c, "TEXT_SP_MISSION_TUT02_OBJECTIVE_C")
		
		if not mission_success and not mission_failure then
			if fort_defended then
				Delete_Objective(tut02_objective_c)
				Delete_Objective(tut02_objective_primary)
				Delete_Objective(tut02_objective_secondary)
				objective_c_completed=true;
			end
			if not TestValid(motorpool) and not TestValid(barracks) and not TestValid(airfield) then
				failure_text="TEXT_SP_MISSION_TUT02_OBJECTIVE_C_FAILED"
				Create_Thread("Thread_Mission_Failed")
			end
		end
	end
	
	Fade_Out_Music()	 
	Fade_Screen_Out(2)
	Sleep(2)
	
  end
	
	hero.Set_Cannot_Be_Killed(true)
	woolard.Set_Cannot_Be_Killed(true)
	
	--MessageBox("Insert Neato Cinematic Here.")
	Change_Local_Faction("Novus")
    Set_Active_Context("Tut02_Story_Campaign_Midtro")
    BlockOnCommand(Play_Bink_Movie("Mission_2_Midtro",true))

	Set_Active_Context("Tut02_StoryCampaign_Novus")

	UI_Hide_Research_Button()
	UI_Hide_Sell_Button()

	novus.Make_Ally(civilian)
	civilian.Make_Ally(novus)
	novus.Make_Ally(uea)
	uea.Make_Ally(novus)
	uea.Make_Ally(civilian)
	civilian.Make_Ally(uea)
	aliens.Make_Enemy(ueatwo)
	ueatwo.Make_Enemy(aliens)
	uea.Make_Ally(ueatwo)
	
	novus_forces_pos_1=Find_Hint("MARKER_GENERIC", "novforces1")
	novus_forces_pos_2=Find_Hint("MARKER_GENERIC", "novforces2")
	novus_forces_pos_3=Find_Hint("MARKER_GENERIC", "novforces3")
	novus_forces_pos_4=Find_Hint("MARKER_GENERIC", "novforces4")
	novus_forces_pos_5=Find_Hint("MARKER_GENERIC", "novforces5")
	endwalker1=Find_Hint("MARKER_GENERIC", "endwalker1")
	endwalker2=Find_Hint("MARKER_GENERIC", "endwalker2")
	endwalker3=Find_Hint("MARKER_GENERIC", "endwalker3")
	uea_retreat=Find_Hint("MARKER_GENERIC", "uearetreat")

		portal_1=Find_Hint("MOV_NOVUS_PORTAL","portal1")
		portal_2=Find_Hint("MOV_NOVUS_PORTAL","portal2")
		portal_3=Find_Hint("MOV_NOVUS_PORTAL","portal3")
		portal_4=Find_Hint("MOV_NOVUS_PORTAL","portal4")
		portal_5=Find_Hint("MOV_NOVUS_PORTAL","portal5")
		portal_1.Hide(true)
		portal_2.Hide(true)
		portal_3.Hide(true)
		portal_4.Hide(true)
		portal_5.Hide(true)
	
	Create_Thread("Setup_Target_Buildings",civilian)
	Create_Thread("Spawn_Novus")
	Create_Thread("Military_Retreat")
	
	novus_hero_pos=Find_Hint("MARKER_GENERIC", "novheropos")
	mirabel=Create_Generic_Object(Find_Object_Type("NOVUS_HERO_MECH"),novus_hero_pos.Get_Position(), novus)
	-- heroes nerfed late, so adding damage modifier, Mirabel old health(1800) / Mirabel new health(1000) - 1 = -.45
	if TestValid(mirabel) then mirabel.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.45) end
	Register_Death_Event(mirabel, Death_Mirabel)
	novus_appeared=true;
	
	UI_Display_Tooltip_Resources(true)

		-- Radar Initialization
		local radar_filter_id1 = RadarMap.Add_Filter("Radar_Map_Enable", novus)
		local radar_filter_id2 = RadarMap.Add_Filter("Radar_Map_Allow_Mouse_Input", novus)
		local radar_filter_id3 = RadarMap.Add_Filter("Radar_Map_Show_Terrain", novus)
		local radar_filter_id4 = RadarMap.Add_Filter("Radar_Map_Show_FOW", novus)
		local radar_filter_id5 = RadarMap.Add_Filter("Radar_Map_Show_Owned", novus)
		local radar_filter_id6 = RadarMap.Add_Filter("Radar_Map_Show_Allied", novus)
		local radar_filter_id7 = RadarMap.Add_Filter("Radar_Map_Show_Enemy", novus)
		local radar_filter_id8 = RadarMap.Add_Filter("Radar_Map_Show_Neutral", novus)
		
	Point_Camera_At(mirabel)
	Lock_Controls(1)
	Fade_Screen_Out(0)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	Transition_Cinematic_Target_Key(mirabel, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(mirabel, 0, 200, 55, 65, 1, 0, 0, 0)
	Fade_Screen_In(1) 
	Transition_To_Tactical_Camera(5)
	Sleep(3)
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()
		
	Play_Music("Music_Modern_Design")
	Show_Objective_D()
	
	while not objective_d_completed do
		Sleep(1)
		if not mission_success and not mission_failure then
			if walker_destroyed then
				Remove_Radar_Blip("blip_objective_d")
				Set_Objective_Text(tut02_objective_d, "TEXT_SP_MISSION_TUT02_OBJECTIVE_D")
				Objective_Complete(tut02_objective_d)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT02_OBJECTIVE_D_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_d_completed=true;
			end
		end
	end
	
	--Sleep(2)
	
	mirabel.Set_Cannot_Be_Killed(true)
	Enable_Automatic_Tactical_Mode_Music()
	Create_Thread("Thread_Mission_Complete");
	
end

function Setup_Fuel_Tankers()
	tankers=Find_All_Objects_Of_Type("TUT01_CIVILIAN_OIL_TANKER_TRAILER")
	for i,tanker in pairs(tankers) do
		tanker.Register_Signal_Handler(Callback_Tanker_Killed, "OBJECT_HEALTH_AT_ZERO")
	end
end

function Callback_Tanker_Killed(trigger_obj)
	--MessageBox("Burn Baby Burn")
	local radius=150
	Burn_All_Objects(trigger_obj, radius, _TREE_MAPLE_02) --check
	Burn_All_Objects(trigger_obj, radius, _TREE_ELM_01) --check
	Burn_All_Objects(trigger_obj, radius, _TREE_CHERRY_WHITE) --check
	Burn_All_Objects(trigger_obj, radius, _BUSHES_04) --check
	Burn_All_Objects(trigger_obj, radius, _TREE_ELM_01_GROVE) --check
	Burn_All_Objects(trigger_obj, radius, _GRASS_04) --check
	Burn_All_Objects(trigger_obj, radius, _BUSH_DESERT_SCRUB) --check
	Burn_All_Objects(trigger_obj, radius, _BUSH_ROSE_RED_BIG) --check
	Burn_All_Objects(trigger_obj, radius, _TREE_OAK_01_GROVE) --check
	
	--do a distance check on charlie fodder
	local the_military=Find_All_Objects_Of_Type(uea, "CanAttack")
	for j, type in pairs(the_military) do
		if TestValid(type) then
			local distance = type.Get_Distance(trigger_obj)
			if distance < radius then
				type.Take_Damage(250, "Damage_Fire")
			end
		end
	end
	local aliens=Find_All_Objects_Of_Type(aliens, "CanAttack")
	for j, type in pairs(aliens) do
		if TestValid(type) then
			local distance = type.Get_Distance(trigger_obj)
			if distance < radius then
				type.Take_Damage(250, "Damage_Fire")
			end
		end
	end
end

function Setup_Civilians()
	while true do
		markers=Find_All_Objects_Of_Type("MARKER_CIVILIAN_PEDESTRIAN_SPAWNER")
		for units, unit in pairs(markers) do
			if TestValid(unit) then
				Make_Civilians_Panic(unit, 500)
			end
		end
		Sleep(10)
	end
end

-- adds mission objective for objective A
function Show_Objective_A()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT02_OBJECTIVE_A_ADD"} )
	Sleep(time_objective_sleep)
	Add_Radar_Blip(obja_flag, "DEFAULT", "blip_objective_a")
	tut02_objective_a = Add_Objective("TEXT_SP_MISSION_TUT02_OBJECTIVE_A")
	obja_flag.Highlight(true)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	if TestValid(president) then president.Highlight_Small(true, -40) end
end

function Setup_Guerillas()
	for units, unit in pairs(guerillas) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",true,true,unit,275)
		end
	end
end

function Setup_Bombers()
	for units, unit in pairs(bombers) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",true,true,unit,200)
			--Register_Prox(unit, Prox_Bomb_And_Run, 135, uea)
			Register_Prox(unit, Prox_Bomb_And_Run, 150, uea)
		end
	end
end

function Prox_Bomb_And_Run(prox_obj, trigger_obj)
	if trigger_obj==president then
		Create_Thread("Lost_Ones_Bomb_And_Run", prox_obj)
		prox_obj.Cancel_Event_Object_In_Range(Prox_Reached_Fort_Obj_A)
	end
end

function Lost_Ones_Bomb_And_Run(grey)
	if TestValid(grey) then
		BlockOnCommand(grey.Activate_Ability("Lost_One_Plasma_Bomb_Unit_Ability",true, grey.Get_Position()))
	end
	Sleep(1)
	if TestValid(grey) then
		BlockOnCommand(grey.Activate_Ability("Grey_Phase_Unit_Ability",true))
	end
	if TestValid(grey) then
		BlockOnCommand(grey.Move_To(bombersgoto))
	end
	if TestValid(grey) then
		Hunt(grey,"PrioritiesLikeOneWouldExpectThemToBe",true,true,grey,500)
	end
end

function President_Health_Tracker()
	local lasthealth=1
	while not objective_a_completed do
		if TestValid(president) then
			local health=president.Get_Hull()
			if not mission_success and not mission_failure then
				if health<.25 and lasthealth>health then
					BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE04_02"))
					lasthealth=0
				end
			end
			if not mission_success and not mission_failure then
				if health<.5 and lasthealth>health then
					BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE04_03"))
					lasthealth=.25
				end
			end
			if not mission_success and not mission_failure then
				if health<.75 and lasthealth>health then
					BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE04_05"))
					lasthealth=.5
				end	
			end
			Sleep(1)
		end
		Sleep(1)
	end
end

function Prox_Reached_Fort_Obj_A(prox_obj, trigger_obj)
	if trigger_obj==president then
		president_reached_fort=true;
		prox_obj.Cancel_Event_Object_In_Range(Prox_Reached_Fort_Obj_A)
	end
end

function President_Leave()
	if TestValid(president) then
		president.Set_Selectable(false)
	end
	if TestValid(president) then
		BlockOnCommand(president.Move_To(president_goto))
	end
	if TestValid(president) then
		president_escaped=true
		president.Despawn()
	end
end

function Activate_Fort()
	
	Add_Radar_Blip(motorpool, "Default_Beacon_Placement", "motorpool")
	motorpool.Change_Owner(uea)
	motorpool.Highlight(true,-50)
	Add_Radar_Blip(barracks, "Default_Beacon_Placement", "barracks")
	barracks.Change_Owner(uea)
	barracks.Highlight(true,-50)
	Add_Radar_Blip(airfield, "Default_Beacon_Placement", "airfield")
	airfield.Change_Owner(uea)
	airfield.Highlight(true,-50)
	for units, unit in pairs(turrets) do
		if TestValid(unit) then
			unit.Change_Owner(uea)
		end
	end
	for units, unit in pairs(freeunits) do
		if TestValid(unit) then
			unit.Change_Owner(uea)
		end
	end

	--have remaining waiting units attack
	for units, unit in pairs(guerillas) do
		if TestValid(unit) then
			Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",false,false)
		end
	end
	for units, unit in pairs(bombers) do
		if TestValid(unit) then
			Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",false,false)
		end
	end
	
	--FogOfWar.Reveal_All(uea)
	
	Sleep(1)
	
	Add_Independent_Hint(HINT_TUT02_BUILDING_UNITS)

	Sleep(20)
	
	Remove_Radar_Blip("motorpool")
	Remove_Radar_Blip("barracks")
	Remove_Radar_Blip("airfield")
	motorpool.Highlight(false)
	barracks.Highlight(false)
	airfield.Highlight(false)
	
end

function Spawn_Woolard()
	woolard=Create_Generic_Object(Find_Object_Type("MILITARY_HERO_TANK"),spawn_woolard.Get_Position(), uea)
	Add_Radar_Blip(woolard, "DEFAULT", "blip_objective_b")
	if TestValid(woolard) then woolard.Move_To(fort_mcnair) end
	
	woolard_troops_list={"MILITARY_ABRAMSM2_TANK", "MILITARY_ABRAMSM2_TANK", "MILITARY_HUMMER"}
	troops_list=SpawnList(woolard_troops_list, spawn_woolard, uea)
	for units, unit in pairs(troops_list) do
		if TestValid(unit) then
			if TestValid(unit) then unit.Move_To(fort_mcnair) end
		end
	end
	
	Register_Prox(fort_mcnair, Prox_Reached_Fort_Obj_B, 550, uea)
	Register_Death_Event(woolard, Death_Woolard)
	Create_Thread("Woolard_Come_Home")
	Create_Thread("Woolard_Health_Tracker")
	
	Sleep(40)
	
	walker.Get_Script().Call_Function("Walker_Set_Invulnerable", true)
	walker.Set_Selectable(false)
	walker.Teleport_And_Face(spawn_walker)
	Create_Thread("Walker_Come_Home")
	walker.Add_Reveal_For_Player(uea)
	walker.Set_Targeting_Priorities("TM02_WalkerDestruction")
	Add_Radar_Blip(walker, "Default_Beacon_Placement", "walker")
	
	--walker_target1.Change_Owner(hostile)
	--walker_target2.Change_Owner(hostile)
	--walker_target3.Change_Owner(hostile)
	--walker_target4.Change_Owner(hostile)
	--walker_target5.Change_Owner(hostile)
	--walker_building1.Set_Cannot_Be_Killed(false)
	--walker_building2.Set_Cannot_Be_Killed(false)
	--walker_building3.Set_Cannot_Be_Killed(false)
	--walker_building4.Set_Cannot_Be_Killed(false)
	--walker_building5.Set_Cannot_Be_Killed (false)

	alien_air_list={"ALIEN_FOO_CORE","ALIEN_FOO_CORE","ALIEN_FOO_CORE"}
	foo_list=SpawnList(alien_air_list, walker, aliens)
	--for units, unit in pairs(foo_list) do
	--	if TestValid(unit) then
	--		unit.Make_Invulnerable(true)
	--	end
	--end
	Create_Thread("Foos_Heal_Walker",foo_list)
	
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_comm, "MIL_TUT02_SCENE04_16"))
	end
	
	Create_Thread("Setup_Target_Buildings",novus)
	
	Sleep(10)
	Remove_Radar_Blip("walker")
	Sleep(30)
	Create_Thread("Ground_Invasion")
	Create_Thread("Audio_Aliens_Incoming")

end

function Setup_Target_Buildings(faction)
	buildings=Find_All_Objects_With_Hint("shootme")
	for bldgs, bldg in pairs(buildings) do
		if TestValid(bldg) then
			bldg.Change_Owner(faction)
		end
	end
end

-- adds mission objective for objective B
function Show_Objective_B()
	--Queue_Talking_Head(hero, "MT01_COL0119_ENG")
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT02_OBJECTIVE_B_ADD"} )
	Sleep(time_objective_sleep)
	tut02_objective_b = Add_Objective("TEXT_SP_MISSION_TUT02_OBJECTIVE_B")
	obja_flag.Highlight(true)
	woolard.Highlight_Small(true, -40)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

function Setup_Ambushes()
	for units, unit in pairs(woolard_ambushes) do
		if TestValid(unit) then
			Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",true,true,unit,150)
		end
	end
end

function Woolard_Come_Home()
	--have remaining waiting units attack
	for units, unit in pairs(woolard_ambushes) do
		if TestValid(unit) then
			unit.Attack_Target(woolard)
			Sleep(2)
		end
	end
end

function Woolard_Health_Tracker()
	local lasthealth=1
	while not objective_b_completed do
		if TestValid(woolard) then
			local health=woolard.Get_Hull()
			if not mission_success and not mission_failure then
				if health<.35 and lasthealth>health then
					BlockOnCommand(Queue_Talking_Head(pip_woolard, "MIL_TUT02_SCENE04_12"))
					lasthealth=0
				end
			end
			if not mission_success and not mission_failure then
				if health<.75 and lasthealth>health then
					BlockOnCommand(Queue_Talking_Head(pip_woolard, "MIL_TUT02_SCENE04_11"))
					lasthealth=.35
				end
			end
		end
		Sleep(1)
	end
end

function Setup_Choppers()
	choppers=Find_All_Objects_Of_Type("MILITARY_APACHE")
	for units, unit in pairs(choppers) do
		if TestValid(unit) then
			unit.Play_Animation("Anim_Move",true)
		end
	end
end

function Show_Choppers()
	--highlight choppers
	choppers=Find_All_Objects_Of_Type("MILITARY_APACHE")
	for units, unit in pairs(choppers) do
		if TestValid(unit) then
			unit.Highlight_Small(true,-90)
		end
	end
	Sleep(10)
	for units, unit in pairs(choppers) do
		if TestValid(unit) then
			unit.Highlight_Small(false)
		end
	end
end

function Prox_Reached_Fort_Obj_B(prox_obj, trigger_obj)
	if trigger_obj==woolard then
		woolard_reached_fort=true;
		prox_obj.Cancel_Event_Object_In_Range(Prox_Reached_Fort_Obj_B)
	end
end

-- adds mission objective for objective C
function Show_Objective_C()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, "TEXT_SP_MISSION_TUT02_OBJECTIVE_C_ADD" )
	Sleep(time_objective_sleep)
	tut02_objective_c = Add_Objective("TEXT_SP_MISSION_TUT02_OBJECTIVE_C" )
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, "" )
end

function Ground_Invasion()
	spawn_list_a={"ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_BRUTE", "ALIEN_BRUTE" }
	spawn_list_b={"ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_LOST_ONE", "ALIEN_GRUNT", "ALIEN_GRUNT" }
	for i=1, 5 do
		if not novus_appeared then
			for spots, unit in pairs(invasion_spawns) do
				if GameRandom(1,2)==1 then
					invaders=SpawnList(spawn_list_a, unit.Get_Position(), aliens)
				else
					invaders=SpawnList(spawn_list_b, unit.Get_Position(), aliens)
				end
				Hunt(invaders,"PrioritiesLikeOneWouldExpectThemToBe",false,false)
				Sleep(1)
			end
		end
		Sleep(GameRandom(20,30))
	end
end

function Walker_Come_Home()
	if TestValid(walker) then BlockOnCommand(walker.Move_To(walker_goto1)) end
	if TestValid(walker) then Add_Radar_Blip(walker, "Default_Beacon_Placement", "walker") end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_marine, "MIL_TUT02_SCENE04_08"))
	end
	if TestValid(walker) then BlockOnCommand(walker.Move_To(walker_goto2)) end
	if TestValid(walker) then Add_Radar_Blip(walker, "Default_Beacon_Placement", "walker") end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_marine, "MIL_TUT02_SCENE04_09"))
	end
	if TestValid(walker) then BlockOnCommand(walker.Move_To(walker_goto3)) end
	if TestValid(walker) then Add_Radar_Blip(walker, "Default_Beacon_Placement", "walker") end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_marine, "MIL_TUT02_SCENE04_10"))
	end
	if TestValid(walker) then Add_Radar_Blip(walker, "Default_Beacon_Placement", "walker") end
	if TestValid(walker) then BlockOnCommand(walker.Move_To(fort_mcnair)) end
	
	fort_defended=true
end

function Foos_Heal_Walker(team)
	while true do
		for units, unit in pairs(team) do
			if TestValid(unit) then
				unit.Activate_Ability("Unit_Ability_Foo_Core_Heal_Attack_Toggle", true)
				if TestValid(walker) then
					unit.Move_To(walker)
				end
			end
		end
		Sleep(5)
	end
end

function Foos_Guard_Walker(team)
	while true do
		for units, unit in pairs(team) do
			if TestValid(unit) then
				if TestValid(walker) then
					Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",true,false,walker,400)
				end
			end
		end
		Sleep(5)
	end
end

function Prox_Fort_Defense(prox_obj, trigger_obj)
	if trigger_obj.Get_Type()==Find_Object_Type("TM02_Custom_Habitat_Walker") then
	--if trigger_obj==walker then
		fort_defended=true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Fort_Defense)
	end
end

function End_Walker_Hunt()
	while TestValid(walker) do
		if TestValid(walker) then
			BlockOnCommand(walker.Move_To(endwalker1))
		end
		if TestValid(walker) then
			BlockOnCommand(walker.Move_To(endwalker2))
		end
		if TestValid(walker) then
			BlockOnCommand(walker.Move_To(endwalker3))
		end
	end
end

-- adds mission objective for objective C
function Show_Objective_D()
	--Queue_Talking_Head(hero, "MT01_COL0119_ENG")
	--tut02_objective_primary = Add_Objective("Mirabel must survive.")
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT02_OBJECTIVE_D_ADD"} )
	Sleep(time_objective_sleep)
	tut02_objective_d = Add_Objective("TEXT_SP_MISSION_TUT02_OBJECTIVE_D")
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

function Spawn_Novus()
	walker=Find_Hint("TM02_CUSTOM_HABITAT_WALKER", "thewalker")
	--Register_Death_Event(walker, Death_Walker)
	walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Death_Walker") 
	walker.Override_Max_Speed(.3)
	walker.Add_Reveal_For_Player(novus)
	Create_Thread("End_Walker_Hunt")
	alien_air_list={"ALIEN_FOO_CORE","ALIEN_FOO_CORE","ALIEN_FOO_CORE"}
	foo_list=SpawnList(alien_air_list, walker, aliens)
	Create_Thread("Foos_Heal_Walker",foo_list)
	portal_wait_time=12
	
	Sleep(5)
	novus_forces_list_1={"NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY",
							"NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY",
							"NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY"}
	Create_Thread("Novus_Portal",{novus_forces_pos_1,novus_forces_list_1,portal_1})
	Sleep(3)
	if TestValid(mirabel) then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "MIL_TUT02_SCENE08_01"))
	end
	Sleep(portal_wait_time)

	if not mission_success and not mission_failure then
		Add_Radar_Blip(novus_forces_pos_2, "Default_Beacon_Placement", "radar_blip")
		novus_forces_list_2={"NOVUS_DERVISH_JET","NOVUS_DERVISH_JET","NOVUS_DERVISH_JET","NOVUS_DERVISH_JET"}
		Create_Thread("Novus_Portal",{novus_forces_pos_2,novus_forces_list_2,portal_2})
		Sleep(3)
		Create_Thread("Audio_Dervish_Ability_Ready")
		--for units, unit in pairs(foo_list) do
		--	if TestValid(unit) then
		--		unit.Highlight_Small(true)
		--	end
		--end
		Sleep(portal_wait_time)
	end

	if not mission_success and not mission_failure then
		Add_Radar_Blip(novus_forces_pos_3, "Default_Beacon_Placement", "radar_blip")
		novus_forces_list_3={"NOVUS_ANTIMATTER_TANK","NOVUS_ANTIMATTER_TANK","NOVUS_ANTIMATTER_TANK",
								"NOVUS_ANTIMATTER_TANK","NOVUS_ANTIMATTER_TANK","NOVUS_ANTIMATTER_TANK"}
		Create_Thread("Novus_Portal",{novus_forces_pos_3,novus_forces_list_3,portal_3})
		Sleep(3)
		if TestValid(mirabel) then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "MIL_TUT02_SCENE08_03"))
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "MIL_TUT02_SCENE05_03"))
		end
		hp_list = walker.Find_All_Hard_Points_Of_Type("Alien_Walker_Habitat_HP_Armor_Crown")
		--if TestValid(hp_list[1]) then
		--	for units, unit in pairs(hp_list) do
		--		if TestValid(unit) then
		--			unit.Highlight_Small(true)
		--		end
		--	end
		--end
		Sleep(portal_wait_time)
	end

	if not mission_success and not mission_failure then
		Add_Radar_Blip(novus_forces_pos_4, "Default_Beacon_Placement", "radar_blip")
		novus_forces_list_4={"NOVUS_AMPLIFIER","NOVUS_AMPLIFIER","NOVUS_AMPLIFIER"}
		Create_Thread("Novus_Portal",{novus_forces_pos_4,novus_forces_list_4,portal_4})
		Sleep(3)
		if TestValid(mirabel) then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "MIL_TUT02_SCENE08_04"))
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "MIL_TUT02_SCENE05_04"))
		end
		Sleep(portal_wait_time)
	end

	if not mission_success and not mission_failure then
		Add_Radar_Blip(novus_forces_pos_5, "Default_Beacon_Placement", "radar_blip")
		novus_forces_list_5={"NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY",
								"NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY",
								"NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY","NOVUS_ROBOTIC_INFANTRY"}
		Create_Thread("Novus_Portal",{novus_forces_pos_5,novus_forces_list_5,portal_5})
		Sleep(3)
		if TestValid(mirabel) then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "MIL_TUT02_SCENE05_02"))
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "MIL_TUT02_SCENE05_01"))
		end
		Remove_Radar_Blip("radar_blip")
	end
	
end

function Novus_Portal(params)
	position,forces,portal=params[1],params[2],params[3]
	Raise_Game_Event("Reinforcements_Arrived", novus, position.Get_Position())
	--Add_Radar_Blip(position, "Default_Beacon_Placement", "radar_blip")
	portal.Hide(false)
	portal.Play_Animation("Anim_Build", true, 0)
	Sleep(3)
	portal.Play_Animation("Anim_Idle", true, 0)
	for units, unit in pairs(forces) do
		spawnedunit=Create_Generic_Object(Find_Object_Type(forces[units]),position.Get_Position(),novus)
		jerica=Find_First_Object("NOVUS_HERO_MECH")
		if TestValid(jerica) then
			spawnedunit.Guard_Target(jerica)
		end
		Sleep(.5)
	end
	portal.Play_Animation("Anim_Die", true, 0)
	Sleep(1.5)
	portal.Hide(true)
	Sleep(2)
	Remove_Radar_Blip("radar_blip")
	Sleep(portal_wait_time)
end

function Military_Retreat()
	military_retreating=true;
	Register_Prox(uea_retreat, Prox_Military_Retreat, 50, uea)
	
	Sleep(3)
	
	military_units=Find_All_Objects_Of_Type(uea)
	for units, unit in pairs(military_units) do
		if TestValid(unit) then
			name=unit.Get_Type()
			if (name==Find_Object_Type("MILITARY_ABRAMSM2_TANK") or name==Find_Object_Type("MILITARY_HUMMER") or name==Find_Object_Type("AMERICAN_ARMED_CIVILIAN_SCRIPT")) then
				unit.Prevent_All_Fire(true)
				unit.Move_To(uea_retreat)
			end
			if (name==Find_Object_Type("MILITARY_APACHE") ) then
				unit.Prevent_All_Fire(true)
				unit.Move_To(uea_retreat)
				--unit.Despawn()
			end
			Sleep(.2)
		end
	end
	
	hero=Find_Hint("MILITARY_HERO_GENERAL_RANDAL_MOORE","novusmoore")
	woolard=Find_Hint("MILITARY_HERO_TANK","novuswoolard")
	
	if TestValid(hero) then
		hero.Prevent_All_Fire(true)
		hero.Set_Cannot_Be_Killed(true)
		hero.Move_To(uea_retreat)
	end
	if TestValid(woolard) then
		woolard.Prevent_All_Fire(true)
		woolard.Set_Cannot_Be_Killed(true)
		woolard.Move_To(uea_retreat)
	end
	
end

function Prox_Military_Retreat(prox_obj, trigger_obj)
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Owner()==uea then
			trigger_obj.Despawn()
		end
	end
end

--function Death_Building1(obj, attack_obj)
--	if TestValid(attack_obj) then
--		if attack_obj.Get_Type()==Find_Object_Type("Alien_Walker_Habitat_HP_Plasma_Cannon") or attack_obj==walker then
--			if TestValid(walker_target1) then
--				walker_target1.Despawn()
--			end
--			if TestValid(walker_building1) then
--				walker_building1.Make_Invulnerable(false)
--				walker_building1.Take_Damage(9999)
--			end
--		end
--	end
--end

--function Death_Building2(obj, attack_obj)
--	if TestValid(attack_obj) then
--		if attack_obj.Get_Type()==Find_Object_Type("Alien_Walker_Habitat_HP_Plasma_Cannon") or attack_obj.Get_Type()==Find_Object_Type("TM02_Custom_Habitat_Walker") then
--			if TestValid(walker_target2) then
--				walker_target2.Despawn()
--			end
--			if TestValid(walker_building2) then
--				walker_building2.Make_Invulnerable(false)
--				walker_building2.Take_Damage(9999)
--			end
--		end
--	end
--end

--function Death_Building3(obj, attack_obj)
--	if TestValid(attack_obj) then
--		if attack_obj.Get_Type()==Find_Object_Type("Alien_Walker_Habitat_HP_Plasma_Cannon") or attack_obj.Get_Type()==Find_Object_Type("TM02_Custom_Habitat_Walker") then
--			if TestValid(walker_target3) then
--				walker_target3.Despawn()
--			end
--			if TestValid(walker_building3) then
--				walker_building3.Make_Invulnerable(false)
--				walker_building3.Take_Damage(9999)
--			end
--		end
--	end
--end

--function Death_Building4(obj, attack_obj)
--	if TestValid(attack_obj) then
--		if attack_obj.Get_Type()==Find_Object_Type("Alien_Walker_Habitat_HP_Plasma_Cannon") or attack_obj.Get_Type()==Find_Object_Type("TM02_Custom_Habitat_Walker") then
--			if TestValid(walker_target4) then
--				walker_target4.Despawn()
--			end
--			if TestValid(walker_building4) then
--				walker_building4.Make_Invulnerable(false)
--				walker_building4.Take_Damage(9999)
--			end
--		end
--	end
--end

--function Death_Building5(obj, attack_obj)
--	if TestValid(attack_obj) then
--		if attack_obj.Get_Type()==Find_Object_Type("Alien_Walker_Habitat_HP_Plasma_Cannon") or attack_obj==walker then
--			if TestValid(walker_target5) then
--				walker_target5.Despawn()
--			end
--			if TestValid(walker_building5) then
--				walker_building5.Make_Invulnerable(false)
--				walker_building5.Take_Damage(9999)
--			end
--		end
--	end
--end

--on hero death, force defeat
function Death_Hero()
	if not military_retreating then 
		Queue_Talking_Head(pip_comm, "ALL06_SCENE02_02")
		failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MOORE"
		Create_Thread("Thread_Mission_Failed")
	end
end

function Death_Mirabel()
	if novus_appeared then 
		failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"
		Create_Thread("Thread_Mission_Failed")
	end
end

function Death_Walker()
	if novus_appeared then 
		Queue_Talking_Head(pip_mirabel, "MIL_TUT02_SCENE05_06")
		walker_destroyed=true;
	end
end

function Death_Woolard()
	if not military_retreating then
		Queue_Talking_Head(pip_comm, "MIL_TUT02_SCENE04_13")
		failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_WOOLARD"
		Create_Thread("Thread_Mission_Failed")
	end
end

function Death_President()
	if not president_escaped then
		Queue_Talking_Head(pip_comm, "MIL_TUT02_SCENE04_14")
		failure_text="TEXT_SP_MISSION_TUT02_OBJECTIVE_A_FAILED"
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
	if novus_appeared then 
		Play_Music("Lose_To_Alien_Event") -- this music is faction specific, use: UEA_Lose_Tactical_Event Alien_Lose_Tactical_Event Novus_Lose_Tactical_Event Masari_Lose_Tactical_Event
	else 
		Play_Music("Lose_To_Alien_Event") -- this music is faction specific, use: UEA_Lose_Tactical_Event Alien_Lose_Tactical_Event Novus_Lose_Tactical_Event Masari_Lose_Tactical_Event
	end
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
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
	if novus_appeared then 
		Play_Music("Novus_Win_Tactical_Event") -- this music is faction specific, use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
	else 
		Play_Music("Military_Win_Tactical_Event") -- this music is faction specific, use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
	end
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,90)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
	Sleep(time_objective_sleep)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(0)
	Force_Victory(novus)
end

--***************************************FUNCTIONS****************************************************************************************************
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
			Clear_Hint_Tracking_Map()
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

function Lock_Objects(boolean)
		uea.Lock_Object_Type(Find_Object_Type("MILITARY_ARTILLERY"),boolean,STORY)
		uea.Lock_Object_Type(Find_Object_Type("MILITARY_BUILDER_RIG"),boolean,STORY)
		uea.Lock_Object_Type(Find_Object_Type("MILITARY_DEFENDER_APC"),boolean,STORY)
		uea.Lock_Object_Type(Find_Object_Type("MILITARY_DRAGONFLY_UAV"),boolean,STORY)
		uea.Lock_Object_Type(Find_Object_Type("MILITARY_DRAGOON_MTRV"),boolean,STORY)
		uea.Lock_Object_Type(Find_Object_Type("MILITARY_MAVERICK_JET"),boolean,STORY)
		uea.Lock_Object_Type(Find_Object_Type("MILITARY_SUPPLY_DRONE"),boolean,STORY)
		uea.Lock_Object_Type(Find_Object_Type("MILITARY_TEAM_SCIENCE_SPAWNER"),boolean,STORY)
		uea.Lock_Object_Type(Find_Object_Type("MILITARY_TEAM_SCIENCE"),boolean,STORY)
		uea.Lock_Object_Type(Find_Object_Type("MILITARY_MEDIC"),boolean,STORY)
		uea.Lock_Unit_Ability("Military_Hero_Randal_Moore", "Randal_Moore_Grenade_Attack_Ability", not boolean, STORY)
		uea.Lock_Unit_Ability("Military_Apache", "Unit_Ability_Apache_Rocket_Barrage", true, STORY)
		
		
		novus.Lock_Unit_Ability("Novus_Robotic_Infantry", "Robotic_Infantry_Capture", true, STORY)
		novus.Lock_Generator("RoboticInfantryCaptureGenerator", true,STORY)
		
		novus.Lock_Unit_Ability("Novus_Hero_Founder", "Novus_Founder_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Vertigo", "Novus_Vertigo_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", boolean, STORY)
      novus.Lock_Object_Type(Find_Object_Type("NM04_NOVUS_PORTAL"),boolean,STORY)

		
		aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("ALIEN_LOST_ONE"), "Lost_One_Plasma_Bomb_Ability", not boolean, STORY)
		--aliens.Lock_Unit_Ability("Alien_Lost_One", "Lost_One_Plasma_Bomb_Ability", not boolean, STORY)
end
























function Audio_Mission_Start()
	if not mission_success and not mission_failure then
		Queue_Speech_Event("MIL_TUT02_SCENE01_01")
	end
	if not mission_success and not mission_failure then
		Queue_Speech_Event("MIL_TUT02_SCENE07_01")
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE07_02"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_woolard, "MIL_TUT02_SCENE07_03"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE07_04"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_woolard, "MIL_TUT02_SCENE07_05"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE07_06"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE07_07"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_woolard, "MIL_TUT02_SCENE07_08"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE07_09"))
	end
	intro_mission_done=true
end

function Audio_Reached_Base()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE07_10"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE07_11"))
	end
	Sleep(1)	
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_comm, "MIL_TUT02_SCENE06_01"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_comm, "MIL_TUT02_SCENE06_02"))
	end
	Sleep(1)	
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_marine, "MIL_TUT02_SCENE07_12"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE07_13"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_marine, "MIL_TUT02_SCENE07_14"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE07_15"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_marine, "MIL_TUT02_SCENE07_18"))
	end
	audio_reached_base_done=true
end

function Audio_Woolard_Come_Home()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_woolard, "MIL_TUT02_SCENE02_08"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE02_09"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_woolard, "MIL_TUT02_SCENE02_10"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_woolard, "MIL_TUT02_SCENE02_11"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_comm, "MIL_TUT02_SCENE07_19"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE07_20"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE02_13"))
	end
	Create_Thread("Show_Choppers")
end

function Audio_Woolard_Walker()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_woolard, "MIL_TUT02_SCENE04_17"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "MIL_TUT02_SCENE04_18"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_comm, "MIL_TUT02_SCENE04_19"))
	end
end

function Audio_Aliens_Incoming()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_comm, "MIL_TUT02_SCENE02_06"))
	end
end

function Audio_Dervish_Ability_Ready()
	local audio_played=false
	while not audio_played do
		local dervish=Find_First_Object("NOVUS_DERVISH_JET")
		if dervish.Is_Ability_Ready("Unit_Ability_Dervish_Spin_Attack") then
			local saucer=Find_First_Object("ALIEN_FOO_CORE")
			if TestValid(saucer) then
				if TestValid(mirabel) then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "MIL_TUT02_SCENE08_02"))
					audio_played=true
				end
			end
		end
		Sleep(2)
	end
end

function Post_Load_Callback()
	UI_Hide_Research_Button()
	UI_Hide_Sell_Button()
	UI_Display_Tooltip_Resources(false)
	if not objective_a_completed then
		UI_Set_Display_Credits_Pop(false)
	else
		UI_Set_Display_Credits_Pop(true)
	end
	Movie_Commands_Post_Load_Callback()
end
