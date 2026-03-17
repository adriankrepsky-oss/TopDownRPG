extends Node2D

const FIGHTER_SCENE := preload("res://scenes/fighter/Fighter.tscn")

# Display order in the popup (sorted by unlock cost: easiest -> hardest)
const POPUP_ORDER := ["fists", "shadow_blade", "kunai_stars", "frost_staff", "vine_whip", "iron_buckler", "dragon_gauntlets", "spirit_bow", "warp_dagger", "thunder_claws", "poison_fang", "fire_greatsword", "thors_hammer", "blood_scythe", "bomb_flail", "gravity_orb", "plasma_cannon", "crystal_spear", "minato_kunai"]

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
const WEAPON_COLORS := {
	"fists": Color(0.3, 0.55, 1.0),
	"shadow_blade": Color(0.6, 0.2, 0.85),
	"kunai_stars": Color(0.7, 0.7, 0.75),
	"frost_staff": Color(0.3, 0.78, 1.0),
	"vine_whip": Color(0.3, 0.8, 0.2),
	"iron_buckler": Color(0.5, 0.55, 0.7),
	"dragon_gauntlets": Color(1.0, 0.35, 0.2),
	"spirit_bow": Color(1.0, 0.9, 0.5),
	"warp_dagger": Color(0.9, 0.2, 0.7),
	"thunder_claws": Color(1.0, 0.95, 0.3),
	"poison_fang": Color(0.4, 0.9, 0.15),
	"fire_greatsword": Color(1.0, 0.3, 0.1),
	"thors_hammer": Color(1.0, 0.82, 0.2),
	"blood_scythe": Color(0.7, 0.1, 0.15),
	"bomb_flail": Color(1.0, 0.5, 0.1),
	"gravity_orb": Color(0.4, 0.1, 0.6),
	"plasma_cannon": Color(0.2, 0.9, 1.0),
	"crystal_spear": Color(0.5, 0.7, 1.0),
	"minato_kunai": Color(1.0, 0.85, 0.2),
}
const WEAPON_HINTS := {
	"fists": "LMB light · RMB heavy",
	"shadow_blade": "LMB slash · RMB shadow dash",
	"kunai_stars": "LMB throw · RMB triple fan",
	"frost_staff": "LMB icicle · RMB frost nova",
	"vine_whip": "LMB crack · RMB pull enemy",
	"iron_buckler": "LMB bash · RMB block + counter",
	"dragon_gauntlets": "LMB rapid punch · RMB uppercut",
	"spirit_bow": "LMB arrow · RMB arrow rain",
	"warp_dagger": "LMB stab · RMB blink strike",
	"thunder_claws": "LMB claw · RMB lightning dash",
	"poison_fang": "LMB stab · RMB poison strike",
	"fire_greatsword": "LMB slash · RMB fire burst",
	"thors_hammer": "Hold LMB charge · devastating",
	"blood_scythe": "LMB sweep · RMB drain life",
	"bomb_flail": "LMB flail swing · RMB bomb toss",
	"gravity_orb": "LMB bolt · RMB gravity pull",
	"plasma_cannon": "LMB plasma bolt · RMB laser beam",
	"crystal_spear": "LMB thrust · RMB impale",
	"minato_kunai": "LMB kunai throw · RMB teleport · Super: Rasengan",
}

const MODE_ORDER := ["normal", "2v2", "solo", "practice"]
const MODE_NAMES := {"normal": "Normal", "2v2": "2v2 Teams", "solo": "Solo Royale", "practice": "Practice"}
const MODE_DESCRIPTIONS := {
	"normal": "First to 3 kills · Win = +10 trophies · +5 coins",
	"2v2": "You + ally vs 2 enemies · First to 5 · trophies + coins",
	"solo": "10 players · Last standing wins · 2x trophy reward",
	"practice": "NPC stands still · no trophies",
}

@onready var mode_label: Label = $HUD/ModeLabel
@onready var mode_hint: Label = $HUD/ModeHint
@onready var trophy_label: Label = $HUD/TrophyLabel

var mode_index: int = 0
var preview_fighter: CharacterBody2D

# Weapon selection UI
var weapon_btn: Button
var weapon_hint_label: Label
var weapon_popup: ColorRect
var popup_open: bool = false

# Battle pass UI
var currency_label: Label
var pass_btn: Button
var pass_popup: ColorRect
var pass_popup_open: bool = false
var pass_scroll_offset: int = 0
const PASS_VISIBLE_TIERS := 8

# Skin shop UI
var skin_btn: Button
var skin_popup: ColorRect
var skin_popup_open: bool = false
var skin_tab: String = "character"  # "character" or "weapon"

# Upgrade UI
var upgrade_btn: Button
var upgrade_popup: ColorRect
var upgrade_popup_open: bool = false

# Settings UI
var settings_btn: Button
var settings_popup: ColorRect
var settings_popup_open: bool = false
var _rebinding_action: String = ""  # action currently being rebound
var _rebinding_btn: Button = null   # button label to update

# Trophy Road UI
var road_btn: Button
var road_popup: ColorRect
var road_popup_open: bool = false
var road_scroll_offset: int = 0
var road_selected_index: int = 0
const ROAD_VISIBLE_NODES := 8

# Leaderboard UI
var lb_btn: Button
var lb_popup: ColorRect
var lb_popup_open: bool = false
var lb_weapon_filter: String = ""  # "" = all weapons (total trophies)
var lb_scroll_offset: int = 0
const LB_VISIBLE_ROWS := 12


# Profile UI
var profile_btn: Button
var profile_popup: ColorRect
var profile_popup_open: bool = false
var profile_preview: CharacterBody2D  # fighter preview in profile
var profile_skin_index: int = 0  # index into available body skins
var profile_weapon_index: int = 0  # index into available weapons

# Challenges UI
var challenges_btn: Button
var challenges_popup: ColorRect
var challenges_popup_open: bool = false

# Rank & Streak display
var rank_label: Label
var streak_label: Label

# Login Streak UI
var login_popup: ColorRect
var login_popup_open: bool = false

# Achievements UI
var achievements_btn: Button
var achievements_popup: ColorRect
var achievements_popup_open: bool = false
var ach_scroll_offset: int = 0
const ACH_VISIBLE_ROWS := 8

# Season info
var season_label: Label

var _time: float = 0.0
var _glow_rect: ColorRect
var _title_glow: ColorRect
var _particle_nodes: Array = []

func _ready() -> void:
	if not GameState.is_weapon_unlocked(GameState.fighter_weapon_id):
		GameState.fighter_weapon_id = "fists"
	mode_index = MODE_ORDER.find(GameState.fighter_game_mode)
	if mode_index == -1:
		mode_index = 0
		GameState.fighter_game_mode = MODE_ORDER[0]
	_spawn_preview()
	_create_glow_effects()
	_create_floating_particles()
	_create_currency_display()
	_create_weapon_button()
	_create_weapon_popup()
	_create_pass_button()
	_create_pass_popup()
	_create_skin_button()
	_create_skin_popup()
	_create_upgrade_button()
	_create_upgrade_popup()
	_create_settings_button()
	_create_settings_popup()
	_create_road_button()
	_create_road_popup()
	_create_lb_button()
	_create_lb_popup()
	_create_profile_button()
	_create_profile_popup()
	_create_challenges_button()
	_create_challenges_popup()
	_create_rank_display()
	_create_streak_display()
	_create_achievements_button()
	_create_achievements_popup()
	_create_season_display()
	_style_all_lobby_buttons()
	_update_mode_display()
	_update_trophy_display()
	_update_currency_display()
	# Login streak check
	GameState.check_login_streak()
	GameState.check_season()
	# Generate daily challenges if needed
	GameState.check_daily_challenges()
	_update_challenges_button()
	# Show login streak popup if reward available
	if not GameState.login_reward_claimed_today:
		_show_login_popup()
	# Sync profile name with OnlineLeaderboard
	OnlineLeaderboard.set_player_name(GameState.profile_name)
	OnlineLeaderboard.submit_score()


func _process(delta: float) -> void:
	_time += delta
	# Animate glow around preview fighter
	if _glow_rect:
		var pulse: float = 0.12 + 0.06 * sin(_time * 2.0)
		_glow_rect.color = Color(0.4, 0.25, 0.8, pulse)
	# Animate title glow
	if _title_glow:
		var glow_a: float = 0.15 + 0.08 * sin(_time * 1.5)
		_title_glow.color = Color(0.6, 0.4, 1.0, glow_a)
	# Animate floating particles
	for p in _particle_nodes:
		if is_instance_valid(p):
			var base_y: float = p.get_meta("base_y", p.position.y)
			var speed: float = p.get_meta("speed", 1.0)
			var amp: float = p.get_meta("amp", 8.0)
			p.position.y = base_y + sin(_time * speed + p.position.x * 0.01) * amp
			var pa: float = 0.2 + 0.15 * sin(_time * speed * 0.7)
			p.color = Color(p.color.r, p.color.g, p.color.b, pa)
	# Twinkle stars
	for i in range(1, 9):
		var star := get_node_or_null("Star" + str(i))
		if star:
			var twinkle: float = 0.3 + 0.4 * abs(sin(_time * (0.8 + i * 0.2) + i * 1.5))
			star.color = Color(star.color.r, star.color.g, star.color.b, twinkle)


func _create_glow_effects() -> void:
	# Glow behind preview fighter
	_glow_rect = ColorRect.new()
	_glow_rect.color = Color(0.4, 0.25, 0.8, 0.12)
	_glow_rect.offset_left = 540; _glow_rect.offset_top = 190
	_glow_rect.offset_right = 740; _glow_rect.offset_bottom = 420
	_glow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HUD.add_child(_glow_rect)
	$HUD.move_child(_glow_rect, 0)

	# Title glow background
	_title_glow = ColorRect.new()
	_title_glow.color = Color(0.6, 0.4, 1.0, 0.15)
	_title_glow.offset_left = 350; _title_glow.offset_top = 25
	_title_glow.offset_right = 930; _title_glow.offset_bottom = 105
	_title_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HUD.add_child(_title_glow)
	$HUD.move_child(_title_glow, 0)


func _create_floating_particles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(15):
		var p := Polygon2D.new()
		var size: float = rng.randf_range(1.5, 4.0)
		p.polygon = PackedVector2Array([
			Vector2(-size, -size), Vector2(size, -size),
			Vector2(size, size), Vector2(-size, size),
		])
		var px: float = rng.randf_range(-600, 600)
		var py: float = rng.randf_range(-340, 320)
		p.position = Vector2(px, py)
		var hue: float = rng.randf_range(0.6, 0.85)
		p.color = Color.from_hsv(hue, 0.4, 0.9, 0.2)
		p.set_meta("base_y", py)
		p.set_meta("speed", rng.randf_range(0.5, 1.5))
		p.set_meta("amp", rng.randf_range(4.0, 12.0))
		add_child(p)
		_particle_nodes.append(p)


func _make_styled_button(btn: Button, bg_color: Color, border_color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(4)
	btn.add_theme_stylebox_override("normal", style)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(bg_color.r + 0.05, bg_color.g + 0.05, bg_color.b + 0.1, bg_color.a)
	hover.border_color = Color(border_color.r, border_color.g, border_color.b, minf(border_color.a + 0.3, 1.0))
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(6)
	hover.set_content_margin_all(4)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(bg_color.r + 0.08, bg_color.g + 0.08, bg_color.b + 0.15, bg_color.a)
	pressed.border_color = Color(border_color.r, border_color.g, border_color.b, 1.0)
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(6)
	pressed.set_content_margin_all(4)
	btn.add_theme_stylebox_override("pressed", pressed)


func _style_all_lobby_buttons() -> void:
	# Style bottom row buttons
	_make_styled_button(skin_btn, Color(0.12, 0.08, 0.2, 0.85), Color(0.6, 0.3, 0.8, 0.5))
	_make_styled_button(pass_btn, Color(0.06, 0.12, 0.2, 0.85), Color(0.2, 0.6, 0.9, 0.5))
	_make_styled_button(upgrade_btn, Color(0.15, 0.1, 0.05, 0.85), Color(0.8, 0.5, 0.1, 0.5))
	_make_styled_button(settings_btn, Color(0.1, 0.1, 0.12, 0.85), Color(0.5, 0.5, 0.6, 0.4))
	# Style top row buttons
	_make_styled_button(road_btn, Color(0.12, 0.1, 0.04, 0.85), Color(0.7, 0.55, 0.15, 0.5))
	_make_styled_button(lb_btn, Color(0.06, 0.1, 0.18, 0.85), Color(0.3, 0.6, 0.9, 0.5))
	# Style the FIGHT button
	var fight_btn := $HUD/FightButton
	if fight_btn:
		var fs := StyleBoxFlat.new()
		fs.bg_color = Color(0.15, 0.3, 0.6, 0.9)
		fs.border_color = Color(0.4, 0.7, 1.0, 0.8)
		fs.set_border_width_all(3)
		fs.set_corner_radius_all(10)
		fs.set_content_margin_all(6)
		fight_btn.add_theme_stylebox_override("normal", fs)
		var fh := StyleBoxFlat.new()
		fh.bg_color = Color(0.2, 0.4, 0.75, 0.95)
		fh.border_color = Color(0.5, 0.8, 1.0, 1.0)
		fh.set_border_width_all(3)
		fh.set_corner_radius_all(10)
		fh.set_content_margin_all(6)
		fight_btn.add_theme_stylebox_override("hover", fh)
		var fp := StyleBoxFlat.new()
		fp.bg_color = Color(0.25, 0.5, 0.85, 1.0)
		fp.border_color = Color(0.6, 0.9, 1.0, 1.0)
		fp.set_border_width_all(3)
		fp.set_corner_radius_all(10)
		fp.set_content_margin_all(6)
		fight_btn.add_theme_stylebox_override("pressed", fp)
	# Style mode arrow buttons
	var prev_btn := $HUD/PrevModeButton
	var next_btn := $HUD/NextModeButton
	if prev_btn:
		_make_styled_button(prev_btn, Color(0.12, 0.1, 0.06, 0.8), Color(0.7, 0.55, 0.2, 0.4))
	if next_btn:
		_make_styled_button(next_btn, Color(0.12, 0.1, 0.06, 0.8), Color(0.7, 0.55, 0.2, 0.4))
	# Style weapon button
	_make_styled_button(weapon_btn, Color(0.08, 0.06, 0.16, 0.85), Color(0.5, 0.35, 0.8, 0.5))
	# Style profile button
	_make_styled_button(profile_btn, Color(0.1, 0.08, 0.18, 0.85), Color(0.5, 0.7, 0.4, 0.5))
	# Style challenges button
	_make_styled_button(challenges_btn, Color(0.15, 0.1, 0.04, 0.85), Color(0.9, 0.6, 0.1, 0.5))
	# Style achievements button
	if achievements_btn:
		_make_styled_button(achievements_btn, Color(0.08, 0.12, 0.06, 0.85), Color(0.4, 0.8, 0.3, 0.5))


# ─── PREVIEW FIGHTER ───────────────────────────────────

func _spawn_preview() -> void:
	if preview_fighter:
		preview_fighter.queue_free()
	preview_fighter = FIGHTER_SCENE.instantiate()
	preview_fighter.weapon_id = GameState.fighter_weapon_id
	add_child(preview_fighter)
	preview_fighter.set_physics_process(false)
	preview_fighter.set_process(false)
	preview_fighter.get_node("CollisionShape2D").set_deferred("disabled", true)
	preview_fighter.global_position = $PreviewSpawn.global_position
	preview_fighter.scale = Vector2(2.5, 2.5)


# ─── CURRENCY DISPLAY ─────────────────────────────────

func _create_currency_display() -> void:
	currency_label = Label.new()
	currency_label.offset_left = 40
	currency_label.offset_top = 58
	currency_label.offset_right = 500
	currency_label.offset_bottom = 82
	currency_label.add_theme_font_size_override("font_size", 15)
	currency_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 0.7))
	$HUD.add_child(currency_label)


func _update_currency_display() -> void:
	if currency_label:
		currency_label.text = "Coins: %d    Gems: %d    Power Ups: %d" % [
			GameState.fighter_coins, GameState.fighter_gems, GameState.fighter_power_ups]


# ─── WEAPON BUTTON (main lobby) ───────────────────────

func _create_weapon_button() -> void:
	var wid := GameState.fighter_weapon_id
	var col: Color = WEAPON_COLORS.get(wid, Color.WHITE)
	weapon_btn = Button.new()
	weapon_btn.text = WEAPON_NAMES.get(wid, wid)
	weapon_btn.offset_left = 440
	weapon_btn.offset_top = 475
	weapon_btn.offset_right = 840
	weapon_btn.offset_bottom = 525
	weapon_btn.add_theme_font_size_override("font_size", 24)
	weapon_btn.add_theme_color_override("font_color", col)
	weapon_btn.pressed.connect(_open_weapon_popup)
	$HUD.add_child(weapon_btn)

	weapon_hint_label = Label.new()
	weapon_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_hint_label.offset_left = 390
	weapon_hint_label.offset_top = 530
	weapon_hint_label.offset_right = 890
	weapon_hint_label.offset_bottom = 552
	weapon_hint_label.add_theme_font_size_override("font_size", 12)
	weapon_hint_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6, 0.5))
	weapon_hint_label.text = "Click to change weapon"
	$HUD.add_child(weapon_hint_label)


func _update_weapon_button() -> void:
	var wid := GameState.fighter_weapon_id
	var col: Color = WEAPON_COLORS.get(wid, Color.WHITE)
	weapon_btn.text = WEAPON_NAMES.get(wid, wid)
	weapon_btn.add_theme_color_override("font_color", col)


# ─── WEAPON SELECTION POPUP ───────────────────────────

func _create_weapon_popup() -> void:
	weapon_popup = ColorRect.new()
	weapon_popup.color = Color(0, 0, 0, 0.88)
	weapon_popup.offset_left = 0
	weapon_popup.offset_top = 0
	weapon_popup.offset_right = 1280
	weapon_popup.offset_bottom = 720
	weapon_popup.visible = false
	weapon_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	$HUD.add_child(weapon_popup)


func _open_weapon_popup() -> void:
	if _any_popup_open():
		return
	popup_open = true
	for child in weapon_popup.get_children():
		child.queue_free()

	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = 290; title.offset_top = 40; title.offset_right = 990; title.offset_bottom = 90
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.85, 0.75, 1.0))
	title.text = "SELECT WEAPON"
	weapon_popup.add_child(title)

	var card_w := 130.0; var card_h := 165.0; var gap := 10.0
	var cols := 6
	var row_total := card_w * cols + gap * (cols - 1)
	var start_x := (1280.0 - row_total) / 2.0
	var rows := ceili(POPUP_ORDER.size() / float(cols))
	for row in range(rows):
		var row_y := 90.0 + row * (card_h + gap)
		for col in range(cols):
			var idx := row * cols + col
			if idx >= POPUP_ORDER.size():
				break
			var card_x := start_x + col * (card_w + gap)
			_add_weapon_card(POPUP_ORDER[idx], card_x, row_y, card_w, card_h)

	var hint := Label.new()
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.offset_left = 290; hint.offset_top = 660; hint.offset_right = 990; hint.offset_bottom = 690
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.3))
	hint.text = "Press ESC to close"
	weapon_popup.add_child(hint)
	weapon_popup.visible = true


func _add_weapon_card(wid: String, x: float, y: float, w: float, h: float) -> void:
	var unlocked := GameState.is_weapon_unlocked(wid)
	var selected := (wid == GameState.fighter_weapon_id)
	var col: Color = WEAPON_COLORS.get(wid, Color.WHITE)
	var cost: int = GameState.get_weapon_cost(wid)
	var can_buy := not unlocked and GameState.fighter_coins >= cost

	var card := Button.new()
	card.offset_left = x; card.offset_top = y; card.offset_right = x + w; card.offset_bottom = y + h
	card.name = "Card_%s" % wid
	if unlocked:
		card.pressed.connect(_select_weapon.bind(wid))
	elif can_buy:
		card.pressed.connect(_buy_and_select_weapon.bind(wid))
	weapon_popup.add_child(card)

	# Colored bar (weapon display area)
	var bar := ColorRect.new()
	bar.offset_left = 4; bar.offset_top = 4; bar.offset_right = w - 4; bar.offset_bottom = 80
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.color = Color(col.r * 0.3, col.g * 0.3, col.b * 0.3, 0.85) if unlocked else Color(0.08, 0.08, 0.12, 0.9)
	card.add_child(bar)

	# Weapon visual (drawn with polygons)
	_add_weapon_visual(bar, wid, w - 8, 76, unlocked)

	# Rarity badge
	var rarity_lbl := Label.new()
	rarity_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_lbl.offset_left = 4; rarity_lbl.offset_top = 82; rarity_lbl.offset_right = w - 4; rarity_lbl.offset_bottom = 96
	rarity_lbl.add_theme_font_size_override("font_size", 9)
	rarity_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rarity_lbl.text = GameState.get_rarity_name(wid)
	rarity_lbl.add_theme_color_override("font_color", GameState.get_rarity_color(wid))
	card.add_child(rarity_lbl)

	# Weapon name
	var name_lbl := Label.new()
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.offset_left = 4; name_lbl.offset_top = 96; name_lbl.offset_right = w - 4; name_lbl.offset_bottom = 116
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_lbl.text = WEAPON_NAMES.get(wid, wid)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.9) if unlocked else Color(0.45, 0.45, 0.5, 0.7))
	card.add_child(name_lbl)

	# Status line
	var status := Label.new()
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.offset_left = 4; status.offset_top = 116; status.offset_right = w - 4; status.offset_bottom = 134
	status.add_theme_font_size_override("font_size", 9)
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not unlocked:
		if can_buy:
			status.text = "BUY · %d Coins" % cost
			status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 0.9))
		else:
			status.text = "%d Coins needed" % cost
			status.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3, 0.8))
	elif selected:
		status.text = "✓ SELECTED"
		status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 0.9))
	else:
		status.text = "🏆 %d" % GameState.get_weapon_trophies(wid)
		status.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.7))
	card.add_child(status)

	# Tips / control hints
	var tips := Label.new()
	tips.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tips.offset_left = 4; tips.offset_top = 134; tips.offset_right = w - 4; tips.offset_bottom = 162
	tips.add_theme_font_size_override("font_size", 8)
	tips.autowrap_mode = TextServer.AUTOWRAP_WORD
	tips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tips.text = WEAPON_HINTS.get(wid, "") if unlocked else ""
	tips.add_theme_color_override("font_color", Color(0.65, 0.65, 0.75, 0.5))
	card.add_child(tips)

	# Selection border (green)
	if selected and unlocked:
		for pos_y in [0.0, h - 3.0]:
			var bdr := ColorRect.new()
			bdr.offset_left = 0; bdr.offset_top = pos_y; bdr.offset_right = w; bdr.offset_bottom = pos_y + 3
			bdr.color = Color(0.3, 1.0, 0.4, 0.7)
			bdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_child(bdr)

	# Buy border (gold glow for affordable)
	if can_buy:
		for pos_y in [0.0, h - 3.0]:
			var bdr := ColorRect.new()
			bdr.offset_left = 0; bdr.offset_top = pos_y; bdr.offset_right = w; bdr.offset_bottom = pos_y + 3
			bdr.color = Color(1.0, 0.85, 0.2, 0.6)
			bdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_child(bdr)


func _select_weapon(wid: String) -> void:
	GameState.fighter_weapon_id = wid
	_close_weapon_popup()
	_update_weapon_button()
	_update_trophy_display()
	_spawn_preview()


func _buy_and_select_weapon(wid: String) -> void:
	if GameState.buy_fighter_weapon(wid):
		GameState.fighter_weapon_id = wid
		_close_weapon_popup()
		_update_weapon_button()
		_update_trophy_display()
		_update_currency_display()
		_spawn_preview()


# ─── WEAPON VISUALS (drawn with Control._draw) ──────

func _add_weapon_visual(parent: Control, wid: String, area_w: float, area_h: float, unlocked: bool) -> void:
	var canvas := Control.new()
	canvas.offset_left = 0
	canvas.offset_top = 0
	canvas.offset_right = area_w
	canvas.offset_bottom = area_h
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(canvas)
	var a := 1.0 if unlocked else 0.25
	canvas.draw.connect(func(): _draw_weapon_icon(canvas, wid, a))
	canvas.queue_redraw()


func _draw_weapon_icon(canvas: Control, wid: String, alpha: float) -> void:
	var cx := canvas.size.x / 2.0
	var cy := canvas.size.y / 2.0
	match wid:
		"fists":
			_draw_fists_icon(canvas, cx, cy, alpha)
		"thors_hammer":
			_draw_hammer_icon(canvas, cx, cy, alpha)
		"shadow_blade":
			_draw_blade_icon(canvas, cx, cy, alpha)
		"frost_staff":
			_draw_staff_icon(canvas, cx, cy, alpha)
		"dragon_gauntlets":
			_draw_gauntlets_icon(canvas, cx, cy, alpha)
		"warp_dagger":
			_draw_warp_dagger_icon(canvas, cx, cy, alpha)
		"bomb_flail":
			_draw_bomb_flail_icon(canvas, cx, cy, alpha)
		"plasma_cannon":
			_draw_plasma_cannon_icon(canvas, cx, cy, alpha)
		"kunai_stars":
			_draw_kunai_stars_icon(canvas, cx, cy, alpha)
		"vine_whip":
			_draw_vine_whip_icon(canvas, cx, cy, alpha)
		"iron_buckler":
			_draw_iron_buckler_icon(canvas, cx, cy, alpha)
		"spirit_bow":
			_draw_spirit_bow_icon(canvas, cx, cy, alpha)
		"thunder_claws":
			_draw_thunder_claws_icon(canvas, cx, cy, alpha)
		"poison_fang":
			_draw_poison_fang_icon(canvas, cx, cy, alpha)
		"fire_greatsword":
			_draw_fire_greatsword_icon(canvas, cx, cy, alpha)
		"blood_scythe":
			_draw_blood_scythe_icon(canvas, cx, cy, alpha)
		"gravity_orb":
			_draw_gravity_orb_icon(canvas, cx, cy, alpha)
		"crystal_spear":
			_draw_crystal_spear_icon(canvas, cx, cy, alpha)


func _draw_fists_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var skin := Color(0.9, 0.75, 0.55, a)
	var dark := Color(0.7, 0.55, 0.35, a)
	# Left fist
	c.draw_rect(Rect2(cx - 32, cy - 14, 24, 28), skin)
	c.draw_rect(Rect2(cx - 32, cy - 17, 24, 6), dark)
	c.draw_rect(Rect2(cx - 32, cy + 12, 24, 4), dark)
	# Right fist
	c.draw_rect(Rect2(cx + 8, cy - 14, 24, 28), skin)
	c.draw_rect(Rect2(cx + 8, cy - 17, 24, 6), dark)
	c.draw_rect(Rect2(cx + 8, cy + 12, 24, 4), dark)


func _draw_hammer_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var handle := Color(0.55, 0.35, 0.2, a)
	var head := Color(0.7, 0.7, 0.78, a)
	var glow := Color(0.4, 0.6, 1.0, a * 0.5)
	# Handle
	c.draw_rect(Rect2(cx - 3, cy - 2, 6, 38), handle)
	# Hammer head
	c.draw_rect(Rect2(cx - 20, cy - 22, 40, 22), head)
	# Lightning glow
	c.draw_rect(Rect2(cx - 18, cy - 20, 36, 18), glow)
	# Pommel
	c.draw_rect(Rect2(cx - 5, cy + 34, 10, 6), handle.darkened(0.2))


func _draw_blade_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var blade := Color(0.6, 0.2, 0.85, a)
	var edge := Color(0.85, 0.55, 1.0, a)
	var guard := Color(0.4, 0.35, 0.55, a)
	var grip := Color(0.3, 0.18, 0.4, a)
	# Blade
	var pts := PackedVector2Array([
		Vector2(cx, cy - 32), Vector2(cx + 8, cy + 2),
		Vector2(cx, cy + 10), Vector2(cx - 8, cy + 2)
	])
	c.draw_polygon(pts, PackedColorArray([blade, blade, blade, blade]))
	# Edge highlight
	c.draw_line(Vector2(cx, cy - 32), Vector2(cx + 7, cy), edge, 2.0)
	# Guard
	c.draw_rect(Rect2(cx - 12, cy + 8, 24, 5), guard)
	# Handle
	c.draw_rect(Rect2(cx - 3, cy + 13, 6, 16), grip)


func _draw_staff_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var staff := Color(0.45, 0.6, 0.8, a)
	var crystal := Color(0.3, 0.8, 1.0, a)
	var glow := Color(0.5, 0.88, 1.0, a * 0.35)
	# Staff body
	c.draw_rect(Rect2(cx - 2.5, cy - 5, 5, 42), staff)
	# Crystal (diamond shape)
	var pts := PackedVector2Array([
		Vector2(cx, cy - 30), Vector2(cx + 11, cy - 14),
		Vector2(cx, cy + 2), Vector2(cx - 11, cy - 14)
	])
	c.draw_polygon(pts, PackedColorArray([crystal, crystal, crystal, crystal]))
	# Glow
	c.draw_circle(Vector2(cx, cy - 14), 15, glow)


func _draw_gauntlets_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var metal := Color(0.85, 0.3, 0.15, a)
	var claw := Color(1.0, 0.65, 0.2, a)
	var accent := Color(0.6, 0.2, 0.1, a)
	# Left gauntlet
	c.draw_rect(Rect2(cx - 30, cy - 8, 22, 30), metal)
	c.draw_rect(Rect2(cx - 30, cy - 11, 22, 6), accent)
	for i in range(3):
		c.draw_rect(Rect2(cx - 28 + i * 7, cy - 20, 5, 12), claw)
	# Right gauntlet
	c.draw_rect(Rect2(cx + 8, cy - 8, 22, 30), metal)
	c.draw_rect(Rect2(cx + 8, cy - 11, 22, 6), accent)
	for i in range(3):
		c.draw_rect(Rect2(cx + 10 + i * 7, cy - 20, 5, 12), claw)


func _draw_warp_dagger_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var blade := Color(0.9, 0.2, 0.7, a)
	var edge := Color(1.0, 0.5, 0.85, a)
	var grip := Color(0.5, 0.15, 0.4, a)
	var glow := Color(0.9, 0.3, 0.8, a * 0.3)
	# Blade (short, wide dagger)
	var pts := PackedVector2Array([
		Vector2(cx, cy - 28), Vector2(cx + 10, cy - 4),
		Vector2(cx + 6, cy + 4), Vector2(cx - 6, cy + 4),
		Vector2(cx - 10, cy - 4)
	])
	c.draw_polygon(pts, PackedColorArray([blade, blade, blade, blade, blade]))
	# Edge highlight
	c.draw_line(Vector2(cx, cy - 28), Vector2(cx + 9, cy - 5), edge, 2.0)
	# Guard
	c.draw_rect(Rect2(cx - 14, cy + 4, 28, 4), edge)
	# Handle
	c.draw_rect(Rect2(cx - 3, cy + 8, 6, 18), grip)
	# Warp glow
	c.draw_circle(Vector2(cx, cy - 10), 18, glow)


func _draw_bomb_flail_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var chain := Color(0.5, 0.5, 0.55, a)
	var bomb := Color(0.25, 0.25, 0.3, a)
	var spike := Color(1.0, 0.5, 0.1, a)
	var fuse := Color(1.0, 0.8, 0.2, a)
	# Chain
	for i in range(5):
		c.draw_rect(Rect2(cx - 2, cy + i * 8, 4, 5), chain)
	# Handle
	c.draw_rect(Rect2(cx - 4, cy + 34, 8, 12), Color(0.4, 0.25, 0.15, a))
	# Bomb ball
	c.draw_circle(Vector2(cx, cy - 12), 16, bomb)
	# Spikes
	for angle_i in range(6):
		var angle: float = angle_i * (TAU / 6.0)
		var sx: float = cx + cos(angle) * 18.0
		var sy: float = cy - 12.0 + sin(angle) * 18.0
		c.draw_rect(Rect2(sx - 3, sy - 3, 6, 6), spike)
	# Fuse
	c.draw_line(Vector2(cx + 4, cy - 26), Vector2(cx + 10, cy - 34), fuse, 2.0)
	c.draw_circle(Vector2(cx + 10, cy - 34), 3, Color(1.0, 0.4, 0.1, a))


func _draw_plasma_cannon_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var body := Color(0.3, 0.35, 0.45, a)
	var barrel := Color(0.2, 0.8, 0.95, a)
	var glow := Color(0.2, 0.9, 1.0, a * 0.4)
	var accent := Color(0.15, 0.5, 0.65, a)
	# Cannon body
	c.draw_rect(Rect2(cx - 14, cy - 6, 28, 18), body)
	# Barrel
	c.draw_rect(Rect2(cx - 6, cy - 28, 12, 24), barrel)
	# Barrel accent lines
	c.draw_rect(Rect2(cx - 8, cy - 28, 16, 3), accent)
	c.draw_rect(Rect2(cx - 8, cy - 18, 16, 3), accent)
	# Handle / grip
	c.draw_rect(Rect2(cx - 4, cy + 12, 8, 16), Color(0.25, 0.25, 0.3, a))
	# Energy glow at barrel tip
	c.draw_circle(Vector2(cx, cy - 28), 8, glow)
	# Power core glow
	c.draw_circle(Vector2(cx, cy + 2), 6, glow)


func _draw_kunai_stars_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var metal := Color(0.7, 0.7, 0.75, a)
	var shine := Color(0.85, 0.85, 0.9, a)
	# Star shape (4-pointed)
	var pts := PackedVector2Array([
		Vector2(cx, cy - 18), Vector2(cx + 4, cy - 4),
		Vector2(cx + 18, cy), Vector2(cx + 4, cy + 4),
		Vector2(cx, cy + 18), Vector2(cx - 4, cy + 4),
		Vector2(cx - 18, cy), Vector2(cx - 4, cy - 4)
	])
	c.draw_polygon(pts, PackedColorArray([metal, metal, metal, metal, metal, metal, metal, metal]))
	c.draw_circle(Vector2(cx, cy), 4, shine)


func _draw_vine_whip_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var vine := Color(0.25, 0.6, 0.15, a)
	var leaf := Color(0.3, 0.8, 0.2, a)
	# Whip curve
	c.draw_line(Vector2(cx - 4, cy + 20), Vector2(cx, cy), vine, 3.0)
	c.draw_line(Vector2(cx, cy), Vector2(cx + 8, cy - 12), vine, 2.5)
	c.draw_line(Vector2(cx + 8, cy - 12), Vector2(cx + 2, cy - 24), vine, 2.0)
	# Leaves
	c.draw_circle(Vector2(cx + 2, cy - 24), 5, leaf)
	c.draw_circle(Vector2(cx + 10, cy - 8), 4, leaf)
	# Handle
	c.draw_rect(Rect2(cx - 5, cy + 18, 6, 12), Color(0.4, 0.25, 0.15, a))


func _draw_iron_buckler_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var shield := Color(0.45, 0.5, 0.6, a)
	var border := Color(0.6, 0.65, 0.75, a)
	var boss := Color(0.7, 0.72, 0.8, a)
	# Shield outline
	c.draw_circle(Vector2(cx, cy), 22, border)
	c.draw_circle(Vector2(cx, cy), 19, shield)
	# Boss (center knob)
	c.draw_circle(Vector2(cx, cy), 7, boss)
	# Cross pattern
	c.draw_rect(Rect2(cx - 1, cy - 16, 2, 32), border)
	c.draw_rect(Rect2(cx - 16, cy - 1, 32, 2), border)


func _draw_spirit_bow_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var wood := Color(0.8, 0.65, 0.3, a)
	var string_col := Color(1.0, 0.95, 0.7, a * 0.7)
	var glow := Color(1.0, 0.9, 0.5, a * 0.3)
	# Bow limbs
	c.draw_line(Vector2(cx - 4, cy - 24), Vector2(cx - 8, cy), wood, 3.0)
	c.draw_line(Vector2(cx - 8, cy), Vector2(cx - 4, cy + 24), wood, 3.0)
	# String
	c.draw_line(Vector2(cx - 4, cy - 24), Vector2(cx - 4, cy + 24), string_col, 1.5)
	# Arrow
	c.draw_line(Vector2(cx - 2, cy), Vector2(cx + 16, cy), wood, 2.0)
	# Arrowhead
	var pts := PackedVector2Array([Vector2(cx + 16, cy - 4), Vector2(cx + 22, cy), Vector2(cx + 16, cy + 4)])
	c.draw_polygon(pts, PackedColorArray([wood, wood, wood]))
	# Glow
	c.draw_circle(Vector2(cx + 18, cy), 6, glow)


func _draw_thunder_claws_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var metal := Color(0.9, 0.85, 0.2, a)
	var spark := Color(1.0, 1.0, 0.5, a * 0.5)
	# Left claw
	for i in range(3):
		c.draw_rect(Rect2(cx - 28 + i * 7, cy - 18, 5, 14), metal)
	c.draw_rect(Rect2(cx - 30, cy - 6, 22, 24), Color(0.7, 0.65, 0.15, a))
	# Right claw
	for i in range(3):
		c.draw_rect(Rect2(cx + 10 + i * 7, cy - 18, 5, 14), metal)
	c.draw_rect(Rect2(cx + 8, cy - 6, 22, 24), Color(0.7, 0.65, 0.15, a))
	# Sparks
	c.draw_circle(Vector2(cx, cy - 10), 6, spark)


func _draw_poison_fang_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var fang := Color(0.3, 0.7, 0.1, a)
	var drip := Color(0.4, 0.9, 0.15, a * 0.6)
	var grip := Color(0.2, 0.4, 0.1, a)
	# Left fang
	var pts_l := PackedVector2Array([Vector2(cx - 12, cy + 6), Vector2(cx - 8, cy - 22), Vector2(cx - 4, cy + 6)])
	c.draw_polygon(pts_l, PackedColorArray([fang, fang, fang]))
	# Right fang
	var pts_r := PackedVector2Array([Vector2(cx + 4, cy + 6), Vector2(cx + 8, cy - 22), Vector2(cx + 12, cy + 6)])
	c.draw_polygon(pts_r, PackedColorArray([fang, fang, fang]))
	# Grips
	c.draw_rect(Rect2(cx - 12, cy + 6, 8, 14), grip)
	c.draw_rect(Rect2(cx + 4, cy + 6, 8, 14), grip)
	# Drips
	c.draw_circle(Vector2(cx - 8, cy - 22), 3, drip)
	c.draw_circle(Vector2(cx + 8, cy - 22), 3, drip)


func _draw_fire_greatsword_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var blade := Color(0.7, 0.25, 0.08, a)
	var edge := Color(1.0, 0.5, 0.15, a)
	var glow := Color(1.0, 0.3, 0.1, a * 0.3)
	var guard := Color(0.5, 0.2, 0.1, a)
	# Blade
	var pts := PackedVector2Array([
		Vector2(cx, cy - 32), Vector2(cx + 8, cy + 2),
		Vector2(cx, cy + 8), Vector2(cx - 8, cy + 2)
	])
	c.draw_polygon(pts, PackedColorArray([blade, blade, blade, blade]))
	c.draw_line(Vector2(cx, cy - 32), Vector2(cx + 7, cy), edge, 2.0)
	# Guard
	c.draw_rect(Rect2(cx - 14, cy + 6, 28, 5), guard)
	# Handle
	c.draw_rect(Rect2(cx - 3, cy + 11, 6, 16), Color(0.35, 0.15, 0.08, a))
	# Fire glow
	c.draw_circle(Vector2(cx, cy - 16), 12, glow)


func _draw_blood_scythe_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var blade := Color(0.5, 0.08, 0.1, a)
	var edge := Color(0.7, 0.15, 0.2, a)
	var handle := Color(0.35, 0.2, 0.22, a)
	var glow := Color(0.7, 0.1, 0.15, a * 0.3)
	# Handle (long vertical)
	c.draw_rect(Rect2(cx - 2, cy - 10, 4, 36), handle)
	# Blade (curved)
	var pts := PackedVector2Array([
		Vector2(cx - 2, cy - 10), Vector2(cx + 4, cy - 16),
		Vector2(cx + 16, cy - 18), Vector2(cx + 18, cy - 14),
		Vector2(cx + 8, cy - 10), Vector2(cx + 2, cy - 6)
	])
	c.draw_polygon(pts, PackedColorArray([blade, blade, blade, blade, blade, blade]))
	c.draw_line(Vector2(cx + 4, cy - 16), Vector2(cx + 18, cy - 14), edge, 2.0)
	c.draw_circle(Vector2(cx + 12, cy - 16), 5, glow)


func _draw_gravity_orb_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var orb := Color(0.3, 0.08, 0.45, a)
	var ring := Color(0.5, 0.15, 0.7, a * 0.5)
	var glow := Color(0.4, 0.1, 0.6, a * 0.25)
	# Outer glow
	c.draw_circle(Vector2(cx, cy), 22, glow)
	# Ring
	c.draw_circle(Vector2(cx, cy), 16, ring)
	# Core orb
	c.draw_circle(Vector2(cx, cy), 10, orb)
	# Bright center
	c.draw_circle(Vector2(cx, cy), 4, Color(0.6, 0.3, 0.9, a))


func _draw_crystal_spear_icon(c: Control, cx: float, cy: float, a: float) -> void:
	var shaft := Color(0.4, 0.55, 0.8, a)
	var tip := Color(0.5, 0.7, 1.0, a)
	var glow := Color(0.5, 0.7, 1.0, a * 0.3)
	# Shaft
	c.draw_rect(Rect2(cx - 2, cy - 8, 4, 36), shaft)
	# Spear tip
	var pts := PackedVector2Array([Vector2(cx - 5, cy - 8), Vector2(cx, cy - 26), Vector2(cx + 5, cy - 8)])
	c.draw_polygon(pts, PackedColorArray([tip, tip, tip]))
	# Glow on tip
	c.draw_circle(Vector2(cx, cy - 18), 7, glow)
	# Pommel
	c.draw_rect(Rect2(cx - 4, cy + 26, 8, 4), Color(0.3, 0.4, 0.6, a))


func _close_weapon_popup() -> void:
	popup_open = false
	weapon_popup.visible = false


# ─── BATTLE PASS BUTTON ──────────────────────────────

func _create_pass_button() -> void:
	pass_btn = Button.new()
	pass_btn.text = "BATTLE PASS"
	pass_btn.offset_left = 520
	pass_btn.offset_top = 613
	pass_btn.offset_right = 765
	pass_btn.offset_bottom = 645
	pass_btn.add_theme_font_size_override("font_size", 16)
	pass_btn.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
	pass_btn.pressed.connect(_open_pass_popup)
	$HUD.add_child(pass_btn)


# ─── BATTLE PASS POPUP ───────────────────────────────

func _create_pass_popup() -> void:
	pass_popup = ColorRect.new()
	pass_popup.color = Color(0, 0, 0, 0.92)
	pass_popup.offset_left = 0
	pass_popup.offset_top = 0
	pass_popup.offset_right = 1280
	pass_popup.offset_bottom = 720
	pass_popup.visible = false
	pass_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	$HUD.add_child(pass_popup)


func _open_pass_popup() -> void:
	if _any_popup_open():
		return
	pass_popup_open = true
	# Center scroll on current progress
	pass_scroll_offset = maxi(GameState.fighter_pass_progress - 3, 0)
	_build_pass_contents()
	pass_popup.visible = true


func _pass_scroll(dir: int) -> void:
	pass_scroll_offset = maxi(pass_scroll_offset + dir, 0)
	_build_pass_contents()


func _build_pass_contents() -> void:
	for child in pass_popup.get_children():
		child.queue_free()

	# Title
	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = 190; title.offset_top = 25; title.offset_right = 1090; title.offset_bottom = 70
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
	title.text = "BATTLE PASS"
	pass_popup.add_child(title)

	# Currency display inside popup
	var cur := Label.new()
	cur.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cur.offset_left = 190; cur.offset_top = 72; cur.offset_right = 1090; cur.offset_bottom = 95
	cur.add_theme_font_size_override("font_size", 15)
	cur.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 0.6))
	cur.text = "Coins: %d    Gems: %d    Power Ups: %d" % [
		GameState.fighter_coins, GameState.fighter_gems, GameState.fighter_power_ups]
	pass_popup.add_child(cur)

	# --- Tier grid (windowed, 8 visible) ---
	var box_w := 110.0
	var box_h := 75.0
	var gap := 8.0
	var vis := PASS_VISIBLE_TIERS
	var total_w := box_w * vis + gap * (vis - 1)
	var sx := (1280.0 - total_w) / 2.0

	# Left scroll arrow
	if pass_scroll_offset > 0:
		var left_btn := Button.new()
		left_btn.offset_left = sx - 40; left_btn.offset_top = 180; left_btn.offset_right = sx - 8; left_btn.offset_bottom = 220
		left_btn.text = "<"
		left_btn.add_theme_font_size_override("font_size", 20)
		left_btn.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
		left_btn.pressed.connect(_pass_scroll.bind(-1))
		pass_popup.add_child(left_btn)

	# Right scroll arrow (always available — infinite pass)
	var right_btn := Button.new()
	right_btn.offset_left = sx + total_w + 8; right_btn.offset_top = 180
	right_btn.offset_right = sx + total_w + 40; right_btn.offset_bottom = 220
	right_btn.text = ">"
	right_btn.add_theme_font_size_override("font_size", 20)
	right_btn.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
	right_btn.pressed.connect(_pass_scroll.bind(1))
	pass_popup.add_child(right_btn)

	# Paid row label
	var paid_lbl := Label.new()
	paid_lbl.offset_left = sx; paid_lbl.offset_top = 110; paid_lbl.offset_right = sx + 300; paid_lbl.offset_bottom = 130
	paid_lbl.add_theme_font_size_override("font_size", 13)
	if GameState.fighter_pass_purchased:
		paid_lbl.text = "PREMIUM TRACK ✓"
		paid_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 0.8))
	else:
		paid_lbl.text = "PREMIUM TRACK 🔒"
		paid_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 0.6))
	pass_popup.add_child(paid_lbl)

	# Paid row boxes (windowed)
	var paid_y := 135.0
	for i in range(vis):
		var tier := pass_scroll_offset + i
		var bx := sx + i * (box_w + gap)
		_add_pass_box(tier, bx, paid_y, box_w, box_h, true)

	# Tier numbers
	var num_y := paid_y + box_h + 2
	for i in range(vis):
		var tier := pass_scroll_offset + i
		var bx := sx + i * (box_w + gap)
		var num := Label.new()
		num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num.offset_left = bx; num.offset_top = num_y; num.offset_right = bx + box_w; num.offset_bottom = num_y + 16
		num.add_theme_font_size_override("font_size", 11)
		var reached := tier < GameState.fighter_pass_progress
		num.add_theme_color_override("font_color", Color(1, 1, 1, 0.5) if reached else Color(0.4, 0.4, 0.4, 0.4))
		num.text = str(tier + 1)
		pass_popup.add_child(num)

	# Free row label
	var free_lbl := Label.new()
	var free_label_y := num_y + 20
	free_lbl.offset_left = sx; free_lbl.offset_top = free_label_y; free_lbl.offset_right = sx + 300; free_lbl.offset_bottom = free_label_y + 18
	free_lbl.add_theme_font_size_override("font_size", 13)
	free_lbl.text = "FREE TRACK"
	free_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 0.7))
	pass_popup.add_child(free_lbl)

	# Free row boxes (windowed)
	var free_y := free_label_y + 22
	for i in range(vis):
		var tier := pass_scroll_offset + i
		var bx := sx + i * (box_w + gap)
		_add_pass_box(tier, bx, free_y, box_w, box_h, false)

	# --- Progress text (no bar — infinite) ---
	var prog_y := free_y + box_h + 20
	var prog_lbl := Label.new()
	prog_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prog_lbl.offset_left = sx; prog_lbl.offset_top = prog_y; prog_lbl.offset_right = sx + total_w; prog_lbl.offset_bottom = prog_y + 24
	prog_lbl.add_theme_font_size_override("font_size", 15)
	prog_lbl.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0, 0.7))
	prog_lbl.text = "Progress: %d wins" % GameState.fighter_pass_progress
	pass_popup.add_child(prog_lbl)

	# --- Buy pass button (or purchased badge) ---
	var buy_y := prog_y + 35
	if not GameState.fighter_pass_purchased:
		var buy_btn := Button.new()
		buy_btn.offset_left = 490; buy_btn.offset_top = buy_y; buy_btn.offset_right = 790; buy_btn.offset_bottom = buy_y + 42
		buy_btn.add_theme_font_size_override("font_size", 18)
		if GameState.fighter_coins >= GameState.PASS_COST:
			buy_btn.text = "BUY PASS  -  %d Coins" % GameState.PASS_COST
			buy_btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
			buy_btn.pressed.connect(_on_buy_pass)
		else:
			buy_btn.text = "NEED %d Coins  (have %d)" % [GameState.PASS_COST, GameState.fighter_coins]
			buy_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.6))
		pass_popup.add_child(buy_btn)
	else:
		var badge := Label.new()
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge.offset_left = 490; badge.offset_top = buy_y; badge.offset_right = 790; badge.offset_bottom = buy_y + 35
		badge.add_theme_font_size_override("font_size", 18)
		badge.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 0.8))
		badge.text = "✓ PASS PURCHASED"
		pass_popup.add_child(badge)

	# ESC hint
	var esc := Label.new()
	esc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	esc.offset_left = 290; esc.offset_top = 675; esc.offset_right = 990; esc.offset_bottom = 700
	esc.add_theme_font_size_override("font_size", 14)
	esc.add_theme_color_override("font_color", Color(1, 1, 1, 0.25))
	esc.text = "Press ESC to close"
	pass_popup.add_child(esc)


func _add_pass_box(tier: int, x: float, y: float, w: float, h: float, is_paid: bool) -> void:
	var claimed_arr: Array[int] = GameState.fighter_pass_paid_claimed if is_paid else GameState.fighter_pass_free_claimed
	var reward: Dictionary = GameState.get_paid_reward(tier) if is_paid else GameState.get_free_reward(tier)
	var rtype: String = str(reward.get("type", "coins"))
	var amount: int = int(reward.get("amount", 0))
	var reached := tier < GameState.fighter_pass_progress
	var claimed := tier in claimed_arr
	var can_claim := reached and not claimed
	var pass_locked := is_paid and not GameState.fighter_pass_purchased

	# Box button
	var box := Button.new()
	box.offset_left = x; box.offset_top = y; box.offset_right = x + w; box.offset_bottom = y + h
	if can_claim and not pass_locked:
		box.pressed.connect(_on_claim_reward.bind(tier, is_paid))
	pass_popup.add_child(box)

	# Colored background
	var rcol: Color = GameState.REWARD_COLORS.get(rtype, Color(0.5, 0.5, 0.5))
	var bg := ColorRect.new()
	bg.offset_left = 3; bg.offset_top = 3; bg.offset_right = w - 3; bg.offset_bottom = h - 3
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if claimed:
		bg.color = Color(0.1, 0.15, 0.1, 0.8)
	elif pass_locked:
		bg.color = Color(0.1, 0.1, 0.12, 0.9)
	elif not reached:
		bg.color = Color(0.12, 0.12, 0.15, 0.7)
	elif can_claim:
		bg.color = Color(rcol.r * 0.5, rcol.g * 0.5, rcol.b * 0.5, 0.7)
	box.add_child(bg)

	# Reward icon + amount
	var icon_text: String = GameState.REWARD_ICONS.get(rtype, "?")
	var lbl := Label.new()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.offset_left = 0; lbl.offset_top = 2; lbl.offset_right = w - 6; lbl.offset_bottom = 38
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if claimed:
		lbl.text = "✓"
		lbl.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3, 0.7))
	elif pass_locked:
		lbl.text = "🔒"
		lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4, 0.6))
	else:
		lbl.text = "%s %d" % [icon_text, amount]
		var alpha := 0.9 if reached else 0.35
		lbl.add_theme_color_override("font_color", Color(rcol.r, rcol.g, rcol.b, alpha))
	box.add_child(lbl)

	# Type name
	var type_name: String = {"coins": "Coins", "gems": "Gems", "power_ups": "Power"}.get(rtype, rtype)
	var sub := Label.new()
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.offset_left = 0; sub.offset_top = 40; sub.offset_right = w - 6; sub.offset_bottom = 56
	sub.add_theme_font_size_override("font_size", 10)
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if claimed:
		sub.text = "Claimed"
		sub.add_theme_color_override("font_color", Color(0.4, 0.7, 0.4, 0.5))
	elif can_claim and not pass_locked:
		sub.text = "CLAIM!"
		sub.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 0.9))
	elif not reached:
		sub.text = type_name
		sub.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5, 0.3))
	else:
		sub.text = type_name
		sub.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.4))
	box.add_child(sub)

	# Glow border for claimable rewards
	if can_claim and not pass_locked:
		var glow := ColorRect.new()
		glow.offset_left = 0; glow.offset_top = 0; glow.offset_right = w; glow.offset_bottom = 2
		glow.color = Color(0.3, 1.0, 0.4, 0.8)
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(glow)
		var glow_b := ColorRect.new()
		glow_b.offset_left = 0; glow_b.offset_top = h - 2; glow_b.offset_right = w; glow_b.offset_bottom = h
		glow_b.color = Color(0.3, 1.0, 0.4, 0.8)
		glow_b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(glow_b)


func _on_claim_reward(tier: int, is_paid: bool) -> void:
	if is_paid:
		GameState.claim_paid_reward(tier)
	else:
		GameState.claim_free_reward(tier)
	# Rebuild popup to reflect changes
	_build_pass_contents()
	_update_currency_display()


func _on_buy_pass() -> void:
	if GameState.buy_fighter_pass():
		_build_pass_contents()
		_update_currency_display()


func _close_pass_popup() -> void:
	pass_popup_open = false
	pass_popup.visible = false


# ─── SKIN SHOP ───────────────────────────────────────

func _create_skin_button() -> void:
	skin_btn = Button.new()
	skin_btn.text = "SKINS"
	skin_btn.offset_left = 390
	skin_btn.offset_top = 613
	skin_btn.offset_right = 510
	skin_btn.offset_bottom = 645
	skin_btn.add_theme_font_size_override("font_size", 16)
	skin_btn.add_theme_color_override("font_color", Color(0.9, 0.5, 1.0))
	skin_btn.pressed.connect(_open_skin_popup)
	$HUD.add_child(skin_btn)


func _create_skin_popup() -> void:
	skin_popup = ColorRect.new()
	skin_popup.color = Color(0, 0, 0, 0.92)
	skin_popup.offset_left = 0
	skin_popup.offset_top = 0
	skin_popup.offset_right = 1280
	skin_popup.offset_bottom = 720
	skin_popup.visible = false
	skin_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	$HUD.add_child(skin_popup)


func _open_skin_popup() -> void:
	if _any_popup_open():
		return
	skin_popup_open = true
	skin_tab = "character"
	_build_skin_contents()
	skin_popup.visible = true


func _build_skin_contents() -> void:
	for child in skin_popup.get_children():
		child.queue_free()

	# Title
	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = 190; title.offset_top = 20; title.offset_right = 1090; title.offset_bottom = 60
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.9, 0.5, 1.0))
	title.text = "SKIN SHOP"
	skin_popup.add_child(title)

	# Gems display
	var gems_lbl := Label.new()
	gems_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gems_lbl.offset_left = 190; gems_lbl.offset_top = 60; gems_lbl.offset_right = 1090; gems_lbl.offset_bottom = 82
	gems_lbl.add_theme_font_size_override("font_size", 15)
	gems_lbl.add_theme_color_override("font_color", Color(0.2, 0.75, 1.0, 0.8))
	gems_lbl.text = "Gems: %d" % GameState.fighter_gems
	skin_popup.add_child(gems_lbl)

	# Tab buttons
	var body_tab := Button.new()
	body_tab.offset_left = 230; body_tab.offset_top = 90; body_tab.offset_right = 420; body_tab.offset_bottom = 120
	body_tab.add_theme_font_size_override("font_size", 16)
	body_tab.text = "Body Skins"
	if skin_tab == "body":
		body_tab.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2))
	else:
		body_tab.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		body_tab.pressed.connect(_switch_skin_tab.bind("body"))
	skin_popup.add_child(body_tab)

	var char_tab := Button.new()
	char_tab.offset_left = 440; char_tab.offset_top = 90; char_tab.offset_right = 630; char_tab.offset_bottom = 120
	char_tab.add_theme_font_size_override("font_size", 16)
	char_tab.text = "Color Skins"
	if skin_tab == "character":
		char_tab.add_theme_color_override("font_color", Color(0.9, 0.5, 1.0))
	else:
		char_tab.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		char_tab.pressed.connect(_switch_skin_tab.bind("character"))
	skin_popup.add_child(char_tab)

	var weap_tab := Button.new()
	weap_tab.offset_left = 650; weap_tab.offset_top = 90; weap_tab.offset_right = 850; weap_tab.offset_bottom = 120
	weap_tab.add_theme_font_size_override("font_size", 16)
	weap_tab.text = "Weapon Skins"
	if skin_tab == "weapon":
		weap_tab.add_theme_color_override("font_color", Color(0.9, 0.5, 1.0))
	else:
		weap_tab.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		weap_tab.pressed.connect(_switch_skin_tab.bind("weapon"))
	skin_popup.add_child(weap_tab)

	# Skin cards
	var card_w := 170.0
	var card_h := 200.0
	var gap := 16.0

	if skin_tab == "body":
		var order: Array = GameState.BODY_SKIN_ORDER
		var count := order.size()
		var top_count := 3
		var top_total := card_w * top_count + gap * (top_count - 1)
		var top_x := (1280.0 - top_total) / 2.0
		var top_y := 140.0
		for i in range(mini(top_count, count)):
			_add_body_skin_card(str(order[i]), top_x + i * (card_w + gap), top_y, card_w, card_h)
		if count > top_count:
			var bot_count := count - top_count
			var bot_total := card_w * bot_count + gap * (bot_count - 1)
			var bot_x := (1280.0 - bot_total) / 2.0
			var bot_y := top_y + card_h + gap
			for i in range(bot_count):
				_add_body_skin_card(str(order[top_count + i]), bot_x + i * (card_w + gap), bot_y, card_w, card_h)
	elif skin_tab == "character":
		var order: Array = GameState.CHAR_SKIN_ORDER
		var count := order.size()
		var top_count := 3
		var top_total := card_w * top_count + gap * (top_count - 1)
		var top_x := (1280.0 - top_total) / 2.0
		var top_y := 140.0
		for i in range(top_count):
			_add_skin_card(str(order[i]), top_x + i * (card_w + gap), top_y, card_w, card_h, true)
		var bot_count := count - top_count
		var bot_total := card_w * bot_count + gap * (bot_count - 1)
		var bot_x := (1280.0 - bot_total) / 2.0
		var bot_y := top_y + card_h + gap
		for i in range(bot_count):
			_add_skin_card(str(order[top_count + i]), bot_x + i * (card_w + gap), bot_y, card_w, card_h, true)
	else:
		var order: Array = GameState.WEAPON_SKIN_ORDER
		var count := order.size()
		var top_count := 3
		var top_total := card_w * top_count + gap * (top_count - 1)
		var top_x := (1280.0 - top_total) / 2.0
		var top_y := 140.0
		for i in range(top_count):
			_add_skin_card(str(order[i]), top_x + i * (card_w + gap), top_y, card_w, card_h, false)
		var bot_count := count - top_count
		var bot_total := card_w * bot_count + gap * (bot_count - 1)
		var bot_x := (1280.0 - bot_total) / 2.0
		var bot_y := top_y + card_h + gap
		for i in range(bot_count):
			_add_skin_card(str(order[top_count + i]), bot_x + i * (card_w + gap), bot_y, card_w, card_h, false)

	# ESC hint
	var esc := Label.new()
	esc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	esc.offset_left = 290; esc.offset_top = 675; esc.offset_right = 990; esc.offset_bottom = 700
	esc.add_theme_font_size_override("font_size", 14)
	esc.add_theme_color_override("font_color", Color(1, 1, 1, 0.25))
	esc.text = "Press ESC to close"
	skin_popup.add_child(esc)


func _add_skin_card(skin_id: String, x: float, y: float, w: float, h: float, is_char: bool) -> void:
	var skin_data: Dictionary = GameState.CHAR_SKINS.get(skin_id, {}) if is_char else GameState.WEAPON_SKINS.get(skin_id, {})
	var skin_name: String = str(skin_data.get("name", skin_id.capitalize()))
	var cost: int = int(skin_data.get("cost", 0))
	var owned := GameState.owns_char_skin(skin_id) if is_char else GameState.owns_weapon_skin(skin_id)
	var equipped := (GameState.fighter_char_skin == skin_id) if is_char else (GameState.fighter_weapon_skin == skin_id)
	var can_buy := not owned and GameState.fighter_gems >= cost

	var card := Button.new()
	card.offset_left = x; card.offset_top = y; card.offset_right = x + w; card.offset_bottom = y + h
	if owned and not equipped:
		card.pressed.connect(_equip_skin.bind(skin_id, is_char))
	elif not owned and can_buy:
		card.pressed.connect(_buy_skin.bind(skin_id, is_char))
	skin_popup.add_child(card)

	# Color preview area
	var preview := ColorRect.new()
	preview.offset_left = 5; preview.offset_top = 5; preview.offset_right = w - 5; preview.offset_bottom = 100
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_char:
		var scarf_col: Color = skin_data.get("scarf", Color(0.5, 0.5, 0.5))
		var coat_col: Color = skin_data.get("coat", Color(0.1, 0.1, 0.1))
		preview.color = Color(coat_col.r, coat_col.g, coat_col.b, 0.9)
		# Add accent stripe
		var stripe := ColorRect.new()
		stripe.offset_left = 0; stripe.offset_top = 0; stripe.offset_right = w - 10; stripe.offset_bottom = 8
		stripe.color = scarf_col
		stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.add_child(stripe)
		# Character silhouette using skin colors
		var sil_canvas := Control.new()
		sil_canvas.offset_left = 0; sil_canvas.offset_top = 0
		sil_canvas.offset_right = w - 10; sil_canvas.offset_bottom = 95
		sil_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.add_child(sil_canvas)
		var alpha := 1.0 if owned else 0.35
		sil_canvas.draw.connect(func(): _draw_char_skin_preview(sil_canvas, skin_data, alpha))
		sil_canvas.queue_redraw()
	else:
		var glow_col: Color = skin_data.get("glow", Color(0.5, 0.5, 0.5))
		var trail_col: Color = skin_data.get("trail", Color(0.5, 0.5, 0.5))
		preview.color = Color(0.08, 0.08, 0.12, 0.9)
		# Weapon effect preview
		var fx_canvas := Control.new()
		fx_canvas.offset_left = 0; fx_canvas.offset_top = 0
		fx_canvas.offset_right = w - 10; fx_canvas.offset_bottom = 95
		fx_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.add_child(fx_canvas)
		var alpha := 1.0 if owned else 0.35
		fx_canvas.draw.connect(func(): _draw_weapon_skin_preview(fx_canvas, glow_col, trail_col, alpha))
		fx_canvas.queue_redraw()
	card.add_child(preview)

	# Skin name
	var name_lbl := Label.new()
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.offset_left = 5; name_lbl.offset_top = 108; name_lbl.offset_right = w - 5; name_lbl.offset_bottom = 132
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_lbl.text = skin_name
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.9) if owned else Color(0.5, 0.5, 0.6, 0.7))
	card.add_child(name_lbl)

	# Status
	var status := Label.new()
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.offset_left = 5; status.offset_top = 135; status.offset_right = w - 5; status.offset_bottom = 160
	status.add_theme_font_size_override("font_size", 13)
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if equipped:
		status.text = "✓ EQUIPPED"
		status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 0.9))
	elif owned:
		status.text = "Click to equip"
		status.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8, 0.6))
	elif can_buy:
		status.text = "BUY · %d Gems" % cost
		status.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0, 0.9))
	elif cost == 0:
		status.text = "FREE"
		status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	else:
		status.text = "%d Gems needed" % cost
		status.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.6))
	card.add_child(status)

	# Equipped/buyable border
	if equipped:
		for pos_y in [0.0, h - 3.0]:
			var bdr := ColorRect.new()
			bdr.offset_left = 0; bdr.offset_top = pos_y; bdr.offset_right = w; bdr.offset_bottom = pos_y + 3
			bdr.color = Color(0.3, 1.0, 0.4, 0.7)
			bdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_child(bdr)
	elif can_buy:
		for pos_y in [0.0, h - 3.0]:
			var bdr := ColorRect.new()
			bdr.offset_left = 0; bdr.offset_top = pos_y; bdr.offset_right = w; bdr.offset_bottom = pos_y + 3
			bdr.color = Color(0.2, 0.75, 1.0, 0.5)
			bdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_child(bdr)


func _draw_char_skin_preview(c: Control, skin_data: Dictionary, a: float) -> void:
	var cx := c.size.x / 2.0
	var cy := c.size.y / 2.0 + 8.0
	var coat_col: Color = skin_data.get("coat", Color(0.12, 0.12, 0.18))
	var scarf_col: Color = skin_data.get("scarf", Color(0.85, 0.15, 0.2))
	var hair_col: Color = skin_data.get("hair", Color(0.12, 0.1, 0.26))
	var iris_col: Color = skin_data.get("iris", Color(0.2, 0.4, 0.9))
	var accent_col: Color = skin_data.get("accent", Color(0.5, 0.3, 0.8))
	var skin_col := Color(0.92, 0.8, 0.68, a)
	# Body (coat)
	c.draw_rect(Rect2(cx - 10, cy - 8, 20, 28), Color(coat_col.r, coat_col.g, coat_col.b, a))
	# Head
	c.draw_rect(Rect2(cx - 9, cy - 26, 18, 20), skin_col)
	# Hair
	c.draw_rect(Rect2(cx - 11, cy - 32, 22, 12), Color(hair_col.r, hair_col.g, hair_col.b, a))
	# Hair spike
	var spike := PackedVector2Array([Vector2(cx - 2, cy - 32), Vector2(cx + 1, cy - 42), Vector2(cx + 4, cy - 32)])
	var hc := Color(hair_col.r, hair_col.g, hair_col.b, a)
	c.draw_polygon(spike, PackedColorArray([hc, hc, hc]))
	# Eyes
	c.draw_rect(Rect2(cx - 6, cy - 20, 4, 4), Color(iris_col.r, iris_col.g, iris_col.b, a))
	c.draw_rect(Rect2(cx + 2, cy - 20, 4, 4), Color(iris_col.r, iris_col.g, iris_col.b, a))
	# Scarf
	c.draw_rect(Rect2(cx - 8, cy - 10, 16, 5), Color(scarf_col.r, scarf_col.g, scarf_col.b, a))
	# Legs
	c.draw_rect(Rect2(cx - 6, cy + 20, 5, 12), Color(coat_col.r, coat_col.g, coat_col.b, a * 0.8))
	c.draw_rect(Rect2(cx + 1, cy + 20, 5, 12), Color(coat_col.r, coat_col.g, coat_col.b, a * 0.8))
	# Accent emblem
	c.draw_rect(Rect2(cx - 3, cy + 2, 6, 6), Color(accent_col.r, accent_col.g, accent_col.b, a * 0.6))


func _draw_weapon_skin_preview(c: Control, glow_col: Color, trail_col: Color, a: float) -> void:
	var cx := c.size.x / 2.0
	var cy := c.size.y / 2.0
	# Sword silhouette
	c.draw_rect(Rect2(cx - 2, cy - 30, 4, 40), Color(0.5, 0.5, 0.55, a * 0.6))
	c.draw_rect(Rect2(cx - 10, cy + 8, 20, 4), Color(0.4, 0.4, 0.45, a * 0.5))
	# Glow
	c.draw_circle(Vector2(cx, cy - 10), 18, Color(glow_col.r, glow_col.g, glow_col.b, a * 0.3))
	c.draw_circle(Vector2(cx, cy - 10), 10, Color(glow_col.r, glow_col.g, glow_col.b, a * 0.5))
	# Slash arc trail
	var arc := PackedVector2Array([
		Vector2(cx + 8, cy - 25), Vector2(cx + 25, cy - 15),
		Vector2(cx + 30, cy), Vector2(cx + 25, cy + 15),
		Vector2(cx + 15, cy + 10), Vector2(cx + 20, cy),
		Vector2(cx + 18, cy - 10), Vector2(cx + 12, cy - 18)
	])
	c.draw_polygon(arc, PackedColorArray([
		Color(trail_col.r, trail_col.g, trail_col.b, a * 0.6),
		Color(trail_col.r, trail_col.g, trail_col.b, a * 0.5),
		Color(trail_col.r, trail_col.g, trail_col.b, a * 0.4),
		Color(trail_col.r, trail_col.g, trail_col.b, a * 0.3),
		Color(trail_col.r, trail_col.g, trail_col.b, a * 0.2),
		Color(trail_col.r, trail_col.g, trail_col.b, a * 0.3),
		Color(trail_col.r, trail_col.g, trail_col.b, a * 0.4),
		Color(trail_col.r, trail_col.g, trail_col.b, a * 0.5),
	]))


func _add_body_skin_card(skin_id: String, x: float, y: float, w: float, h: float) -> void:
	var skin_data: Dictionary = GameState.BODY_SKINS.get(skin_id, {})
	var skin_name: String = str(skin_data.get("name", skin_id.capitalize()))
	var cost: int = int(skin_data.get("cost", 0))
	var owned := GameState.owns_body_skin(skin_id)
	var equipped := (GameState.fighter_body_skin == skin_id)
	var can_buy := not owned and GameState.fighter_gems >= cost

	var card := Button.new()
	card.offset_left = x; card.offset_top = y; card.offset_right = x + w; card.offset_bottom = y + h
	if owned and not equipped:
		card.pressed.connect(_equip_body_skin.bind(skin_id))
	elif not owned and can_buy:
		card.pressed.connect(_buy_body_skin.bind(skin_id))
	skin_popup.add_child(card)

	# Preview area with body skin silhouette
	var preview := ColorRect.new()
	preview.offset_left = 5; preview.offset_top = 5; preview.offset_right = w - 5; preview.offset_bottom = 100
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.color = Color(0.1, 0.1, 0.14, 0.9)
	card.add_child(preview)

	var sil_canvas := Control.new()
	sil_canvas.offset_left = 0; sil_canvas.offset_top = 0
	sil_canvas.offset_right = w - 10; sil_canvas.offset_bottom = 95
	sil_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.add_child(sil_canvas)
	var alpha := 1.0 if owned else 0.35
	sil_canvas.draw.connect(func(): _draw_body_skin_preview(sil_canvas, skin_id, alpha))
	sil_canvas.queue_redraw()

	# Skin name
	var name_lbl := Label.new()
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.offset_left = 5; name_lbl.offset_top = 108; name_lbl.offset_right = w - 5; name_lbl.offset_bottom = 132
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_lbl.text = skin_name
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.9) if owned else Color(0.5, 0.5, 0.6, 0.7))
	card.add_child(name_lbl)

	# Status
	var status := Label.new()
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.offset_left = 5; status.offset_top = 135; status.offset_right = w - 5; status.offset_bottom = 160
	status.add_theme_font_size_override("font_size", 13)
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if equipped:
		status.text = "✓ EQUIPPED"
		status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 0.9))
	elif owned:
		status.text = "Click to equip"
		status.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8, 0.6))
	elif can_buy:
		status.text = "BUY · %d Gems" % cost
		status.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0, 0.9))
	elif cost == 0:
		status.text = "FREE"
		status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	else:
		status.text = "%d Gems needed" % cost
		status.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.6))
	card.add_child(status)

	# Equipped/buyable border
	if equipped:
		for pos_y in [0.0, h - 3.0]:
			var bdr := ColorRect.new()
			bdr.offset_left = 0; bdr.offset_top = pos_y; bdr.offset_right = w; bdr.offset_bottom = pos_y + 3
			bdr.color = Color(0.3, 1.0, 0.4, 0.7)
			bdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_child(bdr)
	elif can_buy:
		for pos_y in [0.0, h - 3.0]:
			var bdr := ColorRect.new()
			bdr.offset_left = 0; bdr.offset_top = pos_y; bdr.offset_right = w; bdr.offset_bottom = pos_y + 3
			bdr.color = Color(1.0, 0.75, 0.2, 0.5)
			bdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_child(bdr)


func _draw_body_skin_preview(c: Control, skin_id: String, a: float) -> void:
	var cx := c.size.x / 2.0
	var cy := c.size.y / 2.0 + 8.0
	match skin_id:
		"default":
			_draw_default_body_preview(c, cx, cy, a)
		"panda":
			_draw_panda_body_preview(c, cx, cy, a)
		"darth_bader":
			_draw_darth_bader_body_preview(c, cx, cy, a)
		"ninja":
			_draw_ninja_body_preview(c, cx, cy, a)
		"robot":
			_draw_robot_body_preview(c, cx, cy, a)
		"manito":
			_draw_manito_body_preview(c, cx, cy, a)


func _draw_manito_body_preview(c: Control, cx: float, cy: float, a: float) -> void:
	var coat_col := Color(0.95, 0.85, 0.2, a)  # Yellow Hokage coat
	var inner_col := Color(0.1, 0.12, 0.2, a)  # Dark inner
	var skin_col := Color(0.92, 0.8, 0.68, a)
	var hair_col := Color(0.95, 0.85, 0.15, a)  # Blonde spiky hair
	var iris_col := Color(0.2, 0.5, 0.95, a)    # Blue eyes
	var band_col := Color(0.15, 0.15, 0.3, a)   # Headband
	# Body (Hokage coat)
	c.draw_rect(Rect2(cx - 12, cy - 8, 24, 28), coat_col)
	c.draw_rect(Rect2(cx - 8, cy - 6, 16, 24), inner_col)
	# Head
	c.draw_rect(Rect2(cx - 9, cy - 26, 18, 20), skin_col)
	# Spiky blonde hair (3 spikes)
	c.draw_rect(Rect2(cx - 11, cy - 32, 22, 10), hair_col)
	var spike1 := PackedVector2Array([Vector2(cx - 8, cy - 32), Vector2(cx - 5, cy - 44), Vector2(cx - 2, cy - 32)])
	var spike2 := PackedVector2Array([Vector2(cx - 2, cy - 32), Vector2(cx + 1, cy - 46), Vector2(cx + 4, cy - 32)])
	var spike3 := PackedVector2Array([Vector2(cx + 4, cy - 32), Vector2(cx + 7, cy - 42), Vector2(cx + 10, cy - 32)])
	var spike_cols := PackedColorArray([hair_col, hair_col, hair_col])
	c.draw_polygon(spike1, spike_cols)
	c.draw_polygon(spike2, spike_cols)
	c.draw_polygon(spike3, spike_cols)
	# Headband
	c.draw_rect(Rect2(cx - 10, cy - 22, 20, 4), band_col)
	# Metal plate on headband
	c.draw_rect(Rect2(cx - 4, cy - 23, 8, 5), Color(0.6, 0.65, 0.7, a))
	# Blue eyes
	c.draw_rect(Rect2(cx - 6, cy - 18, 4, 4), iris_col)
	c.draw_rect(Rect2(cx + 2, cy - 18, 4, 4), iris_col)
	# Whisker marks (3 lines on each cheek)
	var whisker_col := Color(0.5, 0.4, 0.3, a * 0.5)
	for i in range(3):
		c.draw_line(Vector2(cx - 9, cy - 14 + i * 3), Vector2(cx - 5, cy - 14 + i * 3), whisker_col, 1.0)
		c.draw_line(Vector2(cx + 5, cy - 14 + i * 3), Vector2(cx + 9, cy - 14 + i * 3), whisker_col, 1.0)
	# Legs
	c.draw_rect(Rect2(cx - 6, cy + 20, 5, 12), Color(0.12, 0.12, 0.2, a * 0.8))
	c.draw_rect(Rect2(cx + 1, cy + 20, 5, 12), Color(0.12, 0.12, 0.2, a * 0.8))


func _draw_default_body_preview(c: Control, cx: float, cy: float, a: float) -> void:
	var coat_col := Color(0.12, 0.12, 0.18, a)
	var skin_col := Color(0.92, 0.8, 0.68, a)
	var scarf_col := Color(0.85, 0.15, 0.2, a)
	var hair_col := Color(0.12, 0.1, 0.26, a)
	var iris_col := Color(0.2, 0.4, 0.9, a)
	# Body
	c.draw_rect(Rect2(cx - 10, cy - 8, 20, 28), coat_col)
	# Head
	c.draw_rect(Rect2(cx - 9, cy - 26, 18, 20), skin_col)
	# Hair
	c.draw_rect(Rect2(cx - 11, cy - 32, 22, 12), hair_col)
	var spike := PackedVector2Array([Vector2(cx - 2, cy - 32), Vector2(cx + 1, cy - 42), Vector2(cx + 4, cy - 32)])
	c.draw_polygon(spike, PackedColorArray([hair_col, hair_col, hair_col]))
	# Eyes
	c.draw_rect(Rect2(cx - 6, cy - 20, 4, 4), iris_col)
	c.draw_rect(Rect2(cx + 2, cy - 20, 4, 4), iris_col)
	# Scarf
	c.draw_rect(Rect2(cx - 8, cy - 10, 16, 5), scarf_col)
	# Legs
	c.draw_rect(Rect2(cx - 6, cy + 20, 5, 12), Color(coat_col.r, coat_col.g, coat_col.b, a * 0.8))
	c.draw_rect(Rect2(cx + 1, cy + 20, 5, 12), Color(coat_col.r, coat_col.g, coat_col.b, a * 0.8))


func _draw_panda_body_preview(c: Control, cx: float, cy: float, a: float) -> void:
	var white := Color(0.95, 0.95, 0.97, a)
	var black := Color(0.08, 0.08, 0.1, a)
	var green := Color(0.2, 0.6, 0.15, a)
	# Round white body
	c.draw_circle(Vector2(cx, cy + 6), 16, white)
	# Round white head
	c.draw_circle(Vector2(cx, cy - 16), 14, white)
	# Black round ears (left and right)
	c.draw_circle(Vector2(cx - 11, cy - 28), 7, black)
	c.draw_circle(Vector2(cx + 11, cy - 28), 7, black)
	# Inner ear pink
	c.draw_circle(Vector2(cx - 11, cy - 28), 4, Color(0.85, 0.7, 0.7, a * 0.5))
	c.draw_circle(Vector2(cx + 11, cy - 28), 4, Color(0.85, 0.7, 0.7, a * 0.5))
	# Black eye patches (oval)
	c.draw_circle(Vector2(cx - 5, cy - 18), 5, black)
	c.draw_circle(Vector2(cx + 5, cy - 18), 5, black)
	# White pupils inside
	c.draw_circle(Vector2(cx - 5, cy - 18), 2, Color(1.0, 1.0, 1.0, a))
	c.draw_circle(Vector2(cx + 5, cy - 18), 2, Color(1.0, 1.0, 1.0, a))
	# Tiny black pupils
	c.draw_circle(Vector2(cx - 4, cy - 18), 1, black)
	c.draw_circle(Vector2(cx + 6, cy - 18), 1, black)
	# Little nose
	c.draw_circle(Vector2(cx, cy - 12), 2, black)
	# Cute mouth line
	c.draw_line(Vector2(cx - 3, cy - 10), Vector2(cx, cy - 8), black, 1.5)
	c.draw_line(Vector2(cx, cy - 8), Vector2(cx + 3, cy - 10), black, 1.5)
	# Black arms
	c.draw_rect(Rect2(cx - 18, cy - 2, 8, 16), black)
	c.draw_rect(Rect2(cx + 10, cy - 2, 8, 16), black)
	# Black legs
	c.draw_rect(Rect2(cx - 8, cy + 18, 7, 10), black)
	c.draw_rect(Rect2(cx + 1, cy + 18, 7, 10), black)
	# White belly patch (circle)
	c.draw_circle(Vector2(cx, cy + 4), 8, Color(1.0, 1.0, 1.0, a * 0.5))
	# Green bamboo leaf scarf
	c.draw_rect(Rect2(cx - 7, cy - 6, 14, 4), green)


func _draw_darth_bader_body_preview(c: Control, cx: float, cy: float, a: float) -> void:
	var black := Color(0.06, 0.06, 0.08, a)
	var dark := Color(0.04, 0.04, 0.06, a)
	var red := Color(0.95, 0.1, 0.05, a)
	var dark_red := Color(0.35, 0.05, 0.05, a)
	var grey := Color(0.15, 0.15, 0.18, a)
	# Dark cape (flows behind body)
	var cape := PackedVector2Array([
		Vector2(cx - 14, cy - 8), Vector2(cx - 16, cy + 30),
		Vector2(cx - 8, cy + 35), Vector2(cx + 8, cy + 35),
		Vector2(cx + 16, cy + 30), Vector2(cx + 14, cy - 8)])
	c.draw_polygon(cape, PackedColorArray([dark_red, dark_red, dark_red, dark_red, dark_red, dark_red]))
	# Body — black armor torso
	c.draw_rect(Rect2(cx - 11, cy - 8, 22, 28), black)
	# Chest panel with red lights
	c.draw_rect(Rect2(cx - 6, cy, 12, 8), grey)
	c.draw_circle(Vector2(cx - 2, cy + 4), 2, red)
	c.draw_circle(Vector2(cx + 3, cy + 4), 2, Color(0.2, 0.8, 0.2, a))
	# Angular helmet
	var helmet := PackedVector2Array([
		Vector2(cx, cy - 38), Vector2(cx - 12, cy - 28), Vector2(cx - 14, cy - 16),
		Vector2(cx - 12, cy - 10), Vector2(cx + 12, cy - 10),
		Vector2(cx + 14, cy - 16), Vector2(cx + 12, cy - 28)])
	c.draw_polygon(helmet, PackedColorArray([black, black, black, black, black, black, black]))
	# Helmet ridge
	c.draw_line(Vector2(cx - 12, cy - 22), Vector2(cx + 12, cy - 22), Color(0.12, 0.12, 0.15, a), 2.0)
	# Visor — red glowing triangular eyes
	var left_eye := PackedVector2Array([Vector2(cx - 9, cy - 20), Vector2(cx - 4, cy - 22), Vector2(cx - 4, cy - 19)])
	c.draw_polygon(left_eye, PackedColorArray([red, red, red]))
	var right_eye := PackedVector2Array([Vector2(cx + 9, cy - 20), Vector2(cx + 4, cy - 22), Vector2(cx + 4, cy - 19)])
	c.draw_polygon(right_eye, PackedColorArray([red, red, red]))
	# Breathing apparatus (triangular grille below visor)
	c.draw_rect(Rect2(cx - 4, cy - 15, 8, 5), Color(0.1, 0.1, 0.12, a))
	c.draw_line(Vector2(cx - 2, cy - 15), Vector2(cx - 2, cy - 10), Color(0.15, 0.15, 0.18, a), 1.0)
	c.draw_line(Vector2(cx, cy - 15), Vector2(cx, cy - 10), Color(0.15, 0.15, 0.18, a), 1.0)
	c.draw_line(Vector2(cx + 2, cy - 15), Vector2(cx + 2, cy - 10), Color(0.15, 0.15, 0.18, a), 1.0)
	# Dark legs
	c.draw_rect(Rect2(cx - 6, cy + 20, 5, 12), dark)
	c.draw_rect(Rect2(cx + 1, cy + 20, 5, 12), dark)
	# Red shoulder accents
	c.draw_rect(Rect2(cx - 14, cy - 6, 4, 8), Color(0.7, 0.1, 0.08, a * 0.7))
	c.draw_rect(Rect2(cx + 10, cy - 6, 4, 8), Color(0.7, 0.1, 0.08, a * 0.7))


func _draw_ninja_body_preview(c: Control, cx: float, cy: float, a: float) -> void:
	var dark := Color(0.08, 0.08, 0.18, a)
	var cloth := Color(0.1, 0.1, 0.22, a)
	var cyan := Color(0.1, 0.85, 0.9, a)
	# Body — dark ninja suit
	c.draw_rect(Rect2(cx - 10, cy - 8, 20, 28), dark)
	# Head — wrapped cloth, only eyes visible
	c.draw_circle(Vector2(cx, cy - 20), 12, cloth)
	# Headband/wrap flowing tail
	var tail := PackedVector2Array([Vector2(cx + 8, cy - 24), Vector2(cx + 22, cy - 28), Vector2(cx + 18, cy - 22)])
	c.draw_polygon(tail, PackedColorArray([dark, dark, dark]))
	# Glowing cyan eyes (narrow slits)
	c.draw_line(Vector2(cx - 7, cy - 20), Vector2(cx - 2, cy - 21), cyan, 2.5)
	c.draw_line(Vector2(cx + 2, cy - 21), Vector2(cx + 7, cy - 20), cyan, 2.5)
	# Eye glow
	c.draw_circle(Vector2(cx - 5, cy - 20), 3, Color(0.1, 0.85, 0.9, a * 0.2))
	c.draw_circle(Vector2(cx + 5, cy - 20), 3, Color(0.1, 0.85, 0.9, a * 0.2))
	# Sash/belt
	c.draw_rect(Rect2(cx - 9, cy + 10, 18, 4), Color(0.12, 0.12, 0.25, a))
	# Shuriken emblem on chest
	var star := PackedVector2Array([
		Vector2(cx, cy - 4), Vector2(cx + 2, cy), Vector2(cx + 5, cy + 1),
		Vector2(cx + 2, cy + 2), Vector2(cx, cy + 6), Vector2(cx - 2, cy + 2),
		Vector2(cx - 5, cy + 1), Vector2(cx - 2, cy)])
	c.draw_polygon(star, PackedColorArray([
		Color(0.5, 0.5, 0.6, a), Color(0.5, 0.5, 0.6, a), Color(0.5, 0.5, 0.6, a),
		Color(0.5, 0.5, 0.6, a), Color(0.5, 0.5, 0.6, a), Color(0.5, 0.5, 0.6, a),
		Color(0.5, 0.5, 0.6, a), Color(0.5, 0.5, 0.6, a)]))
	# Dark legs
	c.draw_rect(Rect2(cx - 6, cy + 20, 5, 12), Color(0.06, 0.06, 0.14, a))
	c.draw_rect(Rect2(cx + 1, cy + 20, 5, 12), Color(0.06, 0.06, 0.14, a))
	# Dark arms
	c.draw_rect(Rect2(cx - 15, cy - 4, 6, 14), dark)
	c.draw_rect(Rect2(cx + 9, cy - 4, 6, 14), dark)


func _draw_robot_body_preview(c: Control, cx: float, cy: float, a: float) -> void:
	var metal := Color(0.3, 0.32, 0.35, a)
	var dark_metal := Color(0.22, 0.24, 0.28, a)
	var cyan := Color(0.1, 0.9, 1.0, a)
	var glow := Color(0.1, 0.85, 1.0, a * 0.3)
	# Boxy metal torso
	c.draw_rect(Rect2(cx - 12, cy - 8, 24, 28), metal)
	# Chest plate ridge
	c.draw_line(Vector2(cx - 10, cy - 6), Vector2(cx + 10, cy - 6), dark_metal, 2.0)
	c.draw_line(Vector2(cx - 10, cy + 8), Vector2(cx + 10, cy + 8), dark_metal, 2.0)
	# Circuit emblem (glowing square)
	c.draw_rect(Rect2(cx - 4, cy - 2, 8, 8), Color(0.1, 0.7, 0.9, a * 0.7))
	c.draw_circle(Vector2(cx, cy + 2), 3, glow)
	# Angular head (boxy)
	c.draw_rect(Rect2(cx - 11, cy - 32, 22, 22), dark_metal)
	# Visor screen
	c.draw_rect(Rect2(cx - 8, cy - 26, 16, 10), Color(0.12, 0.14, 0.18, a))
	# Screen eyes (bright cyan)
	c.draw_circle(Vector2(cx - 4, cy - 21), 3, cyan)
	c.draw_circle(Vector2(cx + 4, cy - 21), 3, cyan)
	# Eye glow halos
	c.draw_circle(Vector2(cx - 4, cy - 21), 5, glow)
	c.draw_circle(Vector2(cx + 4, cy - 21), 5, glow)
	# Antenna spike
	c.draw_rect(Rect2(cx - 1, cy - 40, 2, 10), Color(0.4, 0.42, 0.45, a))
	c.draw_circle(Vector2(cx, cy - 40), 3, Color(1.0, 0.3, 0.1, a * 0.8))
	# Metal arms (rectangular)
	c.draw_rect(Rect2(cx - 17, cy - 4, 6, 18), dark_metal)
	c.draw_rect(Rect2(cx + 11, cy - 4, 6, 18), dark_metal)
	# Joint circles
	c.draw_circle(Vector2(cx - 14, cy - 4), 3, Color(0.4, 0.42, 0.45, a))
	c.draw_circle(Vector2(cx + 14, cy - 4), 3, Color(0.4, 0.42, 0.45, a))
	# Metal legs
	c.draw_rect(Rect2(cx - 7, cy + 20, 6, 12), dark_metal)
	c.draw_rect(Rect2(cx + 1, cy + 20, 6, 12), dark_metal)
	# Cable scarf (blue)
	c.draw_rect(Rect2(cx - 8, cy - 10, 16, 3), Color(0.1, 0.5, 0.7, a * 0.6))


func _buy_body_skin(skin_id: String) -> void:
	if GameState.buy_body_skin(skin_id):
		GameState.equip_body_skin(skin_id)
	_build_skin_contents()
	_update_currency_display()
	_spawn_preview()


func _equip_body_skin(skin_id: String) -> void:
	GameState.equip_body_skin(skin_id)
	_build_skin_contents()
	_spawn_preview()


func _switch_skin_tab(tab: String) -> void:
	skin_tab = tab
	_build_skin_contents()


func _buy_skin(skin_id: String, is_char: bool) -> void:
	if is_char:
		if GameState.buy_char_skin(skin_id):
			GameState.equip_char_skin(skin_id)
	else:
		if GameState.buy_weapon_skin(skin_id):
			GameState.equip_weapon_skin(skin_id)
	_build_skin_contents()
	_update_currency_display()
	_spawn_preview()


func _equip_skin(skin_id: String, is_char: bool) -> void:
	if is_char:
		GameState.equip_char_skin(skin_id)
	else:
		GameState.equip_weapon_skin(skin_id)
	_build_skin_contents()
	_spawn_preview()


func _close_skin_popup() -> void:
	skin_popup_open = false
	skin_popup.visible = false


# ─── UPGRADE POPUP ────────────────────────────────────

func _create_upgrade_button() -> void:
	upgrade_btn = Button.new()
	upgrade_btn.text = "UPGRADE"
	upgrade_btn.offset_left = 775
	upgrade_btn.offset_top = 613
	upgrade_btn.offset_right = 890
	upgrade_btn.offset_bottom = 645
	upgrade_btn.add_theme_font_size_override("font_size", 16)
	upgrade_btn.add_theme_color_override("font_color", Color(1.0, 0.6, 0.1))
	upgrade_btn.pressed.connect(_open_upgrade_popup)
	$HUD.add_child(upgrade_btn)


func _create_upgrade_popup() -> void:
	upgrade_popup = ColorRect.new()
	upgrade_popup.color = Color(0, 0, 0, 0.92)
	upgrade_popup.offset_left = 0; upgrade_popup.offset_top = 0
	upgrade_popup.offset_right = 1280; upgrade_popup.offset_bottom = 720
	upgrade_popup.visible = false
	upgrade_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	$HUD.add_child(upgrade_popup)


func _open_upgrade_popup() -> void:
	if _any_popup_open():
		return
	upgrade_popup_open = true
	_build_upgrade_contents()
	upgrade_popup.visible = true


func _close_upgrade_popup() -> void:
	upgrade_popup_open = false
	upgrade_popup.visible = false


func _build_upgrade_contents() -> void:
	for child in upgrade_popup.get_children():
		child.queue_free()

	# Title
	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = 190; title.offset_top = 25; title.offset_right = 1090; title.offset_bottom = 70
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(1.0, 0.6, 0.1))
	title.text = "WEAPON UPGRADES"
	upgrade_popup.add_child(title)

	# Currency display
	var cur := Label.new()
	cur.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cur.offset_left = 190; cur.offset_top = 72; cur.offset_right = 1090; cur.offset_bottom = 95
	cur.add_theme_font_size_override("font_size", 15)
	cur.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 0.6))
	cur.text = "Power Ups: %d    Coins: %d" % [GameState.fighter_power_ups, GameState.fighter_coins]
	upgrade_popup.add_child(cur)

	# Weapon cards — 5 in a row
	var card_w := 210.0
	var card_h := 380.0
	var card_gap := 14.0
	var total_w := card_w * 5 + card_gap * 4
	var sx := (1280.0 - total_w) / 2.0
	var sy := 110.0

	var weapons := ["fists", "shadow_blade", "frost_staff", "dragon_gauntlets", "thors_hammer"]
	for idx in range(weapons.size()):
		var wid: String = weapons[idx]
		var cx := sx + idx * (card_w + card_gap)
		_add_upgrade_card(wid, cx, sy, card_w, card_h)

	# ESC hint
	var esc := Label.new()
	esc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	esc.offset_left = 290; esc.offset_top = 675; esc.offset_right = 990; esc.offset_bottom = 700
	esc.add_theme_font_size_override("font_size", 14)
	esc.add_theme_color_override("font_color", Color(1, 1, 1, 0.25))
	esc.text = "Press ESC to close"
	upgrade_popup.add_child(esc)


func _add_upgrade_card(wid: String, x: float, y: float, w: float, h: float) -> void:
	var level: int = GameState.get_weapon_level(wid)
	var unlocked: bool = GameState.is_weapon_unlocked(wid)
	var wcol: Color = WEAPON_COLORS.get(wid, Color.WHITE)
	var wname: String = WEAPON_NAMES.get(wid, wid)

	# Card background
	var card := ColorRect.new()
	card.offset_left = x; card.offset_top = y; card.offset_right = x + w; card.offset_bottom = y + h
	card.color = Color(0.1, 0.1, 0.14, 0.9)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	upgrade_popup.add_child(card)

	# Weapon color bar at top
	var bar := ColorRect.new()
	bar.offset_left = x; bar.offset_top = y; bar.offset_right = x + w; bar.offset_bottom = y + 4
	bar.color = wcol if unlocked else Color(0.3, 0.3, 0.3)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	upgrade_popup.add_child(bar)

	# Weapon name
	var name_lbl := Label.new()
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.offset_left = x; name_lbl.offset_top = y + 12; name_lbl.offset_right = x + w; name_lbl.offset_bottom = y + 38
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", wcol if unlocked else Color(0.4, 0.4, 0.4))
	name_lbl.text = wname
	upgrade_popup.add_child(name_lbl)

	if not unlocked:
		var lock_lbl := Label.new()
		lock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_lbl.offset_left = x; lock_lbl.offset_top = y + 160; lock_lbl.offset_right = x + w; lock_lbl.offset_bottom = y + 200
		lock_lbl.add_theme_font_size_override("font_size", 18)
		lock_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.6))
		lock_lbl.text = "LOCKED"
		upgrade_popup.add_child(lock_lbl)
		return

	# Level display
	var lv_text := "RAGE" if level == GameState.RAGE_LEVEL else "Lv. %d / %d" % [level, GameState.WEAPON_MAX_LEVEL]
	var lv_lbl := Label.new()
	lv_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv_lbl.offset_left = x; lv_lbl.offset_top = y + 42; lv_lbl.offset_right = x + w; lv_lbl.offset_bottom = y + 62
	lv_lbl.add_theme_font_size_override("font_size", 13)
	if level == GameState.RAGE_LEVEL:
		lv_lbl.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1, 0.9))
	else:
		lv_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 0.7))
	lv_lbl.text = lv_text
	upgrade_popup.add_child(lv_lbl)

	# Level bar (10 segments)
	var seg_w := (w - 30) / 10.0
	var seg_h := 12.0
	var seg_y := y + 68
	var seg_sx := x + 15
	for i in range(10):
		var seg := ColorRect.new()
		seg.offset_left = seg_sx + i * seg_w + 1
		seg.offset_top = seg_y
		seg.offset_right = seg_sx + (i + 1) * seg_w - 1
		seg.offset_bottom = seg_y + seg_h
		seg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if i < level - 1 or (i < level and level <= GameState.WEAPON_MAX_LEVEL):
			if level == GameState.RAGE_LEVEL:
				seg.color = Color(1.0, 0.3, 0.1, 0.9)  # rage red-orange
			else:
				var t := float(i) / 9.0
				seg.color = Color(
					lerpf(wcol.r, 1.0, t * 0.3),
					lerpf(wcol.g, 0.9, t * 0.2),
					lerpf(wcol.b, 0.2, t * 0.5),
					0.8)
		else:
			seg.color = Color(0.2, 0.2, 0.25, 0.5)
		upgrade_popup.add_child(seg)

	# RAGE indicator at end of bar
	if level == GameState.RAGE_LEVEL:
		var rage_lbl := Label.new()
		rage_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rage_lbl.offset_left = x; rage_lbl.offset_top = seg_y + seg_h + 2; rage_lbl.offset_right = x + w; rage_lbl.offset_bottom = seg_y + seg_h + 16
		rage_lbl.add_theme_font_size_override("font_size", 10)
		rage_lbl.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1, 0.8))
		rage_lbl.text = "RAGE UNLOCKED"
		upgrade_popup.add_child(rage_lbl)

	# Stats bonus display
	var dmg_bonus := (level - 1) * GameState.WEAPON_DAMAGE_SCALE * 100.0
	var kb_bonus := (level - 1) * GameState.WEAPON_KB_SCALE * 100.0
	var stats_lbl := Label.new()
	stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_lbl.offset_left = x; stats_lbl.offset_top = y + 95; stats_lbl.offset_right = x + w; stats_lbl.offset_bottom = y + 115
	stats_lbl.add_theme_font_size_override("font_size", 11)
	stats_lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 0.4, 0.7))
	if level > 1:
		stats_lbl.text = "+%.0f%% DMG  +%.0f%% KB" % [dmg_bonus, kb_bonus]
	else:
		stats_lbl.text = "Base stats"
	upgrade_popup.add_child(stats_lbl)

	# Super bonus
	var sdmg_bonus := (level - 1) * GameState.WEAPON_SUPER_DMG_SCALE * 100.0
	if level > 1:
		var super_lbl := Label.new()
		super_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		super_lbl.offset_left = x; super_lbl.offset_top = y + 112; super_lbl.offset_right = x + w; super_lbl.offset_bottom = y + 130
		super_lbl.add_theme_font_size_override("font_size", 10)
		super_lbl.add_theme_color_override("font_color", Color(0.8, 0.6, 0.3, 0.6))
		super_lbl.text = "Super: +%.0f%% DMG" % sdmg_bonus
		upgrade_popup.add_child(super_lbl)

	# Next level preview
	if level < GameState.WEAPON_MAX_LEVEL:
		var next_dmg := level * GameState.WEAPON_DAMAGE_SCALE * 100.0
		var next_lbl := Label.new()
		next_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		next_lbl.offset_left = x; next_lbl.offset_top = y + 140; next_lbl.offset_right = x + w; next_lbl.offset_bottom = y + 158
		next_lbl.add_theme_font_size_override("font_size", 10)
		next_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0, 0.5))
		next_lbl.text = "Next: +%.0f%% DMG" % next_dmg
		upgrade_popup.add_child(next_lbl)

	# Upgrade / Rage button
	var btn_y := y + h - 60
	if level < GameState.WEAPON_MAX_LEVEL:
		# Power-up upgrade button
		var cost: int = GameState.get_upgrade_cost(wid)
		var can_up: bool = GameState.can_upgrade_weapon(wid)
		var up_btn := Button.new()
		up_btn.offset_left = x + 15; up_btn.offset_top = btn_y; up_btn.offset_right = x + w - 15; up_btn.offset_bottom = btn_y + 40
		up_btn.add_theme_font_size_override("font_size", 14)
		if can_up:
			up_btn.text = "UPGRADE  %d P" % cost
			up_btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
			up_btn.pressed.connect(_on_upgrade_weapon.bind(wid))
		else:
			up_btn.text = "NEED %d P" % cost
			up_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.6))
		upgrade_popup.add_child(up_btn)
	elif level == GameState.WEAPON_MAX_LEVEL:
		# Rage purchase button (500 coins)
		var can_rage: bool = GameState.can_buy_rage(wid)
		var rage_btn := Button.new()
		rage_btn.offset_left = x + 10; rage_btn.offset_top = btn_y; rage_btn.offset_right = x + w - 10; rage_btn.offset_bottom = btn_y + 40
		rage_btn.add_theme_font_size_override("font_size", 14)
		if can_rage:
			rage_btn.text = "RAGE  500 C"
			rage_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.15))
			rage_btn.pressed.connect(_on_buy_rage.bind(wid))
		else:
			rage_btn.text = "NEED 500 C"
			rage_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.6))
		upgrade_popup.add_child(rage_btn)
	# level 11 (RAGE) — no button needed, already maxed


# ─── SETTINGS POPUP ──────────────────────────────────

func _create_settings_button() -> void:
	settings_btn = Button.new()
	settings_btn.text = "SETTINGS"
	settings_btn.offset_left = 900
	settings_btn.offset_top = 613
	settings_btn.offset_right = 1030
	settings_btn.offset_bottom = 645
	settings_btn.add_theme_font_size_override("font_size", 16)
	settings_btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	settings_btn.pressed.connect(_open_settings_popup)
	$HUD.add_child(settings_btn)


func _create_settings_popup() -> void:
	settings_popup = ColorRect.new()
	settings_popup.color = Color(0, 0, 0, 0.92)
	settings_popup.offset_left = 0; settings_popup.offset_top = 0
	settings_popup.offset_right = 1280; settings_popup.offset_bottom = 720
	settings_popup.visible = false
	settings_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	$HUD.add_child(settings_popup)


func _open_settings_popup() -> void:
	if _any_popup_open():
		return
	settings_popup_open = true
	_rebinding_action = ""
	_build_settings_contents()
	settings_popup.visible = true


func _close_settings_popup() -> void:
	settings_popup_open = false
	settings_popup.visible = false
	_rebinding_action = ""
	_rebinding_btn = null


func _build_settings_contents() -> void:
	for child in settings_popup.get_children():
		child.queue_free()

	# Title
	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = 190; title.offset_top = 20; title.offset_right = 1090; title.offset_bottom = 60
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.7, 0.7, 0.85))
	title.text = "SETTINGS"
	settings_popup.add_child(title)

	# --- KEY BINDINGS SECTION ---
	var section_lbl := Label.new()
	section_lbl.offset_left = 340; section_lbl.offset_top = 70; section_lbl.offset_right = 940; section_lbl.offset_bottom = 92
	section_lbl.add_theme_font_size_override("font_size", 18)
	section_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
	section_lbl.text = "KEY BINDINGS"
	settings_popup.add_child(section_lbl)

	var row_y := 100.0
	for action in GameState.KEY_BINDING_ORDER:
		var action_name: String = str(GameState.KEY_BINDING_NAMES.get(action, action))
		var keycode: int = GameState.get_key_binding(action)
		var key_name: String = GameState.get_key_name(keycode)

		# Action label
		var act_lbl := Label.new()
		act_lbl.offset_left = 360; act_lbl.offset_top = row_y; act_lbl.offset_right = 560; act_lbl.offset_bottom = row_y + 28
		act_lbl.add_theme_font_size_override("font_size", 15)
		act_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
		act_lbl.text = action_name
		settings_popup.add_child(act_lbl)

		# Key binding button
		var key_btn := Button.new()
		key_btn.offset_left = 580; key_btn.offset_top = row_y; key_btn.offset_right = 780; key_btn.offset_bottom = row_y + 28
		key_btn.add_theme_font_size_override("font_size", 14)
		if _rebinding_action == action:
			key_btn.text = "[ Press a key... ]"
			key_btn.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
		else:
			key_btn.text = key_name
			key_btn.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
		key_btn.pressed.connect(_start_rebind.bind(action, key_btn))
		settings_popup.add_child(key_btn)

		row_y += 34.0

	# Reset keys button
	var reset_btn := Button.new()
	reset_btn.offset_left = 580; reset_btn.offset_top = row_y + 10; reset_btn.offset_right = 780; reset_btn.offset_bottom = row_y + 42
	reset_btn.add_theme_font_size_override("font_size", 14)
	reset_btn.text = "RESET DEFAULTS"
	reset_btn.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))
	reset_btn.pressed.connect(_reset_all_keys)
	settings_popup.add_child(reset_btn)

	# --- TOUCH CONTROLS SECTION ---
	var touch_y := row_y + 60.0
	var touch_lbl := Label.new()
	touch_lbl.offset_left = 340; touch_lbl.offset_top = touch_y; touch_lbl.offset_right = 940; touch_lbl.offset_bottom = touch_y + 22
	touch_lbl.add_theme_font_size_override("font_size", 18)
	touch_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
	touch_lbl.text = "TOUCH CONTROLS"
	settings_popup.add_child(touch_lbl)

	touch_y += 30.0
	# Scale label
	var scale_lbl := Label.new()
	scale_lbl.offset_left = 360; scale_lbl.offset_top = touch_y; scale_lbl.offset_right = 560; scale_lbl.offset_bottom = touch_y + 26
	scale_lbl.add_theme_font_size_override("font_size", 15)
	scale_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	scale_lbl.text = "Button Size: %.0f%%" % (GameState.touch_button_scale * 100.0)
	settings_popup.add_child(scale_lbl)

	# Scale - button
	var scale_down := Button.new()
	scale_down.offset_left = 580; scale_down.offset_top = touch_y; scale_down.offset_right = 640; scale_down.offset_bottom = touch_y + 26
	scale_down.text = "-"
	scale_down.add_theme_font_size_override("font_size", 16)
	scale_down.add_theme_color_override("font_color", Color(0.8, 0.5, 0.3))
	scale_down.pressed.connect(_adjust_touch_scale.bind(-0.1))
	settings_popup.add_child(scale_down)

	# Scale + button
	var scale_up := Button.new()
	scale_up.offset_left = 650; scale_up.offset_top = touch_y; scale_up.offset_right = 710; scale_up.offset_bottom = touch_y + 26
	scale_up.text = "+"
	scale_up.add_theme_font_size_override("font_size", 16)
	scale_up.add_theme_color_override("font_color", Color(0.3, 0.8, 0.5))
	scale_up.pressed.connect(_adjust_touch_scale.bind(0.1))
	settings_popup.add_child(scale_up)

	# Reset touch button
	touch_y += 34.0
	var reset_touch := Button.new()
	reset_touch.offset_left = 580; reset_touch.offset_top = touch_y; reset_touch.offset_right = 780; reset_touch.offset_bottom = touch_y + 28
	reset_touch.add_theme_font_size_override("font_size", 14)
	reset_touch.text = "RESET TOUCH"
	reset_touch.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))
	reset_touch.pressed.connect(_reset_touch)
	settings_popup.add_child(reset_touch)

	# --- VIBRATION SECTION ---
	var vib_y := touch_y + 50.0
	var vib_section := Label.new()
	vib_section.offset_left = 340; vib_section.offset_top = vib_y; vib_section.offset_right = 940; vib_section.offset_bottom = vib_y + 22
	vib_section.add_theme_font_size_override("font_size", 18)
	vib_section.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
	vib_section.text = "VIBRATION"
	settings_popup.add_child(vib_section)

	vib_y += 30.0
	var vib_lbl := Label.new()
	vib_lbl.offset_left = 360; vib_lbl.offset_top = vib_y; vib_lbl.offset_right = 560; vib_lbl.offset_bottom = vib_y + 26
	vib_lbl.add_theme_font_size_override("font_size", 15)
	vib_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	vib_lbl.text = "Vibration: %s" % ("ON" if GameState.vibration_enabled else "OFF")
	settings_popup.add_child(vib_lbl)

	var vib_btn := Button.new()
	vib_btn.offset_left = 580; vib_btn.offset_top = vib_y; vib_btn.offset_right = 780; vib_btn.offset_bottom = vib_y + 26
	vib_btn.add_theme_font_size_override("font_size", 14)
	vib_btn.text = "ON" if GameState.vibration_enabled else "OFF"
	vib_btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4) if GameState.vibration_enabled else Color(1.0, 0.4, 0.3))
	vib_btn.pressed.connect(_toggle_vibration)
	settings_popup.add_child(vib_btn)

	# ESC hint
	var esc := Label.new()
	esc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	esc.offset_left = 290; esc.offset_top = 675; esc.offset_right = 990; esc.offset_bottom = 700
	esc.add_theme_font_size_override("font_size", 14)
	esc.add_theme_color_override("font_color", Color(1, 1, 1, 0.25))
	esc.text = "Press ESC to close"
	settings_popup.add_child(esc)


func _start_rebind(action: String, btn: Button) -> void:
	_rebinding_action = action
	_rebinding_btn = btn
	_build_settings_contents()


func _on_rebind_key(event: InputEvent) -> void:
	if _rebinding_action == "" or not settings_popup_open:
		return
	if event is InputEventKey and event.pressed:
		# Don't allow ESC as a binding (used for closing popups)
		if event.keycode == KEY_ESCAPE:
			_rebinding_action = ""
			_rebinding_btn = null
			_build_settings_contents()
			return
		GameState.set_key_binding(_rebinding_action, event.keycode)
		_rebinding_action = ""
		_rebinding_btn = null
		_build_settings_contents()
		get_viewport().set_input_as_handled()


func _reset_all_keys() -> void:
	GameState.reset_key_bindings()
	_build_settings_contents()


func _adjust_touch_scale(delta: float) -> void:
	GameState.set_touch_scale(GameState.touch_button_scale + delta)
	_build_settings_contents()


func _toggle_vibration() -> void:
	GameState.vibration_enabled = not GameState.vibration_enabled
	GameState.save_fighter_trophies()
	_build_settings_contents()


func _reset_touch() -> void:
	GameState.reset_touch_settings()
	_build_settings_contents()


func _on_upgrade_weapon(wid: String) -> void:
	if GameState.upgrade_weapon(wid):
		_build_upgrade_contents()
		_update_currency_display()


func _on_buy_rage(wid: String) -> void:
	if GameState.buy_rage(wid):
		_build_upgrade_contents()
		_update_currency_display()


# ─── TROPHY ROAD ─────────────────────────────────────

func _create_road_button() -> void:
	road_btn = Button.new()
	var has_unclaimed := GameState.has_unclaimed_road_rewards()
	road_btn.text = "TROPHY ROAD" + (" !" if has_unclaimed else "")
	road_btn.offset_left = 610
	road_btn.offset_top = 25
	road_btn.offset_right = 760
	road_btn.offset_bottom = 55
	road_btn.add_theme_font_size_override("font_size", 16)
	if has_unclaimed:
		road_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	else:
		road_btn.add_theme_color_override("font_color", Color(0.85, 0.7, 0.3))
	road_btn.pressed.connect(_open_road_popup)
	$HUD.add_child(road_btn)


func _create_road_popup() -> void:
	road_popup = ColorRect.new()
	road_popup.color = Color(0, 0, 0, 0.92)
	road_popup.offset_left = 0; road_popup.offset_top = 0
	road_popup.offset_right = 1280; road_popup.offset_bottom = 720
	road_popup.visible = false
	road_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	$HUD.add_child(road_popup)


func _open_road_popup() -> void:
	if _any_popup_open():
		return
	road_popup_open = true
	# Auto-select first unclaimed, or center on progress
	var progress_idx := GameState.get_trophy_road_progress()
	road_selected_index = clampi(progress_idx, 0, GameState.TROPHY_ROAD.size() - 1)
	road_scroll_offset = maxi(road_selected_index - 3, 0)
	_build_road_contents()
	road_popup.visible = true


func _close_road_popup() -> void:
	road_popup_open = false
	road_popup.visible = false
	# Update the button notification indicator
	var has_unclaimed := GameState.has_unclaimed_road_rewards()
	road_btn.text = "TROPHY ROAD" + (" !" if has_unclaimed else "")
	if has_unclaimed:
		road_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	else:
		road_btn.add_theme_color_override("font_color", Color(0.85, 0.7, 0.3))


func _road_scroll(dir: int) -> void:
	road_scroll_offset = clampi(road_scroll_offset + dir, 0, maxi(GameState.TROPHY_ROAD.size() - ROAD_VISIBLE_NODES, 0))
	_build_road_contents()


func _road_select(index: int) -> void:
	road_selected_index = clampi(index, 0, GameState.TROPHY_ROAD.size() - 1)
	_build_road_contents()


func _road_claim(index: int) -> void:
	if GameState.claim_trophy_road(index):
		_build_road_contents()
		_update_currency_display()


func _build_road_contents() -> void:
	for child in road_popup.get_children():
		child.queue_free()

	var total_trophies := GameState.get_total_trophies()
	var road := GameState.TROPHY_ROAD
	var claimed_count := GameState.fighter_trophy_road_claimed.size()

	# Title
	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = 190; title.offset_top = 20; title.offset_right = 1090; title.offset_bottom = 60
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	title.text = "TROPHY ROAD"
	road_popup.add_child(title)

	# Stats line
	var stats := Label.new()
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.offset_left = 190; stats.offset_top = 58; stats.offset_right = 1090; stats.offset_bottom = 80
	stats.add_theme_font_size_override("font_size", 14)
	stats.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 0.6))
	stats.text = "Total Trophies: %d    Claimed: %d / %d" % [total_trophies, claimed_count, road.size()]
	road_popup.add_child(stats)

	# --- Road nodes (horizontal scroll, 8 visible) ---
	var node_w := 120.0
	var node_h := 100.0
	var gap := 12.0
	var vis := ROAD_VISIBLE_NODES
	var total_w := node_w * vis + gap * (vis - 1)
	var sx := (1280.0 - total_w) / 2.0
	var road_y := 100.0

	# Left scroll arrow
	if road_scroll_offset > 0:
		var left_btn := Button.new()
		left_btn.offset_left = sx - 40; left_btn.offset_top = road_y + 35
		left_btn.offset_right = sx - 8; left_btn.offset_bottom = road_y + 70
		left_btn.text = "<"
		left_btn.add_theme_font_size_override("font_size", 20)
		left_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		left_btn.pressed.connect(_road_scroll.bind(-1))
		road_popup.add_child(left_btn)

	# Right scroll arrow
	if road_scroll_offset + vis < road.size():
		var right_btn := Button.new()
		right_btn.offset_left = sx + total_w + 8; right_btn.offset_top = road_y + 35
		right_btn.offset_right = sx + total_w + 40; right_btn.offset_bottom = road_y + 70
		right_btn.text = ">"
		right_btn.add_theme_font_size_override("font_size", 20)
		right_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		right_btn.pressed.connect(_road_scroll.bind(1))
		road_popup.add_child(right_btn)

	# --- Connecting road line ---
	var line_y := road_y + node_h / 2.0
	var line_rect := ColorRect.new()
	line_rect.color = Color(0.3, 0.3, 0.35, 0.6)
	line_rect.offset_left = sx; line_rect.offset_top = line_y - 2
	line_rect.offset_right = sx + total_w; line_rect.offset_bottom = line_y + 2
	road_popup.add_child(line_rect)

	# Progress line (gold, up to current progress)
	var progress_idx := GameState.get_trophy_road_progress()
	if progress_idx >= road_scroll_offset:
		var fill_nodes := mini(progress_idx - road_scroll_offset + 1, vis)
		var fill_w := fill_nodes * node_w + (fill_nodes - 1) * gap
		var gold_line := ColorRect.new()
		gold_line.color = Color(1.0, 0.85, 0.2, 0.5)
		gold_line.offset_left = sx; gold_line.offset_top = line_y - 3
		gold_line.offset_right = sx + fill_w; gold_line.offset_bottom = line_y + 3
		road_popup.add_child(gold_line)

	# --- Draw milestone nodes ---
	for i in range(vis):
		var idx := road_scroll_offset + i
		if idx >= road.size():
			break
		var milestone: Dictionary = road[idx]
		var bx := sx + i * (node_w + gap)
		var is_claimed := idx in GameState.fighter_trophy_road_claimed
		var is_reached := total_trophies >= int(milestone["trophies"])
		var is_selected := idx == road_selected_index

		# Node background
		var node_bg := ColorRect.new()
		if is_selected:
			node_bg.color = Color(0.25, 0.22, 0.15, 0.9)
		elif is_claimed:
			node_bg.color = Color(0.15, 0.18, 0.12, 0.7)
		elif is_reached:
			node_bg.color = Color(0.12, 0.2, 0.12, 0.7)
		else:
			node_bg.color = Color(0.12, 0.12, 0.15, 0.5)
		node_bg.offset_left = bx; node_bg.offset_top = road_y
		node_bg.offset_right = bx + node_w; node_bg.offset_bottom = road_y + node_h
		road_popup.add_child(node_bg)

		# Selection border
		if is_selected:
			for side_data in [
				[bx, road_y, bx + node_w, road_y + 2],
				[bx, road_y + node_h - 2, bx + node_w, road_y + node_h],
				[bx, road_y, bx + 2, road_y + node_h],
				[bx + node_w - 2, road_y, bx + node_w, road_y + node_h],
			]:
				var border := ColorRect.new()
				border.color = Color(1.0, 0.85, 0.2, 0.8)
				border.offset_left = side_data[0]; border.offset_top = side_data[1]
				border.offset_right = side_data[2]; border.offset_bottom = side_data[3]
				road_popup.add_child(border)

		# Trophy threshold number
		var thresh_lbl := Label.new()
		thresh_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		thresh_lbl.offset_left = bx; thresh_lbl.offset_top = road_y + 4
		thresh_lbl.offset_right = bx + node_w; thresh_lbl.offset_bottom = road_y + 22
		thresh_lbl.add_theme_font_size_override("font_size", 13)
		if is_claimed:
			thresh_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.8))
		elif is_reached:
			thresh_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 0.9))
		else:
			thresh_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.6))
		thresh_lbl.text = str(int(milestone["trophies"]))
		road_popup.add_child(thresh_lbl)

		# Status icon
		var status_lbl := Label.new()
		status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_lbl.offset_left = bx; status_lbl.offset_top = road_y + 22
		status_lbl.offset_right = bx + node_w; status_lbl.offset_bottom = road_y + 44
		status_lbl.add_theme_font_size_override("font_size", 16)
		if is_claimed:
			status_lbl.text = "✓"
			status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		elif is_reached:
			status_lbl.text = "!"
			status_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		else:
			status_lbl.text = "🔒"
			status_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		road_popup.add_child(status_lbl)

		# Reward preview (short label)
		var rewards: Array = milestone["rewards"]
		var reward_text := ""
		for r_idx in range(mini(rewards.size(), 2)):
			var r: Dictionary = rewards[r_idx]
			if r_idx > 0:
				reward_text += " + "
			var rtype: String = str(r.get("type", ""))
			match rtype:
				"coins":
					reward_text += str(int(r.get("amount", 0))) + "C"
				"gems":
					reward_text += str(int(r.get("amount", 0))) + "G"
				"power_ups":
					reward_text += str(int(r.get("amount", 0))) + "P"
				"weapon":
					var wid: String = str(r.get("id", ""))
					# Shorten name
					var parts := wid.split("_")
					reward_text += parts[0].capitalize() if parts.size() > 0 else wid
				"char_skin", "weapon_skin", "body_skin":
					var sid: String = str(r.get("id", ""))
					reward_text += sid.capitalize()
		if rewards.size() > 2:
			reward_text += "..."

		var reward_lbl := Label.new()
		reward_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reward_lbl.offset_left = bx; reward_lbl.offset_top = road_y + 46
		reward_lbl.offset_right = bx + node_w; reward_lbl.offset_bottom = road_y + 62
		reward_lbl.add_theme_font_size_override("font_size", 10)
		if is_claimed:
			reward_lbl.add_theme_color_override("font_color", Color(0.6, 0.55, 0.3, 0.6))
		elif is_reached:
			reward_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 0.8))
		else:
			reward_lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.5, 0.5))
		reward_lbl.text = reward_text
		road_popup.add_child(reward_lbl)

		# Reward type label
		var type_label := ""
		for r in rewards:
			var rtype2: String = str(r.get("type", ""))
			var tname: String = str(GameState.TROPHY_ROAD_REWARD_NAMES.get(rtype2, rtype2))
			if type_label != "":
				type_label += "+"
			type_label += tname
		var type_lbl := Label.new()
		type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		type_lbl.offset_left = bx; type_lbl.offset_top = road_y + 62
		type_lbl.offset_right = bx + node_w; type_lbl.offset_bottom = road_y + 78
		type_lbl.add_theme_font_size_override("font_size", 9)
		type_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55, 0.5))
		type_lbl.text = type_label
		road_popup.add_child(type_lbl)

		# Click to select button (invisible overlay)
		var sel_btn := Button.new()
		sel_btn.offset_left = bx; sel_btn.offset_top = road_y
		sel_btn.offset_right = bx + node_w; sel_btn.offset_bottom = road_y + node_h
		sel_btn.add_theme_color_override("font_color", Color(0, 0, 0, 0))
		sel_btn.flat = true
		sel_btn.text = ""
		sel_btn.pressed.connect(_road_select.bind(idx))
		road_popup.add_child(sel_btn)

	# --- Detail panel for selected milestone ---
	var detail_y := road_y + node_h + 30
	if road_selected_index >= 0 and road_selected_index < road.size():
		var sel_milestone: Dictionary = road[road_selected_index]
		var sel_claimed := road_selected_index in GameState.fighter_trophy_road_claimed
		var sel_reached := total_trophies >= int(sel_milestone["trophies"])
		var sel_trophies := int(sel_milestone["trophies"])

		# Detail background
		var detail_bg := ColorRect.new()
		detail_bg.color = Color(0.1, 0.1, 0.12, 0.8)
		detail_bg.offset_left = 290; detail_bg.offset_top = detail_y
		detail_bg.offset_right = 990; detail_bg.offset_bottom = detail_y + 200
		road_popup.add_child(detail_bg)

		# Milestone header
		var header := Label.new()
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.offset_left = 290; header.offset_top = detail_y + 8
		header.offset_right = 990; header.offset_bottom = detail_y + 35
		header.add_theme_font_size_override("font_size", 22)
		header.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		header.text = "Milestone: %d Trophies" % sel_trophies
		road_popup.add_child(header)

		# Reward details
		var sel_rewards: Array = sel_milestone["rewards"]
		var ry := detail_y + 45
		for r in sel_rewards:
			var r_label: String = GameState.get_road_reward_label(r)
			var rtype: String = str(r.get("type", ""))

			var r_lbl := Label.new()
			r_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			r_lbl.offset_left = 290; r_lbl.offset_top = ry
			r_lbl.offset_right = 990; r_lbl.offset_bottom = ry + 24
			r_lbl.add_theme_font_size_override("font_size", 17)

			# Color by reward type
			match rtype:
				"coins":
					r_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
				"gems":
					r_lbl.add_theme_color_override("font_color", Color(0.2, 0.75, 1.0))
				"power_ups":
					r_lbl.add_theme_color_override("font_color", Color(1.0, 0.6, 0.1))
				"weapon":
					r_lbl.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4))
				"char_skin":
					r_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 1.0))
				"weapon_skin":
					r_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.7))
				"body_skin":
					r_lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
				_:
					r_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))

			# Check if already owned (for weapon/skins)
			var owned_note := ""
			match rtype:
				"weapon":
					var wid: String = str(r.get("id", ""))
					if GameState.is_weapon_unlocked(wid) and not sel_claimed:
						owned_note = " (owned - coins instead)"
				"char_skin":
					var sid: String = str(r.get("id", ""))
					if GameState.owns_char_skin(sid) and not sel_claimed:
						owned_note = " (owned - gems instead)"
				"weapon_skin":
					var sid: String = str(r.get("id", ""))
					if GameState.owns_weapon_skin(sid) and not sel_claimed:
						owned_note = " (owned - gems instead)"
				"body_skin":
					var sid: String = str(r.get("id", ""))
					if GameState.owns_body_skin(sid) and not sel_claimed:
						owned_note = " (owned - gems instead)"

			r_lbl.text = r_label + owned_note
			road_popup.add_child(r_lbl)
			ry += 26

		# Status / Claim button
		var btn_y := detail_y + 150
		if sel_claimed:
			var claimed_lbl := Label.new()
			claimed_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			claimed_lbl.offset_left = 490; claimed_lbl.offset_top = btn_y
			claimed_lbl.offset_right = 790; claimed_lbl.offset_bottom = btn_y + 32
			claimed_lbl.add_theme_font_size_override("font_size", 18)
			claimed_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.4, 0.6))
			claimed_lbl.text = "CLAIMED ✓"
			road_popup.add_child(claimed_lbl)
		elif sel_reached:
			var claim_btn := Button.new()
			claim_btn.offset_left = 530; claim_btn.offset_top = btn_y
			claim_btn.offset_right = 750; claim_btn.offset_bottom = btn_y + 36
			claim_btn.text = "CLAIM REWARD"
			claim_btn.add_theme_font_size_override("font_size", 18)
			claim_btn.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
			claim_btn.pressed.connect(_road_claim.bind(road_selected_index))
			road_popup.add_child(claim_btn)
		else:
			var need := sel_trophies - total_trophies
			var need_lbl := Label.new()
			need_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			need_lbl.offset_left = 490; need_lbl.offset_top = btn_y
			need_lbl.offset_right = 790; need_lbl.offset_bottom = btn_y + 32
			need_lbl.add_theme_font_size_override("font_size", 16)
			need_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 0.7))
			need_lbl.text = "Need %d more trophies" % need
			road_popup.add_child(need_lbl)

	# --- Overall progress bar at bottom ---
	var bar_y := 680.0
	var bar_left := 190.0
	var bar_right := 1090.0
	var bar_w := bar_right - bar_left

	# Background bar
	var bg_bar := ColorRect.new()
	bg_bar.color = Color(0.2, 0.2, 0.22, 0.5)
	bg_bar.offset_left = bar_left; bg_bar.offset_top = bar_y
	bg_bar.offset_right = bar_right; bg_bar.offset_bottom = bar_y + 10
	road_popup.add_child(bg_bar)

	# Fill bar
	var max_trophies := int(road[road.size() - 1]["trophies"])
	var fill_ratio := clampf(float(total_trophies) / float(max_trophies), 0.0, 1.0)
	if fill_ratio > 0.0:
		var fill_bar := ColorRect.new()
		fill_bar.color = Color(1.0, 0.85, 0.2, 0.7)
		fill_bar.offset_left = bar_left; fill_bar.offset_top = bar_y
		fill_bar.offset_right = bar_left + bar_w * fill_ratio; fill_bar.offset_bottom = bar_y + 10
		road_popup.add_child(fill_bar)

	# Progress text
	var prog_text := Label.new()
	prog_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prog_text.offset_left = bar_left; prog_text.offset_top = bar_y - 18
	prog_text.offset_right = bar_right; prog_text.offset_bottom = bar_y
	prog_text.add_theme_font_size_override("font_size", 12)
	prog_text.add_theme_color_override("font_color", Color(0.7, 0.65, 0.4, 0.6))
	prog_text.text = "%d / %d trophies to complete the road" % [total_trophies, max_trophies]
	road_popup.add_child(prog_text)


# ─── RANK & STREAK DISPLAY ──────────────────────────

func _create_rank_display() -> void:
	var rank_data := GameState.get_current_rank()
	var rank_name: String = str(rank_data.get("name", "Bronze III"))
	var rank_color: Color = rank_data.get("color", Color(0.72, 0.45, 0.2)) as Color
	var progress := GameState.get_rank_progress()
	var next_rank := GameState.get_next_rank()

	# Rank badge background
	var badge_bg := ColorRect.new()
	badge_bg.color = Color(rank_color.r * 0.2, rank_color.g * 0.2, rank_color.b * 0.2, 0.7)
	badge_bg.offset_left = 40; badge_bg.offset_top = 84
	badge_bg.offset_right = 260; badge_bg.offset_bottom = 130
	badge_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HUD.add_child(badge_bg)

	# Rank border accent
	var badge_border := ColorRect.new()
	badge_border.color = Color(rank_color.r, rank_color.g, rank_color.b, 0.5)
	badge_border.offset_left = 40; badge_border.offset_top = 84
	badge_border.offset_right = 260; badge_border.offset_bottom = 86
	badge_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HUD.add_child(badge_border)

	rank_label = Label.new()
	rank_label.text = rank_name
	rank_label.offset_left = 50; rank_label.offset_top = 88
	rank_label.offset_right = 250; rank_label.offset_bottom = 112
	rank_label.add_theme_font_size_override("font_size", 18)
	rank_label.add_theme_color_override("font_color", rank_color)
	$HUD.add_child(rank_label)

	# Progress bar to next rank
	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.15, 0.12, 0.2, 0.6)
	bar_bg.offset_left = 50; bar_bg.offset_top = 114
	bar_bg.offset_right = 250; bar_bg.offset_bottom = 122
	bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HUD.add_child(bar_bg)

	if progress < 1.0:
		var fill_w: int = maxi(int(progress * 200.0), 2)
		var bar_fill := ColorRect.new()
		bar_fill.color = Color(rank_color.r, rank_color.g, rank_color.b, 0.7)
		bar_fill.offset_left = 50; bar_fill.offset_top = 114
		bar_fill.offset_right = 50 + fill_w; bar_fill.offset_bottom = 122
		bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$HUD.add_child(bar_fill)

	if not next_rank.is_empty():
		var next_lbl := Label.new()
		next_lbl.text = "Next: " + str(next_rank.get("name", ""))
		next_lbl.offset_left = 50; next_lbl.offset_top = 123
		next_lbl.offset_right = 250; next_lbl.offset_bottom = 138
		next_lbl.add_theme_font_size_override("font_size", 10)
		next_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6, 0.6))
		$HUD.add_child(next_lbl)


func _create_streak_display() -> void:
	streak_label = Label.new()
	var streak := GameState.fighter_win_streak
	var best := GameState.fighter_best_win_streak
	if streak > 0:
		streak_label.text = "Win Streak: %d  (Best: %d)" % [streak, best]
		streak_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
	elif best > 0:
		streak_label.text = "Best Streak: %d" % best
		streak_label.add_theme_color_override("font_color", Color(0.6, 0.55, 0.45))
	else:
		streak_label.text = ""
	streak_label.offset_left = 270; streak_label.offset_top = 92
	streak_label.offset_right = 550; streak_label.offset_bottom = 112
	streak_label.add_theme_font_size_override("font_size", 13)
	$HUD.add_child(streak_label)


# ─── DAILY CHALLENGES ────────────────────────────────

func _create_challenges_button() -> void:
	challenges_btn = Button.new()
	challenges_btn.text = "DAILY CHALLENGES"
	challenges_btn.offset_left = 1070
	challenges_btn.offset_top = 25
	challenges_btn.offset_right = 1240
	challenges_btn.offset_bottom = 55
	challenges_btn.add_theme_font_size_override("font_size", 14)
	challenges_btn.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2))
	challenges_btn.pressed.connect(_open_challenges_popup)
	$HUD.add_child(challenges_btn)


func _update_challenges_button() -> void:
	var unclaimed := GameState.get_unclaimed_challenge_count()
	if unclaimed > 0:
		challenges_btn.text = "CHALLENGES (%d)" % unclaimed
		challenges_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	else:
		challenges_btn.text = "DAILY CHALLENGES"
		challenges_btn.add_theme_color_override("font_color", Color(0.7, 0.55, 0.2))


func _create_challenges_popup() -> void:
	challenges_popup = ColorRect.new()
	challenges_popup.color = Color(0, 0, 0, 0.94)
	challenges_popup.offset_left = 0; challenges_popup.offset_top = 0
	challenges_popup.offset_right = 1280; challenges_popup.offset_bottom = 720
	challenges_popup.visible = false
	challenges_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	$HUD.add_child(challenges_popup)


func _open_challenges_popup() -> void:
	if _any_popup_open():
		return
	challenges_popup_open = true
	GameState.check_daily_challenges()
	_build_challenges_contents()
	challenges_popup.visible = true


func _close_challenges_popup() -> void:
	challenges_popup_open = false
	challenges_popup.visible = false
	_update_challenges_button()
	_update_currency_display()


func _build_challenges_contents() -> void:
	for c in challenges_popup.get_children():
		c.queue_free()

	var frame_l := 200; var frame_t := 60; var frame_r := 1080; var frame_b := 660
	var accent := Color(1.0, 0.7, 0.2)

	# Border frame
	for border_data in [
		[frame_l, frame_t, frame_r, frame_t + 3],
		[frame_l, frame_b - 3, frame_r, frame_b],
		[frame_l, frame_t, frame_l + 3, frame_b],
		[frame_r - 3, frame_t, frame_r, frame_b],
	]:
		var bdr := ColorRect.new()
		bdr.color = Color(accent.r, accent.g, accent.b, 0.4)
		bdr.offset_left = border_data[0]; bdr.offset_top = border_data[1]
		bdr.offset_right = border_data[2]; bdr.offset_bottom = border_data[3]
		bdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		challenges_popup.add_child(bdr)
	var inner_bg := ColorRect.new()
	inner_bg.color = Color(0.05, 0.04, 0.08, 0.92)
	inner_bg.offset_left = frame_l + 3; inner_bg.offset_top = frame_t + 3
	inner_bg.offset_right = frame_r - 3; inner_bg.offset_bottom = frame_b - 3
	inner_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	challenges_popup.add_child(inner_bg)

	# Title bar
	var title_bar := ColorRect.new()
	title_bar.color = Color(0.1, 0.08, 0.05, 0.95)
	title_bar.offset_left = frame_l + 3; title_bar.offset_top = frame_t + 3
	title_bar.offset_right = frame_r - 3; title_bar.offset_bottom = frame_t + 52
	title_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	challenges_popup.add_child(title_bar)
	var glow_line := ColorRect.new()
	glow_line.color = Color(accent.r, accent.g, accent.b, 0.5)
	glow_line.offset_left = frame_l + 3; glow_line.offset_top = frame_t + 50
	glow_line.offset_right = frame_r - 3; glow_line.offset_bottom = frame_t + 52
	glow_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	challenges_popup.add_child(glow_line)

	var title := Label.new()
	title.text = "DAILY CHALLENGES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = frame_l; title.offset_top = frame_t + 14
	title.offset_right = frame_r; title.offset_bottom = frame_t + 48
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", accent)
	challenges_popup.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.offset_left = frame_r - 50; close_btn.offset_top = frame_t + 10
	close_btn.offset_right = frame_r - 12; close_btn.offset_bottom = frame_t + 48
	close_btn.add_theme_font_size_override("font_size", 22)
	close_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	close_btn.pressed.connect(_close_challenges_popup)
	challenges_popup.add_child(close_btn)

	# Rank + Streak info bar
	var info_y := frame_t + 62
	var info_bg := ColorRect.new()
	info_bg.color = Color(0.06, 0.05, 0.1, 0.7)
	info_bg.offset_left = frame_l + 15; info_bg.offset_top = info_y
	info_bg.offset_right = frame_r - 15; info_bg.offset_bottom = info_y + 45
	info_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	challenges_popup.add_child(info_bg)

	var rank_data := GameState.get_current_rank()
	var rank_col: Color = rank_data.get("color", Color.WHITE) as Color
	var rank_info := Label.new()
	rank_info.text = "Rank: " + str(rank_data.get("name", "???"))
	rank_info.offset_left = frame_l + 30; rank_info.offset_top = info_y + 10
	rank_info.offset_right = frame_l + 300; rank_info.offset_bottom = info_y + 35
	rank_info.add_theme_font_size_override("font_size", 18)
	rank_info.add_theme_color_override("font_color", rank_col)
	challenges_popup.add_child(rank_info)

	var streak_info := Label.new()
	var streak_text := ""
	if GameState.fighter_win_streak > 0:
		streak_text = "Win Streak: %d (x%.1f bonus)" % [GameState.fighter_win_streak, GameState.get_streak_multiplier()]
	else:
		streak_text = "No active streak"
	streak_info.text = streak_text
	streak_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	streak_info.offset_left = frame_l + 300; streak_info.offset_top = info_y + 10
	streak_info.offset_right = frame_r - 200; streak_info.offset_bottom = info_y + 35
	streak_info.add_theme_font_size_override("font_size", 15)
	streak_info.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2) if GameState.fighter_win_streak > 0 else Color(0.5, 0.5, 0.55))
	challenges_popup.add_child(streak_info)

	var best_info := Label.new()
	best_info.text = "Best: %d" % GameState.fighter_best_win_streak
	best_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	best_info.offset_left = frame_r - 200; best_info.offset_top = info_y + 12
	best_info.offset_right = frame_r - 30; best_info.offset_bottom = info_y + 32
	best_info.add_theme_font_size_override("font_size", 13)
	best_info.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
	challenges_popup.add_child(best_info)

	# Challenge cards
	var card_y := info_y + 60
	var challenges := GameState.daily_challenges

	if challenges.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No challenges available. Check back tomorrow!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.offset_left = frame_l; empty_lbl.offset_top = card_y + 50
		empty_lbl.offset_right = frame_r; empty_lbl.offset_bottom = card_y + 80
		empty_lbl.add_theme_font_size_override("font_size", 16)
		empty_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
		challenges_popup.add_child(empty_lbl)
	else:
		for i in range(challenges.size()):
			var ch: Dictionary = challenges[i]
			var cy: int = card_y + i * 130
			var is_complete: bool = ch.get("completed", false)
			var is_claimed: bool = i in GameState.daily_challenges_claimed
			var progress: int = mini(int(ch.get("progress", 0)), int(ch.get("target", 1)))
			var target: int = int(ch.get("target", 1))

			# Card background
			var card_bg := ColorRect.new()
			if is_claimed:
				card_bg.color = Color(0.05, 0.08, 0.05, 0.6)
			elif is_complete:
				card_bg.color = Color(0.08, 0.12, 0.05, 0.8)
			else:
				card_bg.color = Color(0.06, 0.05, 0.1, 0.8)
			card_bg.offset_left = frame_l + 20; card_bg.offset_top = cy
			card_bg.offset_right = frame_r - 20; card_bg.offset_bottom = cy + 118
			card_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
			challenges_popup.add_child(card_bg)

			# Left accent bar
			var accent_bar := ColorRect.new()
			if is_claimed:
				accent_bar.color = Color(0.3, 0.6, 0.3, 0.5)
			elif is_complete:
				accent_bar.color = Color(0.3, 1.0, 0.3, 0.8)
			else:
				accent_bar.color = Color(accent.r, accent.g, accent.b, 0.5)
			accent_bar.offset_left = frame_l + 20; accent_bar.offset_top = cy
			accent_bar.offset_right = frame_l + 24; accent_bar.offset_bottom = cy + 118
			accent_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
			challenges_popup.add_child(accent_bar)

			# Challenge description
			var desc_lbl := Label.new()
			desc_lbl.text = str(ch.get("desc", "???"))
			desc_lbl.offset_left = frame_l + 40; desc_lbl.offset_top = cy + 12
			desc_lbl.offset_right = frame_r - 200; desc_lbl.offset_bottom = cy + 40
			desc_lbl.add_theme_font_size_override("font_size", 20)
			if is_claimed:
				desc_lbl.add_theme_color_override("font_color", Color(0.5, 0.6, 0.5))
			elif is_complete:
				desc_lbl.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
			else:
				desc_lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 0.75))
			challenges_popup.add_child(desc_lbl)

			# Progress bar
			var pbar_bg := ColorRect.new()
			pbar_bg.color = Color(0.12, 0.1, 0.18, 0.7)
			pbar_bg.offset_left = frame_l + 40; pbar_bg.offset_top = cy + 50
			pbar_bg.offset_right = frame_r - 200; pbar_bg.offset_bottom = cy + 68
			pbar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
			challenges_popup.add_child(pbar_bg)

			var pbar_fill_w := 0.0
			if target > 0:
				pbar_fill_w = clampf(float(progress) / float(target), 0.0, 1.0)
			var fill_max: int = int(frame_r - 200) - int(frame_l + 40)
			var pbar_fill := ColorRect.new()
			if is_claimed:
				pbar_fill.color = Color(0.3, 0.6, 0.3, 0.5)
			elif is_complete:
				pbar_fill.color = Color(0.3, 1.0, 0.3, 0.8)
			else:
				pbar_fill.color = Color(accent.r, accent.g, accent.b, 0.7)
			pbar_fill.offset_left = frame_l + 40; pbar_fill.offset_top = cy + 50
			pbar_fill.offset_right = frame_l + 40 + maxi(int(pbar_fill_w * float(fill_max)), 2); pbar_fill.offset_bottom = cy + 68
			pbar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
			challenges_popup.add_child(pbar_fill)

			# Progress text
			var prog_lbl := Label.new()
			prog_lbl.text = "%d / %d" % [progress, target]
			prog_lbl.offset_left = frame_l + 40; prog_lbl.offset_top = cy + 72
			prog_lbl.offset_right = frame_l + 200; prog_lbl.offset_bottom = cy + 92
			prog_lbl.add_theme_font_size_override("font_size", 13)
			prog_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
			challenges_popup.add_child(prog_lbl)

			# Reward display
			var rtype: String = str(ch.get("reward_type", "coins"))
			var ramount: int = int(ch.get("reward_amount", 0))
			var reward_names := {"coins": "Coins", "gems": "Gems", "power_ups": "Power Ups"}
			var reward_colors := {"coins": Color(1.0, 0.85, 0.2), "gems": Color(0.4, 0.85, 1.0), "power_ups": Color(0.5, 1.0, 0.5)}
			var r_name: String = str(reward_names.get(rtype, rtype))
			var r_col: Color = reward_colors.get(rtype, Color.WHITE) as Color

			var reward_lbl := Label.new()
			reward_lbl.text = "+" + str(ramount) + " " + r_name
			reward_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			reward_lbl.offset_left = frame_r - 200; reward_lbl.offset_top = cy + 15
			reward_lbl.offset_right = frame_r - 35; reward_lbl.offset_bottom = cy + 40
			reward_lbl.add_theme_font_size_override("font_size", 18)
			reward_lbl.add_theme_color_override("font_color", r_col if not is_claimed else Color(r_col.r, r_col.g, r_col.b, 0.4))
			challenges_popup.add_child(reward_lbl)

			# Claim button or status
			if is_claimed:
				var claimed_lbl := Label.new()
				claimed_lbl.text = "CLAIMED"
				claimed_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				claimed_lbl.offset_left = frame_r - 200; claimed_lbl.offset_top = cy + 75
				claimed_lbl.offset_right = frame_r - 35; claimed_lbl.offset_bottom = cy + 100
				claimed_lbl.add_theme_font_size_override("font_size", 16)
				claimed_lbl.add_theme_color_override("font_color", Color(0.4, 0.6, 0.4))
				challenges_popup.add_child(claimed_lbl)
			elif is_complete:
				var claim_btn := Button.new()
				claim_btn.text = "CLAIM"
				claim_btn.offset_left = frame_r - 160; claim_btn.offset_top = cy + 65
				claim_btn.offset_right = frame_r - 35; claim_btn.offset_bottom = cy + 105
				claim_btn.add_theme_font_size_override("font_size", 18)
				claim_btn.add_theme_color_override("font_color", Color(1, 1, 1))
				_make_styled_button(claim_btn, Color(0.15, 0.4, 0.15, 0.9), Color(0.3, 0.9, 0.3, 0.7))
				claim_btn.pressed.connect(_claim_challenge.bind(i))
				challenges_popup.add_child(claim_btn)
			else:
				var status_lbl := Label.new()
				status_lbl.text = "IN PROGRESS"
				status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				status_lbl.offset_left = frame_r - 200; status_lbl.offset_top = cy + 75
				status_lbl.offset_right = frame_r - 35; status_lbl.offset_bottom = cy + 100
				status_lbl.add_theme_font_size_override("font_size", 14)
				status_lbl.add_theme_color_override("font_color", Color(0.6, 0.55, 0.4))
				challenges_popup.add_child(status_lbl)

	# Resets info
	var reset_lbl := Label.new()
	reset_lbl.text = "Challenges reset daily at midnight"
	reset_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reset_lbl.offset_left = frame_l; reset_lbl.offset_top = frame_b - 35
	reset_lbl.offset_right = frame_r; reset_lbl.offset_bottom = frame_b - 15
	reset_lbl.add_theme_font_size_override("font_size", 12)
	reset_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
	challenges_popup.add_child(reset_lbl)


func _claim_challenge(index: int) -> void:
	GameState.claim_daily_challenge(index)
	_build_challenges_contents()


# ─── PROFILE ─────────────────────────────────────────


func _create_profile_button() -> void:
	profile_btn = Button.new()
	profile_btn.text = "PROFILE"
	profile_btn.offset_left = 940
	profile_btn.offset_top = 25
	profile_btn.offset_right = 1060
	profile_btn.offset_bottom = 55
	profile_btn.add_theme_font_size_override("font_size", 16)
	profile_btn.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	profile_btn.pressed.connect(_open_profile_popup)
	$HUD.add_child(profile_btn)


func _create_profile_popup() -> void:
	profile_popup = ColorRect.new()
	profile_popup.color = Color(0, 0, 0, 0.94)
	profile_popup.offset_left = 0; profile_popup.offset_top = 0
	profile_popup.offset_right = 1280; profile_popup.offset_bottom = 720
	profile_popup.visible = false
	profile_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	$HUD.add_child(profile_popup)


func _open_profile_popup() -> void:
	if _any_popup_open():
		return
	profile_popup_open = true
	# Find current indices
	profile_skin_index = GameState.BODY_SKIN_ORDER.find(GameState.profile_fav_skin)
	if profile_skin_index == -1:
		profile_skin_index = 0
	profile_weapon_index = POPUP_ORDER.find(GameState.profile_fav_weapon)
	if profile_weapon_index == -1:
		profile_weapon_index = 0
	_build_profile_contents()
	profile_popup.visible = true


func _close_profile_popup() -> void:
	profile_popup_open = false
	profile_popup.visible = false
	if profile_preview:
		profile_preview.queue_free()
		profile_preview = null


func _spawn_profile_preview() -> void:
	if profile_preview:
		profile_preview.queue_free()
		profile_preview = null
	var skin_id: String = GameState.BODY_SKIN_ORDER[profile_skin_index]
	var weapon_id: String = POPUP_ORDER[profile_weapon_index]
	# Temporarily set skin+weapon so the Fighter _ready() picks them up
	var orig_skin: String = GameState.fighter_body_skin
	var orig_weapon: String = GameState.fighter_weapon_id
	GameState.fighter_body_skin = skin_id
	GameState.fighter_weapon_id = weapon_id
	profile_preview = FIGHTER_SCENE.instantiate()
	profile_preview.weapon_id = weapon_id
	add_child(profile_preview)
	profile_preview.set_physics_process(false)
	profile_preview.set_process(false)
	profile_preview.get_node("CollisionShape2D").set_deferred("disabled", true)
	profile_preview.global_position = Vector2(640, 350)
	profile_preview.scale = Vector2(4.0, 4.0)
	# Restore actual skin+weapon
	GameState.fighter_body_skin = orig_skin
	GameState.fighter_weapon_id = orig_weapon


func _build_profile_contents() -> void:
	for c in profile_popup.get_children():
		c.queue_free()

	var frame_l := 120; var frame_t := 20; var frame_r := 1160; var frame_b := 700
	var accent := Color(0.4, 0.8, 0.4)

	# Border frame
	for border_data in [
		[frame_l, frame_t, frame_r, frame_t + 3],
		[frame_l, frame_b - 3, frame_r, frame_b],
		[frame_l, frame_t, frame_l + 3, frame_b],
		[frame_r - 3, frame_t, frame_r, frame_b],
	]:
		var bdr := ColorRect.new()
		bdr.color = Color(accent.r, accent.g, accent.b, 0.4)
		bdr.offset_left = border_data[0]; bdr.offset_top = border_data[1]
		bdr.offset_right = border_data[2]; bdr.offset_bottom = border_data[3]
		bdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		profile_popup.add_child(bdr)
	var inner_bg := ColorRect.new()
	inner_bg.color = Color(0.04, 0.06, 0.1, 0.92)
	inner_bg.offset_left = frame_l + 3; inner_bg.offset_top = frame_t + 3
	inner_bg.offset_right = frame_r - 3; inner_bg.offset_bottom = frame_b - 3
	inner_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_popup.add_child(inner_bg)

	# Title bar
	var title_bar := ColorRect.new()
	title_bar.color = Color(0.06, 0.12, 0.1, 0.95)
	title_bar.offset_left = frame_l + 3; title_bar.offset_top = frame_t + 3
	title_bar.offset_right = frame_r - 3; title_bar.offset_bottom = frame_t + 52
	title_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_popup.add_child(title_bar)
	var glow_line := ColorRect.new()
	glow_line.color = Color(accent.r, accent.g, accent.b, 0.5)
	glow_line.offset_left = frame_l + 3; glow_line.offset_top = frame_t + 50
	glow_line.offset_right = frame_r - 3; glow_line.offset_bottom = frame_t + 52
	glow_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_popup.add_child(glow_line)

	var title := Label.new()
	title.text = "MY PROFILE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = frame_l; title.offset_top = frame_t + 14
	title.offset_right = frame_r; title.offset_bottom = frame_t + 48
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(0.5, 0.95, 0.5))
	profile_popup.add_child(title)

	# Close button
	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.offset_left = frame_r - 50; close_btn.offset_top = frame_t + 10
	close_btn.offset_right = frame_r - 12; close_btn.offset_bottom = frame_t + 48
	close_btn.add_theme_font_size_override("font_size", 22)
	close_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	close_btn.pressed.connect(_close_profile_popup)
	profile_popup.add_child(close_btn)

	var content_y := frame_t + 65

	# === NAME SECTION ===
	var name_bg := ColorRect.new()
	name_bg.color = Color(0.06, 0.1, 0.08, 0.7)
	name_bg.offset_left = frame_l + 15; name_bg.offset_top = content_y
	name_bg.offset_right = frame_r - 15; name_bg.offset_bottom = content_y + 50
	name_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_popup.add_child(name_bg)

	var name_lbl := Label.new()
	name_lbl.text = "Display Name:"
	name_lbl.offset_left = frame_l + 30; name_lbl.offset_top = content_y + 13
	name_lbl.offset_right = frame_l + 190; name_lbl.offset_bottom = content_y + 38
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	profile_popup.add_child(name_lbl)

	var name_input := LineEdit.new()
	name_input.text = GameState.profile_name
	name_input.offset_left = frame_l + 200; name_input.offset_top = content_y + 8
	name_input.offset_right = frame_l + 520; name_input.offset_bottom = content_y + 42
	name_input.max_length = 16
	name_input.add_theme_font_size_override("font_size", 18)
	name_input.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	var input_style := StyleBoxFlat.new()
	input_style.bg_color = Color(0.08, 0.12, 0.1, 0.9)
	input_style.border_color = Color(0.4, 0.7, 0.4, 0.5)
	input_style.set_border_width_all(2)
	input_style.set_corner_radius_all(4)
	name_input.add_theme_stylebox_override("normal", input_style)
	name_input.text_submitted.connect(_profile_set_name)
	profile_popup.add_child(name_input)

	var name_hint := Label.new()
	name_hint.text = "(Press Enter to save)"
	name_hint.offset_left = frame_l + 530; name_hint.offset_top = content_y + 16
	name_hint.offset_right = frame_l + 720; name_hint.offset_bottom = content_y + 36
	name_hint.add_theme_font_size_override("font_size", 12)
	name_hint.add_theme_color_override("font_color", Color(0.45, 0.55, 0.45))
	profile_popup.add_child(name_hint)

	# Total trophies display
	var total := GameState.get_total_trophies()
	var trophy_lbl := Label.new()
	trophy_lbl.text = "Total Trophies: " + str(total)
	trophy_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	trophy_lbl.offset_left = frame_r - 300; trophy_lbl.offset_top = content_y + 13
	trophy_lbl.offset_right = frame_r - 30; trophy_lbl.offset_bottom = content_y + 38
	trophy_lbl.add_theme_font_size_override("font_size", 18)
	trophy_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	profile_popup.add_child(trophy_lbl)

	content_y += 60

	# === CHARACTER PREVIEW AREA ===
	var preview_bg := ColorRect.new()
	preview_bg.color = Color(0.03, 0.05, 0.08, 0.8)
	preview_bg.offset_left = 400; preview_bg.offset_top = content_y
	preview_bg.offset_right = 880; preview_bg.offset_bottom = content_y + 340
	preview_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_popup.add_child(preview_bg)
	# Glow around preview
	var preview_glow := ColorRect.new()
	preview_glow.color = Color(0.3, 0.6, 0.3, 0.08)
	preview_glow.offset_left = 380; preview_glow.offset_top = content_y - 5
	preview_glow.offset_right = 900; preview_glow.offset_bottom = content_y + 345
	preview_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_popup.add_child(preview_glow)
	profile_popup.move_child(preview_glow, profile_popup.get_child_count() - 2)

	# Spawn the fighter preview
	_spawn_profile_preview()

	# === FAVORITE CHARACTER SELECTOR (left side) ===
	var sel_x := frame_l + 20
	var sel_y := content_y + 10

	var skin_title := Label.new()
	skin_title.text = "FAVORITE CHARACTER"
	skin_title.offset_left = sel_x; skin_title.offset_top = sel_y
	skin_title.offset_right = sel_x + 280; skin_title.offset_bottom = sel_y + 22
	skin_title.add_theme_font_size_override("font_size", 14)
	skin_title.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	profile_popup.add_child(skin_title)

	var cur_skin_id: String = GameState.BODY_SKIN_ORDER[profile_skin_index]
	var cur_skin_name: String = str(GameState.BODY_SKINS.get(cur_skin_id, {}).get("name", cur_skin_id.capitalize())) if GameState.BODY_SKINS.has(cur_skin_id) else cur_skin_id.capitalize()

	var skin_name_lbl := Label.new()
	skin_name_lbl.text = cur_skin_name
	skin_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skin_name_lbl.offset_left = sel_x; skin_name_lbl.offset_top = sel_y + 35
	skin_name_lbl.offset_right = sel_x + 260; skin_name_lbl.offset_bottom = sel_y + 65
	skin_name_lbl.add_theme_font_size_override("font_size", 22)
	skin_name_lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 1.0))
	profile_popup.add_child(skin_name_lbl)

	var prev_skin_btn := Button.new()
	prev_skin_btn.text = "< PREV"
	prev_skin_btn.offset_left = sel_x; prev_skin_btn.offset_top = sel_y + 75
	prev_skin_btn.offset_right = sel_x + 120; prev_skin_btn.offset_bottom = sel_y + 110
	prev_skin_btn.add_theme_font_size_override("font_size", 14)
	prev_skin_btn.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
	_make_styled_button(prev_skin_btn, Color(0.08, 0.12, 0.08, 0.8), Color(0.3, 0.6, 0.3, 0.5))
	prev_skin_btn.pressed.connect(_profile_prev_skin)
	profile_popup.add_child(prev_skin_btn)

	var next_skin_btn := Button.new()
	next_skin_btn.text = "NEXT >"
	next_skin_btn.offset_left = sel_x + 140; next_skin_btn.offset_top = sel_y + 75
	next_skin_btn.offset_right = sel_x + 260; next_skin_btn.offset_bottom = sel_y + 110
	next_skin_btn.add_theme_font_size_override("font_size", 14)
	next_skin_btn.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
	_make_styled_button(next_skin_btn, Color(0.08, 0.12, 0.08, 0.8), Color(0.3, 0.6, 0.3, 0.5))
	next_skin_btn.pressed.connect(_profile_next_skin)
	profile_popup.add_child(next_skin_btn)

	# Skin count indicator
	var skin_count_lbl := Label.new()
	skin_count_lbl.text = str(profile_skin_index + 1) + " / " + str(GameState.BODY_SKIN_ORDER.size())
	skin_count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skin_count_lbl.offset_left = sel_x; skin_count_lbl.offset_top = sel_y + 120
	skin_count_lbl.offset_right = sel_x + 260; skin_count_lbl.offset_bottom = sel_y + 140
	skin_count_lbl.add_theme_font_size_override("font_size", 12)
	skin_count_lbl.add_theme_color_override("font_color", Color(0.45, 0.55, 0.45))
	profile_popup.add_child(skin_count_lbl)

	# === FAVORITE WEAPON SELECTOR (right side) ===
	var wsel_x := frame_r - 300
	var wsel_y := content_y + 10

	var weapon_title := Label.new()
	weapon_title.text = "FAVORITE WEAPON"
	weapon_title.offset_left = wsel_x; weapon_title.offset_top = wsel_y
	weapon_title.offset_right = wsel_x + 280; weapon_title.offset_bottom = wsel_y + 22
	weapon_title.add_theme_font_size_override("font_size", 14)
	weapon_title.add_theme_color_override("font_color", Color(0.5, 0.7, 0.9))
	profile_popup.add_child(weapon_title)

	var cur_weapon_id: String = POPUP_ORDER[profile_weapon_index]
	var cur_weapon_name: String = str(WEAPON_NAMES.get(cur_weapon_id, cur_weapon_id))
	var cur_weapon_col: Color = WEAPON_COLORS.get(cur_weapon_id, Color.WHITE) as Color

	var weapon_name_lbl := Label.new()
	weapon_name_lbl.text = cur_weapon_name
	weapon_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_name_lbl.offset_left = wsel_x; weapon_name_lbl.offset_top = wsel_y + 35
	weapon_name_lbl.offset_right = wsel_x + 260; weapon_name_lbl.offset_bottom = wsel_y + 65
	weapon_name_lbl.add_theme_font_size_override("font_size", 22)
	weapon_name_lbl.add_theme_color_override("font_color", cur_weapon_col)
	profile_popup.add_child(weapon_name_lbl)

	# Weapon trophies for this weapon
	var wt := GameState.get_weapon_trophies(cur_weapon_id)
	var wt_lbl := Label.new()
	wt_lbl.text = str(wt) + " trophies"
	wt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wt_lbl.offset_left = wsel_x; wt_lbl.offset_top = wsel_y + 65
	wt_lbl.offset_right = wsel_x + 260; wt_lbl.offset_bottom = wsel_y + 82
	wt_lbl.add_theme_font_size_override("font_size", 12)
	wt_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.7))
	profile_popup.add_child(wt_lbl)

	var prev_weapon_btn := Button.new()
	prev_weapon_btn.text = "< PREV"
	prev_weapon_btn.offset_left = wsel_x; prev_weapon_btn.offset_top = wsel_y + 90
	prev_weapon_btn.offset_right = wsel_x + 120; prev_weapon_btn.offset_bottom = wsel_y + 125
	prev_weapon_btn.add_theme_font_size_override("font_size", 14)
	prev_weapon_btn.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
	_make_styled_button(prev_weapon_btn, Color(0.06, 0.08, 0.15, 0.8), Color(0.3, 0.4, 0.7, 0.5))
	prev_weapon_btn.pressed.connect(_profile_prev_weapon)
	profile_popup.add_child(prev_weapon_btn)

	var next_weapon_btn := Button.new()
	next_weapon_btn.text = "NEXT >"
	next_weapon_btn.offset_left = wsel_x + 140; next_weapon_btn.offset_top = wsel_y + 90
	next_weapon_btn.offset_right = wsel_x + 260; next_weapon_btn.offset_bottom = wsel_y + 125
	next_weapon_btn.add_theme_font_size_override("font_size", 14)
	next_weapon_btn.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
	_make_styled_button(next_weapon_btn, Color(0.06, 0.08, 0.15, 0.8), Color(0.3, 0.4, 0.7, 0.5))
	next_weapon_btn.pressed.connect(_profile_next_weapon)
	profile_popup.add_child(next_weapon_btn)

	var weapon_count_lbl := Label.new()
	weapon_count_lbl.text = str(profile_weapon_index + 1) + " / " + str(POPUP_ORDER.size())
	weapon_count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_count_lbl.offset_left = wsel_x; weapon_count_lbl.offset_top = wsel_y + 135
	weapon_count_lbl.offset_right = wsel_x + 260; weapon_count_lbl.offset_bottom = wsel_y + 155
	weapon_count_lbl.add_theme_font_size_override("font_size", 12)
	weapon_count_lbl.add_theme_color_override("font_color", Color(0.45, 0.5, 0.6))
	profile_popup.add_child(weapon_count_lbl)

	# === SAVE BUTTON ===
	var save_btn := Button.new()
	save_btn.text = "SAVE PROFILE"
	save_btn.offset_left = 510; save_btn.offset_top = content_y + 355
	save_btn.offset_right = 770; save_btn.offset_bottom = content_y + 400
	save_btn.add_theme_font_size_override("font_size", 20)
	save_btn.add_theme_color_override("font_color", Color(1, 1, 1))
	_make_styled_button(save_btn, Color(0.1, 0.3, 0.15, 0.9), Color(0.3, 0.8, 0.3, 0.7))
	save_btn.pressed.connect(_profile_save)
	profile_popup.add_child(save_btn)

	# Current selection info at bottom
	var info_lbl := Label.new()
	info_lbl.text = "Your profile is shown on the leaderboard"
	info_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_lbl.offset_left = frame_l; info_lbl.offset_top = frame_b - 30
	info_lbl.offset_right = frame_r; info_lbl.offset_bottom = frame_b - 10
	info_lbl.add_theme_font_size_override("font_size", 12)
	info_lbl.add_theme_color_override("font_color", Color(0.4, 0.5, 0.4))
	profile_popup.add_child(info_lbl)


func _profile_set_name(new_name: String) -> void:
	GameState.profile_name = new_name.strip_edges().substr(0, 16)
	if GameState.profile_name == "":
		GameState.profile_name = "Player"
	OnlineLeaderboard.set_player_name(GameState.profile_name)
	GameState.save_fighter_trophies()
	_build_profile_contents()


func _profile_prev_skin() -> void:
	profile_skin_index -= 1
	if profile_skin_index < 0:
		profile_skin_index = GameState.BODY_SKIN_ORDER.size() - 1
	_build_profile_contents()


func _profile_next_skin() -> void:
	profile_skin_index += 1
	if profile_skin_index >= GameState.BODY_SKIN_ORDER.size():
		profile_skin_index = 0
	_build_profile_contents()


func _profile_prev_weapon() -> void:
	profile_weapon_index -= 1
	if profile_weapon_index < 0:
		profile_weapon_index = POPUP_ORDER.size() - 1
	_build_profile_contents()


func _profile_next_weapon() -> void:
	profile_weapon_index += 1
	if profile_weapon_index >= POPUP_ORDER.size():
		profile_weapon_index = 0
	_build_profile_contents()


func _profile_save() -> void:
	var skin_id: String = GameState.BODY_SKIN_ORDER[profile_skin_index]
	var weapon_id: String = POPUP_ORDER[profile_weapon_index]
	GameState.profile_fav_skin = skin_id
	GameState.profile_fav_weapon = weapon_id
	OnlineLeaderboard.set_player_name(GameState.profile_name)
	GameState.save_fighter_trophies()
	OnlineLeaderboard.submit_score()
	_close_profile_popup()


# ─── LEADERBOARD ─────────────────────────────────────

var lb_tab: String = "rankings"  # "rankings" or "stats"

func _create_lb_button() -> void:
	lb_btn = Button.new()
	lb_btn.text = "LEADERBOARD"
	lb_btn.offset_left = 770
	lb_btn.offset_top = 25
	lb_btn.offset_right = 930
	lb_btn.offset_bottom = 55
	lb_btn.add_theme_font_size_override("font_size", 16)
	lb_btn.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	lb_btn.pressed.connect(_open_lb_popup)
	$HUD.add_child(lb_btn)


func _create_lb_popup() -> void:
	lb_popup = ColorRect.new()
	lb_popup.color = Color(0, 0, 0, 0.94)
	lb_popup.offset_left = 0; lb_popup.offset_top = 0
	lb_popup.offset_right = 1280; lb_popup.offset_bottom = 720
	lb_popup.visible = false
	lb_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	$HUD.add_child(lb_popup)


func _open_lb_popup() -> void:
	if _any_popup_open():
		return
	lb_popup_open = true
	lb_weapon_filter = ""
	lb_scroll_offset = 0
	lb_tab = "rankings"
	# Fetch online leaderboard data
	OnlineLeaderboard.leaderboard_fetched.connect(_on_lb_fetched, CONNECT_ONE_SHOT)
	OnlineLeaderboard.fetch_leaderboard(lb_weapon_filter)
	_build_lb_contents()
	lb_popup.visible = true


func _on_lb_fetched() -> void:
	if lb_popup_open:
		_build_lb_contents()


func _close_lb_popup() -> void:
	lb_popup_open = false
	lb_popup.visible = false


func _lb_add_frame(frame_l: int, frame_t: int, frame_r: int, frame_b: int, accent_color: Color) -> void:
	for border_data in [
		[frame_l, frame_t, frame_r, frame_t + 3],
		[frame_l, frame_b - 3, frame_r, frame_b],
		[frame_l, frame_t, frame_l + 3, frame_b],
		[frame_r - 3, frame_t, frame_r, frame_b],
	]:
		var bdr := ColorRect.new()
		bdr.color = Color(accent_color.r, accent_color.g, accent_color.b, 0.4)
		bdr.offset_left = border_data[0]; bdr.offset_top = border_data[1]
		bdr.offset_right = border_data[2]; bdr.offset_bottom = border_data[3]
		bdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lb_popup.add_child(bdr)
	var inner_bg := ColorRect.new()
	inner_bg.color = Color(0.04, 0.06, 0.12, 0.92)
	inner_bg.offset_left = frame_l + 3; inner_bg.offset_top = frame_t + 3
	inner_bg.offset_right = frame_r - 3; inner_bg.offset_bottom = frame_b - 3
	inner_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb_popup.add_child(inner_bg)


func _build_lb_contents() -> void:
	for c in lb_popup.get_children():
		c.queue_free()

	var frame_l := 40; var frame_t := 10; var frame_r := 1240; var frame_b := 710
	var accent := Color(0.3, 0.7, 1.0)
	_lb_add_frame(frame_l, frame_t, frame_r, frame_b, accent)

	# === TITLE BAR ===
	var title_bar := ColorRect.new()
	title_bar.color = Color(0.06, 0.1, 0.22, 0.95)
	title_bar.offset_left = frame_l + 3; title_bar.offset_top = frame_t + 3
	title_bar.offset_right = frame_r - 3; title_bar.offset_bottom = frame_t + 52
	title_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb_popup.add_child(title_bar)
	# Title glow line
	var glow := ColorRect.new()
	glow.color = Color(accent.r, accent.g, accent.b, 0.5)
	glow.offset_left = frame_l + 3; glow.offset_top = frame_t + 50
	glow.offset_right = frame_r - 3; glow.offset_bottom = frame_t + 52
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb_popup.add_child(glow)

	var title := Label.new()
	title.text = "GLOBAL LEADERBOARD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = frame_l; title.offset_top = frame_t + 14
	title.offset_right = frame_r; title.offset_bottom = frame_t + 48
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	lb_popup.add_child(title)

	# Close button
	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.offset_left = frame_r - 50; close_btn.offset_top = frame_t + 10
	close_btn.offset_right = frame_r - 12; close_btn.offset_bottom = frame_t + 48
	close_btn.add_theme_font_size_override("font_size", 22)
	close_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	close_btn.pressed.connect(_close_lb_popup)
	lb_popup.add_child(close_btn)

	# === TAB BUTTONS ===
	var tab_y := frame_t + 58
	var tab_btn_style_active := StyleBoxFlat.new()
	tab_btn_style_active.bg_color = Color(0.15, 0.25, 0.5, 0.9)
	tab_btn_style_active.border_color = accent
	tab_btn_style_active.border_width_bottom = 2
	tab_btn_style_active.corner_radius_top_left = 4
	tab_btn_style_active.corner_radius_top_right = 4
	var tab_btn_style_inactive := StyleBoxFlat.new()
	tab_btn_style_inactive.bg_color = Color(0.08, 0.1, 0.18, 0.7)
	tab_btn_style_inactive.corner_radius_top_left = 4
	tab_btn_style_inactive.corner_radius_top_right = 4

	var rankings_tab := Button.new()
	rankings_tab.text = "RANKINGS"
	rankings_tab.offset_left = frame_l + 15; rankings_tab.offset_top = tab_y
	rankings_tab.offset_right = frame_l + 185; rankings_tab.offset_bottom = tab_y + 34
	rankings_tab.add_theme_font_size_override("font_size", 15)
	rankings_tab.add_theme_color_override("font_color", Color(1, 1, 1) if lb_tab == "rankings" else Color(0.5, 0.6, 0.7))
	rankings_tab.add_theme_stylebox_override("normal", tab_btn_style_active if lb_tab == "rankings" else tab_btn_style_inactive)
	rankings_tab.pressed.connect(_lb_switch_tab.bind("rankings"))
	lb_popup.add_child(rankings_tab)

	var stats_tab := Button.new()
	stats_tab.text = "MY STATS"
	stats_tab.offset_left = frame_l + 195; stats_tab.offset_top = tab_y
	stats_tab.offset_right = frame_l + 365; stats_tab.offset_bottom = tab_y + 34
	stats_tab.add_theme_font_size_override("font_size", 15)
	stats_tab.add_theme_color_override("font_color", Color(1, 1, 1) if lb_tab == "stats" else Color(0.5, 0.6, 0.7))
	stats_tab.add_theme_stylebox_override("normal", tab_btn_style_active if lb_tab == "stats" else tab_btn_style_inactive)
	stats_tab.pressed.connect(_lb_switch_tab.bind("stats"))
	lb_popup.add_child(stats_tab)

	# Tab separator line
	var tab_sep := ColorRect.new()
	tab_sep.color = Color(0.2, 0.3, 0.5, 0.5)
	tab_sep.offset_left = frame_l + 3; tab_sep.offset_top = tab_y + 34
	tab_sep.offset_right = frame_r - 3; tab_sep.offset_bottom = tab_y + 35
	tab_sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb_popup.add_child(tab_sep)

	# === WEAPON FILTER (right side of tab bar) ===
	var filter_lbl := Label.new()
	filter_lbl.text = "Filter:"
	filter_lbl.offset_left = frame_r - 380; filter_lbl.offset_top = tab_y + 6
	filter_lbl.offset_right = frame_r - 330; filter_lbl.offset_bottom = tab_y + 28
	filter_lbl.add_theme_font_size_override("font_size", 13)
	filter_lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
	lb_popup.add_child(filter_lbl)

	var filter_text: String = "All Weapons" if lb_weapon_filter == "" else str(WEAPON_NAMES.get(lb_weapon_filter, lb_weapon_filter))
	var filter_col: Color = Color(0.6, 0.8, 1.0) if lb_weapon_filter == "" else WEAPON_COLORS.get(lb_weapon_filter, Color.WHITE) as Color
	var filter_btn := Button.new()
	filter_btn.text = filter_text
	filter_btn.offset_left = frame_r - 325; filter_btn.offset_top = tab_y + 2
	filter_btn.offset_right = frame_r - 130; filter_btn.offset_bottom = tab_y + 32
	filter_btn.add_theme_font_size_override("font_size", 13)
	filter_btn.add_theme_color_override("font_color", filter_col)
	var filter_style := StyleBoxFlat.new()
	filter_style.bg_color = Color(0.1, 0.15, 0.25, 0.8)
	filter_style.border_color = Color(filter_col.r, filter_col.g, filter_col.b, 0.4)
	filter_style.set_border_width_all(1)
	filter_style.set_corner_radius_all(3)
	filter_btn.add_theme_stylebox_override("normal", filter_style)
	filter_btn.pressed.connect(_lb_cycle_weapon_filter)
	lb_popup.add_child(filter_btn)

	# Clear filter button
	if lb_weapon_filter != "":
		var clear_btn := Button.new()
		clear_btn.text = "X"
		clear_btn.offset_left = frame_r - 125; clear_btn.offset_top = tab_y + 4
		clear_btn.offset_right = frame_r - 95; clear_btn.offset_bottom = tab_y + 30
		clear_btn.add_theme_font_size_override("font_size", 12)
		clear_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		clear_btn.pressed.connect(_lb_filter_weapon.bind(""))
		lb_popup.add_child(clear_btn)

	var content_y := tab_y + 42

	if lb_tab == "rankings":
		_build_lb_rankings(frame_l, frame_r, frame_b, content_y)
	else:
		_build_lb_stats(frame_l, frame_r, frame_b, content_y)


func _build_lb_rankings(frame_l: int, frame_r: int, frame_b: int, start_y: int) -> void:
	var entries: Array = OnlineLeaderboard.cached_leaderboard
	if entries.is_empty():
		# Show local player at minimum
		var trophies: int = 0
		if lb_weapon_filter == "":
			trophies = GameState.get_total_trophies()
		else:
			trophies = GameState.get_weapon_trophies(lb_weapon_filter)
		entries = [{"rank": 1, "name": GameState.profile_name, "trophies": trophies, "is_player": true, "body_skin": GameState.profile_fav_skin}]

	# === PLAYER INFO BAR ===
	var name_y := start_y
	var name_bg := ColorRect.new()
	name_bg.color = Color(0.06, 0.1, 0.2, 0.7)
	name_bg.offset_left = frame_l + 15; name_bg.offset_top = name_y
	name_bg.offset_right = frame_r - 15; name_bg.offset_bottom = name_y + 36
	name_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb_popup.add_child(name_bg)

	var your_name_lbl := Label.new()
	your_name_lbl.text = GameState.profile_name
	your_name_lbl.offset_left = frame_l + 25; your_name_lbl.offset_top = name_y + 7
	your_name_lbl.offset_right = frame_l + 350; your_name_lbl.offset_bottom = name_y + 30
	your_name_lbl.add_theme_font_size_override("font_size", 16)
	your_name_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	lb_popup.add_child(your_name_lbl)

	var edit_hint := Label.new()
	edit_hint.text = "(Edit in Profile)"
	edit_hint.offset_left = frame_l + 355; edit_hint.offset_top = name_y + 10
	edit_hint.offset_right = frame_l + 530; edit_hint.offset_bottom = name_y + 28
	edit_hint.add_theme_font_size_override("font_size", 11)
	edit_hint.add_theme_color_override("font_color", Color(0.4, 0.5, 0.6))
	lb_popup.add_child(edit_hint)

	# Your rank display
	var player_rank := OnlineLeaderboard.get_player_rank()
	var rank_text := "#" + str(player_rank) if player_rank > 0 else "—"
	var rank_lbl := Label.new()
	rank_lbl.text = "Your Rank: " + rank_text
	rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rank_lbl.offset_left = frame_r - 300; rank_lbl.offset_top = name_y + 7
	rank_lbl.offset_right = frame_r - 25; rank_lbl.offset_bottom = name_y + 28
	rank_lbl.add_theme_font_size_override("font_size", 16)
	rank_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	lb_popup.add_child(rank_lbl)

	# === COLUMN HEADERS ===
	var header_y := name_y + 44
	var hdr_bg := ColorRect.new()
	hdr_bg.color = Color(0.08, 0.12, 0.22, 0.8)
	hdr_bg.offset_left = frame_l + 15; hdr_bg.offset_top = header_y
	hdr_bg.offset_right = frame_r - 15; hdr_bg.offset_bottom = header_y + 28
	hdr_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb_popup.add_child(hdr_bg)

	var headers_data := [
		[frame_l + 30, frame_l + 90, "RANK"],
		[frame_l + 100, frame_l + 450, "PLAYER"],
		[frame_l + 460, frame_l + 650, "SKIN"],
		[frame_r - 250, frame_r - 25, "TROPHIES"],
	]
	for hd in headers_data:
		var hlbl := Label.new()
		hlbl.text = hd[2]
		hlbl.offset_left = hd[0]; hlbl.offset_top = header_y + 5
		hlbl.offset_right = hd[1]; hlbl.offset_bottom = header_y + 25
		hlbl.add_theme_font_size_override("font_size", 12)
		hlbl.add_theme_color_override("font_color", Color(0.45, 0.55, 0.7))
		if hd[2] == "TROPHIES":
			hlbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lb_popup.add_child(hlbl)

	# === PLAYER ROWS ===
	var row_y := header_y + 32
	var row_h := 40
	var visible_count := mini(entries.size() - lb_scroll_offset, LB_VISIBLE_ROWS)

	for i in range(visible_count):
		var idx: int = lb_scroll_offset + i
		if idx >= entries.size():
			break
		var entry: Dictionary = entries[idx]
		var is_me: bool = entry.get("is_player", false)
		var ry: int = row_y + i * row_h

		# Row background - alternate + highlight for player
		var row_bg := ColorRect.new()
		if is_me:
			row_bg.color = Color(0.1, 0.2, 0.4, 0.6)
		elif i % 2 == 0:
			row_bg.color = Color(0.05, 0.07, 0.14, 0.4)
		else:
			row_bg.color = Color(0.06, 0.09, 0.16, 0.4)
		row_bg.offset_left = frame_l + 15; row_bg.offset_top = ry
		row_bg.offset_right = frame_r - 15; row_bg.offset_bottom = ry + row_h - 2
		row_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lb_popup.add_child(row_bg)

		# Player highlight left border
		if is_me:
			var highlight := ColorRect.new()
			highlight.color = Color(1.0, 0.85, 0.2, 0.7)
			highlight.offset_left = frame_l + 15; highlight.offset_top = ry
			highlight.offset_right = frame_l + 18; highlight.offset_bottom = ry + row_h - 2
			highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
			lb_popup.add_child(highlight)

		# Rank number
		var rank: int = entry.get("rank", idx + 1)
		var row_rank_label := Label.new()
		var rank_col := Color(1.0, 0.85, 0.2) if rank == 1 else Color(0.8, 0.8, 0.85) if rank == 2 else Color(0.75, 0.55, 0.3) if rank == 3 else Color(0.6, 0.65, 0.75)
		row_rank_label.text = "#" + str(rank)
		row_rank_label.offset_left = frame_l + 30; row_rank_label.offset_top = ry + 8
		row_rank_label.offset_right = frame_l + 90; row_rank_label.offset_bottom = ry + row_h - 4
		row_rank_label.add_theme_font_size_override("font_size", 18 if rank <= 3 else 15)
		row_rank_label.add_theme_color_override("font_color", rank_col)
		lb_popup.add_child(row_rank_label)

		# Player name
		var pname: String = entry.get("name", "???")
		if is_me:
			pname += "  (YOU)"
		var name_lbl := Label.new()
		name_lbl.text = pname
		name_lbl.offset_left = frame_l + 100; name_lbl.offset_top = ry + 8
		name_lbl.offset_right = frame_l + 450; name_lbl.offset_bottom = ry + row_h - 4
		name_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.add_theme_color_override("font_color", Color(1, 1, 1) if is_me else Color(0.8, 0.82, 0.88))
		lb_popup.add_child(name_lbl)

		# Body skin label
		var bskin: String = entry.get("body_skin", "default")
		var skin_display: String = bskin.capitalize()
		if GameState.BODY_SKINS.has(bskin):
			skin_display = str(GameState.BODY_SKINS[bskin].get("name", bskin.capitalize()))
		var skin_lbl := Label.new()
		skin_lbl.text = skin_display
		skin_lbl.offset_left = frame_l + 460; skin_lbl.offset_top = ry + 10
		skin_lbl.offset_right = frame_l + 650; skin_lbl.offset_bottom = ry + row_h - 4
		skin_lbl.add_theme_font_size_override("font_size", 13)
		skin_lbl.add_theme_color_override("font_color", Color(0.6, 0.5, 0.85))
		lb_popup.add_child(skin_lbl)

		# Trophy count
		var t_count: int = entry.get("trophies", 0)
		var trophy_lbl := Label.new()
		trophy_lbl.text = str(t_count)
		trophy_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		trophy_lbl.offset_left = frame_r - 250; trophy_lbl.offset_top = ry + 6
		trophy_lbl.offset_right = frame_r - 25; trophy_lbl.offset_bottom = ry + row_h - 4
		trophy_lbl.add_theme_font_size_override("font_size", 20)
		trophy_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2) if is_me else Color(0.9, 0.82, 0.5))
		lb_popup.add_child(trophy_lbl)

	# === SCROLL BUTTONS ===
	var scroll_y: int = row_y + LB_VISIBLE_ROWS * row_h + 5
	if entries.size() > LB_VISIBLE_ROWS:
		var up_btn := Button.new()
		up_btn.text = "^ UP"
		up_btn.offset_left = frame_l + 450; up_btn.offset_top = scroll_y
		up_btn.offset_right = frame_l + 570; up_btn.offset_bottom = scroll_y + 30
		up_btn.add_theme_font_size_override("font_size", 13)
		up_btn.add_theme_color_override("font_color", Color(0.6, 0.75, 0.9))
		up_btn.pressed.connect(_lb_scroll.bind(-3))
		lb_popup.add_child(up_btn)

		var down_btn := Button.new()
		down_btn.text = "v DOWN"
		down_btn.offset_left = frame_l + 580; down_btn.offset_top = scroll_y
		down_btn.offset_right = frame_l + 700; down_btn.offset_bottom = scroll_y + 30
		down_btn.add_theme_font_size_override("font_size", 13)
		down_btn.add_theme_color_override("font_color", Color(0.6, 0.75, 0.9))
		down_btn.pressed.connect(_lb_scroll.bind(3))
		lb_popup.add_child(down_btn)

	# Bottom status
	var status_y := frame_b - 30
	var status_text := "Showing %d player(s)" % entries.size()
	if OnlineLeaderboard.is_fetching:
		status_text = "Fetching online data..."
	elif entries.size() <= 1:
		status_text = "Waiting for players to join online..."
	var status_lbl := Label.new()
	status_lbl.text = status_text
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_lbl.offset_left = frame_l; status_lbl.offset_top = status_y
	status_lbl.offset_right = frame_r; status_lbl.offset_bottom = status_y + 20
	status_lbl.add_theme_font_size_override("font_size", 12)
	status_lbl.add_theme_color_override("font_color", Color(0.4, 0.5, 0.6))
	lb_popup.add_child(status_lbl)


func _build_lb_stats(frame_l: int, frame_r: int, _frame_b: int, start_y: int) -> void:
	# === YOUR STATS HERO SECTION ===
	var hero_y := start_y + 5
	var hero_bg := ColorRect.new()
	hero_bg.color = Color(0.06, 0.12, 0.25, 0.8)
	hero_bg.offset_left = frame_l + 15; hero_bg.offset_top = hero_y
	hero_bg.offset_right = frame_r - 15; hero_bg.offset_bottom = hero_y + 90
	hero_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb_popup.add_child(hero_bg)
	# Gold accent line
	var hero_accent := ColorRect.new()
	hero_accent.color = Color(1.0, 0.85, 0.2, 0.6)
	hero_accent.offset_left = frame_l + 15; hero_accent.offset_top = hero_y
	hero_accent.offset_right = frame_r - 15; hero_accent.offset_bottom = hero_y + 2
	hero_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb_popup.add_child(hero_accent)

	var total_trophies := GameState.get_total_trophies()
	var big_trophy := Label.new()
	big_trophy.text = str(total_trophies)
	big_trophy.offset_left = frame_l + 40; big_trophy.offset_top = hero_y + 8
	big_trophy.offset_right = frame_l + 250; big_trophy.offset_bottom = hero_y + 55
	big_trophy.add_theme_font_size_override("font_size", 38)
	big_trophy.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	lb_popup.add_child(big_trophy)
	var trophy_sub := Label.new()
	trophy_sub.text = "TOTAL TROPHIES"
	trophy_sub.offset_left = frame_l + 40; trophy_sub.offset_top = hero_y + 55
	trophy_sub.offset_right = frame_l + 250; trophy_sub.offset_bottom = hero_y + 75
	trophy_sub.add_theme_font_size_override("font_size", 12)
	trophy_sub.add_theme_color_override("font_color", Color(0.5, 0.65, 0.8))
	lb_popup.add_child(trophy_sub)

	var cur_wid := GameState.fighter_weapon_id
	var cur_wt := GameState.get_weapon_trophies(cur_wid)
	var wcol: Color = WEAPON_COLORS.get(cur_wid, Color.WHITE)
	var cur_weapon_lbl := Label.new()
	cur_weapon_lbl.text = WEAPON_NAMES.get(cur_wid, cur_wid) + ": " + str(cur_wt)
	cur_weapon_lbl.offset_left = frame_l + 280; cur_weapon_lbl.offset_top = hero_y + 15
	cur_weapon_lbl.offset_right = frame_l + 550; cur_weapon_lbl.offset_bottom = hero_y + 40
	cur_weapon_lbl.add_theme_font_size_override("font_size", 18)
	cur_weapon_lbl.add_theme_color_override("font_color", wcol)
	lb_popup.add_child(cur_weapon_lbl)
	var cur_weapon_sub := Label.new()
	cur_weapon_sub.text = "CURRENT WEAPON"
	cur_weapon_sub.offset_left = frame_l + 280; cur_weapon_sub.offset_top = hero_y + 42
	cur_weapon_sub.offset_right = frame_l + 550; cur_weapon_sub.offset_bottom = hero_y + 60
	cur_weapon_sub.add_theme_font_size_override("font_size", 11)
	cur_weapon_sub.add_theme_color_override("font_color", Color(0.45, 0.55, 0.7))
	lb_popup.add_child(cur_weapon_sub)

	var unlocked := GameState.fighter_unlocked_weapons.size()
	var total_weapons := POPUP_ORDER.size()
	var unlock_lbl := Label.new()
	unlock_lbl.text = str(unlocked) + " / " + str(total_weapons) + " Weapons"
	unlock_lbl.offset_left = frame_r - 280; unlock_lbl.offset_top = hero_y + 15
	unlock_lbl.offset_right = frame_r - 30; unlock_lbl.offset_bottom = hero_y + 40
	unlock_lbl.add_theme_font_size_override("font_size", 18)
	unlock_lbl.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	lb_popup.add_child(unlock_lbl)
	var unlock_sub := Label.new()
	unlock_sub.text = "WEAPONS UNLOCKED"
	unlock_sub.offset_left = frame_r - 280; unlock_sub.offset_top = hero_y + 42
	unlock_sub.offset_right = frame_r - 30; unlock_sub.offset_bottom = hero_y + 60
	unlock_sub.add_theme_font_size_override("font_size", 11)
	unlock_sub.add_theme_color_override("font_color", Color(0.45, 0.55, 0.7))
	lb_popup.add_child(unlock_sub)

	# === WEAPON TROPHY BARS ===
	var bars_y := hero_y + 100
	var bar_section_label := Label.new()
	bar_section_label.text = "TROPHY BREAKDOWN BY WEAPON"
	bar_section_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bar_section_label.offset_left = frame_l; bar_section_label.offset_top = bars_y
	bar_section_label.offset_right = frame_r; bar_section_label.offset_bottom = bars_y + 20
	bar_section_label.add_theme_font_size_override("font_size", 13)
	bar_section_label.add_theme_color_override("font_color", Color(0.5, 0.6, 0.75))
	lb_popup.add_child(bar_section_label)
	var sep := ColorRect.new()
	sep.color = Color(0.3, 0.5, 0.8, 0.3)
	sep.offset_left = frame_l + 100; sep.offset_top = bars_y + 22
	sep.offset_right = frame_r - 100; sep.offset_bottom = bars_y + 23
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb_popup.add_child(sep)

	bars_y += 30
	var max_wt: int = 1
	for wid in POPUP_ORDER:
		var wt: int = GameState.get_weapon_trophies(wid)
		if wt > max_wt:
			max_wt = wt

	var col1_x := frame_l + 30
	var col2_x := frame_l + 610
	var bar_h := 28
	var bar_gap := 4
	var bar_max_w := 320
	var col := 0
	var row := 0

	for wid in POPUP_ORDER:
		var wt: int = GameState.get_weapon_trophies(wid)
		var _wname: String = str(WEAPON_NAMES.get(wid, wid))
		var wcolor: Color = WEAPON_COLORS.get(wid, Color.WHITE)
		var bx: int = col1_x if col == 0 else col2_x
		var by: int = bars_y + row * (bar_h + bar_gap)
		var is_selected: bool = (lb_weapon_filter == wid)

		var wlbl := Label.new()
		wlbl.text = _wname
		wlbl.offset_left = bx; wlbl.offset_top = by + 2
		wlbl.offset_right = bx + 120; wlbl.offset_bottom = by + bar_h
		wlbl.add_theme_font_size_override("font_size", 12)
		wlbl.add_theme_color_override("font_color", wcolor if is_selected else Color(wcolor.r, wcolor.g, wcolor.b, 0.7))
		lb_popup.add_child(wlbl)

		var bar_bg := ColorRect.new()
		bar_bg.color = Color(0.15, 0.15, 0.2, 0.6)
		bar_bg.offset_left = bx + 125; bar_bg.offset_top = by + 5
		bar_bg.offset_right = bx + 125 + bar_max_w; bar_bg.offset_bottom = by + bar_h - 3
		bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lb_popup.add_child(bar_bg)

		if wt > 0:
			var fill_w: int = maxi(int(float(wt) / float(max_wt) * bar_max_w), 4)
			var bar_fill := ColorRect.new()
			bar_fill.color = Color(wcolor.r, wcolor.g, wcolor.b, 0.7 if not is_selected else 1.0)
			bar_fill.offset_left = bx + 125; bar_fill.offset_top = by + 5
			bar_fill.offset_right = bx + 125 + fill_w; bar_fill.offset_bottom = by + bar_h - 3
			bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
			lb_popup.add_child(bar_fill)

		var wt_lbl := Label.new()
		wt_lbl.text = str(wt)
		wt_lbl.offset_left = bx + 125 + bar_max_w + 8; wt_lbl.offset_top = by + 2
		wt_lbl.offset_right = bx + 125 + bar_max_w + 70; wt_lbl.offset_bottom = by + bar_h
		wt_lbl.add_theme_font_size_override("font_size", 12)
		wt_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.8) if wt > 0 else Color(0.4, 0.4, 0.45))
		lb_popup.add_child(wt_lbl)

		var click_btn := Button.new()
		click_btn.text = ""
		click_btn.flat = true
		click_btn.offset_left = bx; click_btn.offset_top = by
		click_btn.offset_right = bx + 125 + bar_max_w + 70; click_btn.offset_bottom = by + bar_h
		click_btn.pressed.connect(_lb_filter_weapon.bind(wid))
		lb_popup.add_child(click_btn)

		col += 1
		if col >= 2:
			col = 0
			row += 1


func _lb_switch_tab(tab: String) -> void:
	lb_tab = tab
	_build_lb_contents()



func _lb_cycle_weapon_filter() -> void:
	# Cycle through: "" -> fists -> shadow_blade -> ... -> ""
	if lb_weapon_filter == "":
		lb_weapon_filter = POPUP_ORDER[0]
	else:
		var idx := POPUP_ORDER.find(lb_weapon_filter)
		if idx == -1 or idx >= POPUP_ORDER.size() - 1:
			lb_weapon_filter = ""
		else:
			lb_weapon_filter = POPUP_ORDER[idx + 1]
	lb_scroll_offset = 0
	# Re-fetch with new filter
	OnlineLeaderboard.last_fetch_time = 0  # Reset cooldown
	OnlineLeaderboard.leaderboard_fetched.connect(_on_lb_fetched, CONNECT_ONE_SHOT)
	OnlineLeaderboard.fetch_leaderboard(lb_weapon_filter)
	_build_lb_contents()


func _lb_filter_weapon(wid: String) -> void:
	lb_weapon_filter = wid
	lb_scroll_offset = 0
	OnlineLeaderboard.last_fetch_time = 0
	OnlineLeaderboard.leaderboard_fetched.connect(_on_lb_fetched, CONNECT_ONE_SHOT)
	OnlineLeaderboard.fetch_leaderboard(lb_weapon_filter)
	_build_lb_contents()


func _lb_scroll(delta: int) -> void:
	var entries: Array = OnlineLeaderboard.cached_leaderboard
	lb_scroll_offset = clampi(lb_scroll_offset + delta, 0, maxi(entries.size() - LB_VISIBLE_ROWS, 0))
	_build_lb_contents()


# ─── HELPERS ──────────────────────────────────────────

func _any_popup_open() -> bool:
	return popup_open or pass_popup_open or skin_popup_open or upgrade_popup_open or settings_popup_open or road_popup_open or lb_popup_open or profile_popup_open or challenges_popup_open or login_popup_open or achievements_popup_open


# ─── MODE CYCLING ─────────────────────────────────────

func _cycle_mode(delta_idx: int) -> void:
	mode_index = wrapi(mode_index + delta_idx, 0, MODE_ORDER.size())
	GameState.fighter_game_mode = MODE_ORDER[mode_index]
	_update_mode_display()


func _update_mode_display() -> void:
	var mid: String = GameState.fighter_game_mode
	mode_label.text = MODE_NAMES.get(mid, mid.capitalize())
	mode_hint.text = MODE_DESCRIPTIONS.get(mid, "")


func _update_trophy_display() -> void:
	var wid: String = GameState.fighter_weapon_id
	var weapon_trophies := GameState.get_weapon_trophies(wid)
	var total_trophies := GameState.get_total_trophies()
	trophy_label.text = "🏆 %d total  ·  %s: %d" % [total_trophies, WEAPON_NAMES.get(wid, wid), weapon_trophies]


# ─── CALLBACKS ────────────────────────────────────────

func _on_fight_pressed() -> void:
	if _any_popup_open():
		return
	get_tree().change_scene_to_file("res://scenes/fighter/Arena.tscn")


func _on_prev_mode_pressed() -> void:
	if _any_popup_open():
		return
	_cycle_mode(-1)


func _on_next_mode_pressed() -> void:
	if _any_popup_open():
		return
	_cycle_mode(1)


# ─── INPUT ────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	# Key rebinding capture (intercept before ESC check)
	if settings_popup_open and _rebinding_action != "" and event is InputEventKey and event.pressed:
		_on_rebind_key(event)
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if popup_open:
			get_viewport().set_input_as_handled()
			_close_weapon_popup()
		elif pass_popup_open:
			get_viewport().set_input_as_handled()
			_close_pass_popup()
			_update_currency_display()
		elif skin_popup_open:
			get_viewport().set_input_as_handled()
			_close_skin_popup()
			_update_currency_display()
		elif upgrade_popup_open:
			get_viewport().set_input_as_handled()
			_close_upgrade_popup()
			_update_currency_display()
		elif settings_popup_open:
			get_viewport().set_input_as_handled()
			_close_settings_popup()
		elif road_popup_open:
			get_viewport().set_input_as_handled()
			_close_road_popup()
			_update_currency_display()
		elif lb_popup_open:
			get_viewport().set_input_as_handled()
			_close_lb_popup()
		elif profile_popup_open:
			get_viewport().set_input_as_handled()
			_close_profile_popup()
		elif challenges_popup_open:
			get_viewport().set_input_as_handled()
			_close_challenges_popup()
		elif login_popup_open:
			get_viewport().set_input_as_handled()
			_close_login_popup()
		elif achievements_popup_open:
			get_viewport().set_input_as_handled()
			_close_achievements_popup()


# ─── LOGIN STREAK POPUP ──────────────────────────────

func _show_login_popup() -> void:
	login_popup_open = true
	login_popup = ColorRect.new()
	login_popup.color = Color(0, 0, 0, 0.85)
	login_popup.offset_left = 0; login_popup.offset_top = 0
	login_popup.offset_right = 1280; login_popup.offset_bottom = 720
	$HUD.add_child(login_popup)

	var frame := ColorRect.new()
	frame.color = Color(0.08, 0.12, 0.06, 0.95)
	frame.offset_left = 390; frame.offset_top = 180
	frame.offset_right = 890; frame.offset_bottom = 540
	login_popup.add_child(frame)

	var border := ColorRect.new()
	border.color = Color(0.3, 0.8, 0.2, 0.4)
	border.offset_left = 388; border.offset_top = 178
	border.offset_right = 892; border.offset_bottom = 542
	border.z_index = -1
	login_popup.add_child(border)

	var title := Label.new()
	title.text = "DAILY LOGIN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = 390; title.offset_top = 195
	title.offset_right = 890; title.offset_bottom = 235
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.4, 0.9, 0.3))
	login_popup.add_child(title)

	var streak_text := Label.new()
	streak_text.text = "Login Streak: %d days" % GameState.login_streak
	streak_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	streak_text.offset_left = 390; streak_text.offset_top = 245
	streak_text.offset_right = 890; streak_text.offset_bottom = 275
	streak_text.add_theme_font_size_override("font_size", 20)
	streak_text.add_theme_color_override("font_color", Color(0.8, 0.85, 0.7))
	login_popup.add_child(streak_text)

	# Show reward tiers
	var ry: int = 290
	for tier in GameState.LOGIN_STREAK_REWARDS:
		var days: int = tier[0]
		var desc: String = str(tier[3])
		var reached: bool = GameState.login_streak >= days
		var lbl := Label.new()
		lbl.text = ("  " if reached else "  ") + desc
		lbl.offset_left = 430; lbl.offset_top = ry
		lbl.offset_right = 850; lbl.offset_bottom = ry + 25
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3) if reached else Color(0.5, 0.5, 0.45))
		login_popup.add_child(lbl)
		ry += 26

	# Claim button
	var reward := GameState.get_login_reward()
	if not reward.is_empty():
		var claim_btn := Button.new()
		claim_btn.text = "CLAIM: %s" % str(reward.get("desc", "Reward"))
		claim_btn.offset_left = 490; claim_btn.offset_top = 490
		claim_btn.offset_right = 790; claim_btn.offset_bottom = 530
		claim_btn.add_theme_font_size_override("font_size", 18)
		claim_btn.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
		_make_styled_button(claim_btn, Color(0.1, 0.25, 0.08, 0.9), Color(0.3, 0.9, 0.2, 0.6))
		claim_btn.pressed.connect(_on_login_claim)
		login_popup.add_child(claim_btn)


func _on_login_claim() -> void:
	GameState.claim_login_reward()
	_close_login_popup()
	_update_currency_display()


func _close_login_popup() -> void:
	if login_popup and is_instance_valid(login_popup):
		login_popup.queue_free()
	login_popup = null
	login_popup_open = false


# ─── ACHIEVEMENTS ────────────────────────────────────

func _create_achievements_button() -> void:
	achievements_btn = Button.new()
	achievements_btn.text = "ACHIEVEMENTS"
	achievements_btn.offset_left = 40
	achievements_btn.offset_top = 570
	achievements_btn.offset_right = 210
	achievements_btn.offset_bottom = 600
	achievements_btn.add_theme_font_size_override("font_size", 14)
	achievements_btn.add_theme_color_override("font_color", Color(0.4, 0.9, 0.3))
	achievements_btn.pressed.connect(_open_achievements_popup)
	$HUD.add_child(achievements_btn)
	_update_achievements_button()


func _update_achievements_button() -> void:
	var unlocked := GameState.unlocked_achievements.size()
	var total := GameState.ACHIEVEMENTS.size()
	if achievements_btn:
		achievements_btn.text = "ACHIEVEMENTS (%d/%d)" % [unlocked, total]


func _create_achievements_popup() -> void:
	achievements_popup = ColorRect.new()
	achievements_popup.color = Color(0, 0, 0, 0.9)
	achievements_popup.offset_left = 0; achievements_popup.offset_top = 0
	achievements_popup.offset_right = 1280; achievements_popup.offset_bottom = 720
	achievements_popup.visible = false
	$HUD.add_child(achievements_popup)


func _open_achievements_popup() -> void:
	if _any_popup_open():
		return
	achievements_popup_open = true
	achievements_popup.visible = true
	ach_scroll_offset = 0
	_build_achievements_contents()


func _close_achievements_popup() -> void:
	achievements_popup_open = false
	achievements_popup.visible = false
	for c in achievements_popup.get_children():
		c.queue_free()


func _build_achievements_contents() -> void:
	for c in achievements_popup.get_children():
		c.queue_free()

	var frame_l: int = 190
	var frame_r: int = 1090
	var frame_t: int = 60
	var frame_b: int = 660

	var frame := ColorRect.new()
	frame.color = Color(0.04, 0.08, 0.03, 0.95)
	frame.offset_left = frame_l; frame.offset_top = frame_t
	frame.offset_right = frame_r; frame.offset_bottom = frame_b
	achievements_popup.add_child(frame)

	var border := ColorRect.new()
	border.color = Color(0.3, 0.7, 0.2, 0.4)
	border.offset_left = frame_l - 2; border.offset_top = frame_t - 2
	border.offset_right = frame_r + 2; border.offset_bottom = frame_b + 2
	border.z_index = -1
	achievements_popup.add_child(border)

	var title := Label.new()
	title.text = "ACHIEVEMENTS  (%d / %d)" % [GameState.unlocked_achievements.size(), GameState.ACHIEVEMENTS.size()]
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.offset_left = frame_l; title.offset_top = frame_t + 10
	title.offset_right = frame_r; title.offset_bottom = frame_t + 45
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.4, 0.9, 0.3))
	achievements_popup.add_child(title)

	# Close button
	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.offset_left = frame_r - 40; close_btn.offset_top = frame_t + 8
	close_btn.offset_right = frame_r - 10; close_btn.offset_bottom = frame_t + 38
	close_btn.add_theme_font_size_override("font_size", 16)
	close_btn.pressed.connect(_close_achievements_popup)
	achievements_popup.add_child(close_btn)

	# Achievement rows
	var row_h: int = 65
	var start_y: int = frame_t + 55
	var visible_achs := GameState.ACHIEVEMENTS.slice(ach_scroll_offset, ach_scroll_offset + ACH_VISIBLE_ROWS)

	for i in range(visible_achs.size()):
		var ach: Dictionary = visible_achs[i]
		var aid: String = str(ach["id"])
		var is_unlocked: bool = aid in GameState.unlocked_achievements
		var ry: int = start_y + i * row_h

		# Row background
		var row_bg := ColorRect.new()
		row_bg.color = Color(0.08, 0.15, 0.06, 0.6) if is_unlocked else Color(0.06, 0.06, 0.08, 0.5)
		row_bg.offset_left = frame_l + 15; row_bg.offset_top = ry
		row_bg.offset_right = frame_r - 15; row_bg.offset_bottom = ry + row_h - 4
		row_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		achievements_popup.add_child(row_bg)

		# Achievement name
		var name_lbl := Label.new()
		name_lbl.text = str(ach["name"])
		name_lbl.offset_left = frame_l + 25; name_lbl.offset_top = ry + 5
		name_lbl.offset_right = frame_l + 300; name_lbl.offset_bottom = ry + 28
		name_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.3) if is_unlocked else Color(0.7, 0.7, 0.6))
		achievements_popup.add_child(name_lbl)

		# Description
		var desc_lbl := Label.new()
		desc_lbl.text = str(ach["desc"])
		desc_lbl.offset_left = frame_l + 25; desc_lbl.offset_top = ry + 28
		desc_lbl.offset_right = frame_l + 500; desc_lbl.offset_bottom = ry + 48
		desc_lbl.add_theme_font_size_override("font_size", 12)
		desc_lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.45))
		achievements_popup.add_child(desc_lbl)

		# Progress bar
		var progress: float = 1.0 if is_unlocked else GameState.get_achievement_progress(ach)
		var bar_bg := ColorRect.new()
		bar_bg.color = Color(0.1, 0.1, 0.12, 0.8)
		bar_bg.offset_left = frame_l + 520; bar_bg.offset_top = ry + 15
		bar_bg.offset_right = frame_r - 120; bar_bg.offset_bottom = ry + 30
		achievements_popup.add_child(bar_bg)

		var bar_fill := ColorRect.new()
		var bar_w: float = (frame_r - 120 - frame_l - 520) * progress
		bar_fill.color = Color(0.3, 0.9, 0.2, 0.8) if is_unlocked else Color(0.6, 0.7, 0.3, 0.6)
		bar_fill.offset_left = frame_l + 520; bar_fill.offset_top = ry + 15
		bar_fill.offset_right = frame_l + 520 + int(bar_w); bar_fill.offset_bottom = ry + 30
		achievements_popup.add_child(bar_fill)

		var pct_lbl := Label.new()
		pct_lbl.text = "DONE" if is_unlocked else "%d%%" % int(progress * 100)
		pct_lbl.offset_left = frame_l + 525; pct_lbl.offset_top = ry + 14
		pct_lbl.offset_right = frame_r - 125; pct_lbl.offset_bottom = ry + 32
		pct_lbl.add_theme_font_size_override("font_size", 10)
		pct_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
		achievements_popup.add_child(pct_lbl)

		# Reward
		var reward_lbl := Label.new()
		reward_lbl.text = "+%d %s" % [int(ach["amount"]), str(ach["reward"]).capitalize()]
		reward_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		reward_lbl.offset_left = frame_r - 115; reward_lbl.offset_top = ry + 12
		reward_lbl.offset_right = frame_r - 20; reward_lbl.offset_bottom = ry + 35
		reward_lbl.add_theme_font_size_override("font_size", 14)
		reward_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.8) if is_unlocked else Color(0.5, 0.45, 0.3, 0.6))
		achievements_popup.add_child(reward_lbl)

	# Scroll buttons
	if ach_scroll_offset > 0:
		var up_btn := Button.new()
		up_btn.text = "UP"
		up_btn.offset_left = frame_l + 15; up_btn.offset_top = frame_b - 40
		up_btn.offset_right = frame_l + 80; up_btn.offset_bottom = frame_b - 10
		up_btn.add_theme_font_size_override("font_size", 12)
		up_btn.pressed.connect(func(): ach_scroll_offset = maxi(ach_scroll_offset - ACH_VISIBLE_ROWS, 0); _build_achievements_contents())
		achievements_popup.add_child(up_btn)

	if ach_scroll_offset + ACH_VISIBLE_ROWS < GameState.ACHIEVEMENTS.size():
		var down_btn := Button.new()
		down_btn.text = "DOWN"
		down_btn.offset_left = frame_r - 80; down_btn.offset_top = frame_b - 40
		down_btn.offset_right = frame_r - 15; down_btn.offset_bottom = frame_b - 10
		down_btn.add_theme_font_size_override("font_size", 12)
		down_btn.pressed.connect(func(): ach_scroll_offset += ACH_VISIBLE_ROWS; _build_achievements_contents())
		achievements_popup.add_child(down_btn)


# ─── SEASON DISPLAY ──────────────────────────────────

func _create_season_display() -> void:
	season_label = Label.new()
	var today := GameState._get_today_string()
	var days_left: int = GameState.SEASON_DURATION_DAYS
	if GameState.season_start_date != "":
		days_left = maxi(GameState.SEASON_DURATION_DAYS - GameState._days_between(GameState.season_start_date, today), 0)
	season_label.text = "Season %d  ·  %d days left  ·  Peak: %d" % [GameState.current_season, days_left, GameState.season_peak_trophies]
	season_label.offset_left = 40
	season_label.offset_top = 605
	season_label.offset_right = 600
	season_label.offset_bottom = 625
	season_label.add_theme_font_size_override("font_size", 12)
	season_label.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7, 0.6))
	$HUD.add_child(season_label)


func _unhandled_input(event: InputEvent) -> void:
	if _any_popup_open():
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP or event.keycode == KEY_W:
			_cycle_mode(1)
		elif event.keycode == KEY_DOWN or event.keycode == KEY_S:
			_cycle_mode(-1)
