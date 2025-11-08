extends State

class_name EnemyOnShipState

@export var nav_agent: NavigationAgent3D

@export var body:CharacterBody3D

@export var max_speed = 8.0

@export var acceleration = 30.0

@export var gravity = 9.8

@export var max_fall_speed = 10.0

@export var min_distance = 5

@export_category("Attack")
@export var attack_scene: PackedScene
@export var attack_state: State 
@export var attack_delay := 1.0
@export var attack_distance := 1.0


var time_since_attack := 0.0
# Make the crab attack the player / target from different directions
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var random_target_offset:Vector3

var has_attacked_in_air := false

func _ready() -> void:
	update_random_target_offset()

func update_random_target_offset():
	random_target_offset = Vector3(rng.randf_range(-1, 1), 0, rng.randf_range(-1, 1))
	
func set_target(target: Vector3):
	nav_agent.target_position = target + random_target_offset

func set_horizontal_velocity(velocity:Vector2):
	body.velocity.x = velocity.x
	body.velocity.z = velocity.y
	
func limit_horizontal_velocity():
	var horizontal_velocity_scalar = get_horizontal_velocity().length()
	if(horizontal_velocity_scalar > max_speed):
		body.velocity.x /= horizontal_velocity_scalar / max_speed
		body.velocity.z /= horizontal_velocity_scalar / max_speed

func get_horizontal_velocity() -> Vector2:
	return Vector2(body.velocity.x, body.velocity.z)

func apply_gravity(delta:float):
	if(!body.is_on_floor()):
		body.velocity.y -= gravity * delta
		body.velocity.y = clampf(body.velocity.y, -max_fall_speed, max_fall_speed)

# Gets the target direction in horizontal plane
func get_target_dir() -> Vector2:
	var target3d = (nav_agent.get_next_path_position() - body.global_position).normalized()
	return Vector2(target3d.x, target3d.z)
	 
func accelerate_towards_target(delta:float):
	var curr_horizontal_velocity := get_horizontal_velocity()
	set_horizontal_velocity(
		curr_horizontal_velocity + 
		get_target_dir() * delta * acceleration
		)
		
func attack():
	time_since_attack = 0
	var attack_instance = attack_scene.instantiate()
	body.add_child(attack_instance)
	has_attacked_in_air = true

func state_process(_delta:float):
	time_since_attack += _delta
	# If close to the player, jump attack the player
	if(body.is_on_floor() && nav_agent.distance_to_target() < min_distance):
		try_set_state(attack_state)
		
	# If on floor, accelerate towards target
	elif(body.is_on_floor()):
		accelerate_towards_target(_delta)
		limit_horizontal_velocity()
		has_attacked_in_air = false
		
	apply_gravity(_delta)
