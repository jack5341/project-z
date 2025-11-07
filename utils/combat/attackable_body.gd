extends Area3D

#	A body that can be attacked and has HP
#	Can be used by e.g. player, enemies and 
#	Destructable parts of the ship
#
#	Set the collision mask of the area3d
#	to determine what can hit it
class_name AttackableBody

signal on_break

signal on_hit(damage: float, knockback: Vector3)

@export var max_health := 1

@export var body_group:String = ""

var health:float:
	get: return health
	set(new_health):
		health = min(new_health, max_health)
		if(new_health<=0):
			on_break.emit()

func _ready() -> void:
	health = max_health

func hit(damage: float, knockback: Vector3):
	health -= damage
	on_hit.emit(damage, knockback)
