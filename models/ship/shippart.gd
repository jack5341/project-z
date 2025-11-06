class_name ShipPart extends AttackableBody

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _on_on_break() -> void:
	collision_shape_3d.disabled = true
	mesh_instance_3d.visible = true
