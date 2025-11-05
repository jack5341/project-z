extends EnemyWaveEvent

class_name SpawnEnemyEvent

@export_category("Spawn Properties")
@export var enemy_scene: PackedScene
@export var spawn_position: Vector3

func execute(_wave_handler: EnemyWaveHandler):
	assert(enemy_scene)
	var enemy_instance: Node3D = enemy_scene.instantiate()
	enemy_instance.position = spawn_position
	_wave_handler.add_child(enemy_instance)
