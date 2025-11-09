class_name ShipPart extends Node3D

@export var max_hp := 1
@onready var mesh_instance_3d: MeshInstance3D = $PlankType1

var hp: float
var _is_broken := false

func _ready() -> void:
	add_to_group("ship_parts")
	hp = max_hp

func _on_on_break() -> void:
	_is_broken = true
	mesh_instance_3d.visible = false

func repair() -> void:
	if _is_broken:
		print("repairing ship part: ", name)
		mesh_instance_3d.visible = true
		hp = max_hp
		_is_broken = false
	else:
		print("ship part is already repaired: ", name)
		
func take_damage(source: DamageArea):
	hp -= source.base_damage
	if(hp<=0):
		_on_on_break()

func get_is_broken():
	return _is_broken
