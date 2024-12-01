-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM04.lua#59 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_NM04.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: Dan_Etter $
--
--            $Change: 90680 $
--
--          $DateTime: 2008/01/09 17:53:49 $
--
--          $Revision: #59 $
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
require("PGStoryMode") 
require("RetryMission")
require("PGColors")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()

	-- only service once a second
	ServiceRate = 1
	
	bool_testing = false
	bool_make_mirabel_unkillable = false
	bool_make_portal_unkillable = false
	bool_show_establishing_shot = true
	
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_NM04_Act01", State_NM04_Act01)
	Define_State("State_NM04_Act02", State_NM04_Act02)
	Define_State("State_NM04_Act03", State_NM04_Act03)
	
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")
   hostile = Find_Player("Hostile")

	PGColors_Init_Constants()
--	aliens.Enable_Colorization(true, COLOR_RED)
--	novus.Enable_Colorization(true, COLOR_CYAN)
	   
   player_faction = novus
	
	pip_mirabel = "NH_Mirabel_pip_head.alo"
	pip_founder = "NH_Founder_pip_Head.alo"
	pip_novus_comm = "NI_Comm_Officer_pip_Head.alo"
	pip_viktor = "NH_Viktor_pip_head.alo"
	
	win_cond_1=false
	win_cond_2=false
	obj_base_established=false
	obj_assembly_given=false
	obj_assembly_down=false
	
	--the various "conversations" that happen througout the mission...uses
	--Create_Thread("Thread_Dialog_Controller", dialog_reference)
	dialog_build_the_portal = 0
	dialog_protect_the_humans = 1
	dialog_aliens_invade = 2
	dialog_intro_new_walker = 3
	dialog_alien_base_destroyed = 6
	dialog_mirabel_killed = 7
	dialog_mirabels_lament = 8
	dialog_establishing_shot = 9
	dialog_assembly_walker_arms_destoyed = 11
	dialog_assembly_walker_shields_destoyed = 12
	dialog_assembly_walker_front_panel_destroyed = 13
	dialog_assembly_walker_destroyed = 14
	dialog_player_has_20k = 15
	
	failure_text = nil
	
	bool_dialog_establishing_shot = false
	bool_dialog_mirabels_lament = false
	bool_dialog_build_the_portal = false
	bool_dialog_protect_the_humans = false
	bool_dialog_aliens_invade = false
	bool_dialog_intro_new_walker = false
	bool_dialog_assembly_walker_arms_destoyed = false
	bool_dialog_assembly_walker_shields_destoyed = false
	bool_dialog_assembly_walker_front_panel_destroyed = false
	bool_dialog_assembly_walker_destroyed = false
	bool_dialog_alien_base_destroyed = false
	bool_dialog_mirabel_killed  = false
	bool_dialog_player_has_20k  = false
	
	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
	bool_capture_team_destroyed = true
	new_capture_team = {}
	counter_capture_team_members_killed = 0
	
	bool_establishing_shot_finished = false
	bool_mission_failure = false
	bool_mission_success = false
	bool_this_is_first_habitat_walker = true
	bool_novus_units_present_at_build_spot = true
	--bool_bonus_portal_objective_failed = false
	bool_portal_objective_failed = false
	bool_portal_built = false
	bool_hierarchy_base_objective_active = false
	bool_objective03_humans_saved = true
	bool_tracking_victory_conditions = false
	bool_flagging_refineries = false -- used to determine when to remove refinery arrows and radar blips
	bool_first_human_killed = true
	bool_humantown01_active = true
	bool_humantown02_active = true
	bool_humantown03_active = true
	bool_humantown04_active = true
	
	starting_camera_position = nil

   timer_intro_assembly_walker = 60
	time_objective_sleep = 5
	timer_arrival_site_construction = 10
	
	assembly_walker = nil
	assembly_walker_defiler_hardpoint = nil
	assembly_walker_tank_hardpoint = nil
	
	type_novus_portal_buildable = Find_Object_Type("NM04_Novus_Portal")
	
	type_novus_portal = Find_Object_Type("NM04_NOVUS_PORTAL_CONSTRUCTION")
	type_glyph_carver = Find_Object_Type("ALIEN_GLYPH_CARVER")
	type_arrival_site = Find_Object_Type("ALIEN_ARRIVAL_SITE")
	type_reaper_turret = Find_Object_Type("ALIEN_SUPERWEAPON_REAPER_TURRET") 
	type_habitat_walker = Find_Object_Type("ALIEN_WALKER_HABITAT") 
	type_assembly_walker = Find_Object_Type("ALIEN_WALKER_ASSEMBLY") 
	type_grunt = Find_Object_Type("ALIEN_GRUNT")
	type_defiler = Find_Object_Type("ALIEN_DEFILER") 
	type_recon_tank = Find_Object_Type("ALIEN_RECON_TANK") 
	type_monolith = Find_Object_Type("ALIEN_CYLINDER")
	type_scan_drone = Find_Object_Type("ALIEN_SCAN_DRONE")
	type_defiler_hardpoint = Find_Object_Type("Alien_Walker_Assembly_HP_Defiler_Assembly_Pod")
	type_tank_hardpont = Find_Object_Type("Alien_Walker_Assembly_HP_Phase_Tank_Assembly_Pod")
	
	object_portal = nil
	object_arrival_site = nil
	object_habitat_walker = nil
	object_scan_drone = nil
	object_glyph_carver_list = {}
	
	counter_glyph_carvers = 0 
	counter_arrival_sites = 0
	counter_habitat_walkers = 0
	counter_assembly_walkers = 0
	counter_scan_drones = 0
	counter_field_inverters = 0
	
	fow_reveal_starting_cine = nil
	fow_reveal_human_town01 = nil
	fow_reveal_human_town02 = nil
	fow_reveal_human_town03 = nil
	fow_reveal_human_town04 = nil
	
	fow_reveal_refinery_list = {}
	
	
	
	
	list_field_inverter_reinforcements = {
		"Novus_Field_Inverter",
		"Novus_Field_Inverter",
		"Novus_Field_Inverter",
	}
	
	assembly_walker_left_arm = nil
	assembly_walker_right_arm = nil
	assembly_walker_left_shield = nil
	assembly_walker_right_shield = nil
	assembly_walker_core = nil

		--list of OBJECTIVES for easy reference
	--NM04_Objective01 = Add_Objective("Build the Portal in less than five minutes. (300 seconds left).")
	--NM04_Objective02 = Add_Objective("Protect the portal at all costs.")
	--NM04_Objective03 = Add_Objective("Protect the sentients to the North (20 humans remain).")
	--NM04_Objective04 = Add_Objective("Destroy the Assembly Walker.")
	--NM04_Objective05 = Add_Objective("Destroy the Hierarchy base.")
	
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through
function State_Init(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("Story_Campaign_Novus_NM04 START!"))
		--this following OutputDebug puts a message in the logfile that lets me determine where mission relevent info starts...mainly using to determine what assets need
		--to be pre-cached.
		OutputDebug("\n\n\n#*#*#*#*#*#*#*#*#*#*#*#*#\njdg: Story_Campaign_Novus_NM04 START!\n#*#*#*#*#*#*#*#*#*#*#*#*#\n")

		
		Fade_Screen_Out(0)
		
		-- ***** HINT SYSTEM *****
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		local scene = Get_Game_Mode_GUI_Scene()
		Register_Hint_Context_Scene(scene)			-- Set the scene to which independant hints will be attached.
		-- ***** HINT SYSTEM *****
      
      Cache_Models()
      Define_Hints()
		
		novus.Reset_Story_Locks()
		aliens.Reset_Story_Locks()
	
		Lock_Out_Stuff(true)
		--Init_Radar()
		
	uea.Allow_AI_Unit_Behavior(false)
	aliens.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
	
		UI_Hide_Research_Button()
		UI_Hide_Sell_Button()

		civilian.Make_Enemy(aliens)
		
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
			
		Set_Next_State("State_NM04_Act01")
      
	elseif message == OnUpdate then
	end
end

function State_NM04_Act01(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("*******State Change: State_NM04_Act01"))
		
		player_script = aliens.Get_Script()
	
		Create_Thread("Thread_NM04_Act01_Start")
		Create_Thread("Thread_Victory_Checks")
	end
end

function State_NM04_Act02(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("*******State Change: State_NM04_Act02"))
		
		Create_Thread("Thread_NM04_Act02_Start")
	end
end

function State_NM04_Act03(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("*******State Change: State_NM04_Act03"))
		
		Create_Thread("Thread_NM04_Act03_Start")
	end
end

function Thread_Establishing_Shot()

	Point_Camera_At(mirabel)
	Lock_Controls(1)
	Sleep(1)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	
	Create_Thread("Thread_Dialog_Controller", dialog_establishing_shot)

	Transition_Cinematic_Target_Key(mirabel, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(mirabel, 0, 200, 55, 65, 1, 0, 0, 0)

	Fade_Screen_In(1) 

	Transition_To_Tactical_Camera(5)
	Sleep(5)

	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()

	Sleep(60)
	
	Create_Thread("Thread_Dialog_Controller", dialog_mirabels_lament)

end


--***************************************THREADS****************************************************************************************************
-- below are the various threads used in this script
function Thread_NM04_Act01_Start()
   _CustomScriptMessage("JoeLog.txt", string.format("Thread_NM04_Act01_Start Hit!"))
	
	if bool_show_establishing_shot == true then
		Create_Thread("Thread_Establishing_Shot")
		while bool_establishing_shot_finished == false do
			Sleep(1)
		end
		Lock_Controls(0)
	else
		Fade_Screen_In(2)
	end
	

	
	--put hint on field inverter
	--field_inverter = Find_First_Object("NOVUS_FIELD_INVERTER")
	if TestValid(starting_inverter) then
		--Add_Attached_Hint(starting_inverter, HINT_BUILT_NOVUS_FIELD_INVERTER)
		Add_Attached_Hint(starting_inverter, HINT_NM04_FIELDINVERTERS)
		Create_Thread("Thread_Starting_Inverter")
	end	
	-- ***** HINT SYSTEM *****
	
	if bool_testing == true then
		player_faction.Give_Money(20000)
		Sleep(10)
	else
		Sleep(240)
		--Sleep(180)
	end

	if not (Get_Current_State() == "State_NM04_Act02") then
		Set_Next_State("State_NM04_Act02")
	end
	
end

function Thread_NM04_Act02_Start()
	if not bool_testing then
		Create_Thread("Thread_Aliens_Attack_Humans")
	end
	
	--if bool_testing == true then
	--	Sleep(10)
	--else
	--	Sleep(60)
	--end
	

	
	Set_Next_State("State_NM04_Act03")
end

function Thread_Starting_Inverter()
	while bool_establishing_shot_finished == false do
		Sleep(1)
	end
	
	if TestValid(starting_inverter) then
		BlockOnCommand(starting_inverter.Move_To(starting_inverter_goto))
	end
	
	if TestValid(starting_inverter) then
		starting_inverter.Activate_Ability("Novus_Inverter_Toggle_Shield_Mode", true)
	end
	
	while (bool_portal_built == false) do
		Sleep(5)
	end
	
	--portal is up...turn off your shields
	if TestValid(starting_inverter) then
		starting_inverter.Activate_Ability("Novus_Inverter_Toggle_Shield_Mode", false)
	end
	
end

function Thread_NM04_Act03_Start()
	while TestValid(starting_reaper) do
		Sleep(5)
	end

	Create_Thread("Thread_Aliens_SetUp_Base")
	Create_Thread("Thread_Monitor_For_Arrival_Site")
end

function Thread_Monitor_For_Arrival_Site()
	while true do
		Sleep(5)
		local arrival_site_construction = Find_First_Object("Alien_Arrival_Site_Construction")
		
		if TestValid(arrival_site_construction) then
			MessageBox("Thread_Monitor_For_Arrival_Site: Alien_Arrival_Site_Construction detected")
			--arrival_site_construction.Add_Attribute_Modifier( "Structure_Speed_Build", 15 )
			arrival_site_construction.Add_Attribute_Modifier( "Structure_Speed_Build", 5 )
			return
		end
	end
end


function Thread_Monitor_For_Portal()
	while not bool_portal_built do
		Sleep(3)
		--DME: changing the object search to the beacon rather than the under construction version.
		local portal_beacon = Find_First_Object("NM04_NOVUS_PORTAL_BEACON")
		
		if TestValid(portal_beacon) then
			--prevent further portals from being built
			player_faction.Lock_Object_Type(type_novus_portal_buildable,true,STORY)
			--player_faction.Lock_Object_Type(type_novus_portal,true,STORY)
		end
		
		local portal_construction = Find_First_Object("NM04_NOVUS_PORTAL_CONSTRUCTION")
		
		if TestValid(portal_construction) then
			--portal_trasnport.Move_To(portal_construction.Get_Position())
			portal_construction.Register_Signal_Handler(Callback_Portal_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
	
			if not bool_mission_failure then
				bool_portal_built = true
				
				if  bool_flagging_refineries == true then
					for i, refinery in pairs(refinery_list) do
						if TestValid(refinery) then
							
							Remove_Radar_Blip("blip_refinery_"..i)
							
							fow_reveal_refinery_list[i].Undo_Reveal()
							bool_flagging_refineries = false
						end
					end
				end
				
				Objective_Complete(NM04_Objective01)
				if NM04_Objective01_Hint ~= nil then
					Delete_Objective(NM04_Objective01_Hint) -- removes the hint to capture oil derriks
				end
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_AD_COMPLETE"} )--Objective complete: Build the Home Portal within five minutes.

				Create_Thread("Thread_Add_Protect_Portal_Objective")
				
				if TestValid(portal_trasnport) then
					local portal_type = portal_trasnport.Get_Type() 
					
					empty_portal_transpot = Spawn_Unit(portal_type, portal_trasnport, novus, false)
					empty_portal_transpot.Teleport_And_Face(portal_trasnport)
					
					portal_trasnport.Despawn()
				
				else
					_CustomScriptMessage("JoeLog.txt", string.format("ERROR!! Trying to replace portal_transport...NOT TestValid(portal_trasnport)"))
				end
				
				if not (Get_Current_State() == "State_NM04_Act02") then
					Set_Next_State("State_NM04_Act02")
				end
			end
		end
	end
end

function Thread_Monitor_Players_Money()
	local players_cash = player_faction.Get_Credits()
	
	while players_cash < 20000 do
		players_cash = player_faction.Get_Credits()
		Sleep(1)
	end
	
	Create_Thread("Thread_Dialog_Controller", dialog_player_has_20k)
end

function Thread_Monitor_Objective01_Timer()
	local time_left_minutes = 6
	local time_left_seconds = 0
	local time_left = 360
	
	Create_Thread("Thread_Monitor_For_Portal")
	
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_AD_ADD"} )--New objective: Build the Wormhole Portal within six minutes.
	Sleep(time_objective_sleep)
	NM04_Objective01 = Add_Objective("TEXT_SP_MISSION_NVS04_OBJECTIVE_AD2")--Build the Home Portal within six minutes (##1:0##2).
	out_string = Get_Game_Text("TEXT_SP_MISSION_NVS04_OBJECTIVE_AD2")
	out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_minutes), 1)
	out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_seconds), 2)
	Set_Objective_Text(NM04_Objective01, out_string)
	
	Sleep(1)
	
	
	while (time_left >= 0) do
		
		if time_left == 359 then
			time_left_minutes = 5
			time_left_seconds = 59
		elseif time_left == 299 then
			time_left_minutes = 4
			time_left_seconds = 59
		elseif time_left == 239 then
			time_left_minutes = 3
			time_left_seconds = 59
		elseif time_left == 179 then
			time_left_minutes = 2
			time_left_seconds = 59
		elseif time_left == 119 then
			time_left_minutes = 1
			time_left_seconds = 59
		elseif time_left == 59 then
			time_left_minutes = 0
			time_left_seconds = 59
		end
		
		if time_left == 180 then -- build reminders
			Queue_Talking_Head(pip_founder, "NVS04_SCENE05_01")--Founder (FOU): This is our only way home, Mirabel.  You must get the portal constructed as quickly as possible and protect it at all costs.
		elseif time_left == 120  then
			Queue_Talking_Head(pip_founder, "NVS04_SCENE06_44")--Founder (FOU): Be expedient, Mirabel! The quantum threshhold is closing fast.
		elseif time_left == 60  then
			Queue_Talking_Head(pip_founder, "NVS04_SCENE06_45")--Founder (FOU): You must hurry, Mirabel. The timing is critical.
		end
		

		if time_left_seconds < 10 then --this is a variant of the objective that allows me to put a zero in-front of any seconds less than 10 (eg. 09, 08...)
			out_string = Get_Game_Text("TEXT_SP_MISSION_NVS04_OBJECTIVE_AD2")
			out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_minutes), 1)
			out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_seconds), 2)
			Set_Objective_Text(NM04_Objective01, out_string)
		else
			out_string = Get_Game_Text("TEXT_SP_MISSION_NVS04_OBJECTIVE_AD")
			out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_minutes), 1)
			out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(time_left_seconds), 2)
			Set_Objective_Text(NM04_Objective01, out_string)
		end
		
		if time_left <= 0 then--safety
			time_left = 0
			break
		end
		
		time_left = time_left - 1
		time_left_seconds = time_left_seconds - 1
		Sleep(1)
		
		if bool_portal_built == true then -- portal has been built break out of this thread
			return
		end
	end
	
	if not bool_portal_built then
		bool_portal_objective_failed = true
		failure_text = "TEXT_SP_MISSION_NVS04_OBJECTIVE_AA_FAILED"
		Create_Thread("Thread_Mission_Failed")
	end
end

function Thread_Monitor_Refinery_Owner(local_refinery)
	while TestValid(local_refinery) do
		if local_refinery.Get_Owner() == player_faction then
			for i, refinery in pairs(refinery_list) do
				if TestValid(refinery) then
					if refinery == local_refinery then
						--local_refinery.Highlight(false)
						Remove_Radar_Blip("blip_refinery_"..i)
						return -- this thread has served its purpose...break out
					end
				end
			end		
		end
		Sleep(3)
	end
end

function Thread_Aliens_SetUp_Base()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Aliens_SetUp_Base HIT!"))

	--send in the secure team...
	for i, secure_team_member in pairs(secure_team) do
		if TestValid(secure_team_member) then
				secure_team_member.Set_Object_Context_ID("NM04_StoryCampaign")
		end
	end
	
	if TestValid(secure_team_walker) then
		secure_team_walker.Set_Object_Context_ID("NM04_StoryCampaign")
		secure_team_walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Callback_HabitatWalker_Destroyed")
		counter_habitat_walkers = counter_habitat_walkers + 1
		object_habitat_walker = secure_team_walker
	end
	
	Create_Thread("Thread_Check_For_Novus_Units")
	Hunt(secure_team, "AntiDefault", true, false, alien_base, 300)
	
	-- [jgs] removed this since it seems to cause a stalemate
	--while bool_novus_units_present_at_build_spot == true do
	--	Sleep(5)
	--end
	
	-- added by jgs -- often the portal would not be built when the founder ordered it to be disassembled
	while bool_portal_built == false do
		Sleep(5)
	end
	
	Create_Thread("Thread_Dialog_Controller", dialog_aliens_invade)
	
	if TestValid(secure_team_walker) then
	    --removed since walkers don't hunt, also changed to move to spot by the base
		--Hunt(secure_team_walker, false, true, assembly_walker_guard_spot, 25)
		secure_team_walker.Move_To(assembly_walker_build_spot)
		Define_BarracksWalker_Build_Stuff()
		Create_Thread("Thread_Enter_The_Builders")
	end
	
	Create_Thread("Harass_Player")
	
	Sleep(45)
	
	-- this stuff was previously set to trigger on construction complete, but never happened if the alien base wasn't built
	Create_Thread("Thread_Introduce_Assembly_Walkers")
	Create_Thread("Thread_Track_Victory_Conditions")
	Create_Thread("Thread_Victory_Checks")
end

function Harass_Player()
	--go harrass the player  while your builders set up shop
	local bool_prefered_target_exists = true
	while bool_prefered_target_exists == true do
		local prefered_target = Find_First_Object("NOVUS_INPUT_STATION")
		if TestValid(prefered_target) then
			Hunt(secure_team, "AntiDefault", true, false, prefered_target, 50)
		else
			bool_prefered_target_exists = false 
		end
		Sleep(20)
	end
end

function Thread_Enter_The_Builders()
	--send in builders
	for i, builder_team_member in pairs(builder_team) do
		if TestValid(builder_team_member) then
				builder_team_member.Set_Object_Context_ID("NM04_StoryCampaign")
				builder_team_member.Register_Signal_Handler(Callback_GlyphCarver_Killed, "OBJECT_HEALTH_AT_ZERO")
				
				counter_glyph_carvers = counter_glyph_carvers + 1
		end
	end
	
	for i, glyph_carver_guard in pairs(glyph_carver_guards) do
		if TestValid(glyph_carver_guard) then
				glyph_carver_guard.Set_Object_Context_ID("NM04_StoryCampaign")
		end
	end
	
	for i, builder_team_member in pairs(builder_team) do
		if TestValid(builder_team_member) then
			for i, glyph_carver_guard in pairs(glyph_carver_guards) do
				if TestValid(glyph_carver_guard) then
						glyph_carver_guard.Guard_Target(builder_team_member)
				end
			end
			break
		end
	end
	
	
	Formation_Move(builder_team, alien_base.Get_Position()) -- this blocks
	Sleep(5)
	Maintain_Base(aliens, "NM04_Alien_Base01")
end

function Thread_Check_For_Novus_Units()
	while bool_novus_units_present_at_build_spot == true do
		local nearest_novus_unit = Find_Nearest(alien_base, novus, true)
		local distance = alien_base.Get_Distance(nearest_novus_unit)
		
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Check_For_Novus_Units distance = %d", distance))
		
		if distance>= 500 then
			bool_novus_units_present_at_build_spot = false
			return
		end
		Sleep(5)
	end
end

function Thread_Introduce_Assembly_Walkers()
	Sleep(30) -- delaying entry a bit
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Introduce_Assembly_Walkers HIT!!"))
	Create_Thread("Thread_Dialog_Controller", dialog_intro_new_walker)
	
	if TestValid(assembly_walker) then
		assembly_walker.Set_Object_Context_ID("NM04_StoryCampaign")
		
		assembly_walker.Override_Max_Speed(.6) -- overriding multiplayer creep balance
		
		counter_assembly_walkers = counter_assembly_walkers + 1
		assembly_walker.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Callback_AssemblyWalker_Destroyed")
		
		Create_Thread("Thread_Assembly_Walker_Upgrade_Hardpoints", assembly_walker)
		
		if TestValid(assembly_walker) then
			assembly_walker_left_arm = Find_First_Object("Alien_Walker_Assembly_Left_Arm_00")
			assembly_walker_right_arm = Find_First_Object("Alien_Walker_Assembly_Right_Arm_00")
			assembly_walker_left_shield = Find_First_Object("Alien_Walker_Assembly_Shield_Left")
			assembly_walker_right_shield = Find_First_Object("Alien_Walker_Assembly_Shield_Right")
			assembly_face_cap = Find_First_Object("Alien_Walker_Assembly_Face_Cap")
			assembly_walker_core = Find_First_Object("Alien_Walker_Assembly_Core")
		end
		
		if TestValid(assembly_walker_left_arm) then
			_CustomScriptMessage("JoeLog.txt", string.format("TestValid(assembly_walker_left_arm)"))
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! Story_On_Construction_Complete: NOT TestValid(assembly_walker_left_arm)"))
		end
		
		if TestValid(assembly_walker_right_arm) then
			_CustomScriptMessage("JoeLog.txt", string.format("TestValid(assembly_walker_right_arm)"))
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! Story_On_Construction_Complete:  NOT TestValid(assembly_walker_right_arm)"))
		end
		
		if TestValid(assembly_walker_left_shield) then
			_CustomScriptMessage("JoeLog.txt", string.format("TestValid(assembly_walker_left_shield)"))
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! Story_On_Construction_Complete: NOT TestValid(assembly_walker_left_shield)"))
		end
		
		if TestValid(assembly_walker_right_shield) then
			_CustomScriptMessage("JoeLog.txt", string.format("TestValid(assembly_walker_right_shield)"))
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! Story_On_Construction_Complete: NOT TestValid(assembly_walker_right_shield)"))
		end
		
		if TestValid(assembly_face_cap) then
			_CustomScriptMessage("JoeLog.txt", string.format("TestValid(assembly_face_cap)"))
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! Story_On_Construction_Complete: NOT TestValid(assembly_face_cap)"))
		end
		
		if TestValid(assembly_walker_core) then
			_CustomScriptMessage("JoeLog.txt", string.format("TestValid(assembly_walker_core)"))
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! Story_On_Construction_Complete: NOT TestValid(assembly_walker_core)"))
		end
		
		Create_Thread("Thread_Monitor_Assembly_Walker_Puzzle")
		
		BlockOnCommand(assembly_walker.Move_To(assembly_walker_guard_spot.Get_Position()))
		Create_Thread("Thread_Dialog_Controller", dialog_intro_new_walker)
		Hunt(assembly_walker, "AntiDefault", true, false, novus_base, 150)
	end

end

function Thread_Monitor_Assembly_Walker_Puzzle()
	if not TestValid(assembly_walker) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!! NOT TestValid(assembly_walker)"))
		return
	end
	
	if TestValid(assembly_walker_left_arm) then
		assembly_walker_left_arm.Highlight(true)
	else 
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!!Thread_Monitor_Assembly_Walker_Puzzle NOT TestValid(assembly_left_arm) "))
	end
	
	if TestValid(assembly_walker_right_arm) then
		assembly_walker_right_arm.Highlight(true)
	end
	
	while TestValid(assembly_walker_left_arm) do
		Sleep(1)
	end
	
	while TestValid(assembly_walker_right_arm) do
		Sleep(1)
	end
	
	if TestValid(assembly_walker_left_shield) or TestValid(assembly_walker_right_shield) then
		Create_Thread("Thread_Dialog_Controller", dialog_assembly_walker_arms_destoyed)
	end
	
	if TestValid(assembly_walker_left_shield) then
		assembly_walker_left_shield.Highlight(true)
	end
	
	if TestValid(assembly_walker_right_shield) then
		assembly_walker_right_shield.Highlight(true)
	end
	
	while TestValid(assembly_walker_left_shield) do
		Sleep(1)
	end
	
	while TestValid(assembly_walker_right_shield) do
		Sleep(1)
	end
	
	if TestValid(assembly_face_cap) then
		Create_Thread("Thread_Dialog_Controller", dialog_assembly_walker_shields_destoyed)
	end
	
	if TestValid(assembly_face_cap) then
		assembly_face_cap.Highlight(true)
	end
	
	while TestValid(assembly_face_cap) do
		Sleep(1)
	end
	
	if TestValid(assembly_walker_core) then
		Create_Thread("Thread_Dialog_Controller", dialog_assembly_walker_front_panel_destroyed)
	end
	
	if TestValid(assembly_walker_core) then
		assembly_walker_core.Highlight(true)
	end
	

end








function Callback_ArrivalSite_Destroyed()
	counter_arrival_sites = counter_arrival_sites - 1
	
	if bool_tracking_victory_conditions == false then
		bool_tracking_victory_conditions = true
	end
	
	if counter_arrival_sites < 0 then --safety
		counter_arrival_sites = 0
	end
	
	Remove_Radar_Blip("blip_alien_arrival_site")
end

function Callback_GlyphCarver_Killed()
	counter_glyph_carvers = counter_glyph_carvers - 1
	
	if counter_glyph_carvers < 0 then --safety
		counter_glyph_carvers = 0
	end
end

function Callback_HabitatWalker_Destroyed()
	counter_habitat_walkers = counter_habitat_walkers - 1
	
	if counter_habitat_walkers < 0 then --safety
		counter_habitat_walkers = 0
	end
end

function Callback_AssemblyWalker_Destroyed()
	_CustomScriptMessage("JoeLog.txt", string.format("assembly"))
	obj_assembly_down=true
	counter_assembly_walkers = counter_assembly_walkers - 1
	
	_CustomScriptMessage("JoeLog.txt", string.format("walker"))
	Create_Thread("Thread_Dialog_Controller", dialog_assembly_walker_destroyed)
	
	_CustomScriptMessage("JoeLog.txt", string.format("destroyed"))
	Remove_Radar_Blip("blip_assembly_walker")
	
	--Objective_Complete(NM04_Objective04) --("Destroy the Assembly Walker.")
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_D_COMPLETE"} )--Objective complete: Destroy the Assembly Walker.
	
	_CustomScriptMessage("JoeLog.txt", string.format("completely"))
	obj_assembly_down=true
	
	if counter_assembly_walkers < 0 then --safety
		counter_assembly_walkers = 0
	end
end

function Callback_ScanDrone_Destroyed()
	counter_scan_drones = counter_scan_drones - 1
	
	if counter_scan_drones < 0 then --safety
		counter_scan_drones = 0
	end
	
	Remove_Radar_Blip("blip_scan_drone")
	
end

function Thread_Track_Victory_Conditions()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Track_Victory_Conditions: HIT!!"))
	while not (bool_mission_failure) and not (bool_mission_success) do
	
		if obj_base_established and (counter_arrival_sites == 0) and (counter_habitat_walkers == 0) and (counter_scan_drones == 0)  and (not win_cond_1) then
			
			Objective_Complete(NM04_Objective05) --("Destroy the Hierarchy Base.")
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_E_COMPLETE"})--Objective complete: Destroy the Hierarchy base.
			
	_CustomScriptMessage("JoeLog.txt", string.format("win"))
			Create_Thread("Thread_Dialog_Controller", dialog_alien_base_destroyed)
	_CustomScriptMessage("JoeLog.txt", string.format("cond_1"))
			win_cond_1=true
		end
		
		if obj_assembly_given and obj_assembly_down and (not win_cond_2) then
			Objective_Complete(NM04_Objective04) --("Destroy the Assembly Walker.")
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_D_COMPLETE"})--Objective complete: Destroy the Hierarchy base.
	_CustomScriptMessage("JoeLog.txt", string.format("win"))
			win_cond_2=true
	_CustomScriptMessage("JoeLog.txt", string.format("cond_2"))
		end
				

		_CustomScriptMessage("JoeLog.txt", string.format("counter_arrival_sites = %d", counter_arrival_sites))
		_CustomScriptMessage("JoeLog.txt", string.format("counter_glyph_carvers = %d", counter_glyph_carvers))
		_CustomScriptMessage("JoeLog.txt", string.format("counter_habitat_walkers = %d", counter_habitat_walkers))
		_CustomScriptMessage("JoeLog.txt", string.format("counter_assembly_walkers = %d", counter_assembly_walkers))
		_CustomScriptMessage("JoeLog.txt", string.format("counter_scan_drones = %d", counter_scan_drones))
		
		Sleep(1)
	end
end
	
function Thread_Victory_Checks()
	while true do
		if (win_cond_1 and win_cond_2) then
	_CustomScriptMessage("JoeLog.txt", string.format("win cond 1 and win cond 2"))
			if not bool_mission_success then
				Create_Thread("Thread_Mission_Complete")
				bool_mission_success = true
			end
		end
		
		if win_cond_2 then
	_CustomScriptMessage("JoeLog.txt", string.format("What"))
			if not obj_base_established then
	_CustomScriptMessage("JoeLog.txt", string.format("The"))
				if not bool_mission_success then
	_CustomScriptMessage("JoeLog.txt", string.format("Hell?"))
					Create_Thread("Thread_Mission_Complete")
					bool_mission_success = true
				end
			end
		end
		Sleep(1)
	--_CustomScriptMessage("JoeLog.txt", string.format("wtf is this not updating?"))
	end
end

function Thread_Aliens_Attack_Humans()
	--Create_Thread("Thread_Dialog_Controller", dialog_protect_the_humans) -- may want to delay this dialog until humans acutally get attacked
	
	for i, human_attacker01 in pairs(human_attackers01_list) do
		if TestValid(human_attacker01) then
				human_attacker01.Set_Object_Context_ID("NM04_StoryCampaign")
				human_attacker01.Register_Signal_Handler(Callback_Human_Attacker01_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
				
				
				human_attacker01.Prevent_AI_Usage(true)
				human_attacker01.Activate_Ability("Reaper_Auto_Gather_Resources", false)
				
		end
	end
	bool_human_attackers01_on_board = true
	
	
	
	for i, town01_human in pairs(town01_humans_list) do
		if TestValid(town01_human) then
			town01_human.Register_Signal_Handler(Callback_Town01_Human_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
		end
	end
	
	for i, town02_human in pairs(town02_humans_list) do
		if TestValid(town02_human) then
			town02_human.Register_Signal_Handler(Callback_Town02_Human_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
		end
	end
	
	for i, town03_human in pairs(town03_humans_list) do
		if TestValid(town03_human) then
			town03_human.Register_Signal_Handler(Callback_Town03_Human_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
		end
	end
	
	for i, town04_human in pairs(town04_humans_list) do
		if TestValid(town04_human) then
			town04_human.Register_Signal_Handler(Callback_Town04_Human_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
		end
	end
	
	if TestValid(human_attackers01_list[1]) then
		BlockOnCommand(human_attackers01_list[1].Move_To(reaper_starting_goto))
	end
	
	Hunt(human_attackers01_list, "NM04_Human_Hunters_Priorities", true, false, human_town01, 300)
end

function Thread_AttackGroup02_Attack_Humans()

	Sleep(GameRandom(10, 20))
	
	for i, human_attacker02 in pairs(human_attackers02_list) do
		if TestValid(human_attacker02) then
				human_attacker02.Set_Object_Context_ID("NM04_StoryCampaign")
				human_attacker02.Register_Signal_Handler(Callback_Human_Attacker02_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
				
				human_attacker02.Prevent_AI_Usage(true)
				human_attacker02.Activate_Ability("Reaper_Auto_Gather_Resources", false)
		end
	end
	bool_human_attackers02_on_board = true
	
	if TestValid(human_attackers02_list[1]) then
		BlockOnCommand(human_attackers02_list[1].Move_To(reaper_starting_goto))
	end

	if bool_humantown02_active == true then
		Hunt(human_attackers02_list, "NM04_Human_Hunters_Priorities", true, false, human_town02, 300)
	elseif bool_humantown03_active == true then
		Hunt(human_attackers02_list, "NM04_Human_Hunters_Priorities", true, false, human_town03, 300)
	elseif bool_humantown04_active == true then
		Hunt(human_attackers02_list, "NM04_Human_Hunters_Priorities", true, false, human_town04, 300)
	elseif bool_humantown01_active == true then
		Hunt(human_attackers02_list, "NM04_Human_Hunters_Priorities", true, false, human_town01, 300)
	else
		for i, human_attacker02 in pairs(human_attackers02_list) do
			if TestValid(human_attacker02) then
					human_attacker02.Unregister_Signal_Handler(Callback_Human_Attacker02_Destroyed)
					human_attacker02.Prevent_AI_Usage(false)
					human_attacker02.Activate_Ability("Reaper_Auto_Gather_Resources", true)
			end
		end
	end
end

function Thread_AttackGroup03_Attack_Humans()

	Sleep(GameRandom(10, 20))
	
	for i, human_attacker03 in pairs(human_attackers03_list) do
		if TestValid(human_attacker03) then
				human_attacker03.Set_Object_Context_ID("NM04_StoryCampaign")
				human_attacker03.Register_Signal_Handler(Callback_Human_Attacker03_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
				
				human_attacker03.Prevent_AI_Usage(true)
				human_attacker03.Activate_Ability("Reaper_Auto_Gather_Resources", false)
		end
	end
	bool_human_attackers03_on_board = true
	
	if TestValid(human_attackers03_list[1]) then
		BlockOnCommand(human_attackers03_list[1].Move_To(reaper_starting_goto))
	end
	
	if bool_humantown03_active == true then
		Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false, human_town03, 300)
	elseif bool_humantown04_active == true then
		Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false, human_town04, 300)
	elseif bool_humantown02_active == true then
		Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false, human_town02, 300)
	elseif bool_humantown01_active == true then
		Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false, human_town01, 300)
	else
		for i, human_attacker03 in pairs(human_attackers03_list) do
			if TestValid(human_attacker03) then
					human_attacker03.Unregister_Signal_Handler(Callback_Human_Attacker03_Destroyed)
					human_attacker03.Prevent_AI_Usage(false)
					human_attacker03.Activate_Ability("Reaper_Auto_Gather_Resources", true)
			end
		end
	end
end

function Thread_AttackGroup04_Attack_Humans()

	Sleep(GameRandom(10, 30))
	
	for i, human_attacker04 in pairs(human_attackers04_list) do
		if TestValid(human_attacker04) then
				human_attacker04.Set_Object_Context_ID("NM04_StoryCampaign")
				human_attacker04.Register_Signal_Handler(Callback_Human_Attacker04_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
				
				human_attacker04.Prevent_AI_Usage(true)
				human_attacker04.Activate_Ability("Reaper_Auto_Gather_Resources", false)
		end
	end
	bool_human_attackers04_on_board = true
	
	if TestValid(human_attackers04_list[1]) then
		BlockOnCommand(human_attackers04_list[1].Move_To(reaper_starting_goto))
	end
	
	if bool_humantown04_active == true then
		Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false, human_town04, 300)
	elseif bool_humantown03_active == true then
		Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false, human_town03, 300)
	elseif bool_humantown02_active == true then
		Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false, human_town02, 300)
	elseif bool_humantown01_active == true then
		Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false, human_town01, 300)
	else
		for i, human_attacker04 in pairs(human_attackers04_list) do
			if TestValid(human_attacker04) then
					human_attacker04.Unregister_Signal_Handler(Callback_Human_Attacker04_Destroyed)
					human_attacker04.Prevent_AI_Usage(false)
					human_attacker04.Activate_Ability("Reaper_Auto_Gather_Resources", true)
			end
		end
	end
end

function Callback_Town01_Human_Destroyed()
	counter_town01_humans_killed = counter_town01_humans_killed + 1
	
	if bool_first_human_killed == true then
		bool_first_human_killed = false
		Create_Thread("Thread_Dialog_Controller", dialog_protect_the_humans) -- may want to delay this dialog until humans acutally get attacked
		
		fow_reveal_human_town01 = FogOfWar.Reveal(player_faction, human_town01, 250, 250)
	end
	
	_CustomScriptMessage("JoeLog.txt", string.format("counter_town01_humans_killed = %d", counter_town01_humans_killed))
	
	if counter_town01_humans_killed >= counter_town01_humans then -- this town is now empty...remove radar blip and fow reveal
		bool_humantown01_active = false
		fow_reveal_human_town01.Undo_Reveal()
		Remove_Radar_Blip("blip_human_town01")
		
		counter_human_villages = counter_human_villages - 1
		if counter_human_villages <= 0 then 
			counter_human_villages = 0 
		else
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_B_NOTICE"} )--Objective complete: Protect the sentients.
			if bool_human_attackers01_on_board then
				Hunt(human_attackers01_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers02_on_board then
				Hunt(human_attackers02_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers03_on_board then
				Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers04_on_board then
				Hunt(human_attackers04_list, "NM04_Human_Hunters_Priorities", true, false)
			end
		end
		
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS04_OBJECTIVE_B")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(counter_human_villages), 1)
		Set_Objective_Text(NM04_Objective03, out_string)
		
	end
	
	if counter_human_villages == 0 then -- all humans have been destroyed, fail the objective and the mission
		if bool_mission_success ~= true then
			bool_mission_failure = true
			failure_text = "TEXT_SP_MISSION_NVS04_OBJECTIVE_B_FAILED"
			
			Create_Thread("Thread_Dialog_Controller", dialog_mirabel_killed) -- probably need human-protecting failure specific dialog here
		end
	end

end

function Callback_Town02_Human_Destroyed()
	counter_town02_humans_killed = counter_town02_humans_killed + 1
	
	_CustomScriptMessage("JoeLog.txt", string.format("counter_town02_humans_killed = %d", counter_town02_humans_killed))

	if counter_town02_humans_killed >= counter_town02_humans then -- this town is now empty...remove radar blip and fow reveal
		bool_humantown02_active = false
		fow_reveal_human_town02.Undo_Reveal()
		Remove_Radar_Blip("blip_human_town02")
		
		counter_human_villages = counter_human_villages - 1
		if counter_human_villages <= 0 then 
			counter_human_villages = 0 
		else
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_B_NOTICE"} )--Objective complete: Protect the sentients.
			if bool_human_attackers01_on_board then
				Hunt(human_attackers01_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers02_on_board then
				Hunt(human_attackers02_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers03_on_board then
				Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers04_on_board then
				Hunt(human_attackers04_list, "NM04_Human_Hunters_Priorities", true, false)
			end
		end
		
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS04_OBJECTIVE_B")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(counter_human_villages), 1)
		Set_Objective_Text(NM04_Objective03, out_string)
	end
	
	if counter_human_villages == 0 then -- all humans have been destroyed, fail the objective and the mission
		if bool_mission_success ~= true then
			bool_mission_failure = true
			failure_text = "TEXT_SP_MISSION_NVS04_OBJECTIVE_B_FAILED"
			Create_Thread("Thread_Dialog_Controller", dialog_mirabel_killed) -- probably need human-protecting failure specific dialog here
			
		end
	end

end

function Callback_Town03_Human_Destroyed()
	counter_town03_humans_killed = counter_town03_humans_killed + 1
	
	_CustomScriptMessage("JoeLog.txt", string.format("counter_town03_humans_killed = %d", counter_town03_humans_killed))
	
	if counter_town03_humans_killed >= counter_town03_humans then -- this town is now empty...remove radar blip and fow reveal
		bool_humantown03_active = false
		fow_reveal_human_town03.Undo_Reveal()
		Remove_Radar_Blip("blip_human_town03")
		
		counter_human_villages = counter_human_villages - 1
		if counter_human_villages <= 0 then 
			counter_human_villages = 0 
		else
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_B_NOTICE"} )--Objective complete: Protect the sentients.
			if bool_human_attackers01_on_board then
				Hunt(human_attackers01_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers02_on_board then
				Hunt(human_attackers02_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers03_on_board then
				Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers04_on_board then
				Hunt(human_attackers04_list, "NM04_Human_Hunters_Priorities", true, false)
			end
		end
		
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS04_OBJECTIVE_B")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(counter_human_villages), 1)
		Set_Objective_Text(NM04_Objective03, out_string)
	end
	
	if counter_human_villages == 0 then -- all humans have been destroyed, fail the objective and the mission
		if bool_mission_success ~= true then
			bool_mission_failure = true
			failure_text = "TEXT_SP_MISSION_NVS04_OBJECTIVE_B_FAILED"
			Create_Thread("Thread_Dialog_Controller", dialog_mirabel_killed) -- probably need human-protecting failure specific dialog here
		end
	end
end

function Callback_Town04_Human_Destroyed()
	counter_town04_humans_killed = counter_town04_humans_killed + 1
	
	_CustomScriptMessage("JoeLog.txt", string.format("counter_town04_humans_killed = %d", counter_town04_humans_killed))
	
	if counter_town04_humans_killed >= counter_town04_humans then -- this town is now empty...remove radar blip and fow reveal
		bool_humantown04_active = false
		fow_reveal_human_town04.Undo_Reveal()
		Remove_Radar_Blip("blip_human_town04")
		
		counter_human_villages = counter_human_villages - 1
		if counter_human_villages <= 0 then 
			counter_human_villages = 0 
		else
			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_B_NOTICE"} )--Objective complete: Protect the sentients.
			if bool_human_attackers01_on_board then
				Hunt(human_attackers01_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers02_on_board then
				Hunt(human_attackers02_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers03_on_board then
				Hunt(human_attackers03_list, "NM04_Human_Hunters_Priorities", true, false)
			elseif bool_human_attackers04_on_board then
				Hunt(human_attackers04_list, "NM04_Human_Hunters_Priorities", true, false)
			end
		end
		
		out_string = Get_Game_Text("TEXT_SP_MISSION_NVS04_OBJECTIVE_B")
		out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(counter_human_villages), 1)
		Set_Objective_Text(NM04_Objective03, out_string)
	end
	
	if counter_human_villages == 0 then -- all humans have been destroyed, fail the objective and the mission
		if bool_mission_success ~= true then
			bool_mission_failure = true
			failure_text = "TEXT_SP_MISSION_NVS04_OBJECTIVE_B_FAILED"
			Create_Thread("Thread_Dialog_Controller", dialog_mirabel_killed) -- probably need human-protecting failure specific dialog here
		end
	end

end

function Callback_Human_Attacker01_Destroyed() 
	counter_human_attackers01_killed = counter_human_attackers01_killed + 1
	
	if counter_human_attackers01_killed >= counter_human_attackers01 then -- all attack-group-01 aliens have been destroyed, send in wave 02
		if bool_mission_failure ~= true then
			bool_human_attackers01_on_board = false
			Create_Thread("Thread_AttackGroup02_Attack_Humans")
		end
	end
end

function Callback_Human_Attacker02_Destroyed() 
	counter_human_attackers02_killed = counter_human_attackers02_killed + 1
	
	if counter_human_attackers02_killed >= counter_human_attackers02 then -- all attack-group-01 aliens have been destroyed, send in wave 02
		if bool_mission_failure ~= true then
			bool_human_attackers02_on_board = false
			Create_Thread("Thread_AttackGroup03_Attack_Humans")
		end
	end
end

--nixing
function Callback_Human_Attacker03_Destroyed() 
	counter_human_attackers03_killed = counter_human_attackers03_killed + 1
	
	if counter_human_attackers03_killed >= counter_human_attackers03 then -- all attack-group-03 aliens have been destroyed...finish objective
		bool_human_attackers03_on_board = false 
		Create_Thread("Thread_AttackGroup04_Attack_Humans")
	end
end

function Callback_Human_Attacker04_Destroyed() 
	counter_human_attackers04_killed = counter_human_attackers04_killed + 1
	
	if counter_human_attackers04_killed >= counter_human_attackers04 then -- all attack-group-03 aliens have been destroyed...finish objective
		bool_human_attackers04_on_board = false 
		--Create_Thread("Thread_AttackGroup04_Attack_Humans")
	end
end

function Thread_Monolith_Orders(unit)
	local local_monolith = unit
	
	while (true) do
		if not TestValid(local_monolith) then
			return
		end
		--go harass resource collectors if there are any
		local resource_target = nil
		local loop_counter = 0
		while resource_target == nil and loop_counter < 10 do
			potential_resource_target_list = Find_All_Objects_Of_Type("NOVUS_INPUT_STATION")
			counter_potential_resource_target_list =  table.getn(potential_resource_target_list)
			random_roll = GameRandom(1, counter_potential_resource_target_list) 
			resource_target = potential_resource_target_list[random_roll]
			loop_counter = loop_counter + 1
			Sleep(1)
		end
		
		if TestValid(local_monolith) and TestValid(resource_target) then
			
			Hunt(local_monolith, "AntiDefault", true, false, resource_target, 250)
		else
			Hunt(local_monolith, "AntiDefault", true, false, novus_base, 250)
			return
		end
		
		while TestValid(resource_target) do
			Sleep(1)
		end
		Sleep(1)
	end
	
end

function Callback_Monolith_Killed()
   _CustomScriptMessage("JoeLog.txt", string.format("Callback_Monolith_Killed"))
	Create_Thread("Thread_Monolith_Killed")
end

function Thread_Monolith_Killed()
	Sleep(GameRandom(30, 60))
	Story_AI_Request_Build_Units(aliens, Find_Object_Type("ALIEN_CYLINDER"), 1)
end

--Object.Is_Under_Effects_Of_Ability(ability_name)
--function Story_AI_Request_Build_Units(player, type_to_build, number_to_build)
--function Story_AI_Request_Build_Structure_Or_Walker(player, type_to_build, position)
--function Story_AI_Request_Build_Hard_Point(player, type_to_build, on_unit)
--Story_AI_Request_Build_Structure_Or_Walker(player, structure_type, nil)


--******************************************************
--team scripts and death callback for the capture team guys
--******************************************************
function Thread_CaptureTeam_Orders(list)
	_CustomScriptMessage("JoeLog.txt", string.format("function Thread_CaptureTeam_Orders(list) HIT!"))
	local local_capture_team = list
	
	if TestValid(local_capture_team[1]) then
		Hunt(local_capture_team, "AntiDefault", true, true, local_capture_team[1], 125)
	end
	Sleep(10)
		
	while (true) do
		
		local target_refinery = nil
		
		for i, refinery in pairs(refinery_list) do
			if TestValid(refinery) and refinery.Get_Owner() ~= aliens  then
				target_refinery = refinery
				_CustomScriptMessage("JoeLog.txt", string.format("Thread_CaptureTeam_Orders(list) target_refinery determined!"))
				break
			end
		end
		
		if not TestValid(target_refinery)  then -- no refineries to capture...go attack the novus base and kill this thread
			_CustomScriptMessage("JoeLog.txt", string.format("Thread_CaptureTeam_Orders() no refineries to capture...go attack the novus base and kill this thread"))
			Hunt(local_capture_team, "AntiDefault", true, false, novus_base, 250)
			return
		else
			Formation_Move(local_capture_team, target_refinery.Get_Position())
		end
		
		--choose who is going to capture the refinery
		local  capture_guy = nil
		for i, local_capture_team_member in pairs(local_capture_team) do
			if TestValid(local_capture_team_member) and TestValid(target_refinery) then
				capture_guy = local_capture_team_member
				break
			end
		end
		
		--everyone else guard the capture guy
		for i, local_capture_team_member in pairs(local_capture_team) do
			if TestValid(local_capture_team_member) and local_capture_team_member ~= capture_guy then
				Hunt(local_capture_team_member, "AntiDefault", true, true, capture_guy, 25)
			end
		end
		
		if TestValid(capture_guy) and TestValid(target_refinery) then
			BlockOnCommand(capture_guy.Activate_Ability("Grunt_Capture", true, target_refinery))
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_CaptureTeam_Orders: capture_guy or refinery is now not testing valid! killing thread"))
			return
		end
		
		while TestValid(target_refinery) and (target_refinery.Get_Owner() ~= aliens) do
			Sleep(1)
		end
		
		Sleep(1)
	end
end

function Callback_CaptureTeamMemeber_Killed()
   _CustomScriptMessage("JoeLog.txt", string.format("Callback_CaptureTeamMemeber_Killed"))
   counter_capture_team_members_killed = counter_capture_team_members_killed + 1
   if counter_capture_team_members_killed == counter_capture_team_members then
      _CustomScriptMessage("JoeLog.txt", string.format("counter_capture_team_members_killed == counter_capture_team_members"))
      
		--your team is dead...make a new one
		Thread.Kill(thead_id_capture_team_orders) 
		bool_capture_team_destroyed = true
		new_capture_team = {}
		Story_AI_Request_Build_Units(aliens, Find_Object_Type("ALIEN_GRUNT"), counter_capture_team_members)
		
   end
end





--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script
function Callback_Mirabel_Destroyed()
	if bool_mission_success ~= true then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
		Create_Thread("Thread_Dialog_Controller", dialog_mirabel_killed)
		failure_text = "TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MIRABEL"
	end
end


function Callback_Portal_Destroyed()
	if bool_mission_success ~= true then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
		Create_Thread("Thread_Dialog_Controller", dialog_mirabel_killed)
		failure_text = "TEXT_SP_MISSION_NVS04_OBJECTIVE_C_FAILED"
	end
end

function Callback_Transport_Destroyed()
	if bool_mission_success ~= true then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
		Create_Thread("Thread_Dialog_Controller", dialog_mirabel_killed)
		failure_text = "TEXT_SP_MISSION_NVS04_OBJECTIVE_C_FAILED"
	end
end



















































function Cache_Models()
	-- precache the models we expect to spawn from script here so they load faster.


end

function Define_Hints()
   _CustomScriptMessage("JoeLog.txt", string.format("NM04 Define_Hints Hit!"))
	
	local credits
	credits = player_faction.Get_Credits()
	credits = 10000 - credits
	if credits > 0 then
		player_faction.Give_Money(credits)
	end
   
   mirabel = Find_First_Object("Novus_Hero_Mech")
   mirabel_spawn = Find_Hint("MARKER_GENERIC","mirabel-spawn")
   if not TestValid(mirabel) then
      _CustomScriptMessage("JoeLog.txt", string.format("****************WARNING! Story_Campaign_Novus_NM01 cannot find Mirabel! Spawning a new one"))
      mirabel = Spawn_Unit(Find_Object_Type("Novus_Hero_Mech"), mirabel_spawn, player_faction) 
   end
	
	
	-- heroes nerfed late, so adding damage modifier, Mirabel old health(1800) / Charos new health(1000) - 1 = -.45
	if TestValid(mirabel) then
		mirabel.Add_Attribute_Modifier( "Universal_Damage_Modifier", -.45)
	end
	
	if bool_make_mirabel_unkillable == true then
		mirabel.Set_Cannot_Be_Killed(true)
	end
   
   Point_Camera_At(mirabel)
   mirabel.Register_Signal_Handler(Callback_Mirabel_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
	
	--player_faction.Give_Money(10000)
	aliens.Give_Money(20000)
	aliens.Allow_Autonomous_AI_Goal_Activation(false)
	alien_base = Find_Hint("MARKER_GENERIC_RED","alien-base")
	novus_base = Find_Hint("MARKER_GENERIC_RED","novus-base")
	
	
	assembly_walker_build_spot = Find_Hint("MARKER_GENERIC_BLUE","assembly-walker-build-spot")
	assembly_walker_guard_spot = Find_Hint("MARKER_GENERIC_BLUE","assembly-walker-guard-spot")
	
	refinery_list = Find_All_Objects_Of_Type("NEUTRAL_REFINERY")
	
	for i, refinery in pairs(refinery_list) do
		if TestValid(refinery) then
			refinery.Set_Cannot_Be_Killed(true)
		end
	end
	
	--put the secure-team into a hide_me context for now
	secure_team = Find_All_Objects_With_Hint("secure")
	for i, secure_team_member in pairs(secure_team) do
		if TestValid(secure_team_member) then
				secure_team_member.Set_Object_Context_ID("hide_me")
		end
	end
	
	secure_team_walker = Find_Hint("NM04_CUSTOM_HABITAT_WALKER","secure-walker")
	if TestValid(secure_team_walker) then
		secure_team_walker.Set_Object_Context_ID("hide_me")
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!  NOT TestValid(secure_team_walker) !"))
	end
	
	glyph_carver_guards = Find_All_Objects_With_Hint("glyphcarver-guard")
	for i, glyph_carver_guard in pairs(glyph_carver_guards) do
		if TestValid(glyph_carver_guard) then
				glyph_carver_guard.Set_Object_Context_ID("hide_me")
		end
	end
	
	assembly_walker = Find_Hint("ALIEN_WALKER_ASSEMBLY","assembly")
	if TestValid(assembly_walker) then
		assembly_walker.Set_Object_Context_ID("hide_me")
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!  NOT TestValid(secure_team_walker) !"))
	end
	
	--put the aliens builder-team into a hide_me context for now
	builder_team = Find_All_Objects_With_Hint("builder")
	for i, builder_team_member in pairs(builder_team) do
		if TestValid(builder_team_member) then
				builder_team_member.Set_Object_Context_ID("hide_me")
				_CustomScriptMessage("JoeLog.txt", string.format("builder_team_member.Set_Object_Context_ID(hide_me)"))
		end
	end
	
	turret_list = Find_All_Objects_Of_Type("NM04_MILITARY_TURRET_GROUND")
	for i, turret in pairs(turret_list) do
		if TestValid(turret) then
			--Add_Radar_Blip(turret, "DEFAULT", "blip_turret_"..i)
			--Create_Thread("Thread_Monitor_Turret", turret)
			
			turret.Despawn()
		end
	end
	
	--turret_reveal_list = {}
	--town01_turret01 = Find_Hint("NM04_MILITARY_TURRET_GROUND","town01-turret01")	
	--type_turret_fire = Find_Object_Type("CIN_GROUND_FIRE_MEDIUM")
	
	--definitions for protect the humans objective
	human_town01 = Find_Hint("MARKER_GENERIC","human-town01")	
	human_town02 = Find_Hint("MARKER_GENERIC","human-town02")	
	human_town03 = Find_Hint("MARKER_GENERIC","human-town03")	
	human_town04 = Find_Hint("MARKER_GENERIC","human-town04")	

	counter_human_villages = 4
	
	offmap_spawnflag = Find_Hint("MARKER_GENERIC_GREEN","offmap-spawnflag")	
	
	human_town01_spawnflag = Find_Hint("MARKER_GENERIC_GREEN","town01-spawn")	
	bool_town01_guards_spawned = false
	
	town01_humans_list =  Find_All_Objects_With_Hint("town01-human")
	counter_town01_humans = table.getn(town01_humans_list)
	counter_town01_humans_killed = 0
	
	town02_humans_list =  Find_All_Objects_With_Hint("town02-human")
	counter_town02_humans = table.getn(town02_humans_list)
	counter_town02_humans_killed = 0
	
	town03_humans_list =  Find_All_Objects_With_Hint("town03-human")
	counter_town03_humans = table.getn(town03_humans_list)
	counter_town03_humans_killed = 0
	
	town04_humans_list =  Find_All_Objects_With_Hint("town04-human")
	counter_town04_humans = table.getn(town04_humans_list)
	counter_town04_humans_killed = 0
	
	starting_inverter = Find_Hint("NOVUS_FIELD_INVERTER","starting-inverter")	
	starting_inverter_goto = Find_Hint("MARKER_GENERIC_GREEN","starting-inverter-goto")	
	
	reaper_starting_goto = Find_Hint("MARKER_GENERIC_GREEN","reaper-starting-goto")	
	
	field_inverter_list = Find_All_Objects_Of_Type("NOVUS_FIELD_INVERTER")
	for i, field_inverter in pairs(field_inverter_list) do
		if TestValid(field_inverter) then
				field_inverter.Register_Signal_Handler(Callback_FieldInverter_Destroyed, "OBJECT_HEALTH_AT_ZERO")
				counter_field_inverters = counter_field_inverters + 1
		end
	end
	
	
	human_attackers01_list = Find_All_Objects_With_Hint("human-attacker01")
	starting_reaper = human_attackers01_list[1]
	counter_human_attackers01 = table.getn(human_attackers01_list)
	counter_human_attackers01_killed = 0
	for i, human_attackers01 in pairs(human_attackers01_list) do
		if TestValid(human_attackers01) then
				human_attackers01.Set_Object_Context_ID("hide_me")
		end
	end
	bool_human_attackers01_on_board = false
	
	human_attackers02_list = Find_All_Objects_With_Hint("human-attacker02")
	counter_human_attackers02 = table.getn(human_attackers02_list)
	counter_human_attackers02_killed = 0
	for i, human_attackers02 in pairs(human_attackers02_list) do
		if TestValid(human_attackers02) then
				human_attackers02.Set_Object_Context_ID("hide_me")
		end
	end
	bool_human_attackers02_on_board = false
	
	human_attackers03_list = Find_All_Objects_With_Hint("human-attacker03")
	counter_human_attackers03 = table.getn(human_attackers03_list)
	counter_human_attackers03_killed = 0
	for i, human_attackers03 in pairs(human_attackers03_list) do
		if TestValid(human_attackers03) then
				human_attackers03.Set_Object_Context_ID("hide_me")
		end
	end
	bool_human_attackers03_on_board = false
	
	human_attackers04_list = Find_All_Objects_With_Hint("human-attacker04")
	counter_human_attackers04 = table.getn(human_attackers04_list)
	counter_human_attackers04_killed = 0
	for i, human_attackers04 in pairs(human_attackers04_list) do
		if TestValid(human_attackers04) then
				human_attackers04.Set_Object_Context_ID("hide_me")
		end
	end
	bool_human_attackers04_on_board = false
	
	portal_piece_list = Find_All_Objects_With_Hint("portal-piece")
	alien_units_to_maintain_list = {}

	transport_spawn_location = Find_Hint("MARKER_GENERIC_GREEN","novus-transport-spawn")
	reinforcement_spawn_point = Find_Hint("MARKER_GENERIC_GREEN","novus-transport-goto")
	
	portal_trasnport= Find_First_Object("NOVUS_PORTAL_TRANSPORT")
	if TestValid(portal_trasnport) then
		_CustomScriptMessage("JoeLog.txt", string.format("UI_Enable_For_Object(portal_trasnport, false)"))
		UI_Enable_For_Object(portal_trasnport, false)--turning off odd button on this unit
		portal_trasnport.Register_Signal_Handler(Callback_Transport_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
	end
	
end

function Thread_Monitor_Turret(local_turret)
	if not TestValid(local_turret) then
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_Monitor_Turret: not TestValid(local_turret)"))
		return
	end
	
	local_turret.Change_Owner(player_faction)--so he can capture it
	--local_turret.Set_Cannot_Be_Killed(true)
	local local_turret_fire = Spawn_Unit(type_turret_fire, local_turret.Get_Position(), neutral) 
	
	while TestValid(local_turret) do
		
		local_turret.Prevent_All_Fire(true)
		local_turret.Prevent_Opportunity_Fire(true) 
		
		local turret_health = 0
		
		while turret_health < .5 do
			if TestValid(local_turret) then
				turret_health = local_turret.Get_Hull()
			else
				break
			end
			Sleep(1)
		end
		
		if TestValid(local_turret_fire) then
			_CustomScriptMessage("JoeLog.txt", string.format("local_turret_fire.Despawn()"))
			local_turret_fire.Despawn()
		end
		
		while turret_health < .75 do
			--turret_health = local_turret.Get_Hull()
			if TestValid(local_turret) then
				turret_health = local_turret.Get_Hull()
			else
				break
			end
			Sleep(1)
		end
		
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Monitor_Turret should now come ON LINE"))
		
		if TestValid(local_turret) then
			local_turret.Prevent_All_Fire(false)
			local_turret.Prevent_Opportunity_Fire(false) 
		end
		--need to do a reveal here...
		for i, turret in pairs(turret_list) do
			if  turret == local_turret then
				if TestValid(turret) then
					turret_reveal_list[i] = FogOfWar.Reveal(player_faction, turret, 150, 150)
					
				end
			end
		end
	

		while turret_health > 0.33 do
			if TestValid(local_turret) then
				turret_health = local_turret.Get_Hull()
			else
				break
			end
			Sleep(1)
		end
		
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Monitor_Turret should now come OFF LINE"))
		
		if not TestValid(local_turret_fire) then
			_CustomScriptMessage("JoeLog.txt", string.format("human_town01_turret01_fire.Hide(false)"))
			--human_town01_turret01_fire.Hide(false)
			if TestValid(local_turret) then
				local_turret_fire = Spawn_Unit(type_turret_fire, local_turret.Get_Position(), neutral) 
			end
		end
		
		for i, turret in pairs(turret_list) do
			if  turret == local_turret then
				if TestValid(turret) then
					--turret_reveal_list[i] = FogOfWar.Reveal(player_faction, turret, 150, 150)
					turret_reveal_list[i].Undo_Reveal()
					
				end
			end
		end

		Sleep(1)
	end
	
end

function Lock_Out_Stuff(bool)
--	player_script = aliens.Get_Script()
	
	player_faction.Lock_Object_Type(Find_Object_Type("NOVUS_SUPERWEAPON_EMP"),bool,STORY) 
	player_faction.Lock_Object_Type(Find_Object_Type("NOVUS_SUPERWEAPON_GRAVITY_BOMB"),bool,STORY) 
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Science_Lab"),bool,STORY) 
	
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Hero_Vertigo"),bool,STORY) 
	player_faction.Lock_Object_Type(Find_Object_Type("Novus_Hero_Founder"),bool,STORY) 
	
	player_faction.Lock_Unit_Ability("Novus_Hero_Mech", "Novus_Mech_Retreat_From_Tactical_Ability",bool,STORY)
	
		player_faction.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Unit_Ability", false, STORY)
		player_faction.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Control_Turret_Area_Special_Ability", false, STORY)
		player_faction.Lock_Unit_Ability("Novus_Hacker", "Novus_Hacker_Lockdown_Area_Special_Ability", false, STORY)
		
	player_faction.Lock_Generator("VirusInfectAuraGenerator", false )	
	player_faction.Lock_Generator("NovusResearchAdvancedFlowEffectGenerator", false )
	
	--please dont produce any extra walkers
	aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly"),bool,STORY) 
	aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Habitat"),bool,STORY) 
	
	
	
	if bool == true then -- this alien stuff gets unlocked, then locked...works opposite of standard player unit bool-calls.
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly_HP_Phase_Tank_Assembly_Pod"),false,STORY) 
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Radiation_Spitter"),false,STORY) 
		
		player_faction.Lock_Object_Type(Find_Object_Type("Novus_Hacker"),false,STORY) 
	else
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Walker_Assembly_HP_Phase_Tank_Assembly_Pod"),true,STORY) 
		aliens.Lock_Object_Type(Find_Object_Type("Alien_Radiation_Spitter"),true,STORY) 
		
		player_faction.Lock_Object_Type(Find_Object_Type("Novus_Hacker"),true,STORY) 
	end
end


--***************************************WIN/LOSS STUFF****************************************************************************************************
function Thread_Mission_Failed()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
	if bool_mission_success ~= true then
		
		bool_mission_failure = true
		
		Letter_Box_In(1)
      Lock_Controls(1)
      Suspend_AI(1)
      Disable_Automatic_Tactical_Mode_Music()
		-- this music is faction specific, 
		-- use: UEA_Lose_Tactical_Event Alien_Lose_Tactical_Event Novus_Lose_Tactical_Event Masari_Lose_Tactical_Event
      --Play_Music("Novus_Lose_Tactical_Event")     
		Play_Music("Lose_To_Alien_Event")  
		
		
		Zoom_Camera.Set_Transition_Time(10)
      Zoom_Camera(.3)
      Rotate_Camera_By(180,30)
      -- the variable  failure_text  is set at the start of mission to contain the default string "TEXT_SP_MISSION_MISSION_FAILED"
      -- upon mission failure of an objective, or hero death, replace the string  failure_text  with the appropriate xls tag 
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {failure_text} )
      Sleep(5)
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
      Fade_Screen_Out(2)
      Sleep(2)
      Lock_Controls(0)
		
		player_script = aliens.Get_Script()
		
		Force_Victory(aliens)
	end
end

function Thread_Mission_Complete()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
	if not bool_mission_failure then
		Objective_Complete(NM04_Objective03)
		Objective_Complete(NM04_Objective03_Hint)
		Objective_Complete(NM04_Objective02) 
		bool_mission_success = true
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
      Sleep(5)
      Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
      Fade_Screen_Out(2)
      Sleep(2)
		
      Lock_Controls(0)
		
		player_script = aliens.Get_Script()
		
		Force_Victory(novus)
	end
end


function Force_Victory(player)
			
	novus.Reset_Story_Locks()
	aliens.Reset_Story_Locks()
	
	if player == player_faction then
		-- Inform the campaign script of our victory.
		global_script.Call_Function("Novus_Tactical_Mission_Over", true) -- true == player wins
		--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
		Quit_Game_Now(player, false, true, false)
	else
		Show_Retry_Dialog()
	end
end


--***************************************DIALOG CONTROLLER****************************************************************************************************




function Thread_Dialog_Controller(conversation)
	if not bool_mission_failed and not bool_mission_success then
		if conversation == dialog_establishing_shot and bool_dialog_establishing_shot == false then
			bool_dialog_establishing_shot = true
		--bool_mission_failure
		--bool_mission_success
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_founder, "NVS04_SCENE06_25")--Founder (FOU): This is our only way home, Mirabel.  The quantum waveforms in your area are at optimal levels. Construct the portal before they weaken - our window is closing.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE05_02")--Mirabel (MIR): I understand.
			end

			Sleep(5)
			if not bool_mission_failed and not bool_mission_success then
				Create_Thread("Thread_Dialog_Controller", dialog_build_the_portal)
			end
			
		elseif conversation == dialog_mirabels_lament and bool_dialog_mirabels_lament == false then
			bool_dialog_mirabels_lament = true
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE02_01") --I've been thinking about what you said about the faces on the tombs.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_founder, "NVS04_SCENE02_02")--It is in your nature as an organic to be highly emotional.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE02_03")--But I should be one of them - back on Lieta Novus with all the others like me. Yet you saved me from extinction. Why?
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_founder, "NVS04_SCENE02_04")--Our programming was different then. Your ancestors – our creators – felt the worth of a species had value.(regrets) Our purpose no longer allows such distractions. The tombs became too numerous to count.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE02_05")--But they're for the dead, sir.  These sentients have a chance to fight!  Shouldn't we be doing more to help them?
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_founder, "NVS04_SCENE02_06")--They may as well be dead. Our programming accepts that outcome, and so should you.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE02_07")--(swallows her emotions)I understand.  I'm just tired of building tombs.
			end
		elseif conversation == dialog_build_the_portal and bool_dialog_build_the_portal == false then
			bool_dialog_build_the_portal = true
			if not bool_mission_failed and not bool_mission_success then
					-- ***** HINT SYSTEM *****
				--putting a capture hint on the closest refinery
				refinery01 = Find_Hint("NEUTRAL_REFINERY","refinery01")
				local scene = Get_Game_Mode_GUI_Scene()
				Add_Attached_Hint(refinery01, HINT_NM04_CAPTURING)
				BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS04_SCENE06_26"))--Founder (FOU): First, you will need to gather local resources to build the portal.  We have detected carbon deposits in the area that should be suitable.
				Create_Thread("Thread_Monitor_Objective01_Timer")
				Create_Thread("Thread_Monitor_Players_Money")
				--Sleep(3)
			--put arrows and radar blips on the oil derricks
				for i, refinery in pairs(refinery_list) do
					if TestValid(refinery) then
						bool_flagging_refineries = true
						--refinery.Highlight(true, -50)
						Add_Radar_Blip(refinery, "DEFAULT", "blip_refinery_"..i)
					
						Create_Thread("Thread_Monitor_Refinery_Owner", refinery)
						
						fow_reveal_refinery_list[i] = FogOfWar.Reveal(player_faction, refinery, 50, 50)
					end
				end
				
				Sleep(1)
				--NM04_Objective01_Hint = Add_Objective("TEXT_SP_MISSION_NVS04_OBJECTIVE_A_HINT")--HINT: Use Ohm Robots to capture oil derriks for added resources.

				bool_establishing_shot_finished = true
				local block02 = Queue_Talking_Head(pip_founder, "NVS04_SCENE06_27")--Founder (FOU): Employ your Field Inverters.  They can provide a magnetic shield against projectiles or serve as an offensive weapon should the conditions dictate.
				BlockOnCommand(block02)
				
			end
	
		elseif conversation == dialog_protect_the_humans and bool_dialog_protect_the_humans == false then
			bool_dialog_protect_the_humans = true

			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE06_42")--Mirabel (MIR): Founder, the Hierarchy are attacking the local humans.
			end
			if not bool_mission_failed and not bool_mission_success then
				local block03 = Queue_Talking_Head(pip_mirabel, "NVS04_SCENE06_43")---Mirabel (MIR): I'm sorry. I can't stand by while this happens.  I’m going to help them.
				--dialog is MIA...blcoking is breaking stuff?
				BlockOnCommand(block03)
			end
			
			Create_Thread("Thread_Add_Sentient_Objective")
			
		elseif conversation == dialog_aliens_invade and bool_dialog_aliens_invade == false then
			bool_dialog_aliens_invade = true 

			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_novus_comm, "NVS04_SCENE05_08") --Novus Comm (NCO): Mirabel, we are detecting a large enemy force entering from the North.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_founder, "NVS04_SCENE06_28")--Founder (FOU): Mirabel, your intervention has revealed our location.  If the Hierarchy capture the portal, they will have a direct route back to our planet.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE06_29")--We can't give up! We still have a chance to go home!
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_founder, "NVS04_SCENE06_30")--Founder (FOU): The risk is too great.  Eliminate the Hierarchy forces and we'll reassemble the portal at a safer location.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_viktor, "NVS04_SCENE05_13")--Viktor (VIK): blitherty blatherty blue
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE05_14")--Mirabel (MIR): Easy, Victor.  Ready the defenses.
			end
		elseif conversation == dialog_intro_new_walker and bool_dialog_intro_new_walker == false then
			bool_dialog_intro_new_walker = true 
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_founder, "NVS04_SCENE05_15")--Founder (FOU): Gads! The hierarchy are using a new walker.
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE05_16")--Mirabel (MIR): New Walker?
			end
			if not bool_mission_failed and not bool_mission_success then
				local block05 = Queue_Talking_Head(pip_founder, "NVS04_SCENE05_17")--Founder (FOU): It's heading right for the portal, you must destroy it quickly!
			
				BlockOnCommand(block05)
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_D_ADD"} )--New objective: Destroy the Assembly Walker.
				Sleep(time_objective_sleep)
				NM04_Objective04 = Add_Objective("TEXT_SP_MISSION_NVS04_OBJECTIVE_D")--Destroy the Assembly Walker.

				Add_Radar_Blip(assembly_walker, "DEFAULT", "blip_assembly_walker")
				--Create_Thread("Thread_Highlight_Assembly_Walker_Hardpoints")
				obj_assembly_given=true
				Sleep(3)
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE06_31")--Mirabel (MIR):We can bring that Walker down by destroying its core. We'll hit the hardpoints first - start with its arms!
			end
						
		elseif conversation == dialog_assembly_walker_arms_destoyed and bool_dialog_assembly_walker_arms_destoyed == false then
			bool_dialog_assembly_walker_arms_destoyed = true
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE06_32")--Mirabel (MIR):Good job. Now we can attack the shield generators. Hit them hard!
			end
		elseif conversation == dialog_assembly_walker_shields_destoyed and bool_dialog_assembly_walker_shields_destoyed == false then
			bool_dialog_assembly_walker_shields_destoyed = true
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE06_33")--Mirabel (MIR)That did it.  Direct your fire on the front panel now.
			end
		elseif conversation == dialog_assembly_walker_front_panel_destroyed and bool_dialog_assembly_walker_front_panel_destroyed == false then	
			bool_dialog_assembly_walker_front_panel_destroyed = true
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE06_34")--Mirabel (MIR)There's our target - the core is exposed! Give it everything we've got!
			end
		elseif conversation == dialog_assembly_walker_destroyed and bool_dialog_assembly_walker_destroyed == false then
			bool_dialog_assembly_walker_destroyed = true
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE06_35")--Mirabel (MIR):Attention all units - the walker is down!
			end
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_viktor, "NVS04_SCENE05_18")--Viktor (VIK): Zippity zap!
			end
			if not bool_mission_failed and not bool_mission_success then
				-- what if you destroy all this crap before the base is built?  this makes sure the objective is skipped [jgs]
				if counter_arrival_sites>0 then
					local blocking_dialog = Queue_Talking_Head(pip_founder, "NVS04_SCENE06_36")--Founder (FOU): Begin your assault on the base - we can't let them reinforce this position.
					BlockOnCommand(blocking_dialog)
					Create_Thread("Thread_Add_Hierarchy_Base_Objective")
				end
			end
			
		elseif conversation == dialog_alien_base_destroyed and bool_dialog_alien_base_destroyed == false then
			bool_dialog_alien_base_destroyed = true
			if not bool_mission_failed then
				_CustomScriptMessage("JoeLog.txt", string.format("dialog_alien_base_destroyed HIT!"))
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE06_37")--Mirabel (MIR): Looks like they're falling back, let's get those portal pieces out of here.
			end
			if not bool_mission_failed then
				local block08 = Queue_Talking_Head(pip_viktor, "NVS04_SCENE05_23")--Viktor (VIK): Wooty Wooty Woot.
				
				BlockOnCommand(block08)
			end
		elseif conversation == dialog_mirabel_killed and bool_dialog_mirabel_killed == false then
			bool_dialog_mirabel_killed = true
			if not bool_mission_success then
				bool_mission_failed = true
				Stop_All_Speech() -- stopping any other mission dialog that might be going on.
				BlockOnCommand(Queue_Talking_Head(pip_founder, "NVS04_SCENE05_24"))--Founder (FOU): We're doomed. You've failed us all, Mirabel! 
				
				Create_Thread("Thread_Mission_Failed")
			end
			
		elseif conversation == dialog_player_has_20k and bool_dialog_player_has_20k == false then 
			bool_dialog_player_has_20k = true
			if not bool_mission_failed and not bool_mission_success then
				Queue_Talking_Head(pip_mirabel, "NVS04_SCENE02_08")--Mirabel (MIR):Good. Now we enough have resources to build the portal.
				--UI_Start_Flash_Queue_Buttons("NM04_NOVUS_PORTAL")
				--UI_Start_Flash_Queue_Buttons("NOVUS_ROBOTIC_ASSEMBLY")
				UI_Start_Flash_Construct_Building("NM04_NOVUS_PORTAL")
			end
		end
	end
end

function Thread_Add_Sentient_Objective()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_B_ADD"} )--New objective: Build the Wormhole Portal within five minutes.
      Sleep(time_objective_sleep)
	NM04_Objective03 = Add_Objective("TEXT_SP_MISSION_NVS04_OBJECTIVE_B")--Protect the sentients (##1 remain).
	out_string = Get_Game_Text("TEXT_SP_MISSION_NVS04_OBJECTIVE_B")
	out_string = Replace_Token(out_string, Get_Localized_Formatted_Number(counter_human_villages), 1)  --_FIX ME
	Set_Objective_Text(NM04_Objective03, out_string)
	
	FogOfWar.Reveal_All(civilian)
	
	--remove refinery blips
	if  bool_flagging_refineries == true then
		for i, refinery in pairs(refinery_list) do
			if TestValid(refinery) then
				Remove_Radar_Blip("blip_refinery_"..i)
				fow_reveal_refinery_list[i].Undo_Reveal()
				bool_flagging_refineries = false
			end
		end
	end
	
	--Sleep(4)
	
	--if TestValid(town01_turret01) then
	--	Add_Attached_Hint(town01_turret01, HINT_NM04_REPAIRING)
	--end

	--NM04_Objective03_Hint = Add_Objective("TEXT_SP_MISSION_NVS04_OBJECTIVE_B_HINT")--HINT: Repair the nearby turrets with your Constructors to help protect the villages.

	fow_reveal_human_town01 = FogOfWar.Reveal(player_faction, human_town01, 250, 250)
	fow_reveal_human_town02 = FogOfWar.Reveal(player_faction, human_town02, 250, 250)
	fow_reveal_human_town03 = FogOfWar.Reveal(player_faction, human_town03, 250, 250)
	fow_reveal_human_town04 = FogOfWar.Reveal(player_faction, human_town04, 250, 250)

	Add_Radar_Blip(human_town01, "Default_Beacon_Placement_Persistent", "blip_human_town01")
	Add_Radar_Blip(human_town02, "Default_Beacon_Placement_Persistent", "blip_human_town02")
	Add_Radar_Blip(human_town03, "Default_Beacon_Placement_Persistent", "blip_human_town03")
	Add_Radar_Blip(human_town04, "Default_Beacon_Placement_Persistent", "blip_human_town04")
end

function Thread_Add_Hierarchy_Base_Objective()
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_E_ADD"} )--New objective: Destroy the Hierarchy base.
      Sleep(time_objective_sleep)
	NM04_Objective05 = Add_Objective("TEXT_SP_MISSION_NVS04_OBJECTIVE_E")--Destroy the Hierarchy base.

	bool_hierarchy_base_objective_active = true
	
	Sleep(2)
	
	if TestValid(object_arrival_site) then
		Add_Radar_Blip(object_arrival_site, "DEFAULT", "blip_alien_arrival_site")
		object_arrival_site.Highlight(true, -50)
	end
	
	if TestValid(object_habitat_walker) then
		Add_Radar_Blip(object_habitat_walker, "DEFAULT", "blip_habitat_walker")
		object_habitat_walker.Highlight(true)
	end
	
	if TestValid(object_scan_drone) then
		Add_Radar_Blip(object_scan_drone, "DEFAULT", "blip_scan_drone")
		object_scan_drone.Highlight(true, -50)
	end
	
	object_glyph_carver_list = Find_All_Objects_Of_Type("Alien_Glyph_Carver")
	for i, glyph_carver in pairs(object_glyph_carver_list) do
		if TestValid(glyph_carver) then
			Add_Radar_Blip(glyph_carver, "DEFAULT", "blip_glyph_carver_"..i)
			glyph_carver.Highlight(true, -50)
		end
	end
	
end

function Thread_Add_Protect_Portal_Objective()
	Sleep(time_objective_sleep)
	
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_NVS04_OBJECTIVE_C_ADD"} )--New objective: Protect the Home Portal at all costs.
	Sleep(time_objective_sleep)
	NM04_Objective02 = Add_Objective("TEXT_SP_MISSION_NVS04_OBJECTIVE_C")--Protect the Home Portal at all costs.
end

function Story_On_Construction_Complete(obj)

	if obj.Get_Type()==Find_Object_Type("NM04_NOVUS_PORTAL") then
		portal_construction=Find_First_Object("NM04_NOVUS_PORTAL")
		portal_construction.Register_Signal_Handler(Callback_Portal_Destroyed, "OBJECT_HEALTH_AT_ZERO") 
	end

	if obj.Get_Type() == type_arrival_site then
		_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: obj.Get_Type() == type_arrival_site"))
		if not bool_testing then
			Story_AI_Request_Build_Units(aliens, Find_Object_Type("ALIEN_CYLINDER"), 1)
		end
		counter_arrival_sites = counter_arrival_sites + 1
		obj.Register_Signal_Handler(Callback_ArrivalSite_Destroyed, "OBJECT_HEALTH_AT_ZERO")
		
		object_arrival_site = obj
		obj_base_established=true
		
		--aliens.Lock_Unit_Ability("ALIEN_SUPERWEAPON_REAPER_TURRET", "Reaper_Auto_Gather_Resources",	false, STORY)
	
	elseif obj.Get_Type() == type_glyph_carver then
		_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: obj.Get_Type() == type_glyph_carver"))
		--counter_glyph_carvers = counter_glyph_carvers + 1
		obj.Register_Signal_Handler(Callback_GlyphCarver_Killed, "OBJECT_HEALTH_AT_ZERO")
		
	elseif obj.Get_Type() == type_reaper_turret then
		_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: obj.Get_Type() == type_reaper_turret"))
		obj.Activate_Ability("Reaper_Auto_Gather_Resources ", true)
		
		--aliens.Lock_Unit_Ability("ALIEN_SUPERWEAPON_REAPER_TURRET", "Reaper_Auto_Gather_Resources",	true, STORY)
		
	elseif obj.Get_Type() == type_habitat_walker then

		_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: obj.Get_Type() == type_habitat_walker, bool_this_is_first_habitat_walker = true"))

		--counter_habitat_walkers = counter_habitat_walkers + 1
		obj.Get_Script().Call_Function("Register_For_Walker_Death", Script, "Callback_HabitatWalker_Destroyed")

	elseif obj.Get_Type() == type_assembly_walker then
		_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: obj.Get_Type() == type_assembly_walker"))
		
	elseif obj.Get_Type() == type_scan_drone then
		_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: obj.Get_Type() == type_scan_drone"))
		counter_scan_drones = counter_scan_drones + 1
		obj.Register_Signal_Handler(Callback_ScanDrone_Destroyed, "OBJECT_HEALTH_AT_ZERO")
		
		object_scan_drone = obj
	
	elseif obj.Get_Type() == type_grunt then
      _CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: obj.Get_Type() == type_grunt"))

		if bool_capture_team_destroyed == true then
			if not TestValid(new_capture_team[1] ) then
				_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: new_capture_team[1]"))
				new_capture_team[1] = obj
				new_capture_team[1].Prevent_AI_Usage(true)
				--guard your current position while you wait for second member
				Hunt(new_capture_team[1], "AntiDefault", true, true, new_capture_team[1], 25)
				bool_building_grunts = false
				
			elseif  TestValid(new_capture_team[1]) then
				_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: new_capture_team[2]"))
				new_capture_team[2] = obj
				new_capture_team[2].Prevent_AI_Usage(true)
				
				new_capture_team[1].Register_Signal_Handler(Callback_CaptureTeamMemeber_Killed, "OBJECT_HEALTH_AT_ZERO")
				new_capture_team[2].Register_Signal_Handler(Callback_CaptureTeamMemeber_Killed, "OBJECT_HEALTH_AT_ZERO")
				
				counter_capture_team_members = table.getn(new_capture_team)
				counter_capture_team_members_killed = 0
				bool_capture_team_destroyed = false
				
				thead_id_capture_team_orders = Create_Thread("Thread_CaptureTeam_Orders", new_capture_team)
				bool_building_grunts = false
			else
				_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! Story_On_Construction_Complete: unknown type_grunt produced"))
			end
		else
			obj.Prevent_AI_Usage(true)
			Create_Thread("Thread_Move_AlienInfantry_Staging_Units", obj)
			total_grunts = total_grunts + 1
			obj.Register_Signal_Handler(Callback_AttackTeam_Grunt_Killed, "OBJECT_HEALTH_AT_ZERO")
			bool_building_grunts = false
		end
		
		
	elseif obj.Get_Type() == object_type_lost_one then	
		obj.Prevent_AI_Usage(true)
		Create_Thread("Thread_Move_AlienInfantry_Staging_Units", obj)
		total_lost_ones = total_lost_ones + 1
		obj.Register_Signal_Handler(Callback_AttackTeam_LostOne_Killed, "OBJECT_HEALTH_AT_ZERO")
		bool_building_lost_ones = false
		
	elseif obj.Get_Type() == object_type_brute then	
		obj.Prevent_AI_Usage(true)
		Create_Thread("Thread_Move_AlienInfantry_Staging_Units", obj)
		total_brutes = total_brutes + 1
		obj.Register_Signal_Handler(Callback_AttackTeam_Brute_Killed, "OBJECT_HEALTH_AT_ZERO")
		bool_building_brutes = false


	elseif obj.Get_Type() == type_defiler then
		_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: obj.Get_Type() == type_defiler"))
		obj.Prevent_AI_Usage(true)
		obj.Register_Signal_Handler(Callback_Defiler_Killed, "OBJECT_HEALTH_AT_ZERO")
		Hunt(obj, "AntiDefault", true, false, novus_base, 250)
		
	elseif obj.Get_Type() == type_recon_tank then
		_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: obj.Get_Type() == type_recon_tank"))
		obj.Prevent_AI_Usage(true)
		obj.Register_Signal_Handler(Callback_ReconTank_Killed, "OBJECT_HEALTH_AT_ZERO")
		Hunt(obj, "AntiDefault", true, false, novus_base, 250)
		
	elseif obj.Get_Type() == type_monolith then
		_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: obj.Get_Type() == type_monolith"))
		obj.Prevent_AI_Usage(true)
		
		obj.Register_Signal_Handler(Callback_Monolith_Killed, "OBJECT_HEALTH_AT_ZERO")
		Create_Thread("Thread_Monolith_Orders", obj)
		
	elseif obj.Get_Type() == type_novus_portal then
		_CustomScriptMessage("JoeLog.txt", string.format("Story_On_Construction_Complete: obj.Get_Type() == type_novus_portal"))
		
			
		--end
	elseif obj.Get_Type() == type_defiler_hardpoint then
		_CustomScriptMessage("JoeLog.txt", string.format("defiler hardpoint built...requesting defilers"))
		assembly_walker_defiler_hardpoint = obj
		Story_AI_Request_Build_Units(aliens, Find_Object_Type("ALIEN_DEFILER"), 1)
		
	elseif obj.Get_Type() == type_tank_hardpont then
		_CustomScriptMessage("JoeLog.txt", string.format("tank hardpoint built...requesting defilers"))
		assembly_walker_tank_hardpoint = obj
		Story_AI_Request_Build_Units(aliens, Find_Object_Type("Alien_Recon_Tank"), 1)
		
		assembly_walker_tank_hardpoint = obj
   end
end



function Thread_Assembly_Walker_Upgrade_Hardpoints(walker)
	local local_assembly_walker = walker
	
	if not TestValid(local_assembly_walker) then
		return
	end

	--requesting crown associated hard points
	--Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Assembly_HP_Face_Cap_Armor_Crown"), local_assembly_walker)
	--Sleep(5)
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Assembly_HP_Defiler_Assembly_Pod"), local_assembly_walker)
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Assembly_HP_Phase_Tank_Assembly_Pod"), local_assembly_walker)
	
	--requesting leg hardpoints
	Story_AI_Request_Build_Hard_Point(aliens, Find_Object_Type("Alien_Walker_Assembly_HP_Plasma_Cannon"), local_assembly_walker, 4)
	
end



function Callback_Defiler_Killed()
	Create_Thread("Thread_Defiler_Killed")
end

function Thread_Defiler_Killed()
	Sleep(GameRandom(10, 20))
	if TestValid(assembly_walker_defiler_hardpoint) then
		Story_AI_Request_Build_Units(aliens, Find_Object_Type("ALIEN_DEFILER"), 1)
	end
end

function Callback_ReconTank_Killed()
	Create_Thread("Thread_ReconTank_Killed")
end

function Thread_ReconTank_Killed()
	Sleep(GameRandom(10, 20))
	if TestValid(assembly_walker_tank_hardpoint) then
		Story_AI_Request_Build_Units(aliens, Find_Object_Type("ALIEN_RECON_TANK"), 1)
	end
end


--Rich's team-build stuff
function Define_BarracksWalker_Build_Stuff()
	barracks_walker = secure_team_walker
	object_type_lost_one = Find_Object_Type("Alien_Lost_One")
	object_type_grunt = Find_Object_Type("Alien_Grunt")
	object_type_brute = Find_Object_Type("Alien_Brute")
	
	
	total_lost_ones = 0
	maximum_lost_ones = 5
	total_grunts= 0
	maximum_grunts= 5
	total_brutes= 0
	maximum_brutes= 1
	

	alien_infantry_team_rally_point = Find_Hint("MARKER_GENERIC_BLUE","barracks-walker-rally-spot")

	alien_infantry_team_size = 3
	list_alien_infantry_team = {}
	
	Create_Thread("Thread_Alien_BarracksWalker_Build_Infantry")
	Create_Thread("Thread_Aliens_AttackWith_Infantry_Teams")
	
end



function Thread_Alien_BarracksWalker_Build_Infantry()

	while not bool_mission_failure and not bool_mission_success do
		Sleep(5)
		if total_lost_ones < maximum_lost_ones then
			while bool_building_lost_ones == true do
				Sleep(1)
			end
			if TestValid(barracks_walker) then
				if barracks_walker.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(barracks_walker, object_type_lost_one, 1, aliens)
					bool_building_lost_ones = true
				end
			else
				break -- structure no longer exists...kill this thread
			end
		end
		
		if total_grunts < maximum_grunts then
			while bool_building_grunts == true do
				Sleep(1)
			end
				
			if TestValid(barracks_walker) then
				if barracks_walker.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(barracks_walker, object_type_grunt, 1, aliens)
					bool_building_grunts = true
				end
			else
				break -- structure no longer exists...kill this thread
			end
		end
		
		if total_brutes < maximum_brutes then
			while bool_building_brutes == true do
				Sleep(1)
			end
				
			if TestValid(barracks_walker) then
				if barracks_walker.Get_Hull() > 0 then
					Tactical_Enabler_Begin_Production(barracks_walker, object_type_brute, 1, aliens)
					bool_building_brutes = true
				end
			else
				break -- structure no longer exists...kill this thread
			end
		end
	end
end

function Thread_Move_AlienInfantry_Staging_Units(obj)
	if TestValid(obj) then
		bool_alien_infantry_team_list_in_use = true
		table.insert(list_alien_infantry_team, obj)
		bool_alien_infantry_team_list_in_use = false
		BlockOnCommand(obj.Attack_Move(alien_infantry_team_rally_point.Get_Position()))
	end
end

function Thread_Aliens_AttackWith_Infantry_Teams()
	while not bool_mission_success and not bool_mission_failure do
	
		Sleep (30)
		
		if table.getn(list_alien_infantry_team) >= alien_infantry_team_size then
			while bool_alien_infantry_team_list_in_use do
				Sleep(0.1)
			end
			if TestListValid(list_alien_infantry_team) then
				Hunt(list_alien_infantry_team, "AntiDefault", true, false, novus_base, 150)
			end
			list_alien_infantry_team = {}
		end
	end
end


function Callback_AttackTeam_Grunt_Killed()
	total_grunts = total_grunts - 1
end

function Callback_AttackTeam_LostOne_Killed()
	total_lost_ones = total_lost_ones - 1
end

function Callback_AttackTeam_Brute_Killed()
	total_brutes = total_brutes - 1
end

function Callback_FieldInverter_Destroyed()
	counter_field_inverters = counter_field_inverters - 1
	
	if counter_field_inverters == 0 then
		Create_Thread("Thread_Reinforce_FieldInverters")
	end
end


function Thread_Reinforce_FieldInverters()
	Sleep(30)
	local object_type_transport = Find_Object_Type("NOVUS_AIR_INVASION_TRANSPORT")
	local novus_transport = Spawn_Unit(object_type_transport, transport_spawn_location, novus, false)
	if TestValid(novus_transport) then
		local blip_reinforcement = nil
		Add_Radar_Blip(novus_transport, "Default_Beacon_Placement_Persistent", "blip_reinforcement")

		novus_transport.Set_Selectable(false)
		novus_transport.Make_Invulnerable(true)
		
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT01_REINFORCEMENT_NOTICE"})--Notice: Reinforcements have arrived.
		
		BlockOnCommand(novus_transport.Move_To(reinforcement_spawn_point.Get_Position()))
		
		new_field_inverters = SpawnList(list_field_inverter_reinforcements, reinforcement_spawn_point.Get_Position(), novus, false, true, true)
		for i, field_inverter in pairs(new_field_inverters) do
			if TestValid(field_inverter) then
				field_inverter.Register_Signal_Handler(Callback_FieldInverter_Destroyed, "OBJECT_HEALTH_AT_ZERO")
				counter_field_inverters = counter_field_inverters + 1
			end
		end
		
		Sleep(5)
		Remove_Radar_Blip("blip_reinforcement")
		
		if TestValid(novus_transport) then
			BlockOnCommand(novus_transport.Move_To(transport_spawn_location.Get_Position()))
			if TestValid(novus_transport) then
				novus_transport.Make_Invulnerable(false)
				novus_transport.Despawn()
			end
		end
	end
end

function TestListValid(list)
	--local i, unit, valid
	
	local valid = false
	for i, unit in pairs(list) do
		if TestValid(unit) then
			valid = true
			break
			--i = table.getn(list)
		end
	end
	return valid
end

function Post_Load_Callback()
	UI_Hide_Research_Button()
	UI_Hide_Sell_Button()
	Movie_Commands_Post_Load_Callback()
end

