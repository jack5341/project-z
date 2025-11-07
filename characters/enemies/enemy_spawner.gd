extends Node3D

#	A node that spawns enemies at time intervals.
#	Children are added as siblings to this node
#
#
class_name EnemySpawner

var rng := RandomNumberGenerator.new()

@export_category("Spawn Properties")
@export var enemy_scene: PackedScene
@export var spawn_delay := 3.0
@export var max_enemies_spawned := 10

# The maximum time the spawner can be active
@export var max_spawn_time := 20.0

@export_category("Spawn Randomness")
@export var position_randomness := Vector3.ZERO
@export var max_enemies_randomness := 0 :
	set(value):
		assert(value>=0)
		max_enemies_randomness = value
		max_enemies_spawned += rng.randi_range(0, value)
@export var spawn_delay_randomness := 0.0 :
	set(value):
		assert(value>=0)
		if(spawn_timer):
			spawn_timer.wait_time = spawn_delay + rng.randf_range(-value, value)
		spawn_delay_randomness = value

@onready var auto_remove_timer: Timer = $AutoRemoveTimer
@onready var spawn_timer: Timer = $SpawnTimer



var enemies_spawned := 0:
	set(value):
		if(value >= max_enemies_spawned):
			print("VALUE: ", value)
			queue_free()
		enemies_spawned = value

func _ready() -> void:
	auto_remove_timer.wait_time = max_spawn_time
	spawn_timer.wait_time = spawn_delay
	spawn_timer.timeout.connect(
		func():
			spawn_timer.wait_time = (
				spawn_delay + 
				rng.randf_range(-spawn_delay_randomness, spawn_delay_randomness)
				)
	)
	
func spawn_enemy():
	assert(enemy_scene)
	var instance:Node3D = enemy_scene.instantiate()
	var pos := Vector3(
		rng.randf_range(-1, 1),
		rng.randf_range(-1, 1), 
		rng.randf_range(-1, 1),
		)
	pos *= 2.0 * position_randomness
	instance.position = pos
	get_parent().add_child(instance)
	enemies_spawned += 1
