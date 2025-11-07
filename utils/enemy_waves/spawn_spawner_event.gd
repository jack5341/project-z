extends EnemyWaveEvent

class_name SpawnSpawnerEvent

@export_category("Spawn Properties")
@export var spawner_scene: PackedScene
@export var spawn_position: Vector3

@export_category("Spawner Properties")
@export var enemy_scene: PackedScene
@export var spawn_delay := 3.0
@export var max_enemies_spawned := 10
@export var max_spawn_time := 20.0
@export var position_randomness := Vector3.ZERO
@export var max_enemies_randomness := 0
@export var spawn_delay_randomness := 0.0

func execute(_wave_handler: EnemyWaveHandler):
	assert(spawner_scene)
	var spawner_instance: EnemySpawner = spawner_scene.instantiate()
	spawner_instance.position = spawn_position
	
	# Set properties (does it have to be done on ready?)
	spawner_instance.enemy_scene = enemy_scene
	spawner_instance.spawn_delay = spawn_delay
	spawner_instance.max_enemies_spawned = max_enemies_spawned
	spawner_instance.max_spawn_time = max_spawn_time
	spawner_instance.position_randomness = position_randomness
	spawner_instance.max_enemies_randomness = max_enemies_randomness
	spawner_instance.spawn_delay_randomness = spawn_delay_randomness
	
	_wave_handler.add_child(spawner_instance)
