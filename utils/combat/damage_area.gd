extends Area3D

#	Currently used as a flag to tell 
#	attackable body that this area
#	can do damage

class_name DamageArea

signal attackble_body_entered(area:AttackableBody)
signal on_cause_damage()

@export var base_damage:float = 1.0
@export var base_knockback:float = 1.0
@export var attackable_groups: Array[String] = []

func _ready() -> void:
	area_entered.connect(
		func(_other:Area3D):
			if(_other is AttackableBody):
				attackble_body_entered.emit(_other)
	)
	
	attackble_body_entered.connect(
		func(area: AttackableBody):
			if(attackable_groups.has(area.body_group)):
				on_cause_damage.emit()
				area.hit(self)
	)
	
