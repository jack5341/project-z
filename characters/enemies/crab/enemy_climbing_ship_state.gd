extends State

@export var body:CharacterBody3D

@export var speed = 2.0

@export var climb_speed = 5.0

@export var next_state: State

@export var climb_bonus_time = 0.4

var has_reached_wall := false
#	For now, climb untill it reaches a target z
#	later, this will be based on a collider on the ship
# 	/ an Area3d on the ship!
#
func state_process(_delta:float):
	body.velocity = (Vector3.FORWARD) * speed
	
	if(body.is_on_wall()):
		has_reached_wall = true
		body.velocity = (Vector3.UP) * climb_speed
		
	# We let it clima bit more when it reaches the edge
	if(has_reached_wall && !(body.is_on_wall()) && get_child_count()==0):
		# Add timer to change state
		var timer := Timer.new()
		timer.autostart = true
		timer.wait_time = climb_bonus_time
		timer.timeout.connect(
			func():
				try_set_state(next_state)
				timer.queue_free()
		)
		add_child(timer)
		
