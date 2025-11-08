extends Node3D

@export var break_threshold: int = 1

var connected_parts := {}

func _ready() -> void:
	_connect_ship_parts()

func _connect_ship_parts() -> void:
	for child in get_children():
		if child is ShipPart:
			var part: ShipPart = child
			if not connected_parts.has(part):
				part.on_break.connect(_on_ship_part_break)
				connected_parts[part] = true
				print("Connected to ship part: ", part.name)

func _on_ship_part_break() -> void:
	var broken_count: int = 0
	for node in get_tree().get_nodes_in_group("ship_parts"):
		if node is ShipPart:
			var part: ShipPart = node
			if part.mesh_instance_3d.visible:
				broken_count += 1
	
	print("Ship part broke. Total broken parts: ", broken_count, " / ", break_threshold)
	if broken_count >= break_threshold:
		print("Game Over triggered!")
		get_tree().call_group("ui", "show_game_over")
