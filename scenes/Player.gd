extends CharacterBody2D
class_name PlayerController

const BULLET_SCENE := preload("res://scenes/Bullet.tscn")
const HIT_SPARK_SCENE := preload("res://scripts/HitSpark.gd")
const BASIC_GUN_ITEM_ID := "slime_blaster"
const REPEATER_GUN_ITEM_ID := "iron_repeater"
const SUN_GUN_ITEM_ID := "sun_lance"
const SPECIAL_GUN_ITEM_ID := "arc_blaster"

const SLASH_LUNGE_SPEED := 480.0
const SLASH_LUNGE_DURATION := 0.12
const SLASH_ARC_DEGREES := 130.0
const SLASH_WINDUP := 0.04
const SLASH_SWING := 0.1
const SLASH_RECOVER := 0.08
const SLASH_COOLDOWN := 0.32

@export var speed := 220.0
@export var max_hp := 3
@export var attack_duration := 0.1
@export var attack_cooldown := 0.35
@export var attack_knockback := 280.0
@export var invulnerability_duration := 0.7
@export var knife_reach := 32.0
@export var knife_aim_guide_length := 64.0
@export var bullet_speed := 620.0
@export var shoot_cooldown := 0.18
@export var aim_guide_length := 260.0
@export var dash_speed := 560.0
@export var dash_duration := 0.13
@export var dash_cooldown := 1.1
@export var shock_ring_radius := 150.0
@export var shock_ring_cooldown := 3.2

@onready var visuals: Node2D = $Visuals
@onready var shadow: Polygon2D = $Visuals/Shadow
@onready var cloak: Polygon2D = $Visuals/Cloak
@onready var leg_left: Polygon2D = $Visuals/LegLeft
@onready var leg_right: Polygon2D = $Visuals/LegRight
@onready var boot_left: Polygon2D = $Visuals/BootLeft
@onready var boot_right: Polygon2D = $Visuals/BootRight
@onready var arm_left: Polygon2D = $Visuals/ArmLeft
@onready var arm_right: Polygon2D = $Visuals/ArmRight
@onready var hand_left: Polygon2D = $Visuals/HandLeft
@onready var hand_right: Polygon2D = $Visuals/HandRight
@onready var torso_panel: Polygon2D = $Visuals/TorsoPanel
@onready var scarf: Polygon2D = $Visuals/Scarf
@onready var shoulder_pad_left: Polygon2D = $Visuals/ShoulderPadLeft
@onready var shoulder_pad_right: Polygon2D = $Visuals/ShoulderPadRight
@onready var head: Polygon2D = $Visuals/Head
@onready var hair_back: Polygon2D = $Visuals/HairBack
@onready var hair: Polygon2D = $Visuals/Hair
@onready var brow: Polygon2D = $Visuals/Brow
@onready var eye_left: Polygon2D = $Visuals/EyeLeft
@onready var eye_right: Polygon2D = $Visuals/EyeRight
@onready var knife_guard: Polygon2D = $Visuals/KnifeGuard
@onready var sword_visual: Polygon2D = $Visuals/Sword
@onready var hilt_visual: Polygon2D = $Visuals/Hilt
@onready var sword_trail: Line2D = $Visuals/SwordTrail
@onready var gun_pivot: Node2D = $Visuals/GunPivot
@onready var gun_grip: Polygon2D = $Visuals/GunPivot/Grip
@onready var gun_body: Polygon2D = $Visuals/GunPivot/Body
@onready var gun_barrel: Polygon2D = $Visuals/GunPivot/Barrel
@onready var gun_top_rail: Polygon2D = $Visuals/GunPivot/TopRail
@onready var gun_muzzle: Marker2D = $Visuals/GunPivot/Muzzle
@onready var muzzle_flash: Polygon2D = $Visuals/GunPivot/MuzzleFlash
@onready var aim_guide: Line2D = $Visuals/AimGuide
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var camera: Camera2D = $Camera2D

var facing := Vector2.DOWN
var is_attacking := false
var attack_on_cooldown := false
var shoot_on_cooldown := false
var invulnerable_time := 0.0
var gun_visible := false
var walk_cycle := 0.0
var dash_time := 0.0
var dash_cooldown_time := 0.0
var dash_direction := Vector2.ZERO
var shock_ring_cooldown_time := 0.0
var base_positions: Dictionary = {}
var base_rotations: Dictionary = {}

# Dash-slash state (Soul Knight style)
var slash_phase := 0  # 0=none, 1=windup, 2=swing+lunge, 3=recover
var slash_phase_time := 0.0
var slash_start_angle := 0.0
var slash_current_angle := 0.0
var slash_target_angle := 0.0
var slash_direction := Vector2.ZERO
var slash_hits_resolved := false

var shake_intensity := 0.0
var shake_decay := 14.0


func _ready() -> void:
	add_to_group("player")
	attack_shape.disabled = true
	GameState.player_max_hp = maxi(GameState.player_max_hp, max_hp)
	if GameState.player_hp <= 0:
		GameState.set_player_hp(GameState.player_max_hp)
	_cache_animation_defaults()
	_refresh_weapon_state()
	sword_trail.clear_points()


func _physics_process(delta: float) -> void:
	_update_invulnerability(delta)
	_update_power_cooldowns(delta)
	_refresh_weapon_state()
	_process_dash_slash(delta)
	_process_screen_shake(delta)

	var input_dir := Vector2.ZERO
	if _can_accept_input():
		var aim_direction := _get_weapon_aim_direction(global_position)
		if aim_direction != Vector2.ZERO:
			facing = aim_direction

	if _can_accept_input() and dash_time <= 0.0 and not is_attacking:
		input_dir.x = Input.get_axis("ui_left", "ui_right")
		input_dir.y = Input.get_axis("ui_up", "ui_down")
		if Input.is_action_just_pressed("shoot"):
			_attempt_primary_action()
		if Input.is_action_just_pressed("attack") and not _has_gun():
			_attempt_dash_slash()
		if Input.is_action_just_pressed("ability"):
			_attempt_dash()
		if Input.is_action_just_pressed("power_secondary"):
			_attempt_shock_ring()
		if Input.is_action_just_pressed("interact") and not _is_interact_locked():
			_try_interact()

	_animate_player(delta, input_dir)
	_update_weapon_aim()
	var move_speed := speed + (28.0 if GameState.has_power("trail_haste") else 0.0)

	if slash_phase == 2:
		velocity = slash_direction * SLASH_LUNGE_SPEED
	elif dash_time > 0.0:
		velocity = dash_direction * dash_speed
		dash_time = maxf(dash_time - delta, 0.0)
	elif _is_zero_gravity_room():
		var desired_velocity := input_dir.normalized() * move_speed if input_dir != Vector2.ZERO and not is_attacking else Vector2.ZERO
		var steer := 520.0 if input_dir != Vector2.ZERO else 160.0
		velocity = velocity.move_toward(desired_velocity, steer * delta)
	else:
		velocity = input_dir.normalized() * move_speed if input_dir != Vector2.ZERO and not is_attacking else Vector2.ZERO
	move_and_slide()


func get_interaction_prompt() -> String:
	var target = _get_nearest_interactable()
	if target == null:
		return ""
	return "[E] %s" % target.get_prompt_text()


func take_damage(amount: int, source_position: Vector2) -> void:
	if invulnerable_time > 0.0 or amount <= 0:
		return

	invulnerable_time = invulnerability_duration
	GameState.set_player_hp(GameState.player_hp - amount)
	_trigger_screen_shake(3.5)

	if GameState.player_hp <= 0:
		var current_scene = get_tree().current_scene
		if current_scene != null and current_scene.has_method("respawn_player"):
			current_scene.respawn_player()
		return

	var push_direction := global_position - source_position
	if push_direction == Vector2.ZERO:
		push_direction = -facing
	global_position += push_direction.normalized() * 24.0


# --- SCREEN SHAKE ---

func _trigger_screen_shake(intensity: float) -> void:
	shake_intensity = maxf(shake_intensity, intensity)


func _process_screen_shake(delta: float) -> void:
	if shake_intensity <= 0.1:
		camera.offset = Vector2.ZERO
		shake_intensity = 0.0
		return
	shake_intensity = move_toward(shake_intensity, 0.0, shake_decay * delta)
	camera.offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)


# --- DASH-SLASH (Soul Knight style: left click = lunge + swing) ---

func _attempt_dash_slash() -> void:
	if attack_on_cooldown or is_attacking or not _can_accept_input():
		return

	var aim := _get_weapon_aim_direction(global_position)
	if aim == Vector2.ZERO:
		aim = facing
	aim = aim.normalized()
	facing = aim
	is_attacking = true
	attack_on_cooldown = true
	slash_direction = aim
	slash_hits_resolved = false

	var base_angle := aim.angle()
	slash_start_angle = base_angle - deg_to_rad(SLASH_ARC_DEGREES * 0.5)
	slash_target_angle = base_angle + deg_to_rad(SLASH_ARC_DEGREES * 0.5)
	slash_current_angle = slash_start_angle

	slash_phase = 1
	slash_phase_time = 0.0
	sword_trail.clear_points()
	sword_trail.default_color = Color(0.85, 0.9, 1.0, 0.55)
	sword_trail.width = 6.0

	invulnerable_time = maxf(invulnerable_time, SLASH_WINDUP + SLASH_SWING + 0.04)


func _process_dash_slash(delta: float) -> void:
	if slash_phase == 0:
		return

	slash_phase_time += delta

	match slash_phase:
		1:  # WINDUP - sword pulls back, body coils
			var t := clampf(slash_phase_time / SLASH_WINDUP, 0.0, 1.0)
			slash_current_angle = slash_start_angle
			_position_sword_at_angle(slash_current_angle, 0.88 + t * 0.12)
			if slash_phase_time >= SLASH_WINDUP:
				slash_phase = 2
				slash_phase_time = 0.0
				attack_hitbox.position = slash_direction * knife_reach
				attack_hitbox.rotation = slash_direction.angle()
				attack_shape.disabled = false

		2:  # SWING + LUNGE - dash forward while sword arcs
			var t := clampf(slash_phase_time / SLASH_SWING, 0.0, 1.0)
			var eased := 1.0 - pow(1.0 - t, 3.0)
			slash_current_angle = lerp_angle(slash_start_angle, slash_target_angle, eased)
			_position_sword_at_angle(slash_current_angle, 1.22)
			_append_sword_trail_point()

			if not slash_hits_resolved and t > 0.15:
				slash_hits_resolved = true
				_resolve_slash_hits()

			if slash_phase_time >= SLASH_SWING:
				slash_phase = 3
				slash_phase_time = 0.0
				attack_shape.disabled = true

		3:  # RECOVER - sword returns, speed drops
			var t := clampf(slash_phase_time / SLASH_RECOVER, 0.0, 1.0)
			var eased := t * t
			_position_sword_at_angle(
				lerp_angle(slash_target_angle, slash_direction.angle(), eased),
				lerpf(1.22, 1.0, eased)
			)
			_fade_sword_trail(t)
			if slash_phase_time >= SLASH_RECOVER:
				slash_phase = 0
				is_attacking = false
				sword_trail.clear_points()
				_start_slash_cooldown()


func _start_slash_cooldown() -> void:
	await get_tree().create_timer(SLASH_COOLDOWN).timeout
	attack_on_cooldown = false


func _resolve_slash_hits() -> void:
	await get_tree().physics_frame
	var hit_any := false
	for body in attack_hitbox.get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(1, slash_direction * attack_knockback)
			hit_any = true

	# Also check enemies near the lunge path
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not (enemy is Node2D) or not enemy.has_method("take_damage"):
			continue
		var dist := (enemy as Node2D).global_position.distance_to(global_position)
		if dist < 48.0:
			var already_hit := false
			for body in attack_hitbox.get_overlapping_bodies():
				if body == enemy:
					already_hit = true
					break
			if not already_hit:
				enemy.take_damage(1, slash_direction * attack_knockback)
				hit_any = true

	if hit_any:
		_trigger_screen_shake(5.0)
		_spawn_hit_spark(global_position + slash_direction * knife_reach)


func _position_sword_at_angle(angle: float, scale_factor: float) -> void:
	var direction := Vector2.from_angle(angle)
	sword_visual.rotation = angle + PI * 0.5
	hilt_visual.rotation = angle + PI * 0.5
	knife_guard.rotation = angle + PI * 0.5
	sword_visual.position = Vector2(direction.x * 16.0, 4.0 + direction.y * 11.0)
	hilt_visual.position = Vector2(direction.x * 14.0, 12.0 + direction.y * 11.0)
	knife_guard.position = Vector2(direction.x * 14.5, 9.0 + direction.y * 11.0)
	sword_visual.scale = Vector2.ONE * scale_factor
	hilt_visual.scale = Vector2.ONE * (scale_factor * 0.94)
	knife_guard.scale = Vector2.ONE * (scale_factor * 0.96)


func _append_sword_trail_point() -> void:
	var tip_local := Vector2.from_angle(slash_current_angle) * 26.0
	sword_trail.add_point(tip_local)
	while sword_trail.get_point_count() > 16:
		sword_trail.remove_point(0)


func _fade_sword_trail(t: float) -> void:
	sword_trail.default_color = Color(0.85, 0.9, 1.0, 0.55 * (1.0 - t))
	sword_trail.width = lerpf(6.0, 1.0, t)


func _spawn_hit_spark(world_position: Vector2) -> void:
	var spark := Node2D.new()
	spark.set_script(HIT_SPARK_SCENE)
	get_parent().add_child(spark)
	spark.global_position = world_position


# --- GUN COMBAT ---

func _attempt_primary_action() -> void:
	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("is_room_silent_mission") and bool(current_scene.call("is_room_silent_mission")):
		if current_scene.has_method("get_room_silent_failure_message") and current_scene.has_method("fail_mission"):
			current_scene.call("fail_mission", str(current_scene.call("get_room_silent_failure_message")))
		return

	if _has_gun():
		_attempt_shot()
	else:
		_attempt_dash_slash()


func _attempt_shot() -> void:
	if shoot_on_cooldown or not _has_gun() or not _can_accept_input():
		return

	var shoot_direction := _get_weapon_aim_direction(global_position)
	facing = shoot_direction
	shoot_on_cooldown = true

	var gun_id := _get_current_gun_id()
	var cooldown := shoot_cooldown
	var projectile_speed := bullet_speed
	var spread_angles := PackedFloat32Array([0.0])

	match gun_id:
		REPEATER_GUN_ITEM_ID:
			cooldown = 0.12
			projectile_speed = bullet_speed * 1.12
		SUN_GUN_ITEM_ID:
			cooldown = 0.15
			projectile_speed = bullet_speed * 1.18
			spread_angles = PackedFloat32Array([-0.07, 0.07])
		SPECIAL_GUN_ITEM_ID:
			cooldown = 0.11
			projectile_speed = bullet_speed * 1.22
			spread_angles = PackedFloat32Array([-0.14, 0.0, 0.14])

	if GameState.has_power("overdrive"):
		cooldown *= 0.85
		projectile_speed *= 1.12

	for angle in spread_angles:
		_spawn_bullet(shoot_direction.rotated(angle), projectile_speed)

	_flash_muzzle()
	await get_tree().create_timer(cooldown).timeout
	shoot_on_cooldown = false


# --- ABILITIES ---

func _attempt_dash() -> void:
	if not GameState.has_power("blink_dash") or dash_cooldown_time > 0.0 or not _can_accept_input():
		return

	var aim_direction := _get_weapon_aim_direction(global_position)
	if aim_direction == Vector2.ZERO:
		aim_direction = facing
	if aim_direction == Vector2.ZERO:
		return

	dash_direction = aim_direction.normalized()
	dash_time = dash_duration
	dash_cooldown_time = dash_cooldown
	invulnerable_time = maxf(invulnerable_time, dash_duration + 0.08)


func _attempt_shock_ring() -> void:
	if not GameState.has_power("shock_ring") or shock_ring_cooldown_time > 0.0 or not _can_accept_input():
		return

	shock_ring_cooldown_time = shock_ring_cooldown
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not enemy.has_method("take_damage"):
			continue
		if not (enemy is Node2D):
			continue
		var enemy_node := enemy as Node2D
		var offset := enemy_node.global_position - global_position
		if offset.length() <= shock_ring_radius:
			enemy.take_damage(1, offset.normalized() * 360.0)

	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("show_status_message"):
		current_scene.show_status_message("Shock Ring bursts outward.")


# --- HELPERS ---

func _spawn_bullet(direction: Vector2, projectile_speed: float) -> void:
	var bullet := BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = gun_muzzle.global_position
	bullet.setup(direction.normalized(), projectile_speed)


func _flash_muzzle() -> void:
	muzzle_flash.visible = true
	await get_tree().create_timer(0.05).timeout
	if is_instance_valid(muzzle_flash):
		muzzle_flash.visible = false


func _try_interact() -> void:
	var target = _get_nearest_interactable()
	if target == null:
		return
	target.interact(self)


func _is_zero_gravity_room() -> bool:
	return GameState.current_room_id == "echo_rift" or GameState.current_room_id == "ashen_rift"


func _get_nearest_interactable() -> Node:
	var nearest: Node
	var nearest_distance := INF
	for area in interaction_area.get_overlapping_areas():
		if not area.is_in_group("interactable"):
			continue
		var distance := global_position.distance_squared_to(area.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = area
	return nearest


func _update_invulnerability(delta: float) -> void:
	if invulnerable_time <= 0.0:
		modulate = Color.WHITE
		return

	invulnerable_time = max(invulnerable_time - delta, 0.0)
	var alpha := 0.45 if fmod(invulnerable_time * 20.0, 2.0) < 1.0 else 1.0
	modulate = Color(1.0, 1.0, 1.0, alpha)


func _update_power_cooldowns(delta: float) -> void:
	dash_cooldown_time = maxf(dash_cooldown_time - delta, 0.0)
	shock_ring_cooldown_time = maxf(shock_ring_cooldown_time - delta, 0.0)


func _update_weapon_aim() -> void:
	var aim_direction := _get_weapon_aim_direction(global_position)
	if aim_direction == Vector2.ZERO:
		aim_direction = facing

	if not gun_visible:
		gun_pivot.rotation = 0.0
		if slash_phase == 0:
			var weapon_angle := aim_direction.angle()
			sword_visual.rotation = weapon_angle + PI * 0.5
			hilt_visual.rotation = weapon_angle + PI * 0.5
			knife_guard.rotation = weapon_angle + PI * 0.5
			sword_visual.position = Vector2(aim_direction.x * 13.0, 4.0 + aim_direction.y * 8.0)
			hilt_visual.position = Vector2(aim_direction.x * 11.0, 12.0 + aim_direction.y * 8.0)
			knife_guard.position = Vector2(aim_direction.x * 11.5, 9.0 + aim_direction.y * 8.0)
		aim_guide.visible = _can_accept_input() and slash_phase == 0
		aim_guide.points = PackedVector2Array([Vector2.ZERO, aim_direction * knife_aim_guide_length])
		return

	gun_pivot.look_at(get_global_mouse_position())
	aim_guide.visible = _can_accept_input()
	aim_guide.points = PackedVector2Array([Vector2.ZERO, aim_direction * (_get_aim_guide_length())])


func _refresh_weapon_state() -> void:
	gun_visible = _has_gun()
	knife_guard.visible = not gun_visible
	sword_visual.visible = not gun_visible
	hilt_visual.visible = not gun_visible
	gun_pivot.visible = gun_visible

	var gun_id := _get_current_gun_id()
	match gun_id:
		SPECIAL_GUN_ITEM_ID:
			gun_grip.color = Color(0.22, 0.24, 0.32, 1)
			gun_body.color = Color(0.24, 0.78, 0.94, 1)
			gun_barrel.color = Color(0.9, 0.97, 1.0, 1)
			gun_top_rail.color = Color(0.09, 0.26, 0.34, 1)
			muzzle_flash.color = Color(0.46, 0.94, 1.0, 1)
			aim_guide.default_color = Color(0.72, 0.96, 1.0, 0.26)
		SUN_GUN_ITEM_ID:
			gun_grip.color = Color(0.56, 0.31, 0.15, 1)
			gun_body.color = Color(0.92, 0.72, 0.22, 1)
			gun_barrel.color = Color(1.0, 0.91, 0.48, 1)
			gun_top_rail.color = Color(0.55, 0.28, 0.11, 1)
			muzzle_flash.color = Color(1.0, 0.88, 0.42, 1)
			aim_guide.default_color = Color(1.0, 0.86, 0.36, 0.24)
		REPEATER_GUN_ITEM_ID:
			gun_grip.color = Color(0.34, 0.24, 0.16, 1)
			gun_body.color = Color(0.54, 0.56, 0.62, 1)
			gun_barrel.color = Color(0.78, 0.82, 0.87, 1)
			gun_top_rail.color = Color(0.19, 0.21, 0.25, 1)
			muzzle_flash.color = Color(1.0, 0.84, 0.3, 1)
			aim_guide.default_color = Color(0.88, 0.9, 1.0, 0.22)
		BASIC_GUN_ITEM_ID:
			gun_grip.color = Color(0.42, 0.24, 0.12, 1)
			gun_body.color = Color(0.27, 0.31, 0.36, 1)
			gun_barrel.color = Color(0.57, 0.62, 0.69, 1)
			gun_top_rail.color = Color(0.13, 0.16, 0.2, 1)
			muzzle_flash.color = Color(1, 0.84, 0.26, 1)
			aim_guide.default_color = Color(1, 1, 1, 0.2)
		_:
			gun_top_rail.color = Color(0.13, 0.16, 0.2, 1)
			aim_guide.default_color = Color(1, 1, 1, 0.16)


func _has_gun() -> bool:
	return not _get_current_gun_id().is_empty()


func _get_current_gun_id() -> String:
	return GameState.get_best_gun_id()


func _get_aim_guide_length() -> float:
	match _get_current_gun_id():
		SPECIAL_GUN_ITEM_ID:
			return aim_guide_length * 1.18
		SUN_GUN_ITEM_ID:
			return aim_guide_length * 1.08
		_:
			return aim_guide_length


func _get_weapon_aim_direction(origin: Vector2) -> Vector2:
	var aim_direction := get_global_mouse_position() - origin
	if aim_direction == Vector2.ZERO:
		return facing.normalized()
	return aim_direction.normalized()


func _cache_animation_defaults() -> void:
	for node in [
		visuals, shadow, cloak, leg_left, leg_right, boot_left, boot_right,
		arm_left, arm_right, hand_left, hand_right, torso_panel, scarf,
		shoulder_pad_left, shoulder_pad_right, head, hair_back, hair,
		brow, eye_left, eye_right, knife_guard, sword_visual, hilt_visual, gun_pivot,
	]:
		base_positions[node] = node.position
		base_rotations[node] = node.rotation


func _animate_player(delta: float, input_dir: Vector2) -> void:
	var moving := input_dir != Vector2.ZERO and _can_accept_input()
	if moving:
		walk_cycle += delta * 11.0
	else:
		walk_cycle += delta * 2.0

	var bob := sin(walk_cycle) * (2.8 if moving else 0.8)
	var stride := sin(walk_cycle) * (4.0 if moving else 0.0)
	var stride_opposite := sin(walk_cycle + PI) * (4.0 if moving else 0.0)
	var sway := sin(walk_cycle * 0.5) * 0.05
	var lean := clampf(input_dir.x * 0.08, -0.08, 0.08)
	var arm_swing := sin(walk_cycle) * (0.2 if moving else 0.04)
	var arm_swing_opposite := sin(walk_cycle + PI) * (0.2 if moving else 0.04)
	var eye_shift := clampf(facing.x * 1.2, -1.2, 1.2)

	# Lean into dash-slash direction
	if slash_phase == 2:
		lean = slash_direction.x * 0.18
		bob = -2.0
	elif dash_time > 0.0:
		lean = dash_direction.x * 0.14

	visuals.position = base_positions[visuals] + Vector2(0, bob)
	visuals.rotation = lean
	shadow.scale = Vector2(1.0 - absf(bob) * 0.025, 1.0 - absf(bob) * 0.01)
	cloak.position = base_positions[cloak] + Vector2(0, bob * 0.2)
	cloak.rotation = base_rotations[cloak] + sway - lean * 0.45
	leg_left.position = base_positions[leg_left] + Vector2(0, stride * 0.55)
	leg_right.position = base_positions[leg_right] + Vector2(0, stride_opposite * 0.55)
	head.position = base_positions[head] + Vector2(0, -bob * 0.18)
	hair_back.position = base_positions[hair_back] + Vector2(0, -bob * 0.15)
	hair.position = base_positions[hair] + Vector2(0, -bob * 0.2)
	brow.position = base_positions[brow] + Vector2(eye_shift * 0.3, 0)
	eye_left.position = base_positions[eye_left] + Vector2(eye_shift, 0)
	eye_right.position = base_positions[eye_right] + Vector2(eye_shift, 0)
	boot_left.position = base_positions[boot_left] + Vector2(0, stride)
	boot_right.position = base_positions[boot_right] + Vector2(0, stride_opposite)
	arm_left.rotation = base_rotations[arm_left] + arm_swing
	arm_right.rotation = base_rotations[arm_right] + arm_swing_opposite
	hand_left.position = base_positions[hand_left] + Vector2(0, stride * 0.3)
	hand_right.position = base_positions[hand_right] + Vector2(0, stride_opposite * 0.3)
	torso_panel.position = base_positions[torso_panel] + Vector2(0, bob * 0.1)
	scarf.position = base_positions[scarf] + Vector2(0, -bob * 0.1)
	scarf.rotation = base_rotations[scarf] + sway * 1.4
	shoulder_pad_left.rotation = base_rotations[shoulder_pad_left] + lean * 0.6
	shoulder_pad_right.rotation = base_rotations[shoulder_pad_right] + lean * 0.6

	if not gun_visible:
		if slash_phase == 0:
			knife_guard.scale = Vector2.ONE
			sword_visual.scale = Vector2.ONE
			hilt_visual.scale = Vector2.ONE
	else:
		knife_guard.scale = Vector2.ONE
		sword_visual.scale = Vector2.ONE
		hilt_visual.scale = Vector2.ONE


func _can_accept_input() -> bool:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return true
	if current_scene.has_method("can_accept_player_input"):
		return current_scene.can_accept_player_input()
	return true


func _is_interact_locked() -> bool:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return false
	if current_scene.has_method("is_interact_locked"):
		return current_scene.is_interact_locked()
	return false
