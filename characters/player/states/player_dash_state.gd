extends State

@export var body: Player
@export var return_state: State

var dash_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

func set_dash(direction: Vector3) -> void:
	dash_direction = direction.normalized()

func _ready() -> void:
	enter_state.connect(
		func():
			if body != null:
				if body.has_method("is_node_ready") and not body.is_node_ready():
					await body.ready
				if body.spine != null:
					body.spine.play_animation("1 front - roll", true)
	)

func state_process(delta: float) -> void:
	if dash_timer > 0.0:
		dash_timer -= delta
		var current_y := body.velocity.y
		body.velocity = dash_direction * body.dash_force
		body.velocity.y = current_y
		body.move_and_slide()
	else:
		body.is_dashing = false
		body.dash_cooldown_timer = body.dash_cooldown
		try_set_state(return_state)
