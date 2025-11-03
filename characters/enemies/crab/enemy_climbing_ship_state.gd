extends State

@export var body:CharacterBody3D

@export var speed = 10.0

@export var target_height = 10.0

@export var next_state: State


#	For now, climb untill it reaches a target height
#	later, this will be based on a collider on the ship
# 	/ an Area3d on the ship!
#

func state_process(_delta:float):
	body.velocity = Vector3.UP * speed
	if(body.global_position.y > target_height):
		try_set_state(next_state)
