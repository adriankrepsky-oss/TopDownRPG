extends CanvasLayer

const JOYSTICK_RADIUS := 60.0
const THUMB_RADIUS := 24.0
const DEAD_ZONE := 0.15

var joystick_touch_index: int = -1
var jump_touch_index: int = -1
var attack_touch_index: int = -1
var heavy_touch_index: int = -1
var joystick_center := Vector2.ZERO
var joystick_input := Vector2.ZERO

@onready var joystick_base: Control = $JoystickBase
@onready var joystick_thumb: Control = $JoystickBase/Thumb
@onready var jump_button: Control = $JumpButton


func _ready() -> void:
	layer = 10
	joystick_center = joystick_base.get_rect().get_center()
	# Apply saved position/scale from GameState
	_apply_touch_settings()


func _apply_touch_settings() -> void:
	var s: float = GameState.touch_button_scale
	# Scale joystick
	joystick_base.scale = Vector2(s, s)
	joystick_base.position = Vector2(GameState.touch_joystick_x, GameState.touch_joystick_y)
	# Scale jump button
	jump_button.scale = Vector2(s, s)
	jump_button.position = Vector2(GameState.touch_attack_x, GameState.touch_attack_y)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Check if touch is on the jump button side (right half of screen)
		if _is_in_jump_area(event.position):
			# Upper right = heavy attack, lower right = jump
			if event.position.y < get_viewport().get_visible_rect().size.y * 0.5:
				heavy_touch_index = event.index
				Input.action_press("fighter_heavy")
			else:
				jump_touch_index = event.index
				Input.action_press("fighter_jump")
				jump_button.modulate = Color(1.2, 1.2, 1.2, 1)
		# Middle area = light attack
		elif _is_in_attack_area(event.position):
			attack_touch_index = event.index
			Input.action_press("fighter_light")
		# Check if touch is on joystick side (left half of screen)
		elif _is_in_joystick_area(event.position):
			joystick_touch_index = event.index
			_update_joystick(event.position)
	else:
		if event.index == joystick_touch_index:
			joystick_touch_index = -1
			joystick_input = Vector2.ZERO
			joystick_thumb.position = Vector2.ZERO
			_release_movement()
		if event.index == jump_touch_index:
			jump_touch_index = -1
			Input.action_release("fighter_jump")
			jump_button.modulate = Color(1, 1, 1, 1)
		if event.index == attack_touch_index:
			attack_touch_index = -1
			Input.action_release("fighter_light")
		if event.index == heavy_touch_index:
			heavy_touch_index = -1
			Input.action_release("fighter_heavy")


func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == joystick_touch_index:
		_update_joystick(event.position)


func _update_joystick(touch_pos: Vector2) -> void:
	var base_center := joystick_base.global_position + joystick_base.size * 0.5 * GameState.touch_button_scale
	var direction := touch_pos - base_center
	var distance := direction.length()

	if distance > JOYSTICK_RADIUS * GameState.touch_button_scale:
		direction = direction.normalized() * JOYSTICK_RADIUS * GameState.touch_button_scale

	joystick_thumb.position = direction / GameState.touch_button_scale
	joystick_input = direction / (JOYSTICK_RADIUS * GameState.touch_button_scale)

	# Apply dead zone
	if absf(joystick_input.x) < DEAD_ZONE:
		joystick_input.x = 0.0

	# Down input for drop-through
	if joystick_input.y > 0.5:
		Input.action_press("fighter_down", joystick_input.y)
	else:
		Input.action_release("fighter_down")

	_apply_movement()


func _apply_movement() -> void:
	if joystick_input.x < 0.0:
		Input.action_press("fighter_left", absf(joystick_input.x))
		Input.action_release("fighter_right")
	elif joystick_input.x > 0.0:
		Input.action_press("fighter_right", absf(joystick_input.x))
		Input.action_release("fighter_left")
	else:
		_release_movement()


func _release_movement() -> void:
	Input.action_release("fighter_left")
	Input.action_release("fighter_right")
	Input.action_release("fighter_down")


func _is_in_joystick_area(pos: Vector2) -> bool:
	var viewport_size := get_viewport().get_visible_rect().size
	return pos.x < viewport_size.x * 0.35


func _is_in_attack_area(pos: Vector2) -> bool:
	var viewport_size := get_viewport().get_visible_rect().size
	return pos.x > viewport_size.x * 0.35 and pos.x < viewport_size.x * 0.65


func _is_in_jump_area(pos: Vector2) -> bool:
	var viewport_size := get_viewport().get_visible_rect().size
	return pos.x > viewport_size.x * 0.55
