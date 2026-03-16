extends Area2D
class_name Chicken

@export var completion_flag := ""
@export var roam_speed := 42.0
@export var flee_speed := 86.0
@export var roam_radius := 96.0
@export var reward_coins := 1
@export var catch_message := "Chicken caught."

@onready var body: Polygon2D = $Body
@onready var wing: Polygon2D = $Wing
@onready var beak: Polygon2D = $Beak
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var home_position := Vector2.ZERO
var velocity := Vector2.ZERO
var drift_time := 0.0
var rng := RandomNumberGenerator.new()
var player: Node2D


func _ready() -> void:
	if not completion_flag.is_empty() and GameState.get_flag(completion_flag):
		queue_free()
		return

	body_entered.connect(_on_body_entered)
	rng.randomize()
	home_position = global_position
	player = get_tree().get_first_node_in_group("player") as Node2D


func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D

	drift_time -= delta
	var desired_velocity := Vector2.ZERO
	if player != null:
		var to_player := global_position - player.global_position
		var distance := to_player.length()
		if distance < 120.0 and distance > 0.001:
			desired_velocity = to_player.normalized() * flee_speed
	elif drift_time <= 0.0:
		drift_time = rng.randf_range(0.6, 1.4)
		desired_velocity = Vector2.RIGHT.rotated(rng.randf_range(-PI, PI)) * roam_speed

	if desired_velocity == Vector2.ZERO and drift_time <= 0.0:
		drift_time = rng.randf_range(0.6, 1.4)
		desired_velocity = Vector2.RIGHT.rotated(rng.randf_range(-PI, PI)) * roam_speed

	if global_position.distance_to(home_position) > roam_radius:
		desired_velocity = (home_position - global_position).normalized() * roam_speed

	velocity = velocity.move_toward(desired_velocity, 240.0 * delta)
	global_position += velocity * delta
	rotation = lerp_angle(rotation, velocity.angle() * 0.08, 8.0 * delta)
	wing.rotation = sin(Time.get_ticks_msec() * 0.02) * 0.14


func _on_body_entered(node: Node2D) -> void:
	if not node.is_in_group("player"):
		return
	if not completion_flag.is_empty():
		GameState.set_flag(completion_flag)
	if reward_coins > 0:
		GameState.add_coins(reward_coins)
	var current_scene := get_tree().current_scene
	if current_scene != null and current_scene.has_method("show_status_message"):
		current_scene.show_status_message(catch_message)
	queue_free()
