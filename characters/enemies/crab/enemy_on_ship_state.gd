extends State

class_name EnemyOnShipState

@export var nav_agent: NavigationAgent3D

@export var body:CharacterBody3D

@export var speed = 10.0

@export var gravity = 9.8

@export var max_fall_speed = 10.0

@export var min_distance = 0.5

func set_target(target: Vector3):
	nav_agent.target_position = target

func set_horizontal_velocity(velocity:Vector2):
	body.velocity.x = velocity.x
	body.velocity.z = velocity.y

func apply_gravity(delta:float):
	if(!body.is_on_floor()):
		body.velocity.y -= gravity * delta
		body.velocity.y = clampf(body.velocity.y, -max_fall_speed, max_fall_speed)

# Gets the target direction in horizontal plane
func get_target_dir() -> Vector2:
	var target3d = (nav_agent.get_next_path_position() - body.global_position).normalized()
	return Vector2(target3d.x, target3d.z)
	 
func state_process(_delta:float):
	if(nav_agent.distance_to_target() < min_distance):
		set_horizontal_velocity(Vector2.ZERO)
	else:
		set_horizontal_velocity(speed * get_target_dir())
	apply_gravity(_delta)
