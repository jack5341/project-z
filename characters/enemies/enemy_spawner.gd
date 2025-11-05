extends Node3D

#	A node that spawns enemies at time intervals.
#	Children are added as siblings to this node
#
#
class_name EnemySpawner

@export_category("Spawn Properties")
@export var enemy_scene: PackedScene
@export var spawn_delay := 3.0
@export var max_enemies_spawned := 10

# The maximum time the spawner can be active
@export var max_spawn_time := 20.0

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
	
func spawn_enemy():
	assert(enemy_scene)
	var instance := enemy_scene.instantiate()
	get_parent().add_child(instance)
	enemies_spawned+=1
