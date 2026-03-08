extends CharacterBody2D
class_name Slime

const COIN_PICKUP_SCENE := preload("res://scenes/CoinPickup.tscn")

@export var max_hp := 2
@export var move_speed := 75.0
@export var detection_radius := 180.0
@export var saved_enemy_id := ""
@export var hp_bar_width := 34.0
@export var coin_reward := 1

@onready var health_fill: Line2D = $HealthBar/Fill

var hp := max_hp
var home_position := Vector2.ZERO
var patrol_direction := 1.0
var knockback_velocity := Vector2.ZERO
var hit_stun_time := 0.0
var player: CharacterBody2D


func _ready() -> void:
	if not saved_enemy_id.is_empty() and GameState.get_flag(saved_enemy_id):
		queue_free()
		return

	add_to_group("enemy")
	home_position = global_position
	_apply_difficulty_scaling()
	hp = max_hp
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	_update_health_bar()


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	if hit_stun_time > 0.0:
		hit_stun_time -= delta
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 900.0 * delta)
	else:
		if player != null and global_position.distance_to(player.global_position) <= detection_radius:
			velocity = (player.global_position - global_position).normalized() * move_speed
		else:
			var offset: float = global_position.x - home_position.x
			if absf(offset) > 90.0:
				patrol_direction *= -1.0
			velocity = Vector2(patrol_direction * move_speed * 0.55, 0.0)

	move_and_slide()

	if player != null and global_position.distance_to(player.global_position) < 30.0:
		player.take_damage(1, global_position)


func take_damage(amount: int, knockback: Vector2) -> void:
	if amount <= 0:
		return

	hp -= amount
	_update_health_bar()
	hit_stun_time = 0.18
	knockback_velocity = knockback
	modulate = Color(1.0, 0.65, 0.65, 1.0)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		modulate = Color.WHITE

	if hp > 0:
		return

	if not saved_enemy_id.is_empty():
		GameState.set_flag(saved_enemy_id)

	_drop_coin_reward()

	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("show_status_message"):
		if not GameState.get_flag("slime_blaster_collected"):
			current_scene.show_status_message("The slime dropped a strange gun.")
		else:
			current_scene.show_status_message("The slime splats into goo.")
	queue_free()


func _update_health_bar() -> void:
	var ratio := 0.0 if max_hp <= 0 else clampf(float(hp) / float(max_hp), 0.0, 1.0)
	var left := -hp_bar_width * 0.5
	var right := left + hp_bar_width * ratio
	health_fill.points = PackedVector2Array([Vector2(left, 0), Vector2(right, 0)])


func _drop_coin_reward() -> void:
	if coin_reward <= 0 or get_parent() == null:
		return

	var pickup := COIN_PICKUP_SCENE.instantiate()
	get_parent().add_child(pickup)
	pickup.global_position = global_position
	pickup.amount = coin_reward


func _apply_difficulty_scaling() -> void:
	var difficulty := GameState.get_room_difficulty_multiplier(GameState.current_room_id)
	max_hp = maxi(max_hp, int(round(max_hp * lerpf(1.0, difficulty, 0.65))))
	move_speed *= lerpf(1.0, difficulty, 0.45)
	detection_radius *= lerpf(1.0, difficulty, 0.3)

