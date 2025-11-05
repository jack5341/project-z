extends Resource

#	Abstract base class
#	for all wave events, such as
#	an enemy spawning, enemies or
#	water waves / bosses and 
#   other wave related events (even animations!)
#

class_name EnemyWaveEvent

@export_category("Event Execution Time")
@export var event_time: float = 0

# Abstract method for event execution
func execute(_wave_handler: EnemyWaveHandler):
	pass
