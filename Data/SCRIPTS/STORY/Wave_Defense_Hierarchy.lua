
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
	wave_timer = 5
    total_waves = 2

	--this allows a win here to be reported to the strategic level lua script
	global_script = Get_Game_Mode_Script("Strategic")

    grunt = "ALIEN_GRUNT"
    lost = "ALIEN_LOST_ONE"
    var = "NOVUS_VARIANT"
    amtank = "NOVUS_ANTIMATTER_TANK"
    senty = "MASARI_SENTRY"

    H_I_1 = genUnits({grunt, lost}, {8, 6})
    N_V_1 = genUnits({var}, {8})
    N_V_2 = genUnits({var, amtank}, {6, 4})

    N_V_F = genUnits({var}, {3})
    M_V_F = genUnits({senty}, {3})

	waves = {
		{N_V_F, N_V_F},
		{N_V_F, M_V_F, N_V_F},
		{N_V_F, N_V_F}
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
		M.Allow_Autonomous_AI_Goal_Activation(false)		
	
        military.Allow_AI_Unit_Behavior(false)
        N.Allow_AI_Unit_Behavior(false)
        M.Allow_AI_Unit_Behavior(false)
	
		Stop_All_Speech()
		Flush_PIP_Queue()
		Allow_Speech_Events(true)
		
		-- Construction Locks/Unlocks
		aliens.Lock_Unit_Ability("Alien_Hero_Orlok", "Alien_Orlok_Retreat_From_Tactical_Ability", true,STORY)
		aliens.Lock_Unit_Ability("Alien_Hero_Nufai", "Alien_Nufai_Retreat_From_Tactical_Ability", true,STORY)
		aliens.Lock_Unit_Ability("Alien_Hero_Kamal", "Alien_Kamal_Retreat_From_Tactical_Ability", true,STORY)

        aliens.Give_Money(10000)
		
		Create_Thread("Thread_Mission_Start")

	elseif message == OnUpdate then
    end  
end

function Thread_Mission_Start(message) 
	N.Make_Ally(M)
	N.Make_Ally(H)
	M.Make_Ally(N)
	M.Make_Ally(H)
	H.Make_Ally(M)
	H.Make_Ally(M)

	wavesCompleted = 0
	currentWave = 0
	startloc = Find_Hint("ALIEN_HIERARCHY_CORE", "start") 

    spawnFrontL = Find_Hint("MARKER_GENERIC_RED", "spawn1")
    spawnBack = Find_Hint("MARKER_GENERIC_RED", "spawn2")
    spawnFront = Find_Hint("MARKER_GENERIC_RED", "spawn3")
    spawnBackL = Find_Hint("MARKER_GENERIC_RED", "spawn4")
    spawnBackR = Find_Hint("MARKER_GENERIC_RED", "spawn5")
    spawnFrontR = Find_Hint("MARKER_GENERIC_RED", "spawn6")

	spawnLocs = {spawnFront, spawnFrontR, spawnFrontL, spawnBack, spawnBackR, spawnBackL}

	FogOfWar.Reveal(aliens, spawnFront, 600, 600)
	FogOfWar.Reveal(aliens, spawnBack, 600, 600)
	FogOfWar.Reveal(aliens, spawnFrontR, 600, 600)
	FogOfWar.Reveal(aliens, spawnFrontL, 600, 600)

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

	nextText = string.format("Beginning wave: %d", wave_timer)
	nextWave = Add_Objective(nextText)
	counter = wave_timer
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
			spawnsList[spawnIdx] = SpawnList(spawnGroups[l], spawnLocs[locIdx].Get_Position(), M)
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
	Force_Victory(N)
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
   Play_Music("Alien_Win_Tactical_Event")
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
	Force_Victory(aliens)
end

function Force_Victory(player)
   Fade_Out_Music()
	if player == aliens then
	   
		-- Inform the campaign script of our victory.
		global_script.Call_Function("Hierarchy_Tactical_Mission_Over", true) -- true == player wins/false == player loses
		--Quit_Game_Now( winning_player, quit_to_main_menu, destroy_loser_forces, build_temp_command_center, VerticalSliceTriggerVictorySplashFlag)
		Quit_Game_Now(player, false, true, false)
	else
		Show_Retry_Dialog()
	end
end

function Post_Load_Callback()
end