extends State

@export var body: Player
@export var dash_state: State
@export var jump_state: State
@export var idle_state: State
@export var attack_state: State

func _ready() -> void:
	enter_state.connect(
		func():
			if body != null:
				if body.has_method("is_node_ready") and not body.is_node_ready():
					await body.ready
				if body.spine != null:
					body.spine.play_animation("1 front - walk", true)
	)

func _get_move_input() -> Vector3:
	var direction := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	return direction.normalized()

func _handle_attack() -> bool:
	if Input.is_action_pressed("player_attack") and body.tap_elapse_attack > body.attack_delay:
		try_set_state(attack_state)
		return true
	return false

func state_process(delta: float) -> void:
	# Attack cooldown timer
	body.tap_elapse_attack += delta

	var direction := _get_move_input()
	var is_moving := direction != Vector3.ZERO

	if _handle_attack():
		return

	# Switch to idle if no movement input
	if not is_moving and body.is_on_floor():
		try_set_state(idle_state)
		return

	var speed := body.move_speed

	# Dash
	if body.dash_cooldown_timer > 0.0:
		body.dash_cooldown_timer -= delta
	if Input.is_action_just_pressed("move_dash") and is_moving and body.dash_cooldown_timer <= 0.0:
		if "set_dash" in dash_state:
			dash_state.set_dash(direction)
		try_set_state(dash_state)
		return

	# Jump
	if body.is_on_floor() and Input.is_action_just_pressed("move_jump"):
		body.velocity.y = body.jump_force
		body.is_jumping = true
		try_set_state(jump_state)
		return

	# Gravity
	if not body.is_on_floor():
		body.velocity.y -= body.gravity * delta

	# Horizontal movement
	if direction != Vector3.ZERO:
		body.velocity.x = direction.x * speed
		body.velocity.z = direction.z * speed
	else:
		body.velocity.x = 0.0
		body.velocity.z = 0.0

	body.move_and_slide()
