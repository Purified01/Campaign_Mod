 -- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM07.lua#53 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM07.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Jeff_Stewart $
--
--            $Change: 85498 $
--
--          $DateTime: 2007/10/04 15:22:34 $
--
--          $Revision: #53 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGMoveUnits")
require("PGUICommands")
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
require("PGBaseDefinitions")

require("SuperweaponsControl")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	alientwo = Find_Player("Alien_ZM06_KamalRex")
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
	pip_vertigo = "NH_Vertigo_pip_Head.alo"
	pip_founder = "NH_Founder_pip_Head.alo"
	pip_novscience = "NI_Science_Officer_pip_Head.alo"
	pip_novcomm = "NI_Comm_Officer_pip_Head.alo"

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
		
		--hero_start_pos = Find_Hint("MARKER_INVADER_CREATION_POSITION","nm07")
		--hero = Create_Generic_Object(Find_Object_Type("Novus_Hero_Mech"), hero_start_pos, novus) 
		
	uea.Allow_AI_Unit_Behavior(false)
	aliens.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	alientwo.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
			
		Fade_Screen_Out(0)
		Create_Thread("Thread_Mission_Start")
	
	elseif message == OnUpdate then
	end
end


--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script
function Thread_Mission_Start()
	-- display intro cinematic
	Fade_Out_Music()
    BlockOnCommand(Play_Bink_Movie("Novus_M7_S1",true))
    
	Set_Active_Context("NM07_StoryCampaign")
	
	Import_Base_From_Global()
	novus.Reset_Story_Locks()
	Lock_Objects(true)
	UI_Hide_Research_Button()
	--UI_Hide_Sell_Button()

	failure_text="TEXT_SP_MISSION_MISSION_FAILED"
	
	hero = Find_Hint("Novus_Hero_Mech","mirabel7")
	-- heroes nerfed late, so adding damage modifier, Mirabel old health(1800) / Mirabel new health(1000) - 1 = -.45
	if TestValid(hero) then hero.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.45) end
	hero.Suspend_Locomotor(true)
	vertigo = Find_Hint("NOVUS_HERO_VERTIGO","vertigo")
	-- heroes nerfed late, so adding damage modifier, Vertigo old health(1000) / Vertigo new health(700) - 1 = -.3
	if TestValid(vertigo) then vertigo.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.3) end
	founder = Find_First_Object("Novus_Hero_Founder")
	-- heroes nerfed late, so adding damage modifier, Founder old health(1400) / Founder new health(600/900) - 1 = -.58
	if TestValid(founder) then founder.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.58) end
	moore = Find_First_Object("Military_Hero_General_Randal_Moore")
	moore.Set_Cannot_Be_Killed(true)
	Hunt(moore, "PrioritiesLikeOneWouldExpectThemToBe", false, true, moore, 200)
	
	portal = Find_Hint("NM04_NOVUS_PORTAL", "portal")
	--novusbase7=Find_Hint("MARKER_GENERIC", "novusbase7")
	
	novusbaseattack=Find_All_Objects_With_Hint("novusbase7")
	
	dialogue_radiation=false
	dialogue_assembly_a=false
	dialogue_troop_a=false
	dialogue_science_a=false
	dialogue_science_b=false
	
	--define defeat condifition: hero dies
	Register_Death_Event(hero, Death_Hero_Mech)
	Register_Death_Event(vertigo, Death_Hero_Vertigo)
	Register_Death_Event(founder, Death_Hero_Founder)
	Register_Death_Event(moore, Death_Hero_Moore)
	
	Register_Death_Event(portal, Death_Hero_Portal)
	
	bldg1=Find_Hint("_WAREHOUSE_06","building1")
	bldg1.Take_Damage(9999)
	bldg2=Find_Hint("_WAREHOUSE_04","building2")
	bldg2.Take_Damage(9999)
	
	novus_base=Find_Hint("MARKER_GENERIC","novusbase")
	
	at_spawns=Find_All_Objects_With_Hint("zrh-form-spawn")
	at_formup_a=Find_All_Objects_With_Hint("zrh-form-6")
	at_formup_b=Find_All_Objects_With_Hint("zrh-form-5")
	at_formup_c=Find_All_Objects_With_Hint("zrh-form-4")
	at_formup_d=Find_All_Objects_With_Hint("zrh-form-3")
	at_formup_e=Find_All_Objects_With_Hint("zrh-form-2")
	at_formup_f=Find_All_Objects_With_Hint("zrh-form-1")
	at_formup_time=75
	
	assets=Find_All_Objects_Of_Type("NM07_CUSTOM_ASSEMBLY_WALKER")
	for i, unit in pairs(assets) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
		end
	end
	assets=Find_All_Objects_Of_Type("NM07_CUSTOM_HABITAT_WALKER")
	for i, unit in pairs(assets) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
		end
	end
	assets=Find_All_Objects_Of_Type("NM07_CUSTOM_SCIENCE_WALKER")
	for i, unit in pairs(assets) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
		end
	end
	
	walkers_dead=false
	
	obj_a_walkers=2
	obj_b_walkers=2
	obj_c_walkers=3
	walkera_dead=0
	walkera_alldead=false
	walkerb_dead=0
	walkerb_alldead=false
	walkerc_dead=0
	walkerc_alldead=false
	
	objective_a_completed=false;
	objective_b_completed=false;
	objective_c_completed=false;
	
	mission_success = false
	mission_failure = false
	time_objective_sleep = 5
	time_radar_sleep = 2
	
	aliens.Allow_Autonomous_AI_Goal_Activation(true)
	
	civilian.Make_Ally(novus)
	civilian.Make_Ally(uea)
	uea.Make_Ally(civilian)
	uea.Make_Ally(novus)
	novus.Make_Ally(civilian)
	novus.Make_Ally(uea)
	
	novus.Give_Money(20000)
	
	--set low civ population on large maps (esp single player)
	Spawn_Civilians_Automatically(true)
	Set_Desired_Civilian_Population(100)
	--Make_Civilians_Panic(mapcenter, 10000)

	Disable_Automatic_Tactical_Mode_Music()
	Play_Music("Music_Doom_Of_The_Aliens") -- needs to be big darth vader troops on the move kind of music
	
	Point_Camera_At(hero)
	Lock_Controls(1)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	Transition_Cinematic_Target_Key(hero, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(hero, 0, 200, 55, 65, 1, 0, 0, 0)
	Fade_Screen_In(2) 
	Transition_To_Tactical_Camera(7)
	Sleep(1)
	Create_Thread("Dialogue_Start_Mission")
	Sleep(6)
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()
	hero.Suspend_Locomotor(false)

	inverters_team=Find_All_Objects_With_Hint("unfold")
	for units, unit in pairs(inverters_team) do
		if TestValid(unit) then
			unit.Activate_Ability("Novus_Inverter_Toggle_Shield_Mode", true)
		end
	end
	
	-- show mission objective a and wait for it to be triggered
	Create_Thread("Setup_Military_Defenders")
	Create_Thread("Setup_Hierarchy_Guards")
		
	invasion_time=30
	
if true then
	Create_Thread("Alien_Troops_Cycler")
	nov07_objective = Add_Objective("TEXT_SP_MISSION_NVS07_OBJECTIVE")
	
	while invasion_time>0 do
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(invasion_time), 1)
		Set_Objective_Text(nov07_objective, out_string)
		--MessageBox(tostring(invasion_time))
		Sleep(1)
		invasion_time=invasion_time-1
	end
	Delete_Objective(nov07_objective)
end
if true then
	walkers_left=2
	Create_Thread("Setup_Walker_A")
	Sleep(1)
	Create_Thread("Show_Objective_A")
	Create_Thread("Dialogue_Assembly_Walkers")
	
	while not(objective_a_completed) do
		if not mission_success and not mission_failure then
			if not walkera_alldead then
				if walkers_left<=0 then walkera_alldead=true end
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_A")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_a_walkers-walkers_left), 1)
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_a_walkers), 2)
				Set_Objective_Text(nov07_objective_a, out_string)
				Sleep(1)
			else
				Objective_Complete(nov07_objective_a)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_A_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				Remove_Radar_Blip("blip_objective_a")
				objective_a_completed=true;
			end
		end
		Sleep(1)
	end

	walkers_left=2
	Create_Thread("Setup_Walker_B")
	Sleep(1)
	Create_Thread("Show_Objective_B")
	Create_Thread("Dialogue_Troop_Walkers")
	
	while not(objective_b_completed) do
		if not mission_success and not mission_failure then
			if not walkerb_alldead then
				if walkers_left<=0 then walkerb_alldead=true end
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_B")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_b_walkers-walkers_left), 1)
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_b_walkers), 2)
				Set_Objective_Text(nov07_objective_b, out_string)
				Sleep(1)
			else
				Objective_Complete(nov07_objective_b)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_B_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				Remove_Radar_Blip("blip_objective_b")
				objective_b_completed=true;
			end
		end
		Sleep(1)
	end

end

	Create_Thread("Hierarchy_Guards_Attack")
	
	walkers_left=3
	Create_Thread("Setup_Walker_C")
	Sleep(1)
	Create_Thread("Show_Objective_C")
	Create_Thread("Dialogue_Science_Walkers")
	
	while not(objective_c_completed) do
		if not mission_success and not mission_failure then
			if not walkerc_alldead then
				if walkers_left<=0 then walkerc_alldead=true end
				out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_C")
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_c_walkers-walkers_left), 1)
				out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(obj_c_walkers), 2)
				Set_Objective_Text(nov07_objective_c, out_string)
				Sleep(1)
			else
				Objective_Complete(nov07_objective_c)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_C_COMPLETE"} )
				Sleep(time_objective_sleep)
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
				Remove_Radar_Blip("blip_objective_c")
				objective_c_completed=true;
			end
		end
		Sleep(1)
	end
		 
	hero.Set_Cannot_Be_Killed(true)
	vertigo.Set_Cannot_Be_Killed(true)
	founder.Set_Cannot_Be_Killed(true)
	moore.Set_Cannot_Be_Killed(true)
	portal.Set_Cannot_Be_Killed(true)
	Create_Thread("Thread_Mission_Complete");
	
end

function Hierarchy_Guards_Attack()
	guards=Find_All_Objects_With_Hint("guards")
	for i, unit in pairs(guards) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
			Sleep(1)
		end
	end
end

function Setup_Hierarchy_Guards()
	guards=Find_All_Objects_With_Hint("guards")
	for i, unit in pairs(guards) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(true)
			unit.Prevent_AI_Usage(true)
			unit.Prevent_All_Fire(true)
			Sleep(.1)
		end
	end
	while invasion_time>0 do 
		Sleep(2)
	end
	for i, unit in pairs(guards) do
		if TestValid(unit) then
			unit.Set_Service_Only_When_Rendered(false)
			unit.Prevent_All_Fire(false)
			Sleep(.1)
		end
	end
end

function Alien_Troops_Cycler()
	Create_Thread("Alien_Troops_6")
	Create_Thread("Alien_Troops_5")
	Create_Thread("Alien_Troops_4")
	while not objective_b_completed do
		spawned_table=nil
		spawned_table={}
		for j=1, 3 do
			for i, unit in pairs(at_spawns) do
				if TestValid(unit) then
					spawned=Create_Generic_Object("ALIEN_GRUNT",unit,aliens)
					spawned.Prevent_AI_Usage(true)
					spawned.Prevent_All_Fire(true)
					table.insert(spawned_table, spawned)
					Sleep(.1)
				end
			end
		end
		Create_Thread("Alien_Troops_Movement",spawned_table)
		Sleep(at_formup_time+2)
	end
end

function Alien_Troops_Movement(forces)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_a[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_b[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_c[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_d[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_e[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Move_To(at_formup_f[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(false)
			Sleep(.1)
		end
	end
	Hunt(forces, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
end

function Alien_Troops_6()
	forces6=Find_All_Objects_With_Hint("start6")
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Prevent_AI_Usage(true)
			unit.Prevent_All_Fire(true)
			Sleep(.1)
		end
	end
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Move_To(at_formup_b[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Move_To(at_formup_c[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Move_To(at_formup_d[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Move_To(at_formup_e[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Move_To(at_formup_f[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces6) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(false)
			Sleep(.1)
		end
	end
	Hunt(forces6, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
end

function Alien_Troops_5()
	forces5=Find_All_Objects_With_Hint("start5")
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Prevent_AI_Usage(true)
			unit.Prevent_All_Fire(true)
			Sleep(.1)
		end
	end
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Move_To(at_formup_c[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Move_To(at_formup_d[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Move_To(at_formup_e[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Move_To(at_formup_f[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces5) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(false)
			Sleep(.1)
		end
	end
	Hunt(forces5, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
end

function Alien_Troops_4()
	forces4=Find_All_Objects_With_Hint("start4")
	for i, unit in pairs(forces4) do
		if TestValid(unit) then
			unit.Prevent_AI_Usage(true)
			unit.Prevent_All_Fire(true)
			Sleep(.1)
		end
	end
	for i, unit in pairs(forces4) do
		if TestValid(unit) then
			unit.Move_To(at_formup_d[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces4) do
		if TestValid(unit) then
			unit.Move_To(at_formup_e[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces4) do
		if TestValid(unit) then
			unit.Move_To(at_formup_f[i])
			Sleep(.1)
		end
	end
	Sleep(at_formup_time)
	for i, unit in pairs(forces4) do
		if TestValid(unit) then
			unit.Prevent_All_Fire(false)
			Sleep(.1)
		end
	end
	Hunt(forces4, "PrioritiesLikeOneWouldExpectThemToBe", false, false)
end

function Setup_Walker_A()
	markers=Find_All_Objects_With_Hint("objectivea")
	assets=Find_All_Objects_Of_Type("NM07_CUSTOM_ASSEMBLY_WALKER")
	for i, mark in pairs(markers) do
		if TestValid(mark) then
			--walker=Create_Generic_Object("NM07_CUSTOM_ASSEMBLY_WALKER",mark,aliens)
			walker=assets[i]
			walker.Set_Service_Only_When_Rendered(false)
			walker.Teleport(mark)
			walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Death_Walker_A") 
			Create_Thread("Thread_Assembly_Walker_Attack",{walker,novusbaseattack[i]})
			Create_Thread("Thread_Assembly_Walker_Produce",{walker,table.getn(markers)})
			walker.Add_Reveal_For_Player(novus)
			walker.Override_Max_Speed(.20)
			Add_Radar_Blip(walker, "DEFAULT", "blip_objective_a")
		end
	end
	Create_Thread("Thread_Assembly_Walker_Produced_Hunt")
end

function Death_Walker_A()
	walkers_left=walkers_left-1
	if not dialogue_assembly_a then Create_Thread("Dialogue_Assembly_A") end
end

function Thread_Assembly_Walker_Attack(params)
	local walker_obj=params[1]
	local point=params[2]
	if TestValid(point) then walker_obj.Guard_Target(point) end
	while TestValid(walker_obj) do
		prox_obj=Find_Nearest(walker_obj, novus, true)
		if TestValid(prox_obj) then
			if walker_obj.Get_Distance(prox_obj)<=300 then
				hp_list = walker_obj.Find_All_Hard_Points_Of_Type("Alien_Walker_Assembly_HP_Scarn_Beam")
				if not hp_list==nil then
					for i, hp in pairs(hp_list) do
						hp.Activate_Ability("Assembly_Scarn_Beam", true, prox_obj)
					end
				end
			end
		end
		Sleep(3)
	end
end

function Thread_Assembly_Walker_Produced_Hunt()
	while not walkera_alldead do
		defilers=Find_All_Objects_Of_Type("ALIEN_DEFILER")
		for i, unit in pairs(defilers) do
			Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", false, true, unit, 300)
			--unit.Guard_Target(novusbase7)
		end
		Sleep(GameRandom(5,7))
	end
end

function Thread_Assembly_Walker_Produce(params)
	local walker_obj,number = params[1],params[2]
	local prod_unit=Find_Object_Type("ALIEN_DEFILER")
	local prod_num=3
	local built={}
	local inqueue={}
	local queued=0
	local build=0
	local pod_type = Find_Object_Type("Alien_Walker_Assembly_HP_Defiler_Assembly_Pod")
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
			got_pod=false
			hardpoints=walker_obj.Get_All_Hard_Points()
			for i,hp in pairs(hardpoints) do
				if TestValid(hp) and hp.Get_Type()== pod_type then
					got_pod=true
				end
			end
			if got_pod then
				Tactical_Enabler_Begin_Production(walker_obj, prod_unit, 1, aliens)
			end
			Sleep(GameRandom(4,5))	
		else 
			Sleep(GameRandom(30,45))
		end
	end
end

function Setup_Walker_B()
	markers=Find_All_Objects_With_Hint("objectiveb")
	assets=Find_All_Objects_Of_Type("NM07_CUSTOM_HABITAT_WALKER")
	for i, mark in pairs(markers) do
		if TestValid(mark) then
			--walker=Create_Generic_Object("NM07_CUSTOM_HABITAT_WALKER",mark,aliens)
			walker=assets[i]
			walker.Set_Service_Only_When_Rendered(false)
			walker.Teleport(mark)
			walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Death_Walker_B") 
			Create_Thread("Thread_Habitat_Walker_Attack",{walker,novusbaseattack[i]})
			Create_Thread("Thread_Habitat_Walker_Produce",{walker,table.getn(markers)})
			walker.Add_Reveal_For_Player(novus)
			walker.Override_Max_Speed(.20)
			Add_Radar_Blip(walker, "DEFAULT", "blip_objective_b")
		end
	end
	Create_Thread("Thread_Habitat_Walker_Produced_Hunt")
end

function Thread_Habitat_Walker_Produced_Hunt()
	while not walkera_alldead do
		brutes=Find_All_Objects_Of_Type("ALIEN_BRUTE")
		for i, unit in pairs(brutes) do
			Hunt(unit, "PrioritiesLikeOneWouldExpectThemToBe", false, true, unit, 300)
			--unit.Guard_Target(novusbase7)
		end
		Sleep(GameRandom(5,7))
	end
end

function Thread_Habitat_Walker_Produce(params)
	local walker_obj,number = params[1],params[2]
	local prod_unit=Find_Object_Type("ALIEN_BRUTE")
	local prod_num=9
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
			Sleep(GameRandom(4,5))
		else
			Sleep(GameRandom(30,45))
		end
	end
end

function Death_Walker_B()
	walkers_left=walkers_left-1
	if walkers_left==1 then
		if not dialogue_troop_a then Create_Thread("Dialogue_Troop_A") end
	end
end

function Thread_Habitat_Walker_Attack(params)
	local walker_obj=params[1]
	local point=params[2]
	if TestValid(point) then walker_obj.Guard_Target(point) end
	while TestValid(walker_obj) do
		prox_obj=Find_Nearest(walker_obj, novus, true)
		if TestValid(prox_obj) then
			if walker_obj.Get_Distance(prox_obj)<=250 then
				hp_list = walker_obj.Find_All_Hard_Points_Of_Type("Alien_Walker_Habitat_HP_Terrain_Conditioner")
				if not hp_list==nil then
					ability_used=false
					for i, hp in pairs(hp_list) do
						if not ability_used then
							if hp.Is_Ability_Ready("Radiation_Artillery_Cannon_Attack_Ability") then
								hp.Activate_Ability("Radiation_Artillery_Cannon_Attack_Ability", true, prox_obj)
								ability_used=true
								if not dialogue_radiation then Create_Thread("Dialogue_Troop_Walkers_Damage") end
							end
						end
					end
				end
			end
		end
		Sleep(3)
	end
end

function Setup_Walker_C()
	markers=Find_All_Objects_With_Hint("objectivec")
	assets=Find_All_Objects_Of_Type("NM07_CUSTOM_SCIENCE_WALKER")
	for i, mark in pairs(markers) do
		if TestValid(mark) then
			--walker=Create_Generic_Object("NM07_CUSTOM_SCIENCE_WALKER",mark,aliens)
			walker=assets[i]
			walker.Set_Service_Only_When_Rendered(false)
			walker.Teleport(mark)
			walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Death_Walker_C") 
			Create_Thread("Thread_Science_Walker_Attack",{walker,novusbaseattack[i]})
			walker.Add_Reveal_For_Player(novus)
			walker.Override_Max_Speed(.15)
			Add_Radar_Blip(walker, "DEFAULT", "blip_objective_c")
		end
	end
end

function Death_Walker_C()
	walkers_left=walkers_left-1
	if walkers_left==3 then
		if not dialogue_science_a then Create_Thread("Dialogue_Science_A") end
	end
	if walkers_left==1 then
		if not dialogue_science_b then Create_Thread("Dialogue_Science_B") end
	end
end

function Thread_Science_Walker_Attack(params)
	local walker_obj=params[1]
	local point=params[2]
	if TestValid(point) then walker_obj.Guard_Target(point) end
	local cooldown=0
	while TestValid(walker_obj) do
		prox_obj=Find_Nearest(walker_obj, novus, true)
		if TestValid(prox_obj) then
			if walker_obj.Get_Distance(prox_obj)<=300 then
				cooldown=cooldown-1
				if cooldown<1 then
					walker_obj.Activate_Ability("Alien_Radiation_Cascade_Unit_Ability", true, prox_obj.Get_Position(), true)
					Sleep(12)
					if TestValid(walker_obj) and TestValid(point) then
						walker_obj.Guard_Target(point)
					end
					cooldown=20
				end
			end
		end
		Sleep(3)
	end
end

function Setup_Military_Defenders()
	mil_units=Find_All_Objects_Of_Type("Military_AbramsM2_Tank")
	for i, mil_unit in pairs(mil_units) do
		if TestValid(mil_unit) then
			Hunt(mil_unit, false, true, mil_unit, 200)
		end
	end
	mil_units=Find_All_Objects_Of_Type("Military_Hummer")
	for i, mil_unit in pairs(mil_units) do
		if TestValid(mil_unit) then
			Hunt(mil_unit, false, true, mil_unit, 200)
		end
	end
	mil_units=Find_All_Objects_Of_Type("Military_Apache")
	for i, mil_unit in pairs(mil_units) do
		if TestValid(mil_unit) then
			Hunt(mil_unit, true, false, novus_base, 600)
		end
	end
end

function Show_Objective_A()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_A_ADD"} )
	Sleep(time_objective_sleep)
	nov07_objective_a = Add_Objective("TEXT_SP_MISSION_NVS07_OBJECTIVE_A")
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_A")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(0), 1)
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(2), 2)
		Set_Objective_Text(nov07_objective_a, out_string)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

-- adds mission objective for objective B
function Show_Objective_B()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_B_ADD"} )
	Sleep(time_objective_sleep)
	nov07_objective_b = Add_Objective("TEXT_SP_MISSION_NVS07_OBJECTIVE_B")
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_B")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(0), 1)
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(2), 2)
		Set_Objective_Text(nov07_objective_b, out_string)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

-- adds mission objective for objective C
function Show_Objective_C()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS07_OBJECTIVE_C_ADD"} )
	Sleep(time_objective_sleep)
	nov07_objective_c = Add_Objective("TEXT_SP_MISSION_NVS07_OBJECTIVE_C")
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS07_OBJECTIVE_C")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(0), 1)
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(3), 2)
		Set_Objective_Text(nov07_objective_c, out_string)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
end

--on hero death, force defeat
function Death_Hero_Mech()
	Queue_Talking_Head(pip_novcomm, "ALL06_SCENE02_03")
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"
	Create_Thread("Thread_Mission_Failed")
end

--on hero death, force defeat
function Death_Hero_Moore()
	if TestValid(hero) then
		Queue_Talking_Head(pip_mirabel, "NVS05_SCENE03_18")
	end
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MOORE"
	Create_Thread("Thread_Mission_Failed")
end

--on hero death, force defeat
function Death_Hero_Vertigo()
	Queue_Talking_Head(pip_novcomm, "ALL06_SCENE02_05")
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_VERTIGO"
	Create_Thread("Thread_Mission_Failed")
end

--on hero death, force defeat
function Death_Hero_Founder()
	Queue_Talking_Head(pip_novcomm, "ALL06_SCENE02_04")
	failure_text="TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_FOUNDER"
	Create_Thread("Thread_Mission_Failed")
end

--on hero death, force defeat
function Death_Hero_Portal()
	failure_text="TEXT_SP_MISSION_NVS07_OBJECTIVE_FAIL"
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
	
	Fade_Screen_Out(0)
	--play outro cinematic - final cinematic for novus campaign
	Set_Active_Context("NM07_EndCinematic")
	Fade_Out_Music()
    BlockOnCommand(Play_Bink_Movie("Novus_M7_S3",true))
	
	Force_Victory(novus)
end


--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script
function Force_Victory(player)
		if player == novus then
		
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
		--novus.Lock_Object_Type(Find_Object_Type("NOVUS_DERVISH_JET"),boolean,STORY)
		novus.Lock_Object_Type(Find_Object_Type("NM04_NOVUS_PORTAL"),boolean,STORY)
		
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly_HP_Scarn_Beam"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly_HP_Mass_Driver"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Science_HP_Radiation_Wake"),false,STORY)
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat_HP_Terrain_Conditioner"),false,STORY)
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
		
		novus.Lock_Unit_Ability("Novus_Hero_Founder", "Novus_Founder_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Vertigo", "Novus_Vertigo_Retreat_From_Tactical_Ability", boolean, STORY)
		novus.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability", boolean, STORY)
		
		--All_Locks_Off(aliens, true)
		
		aliens.Lock_Generator("AlienTankPlasmaAEExplosionEffect", true,STORY)
		aliens.Lock_Generator("DefilerOnDeathExplosionGenerator", true,STORY)
		--aliens.Lock_Generator("CylinderOnDeathExplosionGenerator", true)
		aliens.Lock_Generator("ReaperOnDeathExplosionGenerator", true,STORY)
		aliens.Lock_Generator("ScanDroneOnDeathExplosionGenerator", true,STORY)
		aliens.Lock_Generator("AssemblyOnDeathExplosionGenerator", true,STORY)
		aliens.Lock_Generator("HabitatOnDeathExplosionGenerator", true,STORY)
		aliens.Lock_Generator("ScienceWalkerOnDeathExplosionGenerator", true,STORY)
		--aliens.Lock_Generator("FooCoreOnDeathExplosionGenerator", true)
		aliens.Lock_Generator("OrlokOnDeathExplosionGenerator", true,STORY)
		
		aliens.Lock_Effect("AlienRadiatedShotsImpactEffect", true,STORY)
end

function Import_Base_From_Global()
	novus_base_layout = global_script.Call_Function("Global_Load_Novus_Layout")
	structures_type_table = novus_base_layout[1]
	structures_pos_table = novus_base_layout[2]
	structures_face_table = novus_base_layout[3]
	if not structures_type_table==nil then
		for i, structure in pairs(structures_type_table) do
			last_structure = Create_Generic_Object(structures_type_table[i], structures_pos_table[i], novus)
			last_structure.Set_Facing(structures_face_table[i])
		end
	else 
		structures_type_table = Find_All_Objects_Of_Type("MARKER_GENERIC_BLUE")
		for i, structure in pairs(structures_type_table) do
			type_structure=structures_type_table[i]
			if type_structure.Get_Hint()=="terminal" then
				last_structure = Create_Generic_Object(Find_Object_Type("NOVUS_REMOTE_TERMINAL"), type_structure.Get_Position(), novus)
			end
			if type_structure.Get_Hint()=="tower" then
				last_structure = Create_Generic_Object(Find_Object_Type("NOVUS_SIGNAL_TOWER"), type_structure.Get_Position(), novus)
			end
			if type_structure.Get_Hint()=="power" then
				last_structure = Create_Generic_Object(Find_Object_Type("NOVUS_POWER_ROUTER"), type_structure.Get_Position(), novus)
			end
			if type_structure.Get_Hint()=="input" then
				last_structure = Create_Generic_Object(Find_Object_Type("NOVUS_INPUT_STATION"), type_structure.Get_Position(), novus)
			end
			if type_structure.Get_Hint()=="robotic" then
				last_structure = Create_Generic_Object(Find_Object_Type("NOVUS_ROBOTIC_ASSEMBLY"), type_structure.Get_Position(), novus)
			end

		end
	end
end

function Dialogue_Start_Mission()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE04_01"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE04_02"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE04_06"))
	end
	vertigo.Activate_Ability("Upload_Unit_Ability",true,hero,true)
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_vertigo, "NVS07_SCENE05_15"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_14"))
	end
end

function Dialogue_Assembly_Walkers()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS07_SCENE05_16"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE05_17"))
	end
end

function Dialogue_Assembly_A()
	dialogue_assembly_a=true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE05_07"))
	end
end

function Dialogue_Troop_Walkers()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS07_SCENE05_18"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_19"))
	end
end

function Dialogue_Troop_A()
	dialogue_troop_a=true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE05_02"))
	end
end

function Dialogue_Troop_Walkers_Damage()
	dialogue_radiation=true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS07_SCENE05_20"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_21"))
	end
end

function Dialogue_Science_A()
	dialogue_science_a=true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_vertigo, "NVS07_SCENE05_12"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_13"))
	end
end

function Dialogue_Science_B()
	dialogue_science_b=true
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE05_10"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_11"))
	end
end

function Dialogue_Science_Walkers()
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_novcomm, "NVS07_SCENE05_22"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_vertigo, "NVS07_SCENE05_23"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_mirabel, "NVS07_SCENE05_24"))
	end
	if not mission_success and not mission_failure then
		BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS07_SCENE05_25"))
	end
end

function Post_Load_Callback()
	UI_Hide_Research_Button()
	--UI_Hide_Sell_Button()
	Movie_Commands_Post_Load_Callback()
end

