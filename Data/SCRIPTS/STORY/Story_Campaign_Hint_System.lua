-- $Id: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hint_System.lua#13 $
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
--              $File: //depot/Projects/Invasion/Run/Data/Scripts/Story/Story_Campaign_Hint_System.lua $
--
--    Original Author: Rick Donnelly
--
--            $Author: Rich_Donnelly $
--
--            $Change: 74794 $
--
--          $DateTime: 2007/06/28 17:21:25 $
--
--          $Revision: #13 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGHintSystem")
require("PGHintSystemDefs")

-- Don't pool story scripts.
ScriptPoolCount = 0


function On_Construction_Complete(obj, constructor)
	if TestValid(obj) then	
		if obj.Get_Owner() == Find_Player("local") then
			obj_type = obj.Get_Type()
			
			PGHintSystemDefs_Init()
			PGHintSystem_Init()
			
			-- Novus Construction Hints
			if obj_type == Find_Object_Type("NOVUS_REFLEX_TROOPER") then
				Add_Attached_Hint(obj, HINT_BUILT_NOVUS_REFLEX_TROOPER)

			elseif obj_type == Find_Object_Type("NOVUS_ROBOTIC_INFANTRY") then
				Add_Attached_Hint(obj, HINT_BUILT_NOVUS_ROBOTIC_INFANTRY)

			elseif obj_type == Find_Object_Type("NOVUS_VARIANT") then
				Add_Attached_Hint(obj, HINT_BUILT_NOVUS_VARIANT)

			elseif obj_type == Find_Object_Type("NOVUS_AMPLIFIER") then
				Add_Attached_Hint(obj, HINT_BUILT_NOVUS_AMPLIFIER)

			elseif obj_type == Find_Object_Type("NOVUS_ANTIMATTER_TANK") then
				Add_Attached_Hint(obj, HINT_BUILT_NOVUS_ANTIMATTER_TANK)

			elseif obj_type == Find_Object_Type("NOVUS_CONSTRUCTOR") then
				Add_Attached_Hint(obj, HINT_BUILT_NOVUS_CONSTRUCTOR)

			elseif obj_type == Find_Object_Type("NOVUS_DERVISH_JET") then
				Add_Attached_Hint(obj, HINT_BUILT_NOVUS_DERVISH_JET)

			elseif obj_type == Find_Object_Type("NOVUS_FIELD_INVERTER") then
				Add_Attached_Hint(obj, HINT_BUILT_NOVUS_FIELD_INVERTER)
				
			elseif obj_type == Find_Object_Type("NOVUS_HACKER") then
				Add_Attached_Hint(obj, HINT_BUILT_NOVUS_HACKER)

			elseif obj_type == Find_Object_Type("NOVUS_CORRUPTOR") then
				Add_Attached_Hint(obj, HINT_BUILT_NOVUS_CORRUPTOR)


			-- Hierarchy Construction Hints
			elseif obj_type == Find_Object_Type("ALIEN_BRUTE") then
				Add_Attached_Hint(obj, HINT_BUILT_ALIEN_BRUTE)

			elseif obj_type == Find_Object_Type("ALIEN_GLYPH_CARVER") then
				Add_Attached_Hint(obj, HINT_BUILT_ALIEN_GLYPH_CARVER)

			elseif obj_type == Find_Object_Type("ALIEN_GRUNT") then
				Add_Attached_Hint(obj, HINT_BUILT_ALIEN_GRUNT)

			elseif obj_type == Find_Object_Type("ALIEN_LOST_ONE") then
				Add_Attached_Hint(obj, HINT_BUILT_ALIEN_SCIENCE_TEAM)

			elseif obj_type == Find_Object_Type("ALIEN_CYLINDER") then
				Add_Attached_Hint(obj, HINT_BUILT_ALIEN_CYLINDER)

			elseif obj_type == Find_Object_Type("ALIEN_DEFILER") then
				Add_Attached_Hint(obj, HINT_BUILT_ALIEN_DEFILER)

			elseif obj_type == Find_Object_Type("ALIEN_FOO_CORE") then
				Add_Attached_Hint(obj, HINT_BUILT_ALIEN_SAUCER)

			elseif obj_type == Find_Object_Type("ALIEN_SUPERWEAPON_REAPER_TURRET") then
				Add_Attached_Hint(obj, HINT_BUILT_ALIEN_REAPER_TURRET)

			elseif obj_type == Find_Object_Type("ALIEN_RECON_TANK") then
				Add_Attached_Hint(obj, HINT_BUILT_ALIEN_TANK)
				
				
			-- Masari Construction Hints
			elseif obj_type == Find_Object_Type("MASARI_FIGMENT") then
				Add_Attached_Hint(obj, HINT_BUILT_MASARI_FIGMENT)

			elseif obj_type == Find_Object_Type("MASARI_SEEKER") then
				Add_Attached_Hint(obj, HINT_BUILT_MASARI_SEEKER)

			elseif obj_type == Find_Object_Type("MASARI_SKYLORD") then
				Add_Attached_Hint(obj, HINT_BUILT_MASARI_SKYLORD)

			elseif obj_type == Find_Object_Type("MASARI_ARCHITECT") then
				Add_Attached_Hint(obj, HINT_BUILT_MASARI_ARCHITECT)

			elseif obj_type == Find_Object_Type("MASARI_AVENGER") then
				Add_Attached_Hint(obj, HINT_BUILT_MASARI_AVENGER)

			elseif obj_type == Find_Object_Type("MASARI_DISCIPLE") then
				Add_Attached_Hint(obj, HINT_BUILT_MASARI_DISCIPLE)

			elseif obj_type == Find_Object_Type("MASARI_SEER") then
				Add_Attached_Hint(obj, HINT_BUILT_MASARI_SEER)

			elseif obj_type == Find_Object_Type("MASARI_ENFORCER") then
				Add_Attached_Hint(obj, HINT_BUILT_MASARI_ENFORCER)

			elseif obj_type == Find_Object_Type("MASARI_PEACEBRINGER") then
				Add_Attached_Hint(obj, HINT_BUILT_MASARI_PEACEBRINGER)

			elseif obj_type == Find_Object_Type("MASARI_SENTRY") then
				Add_Attached_Hint(obj, HINT_BUILT_MASARI_SENTRY)
			end
		end
	
		-- Check for Story construction events.
		if Story_On_Construction_Complete then
			Story_On_Construction_Complete(obj, constructor)
		end
	end	
end