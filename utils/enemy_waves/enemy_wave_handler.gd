extends Node3D

class_name EnemyWaveHandler

#	Stores the animation names of the waves
#	in order. 
@export var wave_names: Array[String]
@onready var wave_animator: AnimationPlayer = $WaveAnimator

var curr_wave_id := 0

func _ready() -> void:
	play_wave(0)
	# When the animation wave is over, start the next one!
	wave_animator.animation_finished.connect(
		func(_name):
			play_next_wave()
	)

# When we start the next wave, we kill all the nodes
# spawned during the wave
func kill_all_spawned_nodes():
	for child in get_children():
		if(child != wave_animator):
			child.queue_free()

func play_wave(wave_num:int):
	assert(wave_num < wave_names.size())
	kill_all_spawned_nodes()
	var animation_name := wave_names[wave_num]
	wave_animator.play(animation_name)
	print("Playing wave: ", animation_name)
	
func play_next_wave():
	if(curr_wave_id+1 >= wave_names.size()):
		wave_animator.stop()
		print("TODO: All waves are over")
		return
	curr_wave_id += 1
	play_wave(curr_wave_id)

func execute_event(event: EnemyWaveEvent):
	event.execute(self)

	
