extends Node

#	A finite state machine used to make
#	state handeling more managable.
#
# 	The first child state will be the 
#	initially active state
#
#	The class assumes that all children
# 	are states

class_name StateMachine

var curr_state: State :
	set(new_state):
		assert(new_state is State)
		curr_state = new_state
		curr_state.enter_state.emit()
	get: 
		return curr_state

# Set the new state. Only the current state 
# is allowed to change the state.
# This simplifies the implementation of states
func try_set_state(caller: State, new_state: State):
	if(caller == curr_state):
		curr_state = new_state

func _ready() -> void:
	if(get_child_count()>0):
		curr_state = get_child(0)

func _physics_process(delta: float) -> void:
	if(curr_state != null):
		curr_state.state_process(delta)
