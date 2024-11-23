-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM05.lua#60 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM05.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Dan_Etter $
--
--            $Change: 90396 $
--
--          $DateTime: 2008/01/07 13:51:24 $
--
--          $Revision: #60 $
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

	PGColors_Init_Constants()
--	aliens.Enable_Colorization(true, COLOR_RED)
--	novus.Enable_Colorization(true, COLOR_CYAN)
--	uea.Enable_Colorization(true, COLOR_GREEN)
		
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
		
		hero = Create_Generic_Object(Find_Object_Type("Novus_Hero_Mech"), Find_First_Object("MARKER_GENERIC_YELLOW").Get_Position(), novus) 
		-- heroes nerfed late, so adding damage modifier, Mirabel old health(1800) / Mirabel new health(1000) - 1 = -.45
		if TestValid(hero) then hero.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.45) end
		Point_Camera_At(hero)
		
	uea.Allow_AI_Unit_Behavior(false)
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
	--UI_Hide_Sell_Button()
	
	novus.Give_Money(15000)
	failure_text="TEXT_SP_MISSION_MISSION_FAILED"
	
	--define defeat condifition: hero dies
	Register_Death_Event(hero, Death_Hero)
	
	--define all ai controlled enemy units and markers
	manipulators_list=Find_All_Objects_Of_Type("ALIEN_GRAVITIC_MANIPULATOR")
	
	inverters_team=Find_All_Objects_With_Hint("goshield")
	defiler_list=Find_All_Objects_Of_Type("ALIEN_DEFILER")
	guards=Find_All_Objects_With_Hint("guard")
	guard_list=Find_All_Objects_Of_Type("ALIEN_RECON_TANK")
	support_list=Find_All_Objects_Of_Type("ALIEN_GRUNT")
	foo_list=Find_All_Objects_Of_Type("ALIEN_FOO_CORE")
		
	alien_arrival=Find_Hint("ALIEN_ARRIVAL_SITE", "alienarrival")
	alien_conduit=Find_Hint("NM06_MATERIAL_CONDUIT", "alienconduit")
	alien_conduit.Set_Cannot_Be_Killed(true)
	
	alienspawner=Find_Hint("MARKER_GENERIC", "alienspawner")
	mapcenter=Find_Hint("MARKER_GENERIC", "centerofmap")
	reinforce_uea_location=Find_Hint("MARKER_GENERIC", "reinforceuea")
	uea_intro=Find_Hint("MARKER_GENERIC", "militaryintro")
	
	walker1=Find_Hint("NM05_CUSTOM_ASSEMBLY_WALKER", "walker1")
	walker2=Find_Hint("NM05_CUSTOM_ASSEMBLY_WALKER", "walker2")
	walker1.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Death_Walker_1") 
	walker2.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Death_Walker_2") 
	walker1_dead=false
	walker2_dead=false
	
	max_power_attacks=1
	num_power_attacks=0
	
	beamfx=Find_Hint("NM05_BEAM_FX","beamfx")
	beamfx.Hide(true)

	objective_b_location_a=Find_Hint("MARKER_GENERIC", "objectiveba")
	objective_b_location_b=Find_Hint("MARKER_GENERIC", "objectivebb")
	objective_b_location_c=Find_Hint("MARKER_GENERIC", "objectivebc")
	objective_b_location_d=Find_Hint("MARKER_GENERIC", "objectivebd")
	objective_c_location=Find_Hint("MARKER_GENERIC", "objectivec")
	
	objective_b_despawner_aa=Find_Hint("MARKER_CIVILIAN_DESPAWNER", "despawner-aa")
	objective_b_despawner_ba=Find_Hint("MARKER_CIVILIAN_DESPAWNER", "despawner-ba")
	objective_b_despawner_ca=Find_Hint("MARKER_CIVILIAN_DESPAWNER", "despawner-ca")
	objective_b_despawner_da=Find_Hint("MARKER_CIVILIAN_DESPAWNER", "despawner-da")
	objective_b_despawner_ab=Find_Hint("MARKER_CIVILIAN_DESPAWNER", "despawner-ab")
	objective_b_despawner_bb=Find_Hint("MARKER_CIVILIAN_DESPAWNER", "despawner-bb")
	objective_b_despawner_cb=Find_Hint("MARKER_CIVILIAN_DESPAWNER", "despawner-cb")
	objective_b_despawner_db=Find_Hint("MARKER_CIVILIAN_DESPAWNER", "despawner-db")
	
	objective_b_chopper_aa=Find_Hint("MILITARY_APACHE", "chop-aa")
	objective_b_chopper_ab=Find_Hint("MILITARY_APACHE", "chop-ab")
	objective_b_chopper_ba=Find_Hint("MILITARY_APACHE", "chop-ba")
	objective_b_chopper_bb=Find_Hint("MILITARY_APACHE", "chop-bb")
	objective_b_chopper_ca=Find_Hint("MILITARY_APACHE", "chop-ca")
	objective_b_chopper_cb=Find_Hint("MILITARY_APACHE", "chop-cb")
	objective_b_chopper_da=Find_Hint("MILITARY_APACHE", "chop-da")
	objective_b_chopper_db=Find_Hint("MILITARY_APACHE", "chop-db")
	objective_b_chopper_aa.Suspend_Locomotor(true)
	objective_b_chopper_ab.Suspend_Locomotor(true)
	objective_b_chopper_ba.Suspend_Locomotor(true)
	objective_b_chopper_bb.Suspend_Locomotor(true)
	objective_b_chopper_ca.Suspend_Locomotor(true)
	objective_b_chopper_cb.Suspend_Locomotor(true)
	objective_b_chopper_da.Suspend_Locomotor(true)
	objective_b_chopper_db.Suspend_Locomotor(true)
	objective_b_chopper_aa.Prevent_All_Fire(true)
	objective_b_chopper_ab.Prevent_All_Fire(true)
	objective_b_chopper_ba.Prevent_All_Fire(true)
	objective_b_chopper_bb.Prevent_All_Fire(true)
	objective_b_chopper_ca.Prevent_All_Fire(true)
	objective_b_chopper_cb.Prevent_All_Fire(true)
	objective_b_chopper_da.Prevent_All_Fire(true)
	objective_b_chopper_db.Prevent_All_Fire(true)
	
	Register_Death_Event(objective_b_chopper_aa, Death_Chopper)
	Register_Death_Event(objective_b_chopper_ab, Death_Chopper)
	Register_Death_Event(objective_b_chopper_ba, Death_Chopper)
	Register_Death_Event(objective_b_chopper_bb, Death_Chopper)
	Register_Death_Event(objective_b_chopper_ca, Death_Chopper)
	Register_Death_Event(objective_b_chopper_cb, Death_Chopper)
	Register_Death_Event(objective_b_chopper_da, Death_Chopper)
	Register_Death_Event(objective_b_chopper_db, Death_Chopper)
	choppers_destroyed=0;

	objective_b_turrets_a = Find_All_Objects_With_Hint("turretsba")
	objective_b_turrets_b = Find_All_Objects_With_Hint("turretsbb")
	objective_b_turrets_c = Find_All_Objects_With_Hint("turretsbc")
	objective_b_turrets_d = Find_All_Objects_With_Hint("turretsbd")
	
	turret_aa=Find_Hint("ALIEN_RADIATION_SPITTER", "turretaa")
	turret_ab=Find_Hint("ALIEN_RADIATION_SPITTER", "turretab")
	turret_ac=Find_Hint("ALIEN_RADIATION_SPITTER", "turretac")
	turret_ba=Find_Hint("ALIEN_RADIATION_SPITTER", "turretba")
	turret_bb=Find_Hint("ALIEN_RADIATION_SPITTER", "turretbb")
	turret_ca=Find_Hint("ALIEN_RADIATION_SPITTER", "turretca")
	turret_cb=Find_Hint("ALIEN_RADIATION_SPITTER", "turretcb")
	turret_da=Find_Hint("ALIEN_RADIATION_SPITTER", "turretda")
	turret_db=Find_Hint("ALIEN_RADIATION_SPITTER", "turretdb")
	turret_cluster_a=Find_Hint("MARKER_GENERIC", "turretclustera")
	turret_cluster_b=Find_Hint("MARKER_GENERIC", "turretclusterb")
	turret_cluster_c=Find_Hint("MARKER_GENERIC", "turretclusterc")
	turret_cluster_d=Find_Hint("MARKER_GENERIC", "turretclusterd")
	
	Register_Prox(turret_cluster_a, Prox_Radiation_Audio, 100, novus)
	Register_Prox(turret_cluster_b, Prox_Radiation_Audio, 100, novus)
	Register_Prox(turret_cluster_c, Prox_Radiation_Audio, 100, novus)
	Register_Prox(turret_cluster_d, Prox_Radiation_Audio, 100, novus)

	novusbase=Find_Hint("MARKER_GENERIC","novusbase")
	
	_CustomScriptMessage("JoeLog.txt", string.format("***************************Setup End"))
	
	audio_dialogue_enter_moore=false;
	audio_dialogue_end_mission=false;
	audio_dialogue_choppers_freed=false;
	audio_dialogue_turrets_down=false;
	turrets_destroyed=false;
	radiation_turrets_seen=false
	
	--define all game objective flags
	objective_a_completed=false;
	objective_b_completed=false;
	objective_c_completed=false;
	base_built=false;
	aided_uea_a=false;
	aided_uea_b=false;
	aided_uea_c=false;
	aided_uea_d=false;
	moore_got_out=false;
	reached_uplink=false;
	
	Setup_Choppers()
	
	-- setting up faction relationships so no one acts out of character
	novus.Make_Ally(civilian)
	civilian.Make_Ally(novus)
	novus.Make_Ally(uea)
	uea.Make_Ally(novus)
	uea.Make_Ally(civilian)
	civilian.Make_Ally(uea)
	
	mission_success = false
	mission_failure = false
	time_objective_sleep = 5
	time_radar_sleep = 2
	reminder_wait_time = 30
	
	--set low civ population on large maps (esp single player)
	Spawn_Civilians_Automatically(true)
	Set_Desired_Civilian_Population(25)
	Make_Civilians_Panic(mapcenter, 9999)
	
	novus.Give_Money(10000)

	Fade_Screen_In(1)
	
	Create_Thread("Setup_Defilers")
	Create_Thread("Setup_Foo_Cores")
	Create_Thread("Setup_Guards")
	Setup_Field_Inverters()
	
	-- show mission objective a and wait for it to be triggered
	Point_Camera_At(hero)
	Lock_Controls(1)
	Fade_Screen_Out(0)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	Transition_Cinematic_Target_Key(hero, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(hero, 0, 200, 55, 65, 1, 0, 0, 0)
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
	Show_Objective_A()
	--UI_Start_Flash_Queue_Buttons ("NOVUS_AIRCRAFT_ASSEMBLY", "NOVUS_SCIENCE_LAB")
	
	Create_Thread("Track_Enemy_Turrets")
	
	while not(objective_a_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			novus_built_labs = Find_All_Objects_Of_Type("NOVUS_SCIENCE_LAB")
			novus_built_air = Find_All_Objects_Of_Type("NOVUS_AIRCRAFT_ASSEMBLY")
			if not base_built then
				if table.getn(novus_built_labs)>0 and table.getn(novus_built_air)>0 then
					base_built = true
				end
			else
				Set_Objective_Text(nov05_objective_a, "TEXT_SP_MISSION_NVS05_OBJECTIVE_A")
				Objective_Complete(nov05_objective_a)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS05_OBJECTIVE_A_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_a_completed=true;
			end
		end
	end
	
	--Col Moore shows up with his compadre of ground troops
	Create_Thread("Reinforce_UEA")
	while not audio_dialogue_enter_moore do
		Sleep(1)
	end
	
	Create_Thread("Flash_Patches")
	
	-- show mission objective b and wait for it to be triggered
	Show_Objective_B()
	Create_Thread("Thread_Track_Objective_B")
	Create_Thread("Send_Power_Attacks")
	
	while not(objective_b_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if aided_uea_a and aided_uea_b and aided_uea_c and aided_uea_d then
				Set_Objective_Text(nov05_objective_b, "TEXT_SP_MISSION_NVS05_OBJECTIVE_B_STATE_2")
				Objective_Complete(nov05_objective_b)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS05_OBJECTIVE_B_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_b_completed=true;
				
				Create_Thread("Military_Retreats")
			end
		end
	end
	
	Create_Thread("Audio_Choppers_Freed")
	while not audio_dialogue_choppers_freed do
		Sleep(1)
	end

	Show_Objective_B_Sub()
	
	while not(objective_bsub_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if(walker1_dead or walker2_dead) then
				Set_Objective_Text(nov05_objective_bsub, "TEXT_SP_MISSION_NVS05_OBJECTIVE_BSUB_STATE_2")
			end
			if(walker1_dead and walker2_dead) then
				Remove_Radar_Blip("blip_objective_bsub")
				Set_Objective_Text(nov05_objective_bsub, "TEXT_SP_MISSION_NVS05_OBJECTIVE_BSUB")
				Objective_Complete(nov05_objective_bsub)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS05_OBJECTIVE_BSUB_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_bsub_completed=true;
			end
		end
	end
	
	-- show mission objective c and allow it to be triggered
	Show_Objective_C()
	Register_Prox(objective_c_location, Prox_Objective_C, 150, novus)
	
	while not(objective_c_completed) do
		Sleep(1)
		if not mission_success and not mission_failure then
			if(reached_uplink) then
				Remove_Radar_Blip("blip_objective_c")
				objective_c_location.Highlight(true)
				Set_Objective_Text(nov05_objective_c, "TEXT_SP_MISSION_NVS05_OBJECTIVE_C")
				Objective_Complete(nov05_objective_c)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS05_OBJECTIVE_C_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				objective_c_completed=true;
			end
		end
	end
	
	hero.Set_Cannot_Be_Killed(true)
	while not audio_dialogue_turrets_down do
		Sleep(1)
	end
	
	-- all objectives complete, win the mission
	Create_Thread("Audio_Mission_Ending")
	while not audio_dialogue_end_mission do
		Sleep(1)
	end
	mission_success = true
	Create_Thread("Thread_Mission_Complete")
	
end

function Flash_Patches()
	Add_Independent_Hint(HINT_NM05_PATCHES)  --PUT THIS BACK IN!!!!
	UI_Start_Patch_Menu_Button_Flash()
	Sleep(10)
	UI_Stop_Patch_Menu_Button_Flash()
end

function Setup_Choppers()
	choppers=Find_All_Objects_Of_Type("MILITARY_APACHE")
	for units, unit in pairs(choppers) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			unit.Play_Animation("Anim_Move",true)
		end
	end
end

function Setup_Field_Inverters()
	for units, unit in pairs(inverters_team) do
		if TestValid(unit) then
			unit.Activate_Ability("Novus_Inverter_Toggle_Shield_Mode", true)
		end
	end
end
	
-- this script spawns some foo saucers to attack the player's power systems
function Send_Power_Attacks()
	while (num_power_attacks>max_power_attacks) do
		Sleep(2)
	end
	if true then
		if not mission_success and not mission_failure then
			alien_forces = { "ALIEN_FOO_CORE", "ALIEN_FOO_CORE", "ALIEN_FOO_CORE",
							"ALIEN_FOO_CORE", "ALIEN_FOO_CORE",
							"ALIEN_CYLINDER", "ALIEN_CYLINDER", "ALIEN_CYLINDER"  }
			strike_power = SpawnList(alien_forces, alienspawner.Get_Position(), aliens)
			Create_Thread("Thread_Power_Strike_AI",strike_power)
		end
	end
end

function Thread_Power_Strike_AI(team)
	local maxair=0
	local air=0
	local team_disband=false
	local air_switch=false
	air=table.getn(team)
	maxair=air
	--Hunt(object_or_table, [priorities, allow_wander, respect_fog, constraint_center, constraint_radius])
	power=Find_Nearest(alienspawner,"NOVUS_POWER_ROUTER")
	Hunt(team, "Nov05_Power_Attack_Priorities", false, false,power,200)
	while not team_disband do
		air=0
		airhull=0
		for units, unit in pairs(team) do
			if TestValid(unit) then
				air=air+1
				airhull=airhull+unit.Get_Hull()
				if air_switch then
					if unit.Get_Type()==Find_Object_Type("ALIEN_FOO_CORE") then
						if unit.Is_Ability_Active("Unit_Ability_Foo_Core_Heal_Attack_Toggle") then
							if GameRandom(1,2)==1 then
								unit.Activate_Ability("Unit_Ability_Foo_Core_Heal_Attack_Toggle", true)
							end
						end
					end
				else 
					if unit.Get_Type()==Find_Object_Type("ALIEN_FOO_CORE") then
						if unit.Is_Ability_Active("Unit_Ability_Foo_Core_Heal_Attack_Toggle") then
							if GameRandom(1,2)==1 then
								unit.Activate_Ability("Unit_Ability_Foo_Core_Heal_Attack_Toggle", false)
							end
						end
					end
				end
			end
		end
		if airhull<(air*.80) then air_switch = true end
		if airhull>(air*.80) then air_switch = false end
		if air<1 then 
			team_disband = true 
			num_power_attacks=num_power_attacks-1
		end
		Sleep(1)
	end
		
end

function Setup_Guards()
	for units, unit in pairs(guards) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",true,false,unit,75)
		end
	end
	for units, unit in pairs(guard_list) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",false,false,unit,350)
		end
	end
	for units, unit in pairs(support_list) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			Hunt(unit,"PrioritiesLikeOneWouldExpectThemToBe",false,false,unit,350)
		end
	end
end

function Setup_Foo_Cores()
	for units, unit in pairs(foo_list) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			unit.Activate_Ability("Unit_Ability_Foo_Core_Heal_Attack_Toggle", true)
			Hunt(unit,true,true,unit,250)
		end
	end
end

function Setup_Defilers()
	for units, unit in pairs(defiler_list) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			unit.Activate_Ability("Defiler_Radiation_Bleed", true)
			Hunt(unit,true,true,unit,300)
		end
	end
end

function Military_Retreats()
	if TestValid(moore) then moore.Set_Cannot_Be_Killed(true) end
	military_forces=Find_All_Objects_Of_Type(uea, "CanAttack")
	for units, unit in pairs(military_forces) do
		if TestValid(unit) then
			unit.Move_To(reinforce_uea_location)
		end
	end
	Register_Prox(reinforce_uea_location, Prox_Military_Retreat, 75, uea)
	while (TestValid(Find_First_Object("MILITARY_TEAM_MARINES", uea))) do
		Sleep(3)
	end
end

function Prox_Foos_Turn(prox_obj, trigger_obj)
	if TestValid(trigger_obj) then
		if trigger_obj.Get_Type()==Find_Object_Type("ALIEN_FOO_CORE") then
			if trigger_obj.Is_Ability_Active("Unit_Ability_Foo_Core_Heal_Attack_Toggle") then
				trigger_obj.Activate_Ability("Unit_Ability_Foo_Core_Heal_Attack_Toggle", false)
				Hunt(trigger_obj,"Nov05_Saucer_Attack_Priorities",true,false)
			end
		end
	end
end

function Prox_Choppers_Retreat(prox_obj, trigger_obj)
	if TestValid(trigger_obj) then
		if trigger_obj==objective_b_chopper_aa or trigger_obj==objective_b_chopper_ab or 
			trigger_obj==objective_b_chopper_ba or trigger_obj==objective_b_chopper_bb or 
			trigger_obj==objective_b_chopper_ca or trigger_obj==objective_b_chopper_cb or 
			trigger_obj==objective_b_chopper_da or trigger_obj==objective_b_chopper_db then
			trigger_obj.Despawn()
		end
	end
end

function Prox_Military_Retreat(prox_obj, trigger_obj)
	if TestValid(trigger_obj) then
		if trigger_obj==moore then
			moore_got_out=true
		end
		if trigger_obj.Get_Owner()==use then
			trigger_obj.Despawn()
		end
	end
end

-- adds mission objective for objective A
function Show_Objective_A()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS05_OBJECTIVE_A_ADD"} )
	Sleep(time_objective_sleep)
	nov05_objective_a = Add_Objective("TEXT_SP_MISSION_NVS05_OBJECTIVE_A")
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

-- adds mission objective and radar blips for objective B
function Show_Objective_B()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS05_OBJECTIVE_B_ADD"} )
	Sleep(time_radar_sleep)
	nov05_objective_b = Add_Objective("TEXT_SP_MISSION_NVS05_OBJECTIVE_B_STATE_1")
	Add_Radar_Blip(objective_b_location_a, "DEFAULT", "blip_objective_ba")
	Add_Radar_Blip(objective_b_location_b, "DEFAULT", "blip_objective_bb")
	Add_Radar_Blip(objective_b_location_c, "DEFAULT", "blip_objective_bc")
	Add_Radar_Blip(objective_b_location_d, "DEFAULT", "blip_objective_bd")
	for turrets, unit in pairs(objective_b_turrets_a) do
		if TestValid(unit) then
			unit.Highlight(true,-50)
		end
	end
	for turrets, unit in pairs(objective_b_turrets_b) do
		if TestValid(unit) then
			unit.Highlight(true,-50)
		end
	end
	for turrets, unit in pairs(objective_b_turrets_c) do
		if TestValid(unit) then
			unit.Highlight(true,-50)
		end
	end
	for turrets, unit in pairs(objective_b_turrets_d) do
		if TestValid(unit) then
			unit.Highlight(true,-50)
		end
	end
	objective_b_chopper_aa.Add_Reveal_For_Player(novus)
	objective_b_chopper_ab.Add_Reveal_For_Player(novus)
	objective_b_chopper_ba.Add_Reveal_For_Player(novus)
	objective_b_chopper_bb.Add_Reveal_For_Player(novus)
	objective_b_chopper_ca.Add_Reveal_For_Player(novus)
	objective_b_chopper_cb.Add_Reveal_For_Player(novus)
	objective_b_chopper_da.Add_Reveal_For_Player(novus)
	objective_b_chopper_db.Add_Reveal_For_Player(novus)
	Sleep(time_objective_sleep-time_radar_sleep)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

--keeps track of objective b, turning off radar pings and letting main thread know when all turrets destroyed
function Thread_Track_Objective_B()
	local check_again=true
	aided_uea_zones=0;
	last_aided_zone=nil
	while not aided_uea do
		if (not aided_uea_a) and (check_again) then
			turrets_left = false
			for turrets, unit in pairs(objective_b_turrets_a) do
				if TestValid(unit) then
					turrets_left = true
				end
			end
			if not turrets_left then
				aided_uea_a = true
				Remove_Radar_Blip("blip_objective_ba")
				aided_uea_zones=aided_uea_zones+1
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS05_OBJECTIVE_B")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(aided_uea_zones), 1)
				Set_Objective_Text(nov05_objective_b, out_string)
				last_aided_zone=objective_b_location_a
				Register_Prox(last_aided_zone, Prox_Foos_Turn, 250, aliens)
				objective_b_chopper_aa.Suspend_Locomotor(false)
				objective_b_chopper_ab.Suspend_Locomotor(false)
				objective_b_chopper_aa.Change_Owner(uea)
				objective_b_chopper_ab.Change_Owner(uea)
				objective_b_chopper_aa.Guard_Target(novusbase)
				objective_b_chopper_ab.Guard_Target(novusbase)
				objective_b_chopper_aa.Set_Service_Only_When_Rendered(false)
				objective_b_chopper_ab.Set_Service_Only_When_Rendered(false)
				num_power_attacks=num_power_attacks+1
				Create_Thread("Send_Power_Attacks")
				check_again=false
			end
		end
		if (not aided_uea_b) and (check_again) then
			turrets_left = false
			for turrets, unit in pairs(objective_b_turrets_b) do
				if TestValid(unit) then
					turrets_left = true
				end
			end
			if not turrets_left then
				aided_uea_b = true
				Remove_Radar_Blip("blip_objective_bb")
				aided_uea_zones=aided_uea_zones+1
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS05_OBJECTIVE_B")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(aided_uea_zones), 1)
				Set_Objective_Text(nov05_objective_b, out_string)
				last_aided_zone=objective_b_location_b
				Register_Prox(last_aided_zone, Prox_Foos_Turn, 250, aliens)
				objective_b_chopper_ba.Suspend_Locomotor(false)
				objective_b_chopper_bb.Suspend_Locomotor(false)
				objective_b_chopper_ba.Change_Owner(uea)
				objective_b_chopper_bb.Change_Owner(uea)
				objective_b_chopper_ba.Guard_Target(novusbase)
				objective_b_chopper_bb.Guard_Target(novusbase)
				objective_b_chopper_ba.Set_Service_Only_When_Rendered(false)
				objective_b_chopper_bb.Set_Service_Only_When_Rendered(false)
				num_power_attacks=num_power_attacks+1
				Create_Thread("Send_Power_Attacks")
				check_again=false
			end
		end
		if (not aided_uea_c) and (check_again) then
			turrets_left = false
			for turrets, unit in pairs(objective_b_turrets_c) do
				if TestValid(unit) then
					turrets_left = true
				end
			end
			if not turrets_left then
				aided_uea_c = true
				Remove_Radar_Blip("blip_objective_bc")
				aided_uea_zones=aided_uea_zones+1
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS05_OBJECTIVE_B")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(aided_uea_zones), 1)
				Set_Objective_Text(nov05_objective_b, out_string)
				last_aided_zone=objective_b_location_c
				Register_Prox(last_aided_zone, Prox_Foos_Turn, 250, aliens)
				objective_b_chopper_ca.Suspend_Locomotor(false)
				objective_b_chopper_cb.Suspend_Locomotor(false)
				objective_b_chopper_ca.Change_Owner(uea)
				objective_b_chopper_cb.Change_Owner(uea)
				objective_b_chopper_ca.Guard_Target(novusbase)
				objective_b_chopper_cb.Guard_Target(novusbase)
				objective_b_chopper_ca.Set_Service_Only_When_Rendered(false)
				objective_b_chopper_cb.Set_Service_Only_When_Rendered(false)
				num_power_attacks=num_power_attacks+1
				Create_Thread("Send_Power_Attacks")
				check_again=false
			end
		end
		if (not aided_uea_d) and (check_again) then
			turrets_left = false
			for turrets, unit in pairs(objective_b_turrets_d) do
				if TestValid(unit) then
					turrets_left = true
				end
			end
			if not turrets_left then
				aided_uea_d = true
				Remove_Radar_Blip("blip_objective_bd")
				aided_uea_zones=aided_uea_zones+1
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS05_OBJECTIVE_B")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(aided_uea_zones), 1)
				Set_Objective_Text(nov05_objective_b, out_string)
				last_aided_zone=objective_b_location_d
				Register_Prox(last_aided_zone, Prox_Foos_Turn, 250, aliens)
				objective_b_chopper_da.Suspend_Locomotor(false)
				objective_b_chopper_db.Suspend_Locomotor(false)
				objective_b_chopper_da.Change_Owner(uea)
				objective_b_chopper_db.Change_Owner(uea)
				objective_b_chopper_da.Guard_Target(novusbase)
				objective_b_chopper_db.Guard_Target(novusbase)
				objective_b_chopper_da.Set_Service_Only_When_Rendered(false)
				objective_b_chopper_db.Set_Service_Only_When_Rendered(false)
				num_power_attacks=num_power_attacks+1
				Create_Thread("Send_Power_Attacks")
				check_again=false
			end
		end
		Sleep(1)
		check_again=true
	end
end

function Track_Enemy_Turrets()
	while not turrets_destroyed do
		if  (not TestValid(turret_aa) and not TestValid(turret_ab) and not TestValid(turret_ac)) or
			(not TestValid(turret_ba) and not TestValid(turret_bb)) or
			(not TestValid(turret_ca) and not TestValid(turret_cb)) or
			(not TestValid(turret_da) and not TestValid(turret_db)) then
			if not mission_success and not mission_failure then
				turrets_destroyed=true
				Create_Thread("Audio_Defenses_Down")
			end
		end
		Sleep(1)
	end
end

function Moore_Health_Tracker()
	local lasthealth=1
	while not objective_b_completed do
		if TestValid(moore) then
			local health=moore.Get_Hull()
			if not mission_success and not mission_failure then
				if health<.25 and lasthealth>health then
					if TestValid(moore) then
						BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE03_16"))
					end
					if TestValid(hero) then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_17"))
					end
					lasthealth=0
				end
			end
			if not mission_success and not mission_failure then
				if health<.5 and lasthealth>health then
					if TestValid(hero) then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_14"))
					end
					if TestValid(moore) then
						BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE03_15"))
					end
					lasthealth=.25
				end
			end
			if not mission_success and not mission_failure then
				if health<.75 and lasthealth>health then
					if TestValid(hero) then
						BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_12"))
					end
					if TestValid(moore) then
						BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE03_13"))
					end
					lasthealth=.5
				end	
			end
			Sleep(1)
		end
		Sleep(1)
	end
end

function Show_Objective_B_Sub()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS05_OBJECTIVE_BSUB_ADD"} )
	Sleep(time_objective_sleep)
	nov05_objective_bsub = Add_Objective("TEXT_SP_MISSION_NVS05_OBJECTIVE_BSUB_STATE_1")
	if TestValid(walker1) then Add_Radar_Blip(walker1, "DEFAULT", "blip_objective_bsub_1") end
	if TestValid(walker2) then Add_Radar_Blip(walker2, "DEFAULT", "blip_objective_bsub_2") end
	--Sleep(time_objective_sleep-time_radar_sleep)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )

	if TestValid(walker1) then Create_Thread("Thread_Assembly_Walker_Produce",{walker1,2}) end
	if TestValid(walker2) then Create_Thread("Thread_Assembly_Walker_Produce",{walker2,2}) end
	Create_Thread("Thread_Assembly_Walker_Produced_Hunt")
end

-- adds mission objective and radar blip for objective C
function Show_Objective_C()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS05_OBJECTIVE_C_ADD"} )
	Sleep(time_radar_sleep)
	nov05_objective_c = Add_Objective("TEXT_SP_MISSION_NVS05_OBJECTIVE_C")
	Add_Radar_Blip(objective_c_location, "DEFAULT", "blip_objective_c")
	objective_c_location.Highlight(true)
	Sleep(time_objective_sleep-time_radar_sleep)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

-- triggers when player reaches obj C
function Prox_Objective_C(prox_obj, trigger_obj)
	if trigger_obj.Get_Type()==Find_Object_Type("NOVUS_HERO_MECH") then
		reached_uplink=true;
		prox_obj.Cancel_Event_Object_In_Range(Prox_Objective_C)
	end
end

--spawns col moore and his ground forces
function Reinforce_UEA()
	
	if not mission_success and not mission_failure then
		uea_forces = { "Military_Hero_General_Randal_Moore", "MILITARY_TEAM_MARINES", "MILITARY_TEAM_MARINES", 
					"MILITARY_TEAM_MARINES", "MILITARY_TEAM_MARINES", "MILITARY_TEAM_MARINES" }
		
		military_forces = SpawnList(uea_forces, reinforce_uea_location.Get_Position(), uea)
		
		--define defeat condifition: hero dies
		moore = Find_First_Object("Military_Hero_General_Randal_Moore")
		moore.Set_Cannot_Be_Killed(true)
		--Add_Radar_Blip(moore, "DEFAULT", "blip_objective_b_primary")
		--moore.Highlight_Small(true, -50)
		Register_Death_Event(moore, Death_Moore)
		Create_Thread("Moore_Health_Tracker")
		
		for forces, unit in pairs(military_forces) do
			unit.Move_To(uea_intro)
		end
		
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS05_SCENE06_01"))
		end
		if not mission_success and not mission_failure then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE06_02"))
		end
		
		Register_Prox(uea_intro, Prox_Military_Arrives, 100, uea)
		while not military_arrived do
			Sleep(2)
		end
		
		Create_Thread("Audio_Enter_Moore")
		while not audio_dialogue_enter_moore do
			Sleep(1)
		end
		
		if TestValid(hero) then
			for forces, unit in pairs(military_forces) do
				unit.Guard_Target(hero)
			end
		end
		--Hunt(military_forces, "Nov05_Military_Attack_Priorities", false, false, hero, 200)
		Register_Prox(reinforce_uea_location, Prox_Choppers_Retreat, 75, uea)
	end
end

function Prox_Military_Arrives(prox_obj, trigger_obj)
	if trigger_obj.Get_Type()==Find_Object_Type("Military_Hero_General_Randal_Moore") then
		military_arrived=true;
		prox_obj.Cancel_Event_Object_In_Range(Prox_Military_Arrives)
	end
end

--on hero death, force defeat
function Death_Hero()
	Queue_Talking_Head(pip_novcomm, "NVS01_SCENE06_14")
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"
	Create_Thread("Thread_Mission_Failed")
end

function Death_Chopper()
	choppers_destroyed=choppers_destroyed+1
	if TestValid(hero) and false then
		if choppers_destroyed==1 then
			Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_22")
		end
		if choppers_destroyed==2 then
			Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_10")
		end
		if choppers_destroyed==3 then
			Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_20")
		end
		if choppers_destroyed==5 then
			Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_19")
		end
		if choppers_destroyed==7 then
			Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_21")
		end
	end
end

function Thread_Assembly_Walker_Produced_Hunt()
	while not walkera_alldead do
		defilers=Find_All_Objects_Of_Type("ALIEN_DEFILER")
		for i, unit in pairs(defilers) do
			unit.Guard_Target(novusbase7)
		end
		Sleep(GameRandom(5,7))
	end
end

function Thread_Assembly_Walker_Produce(params)
	local walker_obj,number = params[1],params[2]
	local prod_unit=Find_Object_Type("ALIEN_DEFILER")
	local prod_num=5
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
		end
		Sleep(GameRandom(4,5))
	end
end

function Death_Walker_1()
	walker1_dead=true
end

function Death_Walker_2()
	walker2_dead=true
end

--on hero death, force defeat
function Death_Moore()
	if not moore_got_out then
		if TestValid(hero) then
			BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_18"))
		end
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
	--Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
	Play_Music("Novus_Win_Tactical_Event") -- this music is faction specific, use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
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
		novus.Lock_Unit_Ability("Novus_Hero_Founder", "Novus_Founder_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Vertigo", "Novus_Vertigo_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Object_Type(Find_Object_Type("NM04_NOVUS_PORTAL"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("Novus_Superweapon_Gravity_Bomb"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("Novus_Science_Lab_Upgrade_Singularity_Processor"),boolean,STORY)
		novus.Lock_Generator("VirusInfectAuraGenerator", false ,STORY)	
		novus.Lock_Generator("NovusResearchAdvancedFlowEffectGenerator", false ,STORY)

		novus.Lock_Generator("Resonance_Beam_Effect_Generator", false ,STORY)
		novus.Lock_Generator("Resonance_Cascade_Beam_Effect_Generator", false ,STORY)
		novus.Lock_Generator("Novus_Amplifier_Resonance_Weapon", false ,STORY)
		novus.Lock_Generator("Novus_Amplifier_Resonance_Cascade_Weapon", false ,STORY)
		novus.Lock_Generator("AmplifierResonanceBeamEffectGenerator", false ,STORY)
		novus.Lock_Generator("AmplifierCascadeResonanceBeamEffectGenerator", false ,STORY)
		
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Unit_Ability", false, STORY)
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Control_Turret_Area_Special_Ability", false, STORY)
		novus.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Special_Ability", false, STORY)
		
		aliens.Lock_Unit_Ability("Alien_Brute", "Brute_Death_From_Above", false, STORY) 
end


function Audio_Mission_Start()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_02"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_01"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE02_01"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_viktor, "NVS05_SCENE02_02"))
	end
end

function Prox_Radiation_Audio(prox_obj, trigger_obj)
	if objective_a_completed and not objective_c_completed then
		if TestValid(hero) and not radiation_turrets_seen then
			if not mission_success and not mission_failure then
				pick=GameRandom(1,2)
				if pick==1 then
					Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_30")
				end
				if pick==2 then
					Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_31")
				end
				radiation_turrets_seen=true
			end
		end
	end
	prox_obj.Cancel_Event_Object_In_Range(Prox_Radiation_Audio)
end

function Audio_Enter_Moore()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE04_01"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE04_02"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE04_03"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE04_04"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE04_05"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE04_06"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE04_07"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE04_08"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE04_09"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE04_10"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE04_11"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE04_12"))
	end
	audio_dialogue_enter_moore=true
end


function Audio_Choppers_Freed()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_moore, "NVS05_SCENE03_23"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_24"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_25"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_29"))
	end
	audio_dialogue_choppers_freed=true	
end

function Audio_Defenses_Down()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_32"))
	end
	--if not mission_success and not mission_failure then
	--	BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_33"))
	--end
	--if not mission_success and not mission_failure then
	--	BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_34"))
	--end
	audio_dialogue_turrets_down=true	
end

function Audio_Mission_Ending()
	Lock_Controls(1)
	Start_Cinematic_Camera()
	Point_Camera_At(objective_c_location)
	Transition_To_Tactical_Camera(1)
	hero.Set_Selectable(false)
	hero.Set_Cannot_Be_Killed(true)
	
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
	
	conduit=Create_Generic_Object(Find_Object_Type("NM06_Material_Conduit_Fake"),alien_conduit.Get_Position(),neutral)
	alien_conduit.Despawn()
	hero.Move_To(objective_c_location)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS05_SCENE05_01"))
	end
	End_Cinematic_Camera()
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS05_SCENE05_02"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS05_SCENE05_03"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS05_SCENE05_04"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS05_SCENE05_05"))
	end
	beamfx.Hide(false)
	Sleep(1)
	hero.Hide(true)
	audio_dialogue_end_mission=true	
end

function Post_Load_Callback()
	UI_Hide_Research_Button()
	Movie_Commands_Post_Load_Callback()
end

