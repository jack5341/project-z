extends State

@export_category("Movement")
@export var gravity := 9.8
@export var max_fall_speed = 10.0
@export var jump_height := 3.0
@export var jump_length := 6.0
@export var walk_state: State

@export_category("Attack")
@export var attack_scene: PackedScene
@export var body : CharacterBody3D
@onready var attack_charge_animator: AnimationPlayer = $attackChargeAnimator

var has_jumped := false

func _get_target_pos() -> Vector3:
	var players := get_tree().get_nodes_in_group("players")
	if(!players):
		return Vector3.ZERO
	players.sort_custom(
		func(a:Node3D, b:Node3D):
			return (
				a.global_position.distance_squared_to(body.global_position) 
				< 
				b.global_position.distance_squared_to(body.global_position) 
				)
			)
	return players.front().global_position

func _attack():
	var attack_instance = attack_scene.instantiate()
	body.add_child(attack_instance)

func _set_horizontal_velocity(velocity:Vector2):
	body.velocity.x = velocity.x
	body.velocity.z = velocity.y

# Starts the jump of the attack. Can deal damage during this jump
func jump():
	var player_delta := (_get_target_pos() - body.global_position)
	var player_dir2d := Vector2(player_delta.x, player_delta.z).normalized()
	_set_horizontal_velocity(player_dir2d*jump_length)
	body.velocity.y = jump_height
	has_jumped = true

# Charge up and jump towards the players location
func _ready() -> void:
	enter_state.connect(
		func():
			attack_charge_animator.play("attack")
			body.velocity = Vector3.ZERO
	)

func apply_gravity(delta:float):
	if(!body.is_on_floor()):
		body.velocity.y -= gravity * delta
		body.velocity.y = clampf(body.velocity.y, -max_fall_speed, max_fall_speed)

var time_since_jump := 0.0
func state_process(_delta:float):
	if(has_jumped):
		time_since_jump += _delta
	if(time_since_jump > 0.5 && body.is_on_floor()):
		try_set_state(walk_state)
	apply_gravity(_delta)
