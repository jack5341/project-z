extends SpineSprite


func _ready() -> void:
	get_animation_state().set_animation("1 front - dance",false,0)
	get_animation_state().add_animation("1 front - idle",false,1)
	get_animation_state().add_animation("1 front - slash",false,2)
	get_animation_state().add_empty_animation(1,0.4,2)
	get_animation_state().add_empty_animation(2,0.4,2)
