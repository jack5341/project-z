extends SpineSprite


func play_animation(animation_name: String, looping := false):
	get_animation_state().set_animation(animation_name, looping, 0)
