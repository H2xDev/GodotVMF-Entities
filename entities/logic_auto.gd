@tool
class_name logic_auto
extends VMFEntityNode

## Fires outputs when the map loads
## Common outputs: OnMapSpawn, OnNewGame
func _entity_ready():
	# Fire OnMapSpawn output when the map loads
	trigger_output("OnMapSpawn")
