extends Node2D
class_name StylizedRoomArt

@export_enum(
	"hub",
	"village",
	"farm",
	"bank",
	"bandit_house",
	"market_house",
	"prison",
	"forge_hall",
	"arcane_vault",
	"iron_docks",
	"verdant_garden",
	"dune_courtyard",
	"ashen_keep",
	"obsidian_hall",
	"frost_labyrinth",
	"storm_sanctum",
	"void_bastion",
	"sky_keep",
	"tavern_interior",
	"store_interior",
	"house_interior",
	"bank_interior",
	"jeweler_interior"
) var style := "hub"

const OUTLINE_COLOR := Color(0.14, 0.16, 0.2, 0.85)
const SHADOW_COLOR := Color(0.03, 0.05, 0.08, 0.12)

var _rng: RandomNumberGenerator


func _ready() -> void:
	z_index = -20
	_rng = RandomNumberGenerator.new()
	_rng.seed = hash(style)
	queue_redraw()


func _draw() -> void:
	_rng.seed = hash(style)
	match style:
		"hub": _draw_hub()
		"village": _draw_village()
		"farm": _draw_farm()
		"bank": _draw_bank()
		"bandit_house": _draw_bandit_house()
		"market_house": _draw_market_house()
		"prison": _draw_prison()
		"forge_hall": _draw_forge_hall()
		"arcane_vault": _draw_arcane_vault()
		"iron_docks": _draw_iron_docks()
		"verdant_garden": _draw_verdant_garden()
		"dune_courtyard": _draw_dune_courtyard()
		"ashen_keep": _draw_ashen_keep()
		"obsidian_hall": _draw_obsidian_hall()
		"frost_labyrinth": _draw_frost_labyrinth()
		"storm_sanctum": _draw_storm_sanctum()
		"void_bastion": _draw_void_bastion()
		"sky_keep": _draw_sky_keep()
		"tavern_interior": _draw_tavern_interior()
		"store_interior": _draw_store_interior()
		"house_interior": _draw_house_interior()
		"bank_interior": _draw_bank_interior()
		"jeweler_interior": _draw_jeweler_interior()
		_: _draw_hub()


# ============================================================
# ROOM STYLES
# ============================================================

func _draw_hub() -> void:
	var bg := Rect2(-1200, -760, 2400, 1520)
	draw_rect(bg, Color(0.58, 0.76, 0.44, 1.0), true)
	_draw_ground_texture(bg, Color(0.58, 0.76, 0.44), "grass")
	# Pond with lily pads
	_draw_blob(Vector2(54, -48), Vector2(264, 154), Color(0.28, 0.62, 0.82, 1.0), Color(0.68, 0.9, 1.0, 0.3))
	_draw_water_detail(Vector2(54, -48), Vector2(264, 154))
	# Lily pads
	draw_circle(Vector2(30, -60), 8.0, Color(0.3, 0.62, 0.3, 0.6))
	draw_circle(Vector2(80, -30), 7.0, Color(0.28, 0.58, 0.28, 0.5))
	draw_circle(Vector2(54, -70), 6.0, Color(0.32, 0.66, 0.32, 0.5))
	# Paths
	_draw_path_textured(Rect2(-980, 244, 1880, 150), Color(0.78, 0.68, 0.5, 1.0))
	_draw_path_textured(Rect2(358, -620, 196, 980), Color(0.78, 0.68, 0.5, 1.0))
	_draw_plaza_tiled(Vector2(424, 260), Vector2(356, 176), Color(0.86, 0.79, 0.66, 1.0))
	# Buildings
	_draw_building(Vector2(-734, 184), Vector2(250, 190), Color(0.92, 0.74, 0.42, 1.0), Color(0.72, 0.3, 0.18, 1.0))
	_draw_building(Vector2(708, 122), Vector2(226, 168), Color(0.86, 0.76, 0.56, 1.0), Color(0.62, 0.28, 0.2, 1.0))
	# Trees with more variety
	_draw_tree_cluster([
		Vector2(-882, -368), Vector2(-798, -298), Vector2(-710, -356),
		Vector2(768, -338), Vector2(878, -278), Vector2(960, -344),
		Vector2(-236, 374), Vector2(-102, 328), Vector2(822, 352),
		Vector2(-940, 120), Vector2(980, 400)
	], 58.0, Color(0.22, 0.56, 0.32, 1.0))
	# Flowers in multiple areas
	_draw_flower_scatter(Rect2(-500, -300, 280, 180), 14, [Color(0.95, 0.82, 0.28), Color(0.88, 0.38, 0.38), Color(0.78, 0.62, 0.92)])
	_draw_flower_scatter(Rect2(500, 340, 200, 120), 8, [Color(0.95, 0.82, 0.28), Color(0.92, 0.92, 0.72)])
	_draw_flower_scatter(Rect2(-200, -440, 160, 100), 6, [Color(0.92, 0.55, 0.65), Color(0.85, 0.85, 0.42)])
	# Light pools
	_draw_light_pool(Vector2(-734, 184), 100.0, Color(1.0, 0.88, 0.62, 0.06))
	_draw_light_pool(Vector2(708, 122), 90.0, Color(1.0, 0.88, 0.62, 0.05))
	# Shrubs with more coverage
	_draw_shrub_row(Vector2(-64, 382), 7, 56.0, Color(0.38, 0.72, 0.4, 1.0))
	_draw_shrub_row(Vector2(-520, -160), 4, 48.0, Color(0.34, 0.68, 0.38, 1.0))
	# Rocks near pond
	_draw_pebble_scatter(Rect2(-80, -150, 280, 60), 6, Color(0.52, 0.5, 0.46))


func _draw_village() -> void:
	var bg := Rect2(-840, -700, 1680, 1400)
	draw_rect(bg, Color(0.68, 0.82, 0.54, 1.0), true)
	_draw_ground_texture(bg, Color(0.68, 0.82, 0.54), "grass")
	_draw_blob(Vector2(-284, -84), Vector2(198, 144), Color(0.36, 0.72, 0.88, 1.0), Color(0.76, 0.94, 1.0, 0.25))
	_draw_water_detail(Vector2(-284, -84), Vector2(198, 144))
	_draw_path_textured(Rect2(-620, -50, 1180, 138), Color(0.82, 0.72, 0.55, 1.0))
	_draw_path_textured(Rect2(108, -600, 172, 1180), Color(0.82, 0.72, 0.55, 1.0))
	_draw_plaza_tiled(Vector2(254, 132), Vector2(404, 236), Color(0.88, 0.8, 0.66, 1.0))
	_draw_building(Vector2(-152, -408), Vector2(216, 156), Color(0.94, 0.84, 0.62, 1.0), Color(0.72, 0.32, 0.2, 1.0))
	_draw_building(Vector2(372, -418), Vector2(204, 150), Color(0.92, 0.78, 0.55, 1.0), Color(0.68, 0.28, 0.18, 1.0))
	_draw_building(Vector2(476, 264), Vector2(220, 160), Color(0.92, 0.78, 0.58, 1.0), Color(0.66, 0.26, 0.2, 1.0))
	_draw_market_stall(Vector2(182, 166), Vector2(110, 74), Color(0.82, 0.38, 0.2, 1.0), Color(0.94, 0.88, 0.66, 1.0))
	_draw_market_stall(Vector2(308, 166), Vector2(110, 74), Color(0.16, 0.56, 0.64, 1.0), Color(0.9, 0.94, 1.0, 1.0))
	_draw_tree_cluster([
		Vector2(-502, -312), Vector2(-612, -216), Vector2(-598, 126),
		Vector2(638, -258), Vector2(606, 84), Vector2(-438, 312)
	], 50.0, Color(0.24, 0.58, 0.34, 1.0))
	_draw_flower_scatter(Rect2(-300, 100, 200, 120), 8, [Color(0.92, 0.75, 0.3), Color(0.8, 0.35, 0.55)])
	_draw_pebble_scatter(Rect2(120, 80, 260, 160), 8, Color(0.58, 0.52, 0.44))


func _draw_farm() -> void:
	var bg := Rect2(-1080, -720, 2160, 1440)
	draw_rect(bg, Color(0.66, 0.8, 0.5, 1.0), true)
	_draw_ground_texture(bg, Color(0.66, 0.8, 0.5), "grass")
	_draw_field_patch(Vector2(-362, 108), Vector2(308, 194), Color(0.6, 0.74, 0.38, 1.0))
	_draw_field_patch(Vector2(350, 120), Vector2(330, 208), Color(0.8, 0.7, 0.38, 1.0))
	_draw_path_textured(Rect2(-220, -620, 156, 1160), Color(0.8, 0.68, 0.5, 1.0))
	_draw_path_textured(Rect2(-780, -8, 1560, 120), Color(0.8, 0.68, 0.5, 1.0))
	_draw_building(Vector2(0, -220), Vector2(306, 204), Color(0.9, 0.78, 0.55, 1.0), Color(0.74, 0.3, 0.2, 1.0))
	_draw_barn(Vector2(462, -136), Vector2(276, 214))
	_draw_fence_line(Vector2(-542, -166), 8, 98.0)
	_draw_fence_line(Vector2(-542, 230), 8, 98.0)
	_draw_hay_bale(Vector2(-478, 28), Vector2(42, 30))
	_draw_hay_bale(Vector2(286, 34), Vector2(42, 30))
	_draw_hay_bale(Vector2(534, 108), Vector2(42, 30))
	_draw_tree_cluster([Vector2(-808, -304), Vector2(-712, -404), Vector2(790, -344), Vector2(884, 126)], 54.0, Color(0.26, 0.62, 0.32, 1.0))
	_draw_flower_scatter(Rect2(-600, 50, 140, 100), 5, [Color(0.92, 0.88, 0.32), Color(0.72, 0.42, 0.42)])


func _draw_bank() -> void:
	var bg := Rect2(-820, -720, 1640, 1440)
	draw_rect(bg, Color(0.82, 0.82, 0.78, 1.0), true)
	_draw_ground_texture(bg, Color(0.82, 0.82, 0.78), "stone")
	_draw_path_textured(Rect2(-700, 196, 1400, 150), Color(0.72, 0.68, 0.58, 1.0))
	_draw_path_textured(Rect2(-122, -620, 244, 1240), Color(0.72, 0.68, 0.58, 1.0))
	_draw_building(Vector2(0, -120), Vector2(540, 356), Color(0.92, 0.88, 0.78, 1.0), Color(0.64, 0.44, 0.2, 1.0))
	_draw_counter(Vector2(0, 134), Vector2(390, 88), Color(0.64, 0.5, 0.3, 1.0))
	_draw_counter(Vector2(-220, 4), Vector2(168, 98), Color(0.72, 0.56, 0.34, 1.0))
	_draw_counter(Vector2(220, 4), Vector2(168, 98), Color(0.72, 0.56, 0.34, 1.0))
	_draw_counter(Vector2(-240, -220), Vector2(232, 66), Color(0.74, 0.6, 0.38, 1.0))
	_draw_counter(Vector2(16, -36), Vector2(234, 66), Color(0.74, 0.6, 0.38, 1.0))
	_draw_counter(Vector2(-40, -324), Vector2(262, 56), Color(0.62, 0.48, 0.28, 1.0))
	_draw_shrub_row(Vector2(-440, 322), 5, 72.0, Color(0.4, 0.66, 0.4, 1.0))
	_draw_shrub_row(Vector2(404, 322), 4, 72.0, Color(0.4, 0.66, 0.4, 1.0))
	_draw_light_pool(Vector2(0, -120), 120.0, Color(1.0, 0.94, 0.78, 0.05))


func _draw_bandit_house() -> void:
	var bg := Rect2(-820, -720, 1640, 1440)
	draw_rect(bg, Color(0.52, 0.66, 0.44, 1.0), true)
	_draw_ground_texture(bg, Color(0.52, 0.66, 0.44), "grass")
	_draw_path_textured(Rect2(-700, 236, 1400, 136), Color(0.76, 0.66, 0.52, 1.0))
	_draw_building(Vector2(56, -72), Vector2(590, 368), Color(0.92, 0.84, 0.68, 1.0), Color(0.6, 0.24, 0.18, 1.0))
	_draw_counter(Vector2(0, 86), Vector2(300, 96), Color(0.56, 0.4, 0.22, 1.0))
	_draw_counter(Vector2(76, -154), Vector2(196, 84), Color(0.54, 0.38, 0.24, 1.0))
	_draw_counter(Vector2(-194, 84), Vector2(108, 188), Color(0.52, 0.36, 0.2, 1.0))
	_draw_bed(Vector2(246, -182), Vector2(174, 70))
	_draw_tree_cluster([Vector2(-566, -268), Vector2(-660, -118), Vector2(648, 220)], 54.0, Color(0.2, 0.52, 0.3, 1.0))
	_draw_shrub_row(Vector2(-64, -352), 6, 76.0, Color(0.36, 0.66, 0.36, 1.0))


func _draw_market_house() -> void:
	var bg := Rect2(-820, -720, 1640, 1440)
	draw_rect(bg, Color(0.82, 0.76, 0.62, 1.0), true)
	_draw_ground_texture(bg, Color(0.82, 0.76, 0.62), "sand")
	_draw_plaza_tiled(Vector2(0, 102), Vector2(620, 276), Color(0.8, 0.74, 0.64, 1.0))
	_draw_building(Vector2(80, -188), Vector2(560, 324), Color(0.94, 0.86, 0.72, 1.0), Color(0.66, 0.26, 0.2, 1.0))
	_draw_market_stall(Vector2(-210, 54), Vector2(118, 80), Color(0.82, 0.4, 0.22, 1.0), Color(0.96, 0.88, 0.72, 1.0))
	_draw_market_stall(Vector2(0, 42), Vector2(118, 80), Color(0.24, 0.62, 0.7, 1.0), Color(0.86, 0.94, 1.0, 1.0))
	_draw_market_stall(Vector2(214, 54), Vector2(118, 80), Color(0.9, 0.6, 0.18, 1.0), Color(1.0, 0.92, 0.66, 1.0))
	_draw_counter(Vector2(-2, -88), Vector2(184, 80), Color(0.58, 0.42, 0.24, 1.0))
	_draw_bed(Vector2(172, -214), Vector2(154, 66))
	_draw_tree_cluster([Vector2(-644, -186), Vector2(648, -144), Vector2(-566, 244), Vector2(590, 272)], 50.0, Color(0.24, 0.56, 0.34, 1.0))
	_draw_pebble_scatter(Rect2(-200, 60, 400, 200), 12, Color(0.65, 0.58, 0.48))


func _draw_prison() -> void:
	var bg := Rect2(-820, -720, 1640, 1440)
	draw_rect(bg, Color(0.58, 0.5, 0.42, 1.0), true)
	_draw_ground_texture(bg, Color(0.58, 0.5, 0.42), "stone")
	_draw_plaza_tiled(Vector2(-18, 130), Vector2(566, 236), Color(0.48, 0.46, 0.44, 1.0))
	_draw_building(Vector2(186, -138), Vector2(360, 286), Color(0.7, 0.7, 0.72, 1.0), Color(0.4, 0.2, 0.16, 1.0))
	_draw_counter(Vector2(-10, 142), Vector2(334, 90), Color(0.36, 0.34, 0.32, 1.0))
	_draw_counter(Vector2(92, -126), Vector2(106, 206), Color(0.38, 0.36, 0.38, 1.0))
	_draw_counter(Vector2(322, -126), Vector2(106, 206), Color(0.38, 0.36, 0.38, 1.0))
	_draw_counter(Vector2(126, -300), Vector2(230, 60), Color(0.44, 0.4, 0.36, 1.0))
	_draw_barred_cell(Vector2(202, -126), Vector2(128, 154))
	_draw_watch_post(Vector2(-442, -228))
	_draw_watch_post(Vector2(562, -238))
	_draw_watch_post(Vector2(-430, 250))


func _draw_forge_hall() -> void:
	var bg := Rect2(-1040, -720, 2080, 1440)
	draw_rect(bg, Color(0.24, 0.18, 0.16, 1.0), true)
	_draw_ground_texture(bg, Color(0.24, 0.18, 0.16), "dark")
	_draw_plaza_tiled(Vector2(0, 42), Vector2(760, 452), Color(0.38, 0.32, 0.28, 1.0))
	_draw_forge_pool(Vector2(0, 12), Vector2(244, 148), Color(1.0, 0.52, 0.18, 1.0))
	_draw_light_pool(Vector2(0, 12), 160.0, Color(1.0, 0.6, 0.2, 0.06))
	_draw_counter(Vector2(-332, -96), Vector2(170, 98), Color(0.22, 0.24, 0.28, 1.0))
	_draw_counter(Vector2(332, -96), Vector2(170, 98), Color(0.22, 0.24, 0.28, 1.0))
	_draw_counter(Vector2(-332, 158), Vector2(180, 104), Color(0.34, 0.24, 0.16, 1.0))
	_draw_counter(Vector2(332, 158), Vector2(180, 104), Color(0.34, 0.24, 0.16, 1.0))
	_draw_column(Vector2(-530, -238), Vector2(54, 180), Color(0.18, 0.19, 0.24, 1.0))
	_draw_column(Vector2(530, -238), Vector2(54, 180), Color(0.18, 0.19, 0.24, 1.0))
	_draw_column(Vector2(-530, 246), Vector2(54, 180), Color(0.18, 0.19, 0.24, 1.0))
	_draw_column(Vector2(530, 246), Vector2(54, 180), Color(0.18, 0.19, 0.24, 1.0))


func _draw_arcane_vault() -> void:
	var bg := Rect2(-1040, -720, 2080, 1440)
	draw_rect(bg, Color(0.08, 0.14, 0.22, 1.0), true)
	_draw_ground_texture(bg, Color(0.08, 0.14, 0.22), "dark")
	_draw_plaza_tiled(Vector2(0, 72), Vector2(760, 462), Color(0.14, 0.22, 0.32, 1.0))
	_draw_rune_ring(Vector2(0, -42), 186.0, Color(0.36, 0.88, 1.0, 1.0), Color(0.36, 0.88, 1.0, 0.06))
	_draw_light_pool(Vector2(0, -42), 200.0, Color(0.36, 0.88, 1.0, 0.04))
	_draw_counter(Vector2(0, 210), Vector2(240, 96), Color(0.22, 0.3, 0.38, 1.0))
	_draw_column(Vector2(-348, -184), Vector2(60, 188), Color(0.2, 0.26, 0.36, 1.0))
	_draw_column(Vector2(348, -184), Vector2(60, 188), Color(0.2, 0.26, 0.36, 1.0))
	_draw_column(Vector2(-348, 194), Vector2(60, 188), Color(0.2, 0.26, 0.36, 1.0))
	_draw_column(Vector2(348, 194), Vector2(60, 188), Color(0.2, 0.26, 0.36, 1.0))
	_draw_blob(Vector2(0, -42), Vector2(84, 84), Color(0.26, 0.86, 1.0, 0.1), Color(1, 1, 1, 0.12))


func _draw_iron_docks() -> void:
	var bg := Rect2(-1040, -720, 2080, 1440)
	draw_rect(bg, Color(0.14, 0.28, 0.4, 1.0), true)
	_draw_ground_texture(bg, Color(0.14, 0.28, 0.4), "water")
	_draw_blob(Vector2(-472, -32), Vector2(328, 240), Color(0.1, 0.22, 0.32, 1.0), Color(0.66, 0.86, 1.0, 0.1))
	_draw_blob(Vector2(484, 88), Vector2(248, 186), Color(0.1, 0.22, 0.32, 1.0), Color(0.66, 0.86, 1.0, 0.1))
	_draw_dock_lane(Rect2(-240, -560, 180, 1080), Color(0.48, 0.36, 0.22, 1.0))
	_draw_dock_lane(Rect2(-80, -120, 540, 160), Color(0.52, 0.38, 0.24, 1.0))
	_draw_dock_lane(Rect2(210, -420, 190, 760), Color(0.48, 0.36, 0.22, 1.0))
	_draw_crate(Vector2(-126, -268), Vector2(66, 66))
	_draw_crate(Vector2(-126, 172), Vector2(66, 66))
	_draw_crate(Vector2(314, -20), Vector2(66, 66))
	_draw_column(Vector2(272, -474), Vector2(34, 128), Color(0.32, 0.38, 0.46, 1.0))
	_draw_column(Vector2(272, 396), Vector2(34, 128), Color(0.32, 0.38, 0.46, 1.0))


func _draw_verdant_garden() -> void:
	var bg := Rect2(-1040, -720, 2080, 1440)
	draw_rect(bg, Color(0.66, 0.82, 0.56, 1.0), true)
	_draw_ground_texture(bg, Color(0.66, 0.82, 0.56), "grass")
	_draw_path_textured(Rect2(-720, -70, 1440, 140), Color(0.82, 0.76, 0.58, 1.0))
	_draw_path_textured(Rect2(-72, -560, 144, 1120), Color(0.82, 0.76, 0.58, 1.0))
	_draw_hedge_strip(Rect2(-622, -416, 1240, 76), Color(0.22, 0.5, 0.24, 1.0))
	_draw_hedge_strip(Rect2(-622, 332, 1240, 76), Color(0.22, 0.5, 0.24, 1.0))
	_draw_hedge_strip(Rect2(-620, -416, 76, 824), Color(0.22, 0.5, 0.24, 1.0))
	_draw_hedge_strip(Rect2(544, -416, 76, 824), Color(0.22, 0.5, 0.24, 1.0))
	_draw_blob(Vector2(0, -6), Vector2(130, 92), Color(0.36, 0.72, 0.9, 1.0), Color(0.76, 0.94, 1.0, 0.2))
	_draw_tree_cluster([Vector2(-420, -220), Vector2(410, -226), Vector2(-418, 210), Vector2(406, 226)], 52.0, Color(0.26, 0.6, 0.32, 1.0))
	_draw_flower_scatter(Rect2(-500, -350, 300, 200), 14, [Color(0.95, 0.82, 0.28), Color(0.85, 0.35, 0.5), Color(0.72, 0.62, 0.92), Color(0.95, 0.95, 0.72)])
	_draw_flower_scatter(Rect2(200, 100, 300, 200), 12, [Color(0.95, 0.42, 0.42), Color(0.85, 0.75, 0.35)])


func _draw_dune_courtyard() -> void:
	var bg := Rect2(-1040, -720, 2080, 1440)
	draw_rect(bg, Color(0.8, 0.72, 0.52, 1.0), true)
	_draw_ground_texture(bg, Color(0.8, 0.72, 0.52), "sand")
	_draw_plaza_tiled(Vector2(0, 44), Vector2(860, 500), Color(0.76, 0.66, 0.5, 1.0))
	_draw_path_textured(Rect2(-240, -560, 480, 1120), Color(0.84, 0.74, 0.58, 1.0))
	_draw_column(Vector2(-326, -180), Vector2(72, 188), Color(0.7, 0.58, 0.4, 1.0))
	_draw_column(Vector2(326, -180), Vector2(72, 188), Color(0.7, 0.58, 0.4, 1.0))
	_draw_column(Vector2(-326, 220), Vector2(72, 188), Color(0.7, 0.58, 0.4, 1.0))
	_draw_column(Vector2(326, 220), Vector2(72, 188), Color(0.7, 0.58, 0.4, 1.0))
	_draw_rune_ring(Vector2(0, 36), 112.0, Color(0.9, 0.58, 0.22, 0.75), Color(1.0, 0.8, 0.44, 0.06))
	_draw_pebble_scatter(Rect2(-400, -300, 800, 600), 20, Color(0.65, 0.56, 0.42))


func _draw_ashen_keep() -> void:
	var bg := Rect2(-1040, -720, 2080, 1440)
	draw_rect(bg, Color(0.18, 0.12, 0.12, 1.0), true)
	_draw_ground_texture(bg, Color(0.18, 0.12, 0.12), "dark")
	_draw_plaza_tiled(Vector2(0, 62), Vector2(860, 520), Color(0.32, 0.24, 0.24, 1.0))
	_draw_lava_crack(PackedVector2Array([Vector2(-420, -220), Vector2(-180, -120), Vector2(0, 12), Vector2(142, 110), Vector2(384, 230)]))
	_draw_lava_crack(PackedVector2Array([Vector2(410, -260), Vector2(208, -110), Vector2(82, 20), Vector2(-24, 148), Vector2(-168, 294)]))
	_draw_light_pool(Vector2(0, 50), 180.0, Color(1.0, 0.4, 0.15, 0.04))
	_draw_column(Vector2(-344, -202), Vector2(72, 184), Color(0.24, 0.24, 0.28, 1.0))
	_draw_column(Vector2(344, -202), Vector2(72, 184), Color(0.24, 0.24, 0.28, 1.0))
	_draw_column(Vector2(0, -270), Vector2(200, 84), Color(0.28, 0.22, 0.2, 1.0))


func _draw_obsidian_hall() -> void:
	var bg := Rect2(-1040, -720, 2080, 1440)
	draw_rect(bg, Color(0.14, 0.12, 0.2, 1.0), true)
	_draw_ground_texture(bg, Color(0.14, 0.12, 0.2), "dark")
	_draw_plaza_tiled(Vector2(0, 48), Vector2(860, 520), Color(0.2, 0.18, 0.26, 1.0))
	_draw_rune_ring(Vector2(0, -34), 154.0, Color(0.72, 0.4, 1.0, 0.85), Color(0.56, 0.14, 1.0, 0.08))
	_draw_light_pool(Vector2(0, -34), 170.0, Color(0.62, 0.3, 1.0, 0.04))
	_draw_column(Vector2(-362, -216), Vector2(82, 204), Color(0.16, 0.16, 0.22, 1.0))
	_draw_column(Vector2(362, -216), Vector2(82, 204), Color(0.16, 0.16, 0.22, 1.0))
	_draw_column(Vector2(-362, 222), Vector2(82, 204), Color(0.16, 0.16, 0.22, 1.0))
	_draw_column(Vector2(362, 222), Vector2(82, 204), Color(0.16, 0.16, 0.22, 1.0))


func _draw_frost_labyrinth() -> void:
	var bg := Rect2(-1040, -720, 2080, 1440)
	draw_rect(bg, Color(0.74, 0.88, 0.96, 1.0), true)
	_draw_ground_texture(bg, Color(0.74, 0.88, 0.96), "ice")
	_draw_path_textured(Rect2(-700, -84, 1400, 168), Color(0.88, 0.94, 1.0, 1.0))
	_draw_path_textured(Rect2(-84, -560, 168, 1120), Color(0.88, 0.94, 1.0, 1.0))
	_draw_ice_wall(Rect2(-620, -420, 180, 620))
	_draw_ice_wall(Rect2(250, -200, 180, 620))
	_draw_ice_wall(Rect2(-120, 180, 340, 160))
	_draw_ice_shard(Vector2(-352, -258), 92.0)
	_draw_ice_shard(Vector2(414, -306), 84.0)
	_draw_ice_shard(Vector2(356, 262), 94.0)


func _draw_storm_sanctum() -> void:
	var bg := Rect2(-1040, -720, 2080, 1440)
	draw_rect(bg, Color(0.16, 0.2, 0.28, 1.0), true)
	_draw_ground_texture(bg, Color(0.16, 0.2, 0.28), "dark")
	_draw_blob(Vector2(0, -420), Vector2(680, 220), Color(0.22, 0.26, 0.34, 1.0), Color(1, 1, 1, 0.03))
	_draw_plaza_tiled(Vector2(0, 72), Vector2(860, 520), Color(0.28, 0.32, 0.44, 1.0))
	_draw_storm_arc(PackedVector2Array([Vector2(-270, -244), Vector2(-140, -134), Vector2(-190, 2), Vector2(-32, 78), Vector2(-86, 236)]))
	_draw_storm_arc(PackedVector2Array([Vector2(284, -224), Vector2(168, -82), Vector2(216, 18), Vector2(72, 92), Vector2(112, 248)]))
	_draw_rune_ring(Vector2(0, -12), 132.0, Color(0.64, 0.84, 1.0, 0.85), Color(0.54, 0.72, 1.0, 0.06))
	_draw_light_pool(Vector2(0, -12), 150.0, Color(0.64, 0.84, 1.0, 0.04))


func _draw_void_bastion() -> void:
	var bg := Rect2(-1040, -720, 2080, 1440)
	draw_rect(bg, Color(0.06, 0.06, 0.1, 1.0), true)
	_draw_ground_texture(bg, Color(0.06, 0.06, 0.1), "dark")
	_draw_blob(Vector2(0, 0), Vector2(720, 520), Color(0.1, 0.08, 0.16, 1.0), Color(0.36, 0.26, 0.64, 0.06))
	_draw_plaza_tiled(Vector2(0, 62), Vector2(760, 420), Color(0.18, 0.14, 0.28, 1.0))
	_draw_counter(Vector2(0, 62), Vector2(260, 120), Color(0.28, 0.16, 0.4, 1.0))
	_draw_rune_ring(Vector2(0, -112), 144.0, Color(0.72, 0.46, 1.0, 0.85), Color(0.66, 0.26, 1.0, 0.06))
	_draw_light_pool(Vector2(0, -112), 160.0, Color(0.66, 0.26, 1.0, 0.04))
	_draw_column(Vector2(-320, 202), Vector2(72, 184), Color(0.16, 0.14, 0.24, 1.0))
	_draw_column(Vector2(320, 202), Vector2(72, 184), Color(0.16, 0.14, 0.24, 1.0))


func _draw_sky_keep() -> void:
	var bg := Rect2(-1040, -720, 2080, 1440)
	draw_rect(bg, Color(0.64, 0.82, 0.96, 1.0), true)
	_draw_ground_texture(bg, Color(0.64, 0.82, 0.96), "ice")
	_draw_cloud(Vector2(-540, -312), Vector2(210, 88), Color(1, 1, 1, 0.58))
	_draw_cloud(Vector2(568, -276), Vector2(196, 82), Color(1, 1, 1, 0.5))
	_draw_cloud(Vector2(-600, 280), Vector2(184, 76), Color(1, 1, 1, 0.36))
	_draw_cloud(Vector2(612, 242), Vector2(220, 84), Color(1, 1, 1, 0.36))
	_draw_plaza_tiled(Vector2(0, 108), Vector2(820, 440), Color(0.84, 0.86, 0.92, 1.0))
	_draw_column(Vector2(-302, -76), Vector2(74, 220), Color(0.82, 0.78, 0.7, 1.0))
	_draw_column(Vector2(302, -76), Vector2(74, 220), Color(0.82, 0.78, 0.7, 1.0))
	_draw_counter(Vector2(0, -120), Vector2(230, 82), Color(0.82, 0.7, 0.38, 1.0))
	_draw_rune_ring(Vector2(0, 18), 142.0, Color(0.56, 0.82, 1.0, 0.8), Color(0.56, 0.82, 1.0, 0.06))
	_draw_light_pool(Vector2(0, 18), 160.0, Color(0.56, 0.82, 1.0, 0.04))


func _draw_tavern_interior() -> void:
	var bg := Rect2(-820, -720, 1640, 1440)
	draw_rect(bg, Color(0.32, 0.22, 0.16, 1.0), true)
	_draw_ground_texture(bg, Color(0.32, 0.22, 0.16), "dark")
	_draw_plaza_tiled(Vector2(0, 42), Vector2(620, 400), Color(0.42, 0.3, 0.2, 1.0))
	_draw_counter(Vector2(0, -180), Vector2(340, 80), Color(0.48, 0.32, 0.18, 1.0))
	_draw_counter(Vector2(-240, 60), Vector2(120, 120), Color(0.52, 0.36, 0.2, 1.0))
	_draw_counter(Vector2(240, 60), Vector2(120, 120), Color(0.52, 0.36, 0.2, 1.0))
	_draw_counter(Vector2(0, 160), Vector2(140, 100), Color(0.52, 0.36, 0.2, 1.0))
	_draw_light_pool(Vector2(0, 0), 140.0, Color(1.0, 0.82, 0.5, 0.06))
	_draw_column(Vector2(-280, -160), Vector2(40, 140), Color(0.36, 0.24, 0.14, 1.0))
	_draw_column(Vector2(280, -160), Vector2(40, 140), Color(0.36, 0.24, 0.14, 1.0))


func _draw_store_interior() -> void:
	var bg := Rect2(-820, -720, 1640, 1440)
	draw_rect(bg, Color(0.78, 0.72, 0.6, 1.0), true)
	_draw_ground_texture(bg, Color(0.78, 0.72, 0.6), "stone")
	_draw_plaza_tiled(Vector2(0, 42), Vector2(620, 400), Color(0.74, 0.68, 0.56, 1.0))
	_draw_counter(Vector2(0, -200), Vector2(400, 70), Color(0.56, 0.42, 0.26, 1.0))
	_draw_counter(Vector2(-220, 20), Vector2(140, 100), Color(0.6, 0.46, 0.28, 1.0))
	_draw_counter(Vector2(220, 20), Vector2(140, 100), Color(0.6, 0.46, 0.28, 1.0))
	_draw_counter(Vector2(0, 140), Vector2(180, 80), Color(0.58, 0.44, 0.26, 1.0))
	_draw_light_pool(Vector2(0, -40), 120.0, Color(1.0, 0.94, 0.72, 0.05))


func _draw_house_interior() -> void:
	var bg := Rect2(-820, -720, 1640, 1440)
	draw_rect(bg, Color(0.72, 0.64, 0.52, 1.0), true)
	_draw_ground_texture(bg, Color(0.72, 0.64, 0.52), "stone")
	_draw_plaza_tiled(Vector2(0, 42), Vector2(560, 380), Color(0.68, 0.6, 0.48, 1.0))
	_draw_counter(Vector2(-180, -120), Vector2(160, 100), Color(0.54, 0.4, 0.24, 1.0))
	_draw_counter(Vector2(200, 80), Vector2(120, 80), Color(0.56, 0.42, 0.26, 1.0))
	_draw_bed(Vector2(180, -140), Vector2(160, 66))
	_draw_light_pool(Vector2(0, 0), 110.0, Color(1.0, 0.9, 0.66, 0.05))


func _draw_bank_interior() -> void:
	var bg := Rect2(-820, -720, 1640, 1440)
	draw_rect(bg, Color(0.84, 0.84, 0.8, 1.0), true)
	_draw_ground_texture(bg, Color(0.84, 0.84, 0.8), "stone")
	_draw_plaza_tiled(Vector2(0, 42), Vector2(580, 380), Color(0.8, 0.78, 0.72, 1.0))
	_draw_counter(Vector2(0, -180), Vector2(380, 70), Color(0.64, 0.5, 0.3, 1.0))
	_draw_counter(Vector2(-200, 40), Vector2(140, 100), Color(0.58, 0.48, 0.32, 1.0))
	_draw_counter(Vector2(200, 40), Vector2(140, 100), Color(0.58, 0.48, 0.32, 1.0))
	_draw_column(Vector2(-260, -160), Vector2(36, 120), Color(0.74, 0.74, 0.7, 1.0))
	_draw_column(Vector2(260, -160), Vector2(36, 120), Color(0.74, 0.74, 0.7, 1.0))
	_draw_light_pool(Vector2(0, -40), 130.0, Color(1.0, 0.96, 0.8, 0.05))


func _draw_jeweler_interior() -> void:
	var bg := Rect2(-820, -720, 1640, 1440)
	draw_rect(bg, Color(0.62, 0.52, 0.38, 1.0), true)
	_draw_ground_texture(bg, Color(0.62, 0.52, 0.38), "sand")
	_draw_plaza_tiled(Vector2(0, 42), Vector2(560, 380), Color(0.58, 0.48, 0.34, 1.0))
	_draw_counter(Vector2(0, -180), Vector2(320, 70), Color(0.44, 0.32, 0.2, 1.0))
	_draw_counter(Vector2(-200, 40), Vector2(120, 100), Color(0.46, 0.34, 0.22, 1.0))
	_draw_counter(Vector2(200, 40), Vector2(120, 100), Color(0.46, 0.34, 0.22, 1.0))
	_draw_light_pool(Vector2(0, -80), 100.0, Color(1.0, 0.88, 0.5, 0.06))
	_draw_light_pool(Vector2(-200, 40), 60.0, Color(1.0, 0.82, 0.4, 0.04))
	_draw_light_pool(Vector2(200, 40), 60.0, Color(1.0, 0.82, 0.4, 0.04))


# ============================================================
# GROUND TEXTURE SYSTEM
# ============================================================

func _draw_ground_texture(rect: Rect2, base_color: Color, biome: String) -> void:
	# Large color variation patches for natural look
	for _i in 10:
		var px := _rng.randf_range(rect.position.x + 60, rect.end.x - 60)
		var py := _rng.randf_range(rect.position.y + 60, rect.end.y - 60)
		var rx := _rng.randf_range(60, 240)
		var ry := _rng.randf_range(40, 160)
		var tint := base_color.lightened(_rng.randf_range(-0.06, 0.06))
		tint.a = _rng.randf_range(0.05, 0.14)
		_draw_blob(Vector2(px, py), Vector2(rx, ry), tint, Color(0, 0, 0, 0))

	# Medium dithering patches
	for _i in 8:
		var px := _rng.randf_range(rect.position.x + 40, rect.end.x - 40)
		var py := _rng.randf_range(rect.position.y + 40, rect.end.y - 40)
		var rx := _rng.randf_range(30, 80)
		var ry := _rng.randf_range(20, 60)
		var shade := base_color.darkened(_rng.randf_range(0.02, 0.08))
		shade.a = _rng.randf_range(0.06, 0.15)
		_draw_blob(Vector2(px, py), Vector2(rx, ry), shade, Color(0, 0, 0, 0))

	# Dense scatter dots for texture
	var dot_count := 90
	for _i in dot_count:
		var dx := _rng.randf_range(rect.position.x + 16, rect.end.x - 16)
		var dy := _rng.randf_range(rect.position.y + 16, rect.end.y - 16)
		var dr := _rng.randf_range(1.2, 3.5)
		var dc := base_color.darkened(_rng.randf_range(0.03, 0.14))
		dc.a = _rng.randf_range(0.1, 0.28)
		draw_circle(Vector2(dx, dy), dr, dc)

	# Light speckles
	for _i in 30:
		var lx := _rng.randf_range(rect.position.x + 20, rect.end.x - 20)
		var ly := _rng.randf_range(rect.position.y + 20, rect.end.y - 20)
		var lr := _rng.randf_range(0.8, 2.0)
		var lc := base_color.lightened(_rng.randf_range(0.06, 0.14))
		lc.a = _rng.randf_range(0.1, 0.22)
		draw_circle(Vector2(lx, ly), lr, lc)

	match biome:
		"grass":
			_draw_grass_tufts(rect, base_color)
		"stone":
			_draw_stone_cracks(rect, base_color)
		"sand":
			_draw_sand_ripples(rect, base_color)
		"dark":
			_draw_dark_glow_spots(rect, base_color)
		"ice":
			_draw_frost_sparkles(rect, base_color)
		"water":
			_draw_water_ripple_arcs(rect, base_color)


func _draw_grass_tufts(rect: Rect2, base_color: Color) -> void:
	# Dense grass blade clusters
	for _i in 55:
		var gx := _rng.randf_range(rect.position.x + 20, rect.end.x - 20)
		var gy := _rng.randf_range(rect.position.y + 20, rect.end.y - 20)
		var gc := base_color.darkened(_rng.randf_range(0.04, 0.18))
		var blade_count := _rng.randi_range(3, 6)
		for b in blade_count:
			var angle := _rng.randf_range(-0.5, 0.5) + float(b) * 0.25 - 0.4
			var blade_len := _rng.randf_range(5, 13)
			var width := _rng.randf_range(1.2, 2.2)
			var base_pt := Vector2(gx, gy)
			var tip := base_pt + Vector2(sin(angle), -cos(angle)) * blade_len
			draw_line(base_pt, tip, gc, width, true)
			# Highlight on some blades
			if _rng.randf() > 0.6:
				var hl := gc.lightened(0.15)
				hl.a = 0.5
				draw_line(base_pt, base_pt + (tip - base_pt) * 0.5, hl, width * 0.6, true)
	# Small clover-like patches
	for _i in 12:
		var cx := _rng.randf_range(rect.position.x + 40, rect.end.x - 40)
		var cy := _rng.randf_range(rect.position.y + 40, rect.end.y - 40)
		var clover_c := base_color.darkened(0.06)
		clover_c.a = 0.4
		for p in 3:
			var a := TAU * float(p) / 3.0 + _rng.randf_range(-0.3, 0.3)
			draw_circle(Vector2(cx, cy) + Vector2.from_angle(a) * 3.0, 2.0, clover_c)


func _draw_stone_cracks(rect: Rect2, base_color: Color) -> void:
	# Main cracks
	for _i in 18:
		var sx := _rng.randf_range(rect.position.x + 30, rect.end.x - 30)
		var sy := _rng.randf_range(rect.position.y + 30, rect.end.y - 30)
		var crack_color := base_color.darkened(0.12)
		crack_color.a = 0.35
		var points := PackedVector2Array()
		points.append(Vector2(sx, sy))
		for _s in _rng.randi_range(2, 5):
			sx += _rng.randf_range(-24, 24)
			sy += _rng.randf_range(-18, 18)
			points.append(Vector2(sx, sy))
		draw_polyline(points, crack_color, _rng.randf_range(1.0, 2.5), true)
		# Branching cracks
		if points.size() > 2 and _rng.randf() > 0.5:
			var branch_start: Vector2 = points[1]
			var bx := branch_start.x + _rng.randf_range(-16, 16)
			var by := branch_start.y + _rng.randf_range(-12, 12)
			draw_line(branch_start, Vector2(bx, by), crack_color, 1.0, true)
	# Stone grain dots
	for _i in 20:
		var gx := _rng.randf_range(rect.position.x + 20, rect.end.x - 20)
		var gy := _rng.randf_range(rect.position.y + 20, rect.end.y - 20)
		var gc := base_color.darkened(0.06)
		gc.a = 0.2
		draw_circle(Vector2(gx, gy), _rng.randf_range(4, 10), gc)


func _draw_sand_ripples(rect: Rect2, base_color: Color) -> void:
	for _i in 10:
		var sx := _rng.randf_range(rect.position.x + 60, rect.end.x - 60)
		var sy := _rng.randf_range(rect.position.y + 60, rect.end.y - 60)
		var ripple_color := base_color.lightened(0.06)
		ripple_color.a = 0.2
		var arc_radius := _rng.randf_range(30, 60)
		var start_angle := _rng.randf_range(0, TAU)
		draw_arc(Vector2(sx, sy), arc_radius, start_angle, start_angle + _rng.randf_range(0.8, 1.6), 12, ripple_color, 1.5, true)


func _draw_dark_glow_spots(rect: Rect2, base_color: Color) -> void:
	for _i in 6:
		var gx := _rng.randf_range(rect.position.x + 80, rect.end.x - 80)
		var gy := _rng.randf_range(rect.position.y + 80, rect.end.y - 80)
		var glow_color := base_color.lightened(0.08)
		glow_color.a = 0.04
		var gr := _rng.randf_range(40, 90)
		_draw_blob(Vector2(gx, gy), Vector2(gr, gr * 0.7), glow_color, Color(0, 0, 0, 0))


func _draw_frost_sparkles(rect: Rect2, _base_color: Color) -> void:
	for _i in 18:
		var fx := _rng.randf_range(rect.position.x + 30, rect.end.x - 30)
		var fy := _rng.randf_range(rect.position.y + 30, rect.end.y - 30)
		var sparkle_size := _rng.randf_range(3, 7)
		var sparkle_color := Color(1, 1, 1, _rng.randf_range(0.12, 0.28))
		for ray in 4:
			var angle := TAU * float(ray) / 4.0 + PI * 0.25
			var tip := Vector2(fx, fy) + Vector2.from_angle(angle) * sparkle_size
			draw_line(Vector2(fx, fy), tip, sparkle_color, 1.0, true)


func _draw_water_ripple_arcs(rect: Rect2, base_color: Color) -> void:
	for _i in 8:
		var wx := _rng.randf_range(rect.position.x + 60, rect.end.x - 60)
		var wy := _rng.randf_range(rect.position.y + 60, rect.end.y - 60)
		var ripple_color := base_color.lightened(0.1)
		ripple_color.a = 0.18
		var r1 := _rng.randf_range(20, 50)
		draw_arc(Vector2(wx, wy), r1, 0, PI, 10, ripple_color, 1.0, true)
		draw_arc(Vector2(wx, wy), r1 * 0.6, PI * 0.3, PI * 0.8, 8, ripple_color, 1.0, true)


# ============================================================
# DETAIL SCATTER HELPERS
# ============================================================

func _draw_flower_scatter(rect: Rect2, count: int, petal_colors: Array) -> void:
	for _i in count:
		var fx := _rng.randf_range(rect.position.x, rect.end.x)
		var fy := _rng.randf_range(rect.position.y, rect.end.y)
		var color_index := _rng.randi_range(0, petal_colors.size() - 1)
		var petal_color: Color = petal_colors[color_index]
		# Stem
		var stem_color := Color(0.28, 0.52, 0.22, 0.6)
		draw_line(Vector2(fx, fy + 3), Vector2(fx + _rng.randf_range(-2, 2), fy + 9), stem_color, 1.2, true)
		# Petals (5 for more detail)
		var petal_count := _rng.randi_range(4, 6)
		for p in petal_count:
			var angle := TAU * float(p) / float(petal_count) + _rng.randf_range(-0.2, 0.2)
			var petal_dist := _rng.randf_range(3.0, 4.5)
			var petal_pos := Vector2(fx, fy) + Vector2.from_angle(angle) * petal_dist
			var petal_r := _rng.randf_range(2.0, 3.0)
			draw_circle(petal_pos, petal_r, petal_color)
			# Petal highlight
			draw_circle(petal_pos + Vector2(-0.5, -0.5), petal_r * 0.4, petal_color.lightened(0.2))
		# Center
		draw_circle(Vector2(fx, fy), 2.0, Color(0.98, 0.92, 0.4, 1.0))
		draw_circle(Vector2(fx - 0.5, fy - 0.5), 1.0, Color(1.0, 0.98, 0.7, 0.7))


func _draw_pebble_scatter(rect: Rect2, count: int, base_color: Color) -> void:
	for _i in count:
		var px := _rng.randf_range(rect.position.x, rect.end.x)
		var py := _rng.randf_range(rect.position.y, rect.end.y)
		var pr := _rng.randf_range(2.5, 5.0)
		var pc := base_color.darkened(_rng.randf_range(-0.06, 0.1))
		draw_circle(Vector2(px, py), pr, pc)
		draw_arc(Vector2(px, py), pr, 0, TAU, 8, OUTLINE_COLOR, 1.0, true)


func _draw_light_pool(center: Vector2, radius: float, color: Color) -> void:
	for i in 6:
		var t := float(i) / 5.0
		var ring_radius := radius * (1.0 - t * 0.55)
		var ring_color := color
		ring_color.a = color.a * (0.2 + t * 0.8)
		_draw_blob(center, Vector2(ring_radius, ring_radius * 0.72), ring_color, Color(0, 0, 0, 0))
	# Bright center spot
	var bright := color
	bright.a = color.a * 1.5
	_draw_blob(center, Vector2(radius * 0.2, radius * 0.15), bright, Color(0, 0, 0, 0))


func _draw_water_detail(center: Vector2, radius: Vector2) -> void:
	for _i in 4:
		var wx := center.x + _rng.randf_range(-radius.x * 0.5, radius.x * 0.5)
		var wy := center.y + _rng.randf_range(-radius.y * 0.4, radius.y * 0.4)
		var wr := _rng.randf_range(12, 28)
		var wc := Color(0.82, 0.94, 1.0, 0.15)
		draw_arc(Vector2(wx, wy), wr, 0, PI, 8, wc, 1.0, true)


# ============================================================
# ENHANCED BUILDING & STRUCTURE HELPERS
# ============================================================

func _draw_building(center: Vector2, size: Vector2, wall_color: Color, roof_color: Color) -> void:
	var wall_rect := Rect2(center - Vector2(size.x * 0.5, size.y * 0.36), Vector2(size.x, size.y * 0.72))
	var roof_points := PackedVector2Array([
		Vector2(center.x - size.x * 0.58, center.y - size.y * 0.12),
		Vector2(center.x, center.y - size.y * 0.58),
		Vector2(center.x + size.x * 0.58, center.y - size.y * 0.12),
		Vector2(center.x + size.x * 0.48, center.y + size.y * 0.02),
		Vector2(center.x - size.x * 0.48, center.y + size.y * 0.02),
	])
	# Deeper ground shadow
	draw_rect(Rect2(wall_rect.position + Vector2(8, 18), wall_rect.size + Vector2(4, 4)), Color(0, 0, 0, 0.1), true)
	draw_rect(Rect2(wall_rect.position + Vector2(4, 10), wall_rect.size), Color(0, 0, 0, 0.06), true)
	# Walls
	draw_rect(wall_rect, wall_color, true)
	# Wall brick/plaster texture
	var brick_color := wall_color.darkened(0.04)
	brick_color.a = 0.25
	var brick_y := wall_rect.position.y + 16.0
	var row := 0
	while brick_y < wall_rect.end.y - 8:
		var brick_x := wall_rect.position.x + 8.0 + (16.0 if row % 2 == 1 else 0.0)
		while brick_x < wall_rect.end.x - 8:
			draw_line(Vector2(brick_x, brick_y), Vector2(brick_x, brick_y + 12), brick_color, 1.0, true)
			brick_x += 32.0
		draw_line(Vector2(wall_rect.position.x + 6, brick_y), Vector2(wall_rect.end.x - 6, brick_y), brick_color, 1.0, true)
		brick_y += 14.0
		row += 1
	# Wall weathering spots
	for _i in 4:
		var wx := _rng.randf_range(wall_rect.position.x + 12, wall_rect.end.x - 12)
		var wy := _rng.randf_range(wall_rect.position.y + 12, wall_rect.end.y - 12)
		var wc := wall_color.darkened(0.06)
		wc.a = 0.12
		draw_circle(Vector2(wx, wy), _rng.randf_range(8, 18), wc)
	draw_rect(wall_rect, OUTLINE_COLOR, false, 4.0)
	# Foundation strip
	var foundation := Rect2(Vector2(wall_rect.position.x, wall_rect.end.y - 10), Vector2(wall_rect.size.x, 10))
	draw_rect(foundation, wall_color.darkened(0.12), true)
	# Roof
	_draw_polygon_with_outline(roof_points, roof_color, OUTLINE_COLOR, 4.0)
	# Roof tile lines
	var tile_color := roof_color.darkened(0.08)
	tile_color.a = 0.4
	for ti in 5:
		var t := float(ti + 1) / 6.0
		var left_pt := roof_points[0].lerp(roof_points[1], t)
		var right_pt := roof_points[2].lerp(roof_points[1], t)
		var line_left := left_pt.lerp(Vector2(center.x - size.x * 0.48, center.y + size.y * 0.02), 1.0 - t)
		var line_right := right_pt.lerp(Vector2(center.x + size.x * 0.48, center.y + size.y * 0.02), 1.0 - t)
		draw_line(line_left, Vector2(center.x, left_pt.y), tile_color, 1.0, true)
		draw_line(Vector2(center.x, right_pt.y), line_right, tile_color, 1.0, true)
	# Roof highlight
	var roof_hl := PackedVector2Array([
		Vector2(center.x - size.x * 0.44, center.y - size.y * 0.08),
		Vector2(center.x, center.y - size.y * 0.48),
		Vector2(center.x + size.x * 0.1, center.y - size.y * 0.38),
		Vector2(center.x - size.x * 0.32, center.y - size.y * 0.04),
	])
	_draw_polygon_with_outline(roof_hl, roof_color.lightened(0.08), Color(0, 0, 0, 0), 0.0)
	# Chimney
	var chimney_x := center.x + size.x * 0.22
	var chimney_top := center.y - size.y * 0.52
	var chimney_rect := Rect2(Vector2(chimney_x - 10, chimney_top), Vector2(20, 36))
	draw_rect(chimney_rect, Color(0.52, 0.36, 0.24, 1.0), true)
	draw_rect(chimney_rect, OUTLINE_COLOR, false, 3.0)
	var chimney_cap := Rect2(Vector2(chimney_x - 13, chimney_top - 4), Vector2(26, 6))
	draw_rect(chimney_cap, Color(0.44, 0.3, 0.2, 1.0), true)
	# Door with frame and step
	var door_rect := Rect2(center + Vector2(-20, size.y * 0.08), Vector2(40, size.y * 0.24))
	# Door frame
	draw_rect(door_rect.grow(4), Color(0.34, 0.2, 0.12, 1.0), true)
	draw_rect(door_rect, Color(0.48, 0.28, 0.16, 1.0), true)
	# Door panels
	var panel_color := Color(0.38, 0.22, 0.12, 0.5)
	draw_rect(Rect2(door_rect.position + Vector2(4, 4), Vector2(14, door_rect.size.y * 0.4)), panel_color, true)
	draw_rect(Rect2(door_rect.position + Vector2(22, 4), Vector2(14, door_rect.size.y * 0.4)), panel_color, true)
	draw_rect(door_rect, OUTLINE_COLOR, false, 3.0)
	# Door knob
	draw_circle(center + Vector2(12, size.y * 0.2), 3.0, Color(0.96, 0.72, 0.2, 1.0))
	draw_circle(center + Vector2(11.5, size.y * 0.195), 1.5, Color(1.0, 0.88, 0.5, 0.6))
	# Door step
	draw_rect(Rect2(center + Vector2(-26, size.y * 0.08 + door_rect.size.y), Vector2(52, 6)), Color(0.6, 0.56, 0.5, 1.0), true)
	# Windows with shutters
	var window_size := Vector2(42, 32)
	var left_w := Rect2(center + Vector2(-size.x * 0.28, -6) - window_size * 0.5, window_size)
	var right_w := Rect2(center + Vector2(size.x * 0.28, -6) - window_size * 0.5, window_size)
	_draw_window(left_w)
	_draw_window(right_w)
	# Hanging sign or lamp post
	if _rng.randf() > 0.4:
		var lamp_x := center.x - size.x * 0.38
		var lamp_y := center.y + size.y * 0.02
		draw_line(Vector2(lamp_x, lamp_y), Vector2(lamp_x - 16, lamp_y), Color(0.3, 0.22, 0.14, 0.8), 2.0, true)
		draw_circle(Vector2(lamp_x - 16, lamp_y + 6), 5.0, Color(1.0, 0.88, 0.4, 0.3))
		draw_circle(Vector2(lamp_x - 16, lamp_y + 6), 3.0, Color(1.0, 0.92, 0.6, 0.5))


func _draw_window(rect: Rect2) -> void:
	# Window sill
	draw_rect(Rect2(rect.position + Vector2(-4, rect.size.y - 2), Vector2(rect.size.x + 8, 6)), Color(0.58, 0.52, 0.44, 1.0), true)
	# Shutters
	var shutter_color := Color(0.36, 0.22, 0.14, 0.85)
	draw_rect(Rect2(rect.position + Vector2(-10, 0), Vector2(10, rect.size.y)), shutter_color, true)
	draw_rect(Rect2(rect.position + Vector2(rect.size.x, 0), Vector2(10, rect.size.y)), shutter_color, true)
	# Window glass with warm interior glow
	draw_rect(rect, Color(0.55, 0.75, 0.92, 1.0), true)
	# Warm light from inside
	draw_rect(rect.grow(-3), Color(1.0, 0.92, 0.65, 0.2), true)
	draw_rect(rect.grow(-6), Color(1.0, 0.88, 0.55, 0.15), true)
	draw_rect(rect, OUTLINE_COLOR, false, 3.0)
	# Window cross frame
	var cx := rect.position.x + rect.size.x * 0.5
	var cy := rect.position.y + rect.size.y * 0.5
	draw_line(Vector2(cx, rect.position.y + 1), Vector2(cx, rect.end.y - 1), Color(0.38, 0.28, 0.2, 0.85), 2.5, true)
	draw_line(Vector2(rect.position.x + 1, cy), Vector2(rect.end.x - 1, cy), Color(0.38, 0.28, 0.2, 0.85), 2.5, true)
	# Reflection highlight
	draw_line(Vector2(rect.position.x + 4, rect.position.y + 4), Vector2(rect.position.x + 14, rect.position.y + 4), Color(1, 1, 1, 0.35), 1.5, true)


func _draw_path_textured(rect: Rect2, fill_color: Color) -> void:
	draw_rect(rect, fill_color, true)
	# Worn edge blending into grass
	for _i in 14:
		var edge_x := rect.position.x + _rng.randf_range(0, rect.size.x)
		var edge_y: float
		if _rng.randf() > 0.5:
			edge_y = rect.position.y + _rng.randf_range(-5, 6)
		else:
			edge_y = rect.end.y + _rng.randf_range(-6, 5)
		draw_circle(Vector2(edge_x, edge_y), _rng.randf_range(3, 9), fill_color.darkened(0.05))
	# Cobblestone grid pattern
	var is_horizontal := rect.size.x > rect.size.y
	var stone_color := fill_color.darkened(0.06)
	stone_color.a = 0.35
	if is_horizontal:
		var sy := rect.position.y + 12.0
		var row := 0
		while sy < rect.end.y - 8:
			var sx := rect.position.x + 10.0 + (14.0 if row % 2 == 1 else 0.0)
			while sx < rect.end.x - 8:
				draw_line(Vector2(sx, sy - 4), Vector2(sx, sy + 4), stone_color, 1.0, true)
				sx += 28.0
			draw_line(Vector2(rect.position.x + 6, sy), Vector2(rect.end.x - 6, sy), stone_color, 1.0, true)
			sy += 14.0
			row += 1
	else:
		var sx := rect.position.x + 12.0
		var col := 0
		while sx < rect.end.x - 8:
			var sy := rect.position.y + 10.0 + (14.0 if col % 2 == 1 else 0.0)
			while sy < rect.end.y - 8:
				draw_line(Vector2(sx - 4, sy), Vector2(sx + 4, sy), stone_color, 1.0, true)
				sy += 28.0
			draw_line(Vector2(sx, rect.position.y + 6), Vector2(sx, rect.end.y - 6), stone_color, 1.0, true)
			sx += 14.0
			col += 1
	# Pebbles and dirt
	for _i in 10:
		var px := _rng.randf_range(rect.position.x + 6, rect.end.x - 6)
		var py := _rng.randf_range(rect.position.y + 6, rect.end.y - 6)
		draw_circle(Vector2(px, py), _rng.randf_range(1.5, 4.0), fill_color.darkened(_rng.randf_range(0.06, 0.14)))
	# Highlight streaks
	for _i in 3:
		var hx := _rng.randf_range(rect.position.x + 20, rect.end.x - 20)
		var hy := _rng.randf_range(rect.position.y + 4, rect.end.y - 4)
		var hl := fill_color.lightened(0.06)
		hl.a = 0.2
		if is_horizontal:
			draw_line(Vector2(hx, hy), Vector2(hx + _rng.randf_range(20, 60), hy), hl, 2.0, true)
		else:
			draw_line(Vector2(hx, hy), Vector2(hx, hy + _rng.randf_range(20, 60)), hl, 2.0, true)
	draw_rect(rect, OUTLINE_COLOR.lightened(0.06), false, 3.0)


func _draw_plaza_tiled(center: Vector2, size: Vector2, fill_color: Color) -> void:
	var rect := Rect2(center - size * 0.5, size)
	draw_rect(rect, fill_color, true)
	# Subtle color variation across tiles
	for _i in 6:
		var vx := _rng.randf_range(rect.position.x + 20, rect.end.x - 20)
		var vy := _rng.randf_range(rect.position.y + 20, rect.end.y - 20)
		var vc := fill_color.lightened(_rng.randf_range(-0.04, 0.04))
		vc.a = 0.12
		draw_circle(Vector2(vx, vy), _rng.randf_range(30, 70), vc)
	draw_rect(rect, Color(0.56, 0.5, 0.42, 0.8), false, 4.0)
	# Tile grid with slight randomness
	var tile_spacing := 34.0
	var line_color := fill_color.darkened(0.06)
	line_color.a = 0.45
	var y := rect.position.y + tile_spacing
	while y < rect.end.y:
		draw_line(Vector2(rect.position.x + 3, y), Vector2(rect.end.x - 3, y), line_color, 1.2, true)
		y += tile_spacing
	var x := rect.position.x + tile_spacing
	while x < rect.end.x:
		draw_line(Vector2(x, rect.position.y + 3), Vector2(x, rect.end.y - 3), line_color, 1.2, true)
		x += tile_spacing
	# Random chipped/worn tiles
	for _i in 8:
		var cx := _rng.randf_range(rect.position.x + 10, rect.end.x - 10)
		var cy := _rng.randf_range(rect.position.y + 10, rect.end.y - 10)
		var cc := fill_color.darkened(0.08)
		cc.a = 0.18
		draw_circle(Vector2(cx, cy), _rng.randf_range(4, 12), cc)


func _draw_market_stall(center: Vector2, size: Vector2, awning_color: Color, cloth_color: Color) -> void:
	# Support poles
	draw_rect(Rect2(center + Vector2(-size.x * 0.44, -size.y * 0.1), Vector2(6, size.y * 0.42)), Color(0.48, 0.32, 0.18, 1.0), true)
	draw_rect(Rect2(center + Vector2(size.x * 0.38, -size.y * 0.1), Vector2(6, size.y * 0.42)), Color(0.48, 0.32, 0.18, 1.0), true)
	# Stand counter
	var stand_rect := Rect2(center - Vector2(size.x * 0.5, size.y * 0.3), Vector2(size.x, size.y * 0.6))
	draw_rect(Rect2(stand_rect.position + Vector2(3, 5), stand_rect.size), Color(0, 0, 0, 0.06), true)
	draw_rect(stand_rect, Color(0.58, 0.42, 0.24, 1.0), true)
	# Wares on counter (small colored circles)
	for _i in 4:
		var wx := _rng.randf_range(stand_rect.position.x + 10, stand_rect.end.x - 10)
		var wy := _rng.randf_range(stand_rect.position.y + 6, stand_rect.end.y - 6)
		draw_circle(Vector2(wx, wy), _rng.randf_range(3, 6), cloth_color.darkened(0.1))
	draw_rect(stand_rect, OUTLINE_COLOR, false, 3.0)
	# Awning with scalloped edge
	var awning := PackedVector2Array([
		Vector2(center.x - size.x * 0.58, center.y - size.y * 0.1),
		Vector2(center.x + size.x * 0.58, center.y - size.y * 0.1),
		Vector2(center.x + size.x * 0.48, center.y - size.y * 0.48),
		Vector2(center.x - size.x * 0.48, center.y - size.y * 0.48),
	])
	_draw_polygon_with_outline(awning, awning_color, OUTLINE_COLOR, 3.0)
	# Awning stripes
	for stripe_index in range(-2, 3, 2):
		var stripe_rect := Rect2(center + Vector2(float(stripe_index) * 18.0 - 9.0, -size.y * 0.48), Vector2(18, size.y * 0.38))
		draw_rect(stripe_rect, cloth_color, true)
	# Scalloped bottom edge
	var scallop_y := center.y - size.y * 0.1
	var scallop_start := center.x - size.x * 0.54
	for si in 6:
		var sx := scallop_start + float(si) * size.x * 0.18
		draw_arc(Vector2(sx, scallop_y), 8.0, 0, PI, 6, awning_color.darkened(0.08), 2.0, true)


# ============================================================
# TREE SYSTEM (layered canopy)
# ============================================================

func _draw_tree_cluster(positions: Array, radius: float, canopy_color: Color) -> void:
	for position_variant in positions:
		var tree_position: Vector2 = position_variant
		_draw_tree(tree_position, radius, canopy_color)


func _draw_tree(center: Vector2, radius: float, canopy_color: Color) -> void:
	# Ground shadow (larger, softer)
	_draw_blob(center + Vector2(8, radius * 0.78), Vector2(radius * 0.82, radius * 0.42), Color(0, 0, 0, 0.08), Color(0, 0, 0, 0))
	_draw_blob(center + Vector2(4, radius * 0.7), Vector2(radius * 0.66, radius * 0.32), Color(0, 0, 0, 0.05), Color(0, 0, 0, 0))
	# Trunk with bark texture (tapered)
	var trunk_color := Color(0.42, 0.26, 0.14, 1.0)
	var trunk := PackedVector2Array([
		center + Vector2(-8, radius * 0.24),
		center + Vector2(-6, radius * 0.66),
		center + Vector2(6, radius * 0.66),
		center + Vector2(8, radius * 0.24),
	])
	_draw_polygon_with_outline(trunk, trunk_color, OUTLINE_COLOR, 3.0)
	# Bark lines
	var bark_dark := trunk_color.darkened(0.15)
	bark_dark.a = 0.5
	draw_line(center + Vector2(-3, radius * 0.28), center + Vector2(-2, radius * 0.55), bark_dark, 1.0, true)
	draw_line(center + Vector2(2, radius * 0.32), center + Vector2(3, radius * 0.58), bark_dark, 1.0, true)
	# Root bumps at base
	draw_circle(center + Vector2(-8, radius * 0.64), 4.0, trunk_color.darkened(0.06))
	draw_circle(center + Vector2(8, radius * 0.64), 4.0, trunk_color.darkened(0.06))
	# Back canopy (darker, larger)
	_draw_blob(center + Vector2(0, 8), Vector2(radius * 1.08, radius * 0.86), canopy_color.darkened(0.16), Color(0, 0, 0, 0))
	# Mid canopy layers
	_draw_blob(center + Vector2(radius * 0.2, 2), Vector2(radius * 0.7, radius * 0.58), canopy_color.darkened(0.06), Color(0, 0, 0, 0))
	_draw_blob(center + Vector2(-radius * 0.16, -4), Vector2(radius * 0.72, radius * 0.6), canopy_color.darkened(0.03), Color(0, 0, 0, 0))
	# Main canopy
	_draw_blob(center + Vector2(0, -4), Vector2(radius * 0.92, radius * 0.72), canopy_color, Color(1, 1, 1, 0.04))
	# Highlight canopy (sun-facing side)
	_draw_blob(center + Vector2(-radius * 0.2, -radius * 0.18), Vector2(radius * 0.42, radius * 0.34), canopy_color.lightened(0.12), Color(0, 0, 0, 0))
	# Leaf cluster bumps around edges
	for _i in 8:
		var angle := _rng.randf_range(0, TAU)
		var dist := _rng.randf_range(radius * 0.4, radius * 0.76)
		var bx := center.x + cos(angle) * dist
		var by := center.y + sin(angle) * dist * 0.7 - 4
		var br := _rng.randf_range(8, 16)
		var bc := canopy_color.lightened(_rng.randf_range(-0.08, 0.08))
		draw_circle(Vector2(bx, by), br, bc)
	# Inner leaf details
	for _i in 5:
		var dx := center.x + _rng.randf_range(-radius * 0.5, radius * 0.5)
		var dy := center.y + _rng.randf_range(-radius * 0.4, radius * 0.25)
		var ds := _rng.randf_range(3, 7)
		draw_circle(Vector2(dx, dy), ds, canopy_color.lightened(_rng.randf_range(0.02, 0.1)))


func _draw_shrub_row(start: Vector2, count: int, spacing: float, shrub_color: Color) -> void:
	for index in range(count):
		var center := start + Vector2(float(index) * spacing, 0)
		# Shadow
		_draw_blob(center + Vector2(3, 6), Vector2(34, 18), Color(0, 0, 0, 0.06), Color(0, 0, 0, 0))
		# Back layer
		_draw_blob(center + Vector2(0, 3), Vector2(38, 28), shrub_color.darkened(0.1), Color(0, 0, 0, 0))
		# Main shrub
		_draw_blob(center, Vector2(34, 24), shrub_color, Color(1, 1, 1, 0.04))
		# Highlight
		_draw_blob(center + Vector2(-6, -4), Vector2(16, 12), shrub_color.lightened(0.08), Color(0, 0, 0, 0))
		# Berry dots
		if _rng.randf() > 0.5:
			for _b in _rng.randi_range(2, 4):
				var bx := center.x + _rng.randf_range(-14, 14)
				var by := center.y + _rng.randf_range(-8, 8)
				draw_circle(Vector2(bx, by), 2.0, Color(0.85, 0.25, 0.25, 0.7))


# ============================================================
# MISC STRUCTURE HELPERS
# ============================================================

func _draw_field_patch(center: Vector2, size: Vector2, fill_color: Color) -> void:
	var rect := Rect2(center - size * 0.5, size)
	draw_rect(rect, fill_color, true)
	draw_rect(rect, OUTLINE_COLOR, false, 4.0)
	for row_index in range(5):
		var y := rect.position.y + 22.0 + float(row_index) * 34.0
		draw_line(Vector2(rect.position.x + 16.0, y), Vector2(rect.position.x + rect.size.x - 16.0, y), fill_color.darkened(0.08), 2.0, true)
	# Crop dots
	for _i in 8:
		var cx := _rng.randf_range(rect.position.x + 12, rect.end.x - 12)
		var cy := _rng.randf_range(rect.position.y + 10, rect.end.y - 10)
		draw_circle(Vector2(cx, cy), 2.0, fill_color.lightened(0.08))


func _draw_barn(center: Vector2, size: Vector2) -> void:
	_draw_building(center, size, Color(0.88, 0.52, 0.28, 1.0), Color(0.6, 0.2, 0.14, 1.0))
	var loft_rect := Rect2(center + Vector2(-34, -84), Vector2(68, 42))
	draw_rect(loft_rect, Color(0.56, 0.2, 0.12, 1.0), true)
	draw_rect(loft_rect, OUTLINE_COLOR, false, 3.0)


func _draw_fence_line(start: Vector2, post_count: int, spacing: float) -> void:
	for index in range(post_count):
		var x := start.x + float(index) * spacing
		var rect := Rect2(Vector2(x - 6, start.y - 16), Vector2(12, 32))
		draw_rect(rect, Color(0.58, 0.4, 0.22, 1.0), true)
	draw_line(start + Vector2(-12, -5), start + Vector2(float(post_count - 1) * spacing + 12, -5), Color(0.58, 0.4, 0.22, 1.0), 6.0, true)
	draw_line(start + Vector2(-12, 9), start + Vector2(float(post_count - 1) * spacing + 12, 9), Color(0.58, 0.4, 0.22, 1.0), 6.0, true)


func _draw_hay_bale(center: Vector2, size: Vector2) -> void:
	var rect := Rect2(center - size * 0.5, size)
	draw_rect(rect, Color(0.9, 0.74, 0.32, 1.0), true)
	draw_rect(rect, OUTLINE_COLOR, false, 3.0)
	for stripe_index in range(1, 3):
		var x := rect.position.x + float(stripe_index) * rect.size.x / 3.0
		draw_line(Vector2(x, rect.position.y + 4), Vector2(x, rect.position.y + rect.size.y - 4), Color(0.82, 0.64, 0.24, 1.0), 1.5, true)


func _draw_counter(center: Vector2, size: Vector2, fill_color: Color) -> void:
	var rect := Rect2(center - size * 0.5, size)
	# Shadow
	draw_rect(Rect2(rect.position + Vector2(5, 8), rect.size), Color(0, 0, 0, 0.1), true)
	draw_rect(Rect2(rect.position + Vector2(2, 4), rect.size), Color(0, 0, 0, 0.05), true)
	# Main body
	draw_rect(rect, fill_color, true)
	# Top surface highlight
	var top_strip := Rect2(rect.position, Vector2(rect.size.x, 6))
	draw_rect(top_strip, fill_color.lightened(0.1), true)
	# Wood grain lines
	var grain_color := fill_color.darkened(0.08)
	grain_color.a = 0.3
	for _i in 3:
		var gy := rect.position.y + _rng.randf_range(8, rect.size.y - 6)
		draw_line(Vector2(rect.position.x + 6, gy), Vector2(rect.end.x - 6, gy), grain_color, 1.0, true)
	draw_rect(rect, OUTLINE_COLOR, false, 4.0)


func _draw_forge_pool(center: Vector2, size: Vector2, fill_color: Color) -> void:
	var rect := Rect2(center - size * 0.5, size)
	draw_rect(rect, Color(0.12, 0.1, 0.08, 1.0), true)
	draw_rect(rect, OUTLINE_COLOR, false, 4.0)
	var molten := rect.grow_individual(-14, -14, -14, -14)
	draw_rect(molten, fill_color, true)
	draw_rect(molten, Color(1.0, 0.82, 0.42, 0.4), false, 3.0)


func _draw_column(center: Vector2, size: Vector2, fill_color: Color) -> void:
	var rect := Rect2(center - size * 0.5, size)
	# Shadow
	draw_rect(Rect2(rect.position + Vector2(5, 12), rect.size), Color(0, 0, 0, 0.08), true)
	# Column body
	draw_rect(rect, fill_color, true)
	# Fluting lines (vertical grooves)
	var flute_color := fill_color.darkened(0.08)
	flute_color.a = 0.3
	for fi in 3:
		var fx := rect.position.x + rect.size.x * (0.25 + float(fi) * 0.25)
		draw_line(Vector2(fx, rect.position.y + 8), Vector2(fx, rect.end.y - 8), flute_color, 1.5, true)
	# Highlight edge
	var hl := fill_color.lightened(0.1)
	hl.a = 0.4
	draw_line(Vector2(rect.position.x + 3, rect.position.y + 6), Vector2(rect.position.x + 3, rect.end.y - 6), hl, 2.0, true)
	draw_rect(rect, OUTLINE_COLOR, false, 4.0)
	# Capital (top cap)
	var cap_rect := Rect2(rect.position + Vector2(-10, -14), Vector2(rect.size.x + 20, 22))
	draw_rect(cap_rect, fill_color.lightened(0.06), true)
	draw_rect(cap_rect, OUTLINE_COLOR, false, 3.0)
	# Base pedestal
	var base_rect := Rect2(Vector2(rect.position.x - 6, rect.end.y - 6), Vector2(rect.size.x + 12, 12))
	draw_rect(base_rect, fill_color.darkened(0.04), true)
	draw_rect(base_rect, OUTLINE_COLOR, false, 2.0)


func _draw_rune_ring(center: Vector2, radius: float, line_color: Color, glow_color: Color) -> void:
	_draw_blob(center, Vector2(radius + 24, radius + 24), glow_color, Color(0, 0, 0, 0))
	draw_arc(center, radius, 0.0, TAU, 48, line_color, 5.0, true)
	for index in 8:
		var angle := TAU * float(index) / 8.0
		var glyph_center := center + Vector2.RIGHT.rotated(angle) * radius
		var glyph_rect := Rect2(glyph_center - Vector2(9, 9), Vector2(18, 18))
		draw_rect(glyph_rect, line_color, true)


func _draw_dock_lane(rect: Rect2, fill_color: Color) -> void:
	draw_rect(rect, fill_color, true)
	draw_rect(rect, OUTLINE_COLOR, false, 4.0)
	for index in range(1, 6):
		var y := rect.position.y + float(index) * rect.size.y / 6.0
		draw_line(Vector2(rect.position.x + 10, y), Vector2(rect.position.x + rect.size.x - 10, y), fill_color.darkened(0.12), 2.0, true)


func _draw_crate(center: Vector2, size: Vector2) -> void:
	var rect := Rect2(center - size * 0.5, size)
	# Shadow
	draw_rect(Rect2(rect.position + Vector2(4, 7), rect.size), Color(0, 0, 0, 0.1), true)
	# Crate body
	draw_rect(rect, Color(0.58, 0.42, 0.24, 1.0), true)
	# Plank lines
	var plank_color := Color(0.5, 0.36, 0.2, 0.5)
	draw_line(Vector2(rect.position.x + rect.size.x * 0.33, rect.position.y + 3), Vector2(rect.position.x + rect.size.x * 0.33, rect.end.y - 3), plank_color, 1.0, true)
	draw_line(Vector2(rect.position.x + rect.size.x * 0.66, rect.position.y + 3), Vector2(rect.position.x + rect.size.x * 0.66, rect.end.y - 3), plank_color, 1.0, true)
	# Cross braces
	draw_line(rect.position + Vector2(4, 4), rect.position + rect.size - Vector2(4, 4), Color(0.44, 0.3, 0.16, 0.7), 2.5, true)
	draw_line(Vector2(rect.end.x - 4, rect.position.y + 4), Vector2(rect.position.x + 4, rect.end.y - 4), Color(0.44, 0.3, 0.16, 0.7), 2.5, true)
	# Metal corner brackets
	var bracket_color := Color(0.4, 0.42, 0.46, 0.7)
	for corner in [rect.position + Vector2(3, 3), Vector2(rect.end.x - 9, rect.position.y + 3), Vector2(rect.position.x + 3, rect.end.y - 9), rect.end - Vector2(9, 9)]:
		draw_rect(Rect2(corner, Vector2(6, 6)), bracket_color, true)
	draw_rect(rect, OUTLINE_COLOR, false, 3.0)
	# Highlight edge
	draw_line(Vector2(rect.position.x + 2, rect.position.y + 2), Vector2(rect.end.x - 2, rect.position.y + 2), Color(0.68, 0.52, 0.34, 0.4), 1.5, true)


func _draw_hedge_strip(rect: Rect2, fill_color: Color) -> void:
	# Shadow
	draw_rect(Rect2(rect.position + Vector2(3, 5), rect.size), Color(0, 0, 0, 0.06), true)
	# Base
	draw_rect(rect, fill_color, true)
	# Leaf bumps along top
	var bump_x := rect.position.x + 8.0
	while bump_x < rect.end.x - 8:
		var bump_r := _rng.randf_range(8, 14)
		draw_circle(Vector2(bump_x, rect.position.y), bump_r, fill_color.lightened(0.04))
		bump_x += _rng.randf_range(14, 22)
	draw_rect(rect, fill_color.darkened(0.14), false, 4.0)
	# Internal texture
	for index in range(1, 5):
		var x := rect.position.x + float(index) * rect.size.x / 5.0
		draw_line(Vector2(x, rect.position.y + 5), Vector2(x, rect.position.y + rect.size.y - 5), fill_color.darkened(0.06), 1.5, true)
	# Highlight spots
	for _i in 4:
		var hx := _rng.randf_range(rect.position.x + 8, rect.end.x - 8)
		var hy := _rng.randf_range(rect.position.y + 4, rect.end.y - 4)
		draw_circle(Vector2(hx, hy), _rng.randf_range(4, 8), fill_color.lightened(0.06))


func _draw_lava_crack(points: PackedVector2Array) -> void:
	draw_polyline(points, Color(1.0, 0.42, 0.14, 1.0), 16.0, true)
	draw_polyline(points, Color(1.0, 0.72, 0.3, 0.68), 6.0, true)


func _draw_ice_wall(rect: Rect2) -> void:
	draw_rect(rect, Color(0.68, 0.86, 0.94, 1.0), true)
	draw_rect(rect, Color(0.44, 0.62, 0.76, 1.0), false, 4.0)
	for index in range(3):
		var y := rect.position.y + 22.0 + float(index) * (rect.size.y - 44.0) / 2.0
		draw_line(Vector2(rect.position.x + 10, y), Vector2(rect.position.x + rect.size.x - 10, y), Color(1, 1, 1, 0.2), 1.5, true)


func _draw_ice_shard(center: Vector2, scale_size: float) -> void:
	var points := PackedVector2Array([
		center + Vector2(0, -scale_size),
		center + Vector2(scale_size * 0.48, -scale_size * 0.18),
		center + Vector2(scale_size * 0.18, scale_size * 0.86),
		center + Vector2(-scale_size * 0.2, scale_size * 0.46),
		center + Vector2(-scale_size * 0.52, -scale_size * 0.1),
	])
	_draw_polygon_with_outline(points, Color(0.82, 0.94, 1.0, 0.9), Color(0.5, 0.7, 0.86, 1.0), 3.0)


func _draw_storm_arc(points: PackedVector2Array) -> void:
	draw_polyline(points, Color(0.68, 0.86, 1.0, 1.0), 7.0, true)
	draw_polyline(points, Color(1, 1, 1, 0.5), 2.0, true)


func _draw_cloud(center: Vector2, size: Vector2, fill_color: Color) -> void:
	_draw_blob(center + Vector2(-size.x * 0.18, 0), Vector2(size.x * 0.34, size.y * 0.52), fill_color, Color(0, 0, 0, 0))
	_draw_blob(center + Vector2(size.x * 0.16, 0), Vector2(size.x * 0.38, size.y * 0.48), fill_color, Color(0, 0, 0, 0))
	_draw_blob(center + Vector2(0, -size.y * 0.14), Vector2(size.x * 0.28, size.y * 0.42), fill_color, Color(0, 0, 0, 0))


func _draw_bed(center: Vector2, size: Vector2) -> void:
	var frame := Rect2(center - size * 0.5, size)
	# Shadow
	draw_rect(Rect2(frame.position + Vector2(4, 8), frame.size), Color(0, 0, 0, 0.08), true)
	# Frame
	draw_rect(frame, Color(0.5, 0.38, 0.24, 1.0), true)
	# Headboard
	var headboard := Rect2(frame.position + Vector2(0, -6), Vector2(frame.size.x, 12))
	draw_rect(headboard, Color(0.44, 0.32, 0.2, 1.0), true)
	draw_rect(headboard, OUTLINE_COLOR, false, 2.0)
	draw_rect(frame, OUTLINE_COLOR, false, 4.0)
	# Blanket with fold detail
	var blanket := frame.grow_individual(-12, -10, -12, -10)
	draw_rect(blanket, Color(0.72, 0.38, 0.28, 1.0), true)
	# Blanket stripe
	var stripe := Rect2(blanket.position + Vector2(0, blanket.size.y * 0.3), Vector2(blanket.size.x, 8))
	draw_rect(stripe, Color(0.82, 0.52, 0.36, 1.0), true)
	draw_rect(blanket, Color(0.58, 0.3, 0.22, 1.0), false, 2.0)
	# Fold line
	var fold_y := blanket.position.y + blanket.size.y * 0.2
	draw_line(Vector2(blanket.position.x + 4, fold_y), Vector2(blanket.end.x - 4, fold_y), Color(0.62, 0.3, 0.2, 0.4), 1.5, true)
	# Pillow
	var pillow := Rect2(frame.position + Vector2(12, 8), Vector2(44, 22))
	draw_rect(pillow, Color(0.96, 0.96, 0.92, 1.0), true)
	draw_rect(pillow, Color(0.82, 0.8, 0.76, 1.0), false, 1.5)
	# Pillow puff
	draw_circle(pillow.position + Vector2(22, 11), 8.0, Color(1, 1, 1, 0.1))


func _draw_barred_cell(center: Vector2, size: Vector2) -> void:
	var rect := Rect2(center - size * 0.5, size)
	draw_rect(rect, Color(0.62, 0.62, 0.66, 1.0), true)
	draw_rect(rect, OUTLINE_COLOR, false, 4.0)
	for index in range(-2, 3):
		var x := center.x + float(index) * 20.0
		draw_line(Vector2(x, rect.position.y + 8), Vector2(x, rect.position.y + rect.size.y - 8), Color(0.26, 0.28, 0.32, 1.0), 3.0, true)


func _draw_watch_post(center: Vector2) -> void:
	var base_rect := Rect2(center - Vector2(34, 34), Vector2(68, 68))
	draw_rect(base_rect, Color(0.38, 0.36, 0.34, 1.0), true)
	draw_rect(base_rect, OUTLINE_COLOR, false, 4.0)
	var top_rect := Rect2(center - Vector2(48, 60), Vector2(96, 22))
	draw_rect(top_rect, Color(0.5, 0.24, 0.14, 1.0), true)
	draw_rect(top_rect, OUTLINE_COLOR, false, 3.0)


# ============================================================
# PRIMITIVE HELPERS
# ============================================================

func _draw_blob(center: Vector2, radius: Vector2, fill_color: Color, highlight_color: Color) -> void:
	var points := _ellipse_points(center, radius, 28)
	_draw_polygon_with_outline(points, fill_color, Color(0, 0, 0, 0), 0.0)
	if highlight_color.a > 0.01:
		var highlight := _ellipse_points(center + Vector2(-radius.x * 0.2, -radius.y * 0.22), radius * 0.52, 18)
		_draw_polygon_with_outline(highlight, highlight_color, Color(0, 0, 0, 0), 0.0)


func _draw_polygon_with_outline(points: PackedVector2Array, fill_color: Color, outline_color: Color = OUTLINE_COLOR, outline_width: float = 4.0) -> void:
	var colors := PackedColorArray()
	for _index in range(points.size()):
		colors.append(fill_color)
	draw_polygon(points, colors)
	if outline_width > 0.0 and outline_color.a > 0.0:
		var polyline_points := points.duplicate()
		polyline_points.append(points[0])
		draw_polyline(polyline_points, outline_color, outline_width, true)


func _ellipse_points(center: Vector2, radius: Vector2, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points
