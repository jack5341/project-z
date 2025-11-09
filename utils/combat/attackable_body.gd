extends Area3D

#	Set the body_group
#	to determine what can hit it
class_name AttackableBody

@export var owner_path: NodePath
@export var body_group: String = ""

var owner_entity: Node3D

func _ready() -> void:
	owner_entity = get_node(owner_path)
	# Verify as early as possible that the owner
	# exists and has the correct method
	# Crashing as early as possible makes
	# debugging easier!
	assert(owner_entity)
	assert(owner_entity.has_method("take_damage"))

# TODO, if we include the object that hit the entity
# in the take_damage function, we can define how the
# entity reacts to being hit by different objects,
# e.g. different knockbacks depending on weapon type
func hit(damage_area:DamageArea):
	if(owner_entity):
		owner_entity.take_damage(damage_area)
