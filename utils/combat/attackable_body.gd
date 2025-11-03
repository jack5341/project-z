extends Area3D

#	A body that can be attacked and has HP
#	Can be used by e.g. player, enemies and 
#	Destructable parts of the ship
#
#	Set the collision mask of the area3d
#	to determine what can hit it
#

class_name AttackableBody

signal on_break

signal on_hit

@export var health:float = 1 :
	get: return health
	set(new_health):
		health = new_health
		if(new_health<=0):
			on_break.emit()

func _ready() -> void:
	area_entered.connect(
		func(other:Area3D):
			if(other is DamageArea):
				health -= other.base_damage
				on_hit.emit()
				
	)
