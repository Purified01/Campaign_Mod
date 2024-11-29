
require("PGDebug")
require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")
require("PGSpawnUnits")
require("PGMoveUnits")
require("RetryMission")
require("PGColors")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------


function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	Define_State("State_Init", State_Init)

	-- Factions
	neutral = Find_Player("Neutral")
	civilian = Find_Player("Civilian")
	military = Find_Player("Military")
	N = Find_Player("Novus")
	aliens = Find_Player("Alien")
	H = Find_Player("Alien_ZM06_KamalRex")
	M = Find_Player("Masari")

	-- Variables
	mission_success = false
	mission_failure = false
	wave_timer = 30
    total_waves = 30

	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")

	-- infantry
	ohm = "NOVUS_ROBOTIC_INFANTRY"
	blade = "NOVUS_REFLEX_TROOPER"
	hacker = "NOVUS_HACKER"
	disc = "MASARI_DISCIPLE"
	seer = "MASARI_SEER"
    grunt = "ALIEN_GRUNT"
    lost = "ALIEN_LOST_ONE"
	brute = "ALIEN_BRUTE"
	-- vehicles
    var = "NOVUS_VARIANT"
    amtank = "NOVUS_ANTIMATTER_TANK"
	amp = "NOVUS_AMPLIFIER"
	fi = "NOVUS_FIELD_INVERTER"
	fig = "MASARI_FIGMENT"
    senty = "MASARI_SENTRY"
	conq = "MASARI_ENFORCER"
	pb = "MASARI_PEACEBRINGER"
	tank = "ALIEN_RECON_TANK"
	def = "ALIEN_DEFILER"
	-- air
	corr = "NOVUS_CORRUPTOR"
	dervish = "NOVUS_DERVISH_JET"
	inqui = "MASARI_SEEKER"
	sl = "MASARI_SKYLORD"
	mono = "ALIEN_CYLINDER"
	saucer = "ALIEN_FOO_CORE"
	transport = "ALIEN_AIR_INVASION_TRANSPORT_ORLOK"
	-- heroes
	mira = "NOVUS_HERO_MECH"
	founder = "NOVUS_HERO_FOUNDER"
	vertigo = "NOVUS_HERO_VERTIGO"
	orlok = "ALIEN_HERO_ORLOK"
	kamal = "ALIEN_HERO_KAMAL_REX"
	nufai = "ALIEN_HERO_NUFAI"
	charos = "MASARI_HERO_CHAROS"
	alatea = "MASARI_HERO_ALATEA"
	zessus = "MASARI_HERO_ZESSUS"
	-- walkers
	weak_hab = "MM07_ALIEN_HABITAT_WALKER_LOSTONES"
	med_hab = "NM07_CUSTOM_HABITAT_WALKER"
	strong_hab = "HM06_KAMAL_HABITAT_WALKER"
	weak_asmb = "MM07_ALIEN_ASSEMBLY_WALKER_PHASETANKS"
	med_asmb = "NM07_CUSTOM_ASSEMBLY_WALKER"
	strong_asmb = "HM06_KAMAL_ASSEMBLY_WALKER"
	weak_sci = "MM07_ALIEN_WALKER_SCIENCE_MAGNETEER"
	med_sci = "MM07_ALIEN_WALKER_SCIENCE_RADIATIONWAKER"
	strong_sci = "HM06_KAMAL_SCIENCE_WALKER"
	-- hierarchy infantry platoons
    H_I_1 = genUnits({grunt, lost}, {8, 6})
    H_I_2 = genUnits({grunt, lost, brute}, {12, 8, 2})
    H_I_3 = genUnits({grunt, lost, brute, kamal}, {12, 8, 4, 1})
    H_I_4 = genUnits({grunt, brute, nufai}, {20, 6, 2})
    H_I_5 = genUnits({grunt, lost, brute, nufai, kamal}, {20, 20, 8, 2, 2})
	-- hierarchy vehicle platoons
	H_V_1 = genUnits({def, tank}, {4, 2})
	H_V_2 = genUnits({def, tank}, {6, 4})
	H_V_3 = genUnits({def, tank}, {8, 6})
	H_V_4 = genUnits({def, tank, orlok}, {8, 10, 2})
	H_V_5 = genUnits({def, tank, orlok}, {10, 14, 4})
	-- hierarchy air platoons
	H_A_1 = genUnits({mono, saucer}, {2, 6})
	H_A_2 = genUnits({saucer, transport}, {10, 2})
	H_A_3 = genUnits({saucer, transport}, {15, 3})
	H_A_4 = genUnits({saucer, transport}, {25, 5})
	H_A_5 = genUnits({saucer, transport}, {30, 10})
	-- novus infantry platoons
    N_I_1 = genUnits({ohm}, {12})
    N_I_2 = genUnits({ohm, blade}, {6, 4})
    N_I_3 = genUnits({blade, hacker}, {4, 2})
    N_I_4 = genUnits({blade, hacker, founder}, {6, 6, 2})
    N_I_5 = genUnits({blade, hacker, mira}, {8, 4, 4})
	-- novus vehicle platoons
    N_V_1 = genUnits({var}, {8})
    N_V_2 = genUnits({var, amtank}, {6, 4})
    N_V_3 = genUnits({var, amtank, fi}, {4, 8, 2})
    N_V_4 = genUnits({var, amtank, fi, amp}, {19, 8, 4, 2})
    N_V_5 = genUnits({amtank, fi, amp, mira}, {10, 6, 4, 2})
	-- novus air platoons
    N_A_1 = genUnits({corr}, {4})
    N_A_2 = genUnits({corr, dervish}, {4, 4})
    N_A_3 = genUnits({corr, dervish}, {6, 8})
    N_A_4 = genUnits({corr, dervish, vertigo}, {8, 10, 2})
    N_A_5 = genUnits({corr, dervish, vertigo}, {4, 10, 4})
	-- masari infantry platoons
    M_I_1 = genUnits({disc}, {6})
    M_I_2 = genUnits({disc, seer}, {10, 2})
    M_I_3 = genUnits({disc, seer, charos}, {14, 2, 1})
    M_I_4 = genUnits({disc, zessus}, {20, 2})
    M_I_5 = genUnits({disc, charos, zessus}, {24, 6, 2})
	-- masari vehicle platoons
    M_V_1 = genUnits({senty, fig}, {4, 2})
    M_V_2 = genUnits({senty, fig, conq}, {6, 4, 4})
    M_V_3 = genUnits({fig, conq, pb}, {4, 6, 2})
    M_V_4 = genUnits({conq, pb, alatea}, {10, 6, 1})
    M_V_5 = genUnits({conq, pb, alatea}, {16, 8, 2})
	-- masari air platoons
    M_A_1 = genUnits({inqui}, {6})
    M_A_2 = genUnits({inqui, sl}, {8, 1})
    M_A_3 = genUnits({inqui, sl}, {12, 2})
    M_A_4 = genUnits({inqui, sl}, {18, 3})
    M_A_5 = genUnits({inqui, sl}, {20, 5})
	-- walker platoons
	W_H_W = genUnits({weak_hab}, {1})
	W_H_M = genUnits({med_hab}, {1})
	W_H_S = genUnits({strong_hab}, {1})
	W_A_W = genUnits({weak_asmb}, {1})
	W_A_M = genUnits({med_asmb}, {1})
	W_A_S = genUnits({strong_asmb}, {1})
	W_S_W = genUnits({weak_sci}, {1})
	W_S_M = genUnits({med_sci}, {1})
	W_S_S = genUnits({strong_sci}, {1})
	--walker hordes
	W_A_S_3 = genUnits({strong_asmb}, {3})
	W_H_S_2 = genUnits({strong_hab}, {2})

	waves = {
		{N_I_1},
		{N_I_2, N_V_1},
		{N_I_2, N_V_1, H_I_1},
		{N_I_3, N_V_1, H_A_1},
		{N_I_4, N_V_1, N_A_1, W_H_S},
		{N_I_4, N_V_3, N_A_2},
		{N_I_5, N_V_4, N_A_3},
		{N_V_3, N_V_2, M_A_2},
		{N_V_3, N_V_2, H_A_2},
		{N_A_5, N_V_5, W_A_S},
		{M_I_2, M_V_2},
		{M_I_3, M_V_2, M_A_2, H_A_2},
		{M_I_4, M_V_3, M_V_3, M_V_2},
		{M_I_4, M_V_4, H_I_3},
		{M_I_5, M_V_3, M_A_4, W_A_S, W_A_S},
		{M_V_4, M_A_4, H_V_3},
		{M_V_4, M_A_5, N_A_5},
		{M_V_5, N_I_5, H_V_3},
		{M_V_5, N_A_2, M_V_2, M_V_2},
		{M_V_4, N_A_5, M_I_5, W_S_S, W_S_S},
		{H_I_2, H_V_2, W_H_W},
		{H_I_3, H_V_4, W_A_W, W_A_W},
		{H_I_4, H_V_4, W_A_S, W_H_S, W_S_S},
		{H_I_3, H_V_3, H_A_4, W_A_M, W_A_M},
		{H_V_5, W_A_M, W_A_M, W_H_S, W_H_S},
		{H_V_4, H_A_4, N_V_3, M_I_3, W_S_W, W_S_W},
		{H_V_5, H_A_5, N_V_2, M_V_2, W_H_S},
		{H_V_3, N_V_4, N_A_3, M_A_4, W_H_W, W_H_W},
		{H_I_4, M_A_4, M_V_4, W_H_S, W_A_S},
		{H_V_5, H_I_5, H_A_5, W_S_S, W_A_S_3, W_H_S_2}
	}
end

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function genUnits(types, counts)
    local result = {}
    for i = 1, #types do
        -- Add the string 'count' times to the result array
        for j = 1, counts[i] do
            table.insert(result, types[i])
        end
    end

    return result
end

--***************************************STATES****************************************************************************************************
-- below are all the various states that this script will go through

function State_Init(message)
	if message == OnEnter then
		N.Allow_Autonomous_AI_Goal_Activation(false)
		H.Allow_Autonomous_AI_Goal_Activation(false)		
	
        military.Allow_AI_Unit_Behavior(false)
        N.Allow_AI_Unit_Behavior(false)
        H.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
		
		-- Construction Locks/Unlocks
		M.Lock_Unit_Ability("Masari_Hero_Charos", "Masari_Charos_Retreat_From_Tactical_Ability", true,STORY)
		M.Lock_Unit_Ability("Masari_Hero_Alatea", "Masari_Alatea_Retreat_From_Tactical_Ability", true,STORY)
		M.Lock_Unit_Ability("Masari_Hero_Zessus", "Masari_Zessus_Retreat_From_Tactical_Ability", true,STORY)

        M.Give_Money(1000)
		
		Create_Thread("Thread_Mission_Start")

	elseif message == OnUpdate then
    end  
end

function Thread_Mission_Start(message) 

	wavesCompleted = 0
	currentWave = 0
	startloc = Find_Hint("MASARI_ATLATEA", "start") 
	Register_Death_Event(startloc, Death_Objective)
	Add_Objective("Atlatea must not be destroyed")

    spawnFrontL = Find_Hint("MARKER_GENERIC_RED", "spawn1")
    spawnBack = Find_Hint("MARKER_GENERIC_RED", "spawn2")
    spawnFront = Find_Hint("MARKER_GENERIC_RED", "spawn3")
    spawnBackL = Find_Hint("MARKER_GENERIC_RED", "spawn4")
    spawnBackR = Find_Hint("MARKER_GENERIC_RED", "spawn5")
    spawnFrontR = Find_Hint("MARKER_GENERIC_RED", "spawn6")

	spawnLocs = {spawnFront, spawnFrontR, spawnFrontL, spawnBack, spawnBackR, spawnBackL}

	FogOfWar.Reveal(M, spawnFront, 600, 600)
	FogOfWar.Reveal(M, spawnBack, 600, 600)
	FogOfWar.Reveal(M, spawnFrontR, 600, 600)
	FogOfWar.Reveal(M, spawnFrontL, 600, 600)

	Point_Camera_At(startloc)
	Lock_Controls(1)
	Fade_Screen_Out(0)
	Start_Cinematic_Camera()
	Letter_Box_In(0)
	Transition_Cinematic_Target_Key(startloc, 0, 0, 0, 0, 0, 0, 0, 0)
	Transition_Cinematic_Camera_Key(startloc, 0, 200, 55, 65, 1, 0, 0, 0)
	Fade_Screen_In(1) 
	Transition_To_Tactical_Camera(5)
	Sleep(1)
	Letter_Box_Out(1)
	Sleep(1)
	Lock_Controls(0)
	End_Cinematic_Camera()

	nextText = string.format("Beginning wave: %d", wave_timer * 3)
	nextWave = Add_Objective(nextText)
	counter = wave_timer * 3
	while counter > 0 do
		Sleep(1)
		counter = counter - 1
		waveText = string.format("Beginning wave: %d", counter)
		Set_Objective_Text(nextWave, waveText)
	end
	Objective_Complete(nextWave)
    
	while wavesCompleted < total_waves do
		Create_Thread("Spawn_Wave", waves[currentWave + 1])
		Sleep(1)
		while (wavesCompleted < currentWave) do 
			Sleep(1) 
		end
	end

    Create_Thread("Thread_Mission_Complete")
end


function Spawn_Wave(spawns)
	currentWave = currentWave + 1

	spawnGroups = {spawns[1], spawns[2], spawns[3], spawns[4], spawns[5], spawns[6]}
	locIdx = GameRandom(1,6)
	spawnIdx = 0
	spawnsList = {}
	
	waveText = string.format("Defeat Wave %d", wavesCompleted + 1)
	defeatWave = Add_Objective(waveText)
	unitCounter = Add_Objective("Units Left: 0")

	for l = 1, #spawnGroups do
		if spawnGroups[l] ~= nil then
			locIdx = (locIdx + l) % 6 + 1
			spawnsList[spawnIdx] = SpawnList(spawnGroups[l], spawnLocs[locIdx].Get_Position(), H)
			Hunt(spawnsList[spawnIdx], "AntiDefault", true, false)
			spawnIdx = spawnIdx + 1
		end
	end

	invaders_left=1
	while invaders_left>0 do
		invaders_left=0
		for i = 0, #spawnsList do
			if spawnsList[i] ~= nil then
				for j, unit in pairs(spawnsList[i]) do
					if TestValid(unit) then
						invaders_left=invaders_left+1
						waveText = string.format("Units Left: %d", invaders_left)
						Set_Objective_Text(unitCounter, waveText)
					end
				end
			end
		end

		Sleep(1)
	end
	Set_Objective_Text(unitCounter, "Units Left: 0")
	
	Objective_Complete(unitCounter)
	Objective_Complete(defeatWave)

	if wavesCompleted + 1 < total_waves then
		nextText = string.format("Next wave: %d", wave_timer)
		nextWave = Add_Objective(nextText)
		counter = wave_timer
		while counter > 0 do
			Sleep(1)
			counter = counter - 1
			waveText = string.format("Next wave: %d", counter)
			Set_Objective_Text(nextWave, waveText)
		end
		Objective_Complete(nextWave)
	else
		Sleep(5)
	end

	wavesCompleted = wavesCompleted + 1
end

function Story_On_Construction_Complete(obj)
	local obj_type
	
	if TestValid(obj) then
	end
end

function Death_Objective()
	Create_Thread("Thread_Mission_Failed", "Atlatea was destroyed!")
end

function Thread_Mission_Failed(mission_failed_text)
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
	mission_failure = true
   Stop_All_Speech()
   Flush_PIP_Queue()
	Letter_Box_In(1)
	Lock_Controls(1)
	Suspend_AI(1)
	Disable_Automatic_Tactical_Mode_Music()
	Play_Music("Lose_To_Alien_Event")
	Zoom_Camera.Set_Transition_Time(10)
	Zoom_Camera(.3)
	Rotate_Camera_By(180,30)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {mission_failed_text} )
	Sleep(2)
   Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
   Fade_Screen_Out(2)
   Sleep(2)
   Lock_Controls(0)
	Force_Victory(H)
end

function Thread_Mission_Complete()
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(false)
		
	local i, marker

	mission_success = true
   Stop_All_Speech()
   Flush_PIP_Queue()
   
   Letter_Box_In(1)
   Lock_Controls(1)
   Suspend_AI(1)
   Disable_Automatic_Tactical_Mode_Music()
   Play_Music("Masari_Win_Tactical_Event")
   Zoom_Camera.Set_Transition_Time(10)
   Zoom_Camera(.3)
   Rotate_Camera_By(180,90)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"TEXT_SP_MISSION_MISSION_VICTORY"} )
	Sleep(2)
	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {""} )
	Fade_Screen_Out(2)
	Sleep(2)
	Lock_Controls(0)

   Fade_Out_Music()
	Force_Victory(M)
end

function Force_Victory(player)
   Fade_Out_Music()
	if player == M then
	   
		-- Inform the campaign script of our victory.
		global_script.Call_Function("Masari_Tactical_Mission_Over", true) -- true == player wins/false == player loses
		--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
		Quit_Game_Now(player, false, true, false)
	else
		Show_Retry_Dialog()
	end
end

function Post_Load_Callback()
end