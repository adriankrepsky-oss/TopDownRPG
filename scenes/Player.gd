extends CharacterBody2D
class_name PlayerController

const BULLET_SCENE := preload("res://scenes/Bullet.tscn")
const BASIC_GUN_ITEM_ID := "slime_blaster"
const REPEATER_GUN_ITEM_ID := "iron_repeater"
const SUN_GUN_ITEM_ID := "sun_lance"
const SPECIAL_GUN_ITEM_ID := "arc_blaster"

@export var speed := 220.0
@export var max_hp := 3
@export var attack_duration := 0.1
@export var attack_cooldown := 0.35
@export var attack_knockback := 240.0
@export var invulnerability_duration := 0.7
@export var knife_reach := 28.0
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
@onready var boot_left: Polygon2D = $Visuals/BootLeft
@onready var boot_right: Polygon2D = $Visuals/BootRight
@onready var head: Polygon2D = $Visuals/Head
@onready var hair: Polygon2D = $Visuals/Hair
@onready var sword_visual: Polygon2D = $Visuals/Sword
@onready var hilt_visual: Polygon2D = $Visuals/Hilt
@onready var gun_pivot: Node2D = $Visuals/GunPivot
@onready var gun_grip: Polygon2D = $Visuals/GunPivot/Grip
@onready var gun_body: Polygon2D = $Visuals/GunPivot/Body
@onready var gun_barrel: Polygon2D = $Visuals/GunPivot/Barrel
@onready var gun_muzzle: Marker2D = $Visuals/GunPivot/Muzzle
@onready var muzzle_flash: Polygon2D = $Visuals/GunPivot/MuzzleFlash
@onready var aim_guide: Line2D = $Visuals/AimGuide
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea

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


func _ready() -> void:
	add_to_group("player")
	attack_shape.disabled = true
	GameState.player_max_hp = maxi(GameState.player_max_hp, max_hp)
	if GameState.player_hp <= 0:
		GameState.set_player_hp(GameState.player_max_hp)

	_cache_animation_defaults()
	_refresh_weapon_state()


func _physics_process(delta: float) -> void:
	_update_invulnerability(delta)
	_update_power_cooldowns(delta)
	_refresh_weapon_state()

	var input_dir := Vector2.ZERO
	if _can_accept_input():
		var aim_direction := _get_weapon_aim_direction(global_position)
		if aim_direction != Vector2.ZERO:
			facing = aim_direction

	if _can_accept_input() and dash_time <= 0.0 and not is_attacking:
		input_dir.x = Input.get_axis("ui_left", "ui_right")
		input_dir.y = Input.get_axis("ui_up", "ui_down")
		if Input.is_action_just_pressed("attack") and not _has_gun():
			_attempt_attack()
		if Input.is_action_just_pressed("shoot"):
			_attempt_primary_action()
		if Input.is_action_just_pressed("ability"):
			_attempt_dash()
		if Input.is_action_just_pressed("power_secondary"):
			_attempt_shock_ring()
		if Input.is_action_just_pressed("interact") and not _is_interact_locked():
			_try_interact()

	_animate_player(delta, input_dir)
	_update_weapon_aim()
	var move_speed := speed + (28.0 if GameState.has_power("trail_haste") else 0.0)

	if dash_time > 0.0:
		velocity = dash_direction * dash_speed
		dash_time = maxf(dash_time - delta, 0.0)
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

	if GameState.player_hp <= 0:
		var current_scene = get_tree().current_scene
		if current_scene != null and current_scene.has_method("respawn_player"):
			current_scene.respawn_player()
		return

	var push_direction := global_position - source_position
	if push_direction == Vector2.ZERO:
		push_direction = -facing
	global_position += push_direction.normalized() * 24.0


func _attempt_attack() -> void:
	if attack_on_cooldown or is_attacking or not _can_accept_input():
		return

	var attack_direction := _get_weapon_aim_direction(global_position)
	if attack_direction == Vector2.ZERO:
		attack_direction = facing
	attack_direction = attack_direction.normalized()
	facing = attack_direction
	is_attacking = true
	attack_on_cooldown = true
	attack_hitbox.position = attack_direction * knife_reach
	attack_hitbox.rotation = attack_direction.angle()
	attack_shape.disabled = false

	_resolve_attack(attack_direction)


func _resolve_attack(attack_direction: Vector2) -> void:
	await get_tree().physics_frame
	var hit_enemies: Array[Node] = []
	for body in attack_hitbox.get_overlapping_bodies():
		if body.is_in_group("enemy") and not hit_enemies.has(body):
			hit_enemies.append(body)

	for enemy in hit_enemies:
		if enemy.has_method("take_damage"):
			enemy.take_damage(1, attack_direction * attack_knockback)

	await get_tree().create_timer(attack_duration).timeout
	attack_shape.disabled = true
	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	attack_on_cooldown = false


func _attempt_primary_action() -> void:
	if _has_gun():
		_attempt_shot()
	else:
		_attempt_attack()


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
		var weapon_angle := aim_direction.angle()
		sword_visual.rotation = weapon_angle + PI * 0.5
		hilt_visual.rotation = weapon_angle + PI * 0.5
		sword_visual.position = Vector2(aim_direction.x * 13.0, 4.0 + aim_direction.y * 8.0)
		hilt_visual.position = Vector2(aim_direction.x * 11.0, 12.0 + aim_direction.y * 8.0)
		aim_guide.visible = _can_accept_input()
		aim_guide.points = PackedVector2Array([Vector2.ZERO, aim_direction * knife_aim_guide_length])
		return

	gun_pivot.look_at(get_global_mouse_position())
	aim_guide.visible = _can_accept_input()
	aim_guide.points = PackedVector2Array([Vector2.ZERO, aim_direction * (_get_aim_guide_length())])


func _refresh_weapon_state() -> void:
	gun_visible = _has_gun()
	sword_visual.visible = not gun_visible
	hilt_visual.visible = not gun_visible
	gun_pivot.visible = gun_visible

	var gun_id := _get_current_gun_id()
	match gun_id:
		SPECIAL_GUN_ITEM_ID:
			gun_grip.color = Color(0.22, 0.24, 0.32, 1)
			gun_body.color = Color(0.24, 0.78, 0.94, 1)
			gun_barrel.color = Color(0.9, 0.97, 1.0, 1)
			muzzle_flash.color = Color(0.46, 0.94, 1.0, 1)
			aim_guide.default_color = Color(0.72, 0.96, 1.0, 0.26)
		SUN_GUN_ITEM_ID:
			gun_grip.color = Color(0.56, 0.31, 0.15, 1)
			gun_body.color = Color(0.92, 0.72, 0.22, 1)
			gun_barrel.color = Color(1.0, 0.91, 0.48, 1)
			muzzle_flash.color = Color(1.0, 0.88, 0.42, 1)
			aim_guide.default_color = Color(1.0, 0.86, 0.36, 0.24)
		REPEATER_GUN_ITEM_ID:
			gun_grip.color = Color(0.34, 0.24, 0.16, 1)
			gun_body.color = Color(0.54, 0.56, 0.62, 1)
			gun_barrel.color = Color(0.78, 0.82, 0.87, 1)
			muzzle_flash.color = Color(1.0, 0.84, 0.3, 1)
			aim_guide.default_color = Color(0.88, 0.9, 1.0, 0.22)
		BASIC_GUN_ITEM_ID:
			gun_grip.color = Color(0.42, 0.24, 0.12, 1)
			gun_body.color = Color(0.27, 0.31, 0.36, 1)
			gun_barrel.color = Color(0.57, 0.62, 0.69, 1)
			muzzle_flash.color = Color(1, 0.84, 0.26, 1)
			aim_guide.default_color = Color(1, 1, 1, 0.2)
		_:
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
	for node in [visuals, shadow, cloak, boot_left, boot_right, head, hair, sword_visual, hilt_visual, gun_pivot]:
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
	var sway := sin(walk_cycle * 0.5) * 0.05
	var lean := clampf(input_dir.x * 0.08, -0.08, 0.08)
	if dash_time > 0.0:
		lean = dash_direction.x * 0.14

	visuals.position = base_positions[visuals] + Vector2(0, bob)
	visuals.rotation = lean
	shadow.scale = Vector2(1.0 - absf(bob) * 0.025, 1.0 - absf(bob) * 0.01)
	cloak.position = base_positions[cloak] + Vector2(0, bob * 0.2)
	cloak.rotation = base_rotations[cloak] + sway
	head.position = base_positions[head] + Vector2(0, -bob * 0.18)
	hair.position = base_positions[hair] + Vector2(0, -bob * 0.2)
	boot_left.position = base_positions[boot_left] + Vector2(0, stride)
	boot_right.position = base_positions[boot_right] + Vector2(0, -stride)

	if not gun_visible:
		sword_visual.scale = Vector2.ONE * (1.08 if is_attacking else 1.0)
		hilt_visual.scale = Vector2.ONE * (1.05 if is_attacking else 1.0)
	else:
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
