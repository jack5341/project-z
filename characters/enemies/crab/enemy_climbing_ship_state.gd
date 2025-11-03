extends State

@export var body:CharacterBody3D

@export var speed = 2.0

@export var climb_speed = 5.0

@export var target_z = 5.75

@export var next_state: State


#	For now, climb untill it reaches a target z
#	later, this will be based on a collider on the ship
# 	/ an Area3d on the ship!
#
func state_process(_delta:float):
	body.velocity = (Vector3.FORWARD) * speed
	
	if(body.is_on_wall()):
		body.velocity = (Vector3.UP) * climb_speed
	
	if(body.global_position.z < target_z):
		try_set_state(next_state)
