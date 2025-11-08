class_name ShipPart extends AttackableBody

@onready var mesh_instance_3d: MeshInstance3D = $PlankType1
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	add_to_group("ship_parts")

func _on_on_break() -> void:
	collision_shape_3d.disabled = true
	mesh_instance_3d.visible = false

func repair() -> void:
	if collision_shape_3d.disabled or mesh_instance_3d.visible:
		print("repairing shddddip part: ", name)
		collision_shape_3d.disabled = false
		mesh_instance_3d.visible = true
		health = max_health
	else:
		print("ship part is already repaired: ", name)
