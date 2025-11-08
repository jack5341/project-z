extends CharacterBody3D

@onready var walk_state: EnemyOnShipState = $MovementStateHandler/walkTowardsPlayerState

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
	# Todo, this is a bit ugly, I think
	# the state itself should get this
	# info?
	if(target_node is Node3D):
		walk_state.set_target(target_node.global_position)
	move_and_slide()
