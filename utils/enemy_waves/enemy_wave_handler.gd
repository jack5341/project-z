extends Node3D

class_name EnemyWaveHandler

#	Stores the animation names of the waves
#	in order. 
var wave_names: PackedStringArray
@onready var wave_animator: AnimationPlayer = $WaveAnimator

var curr_wave_id := 0

func _ready() -> void:
	wave_names = wave_animator.get_animation_list()
	
	# Remove Reset animation
	wave_names.remove_at(0)
	wave_names.sort()
	print("wave names: ", wave_names)
	
	# When the animation wave is over, start the next one!
	wave_animator.animation_finished.connect(
		func(_name):
			play_next_wave()
	)
	
	play_wave(0)

# When we start the next wave, we kill all the nodes
# spawned during the wave
func kill_all_spawned_nodes():
	for child in get_children():
		if(child != wave_animator):
			child.queue_free()

func _heal_players():
	var players := get_tree().get_nodes_in_group("players")
	for p in players:
		if(p is Player):
			p.heal_player()

func play_wave(wave_num:int):
	assert(wave_num < wave_names.size())
	kill_all_spawned_nodes()
	var animation_name := wave_names[wave_num]
	wave_animator.play(animation_name)
	_heal_players()
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

	
