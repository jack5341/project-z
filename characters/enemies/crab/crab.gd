extends Enemy

@onready var walk_state: EnemyOnShipState = $MovementStateHandler/walkTowardsPlayerState

var target_node:Node3D
var hp:float

func _ready() -> void:
	hp = max_hp

func _knockback(_damage:float, dir: Vector3):
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

func _get_knockback_vector(damage_area: DamageArea):
	var delta_dist = (self.global_position - damage_area.global_position)
	delta_dist.y = 0
	var dir = delta_dist.normalized()
	return dir * damage_area.base_knockback

func take_damage(damage_area: DamageArea):
	hp -= damage_area.base_damage
	_knockback(damage_area.base_knockback, _get_knockback_vector(damage_area))
	if(hp <= 0):
		queue_free()
