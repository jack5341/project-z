extends State

@export var body: Player
@export var return_state: State

func _ready() -> void:
	enter_state.connect(
		func():
			if body != null:
				if body.has_method("is_node_ready") and not body.is_node_ready():
					await body.ready
				if body.spine != null:
					body.spine.play_animation("1 front - jump", true)
	)

func state_process(delta: float) -> void:
	# Apply gravity
	if not body.is_on_floor():
		body.velocity.y -= body.gravity * delta
	else:
		# Landed
		try_set_state(return_state)
		return

	# Maintain horizontal velocity during jump/fall (no input-driven change here)
	body.move_and_slide()
