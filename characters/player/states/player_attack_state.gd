extends State

@export var body: Player
@export var return_state: State

var has_started := false
var timer := 0.0
@export var attack_state_time := 0.15

func _ready() -> void:
	enter_state.connect(
		func():
			if body != null:
				if body.has_method("is_node_ready") and not body.is_node_ready():
					await body.ready
				if body.spine != null:
					body.spine.play_animation("1 front - slash", true)
	)

func state_process(delta: float) -> void:
	# Apply gravity while attacking
	if not body.is_on_floor():
		body.velocity.y -= body.gravity * delta
	else:
		body.velocity.x = 0.0
		body.velocity.z = 0.0

	body.move_and_slide()

	# Return to idle after a short, fixed attack state time
	timer += delta
	if timer >= attack_state_time:
		try_set_state(return_state)
