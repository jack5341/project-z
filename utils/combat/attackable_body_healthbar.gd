extends Viewport

@export var attackable_body: AttackableBody

@onready var health_progress_bar: ProgressBar = $Container/HealthProgressBar

func _process(_delta: float) -> void:
	if(attackable_body):
		health_progress_bar.max_value = attackable_body.max_health
		health_progress_bar.value = attackable_body.health
