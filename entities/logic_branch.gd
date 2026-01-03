@tool
class_name logic_branch
extends VMFEntityNode

## Current boolean value stored by the logic_branch entity
var current_value: bool = false

func _entity_ready():
	# Initialize the value from the entity's InitialValue property
	# In Source, 0 = false, 1 = true
	var initial_value = entity.get("InitialValue", 0)
	current_value = (initial_value == 1)

# INPUTS

## Sets the boolean value without triggering outputs
func SetValue(param = null):
	if param == null:
		return
	
	# Convert param to boolean (0 = false, 1 = true, or string "0"/"1")
	var bool_value = false
	if param is int or param is float:
		bool_value = (param == 1)
	elif param is String:
		bool_value = (param == "1" or param.to_lower() == "true")
	else:
		bool_value = bool(param)
	
	current_value = bool_value

## Sets the boolean value and triggers outputs based on the new value
func SetValueTest(param = null):
	SetValue(param)
	_evaluate_and_trigger()

## Toggles the boolean value without triggering outputs
func Toggle(_param = null):
	current_value = !current_value

## Toggles the boolean value and triggers outputs based on the new value
func ToggleTest(_param = null):
	Toggle()
	_evaluate_and_trigger()

## Evaluates the current value and triggers the appropriate output
func Test(_param = null):
	_evaluate_and_trigger()

# INTERNAL FUNCTIONS

## Evaluates the current value and triggers OnTrue or OnFalse output
func _evaluate_and_trigger():
	if not enabled:
		return
	
	if current_value:
		trigger_output("OnTrue")
	else:
		trigger_output("OnFalse")
