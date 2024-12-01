-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM06.lua#53 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM06.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Maria_Teruel $
--
--            $Change: 84781 $
--
--          $DateTime: 2007/09/25 14:27:22 $
--
--          $Revision: #53 $
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
	masari = Find_Player("Masari")
	hostile = Find_Player("Hostile")
	novus_two = Find_Player("NovusTwo")

	PGColors_Init_Constants()
--	aliens.Enable_Colorization(true, COLOR_RED)
--	novus.Enable_Colorization(true, COLOR_CYAN)
--	uea.Enable_Colorization(true, COLOR_GREEN)
--	novus_two.Enable_Colorization(true, COLOR_BLUE)
		
	pip_moore = "MH_Moore_pip_Head.alo"
	pip_comm = "mi_comm_officer_pip_head.alo"
	pip_woolard = "Mi_Wollard_pip_head.alo"
	pip_marine = "mi_marine_pip_head.alo"
	pip_mirabel = "NH_Mirabel_pip_Head.alo"
	pip_viktor = "NH_Viktor_pip_Head.alo"
	pip_vertigo = "NH_Vertigo_pip_Head.alo"
	pip_founder = "NH_Founder_pip_Head.alo"
	pip_novscience = "NI_Science_Officer_pip_Head.alo"
	pip_novcomm = "NI_Comm_Officer_pip_Head.alo"
	pip_kamal = "AH_Kamal_Rex_pip_Head.alo"

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
	novus_two.Allow_AI_Unit_Behavior(false)
	
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

	beamfx=Find_Hint("NM05_BEAM_FX","beamfx")
	beamfx2=Find_Hint("NM05_BEAM_FX","beamfx2")
	beamfx.Hide(true)
	
	spot=Find_Hint("MARKER_GENERIC","jericaspawn")
	hero = Create_Generic_Object(Find_Object_Type("Novus_Hero_Mech"),spot.Get_Position() , novus) 
	-- heroes nerfed late, so adding damage modifier, Mirabel old health(1800) / Mirabel new health(1000) - 1 = -.45
	if TestValid(hero) then hero.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.45) end
	Point_Camera_At(hero)
	
	failure_text="TEXT_SP_MISSION_MISSION_FAILED"
	Register_Death_Event(hero, Death_Hero)
	
	-- define data for spawning stations
	spawners=Find_All_Objects_With_Hint("spawners")
	guards=Find_All_Objects_With_Hint("guards")
	reapers=Find_All_Objects_With_Hint("proxtrigger")
	
	moviefoos=Find_All_Objects_Of_Type("MOV_FLYOVER_FOOFIGHTER")
	objcgotos=Find_All_Objects_With_Hint("mongoto")
	objcspawn=Find_Hint("MARKER_GENERIC","spawnmons")

	infothing=Find_Hint("NM06_COMM_TERMINAL","infothing")
	stationary=Find_All_Objects_With_Hint("stationary")
	
	cage_doors=Find_All_Objects_Of_Type("NM06_CAGE_DOOR")
	caged_prisoners=Find_All_Objects_Of_Type(novus_two)
	
	jspawn=Find_Hint("MARKER_GENERIC","jericaspawn")
	jgoto=Find_Hint("MARKER_GENERIC","jericagoto")
		
	brutea1=Find_Hint("ALIEN_BRUTE","bruterighta1")
	brutea2=Find_Hint("ALIEN_BRUTE","bruterighta2")
	bridgea1=Find_Hint("ALIEN_BRIDGE_01","righta1")
	bridgea2=Find_Hint("ALIEN_BRIDGE_01","righta2")
	if not TestValid(bridgea1) then MessageBox("wtf now? 1") end
	if not TestValid(bridgea2) then MessageBox("wtf now? 2") end
	triggera1=Find_Hint("MARKER_GENERIC","triggerrighta1")
	triggera2=Find_Hint("MARKER_GENERIC","triggerrighta2")
	chargea1a=Find_Hint("NM06_VOLATILE_STRUCTURE","chargea1a")
	chargea1b=Find_Hint("NM06_VOLATILE_STRUCTURE","chargea1b")
	chargea2a=Find_Hint("NM06_VOLATILE_STRUCTURE","chargea2a")
	chargea2b=Find_Hint("NM06_VOLATILE_STRUCTURE","chargea2b")
	
	-- define data and prox objects for alien structures
	power_core_a=Find_Hint("NM06_POWER_CORE","corea")
	power_core_b=Find_Hint("NM06_POWER_CORE","coreb")
	power_core_c=Find_Hint("NM06_POWER_CORE","corec")
	power_core_a.Make_Invulnerable(true)
	power_core_b.Make_Invulnerable(true)
	power_core_c.Make_Invulnerable(true)
	power_core_a.Prevent_All_Fire(true)
	power_core_b.Prevent_All_Fire(true)
	power_core_c.Prevent_All_Fire(true)
	beam_point_a=Find_Hint("MARKER_GENERIC","beama")
	beam_point_b=Find_Hint("MARKER_GENERIC","beamb")
	beam_point_c=Find_Hint("MARKER_GENERIC","beamc")
	
	-- define data and prox objects for mission objectives
	objective_a_location=Find_Hint("MARKER_GENERIC","objectivea")
	objective_b_location_a=Find_Hint("MARKER_GENERIC","objectiveba")
	objective_b_location_b=Find_Hint("MARKER_GENERIC","objectivebb")
	objective_b_location_c=Find_Hint("MARKER_GENERIC","objectivebc")
	objective_c_location=Find_Hint("MARKER_GENERIC","objectivec")

	objective_a_object=Find_Hint("ALIEN_SCAN_DRONE","infothing")
	
	bridges=Find_All_Objects_Of_Type("ALIEN_BRIDGE_01")
	for i, bridge in pairs(bridges) do
		bridge.Make_Invulnerable(true)
	end
	
	objective_a_completed=false;
	terminal_reached=false;
	objective_b_completed=false;
	core_a_indanger=false;
	core_b_indanger=false;
	core_c_indanger=false;
	core_a_repaired=false;
	core_b_repaired=false;
	core_c_repaired=false;
	spawns_greys_started=false;
	objective_c_completed=false;
	uplink_reached=false;

	midtro_cinematic_done=false;
	
	audio_dialogue_start=false;
	audio_dialogue_cores_repaired=false;
	
	mission_success = false
	mission_failure = false
	time_objective_sleep = 5
	time_radar_sleep = 2
	reminder_wait_time=30
	
	Set_New_Environment(0)
	
	--novus.Make_Ally(novus_two)
	--novus_two.Make_Ally(novus)
	civilian.Make_Ally(novus_two)
	novus_two.Make_Ally(civilian)
	aliens.Make_Ally(novus_two)
	novus_two.Make_Ally(aliens)
	hostile.Make_Ally(novus_two)
	novus_two.Make_Ally(hostile)
	hostile.Make_Ally(aliens)
	aliens.Make_Ally(hostile)
	
	novus.Make_Ally(civilian)
	civilian.Make_Ally(novus)
	novus.Make_Ally(uea)
	uea.Make_Ally(novus)
	uea.Make_Ally(civilian)
	civilian.Make_Ally(uea)
	
	novus.Give_Money(10000)
	
	-- define data and prox objects for rescued novus prisoners
	Setup_Captured_Allies()
	Setup_Reaper_Units()
	Setup_Guard_Units()
	Setup_Walkers_Under_Construction()
	Setup_Cage_Door_Proxes()
	Create_Thread("Thread_Hide_Movie_Foos")
	Create_Thread("Thread_Reactor_Effects")
	Create_Thread("Thread_Constructors_Tracker")
	--Set_Desired_Civilian_Population(100)
	Spawn_Civilians_Automatically(true)
	Set_Desired_Civilian_Population(50)
	--Make_Civilians_Panic(hero, 10000)
	
	hero.Teleport_And_Face(jspawn)
	Point_Camera_At(jgoto)
	
if true then
	Lock_Controls(1)
	Fade_Screen_Out(0)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	Transition_Cinematic_Target_Key(hero, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(hero, 0, 200, 55, 65, 1, 0, 0, 0)
	Fade_Screen_In(1) 
	Transition_To_Tactical_Camera(5)
	--hero.Suspend_Locomotor(true)
	Sleep(1)
	hero.Move_To(jgoto)
	beamfx2.Hide(true)
	Create_Thread("Audio_Mission_Start")
	Sleep(5)
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()
	Sleep(1)
	--hero.Suspend_Locomotor(false)

	Show_Objective_A()
	
	Sleep(1)
	--Create_Thread("Thread_Begin_Spawns")
	
	while not(objective_a_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if terminal_reached and audio_dialogue_start then
				objective_a_location.Highlight(false)
				Remove_Radar_Blip("blip_objective_a")
				if TestValid(objective_a_area) then objective_a_area.Despawn() end
				Set_Objective_Text(nov06_objective_a, "TEXT_SP_MISSION_NVS06_OBJECTIVE_A")
				Objective_Complete(nov06_objective_a)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS06_OBJECTIVE_A_COMPLETE"} )
				--Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_a_completed=true;
			end
		end
	end
end
	
	Create_Thread("Midtro_Cinematic")
	while not midtro_cinematic_done do
		Sleep(1)
	end
	
	if TestValid(hero) then
		BlockOnCommand(Queue_Talking_Head(pip_viktor, "NVS06_SCENE02_12"))
	end
	if TestValid(hero) then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE02_13"))
	end
	if TestValid(hero) then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE02_14"))
	end
	Show_Objective_B()
	Create_Thread("Thread_Begin_Spawns")
	Create_Thread("Thread_Cinematic_Foos")
	Create_Thread("Thread_Under_Attack")
	
	repaired_cores=0;
	last_repaired_cores=0;
	while not(objective_b_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if (power_core_a.Get_Hull()==1 and core_a_repaired==false) then 
				core_a_repaired=true
				repaired_cores=repaired_cores+1;
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS06_OBJECTIVE_B")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(repaired_cores), 1)
				Set_Objective_Text(nov06_objective_b, out_string)
				--Set_Objective_Text(nov06_objective_b, string.format("TEXT_SP_MISSION_NVS06_OBJECTIVE_B"))
				Remove_Radar_Blip("blip_objective_b_a")
			end
			if (power_core_b.Get_Hull()==1 and core_b_repaired==false) then 
				core_b_repaired=true
				repaired_cores=repaired_cores+1;
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS06_OBJECTIVE_B")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(repaired_cores), 1)
				Set_Objective_Text(nov06_objective_b, out_string)
				--Set_Objective_Text(nov06_objective_b, string.format("TEXT_SP_MISSION_NVS06_OBJECTIVE_B"))
				Remove_Radar_Blip("blip_objective_b_b")
			end
			if (power_core_c.Get_Hull()==1 and core_c_repaired==false) then 
				core_c_repaired=true
				repaired_cores=repaired_cores+1;
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS06_OBJECTIVE_B")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(repaired_cores), 1)
				Set_Objective_Text(nov06_objective_b, out_string)
				--Set_Objective_Text(nov06_objective_b, string.format("TEXT_SP_MISSION_NVS06_OBJECTIVE_B"))
				Remove_Radar_Blip("blip_objective_b_c")
			end
			if (core_a_repaired and core_b_repaired and core_c_repaired) then
				if TestValid(hero) then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_39"))
				end
				Set_Objective_Text(nov06_objective_b, "TEXT_SP_MISSION_NVS06_OBJECTIVE_B_STATE_2")
				Objective_Complete(nov06_objective_b)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS06_OBJECTIVE_B_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_b_completed=true;
			end
			if repaired_cores==1 and not last_repaired_cores==repaired_cores then
				if TestValid(hero) then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_37"))
				end
				last_repaired_cores=repaired_cores
			end
			if repaired_cores==2 and not last_repaired_cores==repaired_cores then
				if TestValid(hero) then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_38"))
				end
				last_repaired_cores=repaired_cores
			end
		end
	end
	Set_New_Environment(0)

	Create_Thread("Audio_Mission_Cores_Repaired")
	while not audio_dialogue_cores_repaired do
		Sleep(1)
	end
	-- show mission objective c and allow it to be triggered
	Sleep(1)
	Create_Thread("Thread_Ship_Destruction")
	Create_Thread("Thread_Begin_Foo_Spawns")

	Show_Objective_C()
	Register_Prox(objective_c_location, Prox_Objective_C, 200, novus)
	_CustomScriptMessage("JoeLog.txt", string.format("****Prox Registered Objective C"))
	
	while not(objective_c_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if(uplink_reached) then
				
				Remove_Radar_Blip("blip_objective_c")
				Set_Objective_Text(nov06_objective_c, "TEXT_SP_MISSION_NVS06_OBJECTIVE_C")
				Objective_Complete(nov06_objective_c)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS06_OBJECTIVE_C_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_c_completed=true;
			end
		end
	end
	
	-- all objectives complete, win the mission
	mission_success=true
	hero.Set_Cannot_Be_Killed(true)
	Sleep(1)
	
	conduit=Find_First_Object("NM06_MATERIAL_CONDUIT_FAKE")
	hero.Set_Selectable(false)
	hero.Set_Cannot_Be_Killed(true)
	Lock_Controls(1)
	BlockOnCommand(hero.Move_To(conduit))
	Point_Camera_At(hero)
	Sleep(1)
	beamfx.Hide(false)
	hero.Prevent_All_Fire(true)
	Sleep(1)
	
	Create_Thread("Thread_Mission_Complete")
	Sleep(4)
	hero.Hide(true)
	beamfx.Hide(true)
end

function Thread_Reactor_Effects()
	while true do
		if TestValid(power_core_a) then
			if power_core_a.Get_Hull()==1 then
				Play_Lightning_Effect("Reactor_Lightning", power_core_a.Get_Position(), beam_point_a.Get_Position())
			end
		end				
		Sleep(GameRandom(1,4)/8)
		if TestValid(power_core_a) then
			if power_core_a.Get_Hull()==1 then
				Play_Lightning_Effect("Reactor_Lightning", power_core_b.Get_Position(), beam_point_b.Get_Position())
			end
		end				
		Sleep(GameRandom(1,4)/8)
		if TestValid(power_core_a) then
			if power_core_a.Get_Hull()==1 then
				Play_Lightning_Effect("Reactor_Lightning", power_core_c.Get_Position(), beam_point_c.Get_Position())
			end
		end				
		Sleep(GameRandom(1,4)/8)
	end
end

function Thread_Hide_Movie_Foos()
	for i=1, table.getn(moviefoos) do
		moviefoos[i].Hide(true)
	end
end

function Setup_Walkers_Under_Construction()
	for allwalkers, walker in pairs(stationary) do
		walker.Set_Service_Only_When_Rendered(true)
		walker.Suspend_Locomotor(true)
		walker.Override_Max_Speed(0)
		--walker.Prevent_Opportunity_Fire(true)
	end
end

function Setup_Guard_Units()
	for triggered, unit in pairs(guards) do
		unit.Set_Service_Only_When_Rendered(true)
		Hunt(unit,false,true,unit,250)
	end
end

function Setup_Reaper_Units()
	for triggered, unit in pairs(reapers) do
		unit.Set_Service_Only_When_Rendered(true)
		--Hunt(unit,false,true,unit,50)
        --Register_Prox(unit, Prox_Reapers_Attack, 150, novus)
	end
end

--function Prox_Reapers_Attack(prox_obj, trigger_obj)
--	if TestValid(trigger_obj) then
--		if trigger_obj.Get_Owner().Get_Faction_Name()=="NOVUS" then
--			Hunt(prox_obj, "NM06_Harvester_Targeting", false, false)
--            prox_obj.Cancel_Event_Object_In_Range(Prox_Reapers_Attack)
--		end
--	end
--end

function Setup_Cage_Door_Proxes()
	for doors, door in pairs(cage_doors) do
        Register_Prox(door, Prox_Cage_Door, 75, novus)
	end
	--for units, unit in pairs(caged_prisoners) do
	--	unit.Add_Reveal_For_Player(novus)
	--end
end

function Prox_Cage_Door(prox_obj, trigger_obj)
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Owner()==hero.Get_Owner() then
			Create_Thread("Audio_Cage_Doors_Sighted")
			prox_obj.Cancel_Event_Object_In_Range(Prox_Cage_Door)
		end
	end
end

function Thread_Begin_Spawns()
	spawner1_source=Find_Hint("NM06_RELOCATOR_FAKE","spawner1")
	spawner1_point =spawner1_source.Get_Bone_Position("P_alien_teleport_in")
	spawner1_target=Find_Hint("MARKER_GENERIC","spawner1a")
	spawner2_source=Find_Hint("NM06_RELOCATOR_FAKE","spawner2")
	spawner2_point =spawner2_source.Get_Bone_Position("P_alien_teleport_in")
	spawner2_target=Find_Hint("MARKER_GENERIC","spawner2a")
	while not(objective_c_completed) do
		grunts=Find_All_Objects_Of_Type("ALIEN_GRUNT")
		if table.getn(grunts)<8 then
			for i=1, 3 do
				if TestValid(hero) then
					--spawner1_source.Play_Animation("anim_teleport_in",true,0)
					spawner1_source.Play_SFX_Event("SFX_Alien_Teleport_In")
					Play_Lightning_Effect("Teleport_Spawn_Beam", spawner1_point, spawner1_target)
					spawner1_source.Stop_SFX_Event("SFX_Alien_Teleport_In")
					if GameRandom(1,2)==1 then
						unit=Create_Generic_Object(Find_Object_Type("ALIEN_GRUNT"),spawner1_target,aliens)
					else
						unit=Create_Generic_Object(Find_Object_Type("ALIEN_LOST_ONE"),spawner1_target,aliens)
					end
					Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",true,true,hero,150)
					Sleep(2)
					spawner2_source.Play_SFX_Event("SFX_Alien_Teleport_In")
					Play_Lightning_Effect("Teleport_Spawn_Beam", spawner2_point, spawner2_target)
					spawner2_source.Stop_SFX_Event("SFX_Alien_Teleport_In")
					if GameRandom(1,2)==1 then
						unit=Create_Generic_Object(Find_Object_Type("ALIEN_GRUNT"),spawner2_target,aliens)
					else
						unit=Create_Generic_Object(Find_Object_Type("ALIEN_LOST_ONE"),spawner2_target,aliens)
					end
					Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",true,true,hero,150)
					Sleep(2)
				end
			end
		end
		Sleep(GameRandom(45,90))
	end
end

-- adds mission objective and radar blip
function Show_Objective_A()
	--nov06_objective_primary = Add_Objective("Mirabel must survive.")
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS06_OBJECTIVE_A_ADD"} )
	Sleep(time_radar_sleep)
	nov06_objective_a = Add_Objective("TEXT_SP_MISSION_NVS06_OBJECTIVE_A")
	Add_Radar_Blip(objective_a_location, "DEFAULT", "blip_objective_a")
	objective_a_location.Highlight(true)
	objective_a_area=Create_Generic_Object(Find_Object_Type("Highlight_Area"), objective_a_location, neutral)
	Sleep(time_objective_sleep-time_radar_sleep)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Register_Prox(objective_a_location, Prox_Objective_A, 100, novus)
end

-- triggers when player reaches comm terminal
function Prox_Objective_A(prox_obj, trigger_obj)
	if trigger_obj==hero then
		terminal_reached=true
		Lock_Controls(1)
		Suspend_AI(1)
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective_A)
	end
end


function Midtro_Cinematic()
	power_core_a.Prevent_All_Fire(false)
	power_core_b.Prevent_All_Fire(false)
	power_core_c.Prevent_All_Fire(false)
	
	reactor=Find_Hint("MARKER_GENERIC","seereactor")
	grey=Find_Hint("NM06_ALIEN_MANIPULATOR","grey")
	if TestValid(hero) then
		hero.Set_Selectable(false)
		hero.Make_Invulnerable(true)
		hero.Suspend_Locomotor(true)
		hero.Play_Animation("Anim_Idle", true, 0)
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE01_08"))
	end
	
	novus_units=Find_All_Objects_Of_Type(novus, "CanAttack")
	gotos=Find_All_Objects_With_Hint("gotos")
	for i, unit in pairs(novus_units) do
		if TestValid(unit) then
			if GameRandom(1,2)==1 then
				unit.Move_To(gotos[1])
			else
				unit.Move_To(gotos[2])
			end
		end
	end
	
	Fade_Screen_Out(1)
	Sleep(1)
	hero.Teleport_And_Face(objective_a_location)
	Letter_Box_In(0)
	Point_Camera_At(reactor)
	Sleep(1)
	power_core_a.Add_Reveal_For_Player(novus)
	power_core_b.Add_Reveal_For_Player(novus)
	power_core_c.Add_Reveal_For_Player(novus)
	Fade_Screen_In(1)
	Sleep(1)
		exp_a=Create_Generic_Object(Find_Object_Type("NEUTRAL_PURIFIER_TARGET_OBJECT"),power_core_a,neutral)
		exp_b=Create_Generic_Object(Find_Object_Type("NEUTRAL_PURIFIER_TARGET_OBJECT"),power_core_b,neutral)
		exp_c=Create_Generic_Object(Find_Object_Type("NEUTRAL_PURIFIER_TARGET_OBJECT"),power_core_c,neutral)
		exp_a.Attach_Particle_Effect("Oil_Tanker_Explosion")
		exp_b.Attach_Particle_Effect("Oil_Tanker_Explosion")
		exp_c.Attach_Particle_Effect("Oil_Tanker_Explosion")
	Destroy_Power_Cores()
	if TestValid(hero) then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE02_04"))
	end
	Sleep(1)
	Fade_Screen_Out(1)
	Sleep(1)
		exp_a.Despawn()
		exp_b.Despawn()
		exp_c.Despawn()
	if TestValid(grey) then grey.Despawn() end
	
	infothing.Play_Animation("Anim_Cinematic",true, 0)
	Point_Camera_At(hero)
	Start_Cinematic_Camera()
	-- Transition_Cinematic_Camera_Key(target_pos, time, xoffset_dist, yoffset_pitch, zoffset_yaw, angles?, attach_object, use_object_rotation, cinematic_animation)
	Transition_Cinematic_Target_Key(infothing, 0, 0, 5, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(hero, 0, 215, 50, 8, 1, 0, 0, 0)
	Fade_Screen_In(1) 
	Sleep(1)
	
	if TestValid(hero) then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "NVS06_SCENE02_08"))
	end
	
	if TestValid(hero) then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE02_06"))
	end
	
	Transition_To_Tactical_Camera(5)
	
	if TestValid(hero) then
		BlockOnCommand(Queue_Talking_Head(pip_kamal, "NVS06_SCENE02_07"))
	end
	End_Cinematic_Camera()
	Letter_Box_Out(1)
	Lock_Controls(0)
	Suspend_AI(0)
	hero.Make_Invulnerable(false)
	hero.Set_Selectable(true)
	hero.Suspend_Locomotor(false)
	
	infothing.Take_Damage(2000)
	
	midtro_cinematic_done=true;
end

-- midtro objective creator
function Destroy_Power_Cores()
	if true then
		power_core_a.Make_Invulnerable(false)
		power_core_b.Make_Invulnerable(false)
		power_core_c.Make_Invulnerable(false)
		power_core_a.Take_Damage(300)
		power_core_b.Take_Damage(300)
		power_core_c.Take_Damage(300)
		power_core_a.Set_Cannot_Be_Killed(true)
		power_core_b.Set_Cannot_Be_Killed(true)
		power_core_c.Set_Cannot_Be_Killed(true)
	end
	
		Shake_Camera(1, 2)
		power_core_a.Change_Owner(novus)
		power_core_b.Change_Owner(novus)
		power_core_c.Change_Owner(novus)
		Register_Death_Event(power_core_a, Death_Core)
		Register_Death_Event(power_core_b, Death_Core)
		Register_Death_Event(power_core_c, Death_Core)
		
		--change weather scenario to do lighting
		Set_New_Environment(1)
		--Create_Thread("Thread_Track_Power_Core_Health")
end

-- adds mission objective and radar blip
function Show_Objective_B()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS06_OBJECTIVE_B_ADD"} )
	Sleep(time_radar_sleep)
	nov06_objective_b = Add_Objective("TEXT_SP_MISSION_NVS06_OBJECTIVE_B_STATE_1")
	Add_Radar_Blip(objective_b_location_a, "DEFAULT", "blip_objective_b_a")
	Add_Radar_Blip(objective_b_location_b, "DEFAULT", "blip_objective_b_b")
	Add_Radar_Blip(objective_b_location_c, "DEFAULT", "blip_objective_b_c")
	Sleep(time_objective_sleep-time_radar_sleep)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Create_Thread("Reveal_Constructors")
end

function Reveal_Constructors()
	while not objective_b_completed do
		constructors=Find_All_Objects_Of_Type("Novus_Constructor")
		for i, unit in pairs(constructors) do
			Add_Radar_Blip(unit, "Default_Beacon_Placement", "temp")
			unit.Add_Reveal_For_Player(novus)
		end
		Sleep(15)
	end
end

function Thread_Track_Power_Core_Health()
	while (not mission_failure and not mission_success) do
		if TestValid(power_core_a) and TestValid(power_core_b) and TestValid(power_core_c) then
			if (power_core_a.Get_Hull()<0.5 and core_a_repaired==true) then 
				core_a_repaired=false;
				Add_Radar_Blip(objective_b_location_a, "DEFAULT", "blip_objective_b_a")
			end
			if (power_core_b.Get_Hull()<0.5 and core_b_repaired==true) then 
				core_b_repaired=false;
				Add_Radar_Blip(objective_b_location_b, "DEFAULT", "blip_objective_b_b")
			end
			if (power_core_c.Get_Hull()<0.5 and core_c_repaired==true) then 
				core_c_repaired=false;
				Add_Radar_Blip(objective_b_location_c, "DEFAULT", "blip_objective_b_c")
			end
			if (power_core_a.Get_Hull()<0.15 and core_a_indanger==false) then 
				core_a_indanger=true;
				-- say something about it
				--MessageBox("Core A is in danger!")
			end
			if (power_core_b.Get_Hull()<0.15 and core_b_indanger==false) then 
				core_b_indanger=true;
				-- say something about it
				--MessageBox("Core B is in danger!")
			end
			if (power_core_c.Get_Hull()<0.15 and core_c_indanger==false) then 
				core_c_indanger=true;
				-- say something about it
				--MessageBox("Core C is in danger!")
			end
		end
		Sleep(1)
	end
end

-- adds mission objective and radar blip
function Show_Objective_C()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS06_OBJECTIVE_C_ADD"} )
	Sleep(time_radar_sleep)
	nov06_objective_c = Add_Objective("TEXT_SP_MISSION_NVS06_OBJECTIVE_C")
	Add_Radar_Blip(objective_c_location, "DEFAULT", "blip_objective_c")
	Sleep(time_objective_sleep-time_radar_sleep)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	
	Register_Prox(triggera1, Prox_Right_A1, 250, novus)
	Register_Prox(triggera2, Prox_Right_A2, 250, novus)
end

function Prox_Right_A1(prox_obj, trigger_obj)
	if TestValid(trigger_obj) then
		chargea1a.Take_Damage(9999)
		chargea1b.Take_Damage(9999)
		bridgea1.Make_Invulnerable(false)
		bridgea1.Take_Damage(99999, "Damage_Unconditional")
		Hunt(brutea1, false, false)
		Hunt(brutea2, false, false)
		triggera1.Cancel_Event_Object_In_Range(Prox_Right_A1)
		triggera2.Cancel_Event_Object_In_Range(Prox_Right_A2)
	end
end

function Prox_Right_A2(prox_obj, trigger_obj)
	if TestValid(trigger_obj) then
		chargea2a.Take_Damage(9999)
		chargea2b.Take_Damage(9999)
		bridgea2.Make_Invulnerable(false)
		bridgea2.Take_Damage(99999, "Damage_Unconditional")
		Hunt(brutea1, false, false)
		Hunt(brutea2, false, false)
		triggera1.Cancel_Event_Object_In_Range(Prox_Right_A1)
		triggera2.Cancel_Event_Object_In_Range(Prox_Right_A2)
	end
end

function Thread_Constructors_Tracker()
	constructors_left=true
	while constructors_left==true do
		constructors=Find_First_Object("NOVUS_CONSTRUCTOR")
		if not TestValid(constructors) then
			constructors_left=false
		end
		Sleep(3)
	end
	if not objective_b_completed then
		if TestValid(hero) then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_25"))
		end
		failure_text="TEXT_SP_MISSION_NVS06_OBJECTIVE_B_FAILED"
		Create_Thread("Thread_Mission_Failed")
	end
end

function Thread_Cinematic_Foos()
	for i=1, table.getn(moviefoos) do
		moviefoos[i].Hide(false)
		moviefoos[i].Play_Animation("Anim_Cinematic", true, 0)
		Sleep(GameRandom(1,5))
	end
end

function Thread_Begin_Foo_Spawns()
	if TestValid(hero) then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_41"))
	end
	while not(objective_c_completed) do
		goto_site=objcgotos[GameRandom(1,table.getn(objcgotos))]
		if TestValid(goto_site) then
			team = { "ALIEN_FOO_CORE" }
			spawnteam = SpawnList(team, objcspawn.Get_Position(), aliens, false, true);
			Hunt(spawnteam,true,true,goto_site,350)
		end
		Sleep(GameRandom(5,10))
	end
end

-- this thread simulates the "ship" being under attack by alien forces in space
function Thread_Under_Attack()
	while not(objective_c_completed) do
		--Shake_Camera(shake_amount, seconds)
		Shake_Camera(1, GameRandom(2,4))
		Sleep(GameRandom(5,15))
	end
end

function Thread_Ship_Destruction()
	fire_starters=Find_All_Objects_Of_Type("NM06_VOLATILE_STRUCTURE")
	total_starters=table.getn(fire_starters)
	for conduits, conduit in pairs(fire_starters) do
		if TestValid(conduit) then
			Register_Prox(conduit, Prox_Destroy_Conduit, GameRandom(100,300), novus)
		end
	end
end

function Prox_Destroy_Conduit(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner().Get_Faction_Name()=="NOVUS" then
		prox_obj.Take_Damage(9999)
		prox_obj.Cancel_Event_Object_In_Range(Prox_Destroy_Conduit)
	end
end


-- triggers when player reaches comm terminal
function Prox_Objective_C(prox_obj, trigger_obj)
	if trigger_obj.Get_Type()==hero.Get_Type() then
		uplink_reached=true
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective_C)
	end
end

function Setup_Captured_Allies()
	allies_1=Find_All_Objects_With_Hint("allies1")
	allies_2=Find_All_Objects_With_Hint("allies2")
	allies_3=Find_All_Objects_With_Hint("allies3")
	allies_4=Find_All_Objects_With_Hint("allies4")
	allies_5=Find_All_Objects_With_Hint("allies5")
	allies_6=Find_All_Objects_With_Hint("allies6")
	allies_7=Find_All_Objects_With_Hint("allies7")
	allies_8=Find_All_Objects_With_Hint("allies8")
	wall_1=Find_Hint("NM06_CAGE_DOOR","wall1")
	wall_2=Find_Hint("NM06_CAGE_DOOR","wall2")
	wall_3=Find_Hint("NM06_CAGE_DOOR","wall3")
	wall_4=Find_Hint("NM06_CAGE_DOOR","wall4")
	wall_5=Find_Hint("NM06_CAGE_DOOR","wall5")
	wall_6=Find_Hint("NM06_CAGE_DOOR","wall6")
	wall_7=Find_Hint("NM06_CAGE_DOOR","wall7")
	wall_8=Find_Hint("NM06_CAGE_DOOR","wall8")
	Register_Death_Event(wall_1, Death_Wall_1)
	Register_Death_Event(wall_2, Death_Wall_2)
	Register_Death_Event(wall_3, Death_Wall_3)
	Register_Death_Event(wall_4, Death_Wall_4)
	Register_Death_Event(wall_5, Death_Wall_5)
	Register_Death_Event(wall_6, Death_Wall_6)
	Register_Death_Event(wall_7, Death_Wall_7)
	Register_Death_Event(wall_8, Death_Wall_8)
end

function Death_Wall_1()
	goto=Find_Hint("MARKER_GENERIC_PURPLE","goto1")
	for prisoners, unit in pairs(allies_1) do
		if TestValid(unit) then
			unit.Change_Owner(novus)
  			unit.Move_To(goto.Get_Position())
		end
	end
	Create_Thread("Audio_Freed_Constructors")
end

function Death_Wall_2()
	goto=Find_Hint("MARKER_GENERIC_PURPLE","goto2")
	for prisoners, unit in pairs(allies_2) do
		if TestValid(unit) then
			unit.Change_Owner(novus)
			unit.Move_To(goto.Get_Position())
		end
	end
	Create_Thread("Audio_Freed_Generic_Guys")
end

function Death_Wall_3()
	goto=Find_Hint("MARKER_GENERIC_PURPLE","goto3")
	for prisoners, unit in pairs(allies_3) do
		if TestValid(unit) then
			unit.Change_Owner(novus)
			unit.Move_To(goto.Get_Position())
		end
	end
	Create_Thread("Audio_Freed_Constructors")
end

function Death_Wall_4()
	goto=Find_Hint("MARKER_GENERIC_PURPLE","goto4")
	for prisoners, unit in pairs(allies_4) do
		if TestValid(unit) then
			unit.Change_Owner(novus)
			unit.Move_To(goto.Get_Position())
		end
	end
	Create_Thread("Audio_Freed_Generic_Guys")
end

function Death_Wall_5()
	goto=Find_Hint("MARKER_GENERIC_PURPLE","goto5")
	for prisoners, unit in pairs(allies_5) do
		if TestValid(unit) then
			unit.Change_Owner(novus)
			unit.Move_To(goto.Get_Position())
		end
	end
	Create_Thread("Audio_Freed_Generic_Guys")
end

function Death_Wall_6()
	goto=Find_Hint("MARKER_GENERIC_PURPLE","goto6")
	for prisoners, unit in pairs(allies_6) do
		if TestValid(unit) then
			unit.Change_Owner(novus)
			unit.Move_To(goto.Get_Position())
		end
	end
	Create_Thread("Audio_Freed_Constructors")
end

function Death_Wall_7()
	goto=Find_Hint("MARKER_GENERIC_PURPLE","goto7")
	for prisoners, unit in pairs(allies_7) do
		if TestValid(unit) then
			unit.Change_Owner(novus)
			unit.Move_To(goto.Get_Position())
		end
	end
	Create_Thread("Audio_Freed_Generic_Guys")
end

function Death_Wall_8()
	goto=Find_Hint("MARKER_GENERIC_PURPLE","goto8")
	for prisoners, unit in pairs(allies_8) do
		if TestValid(unit) then
			unit.Change_Owner(novus)
			unit.Move_To(goto.Get_Position())
		end
	end
	Create_Thread("Audio_Freed_Generic_Guys")
end

function Death_Wall_9()
	goto=Find_Hint("MARKER_GENERIC_PURPLE","goto9")
	for prisoners, unit in pairs(allies_9) do
		if TestValid(unit) then
			unit.Change_Owner(novus)
			unit.Move_To(goto.Get_Position())
		end
	end
	Create_Thread("Audio_Freed_Generic_Guys")
end

function Death_Wall_10()
	goto=Find_Hint("MARKER_GENERIC_PURPLE","goto10")
	for prisoners, unit in pairs(allies_10) do
		if TestValid(unit) then
			unit.Change_Owner(novus)
			unit.Move_To(goto.Get_Position())
		end
	end
	Create_Thread("Audio_Freed_Generic_Guys")
end

function Death_Wall_11()
	goto=Find_Hint("MARKER_GENERIC_PURPLE","goto11")
	for prisoners, unit in pairs(allies_11) do
		if TestValid(unit) then
			unit.Change_Owner(novus)
			unit.Move_To(goto.Get_Position())
		end
	end
	Create_Thread("Audio_Freed_Generic_Guys")
end

function Death_Hero()
	Queue_Talking_Head(pip_novcomm, "NVS01_SCENE06_14")
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"
	Create_Thread("Thread_Mission_Failed")
end

function Death_Core()
	if TestValid(hero) then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_25"))
	end
	failure_text="TEXT_SP_MISSION_NVS06_OBJECTIVE_C_FAILED"
	Create_Thread("Thread_Mission_Failed")
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
	Play_Music("Lose_To_Alien_Event") -- this music is faction specific, use: UEA_Lose_Tactical_Event Alien_Lose_Tactical_Event Novus_Lose_Tactical_Event Masari_Lose_Tactical_Event
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
	Play_Music("Novus_Win_Tactical_Event") -- this music is faction specific, use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
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
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_AIRCRAFT_ASSEMBLY"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_CENTRAL_PROCESSOR"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_ROBOTIC_ASSEMBLY"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_INPUT_STATION"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_SIGNAL_TOWER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_MATERIAL_CENTER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_MEGAWEAPON"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_NANOCENTER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_POWER_ROUTER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_REDIRECTION_TURRET"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_REMOTE_TERMINAL"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_RESEARCH_CENTER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_SCIENCE_LAB"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_SUPERWEAPON_EMP"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_SUPERWEAPON_GRAVITY_BOMB"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_VEHICLE_ASSEMBLY"),boolean,STORY)
		
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_HERO_FOUNDER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_HERO_VERTIGO"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_AMPLIFIER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_ANTIMATTER_TANK"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_CORRUPTOR"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_DERVISH_JET"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_FIELD_INVERTER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_HACKER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_ROBOTIC_INFANTRY"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_REFLEX_TROOPER"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NOVUS_VARIANT"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NM04_NOVUS_PORTAL"),boolean,STORY)
		novus.Lock_Generator("VirusInfectAuraGenerator", false ,STORY)	
		novus.Lock_Generator("NovusResearchAdvancedFlowEffectGenerator", false ,STORY)
		
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Unit_Ability", false, STORY)
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Control_Turret_Area_Special_Ability", false, STORY)
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Special_Ability", false, STORY)
		

		novus.Lock_Generator("Resonance_Beam_Effect_Generator", false ,STORY)
		novus.Lock_Generator("Resonance_Cascade_Beam_Effect_Generator", false ,STORY)
		novus.Lock_Generator("Novus_Amplifier_Resonance_Weapon", false ,STORY)
		novus.Lock_Generator("Novus_Amplifier_Resonance_Cascade_Weapon", false ,STORY)
		novus.Lock_Generator("AmplifierResonanceBeamEffectGenerator", false ,STORY)
		novus.Lock_Generator("AmplifierCascadeResonanceBeamEffectGenerator", false ,STORY)
		
		novus.Lock_Unit_Ability("Novus_Hero_Founder", "Novus_Founder_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Vertigo", "Novus_Vertigo_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", boolean, STORY)
end



function Audio_Mission_Start()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE01_02"))
	end
	Sleep(1)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE01_03"))
	end
	Sleep(1)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_viktor, "NVS06_SCENE01_04"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE02_02"))
	end
	destroy_me = Create_Generic_Object(Find_Object_Type("NM06_MATERIAL_CONDUIT"),Find_Hint("NM06_MATERIAL_CONDUIT_FAKE", "destroyme").Get_Position(),neutral)
	Find_Hint("NM06_MATERIAL_CONDUIT_FAKE", "destroyme").Despawn()
	if TestValid(destroy_me) then
		destroy_me.Take_Damage(99999)
		Shake_Camera(2,2)
	end
	Sleep(3)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE01_01"))
	end
	audio_dialogue_start=true;
end

function Audio_Mission_Cores_Repaired()
	Shake_Camera(2, 2)
	Sleep(1)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE03_03"))
	end
	audio_dialogue_cores_repaired=true;
end

function Audio_Freed_Generic_Guys()
	if not objective_c_completed and audio_dialogue_start then
		if TestValid(hero) then
			if not mission_success and not mission_failure then
				pick=GameRandom(1,5)
				if pick==1 then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_12"))
				end
				if pick==2 then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_14"))
				end
				if pick==3 then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_16"))
				end
				if pick==4 then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_19"))
				end
				if pick==5 then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_20"))
				end
			end
		end
	end
end

function Audio_Freed_Constructors()
	if not objective_c_completed and audio_dialogue_start then
		if objective_a_completed and not objective_b_completed then
			if TestValid(hero) then
				if not mission_success and not mission_failure then
					pick=GameRandom(1,5)
					if pick==1 then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_22"))
					end
					if pick==2 then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_23"))
					end
					if pick==3 then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_24"))
					end
					if pick==4 then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_26"))
					end
					if pick==5 then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_27"))
					end
				end
			end
		else
			if TestValid(hero) then
				if not mission_success and not mission_failure then
					pick=GameRandom(1,5)
					if pick==1 then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_12"))
					end
					if pick==2 then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_14"))
					end
					if pick==3 then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_16"))
					end
					if pick==4 then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_19"))
					end
					if pick==5 then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_20"))
					end
				end
			end
		end
	end
end


function Audio_Cage_Doors_Sighted()
	if not objective_c_completed and audio_dialogue_start then
		if TestValid(hero) then
			if not mission_success and not mission_failure then
				pick=GameRandom(1,4)
				if pick==1 then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_13"))
				end
				if pick==2 then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_17"))
				end
				if pick==3 then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_15"))
				end
				if pick==4 then
					BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS06_SCENE04_18"))
				end
			end
		end
	end
end


function Post_Load_Callback()
	UI_Hide_Research_Button()
	UI_Hide_Sell_Button()
	Movie_Commands_Post_Load_Callback()
end

