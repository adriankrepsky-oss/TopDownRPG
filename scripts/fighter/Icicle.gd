extends Area2D

var direction: float = 1.0
var damage: float = 8.0
var knockback: float = 200.0
var max_range: float = 400.0
var speed: float = 600.0
var slow_duration: float = 0.5
var slow_amount: float = 0.5
var owner_fighter: CharacterBody2D = null

var _start_x: float = 0.0


func _ready() -> void:
	_start_x = global_position.x
	body_entered.connect(_on_body_entered)
	# Flip visuals if going left
	if direction < 0.0:
		$IcicleBody.scale.x = -1.0
		$IcicleGlow.scale.x = -1.0


func _physics_process(delta: float) -> void:
	global_position.x += direction * speed * delta
	if absf(global_position.x - _start_x) >= max_range:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not is_instance_valid(body):
		return
	if is_instance_valid(owner_fighter) and body == owner_fighter:
		return
	# Skip teammates in 2v2
	if is_instance_valid(owner_fighter) and "team_id" in owner_fighter and "team_id" in body:
		if body.team_id == owner_fighter.team_id:
			return
	if body is CharacterBody2D and body.has_method("take_hit"):
		var kb_dir := Vector2(direction, -0.3).normalized()
		body.take_hit(damage, kb_dir, knockback)
		if body.has_method("apply_slow"):
			body.apply_slow(slow_duration, slow_amount)
	queue_free()
