-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/DefaultStrategicScript.lua#47 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/DefaultStrategicScript.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 90587 $
--
--          $DateTime: 2008/01/09 09:43:09 $
--
--          $Revision: #47 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")
require("PGSpawnUnits")
require("UIControl")
require("PGFactions")

--No need to sync this script - it's SP only
ScriptShouldCRC = false

---------------------------------------------------------------------------------------------------------------------------------
--This script implements victory conditions and opponent play for the procedural strategic game.
---------------------------------------------------------------------------------------------------------------------------------

function Definitions()
	Define_State("State_Init", State_Init)
	Define_State("State_Idle", State_Idle)
	Define_State("State_Prepare_Action", State_Prepare_Action)
	Define_State("State_Attack", State_Attack)
	Define_State("State_Finalize_Successful_Attack", State_Finalize_Successful_Attack)
	Define_State("State_Attack_Data_Cleanup", State_Attack_Data_Cleanup)
	
	-- Oksana: mark as scenario so scoring manager knows what to expect
	IsScenario = true;

	--One player per faction right now
	MAX_PLAYERS = 7
	
	PGFactions_Init()
	AIDifficulty = nil
end

function State_Init(message)
	if message == OnEnter then
		Script.Set_Async_Data("IsScenarioCampaign", true)
		AllRegions = Find_Objects_With_Behavior(BEHAVIOR_REGION)
		Init_AI_Command_Center_Types()
		Init_AI_Unit_Tables()
		Init_AI_Player_Table()
		Init_AI_Personality_Table()
		Init_AI_Event_Table()
		Init_AI_Action_Table()
		VictoryThreadID = Create_Thread("Victory_Monitor")
		NextActionTime = 0
		Set_Next_State("State_Idle")
		Fade_Screen_Out(0)
		Fade_Screen_In(2.0)
	end
end

---------------------------------------------------------------------------------------------------------------------------------
--Victory conditions
---------------------------------------------------------------------------------------------------------------------------------

function Victory_Monitor()
	local human_player = Find_Player("local")
	RealPlayers = table.copy(AIPlayerTable)
	table.insert(RealPlayers, human_player)
	
	while not VictoryEncountered do
		for i, player in pairs(RealPlayers) do
			if player then
				if Has_Won(player) then
					for _, other_player in pairs(RealPlayers) do
						if other_player ~= winner then
							Create_Thread("Elimination_Sequence", other_player)
							break
						end
					end
					return
				elseif Has_Lost(player) then
					Create_Thread("Elimination_Sequence", player)		
					break
				end
			end
			Sleep(1)
		end
		Sleep(3)
	end	
end

function Remove_Player(player)
	for i, ai_player in pairs(AIPlayerTable) do
		if ai_player == player then
			table.remove(AIPlayerTable, i)
			break
		end
	end	
	
	for i, real_player in pairs(RealPlayers) do
		if real_player == player then
			table.remove(RealPlayers, i)
			break
		end
	end
	
	if ActingAIPlayer == player then
		Set_Next_State("State_Attack_Data_Cleanup")
		ActingAIPlayer = nil
	end
	
	if LastActingPlayer == player then
		LastActingPlayer = nil
	end
end

function Get_Region_Explosion_Type(player)
	if not RegionExplosions then
		RegionExplosions = {}
		RegionExplosions["ALIEN"] = Find_Object_Type("Alien_Explosion_Global")
		RegionExplosions["NOVUS"] = Find_Object_Type("Novus_Explosion_Global")
		RegionExplosions["MASARI"] = Find_Object_Type("Masari_Explosion_Global")
	end
	
	return RegionExplosions[player.Get_Faction_Name()]
end

function Elimination_Sequence(player)

	while RunningEliminationSequence do
		Sleep(0)
	end

	RunningEliminationSequence = true

	Lock_Controls(1)
	Remove_Player(player)

	--Destroy moving fleets belonging to the eliminated player.
	--Save off regions for destruction
	local explode_regions = {}
	local all_objects = Find_All_Objects_Of_Type(player)
	for _, object in pairs(all_objects) do
		if TestValid(object) then
			if object.Has_Behavior(BEHAVIOR_REGION) then
				table.insert(explode_regions, object)
			elseif not TestValid(object.Get_Region_In()) then
				object.Despawn()
			end
		end
	end
	
	--without the sleep the message is lost during the transition back from tactical
	Sleep(1)

	local message = Replace_Token(Get_Game_Text("TEXT_STRATEGIC_PLAYER_ELIMINATED"), player.Get_Faction_Display_Name(), 0)
   Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {message} )
	Raise_Game_Event("Player_Defeated", player, nil, nil)
	
	local explosion_type = Get_Region_Explosion_Type(player)
	for _, region in pairs(explode_regions) do
		Point_Camera_At(region)
		region.Attach_Particle_Effect(explosion_type)
		Sleep(1)
		region.Destroy_All_Attached_Forces_Of_Player(player)
	end	
	
	Lock_Controls(0)
	
	RunningEliminationSequence = false	
	
	Sleep(5)
	
	if player.Is_Human() then
		Create_Thread.Kill(VictoryThreadID)	
		Quit_Game_Now(AIPlayerTable[1], true, false, false, false, true)
	elseif #AIPlayerTable == 0 then
		GameScoringManager.Notify_Achievement_System_Of_Campaign_Completion("Scenario")
		Quit_Game_Now(Find_Player("local"), true, false, false, false, true)
		Create_Thread.Kill(VictoryThreadID)	
	end
	
end

function Has_Region_Or_Hero(player)
	local all_objects = Find_All_Objects_Of_Type(player)
	for _, object in pairs(all_objects) do
		if object.Has_Behavior(BEHAVIOR_REGION) then
			return true
		end
		
		if object.Get_Type().Is_Hero() then
			return true
		end
	end
	
	return false
end

function Has_HQ(player)

	local hq_type = player.Get_Faction_Value("Headquarters_Type")
	if not hq_type then
		return false
	end
	
	local hq_table = Find_All_Objects_Of_Type(hq_type, player)
	return hq_table and #hq_table > 0
end

function Has_Won(player)
	--A scenario could redefine this function to implement custom victory conditions
	return false
end

function Has_Lost(player)
	--The neutral player never loses
	if player.Is_Neutral() then
		return false
	end

	--A scenario could redefine this function to implement custom victory conditions
	return not Has_HQ(player)
end

function On_Sub_Mode_Ended(location, winner, loser)
	--Check whether the game is over
	if Has_Won(winner) then
		for _, other_player in pairs(RealPlayers) do
			if other_player ~= winner then
				Create_Thread("Elimination_Sequence", other_player)
			end
		end
	elseif Has_Lost(loser) then
		Create_Thread("Elimination_Sequence", loser)
	end	
	
	Fade_Screen_Out(0)
	Fade_Screen_In(1.0)	
	
	--If we completed a battle against a human opponent then we'll treat
	--our AI attack sequence as being complete regardless of whether this
	--was our intended target
	if WasAIAttack then
		WasAIAttack = false
		if winner == human_player then
			Set_Next_State("State_Attack_Data_Cleanup")
		elseif loser == human_player then
			Set_Next_State("State_Finalize_Successful_Attack")
		end
	end
	
	--Go back to enforcing strategic dependencies 
	for player_index = 0, MAX_PLAYERS - 1 do
		local player = Find_Player(player_index)
		if player then
			Enforce_Global_Production_Dependencies(player, true)
			
			--Research reset is now handled by the player script itself
		end
	end	
end

function On_Land_Invasion()
	WasAIAttack = false
	local human_player = Find_Player("local")
	local is_defender = (InvasionInfo.Location.Get_Owner() == human_player)
	local is_invader = (InvasionInfo.Invader == human_player)

	if is_invader then
		message = Get_Game_Text("TEXT_STRATEGIC_BATTLE_LOCAL_INVADER")
	elseif is_defender then
		message = Get_Game_Text("TEXT_STRATEGIC_BATTLE_LOCAL_DEFENDER")	
		
		--Human got attacked by AI
		WasAIAttack = true
	else
		--AI vs AI battle.  It will be resolved quietly by code.
		return	
	end
	
	BattlePending = true
 	Create_Thread("Pending_Battle_Thread", InvasionInfo.Location)
end

function Pending_Battle_Thread(location)

	while RunningEliminationSequence do
		Sleep(0)
	end
	
	Lock_Controls(1)	
	
 	message = Replace_Token(message, InvasionInfo.Location.Get_Type().Get_Display_Name(), 0)
 	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Minor_Announcement_Text", nil, {message} )
 	Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("End_Tooltip", nil, nil)

	local old_yaw, old_pitch = Point_Camera_At.Set_Transition_Time(0.5, 0.5)
	old_zoom = Zoom_Camera.Set_Transition_Time(3.0)
	Point_Camera_At(location)
	Zoom_Camera(1.0)
	Sleep(4)
	Fade_Screen_Out(1)
	Sleep(1)
	
	--Make sure that building in tactical has no strategic dependencies.
	for player_index = 0, MAX_PLAYERS - 1 do
		local player = Find_Player(player_index)
		if player then
			Enforce_Global_Production_Dependencies(player, false)
		end
	end	
	
	UI_Set_Loading_Screen_Mission_Text(location.Get_Type().Get_Type_Value("Text_ID"))
	UI_Set_Loading_Screen_Faction_ID(Get_Faction_Numeric_Form_From_Localized(Find_Player("local").Get_Faction_Display_Name()))
	
	while PreventNewBattleCount and 	PreventNewBattleCount > 0 do
		Sleep(1)
	end

	Start_Pending_Battle()
	Point_Camera_At.Set_Transition_Time(old_yaw, old_pitch)
	Zoom_Camera.Set_Transition_Time(old_zoom)
	Lock_Controls(0)	
	BattlePending = false
end

function Is_Scenario_Campaign()
	return true
end

---------------------------------------------------------------------------------------------------------------------------------
--The next block of functions defines what is essentially the strategic AI engine.
--The logic is:
-- 1) Wait a while
-- 2) Pick something to do and an AI player to do it
-- 3) Do it
-- 4) Go to 1
---------------------------------------------------------------------------------------------------------------------------------
function State_Idle(message)
	if message == OnEnter then
		if not RequestedAction and GetCurrentTime() >= NextActionTime then
			NextActionTime = Determine_Next_Action_Time()
		end
	elseif message == OnUpdate then
		if not RunningEliminationSequence and not PendingBattle and (GetCurrentTime() >= NextActionTime or RequestedAction) then
			Set_Next_State("State_Prepare_Action")
		end
	end
end

function State_Prepare_Action(message)
	if message == OnEnter then
		local action, player = Determine_Action()
		if action then
			Perform_Action(action, player)
		else
			Set_Next_State("State_Idle")
		end
	end
end

function State_Attack(message)
	if message == OnEnter then
		if not TestValid(AttackHero) then
			--For trivial failure we'll behave as though this never happened
			Action_Failed()
			Set_Next_State("State_Attack_Data_Cleanup")
			return
		end
		local attack_fleet = AttackHero.Get_Parent_Object()
		if not TestValid(attack_fleet) then
			Action_Failed()
			Set_Next_State("State_Attack_Data_Cleanup")
			return
		end
		
		--Clean out any units left from a previous attack.  Passing false preserves the hero.
		attack_fleet.Destroy_Fleet_Contents(false)
		Strategic_SpawnList(AttackForce, ActingAIPlayer, attack_fleet)
	elseif message == OnUpdate then
		if not TestValid(AttackHero) then
			Set_Next_State("State_Attack_Data_Cleanup")
			return
		end
		local attack_fleet = AttackHero.Get_Parent_Object()
		if not TestValid(attack_fleet) then
			Set_Next_State("State_Attack_Data_Cleanup")
			return
		end		
		local current_region = attack_fleet.Get_Parent_Object()
		if TestValid(current_region) then
			if current_region ~= AttackTarget then
				if not Move_Hero_To_Region(AttackHero, AttackTarget) then
					Set_Next_State("State_Attack_Data_Cleanup")	
				end
			else
				Set_Next_State("State_Finalize_Successful_Attack")
			end
		end
	end
end

function State_Finalize_Successful_Attack(message)
	if message == OnEnter then
		if not AttackTarget or AttackTarget.Get_Owner() ~= ActingAIPlayer then
			Set_Next_State("State_Attack_Data_Cleanup")	
			return
		end
		
		local cc_type = Determine_Command_Center_Type(ActingAIPlayer, AttackTarget)
		if cc_type then
			ActingAIPlayer.Add_Credits(cc_type.Get_Type_Value("Build_Cost_Credits"))
			AttackTarget.Start_Command_Center_Construction(cc_type, ActingAIPlayer)
			Set_Next_State("State_Attack_Data_Cleanup")	
		end
	end
end

function State_Attack_Data_Cleanup(message)
	if message == OnEnter then	
		ActingAIPlayer = nil
		AttackHero = nil
		AttackForce = nil
		AttackTarget = nil
		
		Set_Next_State("State_Idle")
	end		
end

---------------------------------------------------------------------------------------------------------------------------------
-- Utility functions for the AI 'engine'.  These should probably not need designer modification.
---------------------------------------------------------------------------------------------------------------------------------
function Init_AI_Player_Table()
	AIPlayerTable = {}
	
	for player_index = 0, MAX_PLAYERS - 1 do
		local player = Find_Player(player_index)
		if player and player.Is_AI_Player() then
			table.insert(AIPlayerTable, player)
			if not AIDifficulty then
				AIDifficulty = player.Get_Difficulty()
			end
		end
	end
end

function Request_Action(action, player)
	if not RequestedAction then
		RequestedAction = { action, player }
	end
end

function Perform_Action(action, player)
	RequestedAction = nil
	LastAction[player] = action
	LastActingPlayer = player
	action(player)
end

function Action_Failed()
	LastAction[LastActingPlayer] = nil
	LastActingPlayer = nil
end

function Select_Unit(player, unit_distribution)
	local first_choice_unit = unit_distribution.Sample()
	while first_choice_unit and player.Is_Object_Type_Locked(first_choice_unit) do
		first_choice_unit = UnitFallbacks[first_choice_unit]
	end
	return first_choice_unit
end

function Init_AI_Personality_Table()
	AGGRESSIVE = Declare_Enum(0)
	TURTLE = Declare_Enum()
	DEVIOUS = Declare_Enum()
	BALANCED = Declare_Enum()
	
	AIPersonalities = {}
	for _, player in pairs(AIPlayerTable) do
		AIPersonalities[player] = GameRandom(AGGRESSIVE, BALANCED)
	end
	
	ActionDefinitions = {}
	ActionDefinitions[AGGRESSIVE] = Define_Aggressive_Actions
	ActionDefinitions[TURTLE] = Define_Turtle_Actions
	ActionDefinitions[DEVIOUS] = Define_Devious_Actions
	ActionDefinitions[BALANCED] = Define_Balanced_Actions
	
	FollowUpDefinitions = {}
	FollowUpDefinitions[AGGRESSIVE] = Define_Aggressive_Follow_Ups
	FollowUpDefinitions[TURTLE] = Define_Turtle_Follow_Ups
	FollowUpDefinitions[DEVIOUS] = Define_Devious_Follow_Ups
	FollowUpDefinitions[BALANCED] = Define_Balanced_Follow_Ups
	
	CommandCenterOrder = {}
	CommandCenterOrder[AGGRESSIVE] = Define_Aggressive_Command_Center_Order()
	CommandCenterOrder[TURTLE] = Define_Turtle_Command_Center_Order()
	CommandCenterOrder[DEVIOUS] = Define_Devious_Command_Center_Order()
	CommandCenterOrder[BALANCED] = Define_Balanced_Command_Center_Order()
	
	MinRegionsForMegaweapon = {}
	MinRegionsForMegaweapon[AGGRESSIVE] = Get_Aggressive_Min_Regions_For_Megaweapon()
	MinRegionsForMegaweapon[TURTLE] = Get_Turtle_Min_Regions_For_Megaweapon()
	MinRegionsForMegaweapon[DEVIOUS] = Get_Devious_Min_Regions_For_Megaweapon()
	MinRegionsForMegaweapon[BALANCED] = Get_Balanced_Min_Regions_For_Megaweapon()
end

function Init_AI_Event_Table()
	NEUTRAL_REGION_CAPTURED = Declare_Enum(0)
	MY_REGION_CAPTURED = Declare_Enum()
	GENERIC_COMMAND_CENTER_BUILT = Declare_Enum()
	MEGAWEAPON_BUILT = Declare_Enum()
	MEGAWEAPON_FIRED = Declare_Enum()
	IDLE_TIME_OUT = Declare_Enum()

	for _, region in pairs(AllRegions) do
		region.Register_Signal_Handler(On_Region_Owner_Changed, "OBJECT_OWNER_CHANGED")
		region.Register_Signal_Handler(On_Region_Production_Finished, "OBJECT_PRODUCTION_FINISHED")
	end
	
	LastAttackedBy = {}	
end

function Init_AI_Action_Table()
	AIActionTable = {}
	FollowUpTable = {}

	for _, player in pairs(AIPlayerTable) do
		AIActionTable[player] = {}
		
		AIActionTable[player]= ActionDefinitions[AIPersonalities[player]]()
		FollowUpTable[player] = FollowUpDefinitions[AIPersonalities[player]]()
	end
	
	LastAction = {}
	LastActingPlayer = nil
end

function Determine_Action()
	if RequestedAction then
		return RequestedAction[1], RequestedAction[2]
	else
		--No requested action?  Then this is a time-out.  Have the players
		--act in turns.
		local acting_player = Determine_Next_Acting_Player()
		
		if not acting_player then
			return nil
		end
		
		--Attempt to follow-up on our last action
		if LastAction[acting_player] then
			local follow_up = FollowUpTable[acting_player][LastAction[player]]
			if follow_up then
				return follow_up, acting_player
			end
		end
		
		return AIActionTable[acting_player][IDLE_TIME_OUT].Sample(), acting_player
	end
end

function Determine_Next_Acting_Player()
	local ai_player_count = #AIPlayerTable
	if ai_player_count == 0 then
		return nil
	end

	local acting_player
	if not LastActingPlayer then
		acting_player = AIPlayerTable[GameRandom(1, ai_player_count)]
	else
		for i, player in pairs(AIPlayerTable) do
			if player == LastActingPlayer then
				acting_player = AIPlayerTable[i + 1]
				break
			end
		end
		
		if not acting_player then
			acting_player = AIPlayerTable[1]
		end
	end
	
	return acting_player
end

function Determine_Command_Center_Type(player)
	--Max research points is 6, but 1 is granted by the HQ
	local MAX_RESEARCH_BUILDINGS = 5
	local RESOURCE_BUILDINGS_FOR_MEGAWEAPON = 6
	local PRODUCTION_BUILDINGS_PRIORITY_CUTOFF = 3
	
	local personality = AIPersonalities[player]
	local faction_name = player.Get_Faction_Name()
	
	local production_cc_type = ProductionCCTypeTable[faction_name]
	local research_cc_type = ResearchCCTypeTable[faction_name]
	local resource_cc_type = ResourceCCTypeTable[faction_name]
	local megaweapon_cc_type = MegaweaponCCTypeTable[faction_name]

	local cc_count = {}
	cc_count[production_cc_type] = 0
	cc_count[research_cc_type] = 0
	cc_count[resource_cc_type] = 0
	cc_count[megaweapon_cc_type] = 0

	--Loop through regions to count command centers.  That way we can account for structures under construction
	for _, region in pairs(AllRegions) do
		if region.Get_Owner() == player then
			local cc_type = region.Get_Command_Center_Under_Construction_Type()
			if region.Has_Command_Center() then
				cc_type = region.Get_Command_Center().Get_Type()
			end
			
			if TestValid(cc_type) and cc_count[cc_type] then
				cc_count[cc_type] = cc_count[cc_type] + 1
			end
		end
	end
				
	--Don't build more research buildings than we need for full research
	if cc_count[research_cc_type] >= MAX_RESEARCH_BUILDINGS then
		cc_count[research_cc_type] = BIG_FLOAT
	end
	
	--At some point production buildings become less desirable
	if cc_count[production_cc_type] >= PRODUCTION_BUILDINGS_PRIORITY_CUTOFF then
		cc_count[production_cc_type] = cc_count[production_cc_type] * 2
	end
	
	--Megaweapon is our preference provided we can build one
	if cc_count[megaweapon_cc_type] < 1 and cc_count[resource_cc_type] >= RESOURCE_BUILDINGS_FOR_MEGAWEAPON then
		--We need a certain number of non-megaweapon command centers to build a megaweapon (exact number depends on personality)
		if (cc_count[production_cc_type] + cc_count[research_cc_type] + cc_count[resource_cc_type]) >= MinRegionsForMegaweapon[personality] then
			return MegaweaponCCTypeTable[faction_name]
		end
	end
	
	local pref_a_type, pref_a_count = Determine_Better_Command_Center(player, production_cc_type, cc_count[production_cc_type], research_cc_type, cc_count[research_cc_type])
	local pref_b_type, pref_b_count = Determine_Better_Command_Center(player, research_cc_type, cc_count[research_cc_type], resource_cc_type, cc_count[resource_cc_type])
	local favorite_type = Determine_Better_Command_Center(player, pref_a_type, pref_a_count, pref_b_type, pref_b_count)

	return favorite_type
end

function Determine_Better_Command_Center(player, type_a, count_a, type_b, count_b)
	if count_a < count_b then
		return type_a, count_a
	elseif count_b < count_a then
		return type_b, count_b
	else
		local cc_order = CommandCenterOrder[AIPersonalities[player]]
		local faction_name = player.Get_Faction_Name()
		if type_a == cc_order[1][faction_name] or type_b == cc_order[1][faction_name] then
			return cc_order[1][faction_name], count_a
		elseif type_a == cc_order[2][faction_name] or type_b == cc_order[2][faction_name] then
			return cc_order[2][faction_name], count_a
		else
			return cc_order[3][faction_name], count_a
		end
	end
end

function On_Region_Owner_Changed(region, old_owner)
	local new_owner = region.Get_Owner()
	if new_owner.Is_Human() then
		if old_owner.Is_Neutral() then
			local acting_player = Determine_Next_Acting_Player()
			Request_Action(AIActionTable[acting_player][NEUTRAL_REGION_CAPTURED].Sample(), acting_player)
		else
			Request_Action(AIActionTable[old_owner][MY_REGION_CAPTURED].Sample(), old_owner)
		end			
	end
	
	if not old_owner.Is_Neutral() and not new_owner.Is_Neutral() then
		region.Attach_Particle_Effect(Get_Region_Explosion_Type(old_owner))
		if old_owner.Is_AI_Player() and new_owner.Is_AI_Player() then
			--Announce result of ai vs ai battle
			local message = Replace_Token(Get_Game_Text("TEXT_AR_HERO_LOSS"), old_owner.Get_Display_Name(), 0)
			message = Replace_Token(message, region.Get_Type().Get_Display_Name(), 1)
			Get_Game_Mode_GUI_Scene().Raise_Event("Set_Minor_Announcement_Text", nil, {message} )
		end
	end
	
	LastAttackedBy[old_owner] = region.Get_Owner()
end

function On_Region_Production_Finished(region)
end

function Move_Hero_To_Region(hero, region)
	if RunningEliminationSequence or PendingBattle then
		return false
	end

	if not TestValid(hero) then
		return false
	end
	
	if not TestValid(region) then
		return false
	end
	
	local fleet = hero.Get_Parent_Object()
	if not TestValid(fleet) then
		return false
	end
	
	if fleet.Is_Fleet_Moving() then
		return false
	end
	
	if fleet.Move_Fleet_To_Region(region) then
		return true
	end
	
	--Hit and run type attacks must only travel through friendly and neutral regions
	local require_neutral = false
	if LastAction[ActingAIPlayer] == Hit_And_Run or LastAction[ActingAIPlayer] == Land_Grab then
		require_neutral = true
	end
	
	local current_region = hero.Get_Region_In()
	if not TestValid(current_region) then
		return false
	end
	
	local all_regions = current_region.Find_Regions_Within(hero.Get_Type().Get_Type_Value("Travel_Range"))
	local closest_region = nil
	local closest_distance = current_region.Get_Distance(region)
	for _, possible_region in pairs(all_regions) do
		local region_owner = possible_region.Get_Owner()
		local is_friendly = region_owner == hero.Get_Owner()
		if is_friendly or not require_neutral or region_owner.Is_Neutral() then
			--Never 'accidentally' move through the HQ region of an opponent - it's too well defended
			local command_center = possible_region.Get_Command_Center()
			if is_friendly or not command_center or not Is_Headquarters(region.Get_Owner(), command_center) then	
				local distance = possible_region.Get_Distance(region)
				if distance < closest_distance then
					closest_region = possible_region
					closest_distance = distance
				end
			end
		end
	end
	
	if TestValid(closest_region) then
		return fleet.Move_Fleet_To_Region(closest_region)
	end
	
	return false
end

function Is_Headquarters(player, object_type)
	return object_type == player.Get_Faction_Value("Headquarters_Type")
end

function Is_Megaweapon(object_type)
	if not AllMegaWeaponTypeTable then
		AllMegaWeaponTypeTable = {}
		AllMegaWeaponTypeTable[Find_Object_Type("Alien_Megaweapon_Purifier")] = true
		AllMegaWeaponTypeTable[Find_Object_Type("Novus_Megaweapon")] = true
		AllMegaWeaponTypeTable[Find_Object_Type("Masari_Megaweapon")] = true
	end
	return AllMegaWeaponTypeTable[object_type]
end

function Is_Region_Defense(object_type)
	if not RegionDefenseTypeTable then
		RegionDefenseTypeTable = {}
		RegionDefenseTypeTable[Find_Object_Type("Alien_Abduction_Core_Basic_Defense_Upgrade")] = true
		RegionDefenseTypeTable[Find_Object_Type("Alien_Creation_Core_Basic_Defense_Upgrade")] = true
		RegionDefenseTypeTable[Find_Object_Type("Alien_Foundation_Basic_Defense_Upgrade")] = true
		RegionDefenseTypeTable[Find_Object_Type("Alien_Theory_Core_Basic_Defense_Upgrade")] = true
		RegionDefenseTypeTable[Find_Object_Type("Masari_Atlatea_Basic_Defense_Upgrade")] = true
		RegionDefenseTypeTable[Find_Object_Type("Masari_Element_Magnet_Basic_Defense_Upgrade")] = true
		RegionDefenseTypeTable[Find_Object_Type("Masari_Key_Inspiration_Basic_Defense_Upgrade")] = true
		RegionDefenseTypeTable[Find_Object_Type("Masari_Will_Processor_Basic_Defense_Upgrade")] = true
		RegionDefenseTypeTable[Find_Object_Type("Novus_Material_Center_Basic_Defense_Upgrade")] = true
		RegionDefenseTypeTable[Find_Object_Type("Novus_Megacorp_Center_Basic_Defense_Upgrade")] = true
		RegionDefenseTypeTable[Find_Object_Type("Novus_Nanocenter_Basic_Defense_Upgrade")] = true
		RegionDefenseTypeTable[Find_Object_Type("Novus_R_and_D_Center_Basic_Defense_Upgrade")] = true
	end
	
	return RegionDefenseTypeTable[object_type]
end

function Is_Megaweapon_Defense(object_type)
	if not MegaweaponDefenseTypeTable then
		MegaweaponDefenseTypeTable = {}
		MegaweaponDefenseTypeTable[Find_Object_Type("Alien_Abduction_Core_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Alien_Foundation_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Alien_Theory_Core_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Masari_Atlatea_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Masari_Element_Magnet_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Masari_Will_Processor_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Novus_Material_Center_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Novus_Megacorp_Center_Megaweapon_Countermeasure_Upgrade")] = true
		MegaweaponDefenseTypeTable[Find_Object_Type("Novus_R_and_D_Center_Megaweapon_Countermeasure_Upgrade")] = true
	end
		
	return MegaweaponDefenseTypeTable[object_type]
end

function Start_Research(player)
	local player_script = player.Get_Script()
	local research_tree_data = player_script.Call_Function("Retrieve_Tree_Data", nil)
	local available_table = {}
	for _, node_info in pairs(research_tree_data) do
		--Data at indices 3 and 4 are Enabled and Completed respectively (see Retrieve_Branch_Data)
		if node_info[3] and not node_info[4] then
			table.insert(available_table, node_info)
		end
	end
	
	--Pick a random available node
	local available_count = #available_table
	if available_count == 0 then
		return
	end
	local next_node = available_table[GameRandom(1, available_count)]
	player_script.Call_Function("Start_Research", next_node)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Stuff below is the 'AI data'.  Designer modifications largely belong here.
---------------------------------------------------------------------------------------------------------------------------------
function Init_AI_Command_Center_Types()
	ProductionCCTypeTable = {}
	ProductionCCTypeTable["NOVUS"] = Find_Object_Type("Novus_Nanocenter")
	ProductionCCTypeTable["ALIEN"] = Find_Object_Type("Alien_Creation_Core")
	ProductionCCTypeTable["MASARI"] = Find_Object_Type("Masari_Key_Inspiration")
	
	ResearchCCTypeTable = {}
	ResearchCCTypeTable["NOVUS"] = Find_Object_Type("Novus_Research_Center")
	ResearchCCTypeTable["ALIEN"] = Find_Object_Type("Alien_Theory_Core")
	ResearchCCTypeTable["MASARI"] = Find_Object_Type("Masari_Will_Processor")
	
	ResourceCCTypeTable = {}
	ResourceCCTypeTable["NOVUS"] = Find_Object_Type("Novus_Material_Center")
	ResourceCCTypeTable["ALIEN"] = Find_Object_Type("Alien_Abduction_Core")
	ResourceCCTypeTable["MASARI"] = Find_Object_Type("Masari_Element_Magnet")
	
	MegaweaponCCTypeTable = {}
	MegaweaponCCTypeTable["NOVUS"] = Find_Object_Type("Novus_Megaweapon")
	MegaweaponCCTypeTable["ALIEN"] = Find_Object_Type("Alien_Megaweapon_Purifier")
	MegaweaponCCTypeTable["MASARI"] = Find_Object_Type("Masari_Megaweapon")
	
	SpyTypeTable = {}
	SpyTypeTable["NOVUS"] = Find_Object_Type("Novus_R_and_D_Center_Spy_System_Upgrade")
	SpyTypeTable["ALIEN"] = Find_Object_Type("Alien_Theory_Core_Spy_System_Upgrade")
	SpyTypeTable["MASARI"] = Find_Object_Type("Masari_Will_Processor_Spy_System_Upgrade")
end

function Init_AI_Unit_Tables()
	--Very, very stub.
	HeavyVehicles = {}
	
	HeavyVehicles["NOVUS"] = DiscreteDistribution.Create()
	HeavyVehicles["NOVUS"].Insert("Novus_Field_Inverter", 1.0)
	HeavyVehicles["NOVUS"].Insert("Novus_Amplifier", 1.0)
	
	HeavyVehicles["ALIEN"] = DiscreteDistribution.Create()
	HeavyVehicles["ALIEN"].Insert("Alien_Defiler", 1.0)
	HeavyVehicles["ALIEN"].Insert("Alien_Foo_Core", 1.0)
	HeavyVehicles["ALIEN"].Insert("Alien_Cylinder", 1.0)
	
	HeavyVehicles["MASARI"] = DiscreteDistribution.Create()
	HeavyVehicles["MASARI"].Insert("Masari_Peacebringer", 1.0)
	HeavyVehicles["MASARI"].Insert("Masari_Skylord", 1.0)
	
	-------------------------------------------------------------
	
	LightVehicles = {}
	LightVehicles["NOVUS"] = DiscreteDistribution.Create()
	LightVehicles["NOVUS"].Insert("Novus_Dervish_Jet", 1.0)
	LightVehicles["NOVUS"].Insert("Novus_Corruptor", 1.0)
	LightVehicles["NOVUS"].Insert("Novus_Antimatter_Tank", 1.0)
	LightVehicles["NOVUS"].Insert("Novus_Variant", 1.0)
	
	LightVehicles["ALIEN"] = DiscreteDistribution.Create()
	LightVehicles["ALIEN"].Insert("Alien_Recon_Tank", 1.0)
	
	LightVehicles["MASARI"] = DiscreteDistribution.Create()
	LightVehicles["MASARI"].Insert("Masari_Enforcer", 1.0)
	LightVehicles["MASARI"].Insert("Masari_Seeker", 1.0)
	LightVehicles["MASARI"].Insert("Masari_Sentry", 1.0)
	
	-------------------------------------------------------------	
	
	HeavyInfantry = {}
	HeavyInfantry["NOVUS"] = DiscreteDistribution.Create()
	HeavyInfantry["NOVUS"].Insert("Novus_Reflex_Trooper", 1.0)
	
	HeavyInfantry["ALIEN"] = DiscreteDistribution.Create()
	HeavyInfantry["ALIEN"].Insert("Alien_Brute", 1.0)
	
	HeavyInfantry["MASARI"] = DiscreteDistribution.Create()
	HeavyInfantry["MASARI"].Insert("Masari_Seer", 1.0)
	
	-------------------------------------------------------------
	
	LightInfantry = {}
	LightInfantry["NOVUS"] = DiscreteDistribution.Create()
	LightInfantry["NOVUS"].Insert("Novus_Robotic_Infantry", 1.0)
	LightInfantry["NOVUS"].Insert("Novus_Hacker", 1.0)
	
	LightInfantry["ALIEN"] = DiscreteDistribution.Create()
	LightInfantry["ALIEN"].Insert("Alien_Grunt", 1.0)
	LightInfantry["ALIEN"].Insert("Alien_Lost_One", 1.0)
	
	LightInfantry["MASARI"] = DiscreteDistribution.Create()
	LightInfantry["MASARI"].Insert("Masari_Disciple", 1.0)

	-------------------------------------------------------------

	UnitFallbacks = {}
	
	UnitFallbacks["Novus_Field_Inverter"] = "Novus_Variant"
	UnitFallbacks["Novus_Amplifier"] = "Novus_Variant"
	UnitFallbacks["Novus_Antimatter_Tank"] = "Novus_Variant"
	UnitFallbacks["Novus_Dervish_Jet"] = "Novus_Corruptor"
	UnitFallbacks["Novus_Reflex_Trooper"] = "Novus_Robotic_Infantry"
	UnitFallbacks["Novus_Hacker"] = "Novus_Robotic_Infantry"

	UnitFallbacks["Alien_Defiler"] = "Alien_Cylinder"
	UnitFallbacks["Alien_Foo_Core"] = "Alien_Cylinder"
	UnitFallbacks["Alien_Recon_Tank"] = "Alien_Cylinder"
	UnitFallbacks["Alien_Lost_One"] = "Alien_Grunt"
	UnitFallbacks["Alien_Brute"] = "Alien_Grunt"

	UnitFallbacks["Masari_Peacebringer"] = "Masari_Sentry"
	UnitFallbacks["Masari_Skylord"] = "Masari_Sentry"
	UnitFallbacks["Masari_Enforcer"] = "Masari_Sentry"
	UnitFallbacks["Masari_Seeker"] = "Masari_Sentry"
	UnitFallbacks["Masari_Seer"] = "Masari_Disciple"
end

function Determine_Next_Action_Time()
	if not LastActingPlayer or not LastAction[LastActingPlayer] then
		--Next frame
		return GetCurrentTime() + 0.033
	end

	local delay = 0
	if LastAction[LastActingPlayer] == Land_Grab or
			LastAction[LastActingPlayer] == Upgrade_Command_Center or 
			LastAction[LastActingPlayer] == Build_Megaweapon_Defense or
			LastAction[LastActingPlayer] == Use_Spy then
		--Don't too long if we didn't engage in direct aggression vs the human player
		delay = GameRandom(5, 20)	
	else
		delay = GameRandom(20, 45)	
	end

	if AIDifficulty == "Easy" then
		delay = delay * 1.5
	elseif AIDifficulty == "Hard" then
		delay = delay * 0.5
	end
	
	return GetCurrentTime() + delay
end		

---------------------------------------------------------------------------------------------------------------------------------
--State sequence to grab the assault hero + large force and go steamroll a player territory
---------------------------------------------------------------------------------------------------------------------------------
function Conquest(ai_player)
	if GetCurrentTime() < 60 then
		--Don't allow this action to occur too early in the game
		Action_Failed()
		Set_Next_State("State_Attack_Data_Cleanup")
		return
	end

	ActingAIPlayer = ai_player
	AttackHero, AttackForce = Get_Conquest_Force(ai_player)
	AttackTarget = Get_Conquest_Target(AttackHero)
	
	if not TestValid(AttackHero) or not AttackForce or not TestValid(AttackTarget) then
		Action_Failed()
		Set_Next_State("State_Attack_Data_Cleanup")
	else		
		Set_Next_State("State_Attack")
	end
end

function Get_Conquest_Force(ai_player)
	local faction = ai_player.Get_Faction_Name()
	local hero = nil
	local unit_table = nil
	
	if faction == "NOVUS" then
		hero = Find_First_Object("Novus_Hero_Mech")
		if not TestValid(hero) then
			hero = Find_First_Object("Novus_Hero_Founder")
		end
	elseif faction == "ALIEN" then
		hero = Find_First_Object("Alien_Hero_Orlok")
		if not TestValid(hero) then
			hero = Find_First_Object("Alien_Hero_Kamal_Rex")
		end
	else
		hero = Find_First_Object("Masari_Hero_Charos")
		if not TestValid(hero) then
			hero = Find_First_Object("Masari_Hero_Alatea")
		end
	end	
	
	unit_table = {	Select_Unit(ai_player, HeavyVehicles[faction]),
						Select_Unit(ai_player, HeavyVehicles[faction]),  
						Select_Unit(ai_player, HeavyVehicles[faction]),  
						Select_Unit(ai_player, HeavyVehicles[faction]),  
						Select_Unit(ai_player, HeavyVehicles[faction]),  
						
						Select_Unit(ai_player, LightVehicles[faction]),  
						Select_Unit(ai_player, LightVehicles[faction]),  
						Select_Unit(ai_player, LightVehicles[faction]),
						  
						Select_Unit(ai_player, HeavyInfantry[faction]),  
						Select_Unit(ai_player, HeavyInfantry[faction]),  
						Select_Unit(ai_player, HeavyInfantry[faction])	}
						
	return hero, unit_table
end

function Get_Conquest_Target(hero)

	if not TestValid(hero) then
		return nil
	end
	local region = hero.Get_Region_In()
	if not TestValid(region) then
		return nil
	end
	
	--Prefer regions reachable in one hop
	local best_score = 0
	local best_target = nil
	local all_regions = region.Find_Regions_Within(hero.Get_Type().Get_Type_Value("Travel_Range"))
	for _, possible_target in pairs(all_regions) do
		local target_score = Score_Conquest_Target(possible_target)
		if target_score > best_score then
			best_target = possible_target
			best_score = target_score
		end		
	end
	
	if TestValid(best_target) then
		return best_target
	end

	--Fallback to the nearest human region.
	local target_player = Find_Player("local")
	return region.Find_Closest_Friendly_Region_For_Player(target_player)
end

function Score_Conquest_Target(region)
	--Prefer neutral regions
	local target_owner = region.Get_Owner()
	if target_owner.Is_Neutral() then
		return 1.5
	end
	
	if target_owner.Is_Ally(ActingAIPlayer) then
		return 0.0
	end

	if target_owner.Is_Human() then
		local score = GameRandom.Get_Float(0.6, 1.0)
		
		--Bonus for spied regions with no defending hero
		if region.Get_Strategic_FOW_Level(ActingAIPlayer) > 0 then
			score = score + 1 - region.Get_Number_Of_Fleets_Contained()
		end	
		return score
	end
	
	return GameRandom.Get_Float(0, 0.5)
end

---------------------------------------------------------------------------------------------------------------------------------
--State sequence to grab the support hero + medium force and attack a player territory
---------------------------------------------------------------------------------------------------------------------------------
function Retaliation(ai_player)
	if GetCurrentTime() < 30 then
		--Don't allow this action to occur too early in the game
		Action_Failed()
		Set_Next_State("State_Attack_Data_Cleanup")
		return
	end

	ActingAIPlayer = ai_player
	AttackHero, AttackForce = Get_Retaliation_Force(ai_player)
	AttackTarget = Get_Retaliation_Target(AttackHero)
	
	if not TestValid(AttackHero) or not AttackForce or not TestValid(AttackTarget) then
		Action_Failed()
		Set_Next_State("State_Attack_Data_Cleanup")
	else		
		Set_Next_State("State_Attack")
	end
end

function Get_Retaliation_Force(ai_player)
	local faction = ai_player.Get_Faction_Name()
	local hero = nil
	local unit_table = nil
	
	if faction == "NOVUS" then
		hero = Find_First_Object("Novus_Hero_Founder")
		if not TestValid(hero) then
			hero = Find_First_Object("Novus_Hero_Mech")
		end
	elseif faction == "ALIEN" then
		hero = Find_First_Object("Alien_Hero_Kamal_Rex")
		if not TestValid(hero) then
			hero = Find_First_Object("Alien_Hero_Orlok")
		end
	else
		hero = Find_First_Object("Masari_Hero_Alatea")
		if not TestValid(hero) then
			hero = Find_First_Object("Masari_Hero_Charos")
		end
	end
	
	unit_table = {	Select_Unit(ai_player, HeavyVehicles[faction]),
						Select_Unit(ai_player, HeavyVehicles[faction]),
						
						Select_Unit(ai_player, LightVehicles[faction]),  
						Select_Unit(ai_player, LightVehicles[faction]),  
						Select_Unit(ai_player, LightVehicles[faction]), 
						 
						Select_Unit(ai_player, HeavyInfantry[faction]),  
						Select_Unit(ai_player, HeavyInfantry[faction]),
						 
						Select_Unit(ai_player, LightInfantry[faction]),  
						Select_Unit(ai_player, LightInfantry[faction])	}		
						
	return hero, unit_table
end

function Get_Retaliation_Target(hero)

	if not TestValid(hero) then
		return nil
	end
	
	local region = hero.Get_Region_In()
	if not TestValid(region) then
		return nil
	end

	local target_player = LastAttackedBy[hero.Get_Owner()] 
	if not target_player then
		return nil
	end
	
	return region.Find_Closest_Friendly_Region_For_Player(target_player)	
end

---------------------------------------------------------------------------------------------------------------------------------
--State sequence to grab the stealth hero + small force and attack a specific player asset
---------------------------------------------------------------------------------------------------------------------------------
function Hit_And_Run(ai_player)
	if GetCurrentTime() < 300 then
		--Don't allow this action to occur too early in the game
		Action_Failed()
		Set_Next_State("State_Attack_Data_Cleanup")
		return
	end
	
	ActingAIPlayer = ai_player
	AttackHero, AttackForce = Get_Hit_And_Run_Force(ai_player)
	AttackTarget = Get_Hit_And_Run_Target()
	
	if not TestValid(AttackHero) or not AttackForce or not TestValid(AttackTarget) then
		Action_Failed()
		Set_Next_State("State_Attack_Data_Cleanup")
	else		
		Set_Next_State("State_Attack")
	end
end

function Get_Hit_And_Run_Force(ai_player)
	local faction = ai_player.Get_Faction_Name()
	local hero = nil
	local unit_table = nil
	
	if faction == "NOVUS" then
		hero = Find_First_Object("Novus_Hero_Vertigo")
	elseif faction == "ALIEN" then
		hero = Find_First_Object("Alien_Hero_Nufai")
	else
		hero = Find_First_Object("Masari_Hero_Zessus")
	end
	
	unit_table = {	Select_Unit(ai_player, LightVehicles[faction]),
						Select_Unit(ai_player, LightVehicles[faction]),  
						Select_Unit(ai_player, HeavyInfantry[faction]),  
						Select_Unit(ai_player, LightInfantry[faction]),  
						Select_Unit(ai_player, LightInfantry[faction]),  
						Select_Unit(ai_player, LightInfantry[faction]),  
						Select_Unit(ai_player, LightInfantry[faction])	}	
						
	return hero, unit_table
end

function Get_Hit_And_Run_Target()
	--Only bother with these vs humans
	local all_targets = DiscreteDistribution.Create()
	
	local human_player = Find_Player("local")
	local all_objects = Find_All_Objects_Of_Type(human_player)
	for _, object in pairs(all_objects) do
		local object_type = object.Get_Type()
		if Is_Region_Defense(object_type) then
			--Favorite targets are base defense
			all_targets.Insert(object.Get_Region_In(), 3.0)
		elseif Is_Megaweapon_Defense(object_type) then
			--Next favorite target are megaweapon countermeasures
			all_targets.Insert(object.Get_Region_In(), 2.0)
		elseif object.Has_Behavior(BEHAVIOR_HARD_POINT) and not object_type.Get_Type_Value("HP_Is_Immune_To_Damage") then
			--Fallback targets are any strategic upgrade.  Be sure not to attack unkillable empty sockets
			local structure = object.Get_Highest_Level_Hard_Point_Parent()
			if TestValid(structure) and not Is_Headquarters(human_player, structure.Get_Type()) then
				--Don't attack the HQ - it's too well defended
				all_targets.Insert(object.Get_Region_In(), 1.0)
			end
		end
	end
	
	return all_targets.Sample()
end

---------------------------------------------------------------------------------------------------------------------------------
--State sequence to claim neutral regions
---------------------------------------------------------------------------------------------------------------------------------
function Land_Grab(ai_player)
	ActingAIPlayer = ai_player
	AttackHero, AttackForce = Get_Land_Grab_Force(ai_player)
	AttackTarget = Get_Land_Grab_Target(AttackHero)
	
	if not TestValid(AttackHero) or not AttackForce or not TestValid(AttackTarget) then
		Action_Failed()
		Set_Next_State("State_Attack_Data_Cleanup")
	else		
		Set_Next_State("State_Attack")
	end
end

function Get_Land_Grab_Force(ai_player)
	local faction = ai_player.Get_Faction_Name()
	local hero = nil
	local unit_table = nil
	
	if faction == "NOVUS" then
		hero = Find_First_Object("Novus_Hero_Vertigo")
		if not TestValid(hero) then
			hero = Find_First_Object("Novus_Hero_Founder")
		end
		if not TestValid(hero) then
			hero = Find_First_Object("Novus_Hero_Mech")
		end
	elseif faction == "ALIEN" then
		hero = Find_First_Object("Alien_Hero_Nufai")
		if not TestValid(hero) then
			hero = Find_First_Object("Alien_Hero_Kamal_Rex")
		end
		if not TestValid(hero) then
			hero = Find_First_Object("Alien_Hero_Orlok")
		end
	else
		hero = Find_First_Object("Masari_Hero_Zessus")
		if not TestValid(hero) then
			hero = Find_First_Object("Masari_Hero_Alatea")
		end
		if not TestValid(hero) then
			hero = Find_First_Object("Masari_Hero_Charos")
		end
	end	
	
	unit_table = {	Select_Unit(ai_player, LightVehicles[faction]),
						Select_Unit(ai_player, LightVehicles[faction]),  
						Select_Unit(ai_player, LightInfantry[faction]),  
						Select_Unit(ai_player, LightInfantry[faction])	}	
						
	return hero, unit_table
end

function Get_Land_Grab_Target(hero)

	if not TestValid(hero) then
		return nil
	end
	local region = hero.Get_Region_In()
	if not TestValid(region) then
		return nil
	end
	
	--Prefer regions reachable in one hop
	local best_target = nil
	local all_regions = region.Find_Regions_Within(hero.Get_Type().Get_Type_Value("Travel_Range"))
	for _, possible_target in pairs(all_regions) do
	
		--Prefer neutral regions
		local target_owner = possible_target.Get_Owner()
		if target_owner.Is_Neutral() then
			return possible_target
		end
	end
	
	--Return the nearest neutral region
	local target_player = Find_Player("Neutral")
	return region.Find_Closest_Friendly_Region_For_Player(target_player)
end

---------------------------------------------------------------------------------------------------------------------------------
--State sequence to fire off a megaweapon
---------------------------------------------------------------------------------------------------------------------------------
function Fire_Megaweapon(ai_player)
	local all_megaweapons = Find_All_Objects_Of_Type(MegaweaponCCTypeTable[ai_player.Get_Faction_Name()], ai_player)
	local weapon_to_fire = nil
	for _, megaweapon in pairs(all_megaweapons) do
		local weapon_script = megaweapon.Get_Script()
		if weapon_script then
			local cooldown_data = weapon_script.Call_Function("Get_Megaweapon_Cooldown")
			if cooldown_data.EndTime <= 0 then
				--This weapon is ready!  Hold on to the script
				weapon_to_fire = weapon_script
			end
		end
	end
	
	if weapon_to_fire then
		local target_region = Get_Megaweapon_Target(ai_player)
		if TestValid(target_region) then
			weapon_to_fire.Call_Function("Fire_Megaweapon_At_Region", target_region)
			Set_Next_State("State_Idle")
			return
		end
	end
	
	--Failed to fire a megaweapon?  Pick a new action straight away
	Action_Failed()
	Set_Next_State("State_Idle")
end

function Get_Megaweapon_Target(player)
	--Fire at a random target for now.  Exclude HQ region though.
	local human_player = Find_Player("local")
	local possible_targets = {}
	for _, object in pairs(AllRegions) do
		local command_center = object.Get_Command_Center()
		if TestValid(command_center) and not Is_Headquarters(command_center.Get_Owner(), command_center.Get_Type()) then
			table.insert(possible_targets, object)
		end
	end
	
	local target_count = #possible_targets
	if target_count > 0 then
		return possible_targets[GameRandom(1, target_count)]
	else
		return nil
	end
end

---------------------------------------------------------------------------------------------------------------------------------
--State sequence to use a global spy hard point
---------------------------------------------------------------------------------------------------------------------------------
function Use_Spy(ai_player)
	local all_spies = Find_All_Objects_Of_Type(SpyTypeTable[ai_player.Get_Faction_Name()], ai_player)
	local spy_to_use = nil
	for _, spy in pairs(all_spies) do
		local spy_script = spy.Get_Script()
		if spy_script then
			local cooldown_data = spy_script.Call_Function("Get_Megaweapon_Cooldown")
			if cooldown_data.EndTime <= 0 then
				--This weapon is ready!  Hold on to the script
				spy_to_use = spy_script
			end
		end
	end
	
	if spy_to_use then
		local target_region = Get_Spy_Target(ai_player)
		if TestValid(target_region) then
			spy_to_use.Call_Function("Fire_Megaweapon_At_Region", target_region)
			Set_Next_State("State_Idle")
			return
		end
	end
	
	--Failed to fire a megaweapon?  Pick a new action straight away
	Action_Failed()
	Set_Next_State("State_Idle")
end

function Get_Spy_Target(player)
	--Fire at a random, unspied, target for now
	local possible_targets = {}
	for _, object in pairs(AllRegions) do
		local owner = object.Get_Owner()
		if owner ~= player and not owner.Is_Neutral() then
			if object.Get_Strategic_FOW_Level(player) == 0 then
				table.insert(possible_targets, object)
			end
		end
	end
	
	local target_count = #possible_targets
	if target_count > 0 then
		return possible_targets[GameRandom(1, target_count)]
	else
		return nil
	end
end

function Upgrade_Command_Center(ai_player)
	--First try to upgrade the HQ
	local hq_type = ai_player.Get_Faction_Value("Headquarters_Type")
	if Upgrade_A_Command_Center_Of_Type(ai_player, hq_type) then
		Set_Next_State("State_Idle")
		return
	end
	
	--Then try for regular command centers working in normal personality-based build order.
	local faction_name = ai_player.Get_Faction_Name()
	local cc_order = table.copy(CommandCenterOrder[AIPersonalities[ai_player]])
	for _, cc_type_table in pairs(cc_order) do
		if Upgrade_A_Command_Center_Of_Type(ai_player, cc_type_table[faction_name]) then
			Set_Next_State("State_Idle")
			return
		end
	end
	
	--Failure!
	Action_Failed()
	Set_Next_State("State_Idle")
end

function Upgrade_A_Command_Center_Of_Type(player, type, filter_function)
	local cc_objects = Find_All_Objects_Of_Type(type, player)
	for _, command_center in pairs(cc_objects) do
	
		local region = command_center.Get_Region_In()
		if TestValid(region) then
			local existing_upgrades = command_center.Get_Strategic_Structure_Socket_Upgrades()
			local empty_socket_type = command_center.Get_Type().Get_Type_Value("Empty_Upgrade_Socket_Type")
			local is_available = false
			for _, upgrade in pairs(existing_upgrades) do
				if not TestValid(upgrade) or upgrade.Get_Type() == empty_socket_type then
					is_available = true
				end
			end
		
			if is_available then
				local upgrade_type = nil
				local upgrades_list = command_center.Get_Available_Strategic_Buildable_Upgrades()
				if filter_function then
					for _, possible_upgrade in pairs(upgrades_list) do
						if possible_upgrade[2] then	
							if filter_function(possible_upgrade[1]) then
								upgrade_type = possible_upgrade[1]
							end
						end
					end
				else
					local upgrades_count = #upgrades_list
					if upgrades_count > 0 then
						upgrade_type = upgrades_list[GameRandom(1, upgrades_count)][1]
					end
				end
				
				if upgrade_type then
					--Leave out the socket index to allow code to pick any open socket
					if Global_Begin_Production(player, region, upgrade_type, command_center) then
						return true
					end
				end
			end
		end
		
	end
	
	return false
end

function Build_Megaweapon_Defense(ai_player)
	--First try to upgrade the HQ
	local hq_type = ai_player.Get_Faction_Value("Headquarters_Type")
	if Upgrade_A_Command_Center_Of_Type(ai_player, hq_type, Is_Megaweapon_Defense) then
		Set_Next_State("State_Idle")
		return
	end
	
	--Then try for regular command centers working in normal personality-based build order.
	local faction_name = ai_player.Get_Faction_Name()
	local cc_order = table.copy(CommandCenterOrder[AIPersonalities[ai_player]])
	for _, cc_type_table in pairs(cc_order) do
		if Upgrade_A_Command_Center_Of_Type(ai_player, cc_type_table[faction_name], Is_Megaweapon_Defense) then
			Set_Next_State("State_Idle")
			return
		end
	end
	
	--Failure!
	Action_Failed()
	Set_Next_State("State_Idle")
end

---------------------------------------------------------------------------------------------------------------------------------
-- Personality tables
---------------------------------------------------------------------------------------------------------------------------------
function Define_Aggressive_Actions()
	local action_table = {}
	
	action_table[NEUTRAL_REGION_CAPTURED] = DiscreteDistribution.Create()
	action_table[NEUTRAL_REGION_CAPTURED].Insert(Use_Spy, 1.0)		
	
	action_table[MY_REGION_CAPTURED] = DiscreteDistribution.Create()
	action_table[MY_REGION_CAPTURED].Insert(Retaliation, 1.0)
	action_table[MY_REGION_CAPTURED].Insert(Fire_Megaweapon, 1.0)

	action_table[GENERIC_COMMAND_CENTER_BUILT] = DiscreteDistribution.Create()
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Conquest, 1.0)
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Hit_And_Run, 1.0)
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Upgrade_Command_Center, 0.5)
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Use_Spy, 0.5)

	action_table[MEGAWEAPON_BUILT] = DiscreteDistribution.Create()
	action_table[MEGAWEAPON_BUILT].Insert(Hit_And_Run, 1.0)
	action_table[MEGAWEAPON_BUILT].Insert(Conquest, 0.5)
	action_table[MEGAWEAPON_BUILT].Insert(Build_Megaweapon_Defense, 0.5)
	
	action_table[MEGAWEAPON_FIRED] = DiscreteDistribution.Create()
	action_table[MEGAWEAPON_FIRED].Insert(Retaliation, 1.0)
	action_table[MEGAWEAPON_FIRED].Insert(Hit_And_Run, 1.0)
	action_table[MEGAWEAPON_FIRED].Insert(Conquest, 0.5)
	action_table[MEGAWEAPON_FIRED].Insert(Build_Megaweapon_Defense, 0.5)
	
	action_table[IDLE_TIME_OUT] = DiscreteDistribution.Create()
	action_table[IDLE_TIME_OUT].Insert(Conquest, 1.0)
	action_table[IDLE_TIME_OUT].Insert(Hit_And_Run, 1.0)
	action_table[IDLE_TIME_OUT].Insert(Fire_Megaweapon, 1.0)
	action_table[IDLE_TIME_OUT].Insert(Upgrade_Command_Center, 1.5)		
	action_table[IDLE_TIME_OUT].Insert(Land_Grab, 1.0)		
	action_table[IDLE_TIME_OUT].Insert(Use_Spy, 0.5)		
		
	return action_table
end

function Define_Turtle_Actions()
	local action_table = {}
	
	action_table[NEUTRAL_REGION_CAPTURED] = DiscreteDistribution.Create()
	action_table[NEUTRAL_REGION_CAPTURED].Insert(Use_Spy, 0.5)		
	
	action_table[MY_REGION_CAPTURED] = DiscreteDistribution.Create()
	action_table[MY_REGION_CAPTURED].Insert(Conquest, 1.0)
	action_table[MY_REGION_CAPTURED].Insert(Retaliation, 1.0)
	action_table[MY_REGION_CAPTURED].Insert(Fire_Megaweapon, 1.0)
	
	action_table[GENERIC_COMMAND_CENTER_BUILT] = DiscreteDistribution.Create()
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Upgrade_Command_Center, 1.0)
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Conquest, 0.5)
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Use_Spy, 0.5)

	action_table[MEGAWEAPON_BUILT] = DiscreteDistribution.Create()
	action_table[MEGAWEAPON_BUILT].Insert(Build_Megaweapon_Defense, 1.0)
	action_table[MEGAWEAPON_BUILT].Insert(Conquest, 0.5)
	
	action_table[MEGAWEAPON_FIRED] = DiscreteDistribution.Create()
	action_table[MEGAWEAPON_FIRED].Insert(Build_Megaweapon_Defense, 1.0)
	action_table[MEGAWEAPON_FIRED].Insert(Conquest, 0.5)
	action_table[MEGAWEAPON_FIRED].Insert(Retaliation, 0.5)
	
	action_table[IDLE_TIME_OUT] = DiscreteDistribution.Create()
	action_table[IDLE_TIME_OUT].Insert(Conquest, 1.0)
	action_table[IDLE_TIME_OUT].Insert(Upgrade_Command_Center, 1.5)		
	action_table[IDLE_TIME_OUT].Insert(Fire_Megaweapon, 0.5)
	action_table[IDLE_TIME_OUT].Insert(Land_Grab, 1.0)		
	action_table[IDLE_TIME_OUT].Insert(Use_Spy, 0.5)		
	
	return action_table
end

function Define_Devious_Actions(event_type)
	local action_table = {}
	
	action_table[NEUTRAL_REGION_CAPTURED] = DiscreteDistribution.Create()
	action_table[NEUTRAL_REGION_CAPTURED].Insert(Use_Spy, 1.0)		
	
	action_table[MY_REGION_CAPTURED] = DiscreteDistribution.Create()
	action_table[MY_REGION_CAPTURED].Insert(Hit_And_Run, 1.0)
	action_table[MY_REGION_CAPTURED].Insert(Retaliation, 1.0)
	action_table[MY_REGION_CAPTURED].Insert(Fire_Megaweapon, 1.0)
	
	action_table[GENERIC_COMMAND_CENTER_BUILT] = DiscreteDistribution.Create()
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Hit_And_Run, 1.0)
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Upgrade_Command_Center, 0.5)
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Conquest, 0.5)
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Use_Spy, 1.0)

	action_table[MEGAWEAPON_BUILT] = DiscreteDistribution.Create()
	action_table[MEGAWEAPON_BUILT].Insert(Hit_And_Run, 1.0)
	action_table[MEGAWEAPON_BUILT].Insert(Build_Megaweapon_Defense, 0.5)
	action_table[MEGAWEAPON_BUILT].Insert(Conquest, 0.5)
	
	action_table[MEGAWEAPON_FIRED] = DiscreteDistribution.Create()
	action_table[MEGAWEAPON_FIRED].Insert(Hit_And_Run, 1.0)
	action_table[MEGAWEAPON_FIRED].Insert(Build_Megaweapon_Defense, 0.5)
	action_table[MEGAWEAPON_FIRED].Insert(Conquest, 0.5)
	action_table[MEGAWEAPON_FIRED].Insert(Retaliation, 0.5)
	
	action_table[IDLE_TIME_OUT] = DiscreteDistribution.Create()
	action_table[IDLE_TIME_OUT].Insert(Hit_And_Run, 1.0)
	action_table[IDLE_TIME_OUT].Insert(Conquest, 1.0)
	action_table[IDLE_TIME_OUT].Insert(Upgrade_Command_Center, 1.5)		
	action_table[IDLE_TIME_OUT].Insert(Fire_Megaweapon, 0.5)
	action_table[IDLE_TIME_OUT].Insert(Land_Grab, 1.0)		
	action_table[IDLE_TIME_OUT].Insert(Use_Spy, 1.0)		
		
	return action_table
end

function Define_Balanced_Actions(event_type)
	local action_table = {}
	
	action_table[NEUTRAL_REGION_CAPTURED] = DiscreteDistribution.Create()
	action_table[NEUTRAL_REGION_CAPTURED].Insert(Use_Spy, 1.0)		
	
	action_table[MY_REGION_CAPTURED] = DiscreteDistribution.Create()
	action_table[MY_REGION_CAPTURED].Insert(Hit_And_Run, 1.0)
	action_table[MY_REGION_CAPTURED].Insert(Conquest, 1.0)
	action_table[MY_REGION_CAPTURED].Insert(Retaliation, 1.0)
	action_table[MY_REGION_CAPTURED].Insert(Fire_Megaweapon, 1.0)
	
	action_table[GENERIC_COMMAND_CENTER_BUILT] = DiscreteDistribution.Create()
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Hit_And_Run, 1.0)
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Upgrade_Command_Center, 1.0)
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Conquest, 1.0)
	action_table[GENERIC_COMMAND_CENTER_BUILT].Insert(Use_Spy, 1.0)

	action_table[MEGAWEAPON_BUILT] = DiscreteDistribution.Create()
	action_table[MEGAWEAPON_BUILT].Insert(Hit_And_Run, 1.0)
	action_table[MEGAWEAPON_BUILT].Insert(Build_Megaweapon_Defense, 1.0)
	action_table[MEGAWEAPON_BUILT].Insert(Conquest, 1.0)
	
	action_table[MEGAWEAPON_FIRED] = DiscreteDistribution.Create()
	action_table[MEGAWEAPON_FIRED].Insert(Hit_And_Run, 1.0)
	action_table[MEGAWEAPON_FIRED].Insert(Build_Megaweapon_Defense, 1.0)
	action_table[MEGAWEAPON_FIRED].Insert(Conquest, 1.0)
	action_table[MEGAWEAPON_FIRED].Insert(Retaliation, 1.0)
	
	action_table[IDLE_TIME_OUT] = DiscreteDistribution.Create()
	action_table[IDLE_TIME_OUT].Insert(Hit_And_Run, 1.0)
	action_table[IDLE_TIME_OUT].Insert(Conquest, 1.0)
	action_table[IDLE_TIME_OUT].Insert(Upgrade_Command_Center, 1.5)		
	action_table[IDLE_TIME_OUT].Insert(Fire_Megaweapon, 1.0)
	action_table[IDLE_TIME_OUT].Insert(Land_Grab, 1.0)		
	action_table[IDLE_TIME_OUT].Insert(Use_Spy, 1.0)		
		
	return action_table
end

function Define_Aggressive_Follow_Ups()
	local follow_up_table = {}
	follow_up_table[Upgrade_Command_Center] = Conquest
	follow_up_table[Build_Megaweapon_Defense] = Conquest
	follow_up_table[Fire_Megaweapon] = Conquest
	follow_up_table[Use_Spy] = Conquest
	
	return follow_up_table
end

function Define_Turtle_Follow_Ups()
	local follow_up_table = {}
	
	follow_up_table[Conquest] = Upgrade_Command_Center
	follow_up_table[Retaliation] = Upgrade_Command_Center
	follow_up_table[Hit_And_Run] = Upgrade_Command_Center
	follow_up_table[Use_Spy] = Conquest	

	return follow_up_table
end

function Define_Devious_Follow_Ups()
	local follow_up_table = {}
	
	follow_up_table[Hit_And_Run] = Conquest
	follow_up_table[Fire_Megaweapon] = Conquest
	follow_up_table[Use_Spy] = Conquest	
	
	return follow_up_table
end

function Define_Balanced_Follow_Ups()
	return {}
end

function Define_Aggressive_Command_Center_Order()
	local cc_order = {}
	cc_order[1] = ProductionCCTypeTable
	cc_order[2] = ResourceCCTypeTable
	cc_order[3] = ResearchCCTypeTable
	return cc_order
end

function Define_Turtle_Command_Center_Order()
	local cc_order = {}
	cc_order[1] = ResearchCCTypeTable
	cc_order[2] = ProductionCCTypeTable
	cc_order[3] = ResourceCCTypeTable
	return cc_order
end

function Define_Devious_Command_Center_Order()
	local cc_order = {}
	cc_order[1] = ProductionCCTypeTable
	cc_order[2] = ResearchCCTypeTable
	cc_order[3] = ResourceCCTypeTable
	return cc_order
end  

function Define_Balanced_Command_Center_Order()
	local cc_order = {}
	cc_order[1] = ResourceCCTypeTable
	cc_order[2] = ProductionCCTypeTable
	cc_order[3] = ResearchCCTypeTable
	return cc_order
end  

function Get_Aggressive_Min_Regions_For_Megaweapon()
	return 9
end

function Get_Turtle_Min_Regions_For_Megaweapon()
	return 13
end

function Get_Devious_Min_Regions_For_Megaweapon()
	return 10
end

function Get_Balanced_Min_Regions_For_Megaweapon()
	return 9
end

function Post_Load_Callback()
	--Make sure that we can still call Game Scoring commands after a load
	Register_Game_Scoring_Commands()
end
