extends Node2D

const FIGHTER_SCENE := preload("res://scenes/fighter/Fighter.tscn")
const AI_FIGHTER_SCENE := preload("res://scenes/fighter/AIFighter.tscn")
const TOUCH_CONTROLS_SCENE := preload("res://scenes/fighter/TouchControls.tscn")

const ALL_WEAPONS := ["fists", "shadow_blade", "kunai_stars", "frost_staff", "vine_whip", "iron_buckler", "dragon_gauntlets", "spirit_bow", "warp_dagger", "thunder_claws", "poison_fang", "fire_greatsword", "thors_hammer", "blood_scythe", "bomb_flail", "gravity_orb", "plasma_cannon", "crystal_spear", "minato_kunai"]
const WEAPON_NAMES := {
	"fists": "Fists",
	"shadow_blade": "Shadow Blade",
	"kunai_stars": "Kunai Stars",
	"frost_staff": "Frost Staff",
	"vine_whip": "Vine Whip",
	"iron_buckler": "Iron Buckler",
	"dragon_gauntlets": "Dragon Gauntlets",
	"spirit_bow": "Spirit Bow",
	"warp_dagger": "Warp Dagger",
	"thunder_claws": "Thunder Claws",
	"poison_fang": "Poison Fang",
	"fire_greatsword": "Fire Greatsword",
	"thors_hammer": "Thor's Hammer",
	"blood_scythe": "Blood Scythe",
	"bomb_flail": "Bomb Flail",
	"gravity_orb": "Gravity Orb",
	"plasma_cannon": "Plasma Cannon",
	"crystal_spear": "Crystal Spear",
	"minato_kunai": "Minato Kunai",
}

const KILLS_TO_WIN := 3
const KILLS_TO_WIN_2V2 := 5
const TROPHY_REWARD_BASE := 10  # base win reward, scales down at higher trophies

# 2v2 team color palettes
const TEAM_COLORS_ALLY := {
	"scarf": Color(0.2, 0.85, 0.3), "coat": Color(0.08, 0.22, 0.1),
	"hair": Color(0.15, 0.35, 0.12), "iris": Color(0.3, 1.0, 0.4),
	"accent": Color(0.3, 0.9, 0.4), "emblem": Color(0.25, 0.85, 0.3),
}
const TEAM_COLORS_ENEMY1 := {
	"scarf": Color(1.0, 0.5, 0.15), "coat": Color(0.3, 0.08, 0.06),
	"hair": Color(0.35, 0.1, 0.08), "iris": Color(1.0, 0.25, 0.2),
	"accent": Color(1.0, 0.45, 0.15), "emblem": Color(0.9, 0.35, 0.1),
}
const TEAM_COLORS_ENEMY2 := {
	"scarf": Color(0.7, 0.2, 0.85), "coat": Color(0.18, 0.06, 0.25),
	"hair": Color(0.25, 0.08, 0.3), "iris": Color(0.9, 0.3, 0.85),
	"accent": Color(0.7, 0.25, 0.9), "emblem": Color(0.65, 0.2, 0.85),
}

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var spawn_point_npc: Marker2D = $SpawnPointNPC
@onready var p1_damage_label: Label = $HUD/P1DamageLabel
@onready var cpu_damage_label: Label = $HUD/CPUDamageLabel

var player: CharacterBody2D
var npc: CharacterBody2D
var charge_label: Label
var p1_weapon_label: Label
var cpu_weapon_label: Label

# 2v2 extra fighters
var ally: CharacterBody2D
var enemy1: CharacterBody2D
var enemy2: CharacterBody2D
var ally_damage_label: Label
var enemy1_damage_label: Label
var enemy2_damage_label: Label

# Score tracking (normal mode only)
var p1_score: int = 0
var cpu_score: int = 0
var team_score: int = 0
var enemy_score: int = 0
var match_over: bool = false
var score_label: Label
var trophy_label: Label
var result_panel: ColorRect
var result_label: Label
var result_trophy_label: Label
var result_coins_label: Label
var result_hint_label: Label

# Rage HUD
var rage_meter_bg: Control
var rage_meter_label: Label

# Countdown
var countdown_active: bool = false
var countdown_timer: float = 0.0
var countdown_label: Label
const COUNTDOWN_DURATION := 3.0

# ─── SCREEN SHAKE ───
var _camera: Camera2D
var _shake_intensity: float = 0.0
var _shake_timer: float = 0.0
const SHAKE_DECAY := 12.0

# ─── HIT FREEZE ───
var _freeze_timer: float = 0.0

# ─── COMBO COUNTER ───
var combo_count: int = 0
var combo_timer: float = 0.0
var combo_label: Label
var style_points: int = 0
var style_label: Label
const COMBO_TIMEOUT := 1.5

# ─── MATCH STATS ───
var stats_damage_dealt: float = 0.0
var stats_damage_taken: float = 0.0
var stats_supers_used: int = 0
var stats_combos_landed: int = 0
var stats_max_combo: int = 0
var stats_style_points: int = 0

# ─── REVENGE MODE ───
var is_revenge_match: bool = false
var revenge_btn: Button

# ─── SOLO BATTLE ROYALE ───
var solo_fighters: Array = []  # all 9 AI fighters
var solo_alive_count: int = 10  # including player
var solo_placement: int = 0  # final placement (1 = winner)
var solo_alive_label: Label
const SOLO_PLAYER_COUNT := 10
const SOLO_TROPHY_MULT := 2.0

# ─── VICTORY TAUNTS ───
var taunt_label: Label
const TAUNTS_WIN := [
	"DOMINATION!", "TOO EASY!", "GET REKT!", "UNSTOPPABLE!",
	"GG EZ!", "FLAWLESS!", "DESTROYED!", "OUTPLAYED!",
	"SUPERIOR!", "NO CONTEST!", "OBLITERATED!", "CRUSHED!",
]
const TAUNTS_LOSE := [
	"NEXT TIME...", "SO CLOSE!", "REVENGE TIME!", "NOT OVER!",
	"REMATCH!", "ALMOST HAD IT!", "COMEBACK LOADING...",
]


func _ready() -> void:
	_setup_input_actions()
	_spawn_fighters()
	_create_charge_label()
	_create_weapon_labels()
	_create_score_hud()
	_create_result_screen()
	_create_rage_hud()
	_create_countdown_label()
	_create_combo_hud()
	if _is_2v2_mode():
		_create_2v2_hud()
	if DisplayServer.is_touchscreen_available():
		var touch_controls := TOUCH_CONTROLS_SCENE.instantiate()
		add_child(touch_controls)
	_camera = $Camera2D if has_node("Camera2D") else null
	is_revenge_match = GameState.get_meta("_revenge_next_match", false) == true
	if is_revenge_match:
		GameState.set_meta("_revenge_next_match", false)
	if _is_solo_mode():
		_create_solo_hud()
	# Show weapon tutorial on first use
	if _should_show_weapon_tutorial():
		_show_weapon_tutorial()
	_start_countdown()


func _process(_delta: float) -> void:
	# Hit freeze handling (pause gameplay briefly)
	if _freeze_timer > 0.0:
		_freeze_timer -= _delta
		if _freeze_timer <= 0.0:
			Engine.time_scale = 1.0
		return

	# Screen shake
	if _camera and _shake_timer > 0.0:
		_shake_timer -= _delta
		_shake_intensity *= (1.0 - SHAKE_DECAY * _delta)
		_camera.offset = Vector2(
			randf_range(-_shake_intensity, _shake_intensity),
			randf_range(-_shake_intensity, _shake_intensity)
		)
		if _shake_timer <= 0.0:
			_camera.offset = Vector2.ZERO
			_shake_intensity = 0.0

	# Combo timeout
	if combo_timer > 0.0 and not match_over:
		combo_timer -= _delta
		if combo_timer <= 0.0:
			if combo_count >= 3:
				stats_combos_landed += 1
				if combo_count > stats_max_combo:
					stats_max_combo = combo_count
				var points: int = combo_count * combo_count * 5
				style_points += points
				stats_style_points += points
				_flash_style_points(points)
			combo_count = 0
			if combo_label:
				combo_label.visible = false

	if match_over:
		return

	# Countdown tick
	if countdown_active:
		countdown_timer -= _delta
		if countdown_timer <= 0.0:
			_end_countdown()
		else:
			var num: int = ceili(countdown_timer)
			if num >= 1:
				countdown_label.text = str(num)
				# Scale pop effect on each new number
				var frac: float = countdown_timer - floorf(countdown_timer)
				var pop: float = 1.0 + 0.3 * frac
				countdown_label.add_theme_font_size_override("font_size", int(72.0 * pop))
			else:
				countdown_label.text = "GO!"
		return

	# Update HUD
	if is_instance_valid(player):
		p1_damage_label.text = "P1  %d%%" % int(player.damage_percent)
	if _is_2v2_mode():
		if is_instance_valid(ally) and ally_damage_label:
			ally_damage_label.text = "ALLY  %d%%" % int(ally.damage_percent)
		if is_instance_valid(enemy1) and enemy1_damage_label:
			enemy1_damage_label.text = "EN1  %d%%" % int(enemy1.damage_percent)
		if is_instance_valid(enemy2) and enemy2_damage_label:
			enemy2_damage_label.text = "EN2  %d%%" % int(enemy2.damage_percent)
		cpu_damage_label.visible = false
	elif _is_solo_mode():
		cpu_damage_label.text = "%d ALIVE" % solo_alive_count
	else:
		if is_instance_valid(npc):
			cpu_damage_label.text = "CPU  %d%%" % int(npc.damage_percent)
	# Update weapon labels
	if p1_weapon_label and is_instance_valid(player):
		p1_weapon_label.text = WEAPON_NAMES.get(player.weapon_id, player.weapon_id)
	if cpu_weapon_label and is_instance_valid(npc):
		if _is_2v2_mode():
			cpu_weapon_label.visible = false
		else:
			cpu_weapon_label.text = WEAPON_NAMES.get(npc.weapon_id, npc.weapon_id)

	# Update charge indicator
	if charge_label and is_instance_valid(player):
		if player.is_charging:
			charge_label.visible = true
			charge_label.text = "CHARGE  %d%%" % int(player.charge_ratio * 100)
		else:
			charge_label.visible = false

	# Update score label
	if score_label and _is_scoring_mode():
		if _is_2v2_mode():
			score_label.text = "%d  -  %d" % [team_score, enemy_score]
		elif _is_solo_mode():
			score_label.text = "%d ALIVE" % solo_alive_count
		else:
			score_label.text = "%d  -  %d" % [p1_score, cpu_score]

	# Update trophy display (per-weapon trophies for current weapon)
	if trophy_label and is_instance_valid(player):
		trophy_label.text = "🏆 %d" % GameState.get_weapon_trophies(player.weapon_id)

	# Update rage meter HUD
	if rage_meter_bg and is_instance_valid(player):
		rage_meter_bg.queue_redraw()
		var rc: Color = GameState.get_rage_color()
		var rc_bright: Color = GameState.get_rage_color_bright()
		if player.rage_active:
			rage_meter_label.text = "RAGE!"
			rage_meter_label.add_theme_color_override("font_color", Color(rc.r, rc.g, rc.b, 0.9))
		elif player.rage_meter >= 100.0:
			rage_meter_label.text = "[E]"
			rage_meter_label.add_theme_color_override("font_color", Color(rc_bright.r, rc_bright.g, rc_bright.b, 1.0))
		else:
			var alpha: float = 0.3 + 0.4 * (player.rage_meter / 100.0)
			rage_meter_label.text = "E"
			rage_meter_label.add_theme_color_override("font_color", Color(rc.r, rc.g, rc.b, alpha))


func _input(event: InputEvent) -> void:
	# Match-over input uses _input so it fires BEFORE any UI node can eat the event
	if match_over and event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			get_viewport().set_input_as_handled()
			get_tree().reload_current_scene()
			return
		elif event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			get_tree().change_scene_to_file("res://scenes/fighter/Lobby.tscn")
			return


func _unhandled_input(_event: InputEvent) -> void:
	if match_over:
		return
	# Cannot leave mid-match — ESC disabled during gameplay


func _setup_input_actions() -> void:
	# Use remappable bindings from GameState (with arrow-key alternates)
	_setup_remappable("fighter_left", KEY_LEFT)
	_setup_remappable("fighter_right", KEY_RIGHT)
	_setup_remappable("fighter_jump", KEY_UP)
	_setup_remappable("fighter_down", KEY_DOWN)
	_setup_remappable("fighter_light")
	_setup_remappable("fighter_heavy")
	_setup_remappable("fighter_rage")
	# Mouse bindings always active
	_ensure_mouse("fighter_light", MOUSE_BUTTON_LEFT)
	_ensure_mouse("fighter_heavy", MOUSE_BUTTON_RIGHT)
	# Menu always ESC
	_ensure_key("fighter_menu", KEY_ESCAPE)


func _setup_remappable(action: String, alt_key: Key = KEY_NONE) -> void:
	# Clear existing events and re-add with custom binding
	if InputMap.has_action(action):
		InputMap.erase_action(action)
	InputMap.add_action(action)
	var primary: int = GameState.get_key_binding(action)
	if primary != KEY_NONE:
		_ensure_key(action, primary)
	if alt_key != KEY_NONE:
		_ensure_key(action, alt_key)


func _spawn_fighters() -> void:
	var weapon: String = GameState.fighter_weapon_id

	# Spawn player
	player = FIGHTER_SCENE.instantiate()
	player.weapon_id = weapon
	player.team_id = 0
	add_child(player)
	player.global_position = spawn_point.global_position

	if _is_2v2_mode():
		_spawn_2v2_fighters(weapon)
	elif _is_solo_mode():
		_spawn_solo_fighters(weapon)
	else:
		_spawn_1v1_npc(weapon)


func _spawn_1v1_npc(weapon: String) -> void:
	var npc_weapon: String = ALL_WEAPONS[randi() % ALL_WEAPONS.size()]
	npc = AI_FIGHTER_SCENE.instantiate()
	npc.weapon_id = npc_weapon
	npc.team_id = 1
	if GameState.fighter_game_mode == "practice":
		npc.practice_mode = true
	if _is_normal_mode():
		npc.trophy_count = _get_scaled_trophies(weapon)
	add_child(npc)
	npc.global_position = spawn_point_npc.global_position
	player.opponent = npc
	npc.opponent = player


func _spawn_2v2_fighters(weapon: String) -> void:
	var scaled := _get_scaled_trophies(weapon)

	# AI Teammate (same team as player)
	ally = AI_FIGHTER_SCENE.instantiate()
	ally.weapon_id = ALL_WEAPONS[randi() % ALL_WEAPONS.size()]
	ally.team_id = 0
	ally.trophy_count = scaled
	ally.color_override = TEAM_COLORS_ALLY
	add_child(ally)
	ally.global_position = Vector2(spawn_point.global_position.x - 70, spawn_point.global_position.y)

	# Enemy 1
	enemy1 = AI_FIGHTER_SCENE.instantiate()
	enemy1.weapon_id = ALL_WEAPONS[randi() % ALL_WEAPONS.size()]
	enemy1.team_id = 1
	enemy1.trophy_count = scaled
	enemy1.color_override = TEAM_COLORS_ENEMY1
	add_child(enemy1)
	enemy1.global_position = spawn_point_npc.global_position

	# Enemy 2
	enemy2 = AI_FIGHTER_SCENE.instantiate()
	enemy2.weapon_id = ALL_WEAPONS[randi() % ALL_WEAPONS.size()]
	enemy2.team_id = 1
	enemy2.trophy_count = scaled
	enemy2.color_override = TEAM_COLORS_ENEMY2
	add_child(enemy2)
	enemy2.global_position = Vector2(spawn_point_npc.global_position.x + 70, spawn_point_npc.global_position.y)

	# Set npc = enemy1 for compatibility with existing HUD/code
	npc = enemy1

	# Wire up teams
	var team_a: Array = [player, ally]
	var team_b: Array = [enemy1, enemy2]
	for f in team_a:
		f.enemies = team_b.duplicate()
		f.allies = []
		for a in team_a:
			if a != f:
				f.allies.append(a)
	for f in team_b:
		f.enemies = team_a.duplicate()
		f.allies = []
		for a in team_b:
			if a != f:
				f.allies.append(a)

	# Set initial opponents
	player.opponent = enemy1
	ally.opponent = enemy2
	enemy1.opponent = player
	enemy2.opponent = ally


func _get_scaled_trophies(weapon: String) -> int:
	var base_trophies: int = GameState.get_weapon_trophies(weapon)
	if GameState.fighter_lose_streak >= 3:
		var mercy: int = (GameState.fighter_lose_streak - 2) * 8
		base_trophies = maxi(base_trophies - mercy, 0)
	return base_trophies


func _is_normal_mode() -> bool:
	return GameState.fighter_game_mode == "normal"


func _is_2v2_mode() -> bool:
	return GameState.fighter_game_mode == "2v2"


func _is_solo_mode() -> bool:
	return GameState.fighter_game_mode == "solo"

func _is_scoring_mode() -> bool:
	return GameState.fighter_game_mode == "normal" or GameState.fighter_game_mode == "2v2" or GameState.fighter_game_mode == "solo"


func _create_charge_label() -> void:
	charge_label = Label.new()
	charge_label.visible = false
	charge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	charge_label.offset_left = 540
	charge_label.offset_top = 650
	charge_label.offset_right = 740
	charge_label.offset_bottom = 690
	charge_label.add_theme_font_size_override("font_size", 18)
	charge_label.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	$HUD.add_child(charge_label)


func _create_weapon_labels() -> void:
	# P1 weapon name (below P1 damage, blue tint)
	p1_weapon_label = Label.new()
	p1_weapon_label.offset_left = 40
	p1_weapon_label.offset_top = 670
	p1_weapon_label.offset_right = 280
	p1_weapon_label.offset_bottom = 700
	p1_weapon_label.add_theme_font_size_override("font_size", 14)
	p1_weapon_label.add_theme_color_override("font_color", Color(0.4, 0.6, 1.0, 0.7))
	p1_weapon_label.text = ""
	$HUD.add_child(p1_weapon_label)

	# CPU weapon name (below CPU damage, orange tint)
	cpu_weapon_label = Label.new()
	cpu_weapon_label.offset_left = 1000
	cpu_weapon_label.offset_top = 670
	cpu_weapon_label.offset_right = 1240
	cpu_weapon_label.offset_bottom = 700
	cpu_weapon_label.add_theme_font_size_override("font_size", 14)
	cpu_weapon_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3, 0.7))
	cpu_weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cpu_weapon_label.text = ""
	$HUD.add_child(cpu_weapon_label)


func _create_score_hud() -> void:
	# Score display (top center) — only visible in normal mode
	score_label = Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.offset_left = 490
	score_label.offset_top = 20
	score_label.offset_right = 790
	score_label.offset_bottom = 60
	score_label.add_theme_font_size_override("font_size", 28)
	score_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	score_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	score_label.add_theme_constant_override("shadow_offset_x", 2)
	score_label.add_theme_constant_override("shadow_offset_y", 2)
	score_label.text = "0  -  0"
	score_label.visible = _is_scoring_mode()
	$HUD.add_child(score_label)

	# "First to N" hint
	if _is_scoring_mode():
		var hint := Label.new()
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.offset_left = 490
		hint.offset_top = 50
		hint.offset_right = 790
		hint.offset_bottom = 70
		hint.add_theme_font_size_override("font_size", 12)
		hint.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.4))
		if _is_2v2_mode():
			hint.text = "First to %d" % KILLS_TO_WIN_2V2
		else:
			hint.text = "First to %d" % KILLS_TO_WIN
		$HUD.add_child(hint)

	# Trophy count (top right)
	trophy_label = Label.new()
	trophy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	trophy_label.offset_left = 1050
	trophy_label.offset_top = 20
	trophy_label.offset_right = 1240
	trophy_label.offset_bottom = 50
	trophy_label.add_theme_font_size_override("font_size", 18)
	trophy_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.8))
	trophy_label.text = "🏆 %d" % GameState.get_weapon_trophies(GameState.fighter_weapon_id)
	$HUD.add_child(trophy_label)


func _create_result_screen() -> void:
	# Dark overlay panel (hidden by default)
	result_panel = ColorRect.new()
	result_panel.color = Color(0, 0, 0, 0.75)
	result_panel.offset_left = 0
	result_panel.offset_top = 0
	result_panel.offset_right = 1280
	result_panel.offset_bottom = 720
	result_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_panel.visible = false
	$HUD.add_child(result_panel)

	# Big result text (WIN / LOSE)
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.offset_left = 340
	result_label.offset_top = 200
	result_label.offset_right = 940
	result_label.offset_bottom = 300
	result_label.add_theme_font_size_override("font_size", 64)
	result_label.text = ""
	result_panel.add_child(result_label)

	# Trophy change text
	result_trophy_label = Label.new()
	result_trophy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_trophy_label.offset_left = 340
	result_trophy_label.offset_top = 320
	result_trophy_label.offset_right = 940
	result_trophy_label.offset_bottom = 370
	result_trophy_label.add_theme_font_size_override("font_size", 24)
	result_trophy_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	result_trophy_label.text = ""
	result_panel.add_child(result_trophy_label)

	# Coin reward text
	result_coins_label = Label.new()
	result_coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_coins_label.offset_left = 340
	result_coins_label.offset_top = 370
	result_coins_label.offset_right = 940
	result_coins_label.offset_bottom = 400
	result_coins_label.add_theme_font_size_override("font_size", 18)
	result_coins_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.7))
	result_coins_label.text = ""
	result_panel.add_child(result_coins_label)

	# Hint text
	result_hint_label = Label.new()
	result_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_hint_label.offset_left = 340
	result_hint_label.offset_top = 430
	result_hint_label.offset_right = 940
	result_hint_label.offset_bottom = 470
	result_hint_label.add_theme_font_size_override("font_size", 16)
	result_hint_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.5))
	result_hint_label.text = "R to rematch  ·  ESC for lobby"
	result_panel.add_child(result_hint_label)


func _create_rage_hud() -> void:
	# Only show rage meter if player has RAGE unlocked for this weapon
	if not GameState.has_rage(GameState.fighter_weapon_id):
		return

	# Background control for drawing the circle
	rage_meter_bg = Control.new()
	rage_meter_bg.offset_left = 600
	rage_meter_bg.offset_top = 605
	rage_meter_bg.offset_right = 680
	rage_meter_bg.offset_bottom = 685
	rage_meter_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HUD.add_child(rage_meter_bg)
	rage_meter_bg.draw.connect(_draw_rage_meter)

	# "E" label in center of circle
	rage_meter_label = Label.new()
	rage_meter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rage_meter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rage_meter_label.offset_left = 600
	rage_meter_label.offset_top = 628
	rage_meter_label.offset_right = 680
	rage_meter_label.offset_bottom = 662
	rage_meter_label.add_theme_font_size_override("font_size", 16)
	rage_meter_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.2, 0.3))
	rage_meter_label.text = "E"
	$HUD.add_child(rage_meter_label)


func _draw_rage_meter() -> void:
	if not player or not rage_meter_bg:
		return
	var cx := 40.0
	var cy := 40.0
	var radius := 28.0
	var bg_color := Color(0.15, 0.15, 0.2, 0.6)
	var rc: Color = GameState.get_rage_color()
	var fill_color: Color = Color(rc.r, rc.g, rc.b, 0.8)
	var full_color: Color = GameState.get_rage_color_bright()

	# Background ring
	rage_meter_bg.draw_arc(Vector2(cx, cy), radius, 0, TAU, 32, bg_color, 4.0)

	# Filled arc
	var fill_ratio: float = player.rage_meter / 100.0
	if fill_ratio > 0.0:
		var start_a: float = -PI / 2.0
		var end_a: float = start_a + fill_ratio * TAU
		var col: Color = full_color if fill_ratio >= 1.0 else fill_color
		rage_meter_bg.draw_arc(Vector2(cx, cy), radius, start_a, end_a, 32, col, 4.0)

	# Active rage: draw pulsing inner glow
	if player.rage_active:
		var pulse: float = 0.4 + 0.3 * sin(player.rage_timer * 8.0)
		rage_meter_bg.draw_circle(Vector2(cx, cy), radius * 0.6, Color(rc.r, rc.g, rc.b, pulse))


func _create_countdown_label() -> void:
	countdown_label = Label.new()
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.offset_left = 440
	countdown_label.offset_top = 250
	countdown_label.offset_right = 840
	countdown_label.offset_bottom = 450
	countdown_label.add_theme_font_size_override("font_size", 72)
	countdown_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	countdown_label.visible = false
	$HUD.add_child(countdown_label)


func _create_2v2_hud() -> void:
	# Ally damage label (green, below P1)
	ally_damage_label = Label.new()
	ally_damage_label.offset_left = 40
	ally_damage_label.offset_top = 650
	ally_damage_label.offset_right = 280
	ally_damage_label.offset_bottom = 680
	ally_damage_label.add_theme_font_size_override("font_size", 22)
	ally_damage_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	ally_damage_label.text = "ALLY  0%"
	$HUD.add_child(ally_damage_label)

	# Enemy 1 damage label (orange, top right area)
	enemy1_damage_label = Label.new()
	enemy1_damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	enemy1_damage_label.offset_left = 1000
	enemy1_damage_label.offset_top = 630
	enemy1_damage_label.offset_right = 1240
	enemy1_damage_label.offset_bottom = 660
	enemy1_damage_label.add_theme_font_size_override("font_size", 22)
	enemy1_damage_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))
	enemy1_damage_label.text = "EN1  0%"
	$HUD.add_child(enemy1_damage_label)

	# Enemy 2 damage label (purple, below enemy1)
	enemy2_damage_label = Label.new()
	enemy2_damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	enemy2_damage_label.offset_left = 1000
	enemy2_damage_label.offset_top = 660
	enemy2_damage_label.offset_right = 1240
	enemy2_damage_label.offset_bottom = 690
	enemy2_damage_label.add_theme_font_size_override("font_size", 22)
	enemy2_damage_label.add_theme_color_override("font_color", Color(0.8, 0.4, 0.9))
	enemy2_damage_label.text = "EN2  0%"
	$HUD.add_child(enemy2_damage_label)


func _start_countdown() -> void:
	if countdown_active:
		return
	countdown_active = true
	countdown_timer = COUNTDOWN_DURATION
	if countdown_label:
		countdown_label.text = str(ceili(countdown_timer))
		countdown_label.visible = true
	# Freeze fighters (they still process physics/gravity, just can't act)
	if is_instance_valid(player):
		player.frozen = true
	if is_instance_valid(npc):
		npc.frozen = true
	if _is_2v2_mode():
		if is_instance_valid(ally):
			ally.frozen = true
		if is_instance_valid(enemy1):
			enemy1.frozen = true
		if is_instance_valid(enemy2):
			enemy2.frozen = true


func _end_countdown() -> void:
	countdown_active = false
	countdown_timer = 0.0
	if countdown_label:
		countdown_label.visible = false
	# Respawn all to clean slate then unfreeze
	if _is_2v2_mode():
		_respawn_all()
	else:
		_respawn_both()
	if is_instance_valid(player):
		player.frozen = false
	if is_instance_valid(npc):
		npc.frozen = false
	if _is_2v2_mode():
		if is_instance_valid(ally):
			ally.frozen = false
		if is_instance_valid(enemy1):
			enemy1.frozen = false
		if is_instance_valid(enemy2):
			enemy2.frozen = false


func _respawn_both() -> void:
	if is_instance_valid(player) and player.has_method("respawn"):
		player.respawn(spawn_point.global_position)
	if is_instance_valid(npc) and npc.has_method("respawn"):
		npc.respawn(spawn_point_npc.global_position)


func _respawn_all() -> void:
	if is_instance_valid(player) and player.has_method("respawn"):
		player.respawn(spawn_point.global_position)
	if is_instance_valid(ally) and ally.has_method("respawn"):
		ally.respawn(Vector2(spawn_point.global_position.x - 70, spawn_point.global_position.y))
	if is_instance_valid(enemy1) and enemy1.has_method("respawn"):
		enemy1.respawn(spawn_point_npc.global_position)
	if is_instance_valid(enemy2) and enemy2.has_method("respawn"):
		enemy2.respawn(Vector2(spawn_point_npc.global_position.x + 70, spawn_point_npc.global_position.y))


func _get_fighter_spawn_pos(body: Node2D) -> Vector2:
	if body == player:
		return spawn_point.global_position
	elif body == ally:
		return Vector2(spawn_point.global_position.x - 70, spawn_point.global_position.y)
	elif body == enemy1:
		return spawn_point_npc.global_position
	elif body == enemy2:
		return Vector2(spawn_point_npc.global_position.x + 70, spawn_point_npc.global_position.y)
	# Fallback for npc in 1v1
	elif body == npc:
		return spawn_point_npc.global_position
	return spawn_point.global_position


func on_kill_zone_entered(body: Node2D) -> void:
	if not is_instance_valid(body):
		return

	var respawn_pos := _get_fighter_spawn_pos(body)

	if countdown_active:
		# During countdown just respawn without scoring
		if body.has_method("respawn"):
			body.respawn(respawn_pos)
		return
	if match_over:
		# Still respawn but don't count score
		if body.has_method("respawn"):
			body.respawn(respawn_pos)
		return

	if _is_2v2_mode():
		_on_kill_zone_2v2(body)
	elif _is_solo_mode():
		_on_kill_zone_solo(body)
	elif _is_normal_mode():
		if body == player:
			cpu_score += 1
			if not _check_match_end():
				_respawn_both()
				_start_countdown()
			else:
				body.respawn(spawn_point.global_position)
		elif body == npc:
			p1_score += 1
			GameState.advance_daily_challenges("kill", 1)
			if is_instance_valid(player) and player.has_method("on_ko_scored"):
				player.on_ko_scored()
			if not _check_match_end():
				_respawn_both()
				_start_countdown()
			else:
				body.respawn(spawn_point_npc.global_position)
	else:
		# Practice mode — just respawn
		if body.has_method("respawn"):
			body.respawn(respawn_pos)


func _on_kill_zone_2v2(body: Node2D) -> void:
	if not is_instance_valid(body):
		return
	# Determine which team scored
	if "team_id" in body:
		if body.team_id == 0:
			# Player's team member died — enemy scores
			enemy_score += 1
		else:
			# Enemy team member died — player's team scores
			team_score += 1
			GameState.advance_daily_challenges("kill", 1)
			if is_instance_valid(player) and player.has_method("on_ko_scored"):
				player.on_ko_scored()
	if not _check_match_end_2v2():
		_respawn_all()
		_start_countdown()
	else:
		# Match ended, just respawn the fallen body
		if body.has_method("respawn"):
			body.respawn(_get_fighter_spawn_pos(body))


func _check_match_end() -> bool:
	if p1_score >= KILLS_TO_WIN:
		_end_match(true)
		return true
	elif cpu_score >= KILLS_TO_WIN:
		_end_match(false)
		return true
	return false


func _check_match_end_2v2() -> bool:
	if team_score >= KILLS_TO_WIN_2V2:
		_end_match(true)
		return true
	elif enemy_score >= KILLS_TO_WIN_2V2:
		_end_match(false)
		return true
	return false


func _end_match(player_won: bool) -> void:
	match_over = true

	# ── Victory slow-mo effect ──
	_start_slow_mo()

	# ── Screen shake on KO ──
	screen_shake(12.0, 0.4)

	# Update trophies (per-weapon) — reward scales down at higher trophies
	var wid: String = GameState.fighter_weapon_id
	if is_instance_valid(player) and player.weapon_id != "":
		wid = player.weapon_id
	var current_weapon_trophies := GameState.get_weapon_trophies(wid)
	var trophy_reward := TROPHY_REWARD_BASE
	if current_weapon_trophies >= 5000:
		trophy_reward = 1
	elif current_weapon_trophies >= 3000:
		trophy_reward = 3
	elif current_weapon_trophies >= 2000:
		trophy_reward = 5
	elif current_weapon_trophies >= 1000:
		trophy_reward = 7
	var trophy_change := 0
	var coin_change := 0
	var streak_bonus := ""
	var first_win_bonus := ""
	if player_won:
		# Win streak multiplier on trophies
		GameState.on_match_win()
		var mult: float = GameState.get_streak_multiplier()
		trophy_change = int(ceil(float(trophy_reward) * mult))
		coin_change = 5
		# Solo gives 2x trophies
		if _is_solo_mode():
			trophy_change = int(ceil(float(trophy_change) * SOLO_TROPHY_MULT))
		# First win of the day = double trophies
		if GameState.check_first_win_of_day():
			trophy_change *= 2
			coin_change *= 2
			first_win_bonus = "  [2x FIRST WIN]"
		# Revenge match = double trophies
		if is_revenge_match:
			trophy_change *= 2
			first_win_bonus += "  [REVENGE x2]"
		GameState.add_weapon_trophies(wid, trophy_change)
		GameState.add_fighter_coins(coin_change)
		GameState.advance_pass()
		# Daily challenge progress
		GameState.advance_daily_challenges("win", 1, wid, GameState.fighter_game_mode)
		if trophy_change > 0:
			GameState.advance_daily_challenges("trophies", trophy_change)
		if GameState.fighter_win_streak >= 2:
			streak_bonus = "  (x%.1f streak)" % mult
		# Style points → bonus coins
		if stats_style_points > 0:
			var bonus_coins: int = int(float(stats_style_points) / 50.0)
			if bonus_coins > 0:
				GameState.add_fighter_coins(bonus_coins)
				coin_change += bonus_coins
		# Check achievements
		GameState.check_achievements(wid)
		GameState.check_match_achievements({
			"won": true,
			"damage_taken": stats_damage_taken,
			"style_points": stats_style_points,
			"max_combo": stats_max_combo,
		})
	else:
		trophy_change = -3
		coin_change = 2
		GameState.on_match_loss()
		GameState.add_weapon_trophies(wid, -3)
		GameState.add_fighter_coins(2)
	GameState.update_season_peak()
	GameState.save_fighter_trophies()

	var weapon_total := GameState.get_weapon_trophies(wid)

	# Show result screen
	result_panel.visible = true

	if player_won:
		if _is_solo_mode():
			result_label.text = "#1 VICTORY ROYALE!"
		elif _is_2v2_mode():
			result_label.text = "TEAM WINS!"
		else:
			result_label.text = "YOU WIN!"
		result_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		result_trophy_label.text = "+%d Trophies%s%s  (%s: %d)" % [trophy_change, streak_bonus, first_win_bonus, str(WEAPON_NAMES.get(wid, wid)), weapon_total]
		# Show streak info
		if GameState.fighter_win_streak >= 2 and result_hint_label:
			result_hint_label.text = "Win Streak: %d  |  R to rematch · ESC for lobby" % GameState.fighter_win_streak
	else:
		if _is_solo_mode():
			result_label.text = "#%d - ELIMINATED" % solo_placement
		elif _is_2v2_mode():
			result_label.text = "TEAM LOSES"
		else:
			result_label.text = "YOU LOSE"
		result_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		if trophy_change < 0:
			result_trophy_label.text = "%d Trophies  (%s: %d)" % [trophy_change, str(WEAPON_NAMES.get(wid, wid)), weapon_total]
		else:
			result_trophy_label.text = "%s: %d Trophies" % [str(WEAPON_NAMES.get(wid, wid)), weapon_total]

	# Show coin reward
	if result_coins_label:
		result_coins_label.text = "+%d Coins  (Total: %d)" % [coin_change, GameState.fighter_coins]

	# Show victory taunt
	_show_victory_taunt(player_won)

	# Show match stats
	_show_match_stats(player_won)

	# Show revenge button if player lost
	if not player_won and not is_revenge_match:
		_create_revenge_button()

	# Update trophy HUD too
	if trophy_label:
		trophy_label.text = "🏆 %d" % weapon_total

	# Freeze fighters completely (physics, process, and input)
	if is_instance_valid(player):
		player.set_physics_process(false)
		player.set_process(false)
		player.set_process_input(false)
		player.set_process_unhandled_input(false)
	if is_instance_valid(npc):
		npc.set_physics_process(false)
		npc.set_process(false)
		npc.set_process_input(false)
		npc.set_process_unhandled_input(false)
	if _is_2v2_mode():
		for f in [ally, enemy1, enemy2]:
			if is_instance_valid(f):
				f.set_physics_process(false)
				f.set_process(false)
				f.set_process_input(false)
				f.set_process_unhandled_input(false)


func _ensure_key(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	if not InputMap.action_has_event(action_name, event):
		InputMap.action_add_event(action_name, event)


func _ensure_mouse(action_name: String, button: MouseButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event := InputEventMouseButton.new()
	event.button_index = button
	if not InputMap.action_has_event(action_name, event):
		InputMap.action_add_event(action_name, event)


# ============================================================
# SCREEN SHAKE
# ============================================================

func screen_shake(intensity: float, duration: float) -> void:
	_shake_intensity = intensity
	_shake_timer = duration
	# Vibrate on mobile if enabled
	if GameState.vibration_enabled and DisplayServer.is_touchscreen_available():
		var vib_ms := int(clampf(duration * 100.0, 20.0, 200.0))
		Input.vibrate_handheld(vib_ms)


# ============================================================
# HIT FREEZE (brief pause on big hits)
# ============================================================

func hit_freeze(duration: float) -> void:
	_freeze_timer = duration
	Engine.time_scale = 0.05


# ============================================================
# SLOW-MO (victory / KO)
# ============================================================

func _start_slow_mo() -> void:
	Engine.time_scale = 0.3
	var tw := create_tween()
	tw.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tw.tween_property(Engine, "time_scale", 1.0, 0.8)


# ============================================================
# COMBO COUNTER
# ============================================================

func _create_combo_hud() -> void:
	combo_label = Label.new()
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.offset_left = 500
	combo_label.offset_top = 130
	combo_label.offset_right = 780
	combo_label.offset_bottom = 180
	combo_label.add_theme_font_size_override("font_size", 32)
	combo_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.1, 0.9))
	combo_label.visible = false
	$HUD.add_child(combo_label)

	style_label = Label.new()
	style_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	style_label.offset_left = 500
	style_label.offset_top = 170
	style_label.offset_right = 780
	style_label.offset_bottom = 200
	style_label.add_theme_font_size_override("font_size", 16)
	style_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.8))
	style_label.visible = false
	$HUD.add_child(style_label)


func on_player_hit_landed(damage: float, is_super: bool) -> void:
	# Called by Fighter when player lands a hit
	stats_damage_dealt += damage
	if is_super:
		stats_supers_used += 1
	combo_count += 1
	combo_timer = COMBO_TIMEOUT
	if combo_label:
		combo_label.visible = true
		if combo_count >= 3:
			combo_label.text = "%d HIT COMBO!" % combo_count
			combo_label.add_theme_font_size_override("font_size", 32 + mini(combo_count * 2, 20))
		else:
			combo_label.text = "%d HITS" % combo_count
			combo_label.add_theme_font_size_override("font_size", 28)
	# Screen shake scales with combo
	screen_shake(3.0 + combo_count * 0.5, 0.15)
	# Hit freeze on big hits (supers or high combos)
	if is_super or combo_count >= 4:
		hit_freeze(0.06)


func on_player_got_hit(damage: float) -> void:
	stats_damage_taken += damage
	# Reset combo on getting hit
	if combo_count >= 3:
		stats_combos_landed += 1
		if combo_count > stats_max_combo:
			stats_max_combo = combo_count
	combo_count = 0
	combo_timer = 0.0
	if combo_label:
		combo_label.visible = false
	# Shake when player takes damage
	screen_shake(4.0, 0.2)


func _flash_style_points(points: int) -> void:
	if style_label:
		style_label.text = "+%d STYLE" % points
		style_label.visible = true
		var tw := create_tween()
		tw.tween_property(style_label, "modulate:a", 0.0, 1.0).from(1.0)
		tw.tween_callback(func(): style_label.visible = false; style_label.modulate.a = 1.0)


# ============================================================
# MATCH STATS
# ============================================================

func _show_match_stats(player_won: bool) -> void:
	var stats_text := ""
	stats_text += "Damage Dealt: %d  |  " % int(stats_damage_dealt)
	stats_text += "Damage Taken: %d\n" % int(stats_damage_taken)
	stats_text += "Best Combo: %d  |  " % stats_max_combo
	stats_text += "Supers Used: %d  |  " % stats_supers_used
	stats_text += "Style: %d pts" % stats_style_points
	if player_won and stats_style_points >= 50:
		stats_text += "  (+%d bonus coins)" % (int(float(stats_style_points) / 50.0))

	var stats_lbl := Label.new()
	stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_lbl.offset_left = 240
	stats_lbl.offset_top = 480
	stats_lbl.offset_right = 1040
	stats_lbl.offset_bottom = 550
	stats_lbl.add_theme_font_size_override("font_size", 14)
	stats_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 0.8))
	stats_lbl.text = stats_text
	result_panel.add_child(stats_lbl)


# ============================================================
# REVENGE BUTTON
# ============================================================

func _create_revenge_button() -> void:
	revenge_btn = Button.new()
	revenge_btn.text = "REVENGE (2x Trophies)"
	revenge_btn.offset_left = 490
	revenge_btn.offset_top = 560
	revenge_btn.offset_right = 790
	revenge_btn.offset_bottom = 600
	revenge_btn.add_theme_font_size_override("font_size", 18)
	revenge_btn.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.3, 0.05, 0.05, 0.9)
	sb.border_color = Color(1.0, 0.3, 0.2, 0.8)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(4)
	revenge_btn.add_theme_stylebox_override("normal", sb)
	var sbh := StyleBoxFlat.new()
	sbh.bg_color = Color(0.4, 0.08, 0.08, 0.95)
	sbh.border_color = Color(1.0, 0.4, 0.3, 1.0)
	sbh.set_border_width_all(2)
	sbh.set_corner_radius_all(8)
	sbh.set_content_margin_all(4)
	revenge_btn.add_theme_stylebox_override("hover", sbh)
	revenge_btn.pressed.connect(_on_revenge_pressed)
	result_panel.add_child(revenge_btn)


func _on_revenge_pressed() -> void:
	GameState.set_meta("_revenge_next_match", true)
	get_tree().reload_current_scene()


# ============================================================
# WEAPON TUTORIAL (first-time popup)
# ============================================================

const WEAPON_TUTORIALS := {
	"minato_kunai": [
		"MINATO KUNAI - Yellow Flash",
		"",
		"LIGHT ATTACK (LMB): Throw a kunai",
		"  Fast projectile that marks your target",
		"",
		"HEAVY ATTACK (RMB): Teleport Strike",
		"  Blink forward and strike at destination",
		"  Use to close distance instantly",
		"",
		"SUPER (on opponent's head): RASENGAN",
		"  Teleport behind enemy + massive spiral burst",
		"  Devastating close-range finisher",
		"",
		"TIP: Throw kunai then blink for combos!",
		"Your speed is the fastest in the game (1.2x)",
	],
}

func _should_show_weapon_tutorial() -> bool:
	var wid: String = GameState.fighter_weapon_id
	if wid not in WEAPON_TUTORIALS:
		return false
	var seen_key := "tutorial_seen_%s" % wid
	return not GameState.get_meta(seen_key, false)


func _show_weapon_tutorial() -> void:
	var wid: String = GameState.fighter_weapon_id
	var lines: Array = WEAPON_TUTORIALS.get(wid, [])
	if lines.is_empty():
		return
	# Mark as seen
	GameState.set_meta("tutorial_seen_%s" % wid, true)

	# Create tutorial overlay
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.88)
	overlay.offset_left = 0; overlay.offset_top = 0
	overlay.offset_right = 1280; overlay.offset_bottom = 720
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	$HUD.add_child(overlay)

	var y_pos := 120.0
	# Title
	var title_lbl := Label.new()
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.offset_left = 290; title_lbl.offset_top = y_pos; title_lbl.offset_right = 990; title_lbl.offset_bottom = y_pos + 40
	title_lbl.add_theme_font_size_override("font_size", 28)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	title_lbl.text = str(lines[0]) if lines.size() > 0 else "TUTORIAL"
	overlay.add_child(title_lbl)
	y_pos += 50.0

	# Tutorial lines
	for i in range(1, lines.size()):
		var line_lbl := Label.new()
		line_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line_lbl.offset_left = 290; line_lbl.offset_top = y_pos; line_lbl.offset_right = 990; line_lbl.offset_bottom = y_pos + 24
		line_lbl.add_theme_font_size_override("font_size", 16)
		var line_text: String = str(lines[i])
		if line_text.begins_with("LIGHT") or line_text.begins_with("HEAVY") or line_text.begins_with("SUPER") or line_text.begins_with("TIP"):
			line_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
		else:
			line_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 0.9))
		line_lbl.text = line_text
		overlay.add_child(line_lbl)
		y_pos += 26.0

	# Close hint
	var close_lbl := Label.new()
	close_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	close_lbl.offset_left = 290; close_lbl.offset_top = 620; close_lbl.offset_right = 990; close_lbl.offset_bottom = 650
	close_lbl.add_theme_font_size_override("font_size", 18)
	close_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.5))
	close_lbl.text = "Click or press any key to start"
	overlay.add_child(close_lbl)

	# Close on any input
	overlay.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			overlay.queue_free()
		elif event is InputEventKey and event.pressed:
			overlay.queue_free()
	)


# ============================================================
# SOLO BATTLE ROYALE (10 players, last standing wins)
# ============================================================

func _spawn_solo_fighters(_weapon: String) -> void:
	var scaled := _get_scaled_trophies(_weapon)
	# Spread 10 fighters across the arena
	var arena_left := spawn_point.global_position.x - 200
	var arena_right := spawn_point_npc.global_position.x + 200
	var arena_width := arena_right - arena_left
	var spacing := arena_width / float(SOLO_PLAYER_COUNT)

	# Player is already spawned, place them at slot 0
	player.global_position.x = arena_left + spacing * 0.5

	# Spawn 9 AI fighters
	for i in range(SOLO_PLAYER_COUNT - 1):
		var ai := AI_FIGHTER_SCENE.instantiate()
		ai.weapon_id = ALL_WEAPONS[randi() % ALL_WEAPONS.size()]
		ai.team_id = i + 1  # each AI on its own team
		ai.trophy_count = scaled + randi_range(-50, 50)
		add_child(ai)
		ai.global_position = Vector2(
			arena_left + spacing * (i + 1.5),
			spawn_point.global_position.y
		)
		# Each AI targets the player initially, will retarget dynamically
		ai.opponent = player
		solo_fighters.append(ai)

	# Set player's initial opponent to nearest AI
	if solo_fighters.size() > 0:
		player.opponent = solo_fighters[0]
	solo_alive_count = SOLO_PLAYER_COUNT


func _on_kill_zone_solo(body: Node2D) -> void:
	if body == player:
		# Player eliminated
		solo_placement = solo_alive_count
		_end_match(false)
		return

	# An AI was eliminated
	if body in solo_fighters:
		solo_alive_count -= 1
		_update_solo_hud()
		GameState.advance_daily_challenges("kill", 1)
		if is_instance_valid(player) and player.has_method("on_ko_scored"):
			player.on_ko_scored()

		# Remove from fight - don't respawn, just hide
		body.set_physics_process(false)
		body.set_process(false)
		body.visible = false
		body.global_position = Vector2(-9999, -9999)

		# Retarget remaining AIs
		_solo_retarget()

		# Check win condition - last standing
		if solo_alive_count <= 1:
			solo_placement = 1
			_end_match(true)
			return

		screen_shake(5.0, 0.2)
		# Flash elimination count
		if countdown_label:
			countdown_label.text = "%d ALIVE" % solo_alive_count
			countdown_label.add_theme_font_size_override("font_size", 36)
			countdown_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))
			var tw := create_tween()
			tw.tween_property(countdown_label, "modulate:a", 0.0, 1.0).set_delay(0.5)


func _solo_retarget() -> void:
	# Get list of alive AIs
	var alive_ais: Array = []
	for ai in solo_fighters:
		if is_instance_valid(ai) and ai.visible:
			alive_ais.append(ai)

	# Assign random opponents among alive fighters (including player)
	var all_alive: Array = alive_ais.duplicate()
	if is_instance_valid(player):
		all_alive.append(player)

	for ai in alive_ais:
		# Pick a random target that isn't itself
		var targets := all_alive.filter(func(f): return f != ai)
		if targets.size() > 0:
			ai.opponent = targets[randi() % targets.size()]

	# Update player's opponent to nearest alive AI
	if is_instance_valid(player) and alive_ais.size() > 0:
		var nearest: Node2D = alive_ais[0]
		var nearest_dist: float = player.global_position.distance_to(nearest.global_position)
		for ai in alive_ais:
			var dist := player.global_position.distance_to(ai.global_position)
			if dist < nearest_dist:
				nearest = ai
				nearest_dist = dist
		player.opponent = nearest


func _create_solo_hud() -> void:
	solo_alive_label = Label.new()
	solo_alive_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	solo_alive_label.offset_left = 490
	solo_alive_label.offset_top = 75
	solo_alive_label.offset_right = 790
	solo_alive_label.offset_bottom = 95
	solo_alive_label.add_theme_font_size_override("font_size", 16)
	solo_alive_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4, 0.8))
	solo_alive_label.text = "%d ALIVE" % SOLO_PLAYER_COUNT
	$HUD.add_child(solo_alive_label)


func _update_solo_hud() -> void:
	if solo_alive_label:
		solo_alive_label.text = "%d ALIVE" % solo_alive_count


# ============================================================
# VICTORY TAUNTS
# ============================================================

func _show_victory_taunt(player_won: bool) -> void:
	var taunt_list: Array = TAUNTS_WIN if player_won else TAUNTS_LOSE
	var taunt_text: String = taunt_list[randi() % taunt_list.size()]
	taunt_label = Label.new()
	taunt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	taunt_label.offset_left = 340
	taunt_label.offset_top = 160
	taunt_label.offset_right = 940
	taunt_label.offset_bottom = 200
	taunt_label.add_theme_font_size_override("font_size", 24)
	var taunt_color := Color(1.0, 0.9, 0.3) if player_won else Color(0.8, 0.4, 0.4)
	taunt_label.add_theme_color_override("font_color", taunt_color)
	taunt_label.text = taunt_text
	taunt_label.modulate.a = 0.0
	result_panel.add_child(taunt_label)
	# Animate taunt
	var tw := create_tween()
	tw.tween_property(taunt_label, "modulate:a", 1.0, 0.3).set_delay(0.3)
	tw.tween_property(taunt_label, "modulate:a", 0.5, 1.5).set_delay(2.0)
