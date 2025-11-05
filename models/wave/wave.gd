class_name Wave extends Area3D

signal wave_hit(damage: int, body: Node)

enum WaveSize {
	Small,
	Medium,
	Big
}

@export var wave_size: WaveSize = WaveSize.Small

@export var small_wave_size: Vector3 = Vector3(0.5, 0.5, 0.5)
@export var medium_wave_size: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var big_wave_size: Vector3 = Vector3(1.5, 1.5, 1.5)

@export var speed: float = 5.0
@export var damage: int = 10
@export var direction: Vector3 = Vector3(1, 0, 0)
@export var despawn_x: float = 120.0

func _ready():
	match wave_size:
		WaveSize.Small:
			scale = small_wave_size
		WaveSize.Medium:
			scale = medium_wave_size
		WaveSize.Big:
			scale = big_wave_size
	
	# Detect collisions with bodies (e.g., the ship)
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	if direction.length() > 0.0:
		global_translate(direction.normalized() * speed * _delta)
		# Despawn when past boundary along X
		if direction.x >= 0.0 and global_position.x >= despawn_x:
			queue_free()
		elif direction.x < 0.0 and global_position.x <= despawn_x:
			queue_free()

func _on_body_entered(body: Node) -> void:
	emit_signal("wave_hit", damage, body)
	queue_free()
