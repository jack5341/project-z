extends CharacterBody3D

@onready var on_ship_state: EnemyOnShipState = $MovementStateHandler/OnShipState


@export var target_node:Node3D

func _physics_process(_delta: float) -> void:
	if(target_node is Node3D):
		on_ship_state.set_target(target_node.global_position)
	move_and_slide()
