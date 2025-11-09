extends Viewport

@export var health_entity_path: NodePath
@onready var health_progress_bar: ProgressBar = $Container/HealthProgressBar

var health_entity:Node3D

func _ready() -> void:
	health_entity = get_node(health_entity_path)
	assert(health_entity)
	# Health entites must define hp and max_hp
	assert("hp" in health_entity)
	assert("max_hp" in health_entity)

func _process(_delta: float) -> void:
	health_progress_bar.max_value = health_entity.max_hp
	health_progress_bar.value = health_entity.hp
