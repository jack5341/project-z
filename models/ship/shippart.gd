class_name ShipPart extends AttackableBody

@export var max_hp := 1
@onready var mesh_instance_3d: MeshInstance3D = $PlankType1
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var hp: float

func _ready() -> void:
	add_to_group("ship_parts")
	# TODO: It does not make musch sense to inherit
	# from attackable body. Attackable body
	# should be a child node of this
	owner_entity = self
	hp = max_hp

func _on_on_break() -> void:
	collision_shape_3d.disabled = true
	mesh_instance_3d.visible = false

func repair() -> void:
	if collision_shape_3d.disabled or mesh_instance_3d.visible:
		print("repairing ship part: ", name)
		collision_shape_3d.disabled = false
		mesh_instance_3d.visible = true
		hp = max_hp

	else:
		print("ship part is already repaired: ", name)
		
func take_damage(source: DamageArea):
	hp -= source.base_damage
	if(hp<=0):
		_on_on_break()
