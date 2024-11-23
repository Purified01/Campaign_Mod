-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_Tut01.lua#168 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Novus_Tut01.lua $
--
--    Original Author: Chris Brooks
--
--            $Author: oksana_kubushyna $
--
--            $Change: 85397 $
--
--          $DateTime: 2007/10/03 15:32:26 $
--
--          $Revision: #168 $
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
   bool_make_col_moore_unkillable = false
	bool_skip_intro = false   
	bool_skip_outro = false
	bool_display_all_joelog = false
	
	time_objective_sleep = 5
	
	--this allows a win here to be reported back upto the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")
	
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)
	Define_State("State_Tut01_Act01", State_Tut01_Act01)
	Define_State("State_Tut01_Act02", State_Tut01_Act02)
	Define_State("State_Tut01_Act03", State_Tut01_Act03)
	Define_State("State_Tut01_Act04", State_Tut01_Act04)
	
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	uea = Find_Player("Military")
	novus = Find_Player("Novus")
	aliens = Find_Player("Alien")
	masari = Find_Player("Masari")
	
	chopper_faction = Find_Player("MilitaryTwo")
	uea.Make_Ally(chopper_faction)
	chopper_faction.Make_Ally(uea)

	PGColors_Init_Constants()
--	chopper_faction.Enable_Colorization(true, COLOR_DARK_GREEN)
--	uea.Enable_Colorization(true, COLOR_GREEN)
--	aliens.Enable_Colorization(true, COLOR_RED)
	
   player_faction = uea 
	
	pip_col_moore = "MH_Moore_pip_head.alo"
	pip_comm_officer = "Mi_comm_officer_pip_head.alo"
	pip_marine = "Mi_marine_pip_head.alo"
	pip_woolard = "Mi_Wollard_pip_head.alo"
	pip_chopper = "Mi_airforce_pip_head.alo"
	
	--any FOW handle must be nil'd at mission start for save-load
	player_reveal = nil
	alien_reveal = nil
   fow_reveal_smithsonian = nil
   fow_reveal_gallery_of_art_list = {}
	fow_reveal_detention_event = nil
	fow_reveal_schoolchildren = nil
   fow_reveal_saucer_encounter = nil
   fow_fuel_truck = nil
	fow_final_reveal = nil
	fow_checkpoint_charlie = nil
	
	--counters
	counter_obj01_greys = 0
	counter_obj01_greys_killed = 0
	counter_obj02_aliens = 0
	counter_obj02_aliens_killed = 0
	counter_obj03_aliens = 0
	counter_obj03_aliens_killed = 0
	counter_obj04_aliens = 0
	counter_obj04_aliens_killed = 0
	counter_brutes_killed = 0
	counter_act01_ambient_greys = 0
	counter_act01_ambient_greys_killed = 0
   counter_ufo_greys = 0
	counter_ufo_greys_killed = 0
   counter_reapers_killed = 0
	counter_choppers = 0
	counter_choppers_killed = 0
   
   thread_id_ufo_ambient_grey = {}
   thread_id_capitol_ambient_grey = {}
   
   bool_mission_started = false
	bool_mission_failed = false
	bool_mission_won = false
	bool_opening_dialog_finished = false
   bool_fuel_truck_dead = false
   bool_ufo_greys_falling_back = false
   bool_act01_greys_falling_back = false
	bool_objective01_greys_falling_back = false
	bool_objective_02_completed = false
	bool_brutes_attacked = false
	bool_papaya_on_board = false
   bool_harvest01_attacked = false
   bool_checkpoint_charlie_secured = false
	bool_structure_garrisoned = false
   bool_dialog_radiation_spitter_tripped = false
	bool_okay_for_choppers_to_use_rockets = false
	bool_thread_charlie_troop_killed_monitoring = false
	bool_taught_med_pack = false
	
	bool_radiation_spitter_dead = false
	
	cinematic_foofighters = {}
	cinematic_foofighters_in_use = {}
	flyover_max = 0
	
	civ_type_list = {
		"American_Civilian_Urban_01_Map_Loiterer",
		"American_Civilian_Urban_02_Map_Loiterer",
		"American_Civilian_Urban_03_Map_Loiterer",
		--"American_Civilian_Urban_04_Map_Loiterer", this is the swimming suit guy...removing from list
		"American_Civilian_Urban_05_Map_Loiterer",
		"American_Civilian_Urban_06_Map_Loiterer",
		"American_Civilian_Urban_07_Map_Loiterer",
		"American_Civilian_Urban_08_Map_Loiterer",
		"American_Civilian_Urban_09_Map_Loiterer",
		"American_Civilian_Urban_10_Map_Loiterer",
		"American_Civilian_Urban_11_Map_Loiterer",
	}
   
   script_civ_type_list = {
		"American_Civilian_Urban_01_Script",
		"American_Civilian_Urban_02_Script",
		"American_Civilian_Urban_03_Script",
		--"American_Civilian_Urban_04_Map_Loiterer", this is the swimming suit guy...removing from list
		"American_Civilian_Urban_05_Script",
		"American_Civilian_Urban_06_Script",
		"American_Civilian_Urban_07_Script",
		"American_Civilian_Urban_08_Script",
		"American_Civilian_Urban_09_Script",
		"American_Civilian_Urban_10_Script",
		"American_Civilian_Urban_11_Script",
	}
	
	schoolchildren_type_list = {
		"American_Child_Female_01",
		"American_Child_Female_02",
		"American_Child_Male_01",
		"American_Child_Male_02",
	}
	
	troop_charlie_spawn_list = {
		"MILITARY_TEAM_MARINES",
		"MILITARY_TEAM_MARINES",
		"MILITARY_TEAM_MARINES",
		"MILITARY_TEAM_FLAMETHROWER",
		"MILITARY_TEAM_FLAMETHROWER",
		"MILITARY_HUMMER",
		"MILITARY_HUMMER",
	}
	
	troop_charlie_spawn_list_post_papaya = {
		"MILITARY_TEAM_MARINES",
		"MILITARY_TEAM_MARINES",
		"MILITARY_TEAM_MARINES",
		"MILITARY_TEAM_FLAMETHROWER",
		"MILITARY_TEAM_FLAMETHROWER",
		"MILITARY_ABRAMSM2_TANK",
		"MILITARY_ABRAMSM2_TANK",
	}
	
	counter_civ_types = 0 -- determines itself later
	counter_schoolchildren_types = 0 --ditto
	civ_spawn_list = {}
	schoolchildren_list = {}

	total_spawn_flags = 0 --dynamically changes as the acts progress
	
	--stuff for the aliens who hide in the trees
	total_ambient_grey_hide_spots = 0 -- determines itself throughout the mission
	ambient_grey_hide_spot_list = {}
	act01_ambient_grey_list = {}
	act01_ambient_grey_hide_spot_list = {}
	act02_ambient_grey_list = {}
	act02_ambient_grey_hide_spot_list = {}
	
	--midtro_proxflag_list = {}

	player_list = {}
	player_list_table_size = 0
	papaya_reinforcement_list = {} --reinforcement stuff
	
   --new dialog stuff
   --just a bunch of dialog references for easy reading
	--uses Create_Thread("Thread_Dialog_Controller", conversation)
   dialog_mission_intro = 0
   dialog_first_contact = 1
   dialog_first_contact_greys_retreating = 2
   dialog_its_a_trap = 3
   dialog_player_destroys_fueltruck = 4
   dialog_first_civvie_encounter = 5
   dialog_approaching_check_point_charlie = 6
	dialog_at_check_point_charlie = 7
   dialog_check_point_charlie_secured = 8
   dialog_radiation_spitter = 9
   dialog_intro_choppers = 10
   dialog_goodbye_choppers = 11
	dialog_all_choppers_dead = 12
   dialog_intro_reapers = 13
	dialog_tanks_are_good = 14
   dialog_introduce_brutes = 15
   dialog_post_brutes = 16
	dialog_final_guard_group = 17
   dialog_approaching_the_capitol = 18
	dialog_presidential_reminder01 = 19
	dialog_garrison_reminder01 = 20
	dialog_garrison_reminder02 = 21
	dialog_garrison_reminder03 = 22
	dialog_rooftop_chatter = 23
	dialog_killing_brutes = 24
	
	list_artillery_flags = {}
	counter_list_artillery_flags = nil
	
	list_artillery_flags_act01 = {}
	list_artillery_flags_act02 = {}
	list_artillery_flags_act03 = {}

end
--OBJECTIVES
--tut01_objective01 = Add_Objective("Use Colonel Moore's Grenade ability to destroy the fuel tanker.")
--tut01_objective02a = Add_Objective("Help defend the checkpoint.")
--tut01_objective03 = Add_Objective("Secure the Capitol Building and rescue the President.")




--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through
function State_Init(message)
	if message == OnEnter then
		aliens.Allow_Autonomous_AI_Goal_Activation(false)
		
		_CustomScriptMessage("JoeLog.txt", string.format("*********************************************Story_Campaign_Novus_Tut01 START!"))
		--this following OutputDebug puts a message in the logfile that lets me determine where mission relevent info starts...mainly using to determine what assets need
		--to be pre-cached.
		OutputDebug("\n\n\n#*#*#*#*#*#*#*#*#*#*#*#*#\njdg: Story_Campaign_Novus_Tut01 START!\n#*#*#*#*#*#*#*#*#*#*#*#*#\n")
	
		Stop_All_Music()
		Disable_Automatic_Tactical_Mode_Music()
		Disable_Automatic_Strategic_Mode_Music()
		
	novus.Allow_AI_Unit_Behavior(false)
	aliens.Allow_AI_Unit_Behavior(false)
	masari.Allow_AI_Unit_Behavior(false)
		
		Play_Music("Music_Tut01_Act01")
		
		--Fade_Screen_Out(0)
		Suspend_AI(1)
		Lock_Controls(1)
		Letter_Box_In(0)

		-- ***** ACHIEVEMENT_AWARD *****
		PGAchievementAward_Init()
		-- ***** ACHIEVEMENT_AWARD *****

		-- ***** HINT SYSTEM *****
		PGHintSystemDefs_Init()
		PGHintSystem_Init()
		local scene = Get_Game_Mode_GUI_Scene()
		Register_Hint_Context_Scene(scene)			-- Set the scene which all hints will be attached to / removed from.
		Register_Hint_Callback_Script(Script)
		-- ***** HINT SYSTEM *****

      Clear_Hint_Tracking_Map() --This will reset tracked hints whenever tutorial 01 is run, so we can ensure our messages are seen again by others in a replay.
		Cache_Models()
      Define_Hints()
		--Init_Radar()
		Define_Explosion_Hints()
				
		Set_Desired_Civilian_Population(50) 
		uea.Reset_Story_Locks()
		aliens.Reset_Story_Locks()
		
		--unlocking lost ones' phase shift
		aliens.Lock_Unit_Ability("Alien_Lost_One", "Grey_Phase_Unit_Ability", false, STORY)
		-- getting rid of unsightly irradiated shots
		aliens.Lock_Generator("AlienGammaRadiatedShotsImpactEffect", true, STORY)
		aliens.Lock_Generator("AlienRadiatedShotsImpactEffect", true, STORY)
		
		--making military and civilians allies 
		civilian.Make_Ally(player_faction)

		Set_Next_State("State_Tut01_Act01")
		Create_Thread("Thread_Ambient_Explsions")
	
	elseif message == OnUpdate then
	end
end

function State_Tut01_Act01(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("Tut01 Now entering State_Tut01_Act01"))
		
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
			
      --Set_Active_Context("Tut01_Opening_AVI")
		Create_Thread("Thread_Mission_Start_Bink")
		
		list_artillery_flags = list_artillery_flags_act01
	end
end


function Thread_Mission_Start_Bink()
	if bool_display_all_joelog == true then
		_CustomScriptMessage("JoeLog.txt", string.format("START BlockOnCommand(Play_Bink_Movie(Mission_1_Intro))"))
	end
   if not bool_skip_intro then
		Fade_Screen_Out(0)
		Fade_Out_Music()
	   BlockOnCommand(Play_Bink_Movie("Mission_1_Intro",true))
   end
	if bool_display_all_joelog == true then
		_CustomScriptMessage("JoeLog.txt", string.format("END BlockOnCommand(Play_Bink_Movie(Mission_1_Intro))"))
	end
   
   --Set_Active_Context("Tut01_StoryCampaign")
   --rehide the starting_flyover -- large saucer
   if TestValid(starting_flyover) then
      starting_flyover.Hide(true)
   end

   panicked_civ_spawner_list = act01_panicked_civ_spawner_list
   total_spawn_flags = table.getn(panicked_civ_spawner_list)
   
   _CustomScriptMessage("JoeLog.txt", string.format("Entering act 01: total_spawn_flags = %d", total_spawn_flags))
   
   cinematic_foofighters = act01_foofighter_flyover_list
   flyover_max = table.getn(cinematic_foofighters)
   
   if flyover_max == 0 then
      _CustomScriptMessage("JoeLog.txt", string.format("State_Tut01_Act01 has no flyovers"))
   end
   
   Create_Thread("Thread_Cine_Mission_Start")
end

function Thread_Mission_Start_Setup_CameraMoves ()

	Point_Camera_At(starting_colmoore_goto)
	Fade_Screen_In(1)
	Start_Cinematic_Camera()
	
	Transition_Cinematic_Camera_Key(col_moore, 0, 100, 45, 0, 1, col_moore, 0, 0)
	Transition_Cinematic_Target_Key(col_moore, 0, 0, 0, 0, 0, col_moore, 0, 0)

	Transition_To_Tactical_Camera(5)
	
	Sleep(1)
	
	while bool_opening_dialog_finished == false do
		Sleep(1)
	end
	
	End_Cinematic_Camera()
	
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	
	Create_Thread("Thread_Spawn_Panicked_Civs")
	
	--***** HINT SYSTEM *****
	Add_Attached_Hint(col_moore, HINT_SYSTEM_HEROES)
	
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT01_OBJECTIVE_A"} )
	Sleep(time_objective_sleep)
	tut01_objective03 = Add_Objective("TEXT_SP_MISSION_TUT01_OBJECTIVE_A")--Secure the Capitol Building and rescue the President.
	Add_Radar_Blip(objective03_location, "DEFAULT", "blip_president")
	
	if TestValid(firstgrey) then
		firstgrey.Register_Signal_Handler(Callback_FirstGrey_Revealed, "OBJECT_REVEALED")
	end
	
	Sleep(3)
	
	for i, foofighter in pairs(opening_cine_foofighters) do
		if TestValid(foofighter) then
			Create_Thread("Thread_StartingFoo_Flyover", foofighter)
		end
	end
	
end

function Callback_FirstGrey_Revealed()
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_FirstGrey_Revealed"))
	firstgrey.Unregister_Signal_Handler(Callback_FirstGrey_Revealed)
	firstgrey.Prevent_All_Fire(false)
	Hunt(firstgrey, "Tut01_Human_Killers_Attack_Priorities", true, true, firstgrey, 20)
end


function Thread_Cine_Mission_Start()
	_CustomScriptMessage("JoeLog.txt", string.format("START Thread_Cine_Mission_Start"))
	
	if not bool_testing then
		Create_Thread("Thread_Mission_Start_Setup_CameraMoves")
	end
	
   -- ***** HINT SYSTEM *****
	--Add_Independent_Hint(HINT_SYSTEM_OBJECTIVES)
	--Add_Independent_Hint(HINT_SYSTEM_ABILITIES)
	--Add_Attached_GUI_Hint(PG_GUI_HINT_SPECIAL_ABILITY_ICON, "TEXT_ABILITY_MILITARY_MOORE_GRENADE", HINT_SYSTEM_ABILITIES)	-- JOE: To attach to a special ability, pass it's TextID.
   --xxx
	
	
	
	
	--Abilities: Most units have abilities. To use Col. Moore's Grenade ability, left-click the Grenade ability button and select a target.
	-- ***** HINT SYSTEM *****
   
   for i, gawker in pairs(gawker_list) do
		if TestValid(gawker) then
			gawker.Suspend_Locomotor(false)
         gawker.Set_Civilian_State(CIVILIAN_STATE_PANIC)
		end
	end
   
	if TestValid(col_moore) then
		col_moore.Move_To(starting_colmoore_goto)
	end

	if TestValid(player1) then
		player1.Move_To(starting_player1_goto)
	else
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Cine_Mission_Start: NOT TestValid(player1)"))
	end
	if TestValid(player2) then
		player2.Move_To(starting_player2_goto)
	end

	if TestValid(player3) then
		player3.Prevent_All_Fire(true)
		player3.Move_To(starting_player3_goto)
	end
	if TestValid(player4) then
		player4.Prevent_All_Fire(true)
		player4.Move_To(starting_player4_goto)
	end
	if TestValid(player5) then
		player5.Prevent_All_Fire(true)
		player5.Move_To(starting_player5_goto)
	end
	if TestValid(player6) then
		player6.Prevent_All_Fire(true)
		player6.Move_To(starting_player6_goto)
	end
	
	Sleep(1)
	
	Queue_Speech_Event("MIL_TUT01_SCENE02_01") -- Get back!
	Queue_Speech_Event("MIL_TUT01_SCENE02_03") -- Get those civvies out of here!
   
	if TestValid(player1) then
		player1.Move_To(starting_player1_goto)
	end
	if TestValid(player2) then
		player2.Move_To(starting_player2_goto)
	end
   
	if TestValid(col_moore) then
		col_moore.Prevent_All_Fire(false)
	end
	if TestValid(player3) then
		player3.Prevent_All_Fire(false)
	end
	if TestValid(player4) then
		player4.Prevent_All_Fire(false)
	end
	if TestValid(player5) then
		player5.Prevent_All_Fire(false)
	end
	if TestValid(player6) then
		player6.Prevent_All_Fire(false)
	end
	
	Sleep(1)
	Create_Thread("Thread_Dialog_Controller", dialog_mission_intro)
	
   _CustomScriptMessage("JoeLog.txt", string.format("END Thread_Cine_Mission_Start"))
end

function State_Tut01_Act02(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("Tut01 Now entering State_Tut01_Act02"))
		
		panicked_civ_spawner_list = act02_panicked_civ_spawner_list
		total_spawn_flags = table.getn(panicked_civ_spawner_list)
		
		_CustomScriptMessage("JoeLog.txt", string.format("Entering act 02: total_spawn_flags = %d", total_spawn_flags))
		
		cinematic_foofighters = act02_foofighter_flyover_list
		flyover_max = table.getn(cinematic_foofighters)
		
		
		
		list_artillery_flags = list_artillery_flags_act02
		
		if flyover_max == 0 then
			_CustomScriptMessage("JoeLog.txt", string.format("State_Tut01_Act02 has no flyovers"))
		end
	end
end

function State_Tut01_Act03(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("Tut01 Now entering State_Tut01_Act03"))
		
		panicked_civ_spawner_list = act03_panicked_civ_spawner_list
		total_spawn_flags = table.getn(panicked_civ_spawner_list)
		
		_CustomScriptMessage("JoeLog.txt", string.format("Entering act 03: total_spawn_flags = %d", total_spawn_flags))
		
		cinematic_foofighters = act03_foofighter_flyover_list
		flyover_max = table.getn(cinematic_foofighters)
		
		
		
		list_artillery_flags = list_artillery_flags_act03
		
		if flyover_max == 0 then
			_CustomScriptMessage("JoeLog.txt", string.format("State_Tut01_Act03 has no flyovers"))
		end
	end
end

function State_Tut01_Act04(message)
	if message == OnEnter then
		_CustomScriptMessage("JoeLog.txt", string.format("Tut01 Now entering State_Tut01_Act04"))
		
		panicked_civ_spawner_list = act04_panicked_civ_spawner_list
		total_spawn_flags = table.getn(panicked_civ_spawner_list)
		
		_CustomScriptMessage("JoeLog.txt", string.format("Entering act 04: total_spawn_flags = %d", total_spawn_flags))
		
		cinematic_foofighters = act04_foofighter_flyover_list
		flyover_max = table.getn(cinematic_foofighters)
		
		if flyover_max == 0 then
			_CustomScriptMessage("JoeLog.txt", string.format("State_Tut01_Act04 has no flyovers"))
		end
	end
end



--***************************************THREADS****************************************************************************************************
--  below are the various threads used in this script
function Thread_Mission_Start()
   --spawn in some civs for the first set of grays to "chase"
   local spawn_number_roll = 10 --spawn 10 guys
   local spawn_flag = act01_greys_civ_spawner
   
   --fill in the spawn list
   for i=1,spawn_number_roll do
      civ_spawn_list[i] = civ_type_list[GameRandom(1,counter_civ_types)]
   end
   
   for i, civ_spawn in pairs(civ_spawn_list) do
      new_civ = Spawn_Unit(Find_Object_Type(civ_spawn), spawn_flag, civilian) 
   end
   
   --send in first group of greys
   Hunt(act01_ambient_grey_list, "Tut01_Reaper_Attack_Priorities", true, true, col_moore, 25) 
	--Hunt(act01_invulnerable_ambient_grey_list, true, true, col_moore, 25) 
	
   Sleep(5)
   
   Create_Thread("Thread_StartingFoo_Flyover", opening_foo01)
	Create_Thread("Thread_StartingFoo_Flyover", opening_foo02)
   
   Sleep(1)
   Create_Thread("Thread_StartingFoo_Flyover", opening_foo03)
end

function Thread_Col_Moore_Health_Monitor()
   while TestValid(col_moore) do
      col_moore_health = col_moore.Get_Health()
      if col_moore_health < 0.5 then
			if bool_taught_med_pack == false then
				bool_taught_med_pack = true
				
				UI_Start_Flash_Ability_Button("TEXT_ABILITY_MILITARY_MOORE_MEDPACK")
				Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT01_HEALTH_WARNING_COL_MOORE"} )--Warning! Colonel Moore's health is low.

			end
         Sleep(30)
      end
      Sleep(5)
   end
end

function Thread_Spawn_Panicked_Civs()
	while (true) do
		local spawn_number_roll = GameRandom(1, 5) --spawn a max of 5 guys

      if bool_display_all_joelog == true then
         _CustomScriptMessage("JoeLog.txt", string.format("Spawn_Civilians(spawn_number_roll, panicked_civ_spawner_list, civ_type_list, CIVILIAN_STATE_PANIC, true)"))
      end
      Spawn_Civilians(spawn_number_roll, panicked_civ_spawner_list, civ_type_list, CIVILIAN_STATE_PANIC, true)
		
		Sleep(10)
	end
end

function Thread_Spawn_Civilian_Survivors(thread_info)
	local spawn_location = thread_info[1]  
	local goto_location = thread_info[2] 
	
	if not TestValid(spawn_location) then
		_CustomScriptMessage("JoeLog.txt", string.format("WARNING:Tut01: Thread_Spawn_Civilian_Survivors has received an invalid spawn_location...breaking out of thread "))
		return
	end
	
	if not TestValid(goto_location) then
		_CustomScriptMessage("JoeLog.txt", string.format("WARNING:Tut01: Thread_Spawn_Civilian_Survivors has received an invalid goto_location...breaking out of thread "))
		return
	end
	
	local spawn_number_roll = GameRandom(10, 15) --spawn between 10 - 15 civs to sell rescue event
	
	if spawn_location == objective05_schoolchildren_spawn then
		for i=1,spawn_number_roll do
			civ_spawn_list[i] = schoolchildren_type_list[GameRandom(1,counter_schoolchildren_types)]   
		end
	else
		--fill in the spawn list
		for i=1,spawn_number_roll do
			civ_spawn_list[i] = civ_type_list[GameRandom(1,counter_civ_types)]
		end
	end
	
	for i, civ_spawn in pairs(civ_spawn_list) do
		--spawning off map then teleporting to location to help sell them coming out of a building...
		--spawning directly at location makes them start in a dart-board formation...not real convincing
		new_civ = Spawn_Unit(Find_Object_Type(civ_spawn), mirabel_wait_spot, civilian) 
		new_civ.Teleport_And_Face(spawn_location)
		
		schoolchildren_list[i] = new_civ
      
      if spawn_location == objective05_schoolchildren_spawn then
			Create_Thread("Thread_SchoolChildren_RunAway", new_civ)
		elseif spawn_location == Find_Hint("MARKER_GENERIC_GREEN","gasstation-civ-spawn-location") then
			gasstation_civ_despawn = Find_Hint("MARKER_CIVILIAN_DESPAWNER","despawn")
			new_civ.Set_Civilian_To_Despawn(gasstation_civ_despawn)
      else      
		   new_civ.Move_To(goto_location)
      end
	end
	
	if spawn_location == objective05_schoolchildren_spawn then
		Sleep(1)
		Remove_Radar_Blip("blip_objective05")
		
		local school_kids_still_around = true
		while (school_kids_still_around == true) do
			school_kids_still_around = false
			for i, schoolchild in pairs(schoolchildren_list) do
				if TestValid(schoolchild) then
					_CustomScriptMessage("JoeLog.txt", string.format("TestValid(schoolchild)"))
					school_kids_still_around = true
					break
				end
			end
			Sleep(1)
		end
	elseif spawn_location ~= Find_Hint("MARKER_GENERIC_GREEN","gasstation-civ-spawn-location") then
		Sleep(1)
		Make_Civilians_Panic(goto_location.Get_Position(), 100)
	end
end

function Thread_SchoolChildren_RunAway(child)
	Sleep(GameRandom(0,1.5)) 
	if TestValid(child) then
		BlockOnCommand(child.Move_To(objective05_schoolchildren_exit_goto))
		if TestValid(child) then
			child.Despawn()
		end
	end
end

function Thread_Mission_Victorious()
	Lock_Controls(1)
	Rotate_Camera_By(180,30)
	Sleep(5)
	Force_Victory(player_faction)
	
	--relocking unit abilities
	Lock_Out_Stuff(true)
end

function Lock_Out_Stuff(local_bool)
	aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("Alien_Grunt"), "Grunt_Grenade_Attack", local_bool, STORY)
	
	--When changing the lock on death from above we must apply the inverse to leap to avoid violating some assumptions code makes.  Bah.
	aliens.Lock_Unit_Ability("Alien_Brute", "Brute_Leap_Ability", not local_bool, STORY)
	aliens.Lock_Unit_Ability("Alien_Brute", "Brute_Death_From_Above", local_bool, STORY) 
	
	aliens.Lock_Unit_Ability("Alien_Foo_Core", "Unit_Ability_Foo_Core_Heal_Attack_Toggle", local_bool, STORY) 
	aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("Alien_Foo_Core"), "Special_Ability_Foo_Core_Heal_Attack_Toggle", local_bool, STORY)
	
	
	if local_bool == true then
		UI_Set_Display_Credits_Pop(false)
	else
		UI_Set_Display_Credits_Pop(true)
	end
end


--***************************************FUNCTIONS****************************************************************************************************
-- below are the various functions used in this script
function Thread_Objective01_Aliens_Fallback()
	for i, obj01_alien_grey in pairs(obj01_alien_greys_list) do
		if TestValid(obj01_alien_grey) then
			if TestValid(reaper01) then -- dont fear the reaper...go guard it
				obj01_alien_grey.Guard_Target(reaper01.Get_Position())
			elseif TestValid(reaper03) then
				obj01_alien_grey.Guard_Target(reaper03.Get_Position())
			elseif TestValid(reaper02) then
				obj01_alien_grey.Guard_Target(reaper02.Get_Position())
			end
		end
	end
	
	Sleep(3)
	
	fow_reveal_smithsonian.Undo_Reveal()
	Remove_Radar_Blip("blip_objective01")
	
	local thread_info = {}
	thread_info[1]  = objective01_survivors_spawn
	thread_info[2]  = objective01_survivors_exit_goto
	Create_Thread("Thread_Spawn_Civilian_Survivors", thread_info)
	
	Set_Next_State("State_Tut01_Act02")
	
	--send in the grunts
	for i, act02_grunt in pairs(act02_grunts_list) do
		if TestValid(act02_grunt) then
			act02_grunt.Suspend_Locomotor(false)
			if bool_display_all_joelog == true then
				_CustomScriptMessage("JoeLog.txt", string.format("Hunt(act02_grunts_list, Tut01_Harvester_Attacking, true, true, col_moore, 25)"))
			end
		end
	end
   
   Hunt(act02_grunts_list, "Tut01_Grunt_Attack_Priorities", true, true, col_moore, 25)
end

function Thread_Grunts_Brutalize_Civs()

	for i, obj01_alien_guards02 in pairs(obj01_alien_guards02_list) do
		if TestValid(obj01_alien_guards02) then
			--bool_alien_guards02_still_alive = true xxx
			obj01_alien_guards02.Set_Service_Only_When_Rendered(false)
		end
	end

   Hunt(obj01_alien_guards02_list, "Tut01_Human_Killers_Attack_Priorities", false, true, obj01_alien_guards02_list[1], 10)
	
	local bool_alien_guards02_still_alive = true
	while bool_alien_guards02_still_alive == true do
		bool_alien_guards02_still_alive = false
		for i, obj01_alien_guards02 in pairs(obj01_alien_guards02_list) do
			if TestValid(obj01_alien_guards02) then
				bool_alien_guards02_still_alive = true
			end
		end
	
		
		Sleep(1)
	end
	
	Create_Thread("Thread_Objective01_Aliens_Fallback")
end

function Thread_Objective01_Captive_Humans_Flee(fleer)
	Sleep(GameRandom(0,2))
	if TestValid(fleer) then
		if TestValid(obj01_fleer_despawn_flag) then
			BlockOnCommand(fleer.Move_To(obj01_fleer_despawn_flag))
		else
			MessageBox("ERROR!! not TestValid(obj01_fleer_despawn_flag) ")
		end
		
	end
	
	if TestValid(fleer) then
		fleer.Despawn()
	end
end

function Callback_Col_Moore_Killed()
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_Col_Moore_Killed"))
	
	
	if not bool_mission_won then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() -- removes any queded dialog
		failure_text = "TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_MOORE_COLONEL"
		bool_mission_failed = true
		Create_Thread("Thread_Mission_Failed")
	end
end

function Callback_Sgt_Woolard_Killed()
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_Sgt_Woolard_Killed"))
	

	if not bool_mission_won then
		Stop_All_Speech() -- stopping any other mission dialog that might be going on.
		Flush_PIP_Queue() 
		failure_text = "TEXT_SP_MISSION_MISSION_FAILED_HERO_DEAD_WOOLARD"
		bool_mission_failed = true
		Create_Thread("Thread_Mission_Failed")
	end
end

function Thread_Mission_Failed()

		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
			
	bool_mission_failed = true --this flag is what I check to make sure no game logic continues when the mission is over
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
-- this music is faction specific, 
-- use: UEA_Lose_Tactical_Event Alien_Lose_Tactical_Event Novus_Lose_Tactical_Event Masari_Lose_Tactical_Event
	--Play_Music("Military_Lose_Tactical_Event")     
	Play_Music("Lose_To_Alien_Event")  
	
	
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,30)
	-- the variable  failure_text  is set at the start of mission to contain the default string "TEXT_SP_MISSION_MISSION_FAILED"
	-- upon mission failure of an objective, or hero death, replace the string  failure_text  with the appropriate xls tag 
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {failure_text} )
	Sleep(5)
	--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(0)
	Force_Victory(aliens)
end

function Thread_Sgt_Woolard_Health_Monitor()
	while TestValid(sgt_woolard) do
      sgt_woolard_health = sgt_woolard.Get_Health()
      if sgt_woolard_health < 0.4 then
         Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT01_HEALTH_WARNING_SGT_WOOLARD"} )--Warning! Sergeant Woolard's health is low.
         Sleep(30)
      end
      Sleep(5)
   end
end

function Callback_Radiation_Spitter_Killed()
	bool_radiation_spitter_dead = true -- this bool gets used to determine when the checkpoint charlie guys can start "guarding" col moore.
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_Radiation_Spitter_Killed HIT!"))
   --send in choppers
   Create_Thread("Thread_Gallery_Choppers")
   
	--give the grunts access to grenades
	aliens.Set_Special_Ability_Type_Lock(Find_Object_Type("Alien_Grunt"), "Grunt_Grenade_Attack", false, STORY)
end

function Thread_Spawn_Turret_Fodder()
   while TestValid(radiation_spitter) do
      spawned_civs = {}
      spawned_civs = Spawn_Civilians(5, radiation_spitter_civ_spawner, civ_type_list, CIVILIAN_STATE_PANIC, true)

      for i, civ in pairs(spawned_civs) do
         if TestValid(civ) then
            civ.Set_Civilian_To_Despawn(charlie_respawn_location)
         end
      end
      
      Sleep(8)
   end
end

function Callback_Charlie_Fodder_Killed(dead_unit)
	counter_charlie_fodder_killed = counter_charlie_fodder_killed + 1
	
	if counter_charlie_fodder_killed == 5 then -- start objective complete safety monitoring, this is due some some weird bug that sometimes wont clear this objective
		Create_Thread("Thread_Monitor_Charlie_Fodder_List")
	end
	
	if counter_charlie_fodder_killed >= counter_charlie_fodder and not bool_checkpoint_charlie_secured then
		_CustomScriptMessage("JoeLog.txt", string.format("check point charlie getting cleared via Callback_Charlie_Fodder_Killed"))
		bool_checkpoint_charlie_secured = true
		Create_Thread("Thread_Dialog_Controller", dialog_check_point_charlie_secured)
	end
end

function Thread_Monitor_Charlie_Fodder_List()
	while (bool_checkpoint_charlie_secured == false) do
		local local_counter_charlie_fodder = 0
		for i, charlie_fodder in pairs(charlie_fodder_list) do
			if TestValid(charlie_fodder) then
				local_counter_charlie_fodder = local_counter_charlie_fodder + 1
			end
		end
		
		 _CustomScriptMessage("JoeLog.txt", string.format("Thread_Monitor_Charlie_Fodder_List: local_counter_charlie_fodder = %d", local_counter_charlie_fodder))
		if local_counter_charlie_fodder == 0 and bool_checkpoint_charlie_secured == false then
			Sleep(1)
	
			local_counter_charlie_fodder = 0
			for i, charlie_fodder in pairs(charlie_fodder_list) do -- second check
				if TestValid(charlie_fodder) then
					local_counter_charlie_fodder = local_counter_charlie_fodder + 1
				end
			end
			
			if local_counter_charlie_fodder == 0 and bool_checkpoint_charlie_secured == false then -- second check has passed, clear the objective
				_CustomScriptMessage("JoeLog.txt", string.format("check point charlie getting cleared via Thread_Monitor_Charlie_Fodder_List"))
				bool_checkpoint_charlie_secured = true
				Create_Thread("Thread_Dialog_Controller", dialog_check_point_charlie_secured)
			end
		end
		
		Sleep(1)
	end
end

function Thread_Col_Moore_Killed()
   Sleep(2.5)
	Force_Victory(aliens)
end

function Thread_Sgt_Woolard_Killed()
   Sleep(2.5)
	Force_Victory(aliens)
end

function Thread_Objective02_Grunts_Emerge()
	--spawn some civs for the grunts to chase out of the building
	civ_spawn_list = {}
	for i=1,3 do
		civ_spawn_list[i] = civ_type_list[GameRandom(1,counter_civ_types)]
	end
	
	for i, civ_spawn in pairs(civ_spawn_list) do
		new_civ = Spawn_Unit(Find_Object_Type(civ_spawn), mirabel_wait_spot, civilian) 
		new_civ.Teleport_And_Face(objective02_survivors_spawn)
		new_civ.Move_To(objective02_survivors_exit_goto.Get_Position())
	end
end

function Callback_Obj02_Alien_Killed()
	counter_obj02_aliens_killed = counter_obj02_aliens_killed + 1
	if bool_display_all_joelog == true then
		_CustomScriptMessage("JoeLog.txt", string.format("current objective 02 dead-deflier count is %d", counter_obj02_aliens_killed))
	end
	
	if counter_obj02_aliens_killed == 2 then -- bring out the grunts
		Create_Thread("Thread_Objective02_Grunts_Emerge")
	end

	if bool_objective_02_completed == false and counter_obj02_aliens_killed >= counter_obj02_aliens then
		bool_objective_02_completed = true
		if bool_display_all_joelog == true then
			_CustomScriptMessage("JoeLog.txt", string.format("All objective 02 aliens killed"))
		end

		local thread_info = {}
		thread_info[1]  = objective02_survivors_spawn
		thread_info[2]  = objective02_survivors_exit_goto
		Create_Thread("Thread_Spawn_Civilian_Survivors", thread_info)
		
		Set_Next_State("State_Tut01_Act03")
	end
end


function Callback_Passguard_Attacked()
   --unregister the passguards
   for i, passguard in pairs(passguard_list) do
		if TestValid(passguard) then
         passguard.Unregister_Signal_Handler(Callback_Passguard_Attacked)
		end
	end
   
   Hunt(passguard_list, "Tut01_Reaper_Attack_Priorities", true, true, passguard_guard_spot, 100)
   
   --send in the ambient guys
   for i, passguard_ambient_grey in pairs(passguard_ambient_grey_list) do
		if TestValid(passguard_ambient_grey) then
         Create_Thread("Thread_Ambient_Greys_Orders", passguard_ambient_grey)
		end
	end
end

function Callback_Capitolguard_Attacked()
   --unregister the passguards
   for i, capitolguard in pairs(capitolguard_list) do
		if TestValid(capitolguard) then
         capitolguard.Unregister_Signal_Handler(Callback_Capitolguard_Attacked)
		end
	end
	
	Create_Thread("Thread_Dialog_Controller", dialog_final_guard_group)
   
   Hunt(capitolguard_list, "Tut01_Reaper_Attack_Priorities", true, true, capitolguard_guard_spot, 200) 
   
   --start ufo routine here 
   Start_Saucer_Encounter()
   
   --send in the ambient guys
   for i, capitolguard_ambient_grey in pairs(capitolguard_ambient_grey_list) do
		if TestValid(capitolguard_ambient_grey) then
         thread_id_capitol_ambient_grey[i] = Create_Thread("Thread_Ambient_Greys_Orders", capitolguard_ambient_grey)
		end
	end
end

function Callback_Capitolguard_Killed()
   counter_capitolguard = counter_capitolguard - 1
	counter_capitolguard_killed = counter_capitolguard_killed + 1
	
   if counter_capitolguard <= 0 then
      --remaining capitol grey guys scatter
      for i=1,table.getn(thread_id_capitol_ambient_grey) do
			if (thread_id_capitol_ambient_grey[i]) then
				Thread.Kill(thread_id_capitol_ambient_grey[i])
			end
		end

      for i, capitolguard_ambient_grey in pairs(capitolguard_ambient_grey_list) do
         if TestValid(capitolguard_ambient_grey) then
            Create_Thread("Thread_CapitolAmbient_Greys_ScatterOrders", capitolguard_ambient_grey)
         end
      end
		
		if TestValid(capitolguard02_list[1]) then
			fow_final_reveal = FogOfWar.Reveal(player_faction, capitolguard02_list[1].Get_Position(), 100, 100)
			capitolguard02_list[1].Highlight(true, -50)
		end
   end
end

function Callback_Capitolguard02_Attacked()
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_Capitolguard02_Attacked HIT...play associated dialog"))
	Create_Thread("Thread_Dialog_Controller", dialog_approaching_the_capitol)
	
	for i, capitolguard02 in pairs(capitolguard02_list) do
		if TestValid(capitolguard02) then
			--changing to death event
			capitolguard02.Unregister_Signal_Handler(Callback_Capitolguard02_Attacked)
		end
	end
end

function Callback_Capitolguard02_Killed()
	counter_capitolguard02_killed = counter_capitolguard02_killed + 1
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_Capitolguard02_Killed HIT, counter_capitolguard02_killed = %d", counter_capitolguard02_killed))
	
	if counter_capitolguard02_killed == counter_capitolguard02 then --everyones dead...roll ending cine.
		 _CustomScriptMessage("JoeLog.txt", string.format("Callback_Capitolguard02_Killed everyones dead..roll ending cine"))
		Create_Thread("Thread_Capitolguard02_Attacked") 
	end
end

function Thread_Capitolguard02_Attacked()
	if not bool_mission_failed then
		bool_mission_won = true
	else
		return
	end
	--make col moore invulnerable to prevent bugs during/after the cine...
	if TestValid(col_moore) then
		col_moore.Make_Invulnerable(true)
		col_moore.Set_Cannot_Be_Killed(true)	
	end

	if TestValid(sgt_woolard) then
		sgt_woolard.Make_Invulnerable(true)
		sgt_woolard.Set_Cannot_Be_Killed(true)	
	end

	Sleep(3)
	
	 --roll the ending cine
	if not bool_mission_failed then
		Create_Thread("Thread_Mission_Complete")
	end
end


function Thread_CapitolAmbient_Greys_ScatterOrders(grey)
   total_capitolguard_ambient_grey_scatter_spot_list = table.getn(capitolguard_ambient_grey_scatter_spot_list)

   random_slot = GameRandom(1, total_capitolguard_ambient_grey_scatter_spot_list) 
   random_loc = capitolguard_ambient_grey_scatter_spot_list[random_slot]
   if TestValid(grey) then
      BlockOnCommand(grey.Move_To(random_loc.Get_Position()))
   end
end

function Thread_Schoolchildren_Brute_Attacked()		
	--When changing the lock on death from above we must apply the inverse to leap to avoid violating some assumptions code makes.  Bah.
	aliens.Lock_Unit_Ability("Alien_Brute", "Brute_Leap_Ability", true, STORY)
	aliens.Lock_Unit_Ability("Alien_Brute", "Brute_Death_From_Above", false, STORY)
	aliens.Lock_Unit_Ability("Alien_Brute", "Alien_Brute_Tackle_Ability", false, STORY)
	
	-- adding helpers to make the brutes a little easier to kill
	--if TestValid(schoolchildren_brute01) then 
	--	schoolchildren_brute01.Add_Attribute_Modifier( "Universal_Damage_Modifier", .75)
	--	schoolchildren_brute01.Override_Max_Speed(.7)
	--end
	if TestValid(schoolchildren_brute_roof) then 
		schoolchildren_brute_roof.Add_Attribute_Modifier( "Universal_Damage_Modifier", .75)
		schoolchildren_brute_roof.Override_Max_Speed(.7)
	end
	if TestValid(schoolchildren_brute_roof02) then 
		schoolchildren_brute_roof02.Add_Attribute_Modifier( "Universal_Damage_Modifier", .75)
		schoolchildren_brute_roof02.Override_Max_Speed(.7)
	end
	   
   --if TestValid(schoolchildren_brute01) then
   --   schoolchildren_brute01.Suspend_Locomotor(false)
		
	--	MessageBox("schoolchildren_brute01_goto")
	--	schoolchildren_brute01.Move_To(schoolchildren_brute01_goto)
		
   --else
     -- _CustomScriptMessage("JoeLog.txt", string.format("ERROR! Thread_Schoolchildren_Brute_Attacked NOT TestValid(schoolchildren_brute01)"))
	--end
   
   if TestValid(schoolchildren_brute_roof) then
		schoolchildren_brute_roof.Suspend_Locomotor(false)
      schoolchildren_brute_roof.Activate_Ability("Brute_Death_From_Above", true, roof_brute_dfa_target)
	end
	
	Sleep(1)

	if TestValid(schoolchildren_brute_roof02) then
      schoolchildren_brute_roof02.Suspend_Locomotor(false)
      schoolchildren_brute_roof02.Activate_Ability("Brute_Death_From_Above", true, roof_brute_dfa_target02)
	end
	
	Sleep(2)
	
	--These Hunt commands were referencing the invalid object 'proxflag_brute_encounter'.  I've changed them
	--to just hunt in a radius around the brute positions so that the Hunt doesn't fail.
	--if TestValid(schoolchildren_brute01) then
	--	Hunt(schoolchildren_brute01, "Tut01_Reaper_Attack_Priorities", false, true, schoolchildren_brute01, 150) 
	--end
	
	if TestValid(schoolchildren_brute_roof) then
		Hunt(schoolchildren_brute_roof, "Tut01_Reaper_Attack_Priorities", false, true, schoolchildren_brute_roof, 150)
	end
	
   if TestValid(schoolchildren_brute_roof02) then
		Hunt(schoolchildren_brute_roof02, "Tut01_Reaper_Attack_Priorities", false, true, schoolchildren_brute_roof02, 150)
	end
end

function Callback_Schoolchildren_Brute_Killed()
	counter_brutes_killed = counter_brutes_killed + 1
   _CustomScriptMessage("JoeLog.txt", string.format("Callback_Schoolchildren_Brute_Killed HIT! counter_brutes_killed = %d", counter_brutes_killed))
	if counter_brutes_killed == 1 then
		Create_Thread("Thread_Dialog_Controller", dialog_killing_brutes)
	end
	
	if counter_brutes_killed == 2 then
		_CustomScriptMessage("JoeLog.txt", string.format("All school_brutes killed"))
			
		local thread_info = {}
		thread_info[1]  = objective05_schoolchildren_spawn
		thread_info[2]  = objective05_schoolchildren_exit_goto
		Create_Thread("Thread_Spawn_Civilian_Survivors", thread_info)
      
      Create_Thread("Thread_Dialog_Controller", dialog_post_brutes)
		
	end
end

function Callback_Act01_AmbientGrey_Damaged()
	counter_act01_ambient_greys_killed = counter_act01_ambient_greys_killed + 1
	if bool_display_all_joelog == true then
		_CustomScriptMessage("JoeLog.txt", string.format("Callback_Act01_AmbientGrey_Damaged: current counter_act01_ambient_greys_killed is %d", counter_act01_ambient_greys_killed))
	end
	
	if counter_act01_ambient_greys_killed == 1 then
		--fall back and guard the smithsonian...leading player this way
		bool_act01_greys_falling_back = true -- breaks them out of their tweak loop
		
		Create_Thread("Thread_Act01_AmbientGrey_Fallback_Orders", act01_ambient_grey_list)
      Create_Thread("Thread_Dialog_Controller", dialog_first_contact_greys_retreating)
		
		--now that this is a damaged event, need to unregister objects
		for i, act01_ambient_grey in pairs(act01_ambient_grey_list) do
			if TestValid(act01_ambient_grey) then
				act01_ambient_grey.Unregister_Signal_Handler(Callback_Act01_AmbientGrey_Damaged)
			end
		end
	end

end

function Callback_FirstTanker_Killed(obj, killer)
	Create_Thread("Thread_FirstTanker_Killed")
	
   bool_fuel_truck_dead = true
	_CustomScriptMessage("JoeLog.txt", string.format("bool_fuel_truck_dead = true"))
	
	if killer.Get_Owner() == player_faction then
		Create_Thread("Thread_Dialog_Controller", dialog_player_destroys_fueltruck)
   end
	
	first_tanker_tree_list = Find_All_Objects_With_Hint("first-tanker-tree")	
	
	for i, first_tanker_tree in pairs(first_tanker_tree_list) do
		if TestValid(first_tanker_tree) then
			--ufo_grey.Take_Damage(150, "Damage_Fire")
			first_tanker_tree.Enable_Behavior(BEHAVIOR_BURNING, true)
		end
	end
	
	--burn off the aliens
	for i, ufo_grey in pairs(ufo_grey_list) do
		if TestValid(ufo_grey) then
			ufo_grey.Take_Damage(150, "Damage_Fire")
		end
	end
	
end

function Thread_FirstTanker_Killed(thread_info)

	while tut01_objective01 == nil do
		Sleep(1)
	end
	
	if tut01_objective01~= nil then
		tanker_flag.Highlight(false)
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT01_OBJECTIVE_B_COMPLETE"} )--Complete: Use Colonel Moore's Grenade ability to destroy the fuel tanker.
		Objective_Complete(tut01_objective01)
	end
	
	if fow_fuel_truck ~= nil then
		fow_fuel_truck.Undo_Reveal()
	end
	
end

function Callback_SecondTanker_Killed()
	Burn_The_Trees(second_tanker_flag, 100)
	
	--do a distance check on charlie fodder
	for i, charlie_fodder in pairs(charlie_fodder_list) do
		if TestValid(charlie_fodder) then
			
			local distance = charlie_fodder.Get_Distance(second_tanker_flag)
				
			if distance < 100 then
				charlie_fodder.Take_Damage(300, "Damage_Fire")
			end
		end
	end
end

function Burn_The_Trees(location, radius)
   Burn_All_Objects(location, radius, Tree_Oak_01_No_Obstacle) --check
end

function Callback_UFO_Grey_Killed()
	counter_ufo_greys_killed = counter_ufo_greys_killed + 1
	if bool_display_all_joelog == true then
		_CustomScriptMessage("JoeLog.txt", string.format("Callback_UFO_Grey_Killed: current counter_ufo_greys_killed is %d", counter_ufo_greys_killed))
	end
   
   if bool_fuel_truck_dead ~= true and bool_ufo_greys_falling_back ~= true then
      --respawn the killed guy
      new_ufo_grey = Spawn_Unit(Find_Object_Type("ALIEN_SCIENCE_GREY_INDIVIDUAL"), ufo_alien_respawnflag, aliens) 
      new_ufo_grey.Set_Hint("ufo-grey")
      thread_id_ufo_ambient_grey[table.getn(thread_id_ufo_ambient_grey) + 1] = Create_Thread("Thread_Ambient_Greys_Orders", new_ufo_grey)
   
      ufo_grey_list[table.getn(ufo_grey_list) + 1] = new_ufo_grey
   end
	
	if (bool_fuel_truck_dead == true and bool_ufo_greys_falling_back == false) or (counter_ufo_greys_killed > 15 and bool_ufo_greys_falling_back == false) then--(counter_ufo_greys -  counter_ufo_greys_killed) == 10 then
		--fall back and guard the smithsonian...leading player this way
		bool_ufo_greys_falling_back = true -- breaks them out of their tweak loop
      
      local l = 1
      for l=1,table.getn(thread_id_ufo_ambient_grey) do
         Thread.Kill(thread_id_ufo_ambient_grey[l])
      end
      
      for i, ufo_grey in pairs(ufo_grey_list) do
         if TestValid(ufo_grey) then
            Create_Thread("Thread_UFO_Grey_Fallback_Orders", ufo_grey)
         end
      end
	end
end





function Thread_UFO_Grey_Fallback_Orders(alien_unit)	

	Sleep(GameRandom(1,3))
   
	if TestValid(alien_unit) then
		alien_unit.Activate_Ability("Grey_Phase_Unit_Ability", true)
		BlockOnCommand(alien_unit.Move_To(objective01_survivors_exit_goto.Get_Position()))
	end
   
   if TestValid(alien_unit) then
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_UFO_Grey_Fallback_Orders: alien_unit.Despawn()"))
      alien_unit.Despawn() --too many of you...please go away
   end
end

function Thread_Act01_AmbientGrey_Fallback_Orders(alien_unit_list)	
	for i, alien_unit in pairs(alien_unit_list) do
		if TestValid(alien_unit) then
			alien_unit.Override_Max_Speed(1.5)
			alien_unit.Activate_Ability("Grey_Phase_Unit_Ability", true)
			
			
			alien_unit.Set_Cannot_Be_Killed(false)
		end
	end
	
	Formation_Move(alien_unit_list, act01_greys_fallback_pos.Get_Position())

	for i, alien_unit in pairs(alien_unit_list) do
		if TestValid(alien_unit) then
			alien_unit.Despawn()--too many of you...go away please
		end
	end
end

function Thread_StartingFoo_Flyover(foofighter)
	if TestValid(foofighter) then
		foofighter.Hide(false)
		if bool_display_all_joelog == true then
			_CustomScriptMessage("JoeLog.txt", string.format("Thread_StartingFoo_Flyover making its entrance"))
		end

		BlockOnCommand(foofighter.Play_Animation("Anim_Cinematic", false, 0))
		if bool_display_all_joelog == true then
			_CustomScriptMessage("JoeLog.txt", string.format("Thread_StartingFoo_Flyover despawning"))
		end
		foofighter.Despawn()
	end
end

function Thread_LargeSaucer_Flyover(largesaucer_flyover)
	--Sleep(5)
	if TestValid(largesaucer_flyover) then
		largesaucer_flyover.Hide(false)
		if bool_display_all_joelog == true then
			_CustomScriptMessage("JoeLog.txt", string.format("starting_flyover making its entrance"))
		end
		
		BlockOnCommand(largesaucer_flyover.Play_Animation("Anim_Cinematic", false, 1))
		
		if bool_display_all_joelog == true then
			_CustomScriptMessage("JoeLog.txt", string.format("starting_flyover despawning"))
		end
		largesaucer_flyover.Despawn()
	end
end

--this detects when player uits are close by and starts the "tweaked-out" greys into their cycle
function PROX_UEA_InRange_of_Greys(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == player_faction then
		prox_obj.Cancel_Event_Object_In_Range(PROX_UEA_InRange_of_Greys)
		prox_obj.Suspend_Locomotor(false)
		Create_Thread("Thread_Ambient_Greys_Orders", prox_obj)
	end
end


function PROX_Reveal_Saucer(prox_obj, trigger_obj)
   if trigger_obj.Get_Owner() == player_faction then
		
		for i, saucer_prox in pairs(saucer_prox_list) do
			if TestValid(saucer_prox) then
				saucer_prox.Cancel_Event_Object_In_Range(PROX_Reveal_Saucer)
			end
		end
	
      fow_reveal_saucer_encounter  = FogOfWar.Reveal(player_faction, saucer01.Get_Position(), 250, 250)
	
		local thread_info = {} 
      thread_info[1] = saucer01
      thread_info[2] = saucer01_grey_list
      thread_info[3] = saucer01_entry
      Create_Thread("Thread_Saucer_Leaves", thread_info)
   end
end

function Thread_Gallery_Choppers()

   _CustomScriptMessage("JoeLog.txt", string.format("Thread_Gallery_Choppers HIT!"))
   
	if TestValid(gallery_chopper01) then
		gallery_chopper01.Set_Object_Context_ID("Tut01_StoryCampaign")
		gallery_chopper01.Set_Selectable(false)
		gallery_chopper01.Change_Owner(chopper_faction)
		gallery_chopper01.Add_Reveal_For_Player(player_faction)
		gallery_chopper01.Override_Max_Speed(4)

      Hunt(gallery_chopper01, "Tut01_Chopper_Attack_Priorities", true, true, gallery_chopper01_goto, 100)
		
		--Create_Thread("Thread_Choppers_Shoot_Rockets", gallery_chopper01)
		counter_choppers = counter_choppers + 1
		
		gallery_chopper01.Register_Signal_Handler(Callback_Chopper_Killed, "OBJECT_HEALTH_AT_ZERO")

	end
	if TestValid(gallery_chopper02) then
		gallery_chopper02.Set_Object_Context_ID("Tut01_StoryCampaign")
		gallery_chopper02.Set_Selectable(false)
		gallery_chopper02.Change_Owner(chopper_faction)
		gallery_chopper02.Add_Reveal_For_Player(player_faction)
		gallery_chopper02.Override_Max_Speed(4)
		
      Hunt(gallery_chopper02, "Tut01_Chopper_Attack_Priorities", true, true, gallery_chopper02_goto, 100)
		--Create_Thread("Thread_Choppers_Shoot_Rockets", chopper_faction)
		counter_choppers = counter_choppers + 1
		
		gallery_chopper02.Register_Signal_Handler(Callback_Chopper_Killed, "OBJECT_HEALTH_AT_ZERO")
	end
	if TestValid(gallery_chopper03) then
		gallery_chopper03.Set_Object_Context_ID("Tut01_StoryCampaign")
		gallery_chopper03.Set_Selectable(false)
		gallery_chopper03.Change_Owner(chopper_faction)
		gallery_chopper03.Add_Reveal_For_Player(player_faction)
		gallery_chopper03.Override_Max_Speed(4)
		
      Hunt(gallery_chopper03, "Tut01_Chopper_Attack_Priorities", true, true, gallery_chopper03_goto, 100)
		--Create_Thread("Thread_Choppers_Shoot_Rockets", chopper_faction)
		counter_choppers = counter_choppers + 1
		
		gallery_chopper03.Register_Signal_Handler(Callback_Chopper_Killed, "OBJECT_HEALTH_AT_ZERO")
	end
	
   
	Sleep(5)
	Create_Thread("Thread_Dialog_Controller", dialog_intro_choppers)
	Sleep(5)
	
	
	
	
	Create_Thread("Thread_Dialog_Controller", dialog_goodbye_choppers)
end

function Callback_Chopper_Killed()
	counter_choppers_killed = counter_choppers_killed + 1
	
	if counter_choppers_killed == 1 then
		Create_Thread("Thread_Dialog_Controller", dialog_first_chopper_dead)
	end
	
	if counter_choppers_killed == counter_choppers then
		--all choppers killed...play goodbye dialog
		if not bool_harvest01_attacked then
			Create_Thread("Thread_Dialog_Controller", dialog_all_choppers_dead)
		end
	end
end


--BUG: Crashing now that choppers aren't on player faction
function Thread_Choppers_Shoot_Rockets(unit)
	local local_chopper = unit
	
	while TestValid(local_chopper) do
		if bool_okay_for_choppers_to_use_rockets == true then
		
			local target = nil
		
			--find a target
			--choppers Targeting_Max_Attack_Distance = 210.0
			alien_grunt_list = Find_All_Objects_Of_Type("ALIEN_GRUNT")
			for i, alien_grunt in pairs(alien_grunt_list) do
				if not TestValid(alien_grunt) then
					_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!  Thread_Choppers_Shoot_Rockets not TestValid(alien_grunt)"))
					break
				end
				
				if not TestValid(local_chopper) then
					_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!!  Thread_Choppers_Shoot_Rockets not TestValid(local_chopper)"))
					break
				end
				
				if TestValid(local_chopper) and TestValid(alien_grunt) then
					local distance = local_chopper.Get_Distance(alien_grunt)
					
					if distance >= 50 and distance <210 then
						target = alien_grunt
						break
					end
				end
				
				
			end
			
			if TestValid(local_chopper) and TestValid(target) then
				Use_Ability_If_Able(local_chopper, "Unit_Ability_Apache_Rocket_Barrage", target.Get_Position())
			end
		end
		
		Sleep(5)
	end
end

function Thread_Gallery_FooFighter_Orders()

	 _CustomScriptMessage("JoeLog.txt", string.format("Thread_Gallery_FooFighter_Orders HIT!"))
	 
	aliens.Make_Enemy(chopper_faction) --should start the hositlities here
	chopper_faction.Make_Enemy(aliens)
	alien_reveal = FogOfWar.Reveal_All(aliens) 
   
	for i, gallery_foo in pairs(gallery_foo_list) do
		if TestValid(gallery_foo) then
			gallery_foo.Override_Max_Speed(7)
			gallery_foo.Set_Object_Context_ID("Tut01_StoryCampaign")
			gallery_foo.Set_Service_Only_When_Rendered(false)
			gallery_foo.Prevent_AI_Usage(true)
			gallery_foo.Set_Targeting_Priorities("Tut01_Foo_Attack_Priorities")
			
			_CustomScriptMessage("JoeLog.txt", string.format("gallery_foo.Set_Object_Context_ID(Tut01_StoryCampaign)"))
		end
	end
	
	--foo_fighter_list = Find_All_Objects_Of_Type("ALIEN_FOO_FIGHTER") 
	for i, foo_fighter in pairs(foo_fighter_list) do
		if TestValid(foo_fighter) then
			foo_fighter.Set_Object_Context_ID("Tut01_StoryCampaign")
			foo_fighter.Set_Service_Only_When_Rendered(false)
			--foo_fighter.Set_Targeting_Priorities("Tut01_Foo_Attack_Priorities")
			foo_fighter.Prevent_AI_Usage(true)
			
			_CustomScriptMessage("JoeLog.txt", string.format("foo_fighter.Set_Service_Only_When_Rendered(false)"))
		end
	end
   
	while TestValid(gallery_chopper03) do
		for i, gallery_foo in pairs(gallery_foo_list) do
			if TestValid(gallery_foo) then
				gallery_foo.Attack_Target(gallery_chopper03)
				_CustomScriptMessage("JoeLog.txt", string.format("gallery_foo.Attack_Target(gallery_chopper03)"))
			end
		end
		Sleep(1)
	end
	
	while TestValid(gallery_chopper02) do
		for i, gallery_foo in pairs(gallery_foo_list) do
			if TestValid(gallery_foo) then
				gallery_foo.Attack_Target(gallery_chopper02)
				_CustomScriptMessage("JoeLog.txt", string.format("gallery_foo.Attack_Target(gallery_chopper02)"))
			end
		end
		Sleep(1)
	end
	
	while TestValid(gallery_chopper01) do
		for i, gallery_foo in pairs(gallery_foo_list) do
			if TestValid(gallery_foo) then
				gallery_foo.Attack_Target(gallery_chopper01)
				_CustomScriptMessage("JoeLog.txt", string.format("gallery_foo.Attack_Target(gallery_chopper01)"))
			end
		end
		Sleep(1)
	end
   
	BlockOnCommand(Formation_Move(gallery_foo_list, obj01_fleer_despawn_flag))
	for i, gallery_foo in pairs(gallery_foo_list) do
		if TestValid(gallery_foo) then
			gallery_foo.Despawn()
		end
	end
	
end

function PROX_Start_Mission(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == player_faction then
      _CustomScriptMessage("JoeLog.txt", string.format("#!#!#!#!#!#!#! ----> PROX_Start_Mission HIT!"))
      bool_mission_started = true
		
		for i, prox_flag in pairs(mission_start_prox_flag_list) do
			prox_flag.Cancel_Event_Object_In_Range(PROX_Start_Mission)
		end
		
		Create_Thread("Thread_Mission_Start")
	end
end

function Callback_GasStation_PointGuard_Killed()
	counter_gas_station_point_guards_killed = counter_gas_station_point_guards_killed + 1
	if counter_gas_station_point_guards_killed == counter_gas_station_point_guards then
		--everyone is dead...spawn some civies from the gas station
		local thread_info = {}
		thread_info[1] = Find_Hint("MARKER_GENERIC_GREEN","gasstation-civ-spawn-location")
		thread_info[2] = Find_Hint("MARKER_GENERIC_GREEN","gasstation-civ-spawn-goto")
		
		Create_Thread("Thread_Spawn_Civilian_Survivors", thread_info)
		Create_Thread("Thread_Dialog_Controller", dialog_presidential_reminder01)
	end
end

function Callback_GasStation_PointGuard_Attacked()
	for i, gas_station_point_guard in pairs(gas_station_point_guard_list) do
		if TestValid(gas_station_point_guard) then
			gas_station_point_guard.Guard_Target(gas_station_point_guard.Get_Position())
			gas_station_point_guard.Unregister_Signal_Handler(Callback_GasStation_PointGuard_Attacked)
		end
	end
end

function PROX_UEA_InRange_of_CkPtCharlie_Fleers(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == player_faction then
		prox_obj.Cancel_Event_Object_In_Range(PROX_UEA_InRange_of_CkPtCharlie_Fleers)
		for i, charlie_fleer in pairs(charlie_fleer_list) do
			if TestValid(charlie_fleer) then
				charlie_fleer.Suspend_Locomotor(false)
				Create_Thread("Thread_Objective01_Captive_Humans_Flee", charlie_fleer)
			end
		end
		
		Create_Thread("Thread_Dialog_Controller", dialog_approaching_check_point_charlie)
	end
end

function PROX_UEA_InRange_of_CkPtCharlie(prox_obj, trigger_obj)
   if trigger_obj.Get_Owner() == player_faction then
      _CustomScriptMessage("JoeLog.txt", string.format("PROX_UEA_InRange_of_CkPtCharlie HIT!"))
      prox_obj.Cancel_Event_Object_In_Range(PROX_UEA_InRange_of_CkPtCharlie)
		
      Create_Thread("Thread_UEA_InRange_of_CkPtCharlie")
   end
end

function Thread_UEA_InRange_of_CkPtCharlie()

	aliens.Make_Enemy(chopper_faction) --should start the hositlities here
	chopper_faction.Make_Enemy(aliens)
	
	for i, troop_charlie in pairs(troop_charlie_list) do
		if TestValid(troop_charlie) then
			troop_charlie.Suspend_Locomotor(false)
		end
	end
	
	Hunt(troop_charlie_list, "AntiDefault", false, true, charlie_guard_location, 10)

	--send in the fodder guys
	for i, charlie_fodder in pairs(charlie_fodder_list) do
		if TestValid(charlie_fodder) then
			charlie_fodder.Suspend_Locomotor(false)
			charlie_fodder.Set_Service_Only_When_Rendered(false)
		end
	end
	
	Hunt(charlie_fodder_list, "Tut01_Grunt_Attack_Priorities", true, true, charlie_guard_location, 50)
	
	Sleep(1)
	fow_checkpoint_charlie = FogOfWar.Reveal(player_faction, charlie_guard_location, 250, 250)
	Create_Thread("Thread_Dialog_Controller", dialog_at_check_point_charlie)
	Create_Thread("Thread_Give_CheckPointCharlie_Objectives")
	if TestValid(radiation_spitter) then
		fow_reveal_radiation_spitter_encounter  = FogOfWar.Reveal(player_faction, radiation_spitter, 250, 250)
		radiation_spitter.Prevent_All_Fire(false)
	end
	
	Create_Thread("Thread_Spawn_Turret_Fodder")

	for i, act02_ambient_grey in pairs(act02_ambient_grey_list) do
		if TestValid(act02_ambient_grey) then
			act02_ambient_grey.Set_In_Limbo(false)
			Create_Thread("Thread_Ambient_Greys_Orders", act02_ambient_grey)
		end
	end

end

function Thread_Give_CheckPointCharlie_Objectives()
--TEST
	Sleep(2)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT01_OBJECTIVE_C_ADD"})
	Sleep(time_objective_sleep)
	tut01_objective02a = Add_Objective("TEXT_SP_MISSION_TUT01_OBJECTIVE_C")--Help defend the checkpoint.
	
	--charlie_guard_location.Highlight(true, -50)
	Create_Thread("Thread_Dialog_Controller", dialog_rooftop_chatter)

	--Sleep(5)

	--charlie_guard_location.Highlight(false)
end



function Callback_CharlieTroop_Killed(dead_troop)
   _CustomScriptMessage("JoeLog.txt", string.format("Callback_CharlieTroop_Killed HIT!"))
   --see who got killed
   --local dead_troop_type =  dead_troop.Get_Type()
	if not bool_thread_charlie_troop_killed_monitoring then
		Create_Thread("Thread_CharlieTroop_Killed")
	end
end

function Thread_CharlieTroop_Killed()
	if bool_thread_charlie_troop_killed_monitoring == true then
		return
	end

	bool_thread_charlie_troop_killed_monitoring = true

   while bool_checkpoint_charlie_secured == false do
      Sleep(5)
   end
	
	counter_current_player_troops = 100
	while counter_current_player_troops > 20  do
		current_player_troops = Find_All_Objects_Of_Type(player_faction, "Organic", "CanAttack")
		counter_current_player_troops = table.getn(current_player_troops)
		
		_CustomScriptMessage("JoeLog.txt", string.format("counter_current_player_troops = %d)", counter_current_player_troops))

		Sleep(3)
	end
	
	Sleep(5)
   
	-- SpawnList(type_list, entry_marker, player, allow_ai_usage, delete_after_scenario, add_to_pop_cap)
	current_player_tanks = Find_All_Objects_Of_Type("MILITARY_ABRAMSM2_TANK") 
	counter_current_player_tanks = table.getn(current_player_tanks)
	if bool_papaya_on_board == true and counter_current_player_tanks <= 1 then
		--replaces hummer with tanks if papaya has been introduced
		troop_charlie_list = SpawnList(troop_charlie_spawn_list_post_papaya, charlie_respawn_location, player_faction, false, true, false)
	else
	
		troop_charlie_list = SpawnList(troop_charlie_spawn_list, charlie_respawn_location, player_faction, false, true, false)
	end
	for i, new_charlie in pairs(troop_charlie_list) do
		new_charlie.Register_Signal_Handler(Callback_CharlieTroop_Killed, "OBJECT_HEALTH_AT_ZERO")
	end
	
	--Raise_Game_Event("Reinforcements_Arrived", player_faction, charlie_respawn_location.Get_Position())

	bool_thread_charlie_troop_killed_monitoring = false --prevents multiple respawns

	while (TestValid(Find_First_Object("Alien_Radiation_Spitter"))) do
		Hunt(troop_charlie_list, "AntiDefault", true, true, charlie_guard_location, 50)
		Sleep(10)
	end
	
	if TestValid(col_moore) then
		_CustomScriptMessage("JoeLog.txt", string.format("Formation_Guard(troop_charlie_list, col_moore)"))
		--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT01_REINFORCEMENT_NOTICE"})--Notice: Reinforcements have arrived.
		Raise_Game_Event("Reinforcements_Arrived", player_faction, troop_charlie_list[1].Get_Position())
		--Formation_Guard(troop_charlie_list, col_moore)
		for vi,vunit in pairs(troop_charlie_list) do
			vunit.Move_To(col_moore)
		end
	end

end

function PROX_Brute_Orders(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == player_faction then
		if bool_display_all_joelog == true then
			_CustomScriptMessage("JoeLog.txt", string.format("PROX_Brute_Orders HIT!  Brutes start acting!!"))
		end
		prox_obj.Cancel_Event_Object_In_Range(PROX_Brute_Orders)
	
		Create_Thread("Thread_School_Brute_Orders")
	end
end

function PROX_Reveal_Brutes(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == player_faction then
		if bool_display_all_joelog == true then
			_CustomScriptMessage("JoeLog.txt", string.format("PROX_Brute_Orders HIT!  Brutes start acting!!"))
		end
		prox_obj.Cancel_Event_Object_In_Range(PROX_Reveal_Brutes)
	
		fow_reveal_schoolchildren = FogOfWar.Reveal(player_faction, roof_brute_target, 250, 250)
      Create_Thread("Thread_Dialog_Controller", dialog_introduce_brutes)
	end
end



function Thread_School_Brute_Orders()
	--reveal map around encounter
	
	if TestValid(schoolchildren_brute_roof) then
		schoolchildren_brute_roof.Set_Service_Only_When_Rendered(false)
		schoolchildren_brute_roof.Play_Animation("ATTACK_SPECIAL_B", true)
	end
	
	--if TestValid(schoolchildren_brute01) then
	--	schoolchildren_brute01.Set_Service_Only_When_Rendered(false)
	--	schoolchildren_brute01.Play_Animation("ATTACK_SPECIAL_A", true)
	--end
	
	Sleep(0.5) --artificial variation so the two roof guys aren't in-sync
	
	if TestValid(schoolchildren_brute_roof02) then
		schoolchildren_brute_roof02.Set_Service_Only_When_Rendered(false)
		schoolchildren_brute_roof02.Play_Animation("ATTACK_SPECIAL_B", true)
	end
end


function PROX_Shoot_The_Tanker(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == player_faction then
		prox_obj.Cancel_Event_Object_In_Range(PROX_Shoot_The_Tanker)
		
		for i, ufo_grey in pairs(ufo_grey_list) do
         if TestValid(ufo_grey) then
            ufo_grey.Suspend_Locomotor(false)
            thread_id_ufo_ambient_grey[i] = Create_Thread("Thread_Ambient_Greys_Orders", ufo_grey)
            if bool_display_all_joelog == true then
               _CustomScriptMessage("JoeLog.txt", string.format("*** SETTING thread_id_ufo_ambient_grey"))
            end
         end
      end
		
		Create_Thread("Thread_Dialog_Controller", dialog_its_a_trap)
		Create_Thread("Thread_Shoot_The_Tanker")
	end
end


function Thread_Shoot_The_Tanker()
	--remove any hints that might not have been opened yet...

	if (HINT_SYSTEM_HINT_SYSTEM ~= nil) then
		Remove_Independent_Hint(HINT_SYSTEM_HINT_SYSTEM)
	end
	
	fow_fuel_truck = FogOfWar.Reveal(player_faction, first_tanker, 250, 250)
	
	player_faction.Lock_Unit_Ability("Military_Hero_Randal_Moore", "Randal_Moore_Grenade_Attack_Ability", false, STORY)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT01_OBJECTIVE_B_ADD"} )
	
	
	Add_Independent_Hint(HINT_SYSTEM_ABILITIES)
	UI_Start_Flash_Ability_Button("TEXT_ABILITY_MILITARY_MOORE_GRENADE")
	--UI_Start_Flash_Ability_Button("TEXT_ABILITY_MILITARY_MOORE_MEDPACK")
	
	Sleep(time_objective_sleep)
	if not bool_fuel_truck_dead then
	   tut01_objective01 = Add_Objective("TEXT_SP_MISSION_TUT01_OBJECTIVE_B")--Use Colonel Moore's Grenade ability to destroy the fuel tanker.
	   Add_Independent_Hint(HINT_SYSTEM_OBJECTIVES)
	   --Sleep(2)
	   --first_tanker.Highlight(true, -65)
	   tanker_flag.Highlight(true, -65)
	end	
end

function PROX_Start_Smithsonian_Objective(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == player_faction then
		prox_obj.Cancel_Event_Object_In_Range(PROX_Start_Smithsonian_Objective)
		
		Create_Thread("Thread_Start_Smithsonian_Objective")
	end
end


function PROX_Start_Smithsonian_Dialog(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == player_faction then
		prox_obj.Cancel_Event_Object_In_Range(PROX_Start_Smithsonian_Dialog)
		
		--Create_Thread("Thread_Start_Smithsonian_Objective")
		Create_Thread("Thread_Dialog_Controller", dialog_first_civvie_encounter)
	end
end



function Thread_Start_Smithsonian_Objective()
	Create_Thread("Thread_Grunts_Brutalize_Civs")
		
	--captive civs panic away...
	for i, captive_human in pairs(captive_human_list) do
		if TestValid(captive_human) then
			captive_human.Suspend_Locomotor(false)
			Create_Thread("Thread_Objective01_Captive_Humans_Flee", captive_human)
		end
	end
	
	--setting up units for first objective
	for i, obj01_alien_grey in pairs(obj01_alien_greys_list) do
		if TestValid(obj01_alien_grey) then
			counter_obj01_greys = counter_obj01_greys + 1
			
			Create_Thread("Thread_Ambient_Greys_Orders", obj01_alien_grey)
			
			--if bool_display_all_joelog == true then
				_CustomScriptMessage("JoeLog.txt", string.format("current objective 01 grey count is %d", counter_obj01_greys))
			--end
		end
	end
	
	for i, obj01_ambush_alien in pairs(obj01_ambush_aliens_list) do
		if TestValid(obj01_ambush_alien) then
			target = Find_Nearest(obj01_ambush_alien, player_faction, true)
				
			if TestValid(target) then
				obj01_ambush_alien.Attack_Move(target.Get_Position())
				if bool_display_all_joelog == true then
					_CustomScriptMessage("JoeLog.txt", string.format("obj01_ambush_alien.Attack_Move(target)"))
				end
			end
		end
	end
		
	Sleep(2)
	
	fow_reveal_smithsonian = FogOfWar.Reveal(player_faction, objective01_location, 250, 250)
	
		
end


function PROX_Start_ArtGallery_Objective(prox_obj, trigger_obj)
	

   if trigger_obj == gallery_chopper01 or trigger_obj == gallery_chopper02 or trigger_obj == gallery_chopper03 then
      return
   end
   
	if trigger_obj.Get_Owner() == player_faction then
		_CustomScriptMessage("JoeLog.txt", string.format("PROX_Start_ArtGallery_Objective HIT!"))
		
		for i, prox_flag in pairs(art_gallery_objective_prox_flag_list) do
			prox_flag.Cancel_Event_Object_In_Range(PROX_Start_ArtGallery_Objective)

		end
		
		Create_Thread("Thread_Start_ArtGallery_Objective")
		
	end
end

function Thread_Start_ArtGallery_Objective()
	
      
	for i, obj02_alien in pairs(obj02_aliens_list) do
		if TestValid(obj02_alien) then
			counter_obj02_aliens = counter_obj02_aliens + 1
			if bool_display_all_joelog == true then
				_CustomScriptMessage("JoeLog.txt", string.format("current objective 02 alien count is %d", counter_obj02_aliens))
			end
			
			Create_Thread("Thread_Ambient_Greys_Orders", obj02_alien)

			obj02_alien.Register_Signal_Handler(Callback_Obj02_Alien_Killed, "OBJECT_HEALTH_AT_ZERO")
		end
	end
	
	for i, reaper in pairs(harvest01_reaper_list) do
		if TestValid(reaper) then
			reaper.Suspend_Locomotor(false)
			reaper.Prevent_All_Fire(false)
			--turn off further notifications
			--reaper.Unregister_Signal_Handler(Callback_Harvest01_Object_Damaged)
		end
	end
	
	for i, civ in pairs(harvest01_civilian_list) do
		if TestValid(civ) then
			civ.Make_Invulnerable(false)
			civ.Set_Cannot_Be_Killed(false)
			Create_Thread("Thread_Captive_Civs_Move_Orders", civ)
		end
	end
	
	Hunt(harvest01_grunt_list, "Tut01_Grunt_Attack_Priorities", true, true, col_moore, 300)
	
	bool_harvest01_attacked = true
	
	Sleep(1)
	
	for i, prox_flag in pairs(art_gallery_objective_prox_flag_list) do
		--prox_flag.Cancel_Event_Object_In_Range(PROX_Start_ArtGallery_Objective)
		fow_reveal_gallery_of_art_list[i] = FogOfWar.Reveal(player_faction, art_gallery_objective_prox_flag_list[i], 250, 250)
	end
	
	Sleep(2)
	Create_Thread("Thread_Dialog_Controller", dialog_intro_reapers)
	
	Sleep(2)
	
	Hunt(harvest01_reaper_list, "Tut01_Reaper_Attack_Priorities", true, true, col_moore, 300)
end

function Thread_Captive_Civs_Move_Orders(civ)
   --_CustomScriptMessage("JoeLog.txt", string.format("Thread_Captive_Civs_Move_Orders HIT!"))
	if not TestValid(civ) then
		return
	end
	
	if civ.Get_Hint() == "harvest01-civ" then
      local civ_panic_goto_list = harvest_01_civ_panic_goto_list
		local total_civ_panic_goto_spots = table.getn(civ_panic_goto_list)
      
       while bool_harvest01_attacked == false do 
         if TestValid(civ) then
            random_slot = GameRandom(1, total_civ_panic_goto_spots) 
            random_loc = civ_panic_goto_list[random_slot]
            BlockOnCommand(civ.Move_To(random_loc.Get_Position()))
            
           -- _CustomScriptMessage("JoeLog.txt", string.format("civ.Move_To(random_loc.Get_Position())"))
         end
         
         Sleep(0.5)
      end
	end
	
   --your group has been attcked...flee off map
   if TestValid(civ) then
      exit_spot_list = Find_All_Objects_Of_Type("MARKER_CIVILIAN_DESPAWNER")
      total_exit_spots = table.getn(exit_spot_list)
      random_slot = GameRandom(1, total_exit_spots) 
      random_loc = exit_spot_list[random_slot]
      BlockOnCommand(civ.Move_To(random_loc.Get_Position()))
      
   end
   
   if TestValid(civ) then
      civ.Despawn()
   end
end

function Callback_Harvest01_Civ_Killed()
   --this replenishes civs from the encounter, unless/until the player has attacked
   if not bool_harvest01_attacked then
      
      script_civ_spawn_type = script_civ_type_list[GameRandom(1,counter_script_civ_types)]
      
      new_civ = Spawn_Unit(Find_Object_Type(script_civ_spawn_type), harvest_01_respawn, civilian) 
      new_civ.Set_Hint("harvest01-civ")
		new_civ.Register_Signal_Handler(Callback_Harvest01_Civ_Killed, "OBJECT_HEALTH_AT_ZERO")
      Create_Thread("Thread_Captive_Civs_Move_Orders", new_civ)
   end
end


function Callback_GalleryReaper_Damaged()
	_CustomScriptMessage("JoeLog.txt", string.format("Callback_Reaper_Damaged HIT!! reapers now to attack uea infantry"))
	--Play_SFX_Event("SFX_Alien_Walker_Announce_2") 
end

function Callback_GalleryReaper_Destroyed()
   counter_reapers_killed = counter_reapers_killed + 1
   if counter_reapers_killed >= 3 then
		--remove death callbacks so dialog only plays once
		for i, harvest01_reaper in pairs(harvest01_reaper_list) do
			if TestValid(harvest01_reaper) then
				harvest01_reaper.Unregister_Signal_Handler(Callback_GalleryReaper_Destroyed)
			end
		end
		
		Create_Thread("Thread_GalleryReaper_Destroyed")
   end
end

function Thread_GalleryReaper_Destroyed()
	while bool_papaya_on_board == false do
		Sleep(3)
	end
	
	--play the not so tough against tanks line
	Create_Thread("Thread_Dialog_Controller", dialog_tanks_are_good) -- old dialog handle getting hijacked to play a presidential reminder
	_CustomScriptMessage("JoeLog.txt", string.format("Create_Thread(Thread_Dialog_Controller, dialog_tanks_are_good)"))
end



--****************************************************
--**************************Saucer encounters stuff
--****************************************************
function Start_Saucer_Encounter()
   for i, saucer01_grey in pairs(saucer01_grey_list) do
      if TestValid(saucer01_grey) then
         --setup death callbacks
         --saucer01_grey.Register_Signal_Handler(Callback_Saucer01_Grey_Killed, "OBJECT_HEALTH_AT_ZERO")
         thread_id_saucer01_grey_tweak_orders[i] = Create_Thread("Thread_Ambient_Greys_Orders", saucer01_grey)
      end
   end
end

function Thread_Saucer_Leaves(thread_info)
   _CustomScriptMessage("JoeLog.txt", string.format("Thread_Saucer_Leaves HIT!!"))
   local saucer = thread_info[1]
   local saucer_grey_list = thread_info[2]
   local saucer_entry = thread_info[3]
   
   if TestValid(saucer) then
      for i, saucer_grey in pairs(saucer_grey_list) do
         if TestValid(saucer_grey) then
            --move into the saucer
            local thread_info = {}
            thread_info[1] = saucer_grey
            thread_info[2] = saucer_entry
            Create_Thread("Thread_SaucerGrey_GetsOnboard", thread_info)
         end
      end
   else
      _CustomScriptMessage("JoeLog.txt", string.format("WARNING!!! Thread_Saucer_Leaves: NOT TestValid(saucer)"))
   end
   
   local bool_all_greys_on_board = false
   while bool_all_greys_on_board == false do
      bool_all_greys_on_board = true
      for i, saucer_grey in pairs(saucer_grey_list) do
         if TestValid(saucer_grey) then
            bool_all_greys_on_board = false
         end
      end
         
      Sleep(0.5)
   end
   
   if TestValid(saucer) then
      BlockOnCommand(saucer.Play_Animation("Anim_Cinematic", false, 1))
   end
   
   if TestValid(saucer) then
      saucer.Despawn()
   end
   
   if fow_reveal_saucer_encounter ~= nil then
      fow_reveal_saucer_encounter.Undo_Reveal()
   end
end

function Thread_SaucerGrey_GetsOnboard(thread_info)
   _CustomScriptMessage("JoeLog.txt", string.format("Thread_SaucerGrey_GetsOnboard HIT!!"))
   local grey = thread_info[1]
   local entry_point = thread_info[2]

   Sleep(GameRandom(0,1)) -- artificial variation
   
   if TestValid(grey) and TestValid(entry_point) then
      grey.Activate_Ability("Grey_Phase_Unit_Ability", true)
      BlockOnCommand(grey.Move_To(entry_point.Get_Position()))
   else
      _CustomScriptMessage("JoeLog.txt", string.format("WARNING!!!  Thread_SaucerGrey_GetsOnboard: NOT TestValid(grey) or TestValid(entry_point) "))
   end
   
   if TestValid(grey) then
      grey.Despawn()
   end
end

function Thread_Papaya_Arrives()
   _CustomScriptMessage("JoeLog.txt", string.format("Thread_Papaya_Arrives HIT!! Papaya should now enter"))
	for i, papaya_reinforcement in pairs(papaya_reinforcement_list) do
		if TestValid(papaya_reinforcement) then
			papaya_reinforcement.Set_Object_Context_ID("Tut01_StoryCampaign")
         papaya_reinforcement.Change_Owner(chopper_faction)
			--papaya_reinforcement.Set_Selectable(false)
		end
	end
	
	if (TestValid(papaya01) and TestValid(papaya01_spawn)) then papaya01.Teleport_And_Face(papaya01_spawn) end
	if (TestValid(papaya02) and TestValid(papaya02_spawn)) then papaya02.Teleport_And_Face(papaya02_spawn) end
	if (TestValid(papaya05) and TestValid(papaya05_spawn)) then papaya05.Teleport_And_Face(papaya05_spawn) end
	if (TestValid(papaya06) and TestValid(papaya06_spawn)) then papaya06.Teleport_And_Face(papaya06_spawn) end
	if (TestValid(papaya08) and TestValid(papaya08_spawn)) then papaya08.Teleport_And_Face(papaya08_spawn) end
	if (TestValid(papaya01a) and TestValid(papaya01a_spawn)) then papaya01a.Teleport_And_Face(papaya01a_spawn) end
	if (TestValid(papaya02a) and TestValid(papaya02a_spawn)) then papaya02a.Teleport_And_Face(papaya02a_spawn) end
	if (TestValid(papaya05a) and TestValid(papaya05a_spawn)) then papaya05a.Teleport_And_Face(papaya05a_spawn) end
	if (TestValid(papaya06a) and TestValid(papaya06a_spawn)) then papaya06a.Teleport_And_Face(papaya06a_spawn) end
	if (TestValid(papaya08a) and TestValid(papaya08a_spawn)) then papaya08a.Teleport_And_Face(papaya08a_spawn) end
	
	bool_papaya_on_board = true
	
	Formation_Guard(papaya_reinforcement_list, col_moore)

	--Sleep(1)
	
	--Create_Thread("Thread_Papaya_Orders")
	
	--Sleep(3)

	if TestValid(sgt_woolard) then
		sgt_woolard.Register_Signal_Handler(Callback_Sgt_Woolard_Killed, "OBJECT_HEALTH_AT_ZERO")
		Create_Thread("Thread_Sgt_Woolard_Health_Monitor")
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR!!! Thread_Papaya_Arrives not detecting woolard"))
	end
	
end

function Thread_Papaya_Orders()
	if TestValid(reaper01) then
		if bool_display_all_joelog == true then
			_CustomScriptMessage("JoeLog.txt", string.format("Formation_Attack_Move(papaya_reinforcement_list, reaper01)"))
		end
		Formation_Attack_Move(papaya_reinforcement_list, reaper01)
	end
	
	while TestValid(reaper01) do
		Sleep(2)
	end
	
	if TestValid(reaper03) then
		if bool_display_all_joelog == true then
			_CustomScriptMessage("JoeLog.txt", string.format("Formation_Attack_Move(papaya_reinforcement_list, reaper03)"))
		end
		Formation_Attack_Move(papaya_reinforcement_list, reaper03)
	end
	
	while TestValid(reaper03) do
		Sleep(2)
	end
	
	if TestValid(reaper02) then
		if bool_display_all_joelog == true then
			_CustomScriptMessage("JoeLog.txt", string.format("Formation_Attack_Move(papaya_reinforcement_list, reaper02)"))
		end
		Formation_Attack_Move(papaya_reinforcement_list, reaper02)
	end
	
	while TestValid(reaper02) do
		Sleep(2)
	end
	
	if TestValid(col_moore) then
		if bool_display_all_joelog == true then
			_CustomScriptMessage("JoeLog.txt", string.format("Formation_Guard(papaya_reinforcement_list, col_moore)"))
		end
		Formation_Guard(papaya_reinforcement_list, col_moore)
	end
end

--stub dialog event 
function PROX_Greys_Spotted_First_Time(prox_obj, trigger_obj)
	if trigger_obj.Get_Owner() == aliens then
		prox_obj.Cancel_Event_Object_In_Range(PROX_Greys_Spotted_First_Time)
		Create_Thread("Thread_Dialog_Controller", dialog_first_contact)
		
	end
end

--this is the functin that makes the greys all tweaky
function Thread_Ambient_Greys_Orders(grey)
	if not TestValid(grey) then
		return
	end
	
   local ambient_grey_hide_spot_list = {}
   
	if grey.Get_Hint() == "act01" then
		--grey.Register_Signal_Handler(Callback_Act01_AmbientGrey_Killed, "OBJECT_HEALTH_AT_ZERO")
		grey.Override_Max_Speed(1)
	elseif grey.Get_Hint() == "ufo-grey" then  
      ambient_grey_hide_spot_list = ufo_alien_hide_spot_list
      grey.Register_Signal_Handler(Callback_UFO_Grey_Killed, "OBJECT_HEALTH_AT_ZERO")
	elseif grey.Get_Hint() == "objective01" then
		ambient_grey_hide_spot_list = obj01_ambient_grey_hide_spot_list
	elseif grey.Get_Hint() == "act02-ambient" then
		ambient_grey_hide_spot_list = act02_ambient_grey_hide_spot_list
	elseif grey.Get_Hint() == "objective02" then
		ambient_grey_hide_spot_list = obj02_ambient_grey_hide_spot_list
   --elseif grey.Get_Hint() == "passguard-ambient" then
      --ambient_grey_hide_spot_list = passguard_ambient_grey_hide_spot_list   
   elseif grey.Get_Hint() == "capitolguard-ambient" then
      ambient_grey_hide_spot_list = capitolguard_ambient_grey_hide_spot_list   
	elseif grey.Get_Hint() == "saucer01" then
      ambient_grey_hide_spot_list = saucer01_grey_goto_list   
	end
   
	if TestValid(ambient_grey_hide_spot_list[1]) then
		local total_ambient_grey_hide_spots = table.getn(ambient_grey_hide_spot_list)
	else
		--something's wrong...break out
		return
	end
	
	while TestValid(grey) do
		if TestValid(grey) then
			if not grey.Has_Attack_Target() then
			
				if grey.Get_Hint() == "objective01" then
					target = smithsonian
					grey.Attack_Target(target)
				elseif grey.Get_Hint() == "objective02" then
					target = art_gallery
					grey.Attack_Target(target)
					
				else
					target = Find_Nearest(grey, player_faction, true)
					if TestValid(target) then
						grey.Attack_Move(target.Get_Position())
						if bool_display_all_joelog == true then
							_CustomScriptMessage("JoeLog.txt", string.format("grey.Attack_Move(target)"))
						end
					end
				end
			end
		end
		
      Sleep(GameRandom(0, 1))
		
		if TestValid(grey) then
         random_slot = GameRandom(1, total_ambient_grey_hide_spots) 
         random_loc = ambient_grey_hide_spot_list[random_slot]
			
			if random_loc ~= nil then
				--if bool_display_all_joelog == true then
					_CustomScriptMessage("JoeLog.txt", string.format("grey.Move_To(random_loc.Get_Position())"))
				--end
				BlockOnCommand(grey.Move_To(random_loc.Get_Position()))
				
			end
		end
      
      Sleep(0.5)
	end
end

-- ##########################################################################################
-- ############################# TEMPORARY CINEMATICS #######################################
-- ##########################################################################################

function Thread_Mission_Complete()

		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
			
	Set_Hint_System_Visible(false)
	bool_mission_won = true --this flag is what I check to make sure no game logic continues when the mission is over
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()

-- this music is faction specific, 
-- use: UEA_Win_Tactical_Event Alien_Win_Tactical_Event Novus_Win_Tactical_Event Masari_Win_Tactical_Event
	Play_Music("Military_Win_Tactical_Event")
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,90)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
	Sleep(6)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	
	if bool_skip_outro ~= true then
		--Crank up the service rate so that we can catch the end of the movie accurately
		--and not have some gameplay sneak in between.
		Fade_Out_Music() 
		local old_service_rate = ServiceRate
		ServiceRate = 0
		Lock_Controls(0)
		BlockOnCommand(Play_Bink_Movie("Mission_1_Outro", true))
		ServiceRate = old_service_rate
   end


	Force_Victory(player_faction)
   Lock_Controls(0)

end


function Cache_Models()
	-- precache the models we expect to spawn from script here so they load faster.
	Find_Object_Type("American_Civilian_Urban_01_Map_Loiterer").Load_Assets()
	Find_Object_Type("American_Civilian_Urban_02_Map_Loiterer").Load_Assets()
	Find_Object_Type("American_Civilian_Urban_03_Map_Loiterer").Load_Assets()
	Find_Object_Type("American_Civilian_Urban_05_Map_Loiterer").Load_Assets()
	Find_Object_Type("American_Civilian_Urban_06_Map_Loiterer").Load_Assets()
	Find_Object_Type("American_Civilian_Urban_07_Map_Loiterer").Load_Assets()
	Find_Object_Type("American_Civilian_Urban_08_Map_Loiterer").Load_Assets()
	Find_Object_Type("American_Civilian_Urban_09_Map_Loiterer").Load_Assets()
	Find_Object_Type("American_Civilian_Urban_10_Map_Loiterer").Load_Assets()
	Find_Object_Type("American_Civilian_Urban_11_Map_Loiterer").Load_Assets()
	Find_Object_Type("LARGE_EXPLOSION_LAND").Load_Assets()
	Find_Object_Type("TUT01_OIL_TANKER_VEHICLE_DEATH_CLONE").Load_Assets()
	Find_Object_Type("OIL_TANKER_VEHICLE_DEATH_CLONE_CHUNK02").Load_Assets()
	Find_Object_Type("Oil_tanker_Vehicle_Death_Clone_Chunk03").Load_Assets()
	Find_Object_Type("Oil_tanker_Vehicle_Death_Clone_Chunk04").Load_Assets()
	Find_Object_Type("Oil_tanker_Vehicle_Death_Clone_Chunk05").Load_Assets()
	Find_Object_Type("Oil_tanker_Vehicle_Death_Clone_Chunk06").Load_Assets()
	Find_Object_Type("Oil_tanker_Vehicle_Death_Clone_tire").Load_Assets()

	Find_Object_Type("Generic_Vehicle_Death_Clone_Chunk").Load_Assets()
	Find_Object_Type("Generic_Vehicle_Death_Clone_Hood").Load_Assets()
	Find_Object_Type("Generic_Vehicle_Death_Clone_Muffler").Load_Assets()
	Find_Object_Type("Generic_Vehicle_Death_Clone_Pipe").Load_Assets()
	Find_Object_Type("Generic_Vehicle_Death_Clone_Radiator").Load_Assets()
	Find_Object_Type("Generic_Vehicle_Death_Clone_wheel1").Load_Assets()
	Find_Object_Type("Generic_Vehicle_Death_Clone_Wheel2").Load_Assets()
	Find_Object_Type("Generic_Vehicle_Death_Clone_Grill").Load_Assets()
	Find_Object_Type("Generic_Vehicle_Death_Clone_Door").Load_Assets()
	Find_Object_Type("Oil_Tanker_Explosion").Load_Assets()
	Find_Object_Type("Combustive_Fire").Load_Assets()
	
end

--[[function  Init_Radar()
	radar_filter_id0 = RadarMap.Add_Filter("Radar_Map_Enable", player_faction, true, "Bitwise_And")
	radar_filter_id1 = RadarMap.Add_Filter("Radar_Map_Show_Fogged", player_faction, false, "Bitwise_And")
	radar_filter_id2 = RadarMap.Add_Filter("Radar_Map_Show_Terrain", player_faction, true, "Bitwise_And")
	radar_filter_id3 = RadarMap.Add_Filter("Radar_Map_Show_FOW", player_faction, false, "Bitwise_And")
	radar_filter_id4 = RadarMap.Add_Filter("Radar_Map_Show_Enemy", player_faction, true, "Bitwise_And")
	radar_filter_id5 = RadarMap.Add_Filter("Radar_Map_Show_Neutral", player_faction, true, "Bitwise_And")
	radar_filter_id6 = RadarMap.Add_Filter("Radar_Map_Show_Owned", player_faction, true, "Bitwise_And")
	radar_filter_id7 = RadarMap.Add_Filter("Radar_Map_Show_Allied", player_faction, true, "Bitwise_And")
end]]


function Define_Hints()
	_CustomScriptMessage("JoeLog.txt", string.format("#*#*#*NOTICE: Define_Hints: Start!"))

	player_list = Find_All_Objects_Of_Type(player_faction)
	

	player_list_table_size = table.getn(player_list)
   
   for i, player_unit in pairs(player_list) do
		if TestValid(player_unit) then
         --player_unit.Register_Signal_Handler(Callback_Player_Unit_Attacked, "OBJECT_DAMAGED")
			
			--if player_unit.Has_Behavior(BEHAVIOR_LOCO) then
				--_CustomScriptMessage("JoeLog.txt", string.format("player_unit.Override_Max_Speed(1.25)"))
			player_unit.Override_Max_Speed(1.25)
			--end
		end
	end
	
	mirabel_wait_spot = Find_Hint("MARKER_GENERIC_GREEN","mirabel-wait")
	if not TestValid(mirabel_wait_spot) then
		_CustomScriptMessage("JoeLog.txt", string.format("#*#*#*ERROR!!*#*#*#*#*#*#*#Story_Campaign_Novus_Tut01 cannot find mirabel_wait_spot!"))
	end
		
	mirabel = Find_First_Object("Novus_Hero_Mech")
	if TestValid(mirabel) then
		mirabel.Teleport_And_Face(mirabel_wait_spot)
		mirabel.Set_Object_Context_ID("hide_me")
	else
		_CustomScriptMessage("JoeLog.txt", string.format("#*#*WARNING!!#*#*#*#*#*#*#*#Story_Campaign_Novus_Tut01 cannot find Mirabel!"))
	end
	
	col_moore = Find_First_Object("MILITARY_HERO_RANDAL_MOORE")  
	if TestValid(col_moore) then
		Point_Camera_At(col_moore)
		Register_Prox(col_moore, PROX_Greys_Spotted_First_Time, 150, aliens)
		
		if bool_make_col_moore_unkillable == true then
			col_moore.Set_Cannot_Be_Killed(true)
		else
			col_moore.Register_Signal_Handler(Callback_Col_Moore_Killed, "OBJECT_HEALTH_AT_ZERO")
		end
      Create_Thread("Thread_Col_Moore_Health_Monitor")
      
	else
		_CustomScriptMessage("JoeLog.txt", string.format("#*#*#*#*#*#*#*#*#*#*#*#*#*#*#ERROR!!!!  Story_Campaign_Novus_Tut01 cannot find col_moore!"))
	end
	
	
	
	starting_player1_list = {}
	starting_player1_list = Find_All_Objects_With_Hint("player1")
	player1 = starting_player1_list[1]
	
	starting_player2_list = {}
	starting_player2_list = Find_All_Objects_With_Hint("player2")
	player2 = starting_player2_list[1]
	
	starting_player3_list = {}
	starting_player3_list = Find_All_Objects_With_Hint("player3")
	player3 = starting_player3_list[1]
	
	starting_player4_list = {}
	starting_player4_list = Find_All_Objects_With_Hint("player4")
	player4 = starting_player4_list[1]
	
	starting_player5_list = {}
	starting_player5_list = Find_All_Objects_With_Hint("player5")
	player5 = starting_player5_list[1]
	
	starting_player6_list = {}
	starting_player6_list = Find_All_Objects_With_Hint("player6")
	player6 = starting_player6_list[1]
	
	starting_colmoore_goto = Find_Hint("MARKER_GENERIC_BLUE","starting-colmoore-goto")
	starting_player1_goto = Find_Hint("MARKER_GENERIC_BLUE","starting-player1-goto")
	starting_player2_goto = Find_Hint("MARKER_GENERIC_BLUE","starting-player2-goto")
	starting_player3_goto = Find_Hint("MARKER_GENERIC_BLUE","starting-player3-goto")
	starting_player4_goto = Find_Hint("MARKER_GENERIC_BLUE","starting-player4-goto")
	starting_player5_goto = Find_Hint("MARKER_GENERIC_BLUE","starting-player5-goto")
	starting_player6_goto = Find_Hint("MARKER_GENERIC_BLUE","starting-player6-goto")
   
	missionstart_camera_start = Find_Hint("MARKER_CAMERA","missionstart-camera-start")
	missionstart_target_start = Find_Hint("MARKER_CAMERA","missionstart-target-start")
	
	missionstart_camera_transition01 = Find_Hint("MARKER_CAMERA","missionstart-camera-transition01")
	missionstart_target_transition01 = Find_Hint("MARKER_CAMERA","missionstart-target-transition01")
	
	gawker_list = Find_All_Objects_With_Hint("gawker")
	for i, gawker in pairs(gawker_list) do
		if TestValid(gawker) then
			gawker.Suspend_Locomotor(true)
		end
	end
	
	player_faction.Lock_Unit_Ability("Military_Apache", "Unit_Ability_Apache_Rocket_Barrage", true, STORY)
	player_faction.Lock_Unit_Ability("Military_Hero_Randal_Moore", "Randal_Moore_Grenade_Attack_Ability", true, STORY)
	--aliens.Lock_Object_Type(Find_Object_Type("Alien_Mutant_Slave"),true,STORY) -- dont want mutant slaves in this mission
	

	first_grey_list = Find_All_Objects_With_Hint("firstgrey")
	firstgrey = first_grey_list[1]
	
	if TestValid(firstgrey) then
		--Hunt(firstgrey, "Tut01_Human_Killers_Attack_Priorities", true, true, firstgrey, 20)
		--Create_Thread("Thread_FirstGrey_AttackOrders")
		firstgrey.Prevent_All_Fire(true)
	end
	
	--TEST: unit.Set_Service_Only_When_Rendered(true)
	alien_units = Find_All_Objects_Of_Type(aliens)
	civilian_units = Find_All_Objects_Of_Type(civilian)
	
	for i, alien in pairs(alien_units) do
		if TestValid(alien) then
			alien.Set_Service_Only_When_Rendered(true)
		end
	end
	
	for i, civilian in pairs(civilian_units) do
		if TestValid(civilian) then
			civilian.Set_Service_Only_When_Rendered(true)
		end
	end
	
	
	
	--first_grey_target_list = Find_All_Objects_With_Hint("firstgrey-target")
	--for i, first_grey_target in pairs(first_grey_target_list) do
	--	if TestValid(first_grey_target) then
			--first_grey_target.Suspend_Locomotor(true)
			--first_grey_target.Make_Invulnerable(true)
	--	end
	--end
	
	
	
   --hunting packs stuff
   hunt_pack01 = Find_All_Objects_With_Hint("hunt-pack01")
   Hunt(hunt_pack01, "Tut01_Grunt_Attack_Priorities", true, true, hunt_pack01[1], 50)
   
   hunt_pack02 = Find_All_Objects_With_Hint("hunt-pack02")
   Hunt(hunt_pack02, "Tut01_Grunt_Attack_Priorities", true, true, hunt_pack02[1], 50)
   
   hunt_pack03 = Find_All_Objects_With_Hint("hunt-pack03")
   Hunt(hunt_pack03, "Tut01_Grunt_Attack_Priorities", true, true, hunt_pack03[1], 50)
   
   hunt_pack04 = Find_All_Objects_With_Hint("hunt-pack04")
   Hunt(hunt_pack04, "Tut01_Grunt_Attack_Priorities", true, true, hunt_pack04[1], 50)
   
   hunt_pack05 = Find_All_Objects_With_Hint("hunt-pack05")
   Hunt(hunt_pack05, "Tut01_Grunt_Attack_Priorities", true, true, hunt_pack05[1], 50)
   
   hunt_pack06 = Find_All_Objects_With_Hint("hunt-pack06")
   Hunt(hunt_pack06, "Tut01_Grunt_Attack_Priorities", true, true, hunt_pack06[1], 50)
   
   --hunt_pack07 = Find_All_Objects_With_Hint("hunt-pack07")
   --Hunt(hunt_pack07, "Tut01_Grunt_Attack_Priorities", true, true, hunt_pack07[1], 50)
   
   hunt_pack08 = Find_All_Objects_With_Hint("hunt-pack08")
   Hunt(hunt_pack08, "Tut01_Grunt_Attack_Priorities", false, true, hunt_pack08[1], 25)
   
   passguard_list = Find_All_Objects_With_Hint("passguard")
   passguard_guard_spot = Find_Hint("MARKER_GENERIC_RED","passguard-guard-spot")
   
   for i, passguard in pairs(passguard_list) do
		if TestValid(passguard) then
         passguard.Register_Signal_Handler(Callback_Passguard_Attacked, "OBJECT_DAMAGED")
		end
	end
   
   passguard_ambient_grey_list = Find_All_Objects_With_Hint("passguard-ambient", "ALIEN_SCIENCE_GREY_INDIVIDUAL")
   --passguard_ambient_grey_hide_spot_list = Find_All_Objects_With_Hint("passguard-alien-hide-spot", "MARKER_GENERIC_YELLOW")
   
   --capitol guard stuff
   capitolguard_list = Find_All_Objects_With_Hint("capitolguard")
   counter_capitolguard = table.getn(capitolguard_list)
	counter_capitolguard_killed = 0
   capitolguard_guard_spot = Find_Hint("MARKER_GENERIC_RED","capitolguard-guard-spot")
	
	Hunt(capitolguard_list, "Tut01_Reaper_Attack_Priorities", false, true, capitolguard_guard_spot, 125) 
	
	
	capitolguard_northpath_list = Find_All_Objects_With_Hint("capitolguard-northpath")
	Hunt(capitolguard_northpath_list, "Tut01_Reaper_Attack_Priorities", false, true, capitolguard_northpath_list[1], 125) 
	
   
   for i, capitolguard in pairs(capitolguard_list) do
		if TestValid(capitolguard) then
         capitolguard.Register_Signal_Handler(Callback_Capitolguard_Attacked, "OBJECT_DAMAGED")
         capitolguard.Register_Signal_Handler(Callback_Capitolguard_Killed, "OBJECT_HEALTH_AT_ZERO")
		end
	end
   
   capitolguard_ambient_grey_list = Find_All_Objects_With_Hint("capitolguard-ambient", "ALIEN_SCIENCE_GREY_INDIVIDUAL")
   capitolguard_ambient_grey_hide_spot_list = Find_All_Objects_With_Hint("capitolguard-alien-hide-spot", "MARKER_GENERIC_YELLOW")
   capitolguard_ambient_grey_scatter_spot_list = Find_All_Objects_With_Hint("capitolguard-alien-scatter-spot", "MARKER_GENERIC_YELLOW")
   
	capitol_building = Find_First_Object("TM01_CAPITOL_BUILDING")
   capitolguard02_list = Find_All_Objects_With_Hint("capitolguard02")
	counter_capitolguard02 = table.getn(capitolguard02_list)
	counter_capitolguard02_killed = 0
   for i, capitolguard02 in pairs(capitolguard02_list) do
		if TestValid(capitolguard02) then
         capitolguard02.Register_Signal_Handler(Callback_Capitolguard02_Attacked, "OBJECT_DAMAGED")
			capitolguard02.Register_Signal_Handler(Callback_Capitolguard02_Killed, "OBJECT_HEALTH_AT_ZERO")
			--capitolguard02.Attack_Target(capitol_building)
		end
	end
	
	Hunt(capitolguard02_list, "Tut01_Reaper_Attack_Priorities", false, true, capitolguard02_list[1], 25) 
	
	--does a quick count of how many "types" of civs are listed above in "civ_type_list"
	counter_civ_types = table.getn(civ_type_list)
   counter_script_civ_types = table.getn(script_civ_type_list)
	counter_schoolchildren_types = table.getn(schoolchildren_type_list)
	
	mission_start_prox_flag_list = Find_All_Objects_With_Hint("prox-mission-start", "MARKER_GENERIC_GREEN")
	for i, prox_flag in pairs(mission_start_prox_flag_list) do
		Register_Prox(prox_flag, PROX_Start_Mission, 100, player_faction)
	end
	
	act01_ambient_grey_list = Find_All_Objects_With_Hint("act01", "ALIEN_SCIENCE_GREY_INDIVIDUAL")
	counter_act01_ambient_greys = table.getn(act01_ambient_grey_list)
	act01_ambient_grey_hide_spot_list = Find_All_Objects_With_Hint("act01-alien-hide-spot", "MARKER_GENERIC_YELLOW")
	act01_greys_fallback_pos = Find_Hint("MARKER_GENERIC_RED","ufo-fallback01")
   act01_greys_guard_pos = Find_Hint("MARKER_GENERIC_GREEN","act01-grey-guard")
   
   --send in the clowns
   for i, act01_ambient_grey in pairs(act01_ambient_grey_list) do
      if TestValid(act01_ambient_grey) then
			act01_ambient_grey.Register_Signal_Handler(Callback_Act01_AmbientGrey_Damaged, "OBJECT_DAMAGED")
			act01_ambient_grey.Set_Cannot_Be_Killed(true)
      end
   end
   
   Hunt(act01_ambient_grey_list, "Tut01_Reaper_Attack_Priorities", true, true, act01_greys_guard_pos, 25) 
	
   --register prox event to spring the trap
   act01_greys_civ_spawner = Find_Hint("MARKER_GENERIC_RED","act01-greys-civ-spawner")
   
	first_tanker = Find_Hint("TUT01_CIVILIAN_OIL_TANKER_TRAILER","first-tanker")
	
	if not TestValid(first_tanker) then
		_CustomScriptMessage("JoeLog.txt", string.format("#*#*#*#*#*#ERROR!!!!#*#*#*#Story_Campaign_Novus_Tut01 cannot find first_tanker!"))
	else
		first_tanker.Register_Signal_Handler(Callback_FirstTanker_Killed, "OBJECT_HEALTH_AT_ZERO")
		_CustomScriptMessage("JoeLog.txt", string.format("first_tanker defined and Callback_FirstTanker_Killed set"))
	end
	first_tanker_flag = Find_Hint("MARKER_GENERIC_RED","first-tanker-flag")
   
	tanker_flag = Find_Hint("MARKER_GENERIC_RED","tanker-flag")
	
	second_tanker = Find_Hint("TUT01_CIVILIAN_OIL_TANKER_TRAILER","second-tanker")
	second_tanker.Register_Signal_Handler(Callback_SecondTanker_Killed, "OBJECT_HEALTH_AT_ZERO")
	second_tanker_flag = Find_Hint("MARKER_GENERIC_RED","second-tanker-flag")
	
   radiation_spitter = Find_First_Object("TUT01_ALIEN_RADIATION_SPITTER")
	radiation_spitter_location = radiation_spitter.Get_Position()
   if TestValid(radiation_spitter) then
      radiation_spitter.Register_Signal_Handler(Callback_Radiation_Spitter_Killed, "OBJECT_HEALTH_AT_ZERO")
		radiation_spitter.Prevent_All_Fire(true)
		
		--XXX TESTING
		--radiation_spitter.Make_Invulnerable(true)--safety
   end
   
   radiation_spitter_civ_spawner = Find_Hint("MARKER_GENERIC_BLUE","turret-civ-spawner")
   if not TestValid(radiation_spitter_civ_spawner) then
		_CustomScriptMessage("JoeLog.txt", string.format("#*#*#*#*#*#ERROR!!!!#*#*#*#Story_Campaign_Novus_Tut01 cannot find radiation_spitter_civ_spawner!"))
	end
   
	if not TestValid(first_tanker_flag) then
		_CustomScriptMessage("JoeLog.txt", string.format("#*#*#*#*#*#ERROR!!!!#*#*#*#Story_Campaign_Novus_Tut01 cannot find first_tanker!"))
	else
		Register_Prox(first_tanker_flag, PROX_Shoot_The_Tanker, 100, player_faction)
	end
   
   ufo_grey_list = Find_All_Objects_With_Hint("ufo-grey", "ALIEN_SCIENCE_GREY_INDIVIDUAL")
   counter_ufo_greys = table.getn(ufo_grey_list)
   for i, ufo_grey in pairs(ufo_grey_list) do
		if TestValid(ufo_grey) then
			ufo_grey.Suspend_Locomotor(true)
		end
	end
   
   ufo_alien_hide_spot_list = Find_All_Objects_With_Hint("ufo-alien-hide-spot", "MARKER_GENERIC_YELLOW")
   ufo_alien_respawnflag = Find_Hint("MARKER_GENERIC_YELLOW","ufo-alien-respawnflag")
	
	--defining misc units 
	obj01_alien_greys_list = Find_All_Objects_With_Hint("objective01")
	obj01_alien_guards02_list = Find_All_Objects_With_Hint("objective01-guard02")
	obj01_ambush_aliens_list = Find_All_Objects_With_Hint("objective01-ambush")
	obj01_ambient_grey_hide_spot_list = Find_All_Objects_With_Hint("objective01-alien-hide-spot", "MARKER_GENERIC_YELLOW")
	
	obj01_fleer_despawn_flag = Find_Hint("MARKER_CIVILIAN_DESPAWNER","despawn")
	
	--obj01_grunt_shotgun_target = Find_Hint("MARKER_GENERIC_RED","grunt-shotgun-target")
		
	obj02_aliens_list = Find_All_Objects_With_Hint("objective02")
	obj02_ambient_grey_hide_spot_list = Find_All_Objects_With_Hint("objective02-alien-hide-spot", "MARKER_GENERIC_YELLOW")

	gallery_chopper_list = {}
	gallery_chopper01 = Find_Hint("MILITARY_APACHE","gallery-chopper01")
	gallery_chopper02 = Find_Hint("MILITARY_APACHE","gallery-chopper02")
	gallery_chopper03 = Find_Hint("MILITARY_APACHE","gallery-chopper03")
	if TestValid(gallery_chopper01) then
		gallery_chopper01.Set_Object_Context_ID("hide_me")
		gallery_chopper_list[1] = gallery_chopper01
	end
	if TestValid(gallery_chopper02) then
		gallery_chopper02.Set_Object_Context_ID("hide_me")
		gallery_chopper_list[2] = gallery_chopper02
	end
	if TestValid(gallery_chopper03) then
		gallery_chopper03.Set_Object_Context_ID("hide_me")
		gallery_chopper_list[3] = gallery_chopper03
	end
	
	--these guys chase after the helicopters
	foo_fighter_list = Find_All_Objects_Of_Type("ALIEN_FOO_FIGHTER") 
	for i, foo_fighter in pairs(foo_fighter_list) do
		if TestValid(foo_fighter) then
			--foo_fighter.Set_Targeting_Priorities("hide_me")
			foo_fighter.Set_Object_Context_ID("hide_me")
		end
	end
	
	gallery_foo_list = Find_All_Objects_With_Hint("gallery-foo")
	for i, gallery_foo in pairs(gallery_foo_list) do
		if TestValid(gallery_foo) then
			gallery_foo.Set_Object_Context_ID("hide_me")
			_CustomScriptMessage("JoeLog.txt", string.format("gallery_foo.Set_Object_Context_ID(hide_me)"))
		end
	end

	gallery_chopper01_goto = Find_Hint("MARKER_GENERIC_BLUE","gallery-chopper01-goto")
	gallery_chopper02_goto = Find_Hint("MARKER_GENERIC_BLUE","gallery-chopper02-goto")
	gallery_chopper03_goto = Find_Hint("MARKER_GENERIC_BLUE","gallery-chopper03-goto")
   
	schoolchildren_brute01 = Find_Hint("ALIEN_BRUTE_TUT01","school-brute-01")
	schoolchildren_brute01.Despawn()
	schoolchildren_brute_roof = Find_Hint("ALIEN_BRUTE_TUT01","school-brute-roof")
   schoolchildren_brute_roof02 = Find_Hint("ALIEN_BRUTE_TUT01","school-brute-roof02")
	
	schoolchildren_brute01_goto = Find_Hint("MARKER_GENERIC_YELLOW","schoolbrute-01-goto")
	
	roof_brute_target = Find_Hint("MARKER_GENERIC_BLUE", "roof-brute-target")
	roof_brute_dfa_target = Find_Hint("MARKER_GENERIC_BLUE", "roof-brute-dfa-target")
   roof_brute_dfa_target02 = Find_Hint("MARKER_GENERIC_BLUE", "roof-brute-dfa-target02")
	
	--if TestValid(schoolchildren_brute01) then
    --  schoolchildren_brute01.Suspend_Locomotor(true)
	--	schoolchildren_brute01.Register_Signal_Handler(Callback_Schoolchildren_Brute_Killed, "OBJECT_HEALTH_AT_ZERO")
	--end

	if TestValid(schoolchildren_brute_roof02) then
      schoolchildren_brute_roof02.Suspend_Locomotor(true)
		schoolchildren_brute_roof02.Register_Signal_Handler(Callback_Schoolchildren_Brute_Killed, "OBJECT_HEALTH_AT_ZERO")
	end
	
	if TestValid(schoolchildren_brute_roof) then
		schoolchildren_brute_roof.Suspend_Locomotor(true)
		schoolchildren_brute_roof.Register_Signal_Handler(Callback_Schoolchildren_Brute_Killed, "OBJECT_HEALTH_AT_ZERO")
	end
	
	human_services_building = Find_Hint("TM01_DEPARTMENT_OF_HEALTH","human-services")
	human_services_building.Make_Invulnerable(true)--safety
	
	proxflag_start_brute_encounter = Find_Hint("MARKER_GENERIC_BLUE","prox-start-brute-encounter")
	Register_Prox(proxflag_start_brute_encounter, PROX_Brute_Orders, 50, player_faction)
	
	proxflag_reveal_brute_encounter = Find_Hint("MARKER_GENERIC_BLUE","prox-reveal-brute-encounter")
	Register_Prox(proxflag_reveal_brute_encounter, PROX_Reveal_Brutes, 50, player_faction)
   	
   schoolbus01_exit = Find_Hint("MARKER_GENERIC_RED","schoolbus-exit")
   
	schoolbus_list = Find_All_Objects_With_Hint("schoolbus")
	for i, schoolbus in pairs(schoolbus_list) do
		if TestValid(schoolbus) then
			schoolbus.Resource_Set_Resource_Units(0)
		end
	end
	
	--generic point guard guys
	pointguard_list = Find_All_Objects_With_Hint("pointguard")
	for i, pointguard in pairs(pointguard_list) do
		if TestValid(pointguard) then
			pointguard.Guard_Target(pointguard.Get_Position())
			Hunt(pointguard, "Tut01_Human_Killers_Attack_Priorities", false, true, pointguard, 20)
		end
	end
	
	gas_station = Find_Hint("AMERICAN_GAS_STATION_02","gas-station")
	if TestValid(gas_station) then
		gas_station.Make_Invulnerable(true)
		gas_station.Set_Cannot_Be_Killed(true)
	else
		_CustomScriptMessage("JoeLog.txt", string.format("ERROR! gas_station coming back as not valid!"))
	end
	gas_station_point_guard_list = Find_All_Objects_With_Hint("gas-station-pointguard")
	counter_gas_station_point_guards = table.getn(gas_station_point_guard_list)
	counter_gas_station_point_guards_killed = 0
	for i, gas_station_point_guard in pairs(gas_station_point_guard_list) do
		if TestValid(gas_station_point_guard) then
			gas_station_point_guard.Register_Signal_Handler(Callback_GasStation_PointGuard_Killed, "OBJECT_HEALTH_AT_ZERO")
			gas_station_point_guard.Register_Signal_Handler(Callback_GasStation_PointGuard_Attacked, "OBJECT_DAMAGED")
		end
	end
	
	Hunt(gas_station_point_guard_list, "Tut01_Human_Killers_Attack_Priorities", false, true, gas_station_point_guard_list[1], 20)
	
	--firstpass troop-reward stuff
	troop_reward_list = Find_All_Objects_With_Hint("troop-reward")
	for i, troop_reward in pairs(troop_reward_list) do
		if TestValid(troop_reward) then
			if bool_display_all_joelog == true then
				_CustomScriptMessage("JoeLog.txt", string.format("Register_Prox(troop_reward, PROX_UEA_Troop_Reward, 100, novus)"))
			end
			Register_Prox(troop_reward, PROX_UEA_Troop_Reward, 100, player_faction)
		end
	end
   
   --checkpoint charlie stuff
   troop_charlie_list = {}
   
   troop_charlie01_list = {}
	troop_charlie01_list = Find_All_Objects_With_Hint("troop-charlie01")
   troop_charlie01 = troop_charlie01_list[1]
   
   troop_charlie02_list = {}
	troop_charlie02_list = Find_All_Objects_With_Hint("troop-charlie02")
   troop_charlie02 = troop_charlie02_list[1]
   
   troop_charlie03_list = {}
	troop_charlie03_list = Find_All_Objects_With_Hint("troop-charlie03")
   troop_charlie03 = troop_charlie03_list[1]
   
   troop_charlie04_list = {}
	troop_charlie04_list = Find_All_Objects_With_Hint("troop-charlie04")
   troop_charlie04 = troop_charlie04_list[1]
   
   troop_charlie05_list = {}
	troop_charlie05_list = Find_All_Objects_With_Hint("troop-charlie05")
   troop_charlie05 = troop_charlie05_list[1]
   
   troop_charlie06_list = {}
	troop_charlie06_list = Find_All_Objects_With_Hint("troop-charlie06")
   troop_charlie06 = troop_charlie06_list[1]
   if not TestValid(troop_charlie06) then
       _CustomScriptMessage("JoeLog.txt", string.format("#$#$#$#$ERROR! Define_Hints Cannot find troop_charlie06"))
   end
   
   troop_charlie07_list = {}
	troop_charlie07_list = Find_All_Objects_With_Hint("troop-charlie07")
   troop_charlie07 = troop_charlie07_list[1]
   if not TestValid(troop_charlie07) then
       _CustomScriptMessage("JoeLog.txt", string.format("#$#$#$#$ERROR! Define_Hints Cannot find troop_charlie07"))
   end
   
   troop_charlie08_list = {}
	troop_charlie08_list = Find_All_Objects_With_Hint("troop-charlie08")
   troop_charlie08 = troop_charlie08_list[1]
   if not TestValid(troop_charlie08) then
       _CustomScriptMessage("JoeLog.txt", string.format("#$#$#$#$ERROR! Define_Hints Cannot find troop_charlie08"))
   end
   
   troop_charlie_turret_list = {}
   troop_charlie_turret_list = Find_All_Objects_With_Hint("troop-charlie", "TUT01_MILITARY_TURRET_GROUND")
	counter_charlie_turrets_killed = 0
	counter_charlie_turrets = 2
   
	troop_charlie_list[1] = troop_charlie01
   troop_charlie_list[2] = troop_charlie02
   troop_charlie_list[3] = troop_charlie03
   troop_charlie_list[4] = troop_charlie04
   troop_charlie_list[5] = troop_charlie05
   troop_charlie_list[6] = troop_charlie06
   troop_charlie_list[7] = troop_charlie07
   troop_charlie_list[8] = troop_charlie08
   
   for i, troop_charlie in pairs(troop_charlie_list) do
      if TestValid(troop_charlie) then
         troop_charlie.Suspend_Locomotor(true)
         troop_charlie.Register_Signal_Handler(Callback_CharlieTroop_Killed, "OBJECT_HEALTH_AT_ZERO")
      end
   end
  
  prox_checkpoint_charlie_fleers = Find_Hint("MARKER_GENERIC_BLUE","prox-checkpoint-charlie-fleers")
   if TestValid(prox_checkpoint_charlie_fleers) then
      Register_Prox(prox_checkpoint_charlie_fleers, PROX_UEA_InRange_of_CkPtCharlie_Fleers, 100, player_faction)
   else
      _CustomScriptMessage("JoeLog.txt", string.format("#$#$#$#$ERROR! Define_Hints Cannot find prox_checkpoint_charlie"))
   end
  
  
   prox_checkpoint_charlie = Find_Hint("MARKER_GENERIC_BLUE","prox-checkpoint-charlie")
   if TestValid(prox_checkpoint_charlie) then
      Register_Prox(prox_checkpoint_charlie, PROX_UEA_InRange_of_CkPtCharlie, 100, player_faction)
   else
      _CustomScriptMessage("JoeLog.txt", string.format("#$#$#$#$ERROR! Define_Hints Cannot find prox_checkpoint_charlie"))
   end
	
	charlie_fodder_respawn = Find_Hint("MARKER_GENERIC_PURPLE","charlie-fodder-respawn")
	
   charlie_fodder_list = Find_All_Objects_With_Hint("charlie-fodder")
   counter_charlie_fodder = table.getn(charlie_fodder_list)
   counter_charlie_fodder_killed = 0
	counter_charlie_fodder_registered = 0
   for i, charlie_fodder in pairs(charlie_fodder_list) do
		if TestValid(charlie_fodder) then
			charlie_fodder.Suspend_Locomotor(true)
         
         charlie_fodder.Register_Signal_Handler(Callback_Charlie_Fodder_Killed, "OBJECT_HEALTH_AT_ZERO")
			counter_charlie_fodder_registered = counter_charlie_fodder_registered + 1
		end
	end
   
   charlie_guard_location = Find_Hint("MARKER_GENERIC_RED","charlie-guard")
   charlie_respawn_location = Find_Hint("MARKER_GENERIC_RED","charlie-respawn")
	charlie_fleer_list = Find_All_Objects_With_Hint("charlie-fleer")
	for i, charlie_fleer in pairs(charlie_fleer_list) do
		if TestValid(charlie_fleer) then
			charlie_fleer.Suspend_Locomotor(true)
			charlie_fleer.Make_Invulnerable(true)
		end
	end
   
	--making grunts ignore aircraft...
	mission_grunt_list = Find_All_Objects_Of_Type("ALIEN_GRUNT")
	for i, mission_grunt in pairs(mission_grunt_list) do
		if TestValid(mission_grunt) then
			mission_grunt.Set_Targeting_Priorities("AntiDefault_No_Aircraft")
		end
	end
	
	act02_ambient_grey_list = Find_All_Objects_With_Hint("act02-ambient")
	act02_ambient_grey_hide_spot_list = Find_All_Objects_With_Hint("act02-alien-hide-spot", "MARKER_GENERIC_YELLOW")
	
	act02_grunts_list = Find_All_Objects_With_Hint("act02-grunt", "ALIEN_GRUNT")
	
	--set the ambient_greys into wait mode...they will start their routines once player gets close
	for i, act02_ambient_grey in pairs(act02_ambient_grey_list) do
		if TestValid(act02_ambient_grey) then
         act02_ambient_grey.Set_In_Limbo(true)
		end
	end
	
	for i, act02_grunt in pairs(act02_grunts_list) do
		if TestValid(act02_grunt) then
			act02_grunt.Suspend_Locomotor(true)
		end
	end
	
	objective01_location = Find_Hint("MARKER_GENERIC_BLUE","objective01-location")
	objective01_survivors_spawn = Find_Hint("MARKER_GENERIC_RED","objective01-survivors-spawn")
	objective01_survivors_exit_goto= Find_Hint("MARKER_GENERIC_RED","objective01-survivors-exit-goto")
	smithsonian = Find_First_Object("TM01_SMITHSONIAN")
	smithsonian.Prevent_Opportunity_Fire(true) --trying to keep aliens from attacking this structure

	objective02_location = Find_Hint("MARKER_GENERIC_BLUE","objective02-location")
	objective02_survivors_spawn = Find_Hint("MARKER_GENERIC_RED","objective02-survivors-spawn")
	objective02_survivors_exit_goto= Find_Hint("MARKER_GENERIC_RED","objective02-survivors-exit-goto")
	art_gallery = Find_First_Object("TM01_NATIONAL_GALLERY_OF_ART")
	
	objective03_location = Find_Hint("MARKER_GENERIC_BLUE","objective03-location")
	
	
	objective05_location = Find_Hint("MARKER_GENERIC_BLUE","objective05-location")
	objective05_schoolchildren_spawn = Find_Hint("MARKER_GENERIC_RED","objective05-schoolchildren-spawn")
	objective05_schoolchildren_exit_goto= Find_Hint("MARKER_GENERIC_RED","objective05-schoolchildren-exit-goto")
	
	--these are the various locations the mission will spawn civs at...the intention is to force the civs to spawn in the area of the map
	--where the player is currently focused...dont want to waste civs in areas where the player has already been 
	act01_panicked_civ_spawner_list = Find_All_Objects_With_Hint("act01", "MARKER_GENERIC_PURPLE")
	act02_panicked_civ_spawner_list = Find_All_Objects_With_Hint("act02", "MARKER_GENERIC_PURPLE")
	act03_panicked_civ_spawner_list = Find_All_Objects_With_Hint("act03", "MARKER_GENERIC_PURPLE")
	act04_panicked_civ_spawner_list = Find_All_Objects_With_Hint("act04", "MARKER_GENERIC_PURPLE")
	
	obj02_action_prox_flag= Find_Hint("MARKER_GENERIC_GREEN","prox-obj02-action")--this guy now starts the two grunts acting, before the reveal
	if TestValid(obj02_action_prox_flag) then
		Register_Prox(obj02_action_prox_flag, PROX_Start_Smithsonian_Objective, 50, player_faction)
	end
	
	obj02_dialog_prox_flag= Find_Hint("MARKER_GENERIC_GREEN","prox-obj02-dialog")--this guy now starts the dialog regarding the two grunts 
	if TestValid(obj02_dialog_prox_flag) then
		Register_Prox(obj02_dialog_prox_flag, PROX_Start_Smithsonian_Dialog, 50, player_faction)
	end
	
	art_gallery_objective_prox_flag_list = Find_All_Objects_With_Hint("prox-obj03", "MARKER_GENERIC_GREEN")
	for i, art_gallery_objective_prox_flag in pairs(art_gallery_objective_prox_flag_list) do
		Register_Prox(art_gallery_objective_prox_flag, PROX_Start_ArtGallery_Objective, 100, player_faction)
	end
	
	--reaper event stuff
	captive_human_list = Find_All_Objects_With_Hint("captive")
	for i, captive_human in pairs(captive_human_list) do
		captive_human.Suspend_Locomotor(true)
	end
   
   harvest01_reaper_list  = Find_All_Objects_With_Hint("harvest01", "ALIEN_SUPERWEAPON_REAPER_TURRET")
   counter_harvest01_reaper_list = table.getn(harvest01_reaper_list)
   _CustomScriptMessage("JoeLog.txt", string.format("counter_harvest01_reaper_list =  %d", counter_harvest01_reaper_list))
   harvest01_grunt_list  = Find_All_Objects_With_Hint("harvest01", "ALIEN_GRUNT")
   counter_harvest01_grunt_list = table.getn(harvest01_grunt_list)
   _CustomScriptMessage("JoeLog.txt", string.format("counter_harvest01_grunt_list =  %d", counter_harvest01_grunt_list))
   harvest01_civilian_list  = Find_All_Objects_With_Hint("harvest01-civ")
   counter_harvest01_civilian_list = table.getn(harvest01_civilian_list)
   _CustomScriptMessage("JoeLog.txt", string.format("counter_harvest01_civilian_list =  %d", counter_harvest01_civilian_list))
   harvest_01_civ_panic_goto_list = Find_All_Objects_With_Hint("harvest01", "MARKER_GENERIC_YELLOW")
   counter_harvest_01_civ_panic_goto_list = table.getn(harvest_01_civ_panic_goto_list)
   _CustomScriptMessage("JoeLog.txt", string.format("counter_harvest_01_civ_panic_goto_list =  %d", counter_harvest_01_civ_panic_goto_list))
   
   harvest_01_respawn = Find_Hint("MARKER_GENERIC_RED","harvest01-respawn")
   
   for i, harvest01_reaper in pairs(harvest01_reaper_list) do
      if TestValid(harvest01_reaper) then
		   harvest01_reaper.Suspend_Locomotor(true)
			harvest01_reaper.Prevent_All_Fire(true)
         harvest01_reaper.Register_Signal_Handler(Callback_GalleryReaper_Damaged, "OBJECT_DAMAGED")
         harvest01_reaper.Register_Signal_Handler(Callback_GalleryReaper_Destroyed, "OBJECT_HEALTH_AT_ZERO")
      end
	end
   
   for i, civ in pairs(harvest01_civilian_list) do
      if TestValid(civ) then
			civ.Make_Invulnerable(true)
			civ.Set_Cannot_Be_Killed(true)
         civ.Register_Signal_Handler(Callback_Harvest01_Civ_Killed, "OBJECT_HEALTH_AT_ZERO")
      end
	end
	
	starting_reaper_list = Find_All_Objects_Of_Type("ALIEN_SUPERWEAPON_REAPER_TURRET")
	for i, starting_reaper in pairs(starting_reaper_list) do
		if TestValid(starting_reaper) then
			starting_reaper.Activate_Ability("Reaper_Auto_Gather_Resources", false)
		end
	end
   
   --saucer encounter stuff
   saucer01 = Find_Hint("MOV_TAKEOFF_LARGESAUCER","saucer01")
   saucer01_grey_list  = Find_All_Objects_With_Hint("saucer01", "ALIEN_SCIENCE_GREY_INDIVIDUAL")
   saucer01_grey_goto_list  = Find_All_Objects_With_Hint("saucer01", "MARKER_GENERIC_BLACK")
   saucer01_entry = Find_Hint("MARKER_GENERIC_RED","saucer01")
   
   counter_saucer01_greys = table.getn(saucer01_grey_list)

   counter_saucer01_greys_killed = 0
   bool_saucer01_killed = false
   
   thread_id_saucer01_grey_tweak_orders = {}
   
   if TestValid(saucer01) then
      saucer01.Play_Animation("Anim_Cinematic", true, 0)
      Create_Thread("Delete_Saucer_After_Time")
   end
   
   saucer_prox_list = Find_All_Objects_With_Hint("prox-saucer")
	
	for i, saucer_prox in pairs(saucer_prox_list) do
		if TestValid(saucer_prox) then
			Register_Prox(saucer_prox, PROX_Reveal_Saucer, 125, player_faction)
		end
	end
   
	--definitions for the first group of papaya reinforcements
   papaya_tank_list = {}
   
	papaya01_list = Find_All_Objects_With_Hint("papaya01")
	papaya01 = papaya01_list[1]
   papaya_tank_list[1] = papaya01 -- tracking tanks to let player get new ones if lost
   
	papaya02_list = Find_All_Objects_With_Hint("papaya02")
	papaya02 = papaya02_list[1]
   papaya_tank_list[2] = papaya02 -- tracking tanks to let player get new ones if lost
   
	papaya05_list = Find_All_Objects_With_Hint("papaya05")
	papaya05 = papaya05_list[1]
	--this is woolard, he does not get replaced
   sgt_woolard = papaya05 
   
	papaya06_list = Find_All_Objects_With_Hint("papaya06")
	papaya06 = papaya06_list[1]
   papaya_tank_list[3] = papaya06 -- tracking tanks to let player get new ones if lost
   
	papaya08_list = Find_All_Objects_With_Hint("papaya08")
	papaya08 = papaya08_list[1]
   papaya_tank_list[4] = papaya08 -- tracking tanks to let player get new ones if lost
   
   --put check-point-charlie death monitors on the tanks
   for i, papaya_tank in pairs(papaya_tank_list) do
		if TestValid(papaya_tank) then
			papaya_tank.Register_Signal_Handler(Callback_CharlieTroop_Killed, "OBJECT_HEALTH_AT_ZERO")
		end
	end
	
	papaya01_spawn = Find_Hint("MARKER_GENERIC_RED","papaya01-spawn")
	papaya02_spawn = Find_Hint("MARKER_GENERIC_RED","papaya02-spawn")
	papaya05_spawn = Find_Hint("MARKER_GENERIC_RED","papaya05-spawn")
	papaya06_spawn = Find_Hint("MARKER_GENERIC_RED","papaya06-spawn")
	papaya08_spawn = Find_Hint("MARKER_GENERIC_RED","papaya08-spawn")

	papaya_reinforcement_list[1] = papaya01
	papaya_reinforcement_list[2] = papaya02
	papaya_reinforcement_list[3] = papaya05
	papaya_reinforcement_list[4] = papaya06
	papaya_reinforcement_list[5] = papaya08
	
	for i, papaya_reinforcement in pairs(papaya_reinforcement_list) do
		if TestValid(papaya_reinforcement) then
			papaya_reinforcement.Set_Object_Context_ID("hide_me")
		end
	end
	
	--definitions for the second group of papaya reinforcements
	papaya01a_list = Find_All_Objects_With_Hint("papaya01a")
	papaya01a = papaya01a_list[1]
	papaya02a_list = Find_All_Objects_With_Hint("papaya02a")
	papaya02a = papaya02a_list[1]
	papaya05a_list = Find_All_Objects_With_Hint("papaya05a")
	papaya05a = papaya05a_list[1]
	papaya06a_list = Find_All_Objects_With_Hint("papaya06a")
	papaya06a = papaya06a_list[1]
	papaya08a_list = Find_All_Objects_With_Hint("papaya08a")
	papaya08a = papaya08a_list[1]
	
	papaya01a_spawn = Find_Hint("MARKER_GENERIC_RED","papaya01a-spawn")
	papaya02a_spawn = Find_Hint("MARKER_GENERIC_RED","papaya02a-spawn")
	papaya05a_spawn = Find_Hint("MARKER_GENERIC_RED","papaya05a-spawn")
	papaya06a_spawn = Find_Hint("MARKER_GENERIC_RED","papaya06a-spawn")
	papaya08a_spawn = Find_Hint("MARKER_GENERIC_RED","papaya08a-spawn")

	papaya02_goto = Find_Hint("MARKER_GENERIC_RED","papaya02-goto")

	papaya_reinforcement_list[6] = papaya01a
	papaya_reinforcement_list[7] = papaya02a
	papaya_reinforcement_list[8] = papaya05a
	papaya_reinforcement_list[9] = papaya06a
	papaya_reinforcement_list[10] = papaya08a
   
	--flyovers
	--hide all the preplaced flyover anim objects
	cinematic_foofighters = Find_All_Objects_Of_Type("MOV_FLYOVER_FOOFIGHTER")
	for i, foofighter in pairs(cinematic_foofighters) do
		if TestValid(foofighter) then
			foofighter.Hide(true)
		end
	end

	opening_cine_foofighters = Find_All_Objects_With_Hint("cinefoo-01", "MOV_FLYOVER_FOOFIGHTER")
	--post_reapers_foofighters = Find_All_Objects_With_Hint("post-reaper", "MOV_FLYOVER_FOOFIGHTER")
	
	post_reapers_foofighters = Find_All_Objects_With_Hint("post-reaper")
	post_reapers02_foofighters = Find_All_Objects_With_Hint("post-reaper02", "MOV_FLYOVER_FOOFIGHTER")
	
	for i, unit in pairs(post_reapers_foofighters) do
		if TestValid(unit) then
			unit.Hide(true)
		end
	end
	
	for i, unit in pairs(post_reapers02_foofighters) do
		if TestValid(unit) then
			unit.Hide(true)
		end
	end
	
	
	
	starting_flyover = Find_Hint("MOV_FLYOVER_LARGESAUCER","starting-flyover")
	starting_flyover.Hide(true)
	
	opening_foo01 = Find_Hint("MOV_FLYOVER_FOOFIGHTER","opening-foo01")
	opening_foo02 = Find_Hint("MOV_FLYOVER_FOOFIGHTER","opening-foo02")
	opening_foo03 = Find_Hint("MOV_FLYOVER_FOOFIGHTER","opening-foo03")
	
	act01_foofighter_flyover_list = Find_All_Objects_With_Hint("act01", "MOV_FLYOVER_FOOFIGHTER")
	act02_foofighter_flyover_list = Find_All_Objects_With_Hint("act02", "MOV_FLYOVER_FOOFIGHTER")
	act03_foofighter_flyover_list = Find_All_Objects_With_Hint("act03", "MOV_FLYOVER_FOOFIGHTER")
	act04_foofighter_flyover_list = Find_All_Objects_With_Hint("act04", "MOV_FLYOVER_FOOFIGHTER")
	
	--patrol points for the walker once it gets spawned
	walker_goto01 = Find_Hint("MARKER_WAYPATH","walker-goto01")
	walker_goto02 = Find_Hint("MARKER_WAYPATH","walker-goto02")
	walker_goto03 = Find_Hint("MARKER_WAYPATH","walker-goto03")
	
	_CustomScriptMessage("JoeLog.txt", string.format("#*#*#*NOTICE: Define_Hints: End!"))
end

function Delete_Saucer_After_Time()
	Sleep(10)
	saucer01.Hide(true)
end

function Define_Explosion_Hints()
	--list_artillery_flags = Find_All_Objects_With_Hint("artillery", "MARKER_GENERIC_BLACK")
	list_artillery_flags_act01 = Find_All_Objects_With_Hint("artillery-act01", "MARKER_GENERIC_BLACK")
	list_artillery_flags_act02 = Find_All_Objects_With_Hint("artillery-act02", "MARKER_GENERIC_BLACK")
	list_artillery_flags_act03 = Find_All_Objects_With_Hint("artillery-act03", "MARKER_GENERIC_BLACK")
	
	
	if counter_list_artillery_flags == 0 then
		MessageBox("counter_list_artillery_flags == 0")
	end
	
	--counter_type_list_explosion_sfx = table.getn(type_list_explosion_sfx)
	
	--if counter_type_list_explosion_sfx == 0 then
	--	MessageBox("counter_type_list_explosion_sfx == 0")
	--end
	
	type_explosion_marker = Find_Object_Type("Marker_SFX_Tut01_Misc_Explosions")
end

function Thread_Ambient_Explsions()
	_CustomScriptMessage("JoeLog.txt", string.format("Thread_Ambient_Explsions Start!!"))
	--Play_SFX_Event("SFX_ALIEN_PARANOIA_LOOP")
	
	
	while true do
		Sleep(GameRandom(0, 3))
		
		counter_list_artillery_flags = table.getn(list_artillery_flags)
		local flag_number = GameRandom( 1, counter_list_artillery_flags )
		
		if TestValid(list_artillery_flags[flag_number]) then
			_CustomScriptMessage("JoeLog.txt", string.format("explosion_marker creation?"))
			explosion_marker = Create_Generic_Object(type_explosion_marker, list_artillery_flags[flag_number], list_artillery_flags[flag_number].Get_Owner())
		else
			MessageBox("ERROR! not TestValid(list_artillery_flags[flag_number]) ")
		end
		
		Sleep(3)
		
		if TestValid(explosion_marker) then
			_CustomScriptMessage("JoeLog.txt", string.format("explosion_marker creation?"))
			explosion_marker.Despawn()
		else
			_CustomScriptMessage("JoeLog.txt", string.format("ERROR! not TestValid(explosion_marker)"))
			MessageBox("ERROR! not TestValid(explosion_marker) ")
		end
		
	end
end



function Force_Victory(player)
	uea.Reset_Story_Locks()
	aliens.Reset_Story_Locks()

	if player == player_faction then
		Fade_Out_Music() 
		
		if TestValid(mirabel) then
			mirabel.Set_Object_Context_ID("Tut01_StoryCampaign")
		else
			_CustomScriptMessage("JoeLog.txt", string.format("#*#*#*#*#*#*#*#*#WARNING!!*#*#Novus_Tut01: Force_Victory: cannot find Mirabel!"))
		end

		-- ***** ACHIEVEMENT_AWARD *****
		if (Player_Earned_Offline_Achievements()) then
			--Supply Novus as the player here - the parameter is only used to determine which version of the *_Tactical_Mission_Over
			--function we call, and as with the no achievements case below the Novus campaign is the one we want to move forward.
			Create_Thread("Show_Earned_Achievements_Thread", {Get_Game_Mode_GUI_Scene(), novus})
		else
			-- Inform the campaign script of our victory.
			global_script.Call_Function("Novus_Tactical_Mission_Over", true) -- true == player wins/false == player loses
			--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
			Quit_Game_Now(player, false, true, false)
		end
		-- ***** ACHIEVEMENT_AWARD *****
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
	Process_Tactical_Mission_Over(map[2])
end
-- ***** ACHIEVEMENT_AWARD *****

-- ***** HINT EVENT CALLBACKS *****
-- JOE: Example activation callback implementation.
function Hint_Activation_Callback(hint_id)
	_CustomScriptMessage("JoeLog.txt", string.format("JOE HINT::::  Hint activated!!: " .. tostring(hint_id)))
end

-- JOE: Example dismissal callback implementation.
function Hint_Dismissal_Callback(hint_id)
	_CustomScriptMessage("JoeLog.txt", string.format("JOE HINT::::  Hint dismissed!!: " .. tostring(hint_id)))
	
	if hint_id == HINT_SYSTEM_HINT_SYSTEM then
		_CustomScriptMessage("JoeLog.txt", string.format("JOE HINT:::: HINT_SYSTEM_HINT_SYSTEM  dismissed!! Thread_Unit_Selection_Hints" ))
		
		--Create_Thread("Thread_Objective_Hints") xxx
		Create_Thread("Thread_Unit_Selection_Hints")
		
	elseif hint_id == HINT_SYSTEM_OBJECTIVES then	
		--Create_Thread("Thread_Unit_Selection_Hints")
		
	--elseif hint_id == HINT_SYSTEM_UNIT_SELECTION then
		--_CustomScriptMessage("JoeLog.txt", string.format("JOE HINT:::: HINT_SYSTEM_UNIT_SELECTION  dismissed!! Thread_Unit_Movement_Hints" ))
		--Create_Thread("Thread_Unit_Movement_Hints")
	elseif hint_id == HINT_SYSTEM_MOVING then
		_CustomScriptMessage("JoeLog.txt", string.format("JOE HINT:::: HINT_SYSTEM_MOVING  dismissed!! Thread_Unit_Attacking_Hints" ))
		-- Create_Thread("Thread_Unit_Attacking_Hints")
	elseif hint_id == HINT_SYSTEM_ATTACKING then
		--_CustomScriptMessage("JoeLog.txt", string.format("JOE HINT:::: HINT_SYSTEM_ATTACKING  dismissed!!" ))
		--Create_Thread("Thread_Unit_Selection_Hints_Advanced")
		
		
		if bool_mission_started == false then-- recycling these starting hints if players dont move out
			_CustomScriptMessage("JoeLog.txt", string.format("JOE HINT:::: HINT_SYSTEM_ATTACKING  dismissed!! Thread_Unit_Selection_Hints_Pause" ))
			Create_Thread("Thread_Unit_Selection_Hints_Pause")
		end
		
		
	--elseif hint_id == HINT_SYSTEM_MULTIPLE_UNITS then	
	--	_CustomScriptMessage("JoeLog.txt", string.format("JOE HINT:::: HINT_SYSTEM_MULTIPLE_UNITS  dismissed!! Thread_Unit_Movement_Hints_Advanced" ))
	--	Create_Thread("Thread_Unit_Movement_Hints_Advanced")
	--elseif hint_id == HINT_SYSTEM_FORCE_MARCH then
	--	_CustomScriptMessage("JoeLog.txt", string.format("JOE HINT:::: HINT_SYSTEM_FORCE_MARCH  dismissed!! Thread_Unit_Attacking_Hints_Advanced" ))
	--	Create_Thread("Thread_Unit_Attacking_Hints_Advanced")
	end
end
-- ***** HINT EVENT CALLBACKS *****

--function Thread_Objective_Hints()
--	Sleep(1)
--	Add_Independent_Hint(HINT_SYSTEM_OBJECTIVES)

	--Add_Independent_Hint(HINT_SYSTEM_SIMILAR_UNITS) -- still not using...should probably sneak in somewhere
--end

function Thread_Unit_Selection_Hints_Pause()	
	Sleep(10)
	if bool_mission_started == false then 
		Create_Thread("Thread_Unit_Selection_Hints")
		_CustomScriptMessage("JoeLog.txt", string.format("Thread_Unit_Selection_Hints_Pause timeout!! Thread_Unit_Selection_Hints" ))
	end
	
end

function Thread_Unit_Selection_Hints()
	if bool_mission_started == false then 
		Sleep(0.5)
		Add_Independent_Hint(HINT_SYSTEM_UNIT_SELECTION)
		Sleep(0.5)
		Add_Independent_Hint(HINT_SYSTEM_MOVING)
		Sleep(0.5)
		Add_Independent_Hint(HINT_SYSTEM_ATTACKING)
		
		
	end
	
	while bool_mission_started == false do
		Sleep(0.5)
		
		if (HINT_SYSTEM_UNIT_SELECTION == nil) and (HINT_SYSTEM_MOVING == nil) and (HINT_SYSTEM_ATTACKING == nil) then
			--player has dismissed the hints....kill this thread
			_CustomScriptMessage("JoeLog.txt", string.format("(Thread_Unit_Selection_Hints: player has dismissed the hints....kill this thread " ))
			return
		end
	end
	
	
	--player has started the mission, these hints are now redundant...go away
	if (HINT_SYSTEM_UNIT_SELECTION ~= nil) then
		Remove_Independent_Hint(HINT_SYSTEM_UNIT_SELECTION)
	end
	
	if (HINT_SYSTEM_MOVING ~= nil) then
		Remove_Independent_Hint(HINT_SYSTEM_MOVING)
	end
	
	if (HINT_SYSTEM_ATTACKING ~= nil) then
		Remove_Independent_Hint(HINT_SYSTEM_ATTACKING)
	end

	--Add_Independent_Hint(HINT_SYSTEM_SIMILAR_UNITS) -- still not using...should probably sneak in somewhere
end

--function Thread_Unit_Movement_Hints()
	--Sleep(3)
	--Add_Independent_Hint(HINT_SYSTEM_MOVING)

--end

--function Thread_Unit_Attacking_Hints()
	--Sleep(3)
	--Add_Independent_Hint(HINT_SYSTEM_ATTACKING)

   --Add_Independent_Hint(HINT_SYSTEM_FORCE_FIRE) -- this hint is actually untrue
--end

--function Thread_Unit_Selection_Hints_Advanced()
--	while (bool_mission_started == false) do
--		Sleep(5)
--	end
		
--	Add_Independent_Hint(HINT_SYSTEM_MULTIPLE_UNITS)
	--Sleep(1)
	--Add_Independent_Hint(HINT_SYSTEM_FORCE_MARCH)
	--Sleep(1)
	--Add_Independent_Hint(HINT_SYSTEM_ATTACKING_MULTIPLE)
--end

--function Thread_Unit_Movement_Hints_Advanced()
	--Sleep(3)
	--Add_Independent_Hint(HINT_SYSTEM_FORCE_MARCH)
--end

--function Thread_Unit_Attacking_Hints_Advanced()
	--Sleep(3)
	--Add_Independent_Hint(HINT_SYSTEM_ATTACKING_MULTIPLE)
--end


-- ##########################################################################################
-- ##################FLYOVER(S) CONTROLLER AND SCRIPTS###########################################
-- ##########################################################################################
function Thread_Foofighter_Flyovers()
	Sleep(5)
	while (true) do
		--now pick a random flyover to play
		local flyover_roll = GameRandom.Free_Random(1, flyover_max)
		
		--this determines if the chosen flyover is already playing its anim, if it is it rolls again
		while cinematic_foofighters_in_use[cinematic_foofighters[flyover_roll]] do
			flyover_roll = GameRandom.Free_Random(1, flyover_max)
			Sleep(3)
		end
		
		Create_Thread("Thread_Flyover_Animation", cinematic_foofighters[flyover_roll])
		
		Sleep(15)
	end
end

function Thread_Flyover_Animation(foofighter)
	cinematic_foofighters_in_use[foofighter] = true
	foofighter.Hide(false)
	BlockOnCommand(foofighter.Play_Animation("Anim_Cinematic", false, 0))
	foofighter.Hide(true)
	cinematic_foofighters_in_use[foofighter] = false
end

function Thread_Dialog_Controller(conversation)
	if not bool_mission_failed and not bool_mission_won then
		if conversation == dialog_mission_intro then
			if not bool_testing then
			
				if not bool_mission_failed and not bool_mission_won then
					Queue_Talking_Head(pip_comm_officer, "MIL_TUT01_SCENE05_05")--Colonel Moore, we're linking you to the Pentagon's battlefield intelligence system. Click on the question mark on the right of your HUD if you need assistance.
				end
				Sleep(5)
				
				--Create_Thread("Thread_LargeSaucer_Flyover", starting_flyover)
				-- ***** HINT SYSTEM *****
				-- Set the scene down here so we're sure of getting the right scene...
				Set_Hint_System_Visible(true)
				Add_Independent_Hint(HINT_SYSTEM_HINT_SYSTEM)
				-- ***** HINT SYSTEM *****
				if not bool_mission_failed and not bool_mission_won then
					local block01a = Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE05_06") --Roger, comm. (I'm sure that cost a few billion.)
				end
				if not bool_mission_failed and not bool_mission_won then
					Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE06_01") --Alright men, now keep it tight! Let's go get our planet back!
				end
				--Queue_Speech_Event("MIL_TUT01_SCENE05_04")--Yes sir.
				
				BlockOnCommand(block01a)

				bool_opening_dialog_finished = true
				
			end
			
		elseif conversation == dialog_first_contact then
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE06_02") --Time for a close encounter! 
			end
			
			
		
		elseif conversation == dialog_first_contact_greys_retreating then
			Sleep(1)
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(col_moore, "MIL_TUT01_SCENE02_52") --Col Moore (MOO): Where are they runnin' off to? [ Careful ladies, this smells like a trap.]
			end
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE08_20") --Careful, this feels like a trap.
			end
		elseif conversation == dialog_its_a_trap then
		  -- make players units stop!!
		  
			current_player_list = Find_All_Objects_Of_Type(player_faction)
			for i, obj in pairs(current_player_list) do
				if TestValid(obj) then
					--obj.Stop()
					
					
					
					Full_Speed_Move(obj, obj.Get_Position())
				end
			end
			
			Sleep(1)
			
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE06_03") --Maybe it's time for a grenade.
			end
			
			if TestValid(first_tanker) then      
				Queue_Talking_Head("Mi_marine_pip_head.alo", "MIL_TUT01_SCENE02_27") --Marine (MAR): Target that fuel truck!
			end
			
		elseif conversation == dialog_player_destroys_fueltruck then
		
			Sleep(2)
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE12_01") --Col Moore:: Well there's some hope: if they can burn, they can die.
			end

		elseif conversation == dialog_first_civvie_encounter then
			
			Sleep(2)
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE06_05") --We got civilians in trouble! Focus your fire on the big guys! 
			end
			
			--cutting for now...
			--Create_Thread("Thread_LargeSaucer_Flyover", starting_flyover)
			
			Sleep(5)
			
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_comm_officer, "MIL_TUT01_SCENE15_02")--Be advised Colonel, the President's losing a lot of blood.
			end
			if not bool_mission_failed and not bool_mission_won then
				local blocking_dialog = Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE08_05") --I know I know! We’re moving as fast as we can!
				BlockOnCommand(blocking_dialog)
			end
			
			
			
			Sleep(15)
			
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_comm_officer, "MIL_TUT01_SCENE20_03") --Colonel, be on the lookout for Charlie squad pinned down in your area. They're taking heavy fire.
			end
		elseif conversation == dialog_approaching_check_point_charlie then	
			
			Sleep(5)
			Play_Music("Music_Tut01_Act02")

		 elseif conversation == dialog_at_check_point_charlie then	
-- 			if not bool_mission_failed and not bool_mission_won then
-- 				Queue_Talking_Head("Mi_marine_pip_head.alo", "MIL_TUT01_SCENE02_43") --Marine (MAR): Sir!  Over there!
-- 			end
			
			--Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE07_01") --There's too many of them! We need to find some cover. Squad, garrison in that building! 
		
		elseif conversation == dialog_check_point_charlie_secured then	

			Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT01_OBJECTIVE_C_COMPLETE"} )--Objective Complete: Help defend the checkpoint.
			Objective_Complete(tut01_objective02a)
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_marine, "MIL_TUT01_SCENE14_01") --I never thought I'd be so happy to see a colonel! Thank you, sir!
			end
			
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE14_02") --Save it 'til we're through this mess. 
			end
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE14_03") --Charlie squad, you're with me! We've got a President to save!
			end
	
			if fow_checkpoint_charlie ~= nil then
				fow_checkpoint_charlie.Undo_Reveal()
			end
			
			for i, troop_charlie in pairs(troop_charlie_list) do
				if TestValid(troop_charlie) then
					troop_charlie.Change_Owner(player_faction)
				end
			end
			
			for i, troop_charlie_turret in pairs(troop_charlie_turret_list) do
				if TestValid(troop_charlie_turret) then
					troop_charlie_turret.Change_Owner(player_faction)
				end
			end
			
		elseif conversation == dialog_intro_choppers then	
			--jdg old dialog playing here...cutting for now 4/17/07

			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE07_04") --Comm, this mission is going south real quick! Do we have any air-support left?
			end
			if not bool_mission_failed and not bool_mission_won then
				Queue_Speech_Event("MIL_TUT01_SCENE07_05") --Roger that, Colonel, air cavalry's got your back!
				--Queue_Talking_Head(pip_chopper, "MIL_TUT01_SCENE07_05") --Roger that, Colonel, air cavalry's got your back!
				
			end
			
			bool_okay_for_choppers_to_use_rockets = true
			chopper_faction.Lock_Unit_Ability("Military_Apache", "Unit_Ability_Apache_Rocket_Barrage", false, STORY)
			
		elseif conversation == dialog_goodbye_choppers then
			Sleep(3)	
			Create_Thread("Thread_Gallery_FooFighter_Orders")
			Sleep(3)	
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_comm_officer, "MIL_TUT01_SCENE07_07")--Blackhawks! Be advised we show incoming bogeys on your position! Break break break!
			end

		elseif conversation == dialog_first_chopper_dead then
			if not bool_mission_failed and not bool_mission_won then
				Queue_Speech_Event("MIL_TUT01_SCENE08_22") --
				--Queue_Talking_Head(pip_chopper, "MIL_TUT01_SCENE08_22") --Holy- where did those things come from?!
			end
		
		elseif conversation == dialog_intro_reapers then
			Play_Music("Music_Tut01_Act03")
			if not bool_mission_failed and not bool_mission_won then
				blockx = Queue_Talking_Head("Mi_marine_pip_head.alo", "MIL_TUT01_SCENE02_39") --CMarine (MAR): What the hell are those things?

				Queue_Talking_Head("Mi_marine_pip_head.alo", "MIL_TUT01_SCENE02_33") --Marine (MAR): Oh god, they're sucking up the civvies!
				BlockOnCommand(blockx)
			end
			
			Create_Thread("Thread_Papaya_Arrives")
			
			while not bool_papaya_on_board do
				Sleep(1)
			end
	
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_marine, "MIL_TUT01_SCENE08_01") --We're not making a dent! Is there anything a bullet can kill?
			end
			if not bool_mission_failed and not bool_mission_won then
				BlockOnCommand(Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE08_02"))--Stay frosty! I told you this was liable to get weird. Comm, are we ever going to see Sgt. Woolard this year?
			end
			if not bool_mission_failed and not bool_mission_won then
				--Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {"TEXT_SP_MISSION_TUT01_REINFORCEMENT_NOTICE"})--Notice: Reinforcements have arrived.
				
				Queue_Talking_Head(pip_woolard, "MIL_TUT01_SCENE08_03") --Right here you ornery coot. Give us your orders and make them hurt.
			end
			
			for i, papaya_reinforcement in pairs(papaya_reinforcement_list) do
				if TestValid(papaya_reinforcement) then
					papaya_reinforcement.Change_Owner(player_faction)
				end
			end
			
			Create_Thread("Thread_Papaya_Orders")
			
			if TestValid(sgt_woolard) then
				--Add_Radar_Blip(sgt_woolard, "Default_Beacon_Placement", "blip_papaya01") -- puts blip on Woolard
				Raise_Game_Event("Reinforcements_Arrived", player_faction, sgt_woolard.Get_Position())
			end
			
			Sleep(2)
			
			Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE04_15")--Focus the tanks against those machines!  Take em down!


		elseif conversation == dialog_tanks_are_good then
			Sleep(2)
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_comm_officer, "MIL_TUT01_SCENE15_03")--Colonel, the doctors say the President's vital signs are crashing.
			end
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE15_06") --Col Moore: Hang in there, we're not far.
			end
			
			
			--starting massive foo fighter flyover event here.
			for i, foofighter in pairs(post_reapers_foofighters) do
				if TestValid(foofighter) then
					Create_Thread("Thread_StartingFoo_Flyover", foofighter)
				end
			end
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE19_01") --Comm, what happened to the Air Force?
			end
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_comm_officer, "MIL_TUT01_SCENE19_02")--Air Combat Command reports most assets have been destroyed. They never stood a chance against those ships.
			end
			
			Sleep(2)
			
			for i, foofighter in pairs(post_reapers02_foofighters) do
				if TestValid(foofighter) then
					Create_Thread("Thread_StartingFoo_Flyover", foofighter)
				end
			end

		
		elseif conversation == dialog_introduce_brutes then
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_marine, "MIL_TUT01_SCENE08_15") --Hostiles on the roof!
			end
			if not bool_mission_failed and not bool_mission_won then
				local blocking_dialog = Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE20_01") --I don't even want to know what those things are. The President's our priority.
			
				BlockOnCommand(blocking_dialog)
			
				Create_Thread("Thread_Schoolchildren_Brute_Attacked")
			end
			Sleep(2)
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE20_02") --Scratch that - bring them down!
			end
			
		elseif conversation == dialog_final_guard_group then
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE09_01") --You know the drill by now - take 'em down!
			end
		
		elseif conversation == dialog_approaching_the_capitol then
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE09_03") --Comm, we're knocking on the door. Let the President's people know we're here.
			end
			
		elseif conversation == dialog_rooftop_chatter then
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE17_01") --Col Moore: Comm, where are these things coming from?
			end
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_comm_officer, "MIL_TUT01_SCENE17_02")--Comm: We have reports all over the globe - Russia's already surrendered, the Chinese are taking huge losses, and nobody's heard anything out of South America.
			end
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE17_03") --Col Moore: The whole continent?
			end
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_comm_officer, "MIL_TUT01_SCENE17_04")--Comm: We're not even sure it's still there anymore, sir.
			end
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE17_05") --Col Moore: Aw hell.
			end

		elseif conversation == dialog_killing_brutes then

			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_comm_officer, "MIL_TUT01_SCENE15_04")--Comm: Colonel Moore, the President's slipping into a coma. You have to hurry.
			end
			if not bool_mission_failed and not bool_mission_won then
				Queue_Talking_Head(pip_col_moore, "MIL_TUT01_SCENE15_07") --Col Moore: Comm, we're in the thick of it right now. Hold tight.
			end

		end
	end
end

function Post_Load_Callback()
	Movie_Commands_Post_Load_Callback()
end
