class_name WaveManager extends Node

@export var wave_count: int = 0	# 0 or less = unlimited spawning
@export var wave_interval: float = 2.0
@export var max_concurrent: int = 8

# Spawn configuration (world space)
@export var spawn_x_start: float = -120.0
@export var spawn_y: float = 0.2
@export var spawn_z_range: Vector2 = Vector2(-45.0, 45.0)
@export var move_direction: Vector3 = Vector3(1, 0, 0)
@export var despawn_x: float = 120.0

# Speed and damage ranges per size
@export var small_speed_range: Vector2 = Vector2(6.0, 9.0)
@export var medium_speed_range: Vector2 = Vector2(4.0, 6.0)
@export var big_speed_range: Vector2 = Vector2(2.5, 4.0)

@export var small_damage_range: Vector2i = Vector2i(15, 25)
@export var medium_damage_range: Vector2i = Vector2i(30, 45)
@export var big_damage_range: Vector2i = Vector2i(50, 80)

@export var wave_scene: PackedScene = preload("res://models/wave/wave.tscn")

var _rng := RandomNumberGenerator.new()
var _spawned_total: int = 0
var _timer: Timer

const WaveScript := preload("res://models/wave/wave.gd")

func _ready():
	_rng.randomize()
	_timer = Timer.new()
	_timer.wait_time = wave_interval
	_timer.autostart = true
	_timer.one_shot = false
	add_child(_timer)
	_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	if wave_count > 0 and _spawned_total >= wave_count:
		_timer.stop()
		return
	if _get_active_wave_count() >= max_concurrent:
		return
	_spawn_wave()

func _get_active_wave_count() -> int:
	var count := 0
	for child in get_children():
		if child is Area3D and child.get_script() == WaveScript:
			count += 1
	return count

func _spawn_wave() -> void:
	if wave_scene == null:
		return
	var wave: Node3D = wave_scene.instantiate()
	var z := _rng.randf_range(spawn_z_range.x, spawn_z_range.y)
	wave.global_position = Vector3(spawn_x_start, spawn_y, z)
	
	# Randomize size
	var size_index := _rng.randi_range(0, 2)
	var wave_size := size_index
	# Apply size, speed and damage based on size
	var speed := _pick_speed_for_size(size_index)
	var damage := _pick_damage_for_size(size_index)
	
	# Set Wave script properties
	# Using duck typing so scene keeps its own script
	wave.set("wave_size", wave_size)
	wave.set("speed", speed)
	wave.set("damage", damage)
	wave.set("direction", move_direction)
	wave.set("despawn_x", despawn_x)
	
	add_child(wave)
	_spawned_total += 1
	
	# Connect signals if available
	if wave.has_signal("wave_hit"):
		wave.connect("wave_hit", Callable(self, "_on_wave_hit"))
	wave.tree_exited.connect(_on_wave_finished)

func _pick_speed_for_size(size_index: int) -> float:
	match size_index:
		WaveScript.WaveSize.Small:
			return _rng.randf_range(small_speed_range.x, small_speed_range.y)
		WaveScript.WaveSize.Medium:
			return _rng.randf_range(medium_speed_range.x, medium_speed_range.y)
		WaveScript.WaveSize.Big:
			return _rng.randf_range(big_speed_range.x, big_speed_range.y)
	return 5.0

func _pick_damage_for_size(size_index: int) -> int:
	match size_index:
		WaveScript.WaveSize.Small:
			return _rng.randi_range(small_damage_range.x, small_damage_range.y)
		WaveScript.WaveSize.Medium:
			return _rng.randi_range(medium_damage_range.x, medium_damage_range.y)
		WaveScript.WaveSize.Big:
			return _rng.randi_range(big_damage_range.x, big_damage_range.y)
	return 10

func _on_wave_finished() -> void:
	# Placeholder for bookkeeping; active waves are counted dynamically
	pass

func _on_wave_hit(damage: int, body: Node) -> void:
	# TODO: Integrate with ship health here
	# print("Wave hit ", body.name, " for ", damage, " damage")
	pass
