extends State

@export var body: Player
@export var move_state: State
@export var dash_state: State
@export var jump_state: State
@export var attack_state: State

func _ready() -> void:
	enter_state.connect(
		func():
			if body != null:
				if body.has_method("is_node_ready") and not body.is_node_ready():
					await body.ready
				if body.spine != null:
					body.spine.play_animation("1 front - idle", true)
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

func state_process(delta: float) -> void:
	# Attack cooldown timer
	body.tap_elapse_attack += delta

	# Attack from idle
	if Input.is_action_pressed("player_attack") and body.tap_elapse_attack > body.attack_delay:
		try_set_state(attack_state)
		return

	# Movement input → move state
	var direction := _get_move_input()
	if direction != Vector3.ZERO:
		try_set_state(move_state)
		return

	# Jump from idle
	if body.is_on_floor() and Input.is_action_just_pressed("move_jump"):
		body.velocity.y = body.jump_force
		try_set_state(jump_state)
		return

	# Gravity while idle
	if not body.is_on_floor():
		body.velocity.y -= body.gravity * delta
	else:
		body.velocity.x = 0.0
		body.velocity.z = 0.0

	body.move_and_slide()
