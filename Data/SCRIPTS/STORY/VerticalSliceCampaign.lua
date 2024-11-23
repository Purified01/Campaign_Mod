-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/VerticalSliceCampaign.lua#26 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/VerticalSliceCampaign.lua $
--
--    Original Author: Steve Copeland
--
--            $Author: Chris_Brooks $
--
--            $Change: 45307 $
--
--          $DateTime: 2006/05/26 14:19:26 $
--
--          $Revision: #26 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")
require("PGMovieCommands")
require("UIControl")

-- DON'T REMOVE! Needed for objectives to function properly, even when they are 
-- called from other scripts. (The data is stored here.)
require("PGObjectives")

---------------------------------------------------------------------------------------------------

function Definitions()
	--MessageBox("%s -- definitions", tostring(Script))
	
	Define_State("State_Init", State_Init)
	Define_State("State_Begin_Global_Research", State_Begin_Global_Research)
	Define_State("State_Refill_Strike_Force", State_Refill_Strike_Force)
	Define_State("State_Complete_Research", State_Complete_Research)
	Define_State("State_Initiate_Second_Attack", State_Initiate_Second_Attack)
	Define_State("State_Mission1_Failed", State_Mission1_Failed)

	num_for_full_fleet = 15
	objective_repeat_delay = 120
end

---------------------------------------------------------------------------------------------------

function State_Init(message)
	if message == OnEnter then

		hero_tank = Find_First_Object("Military_Hero_Tank")
		hero_tank_fleet = hero_tank.Get_Parent_Object()
		
		-- Maria 05.17.2006
		-- Adding this so we can retreat the hero fleet from the enemy region at the end of act 1.
		region_of_origin = hero_tank_fleet.Get_Parent_Object()
		
		if not hero_tank_fleet then
			MessageBox("unable to find hero_tank_fleet")
		end
	
		-- Spawn a non-gameplay scientist object to reserve a hero icon and PIP
		region = Find_First_Object("Region27")
		UEA = Find_Player("Military")
		chief_scientist_type = Find_Object_Type("Military_Hero_Chief_Scientist_PIP_Only")
		hero_chief_scientist = Create_Generic_Object(chief_scientist_type, region, UEA)

		-- Trigger an invasion (campaign starts in tactical)
		--[[
		Stop_All_Music()
		Play_Music("Military_Strategic_Map_Music_Event")
		Force_Land_Invasion(region, hero_tank.Get_Parent_Object(), UEA, true)
		--]]
	elseif message == OnUpdate then
		if mission1_successful then
			Set_Next_State("State_Begin_Global_Research")
		elseif mission1_failed then
			Set_Next_State("State_Mission1_Failed")
		end
	end
end

---------------------------------------------------------------------------------------------------

function State_Begin_Global_Research(message)

	if message == OnEnter then

		Sleep(3)

		-- Spawn this guy to reserve a PIP
		comm_officer_type = Find_Object_Type("Military_Hero_Comm_Officer_PIP_Only")
		hero_comm_officer = Create_Generic_Object(comm_officer_type, region, UEA)
		
		if not research_begun then

			BlockOnCommand(Start_Hero_Movie(hero_tank, "MIVS_ZEN0200_ENG")) 						-- ZENZO (belligerent): Doctor, you need to identify its weakness. That walker will level the city if we dont take it out.
			BlockOnCommand(Start_Hero_Movie(hero_chief_scientist, "MIVS_CSI0201_ENG"))			-- CHIEF SCIENTIST: All right, Ill try. But Im not making any promises.
			
			objective_research = Add_Objective("Research the alien data.")
			
			-- Give the player feedback on how to initiate research, if needed
			if not research_panel_opened then
				UI_Start_Flash_Hero("Military_Hero_Chief_Scientist_PIP_Only")
			end
			
			Register_Timer(Repeat_Hero_Movie, objective_repeat_delay, {hero_chief_scientist, "MIVS_CSI0203_ENG"})	-- CHIEF SCIENTIST: Ive got to stay focused and start my research! Or this will be the shortest war in history.
		end

	elseif message == OnUpdate then
	
		if research_begun then
		
			-- Not completing objective until the research is actually finished.
			Cancel_Timer(Repeat_Hero_Movie)
			Set_Next_State("State_Refill_Strike_Force")
		elseif research_panel_opened and not already_opened_panel then
		
			already_opened_panel = true
			
-- Removed for brevity.
--			BlockOnCommand(Start_Hero_Movie(hero_chief_scientist, "MIVS_CSI0204_ENG"))			-- CHIEF SCIENTIST: The aliens deflectors may be sophisticated, but no defense is impenetrable. Forget the science. Exploits require creativity.		
		end		
	end

end


---------------------------------------------------------------------------------------------------

function State_Refill_Strike_Force(message)
	if message == OnEnter then

		Sleep(1)
		
-- Yanking this line to save some time.
--		BlockOnCommand(Start_Hero_Movie(hero_comm_officer, "MIVS_COM0205_ENG"))		-- COMM. OFF.: I'm picking up all kinds of frantic transmissions, Commander. There are a lot of folks trapped down there.
		BlockOnCommand(Start_Hero_Movie(hero_tank, "MIVS_ZEN0206_ENG")) 				-- ZENZO: If we intend to save that city, well need to drum up some support.
		BlockOnCommand(Start_Hero_Movie(hero_comm_officer, "MIVS_COM0207_ENG"))		-- COMM. OFF.: We have several units in the area, sir. Ill get them on the horn.

		Register_Timer(Repeat_Hero_Movie, objective_repeat_delay, {hero_comm_officer, "MIVS_COM0209_ENG"})	-- COMM. OFF.: We need to pull troops from nearby territories if we're going to have a chance against that walker.

		-- Set hero fleet fill objective and details
		objective_fill_strike_force = Add_Objective("Refill the strike force.")
		objective_num_required = Add_Objective("")

	elseif message == OnUpdate then

		-- Make sure the player has adequately filled the hero fleet
		Create_Thread("Thread_Monitor_Fleet_Fill")

		if research_complete then
			Set_Next_State("State_Complete_Research")
		end
	end
end



---------------------------------------------------------------------------------------------------

function State_Complete_Research(message)
	if message == OnEnter then

		BlockOnCommand(Start_Hero_Movie(hero_chief_scientist, "MIVS_CSI0210_ENG")) 		-- CHIEF SCIENTIST: I think Ive found your flaw, Commander. In the deflectors.
		BlockOnCommand(Start_Hero_Movie(hero_tank, "MIVS_ZEN0211_ENG")) 					-- ZENZO: How long to deploy the counter?
		Start_Hero_Movie(hero_chief_scientist, "MIVS_CSI0212_ENG")						-- CHIEF SCIENTIST: We can broadcast the jamming signal immediately-
		Sleep(2) 																					-- <Interrupts>
		BlockOnCommand(Start_Hero_Movie(hero_tank, "MIVS_ZEN0213_ENG") ) 					-- ZENZO: Then lets get to it.
		Start_Hero_Movie(hero_chief_scientist, "MIVS_CSI0214_ENG")						-- CHIEF SCIENTIST: I wasnt finished, sir--
		Sleep(0.9)																					-- <Interrupts more abruptly and crosstalk>
		BlockOnCommand(Start_Hero_Movie(hero_tank, "MIVS_ZEN0215_ENG")) 					-- ZENZO: Yes you were. Were going back in.
		
	elseif message == OnUpdate then

		if fleet_filled then
			Set_Next_State("State_Initiate_Second_Attack")
		end
	end
end

---------------------------------------------------------------------------------------------------

function State_Initiate_Second_Attack(message)
	if message == OnEnter then

		objective_deploy_to_cali = Add_Objective("Take the strike force back and destroy the walker.")

	elseif message == OnUpdate then

		-- ... just waiting for the player to initiate the attack.		
	end
end

---------------------------------------------------------------------------------------------------
---- Event Handlers

function On_Land_Invasion()
	--MessageBox("%s -- In On_Land_Invasion()", tostring(Script));

	--MessageBox("%s -- Location: %s, Invader: %s, OverrideMap: %s", tostring(Script), tostring(InvasionInfo.Location), 
	--	tostring(InvasionInfo.Invader), tostring(InvasionInfo.OverrideMapName))

	-- DEBUG SKIP TO ACT 3
	-- FirstInvasionDone = true

	if FirstInvasionDone == nil then
		--MessageBox("%s -- setting verticalsliceMission1 script", tostring(Script));	

		-- Use the native map for the region and associate the mission script.
		InvasionInfo.TacticalScript = "VerticalSliceMission1"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = true
	else
		InvasionInfo.OverrideMapName = "./Data/Art/Maps/Invasion_Demo_4_Act_3.ted"
		InvasionInfo.TacticalScript = "VerticalSliceMission3"
		InvasionInfo.UseStrategicPersistence = false
		InvasionInfo.UseStrategicProductionRules = true
		
		-- Clean up the lingering objectives
		Delete_Objective(objective_deploy_to_cali)
	end

	FirstInvasionDone = true
end

function On_Research_Accessed()
	research_panel_opened = true
end

function On_Research_Begin()
	research_begun = true
end

function On_Research_Complete()
	research_complete = true
	Objective_Complete(objective_research)
end

function On_Fleet_Move_Begin(start_fleet, destination_region, destination_fleet)
	if hero_tank_fleet and (destination_fleet == hero_tank_fleet) then
		reinforcements_sent = true
	end
end


function Thread_Monitor_Fleet_Fill()
	while not fleet_filled do
		num_in_fleet = hero_tank_fleet.Get_Contained_Object_Count()
		if num_in_fleet >= num_for_full_fleet then

			-- Wrap up this objective.		
			fleet_filled = true
			Cancel_Timer(Repeat_Hero_Movie)
			Objective_Complete(objective_fill_strike_force)
			Delete_Objective(objective_num_required)
		else

			 -- Update the fill hero fleet objective details	 
			num_needed = Clamp(num_for_full_fleet - num_in_fleet, 0, 100)
			fill_fleet_string = string.format("%d more required.", num_needed)
			Set_Objective_Text(objective_num_required, fill_fleet_string)
		end

		Sleep(1)		
	end
end



---------------------------------------------------------------------------------------------------

-- DEBUG: Move this to a library?
function Repeat_Hero_Movie(params)

	-- Play the bink movie, fire and forget (no blocking)
	hero = params[1]
	bink_filename = params[2]
    Start_Hero_Movie(hero, bink_filename)
	
	-- Repeat until we issue a Cancel_Timer on this funciton
	Register_Timer(Repeat_Hero_Movie, objective_repeat_delay, params)
end

-- Custom event fired by campaign script.
function On_Mission_1_Over(victorious)
	if victorious then
		mission1_successful = true
		Fake_Tech_Acquisition()
		Retreat_To_Region(region_of_origin, hero_tank.Get_Parent_Object(), UEA)
	else
		mission1_failed = true
	end
end

function State_Mission1_Failed(message)
	if message == OnEnter then
		Get_Game_Mode_GUI_Scene().Raise_Event_Immediate("Set_Announcement_Text", nil, {"You have been defeated."} )
		Sleep(5)
	end
end

-- Hack to bypass tactical tech item acquisition requirement for research.
function Fake_Tech_Acquisition()
	local tech_object = Find_Object_Type("ALIEN_TECH_DROP_1") 
	local player_script = UEA.Get_Script()
	dummy_tech = Create_Generic_Object(tech_object, region, UEA)
	research_duration = 15
	player_script.Call_Function("Acquire_Tech_Object", dummy_tech, research_duration)
end

---------------------------------------------------------------------------------------------------