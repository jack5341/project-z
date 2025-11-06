extends Area3D

#	A body that can be attacked and has HP
#	Can be used by e.g. player, enemies and 
#	Destructable parts of the ship
#
#	Set the collision mask of the area3d
#	to determine what can hit it
class_name AttackableBody

signal on_break
signal on_hit(damage: float, knockback: float)

@export var health:float = 1 :
	get: return health
	set(new_health):
		health = new_health
		if(new_health<=0):
			on_break.emit()

@export var body_group:String = ""

func hit(damage: float, knockback: float):
	health -= damage
	on_hit.emit(damage, knockback)
