extends CharacterBody3D

@onready var on_ship_state: EnemyOnShipState = $MovementStateHandler/OnShipState


var target_node:Node3D

func knockback(_damage:float, dir: Vector3):
	velocity += dir

func get_target() -> Node3D:
	var players := get_tree().get_nodes_in_group("players")
	if(players && !players.is_empty()):
		return players[0]
	return null

func _physics_process(_delta: float) -> void:
	target_node = get_target()
	if(target_node is Node3D):
		on_ship_state.set_target(target_node.global_position)
	move_and_slide()
