extends RefCounted

const DATA := {
	"forest_path": {
		"title": "Save Marta from the Square Creatures",
		"purpose": "Enter the old woman's lane, kill the creature outside, and get her out alive.",
		"stakes": "If Marta falls, Willow Village loses its nerve and the whole square collapses into panic.",
		"completion_flag": "quest_forest_route_rebuilt",
		"briefing_lines": [
			"Mission: Save Marta from the Square Creatures.",
			"Marta is trapped in her front lane while a creature prowls the square outside.",
			"Phase 1: kill the creature before it reaches her house.",
			"Phase 2: get to Marta's porch and bring her out."
		],
		"steps": [
			{"flag": "quest_forest_route_rebuilt", "position": Vector2(-126, -356), "prompt": "", "speaker": "Marta", "glyph_text": "", "required_flags": ["enemy_forest_slime_defeated"], "visible_after_flags": ["enemy_forest_slime_defeated"], "dialogue_lines": [], "locked_dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "Marta is safe. Portal unlocked. +4 coins.", "reward_coins": 4, "primary_color": Color(0.3, 0.44, 0.72, 1.0), "accent_color": Color(0.86, 0.92, 1.0, 1.0), "glow_color": Color(0.62, 0.84, 1.0, 0.16)}
		]
	},
	"echo_cave": {
		"title": "Help Farmer Tomas Catch the Chickens",
		"purpose": "Recover the scattered eggs and round up the runaway chickens before the farm loses the whole morning.",
		"stakes": "If the farm breaks for the day, the village loses food, trade, and any sense of normal life.",
		"completion_flag": "quest_echo_sequence_aligned",
		"briefing_lines": [
			"Mission: Help Farmer Tomas Catch the Chickens.",
			"The hens are loose, the eggs are scattered, and the farmer is losing the whole morning.",
			"Phase 1: collect the eggs before they get crushed.",
			"Phase 2: catch the runaway chickens and report back to Tomas."
		],
		"steps": [
			{"flag": "quest_echo_crystal_west", "position": Vector2(-250, 120), "prompt": "", "speaker": "North Nest", "glyph_text": "", "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "First egg secured. +1 coin.", "reward_coins": 1, "primary_color": Color(0.74, 0.5, 0.26, 1.0), "accent_color": Color(1.0, 0.95, 0.72, 1.0), "glow_color": Color(1.0, 0.92, 0.7, 0.18)},
			{"flag": "quest_echo_crystal_east", "position": Vector2(168, 112), "prompt": "", "speaker": "East Nest", "glyph_text": "", "required_flags": ["quest_echo_crystal_west"], "visible_after_flags": ["quest_echo_crystal_west"], "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "Second egg secured. +1 coin.", "reward_coins": 1, "primary_color": Color(0.74, 0.5, 0.26, 1.0), "accent_color": Color(1.0, 0.95, 0.72, 1.0), "glow_color": Color(1.0, 0.92, 0.7, 0.18)},
			{"flag": "quest_echo_sequence_aligned", "position": Vector2(0, -154), "prompt": "", "speaker": "Farmer Tomas", "glyph_text": "", "required_flags": ["quest_echo_crystal_west", "quest_echo_crystal_east", "quest_echo_chicken_white", "quest_echo_chicken_brown"], "visible_after_flags": ["quest_echo_crystal_east"], "dialogue_lines": [], "locked_dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "Farmyard recovered. Portal unlocked. +4 coins and a berry.", "reward_coins": 4, "reward_item_id": "berry", "primary_color": Color(0.42, 0.54, 0.22, 1.0), "accent_color": Color(0.98, 0.94, 0.66, 1.0), "glow_color": Color(0.92, 1.0, 0.72, 0.18)}
		]
	},
	"echo_rift": {
		"title": "Neutralize the Echo Rift Heart",
		"purpose": "Destroy the void screen around the heart and seize control of the breach.",
		"stakes": "If the core stabilizes, Echo Cave becomes a permanent spawn well.",
		"completion_flag": "quest_echo_sequence_aligned",
		"briefing_lines": [
			"Pocket Operation: Neutralize the Echo Rift Heart.",
			"Purpose: fight in zero gravity, wipe the void slimes, and seize the heart before the breach hardens.",
			"Movement is looser here. Use drift, keep spacing, and do not get pinned near the center."
		],
		"steps": [
			{"flag": "quest_echo_sequence_aligned", "position": Vector2(0, -212), "prompt": "Seize void core", "speaker": "Void Core", "glyph_text": "C", "required_flags": ["enemy_echo_rift_slime_a_defeated", "enemy_echo_rift_slime_b_defeated", "enemy_echo_rift_slime_c_defeated"], "dialogue_lines": ["With the void screen dead, the core folds in on itself and the entire breach starts collapsing back into Echo Cave."], "locked_dialogue_lines": ["The heart is still protected. Clear the three void slimes first."], "completion_message": "Echo breach collapsed. Returning to Echo Cave.", "target_room_id": "echo_cave", "target_spawn_id": "spawn_from_rift", "primary_color": Color(0.72, 0.84, 1.0, 1.0), "accent_color": Color(1.0, 1.0, 1.0, 1.0), "glow_color": Color(0.78, 0.9, 1.0, 0.2)}
		]
	},
	"sunstone_ruins": {
		"title": "Rob Stonebank Without Making a Sound",
		"purpose": "Slip through the bank, reach the vault, grab the cash, and leave without firing a shot.",
		"stakes": "If you trigger the bank, the guards kill the job on the spot and you are done.",
		"completion_flag": "quest_sun_tablet_extracted",
		"briefing_lines": [
			"Mission: Rob Stonebank Without Making a Sound.",
			"No gunfire. No panic. No second try if the guards catch you in the wrong lane.",
			"Phase 1: work the side lanes and reach the vault without crossing the open bank lines.",
			"Phase 2: grab the cash and get out through the back alley."
		],
		"steps": [
			{"flag": "quest_sun_key_taken", "position": Vector2(-296, 160), "prompt": "", "speaker": "Side Office", "glyph_text": "", "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "You slip into the bank's side office.", "primary_color": Color(0.78, 0.56, 0.16, 1.0), "accent_color": Color(1.0, 0.92, 0.58, 1.0), "glow_color": Color(1.0, 0.84, 0.34, 0.18)},
			{"flag": "quest_sun_archive_open", "position": Vector2(272, 156), "prompt": "", "speaker": "Vault Hall", "glyph_text": "", "required_flags": ["quest_sun_key_taken"], "visible_after_flags": ["quest_sun_key_taken"], "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "You cross the bank floor unseen.", "primary_color": Color(0.78, 0.56, 0.16, 1.0), "accent_color": Color(1.0, 0.92, 0.58, 1.0), "glow_color": Color(1.0, 0.84, 0.34, 0.18)},
			{"flag": "quest_sun_tablet_taken", "position": Vector2(248, -130), "prompt": "", "speaker": "Vault Shelf", "glyph_text": "", "required_flags": ["quest_sun_archive_open"], "visible_after_flags": ["quest_sun_archive_open"], "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "Cash is in the bag. Move.", "primary_color": Color(0.78, 0.56, 0.16, 1.0), "accent_color": Color(1.0, 0.92, 0.58, 1.0), "glow_color": Color(1.0, 0.84, 0.34, 0.18)},
			{"flag": "quest_sun_cash_second", "position": Vector2(6, -308), "prompt": "", "speaker": "Back Hall", "glyph_text": "", "required_flags": ["quest_sun_tablet_taken"], "visible_after_flags": ["quest_sun_tablet_taken"], "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "Back hall crossed. The alley is close.", "primary_color": Color(0.78, 0.56, 0.16, 1.0), "accent_color": Color(1.0, 0.92, 0.58, 1.0), "glow_color": Color(1.0, 0.84, 0.34, 0.18)},
			{"flag": "quest_sun_tablet_extracted", "position": Vector2(284, -334), "prompt": "", "speaker": "Back Alley Door", "glyph_text": "", "required_flags": ["quest_sun_cash_second"], "visible_after_flags": ["quest_sun_cash_second"], "auto_trigger": true, "show_visuals": false, "completion_message": "Bank heist complete. Portal unlocked. +8 coins.", "reward_coins": 8, "primary_color": Color(0.96, 0.78, 0.32, 1.0), "accent_color": Color(1.0, 0.96, 0.72, 1.0), "glow_color": Color(1.0, 0.88, 0.42, 0.18)}
		]
	},
	"bloom_marsh": {
		"title": "Enter the House and Kill the Robbers",
		"purpose": "Break into the occupied house, clear the gunmen, and secure the family room upstairs.",
		"stakes": "If the robbers hold the house, the whole lane stays under their guns.",
		"completion_flag": "quest_marsh_delivery_done",
		"briefing_lines": [
			"Mission: Enter the House and Kill the Robbers.",
			"Two gunmen took the lane house and trapped the family upstairs.",
			"Phase 1: breach the side door and push into the upper hall.",
			"Phase 2: kill both robbers and secure the family room."
		],
		"steps": [
			{"flag": "quest_marsh_herb_north", "position": Vector2(-262, 48), "prompt": "", "speaker": "Side Door", "glyph_text": "", "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "House breached.", "primary_color": Color(0.36, 0.52, 0.24, 1.0), "accent_color": Color(0.86, 0.98, 0.62, 1.0), "glow_color": Color(0.68, 1.0, 0.7, 0.18)},
			{"flag": "quest_marsh_herb_mid", "position": Vector2(0, -96), "prompt": "", "speaker": "Upper Hall", "glyph_text": "", "required_flags": ["quest_marsh_herb_north"], "visible_after_flags": ["quest_marsh_herb_north"], "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "Upper hall reached.", "primary_color": Color(0.36, 0.52, 0.24, 1.0), "accent_color": Color(0.86, 0.98, 0.62, 1.0), "glow_color": Color(0.68, 1.0, 0.7, 0.18)},
			{"flag": "quest_marsh_delivery_done", "position": Vector2(246, -182), "prompt": "", "speaker": "Family Room", "glyph_text": "", "required_flags": ["quest_marsh_herb_mid", "enemy_bloom_robber_a_defeated", "enemy_bloom_robber_b_defeated"], "visible_after_flags": ["quest_marsh_herb_mid"], "auto_trigger": true, "show_visuals": false, "completion_message": "House secured. Portal unlocked. +6 coins and a berry.", "reward_coins": 6, "reward_item_id": "berry", "primary_color": Color(0.36, 0.52, 0.24, 1.0), "accent_color": Color(0.86, 0.98, 0.62, 1.0), "glow_color": Color(0.68, 1.0, 0.7, 0.18)}
		]
	},
	"market_crossroads": {
		"title": "Sneak into the Jeweler House and Steal the Jewelry",
		"purpose": "Climb into the house over the market, take the jewelry, and get out without the family noticing.",
		"stakes": "If the family wakes, the whole square turns on you and the theft is over.",
		"completion_flag": "quest_market_contract_built",
		"briefing_lines": [
			"Mission: Sneak into the Jeweler House and Steal the Jewelry.",
			"The jeweler's family is upstairs over the market stalls. If they hear you, the square lights up.",
			"Phase 1: climb in through the balcony and reach the jewelry room.",
			"Phase 2: steal the set and escape across the rooftop line."
		],
		"steps": [
			{"flag": "quest_market_rumor_west", "position": Vector2(-16, -104), "prompt": "", "speaker": "Balcony Window", "glyph_text": "", "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "You slip into the jeweler house.", "primary_color": Color(0.42, 0.2, 0.52, 1.0), "accent_color": Color(0.96, 0.84, 0.36, 1.0), "glow_color": Color(0.92, 0.5, 1.0, 0.18)},
			{"flag": "quest_market_rumor_mid", "position": Vector2(162, -208), "prompt": "", "speaker": "Jewelry Cabinet", "glyph_text": "", "required_flags": ["quest_market_rumor_west"], "visible_after_flags": ["quest_market_rumor_west"], "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "Jewelry secured.", "primary_color": Color(0.42, 0.2, 0.52, 1.0), "accent_color": Color(0.96, 0.84, 0.36, 1.0), "glow_color": Color(0.92, 0.5, 1.0, 0.18)},
			{"flag": "quest_market_rumor_east", "position": Vector2(28, -298), "prompt": "", "speaker": "Roofline", "glyph_text": "", "required_flags": ["quest_market_rumor_mid"], "visible_after_flags": ["quest_market_rumor_mid"], "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "Roofline reached.", "primary_color": Color(0.42, 0.2, 0.52, 1.0), "accent_color": Color(0.96, 0.84, 0.36, 1.0), "glow_color": Color(0.92, 0.5, 1.0, 0.18)},
			{"flag": "quest_market_contract_built", "position": Vector2(286, -334), "prompt": "", "speaker": "Escape Roof", "glyph_text": "", "required_flags": ["quest_market_rumor_east"], "visible_after_flags": ["quest_market_rumor_east"], "auto_trigger": true, "show_visuals": false, "completion_message": "Jewelry theft complete. Portal unlocked. +6 coins.", "reward_coins": 6, "primary_color": Color(0.42, 0.2, 0.52, 1.0), "accent_color": Color(0.96, 0.84, 0.36, 1.0), "glow_color": Color(0.92, 0.5, 1.0, 0.18)}
		]
	},
	"ember_fields": {
		"title": "Break the Prisoner out of the Cell Block",
		"purpose": "Slip into the old prison, reach the cell block, and get the prisoner out before the guards lock it down.",
		"stakes": "If the prison stays closed, the whole northern route keeps bleeding people into the cells.",
		"completion_flag": "quest_ember_forge_raided",
		"briefing_lines": [
			"Mission: Break the Prisoner out of the Cell Block.",
			"The guards control the yard, the corridors, and the upper cells.",
			"Phase 1: breach the yard and get into the cell block.",
			"Phase 2: free the prisoner, kill the guards if you must, and escape out the roof gate."
		],
		"steps": [
			{"flag": "quest_ember_valve_left", "position": Vector2(-278, 196), "prompt": "", "speaker": "Yard Gap", "glyph_text": "", "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "You slip through the prison yard wall.", "primary_color": Color(0.54, 0.26, 0.12, 1.0), "accent_color": Color(1.0, 0.7, 0.32, 1.0), "glow_color": Color(1.0, 0.56, 0.22, 0.18)},
			{"flag": "quest_ember_valve_right", "position": Vector2(0, 48), "prompt": "", "speaker": "Cell Block", "glyph_text": "", "required_flags": ["quest_ember_valve_left"], "visible_after_flags": ["quest_ember_valve_left"], "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "Cell block reached.", "primary_color": Color(0.54, 0.26, 0.12, 1.0), "accent_color": Color(1.0, 0.7, 0.32, 1.0), "glow_color": Color(1.0, 0.56, 0.22, 0.18)},
			{"flag": "quest_ember_lift_raised", "position": Vector2(198, -122), "prompt": "", "speaker": "Prison Cell", "glyph_text": "", "required_flags": ["quest_ember_valve_right"], "visible_after_flags": ["quest_ember_valve_right"], "dialogue_lines": [], "auto_trigger": true, "show_visuals": false, "completion_message": "The prisoner is loose. Clear a path out.", "primary_color": Color(0.54, 0.26, 0.12, 1.0), "accent_color": Color(1.0, 0.7, 0.32, 1.0), "glow_color": Color(1.0, 0.56, 0.22, 0.18)},
			{"flag": "quest_ember_forge_raided", "position": Vector2(274, -304), "prompt": "", "speaker": "Roof Gate", "glyph_text": "", "required_flags": ["quest_ember_lift_raised", "enemy_ember_guard_a_defeated", "enemy_ember_guard_b_defeated", "enemy_ember_guard_c_defeated"], "visible_after_flags": ["quest_ember_lift_raised"], "auto_trigger": true, "show_visuals": false, "completion_message": "Prison break complete. Portal unlocked. +7 coins.", "reward_coins": 7, "primary_color": Color(0.54, 0.26, 0.12, 1.0), "accent_color": Color(1.0, 0.7, 0.32, 1.0), "glow_color": Color(1.0, 0.56, 0.22, 0.18)}
		]
	},
	"iron_docks": {
		"title": "Rob the Harbor War Chest",
		"purpose": "Cut into the dock payroll and escape with enough cash to fund the next tier of operations.",
		"stakes": "If the payroll survives, the harbor keeps paying for the slime pressure ahead.",
		"completion_flag": "quest_dock_heist_done",
		"briefing_lines": [
			"Operation: Rob the Harbor War Chest.",
			"Purpose: secure the cutters, break the payroll chain, steal the strongbox, and escape before lockdown.",
			"Phase 1: take the cutters and sever the chain that holds the payroll box.",
			"Phase 2: crack the strongbox and escape by rope lift."
		],
		"steps": [
			{"flag": "quest_dock_cutters_taken", "position": Vector2(-248, 164), "prompt": "Secure bolt cutters", "speaker": "Bolt Cutters", "glyph_text": "C", "dialogue_lines": ["You pull the bolt cutters from the lower gantry stash. Now the payroll is reachable."], "completion_message": "Bolt cutters secured. +1 coin.", "reward_coins": 1, "primary_color": Color(0.32, 0.38, 0.46, 1.0), "accent_color": Color(0.88, 0.96, 1.0, 1.0), "glow_color": Color(0.62, 0.84, 1.0, 0.18)},
			{"flag": "quest_dock_chain_cut", "position": Vector2(0, -132), "prompt": "Cut payroll chain", "speaker": "Strongbox Chain", "glyph_text": "L", "required_flags": ["quest_dock_cutters_taken"], "visible_after_flags": ["quest_dock_cutters_taken"], "dialogue_lines": ["The chain crashes into the water and the payroll box swings free."], "completion_message": "Payroll chain cut. +1 coin.", "reward_coins": 1, "primary_color": Color(0.32, 0.38, 0.46, 1.0), "accent_color": Color(0.88, 0.96, 1.0, 1.0), "glow_color": Color(0.62, 0.84, 1.0, 0.18)},
			{"flag": "quest_dock_strongbox_taken", "position": Vector2(-258, -172), "prompt": "Crack war chest", "speaker": "Dock Strongbox", "glyph_text": "$", "required_flags": ["quest_dock_chain_cut"], "visible_after_flags": ["quest_dock_chain_cut"], "dialogue_lines": ["The strongbox bursts open under pressure. The payout inside is heavy enough to matter."], "completion_message": "Harbor war chest cracked.", "primary_color": Color(0.32, 0.38, 0.46, 1.0), "accent_color": Color(0.88, 0.96, 1.0, 1.0), "glow_color": Color(0.62, 0.84, 1.0, 0.18)},
			{"flag": "quest_dock_heist_done", "position": Vector2(152, -318), "prompt": "Escape with payroll", "speaker": "Rope Lift", "glyph_text": "X", "required_flags": ["quest_dock_strongbox_taken", "enemy_iron_docks_slime_a_defeated", "enemy_iron_docks_slime_b_defeated", "enemy_iron_docks_slime_c_defeated"], "visible_after_flags": ["quest_dock_strongbox_taken"], "auto_trigger": true, "completion_message": "Harbor war chest stolen. Portal unlocked. +8 coins.", "reward_coins": 8, "primary_color": Color(0.72, 0.82, 0.94, 1.0), "accent_color": Color(1.0, 1.0, 1.0, 1.0), "glow_color": Color(0.78, 0.9, 1.0, 0.18)}
		]
	},
	"verdant_garden": {
		"title": "Open the Greenhouse Relief Vault",
		"purpose": "Trace the clue trail, recover the brass key, and unlock the medical reserve.",
		"stakes": "If the vault stays sealed, the run loses its only stable recovery stockpile.",
		"completion_flag": "quest_garden_vault_open",
		"briefing_lines": [
			"Operation: Open the Greenhouse Relief Vault.",
			"Purpose: follow the hedge clues, clear the greenhouse guards, and unlock the buried relief cache.",
			"Phase 1: gather the three clue markers hidden in the hedge line.",
			"Phase 2: recover the brass key and open the relief vault."
		],
		"steps": [
			{"flag": "quest_garden_clue_left", "position": Vector2(-224, 132), "prompt": "Trace hedge clue", "speaker": "Trimmed Hedge", "glyph_text": "1", "dialogue_lines": ["A brass scratch-mark in the hedge points to the first leg of the vault trail."], "completion_message": "Hedge clue 1 traced. +1 coin.", "reward_coins": 1, "primary_color": Color(0.36, 0.52, 0.28, 1.0), "accent_color": Color(1.0, 0.94, 0.58, 1.0), "glow_color": Color(0.7, 1.0, 0.74, 0.18)},
			{"flag": "quest_garden_clue_top", "position": Vector2(0, -156), "prompt": "Trace hedge clue", "speaker": "Trimmed Hedge", "glyph_text": "2", "dialogue_lines": ["The second hedge clue reveals a hidden greenhouse route above the center lane."], "completion_message": "Hedge clue 2 traced. +1 coin.", "reward_coins": 1, "primary_color": Color(0.36, 0.52, 0.28, 1.0), "accent_color": Color(1.0, 0.94, 0.58, 1.0), "glow_color": Color(0.7, 1.0, 0.74, 0.18)},
			{"flag": "quest_garden_clue_right", "position": Vector2(232, 128), "prompt": "Trace hedge clue", "speaker": "Trimmed Hedge", "glyph_text": "3", "dialogue_lines": ["The last clue identifies the burial point of the greenhouse key."], "completion_message": "Hedge clue 3 traced. +1 coin.", "reward_coins": 1, "primary_color": Color(0.36, 0.52, 0.28, 1.0), "accent_color": Color(1.0, 0.94, 0.58, 1.0), "glow_color": Color(0.7, 1.0, 0.74, 0.18)},
			{"flag": "quest_garden_key_taken", "position": Vector2(0, -128), "prompt": "Recover brass key", "speaker": "Brass Key", "glyph_text": "K", "required_flags": ["quest_garden_clue_left", "quest_garden_clue_top", "quest_garden_clue_right", "enemy_verdant_garden_slime_a_defeated", "enemy_verdant_garden_slime_b_defeated", "enemy_verdant_garden_slime_c_defeated"], "visible_after_flags": ["quest_garden_clue_left", "quest_garden_clue_top", "quest_garden_clue_right"], "dialogue_lines": ["You pull the brass key out of the soft soil under the center beds."], "completion_message": "Greenhouse key recovered. +1 coin.", "reward_coins": 1, "primary_color": Color(0.36, 0.52, 0.28, 1.0), "accent_color": Color(1.0, 0.94, 0.58, 1.0), "glow_color": Color(0.7, 1.0, 0.74, 0.18)},
			{"flag": "quest_garden_vault_open", "position": Vector2(250, -166), "prompt": "Open relief vault", "speaker": "Greenhouse Vault", "glyph_text": "V", "required_flags": ["quest_garden_key_taken"], "visible_after_flags": ["quest_garden_key_taken"], "dialogue_lines": ["The relief vault opens and spills out preserved supplies and a clean reserve berry."], "completion_message": "Relief vault opened. Portal unlocked. +7 coins and a berry.", "reward_coins": 7, "reward_item_id": "berry", "primary_color": Color(0.36, 0.52, 0.28, 1.0), "accent_color": Color(1.0, 0.94, 0.58, 1.0), "glow_color": Color(0.7, 1.0, 0.74, 0.18)}
		]
	},
	"dune_courtyard": {
		"title": "Expose the Magistrate Debt Lattice",
		"purpose": "Crack the archive trail and steal the ledger that controls the route economy.",
		"stakes": "If the ledger survives, every deeper district keeps answering to the same payout machine.",
		"completion_flag": "quest_dune_ledger_stolen",
		"briefing_lines": [
			"Operation: Expose the Magistrate Debt Lattice.",
			"Purpose: steal the scout notes, align the sun dial, forge a pass, and seize the magistrate ledger.",
			"Phase 1: gather the archive code from the lower court and center dial.",
			"Phase 2: forge access, clear the archive lane, and steal the ledger."
		],
		"steps": [
			{"flag": "quest_dune_notes_taken", "position": Vector2(-222, 132), "prompt": "Steal scout notes", "speaker": "Scout Notes", "glyph_text": "N", "dialogue_lines": ["The scout notes carry half of the code that guards the magistrate archive."], "completion_message": "Scout notes stolen. +1 coin.", "reward_coins": 1, "primary_color": Color(0.6, 0.34, 0.14, 1.0), "accent_color": Color(1.0, 0.86, 0.46, 1.0), "glow_color": Color(1.0, 0.8, 0.38, 0.18)},
			{"flag": "quest_dune_sundial_aligned", "position": Vector2(0, -126), "prompt": "Align sun dial", "speaker": "Sun Dial", "glyph_text": "S", "required_flags": ["quest_dune_notes_taken"], "visible_after_flags": ["quest_dune_notes_taken"], "dialogue_lines": ["The dial clicks into place and reveals the second half of the archive code."], "completion_message": "Sun dial aligned. +1 coin.", "reward_coins": 1, "primary_color": Color(0.6, 0.34, 0.14, 1.0), "accent_color": Color(1.0, 0.86, 0.46, 1.0), "glow_color": Color(1.0, 0.8, 0.38, 0.18)},
			{"flag": "quest_dune_pass_forged", "position": Vector2(204, 122), "prompt": "Forge archive pass", "speaker": "Entry Desk", "glyph_text": "P", "required_flags": ["quest_dune_sundial_aligned"], "visible_after_flags": ["quest_dune_sundial_aligned"], "dialogue_lines": ["The forged pass will hold long enough to get you into the ledger chest."], "completion_message": "Archive pass forged. +1 coin.", "reward_coins": 1, "primary_color": Color(0.6, 0.34, 0.14, 1.0), "accent_color": Color(1.0, 0.86, 0.46, 1.0), "glow_color": Color(1.0, 0.8, 0.38, 0.18)},
			{"flag": "quest_dune_ledger_stolen", "position": Vector2(252, -178), "prompt": "Seize ledger", "speaker": "Magistrate Ledger", "glyph_text": "L", "required_flags": ["quest_dune_pass_forged", "enemy_dune_courtyard_slime_a_defeated", "enemy_dune_courtyard_slime_b_defeated", "enemy_dune_courtyard_slime_c_defeated"], "visible_after_flags": ["quest_dune_pass_forged"], "dialogue_lines": ["The ledger is packed with route debt chains, bribes, and the leverage that shaped the whole corridor."], "completion_message": "Debt ledger stolen. Portal unlocked. +8 coins.", "reward_coins": 8, "primary_color": Color(0.6, 0.34, 0.14, 1.0), "accent_color": Color(1.0, 0.86, 0.46, 1.0), "glow_color": Color(1.0, 0.8, 0.38, 0.18)}
		]
	},
	"ashen_rift": {
		"title": "Crash the Ashen Seal Core",
		"purpose": "Survive the burning zero-gravity breach and rip the core out before it seals again.",
		"stakes": "If the breach stays open, the Ashen Keep becomes a permanent dimensional furnace.",
		"completion_flag": "quest_keep_seal_escaped",
		"briefing_lines": [
			"Pocket Operation: Crash the Ashen Seal Core.",
			"Purpose: clear the shadow screen in zero gravity and rip the core out before the breach hardens.",
			"The arena drifts, burns, and punishes hesitation. Keep moving."
		],
		"steps": [
			{"flag": "quest_keep_seal_escaped", "position": Vector2(0, -214), "prompt": "Rip out seal core", "speaker": "Seal Core", "glyph_text": "C", "required_flags": ["enemy_ashen_rift_slime_a_defeated", "enemy_ashen_rift_slime_b_defeated", "enemy_ashen_rift_slime_c_defeated"], "dialogue_lines": ["With the shadow screen broken, the seal core tears free and the burning breach starts imploding."], "locked_dialogue_lines": ["The breach is still defended. Clear the three shadow slimes first."], "completion_message": "Ashen breach collapsed. Returning to Ashen Keep.", "target_room_id": "ashen_keep", "target_spawn_id": "spawn_from_rift", "primary_color": Color(0.92, 0.42, 0.34, 1.0), "accent_color": Color(1.0, 0.8, 0.72, 1.0), "glow_color": Color(1.0, 0.58, 0.44, 0.2)}
		]
	},
	"ashen_keep": {
		"title": "Breach the Ashen Prison Lattice",
		"purpose": "Break the ward line, seize the black seal, and enter the dimensional prison breach.",
		"stakes": "If the prison lattice survives, the final corridor keeps feeding from the same sealed furnace.",
		"completion_flag": "quest_keep_seal_escaped",
		"briefing_lines": [
			"Operation: Breach the Ashen Prison Lattice.",
			"Purpose: disable both ward braziers, seize the black seal, and collapse the prison breach from within.",
			"Phase 1: destroy the ward line guarding the seal.",
			"Phase 2: enter the burning zero-gravity breach and finish the collapse."
		],
		"steps": [
			{"flag": "quest_keep_brazier_left", "position": Vector2(-208, 120), "prompt": "Disable left ward", "speaker": "Ward Brazier", "glyph_text": "A", "dialogue_lines": ["The left ward brazier goes black and the prison field weakens."], "completion_message": "Left ward disabled. +1 coin.", "reward_coins": 1, "primary_color": Color(0.28, 0.16, 0.18, 1.0), "accent_color": Color(0.94, 0.46, 0.34, 1.0), "glow_color": Color(1.0, 0.48, 0.34, 0.18)},
			{"flag": "quest_keep_brazier_right", "position": Vector2(210, 120), "prompt": "Disable right ward", "speaker": "Ward Brazier", "glyph_text": "B", "dialogue_lines": ["The right brazier dies too and the prison seal starts to crack."], "completion_message": "Right ward disabled. +1 coin.", "reward_coins": 1, "primary_color": Color(0.28, 0.16, 0.18, 1.0), "accent_color": Color(0.94, 0.46, 0.34, 1.0), "glow_color": Color(1.0, 0.48, 0.34, 0.18)},
			{"flag": "quest_keep_black_seal_taken", "position": Vector2(0, -176), "prompt": "Seize black seal", "speaker": "Black Seal", "glyph_text": "S", "required_flags": ["quest_keep_brazier_left", "quest_keep_brazier_right"], "visible_after_flags": ["quest_keep_brazier_left", "quest_keep_brazier_right"], "dialogue_lines": ["The black seal comes free from the war room pedestal and the whole keep starts screaming around it."], "completion_message": "Black seal secured.", "primary_color": Color(0.28, 0.16, 0.18, 1.0), "accent_color": Color(0.94, 0.46, 0.34, 1.0), "glow_color": Color(1.0, 0.48, 0.34, 0.18)},
			{"flag": "", "position": Vector2(120, -318), "prompt": "Enter prison breach", "speaker": "Seal Breach", "glyph_text": "X", "required_flags": ["quest_keep_black_seal_taken", "enemy_ashen_keep_slime_a_defeated", "enemy_ashen_keep_slime_b_defeated", "enemy_ashen_keep_slime_c_defeated"], "visible_after_flags": ["quest_keep_black_seal_taken"], "dialogue_lines": ["The stolen seal tears the keep open into a burning zero-gravity prison breach. The core is exposed inside."], "completion_message": "", "target_room_id": "ashen_rift", "target_spawn_id": "spawn_from_keep", "primary_color": Color(0.92, 0.42, 0.34, 1.0), "accent_color": Color(1.0, 0.78, 0.72, 1.0), "glow_color": Color(1.0, 0.54, 0.42, 0.18)}
		]
	}
}
