extends State

@export var body:CharacterBody3D

@export var speed = 2.0

@export var climb_speed = 5.0

@export var next_state: State

@export var climb_bonus_time = 0.4

var has_reached_wall := false
var time_since_last_wall_touch := 0.0

func state_process(_delta:float):
	body.velocity = (Vector3.FORWARD) * speed
	time_since_last_wall_touch += _delta
	if(body.is_on_wall()):
		has_reached_wall = true
		time_since_last_wall_touch = 0
		body.velocity = (Vector3.UP) * climb_speed
		
	# We let it clima bit more if it temporarely stop touching the ship
	if(has_reached_wall && time_since_last_wall_touch>climb_bonus_time):
		try_set_state(next_state)

		
