extends CharacterBody3D

@onready var on_ship_state: EnemyOnShipState = $MovementStateHandler/OnShipState


@export var target_node:Node3D

func _ready() -> void:
	# If target is killed, set it to null
	if(target_node):
		target_node.tree_exiting.connect(
			func():
				target_node = null
		)

func knockback(_damage:float, dir: Vector3):
	velocity += dir

func _physics_process(_delta: float) -> void:
	if(target_node is Node3D):
		on_ship_state.set_target(target_node.global_position)
	move_and_slide()
