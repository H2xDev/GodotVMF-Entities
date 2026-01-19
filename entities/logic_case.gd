@tool
class_name logic_case
extends VMFEntityNode

## Dictionary mapping case values (strings) to case numbers (1-16)
var cases: Dictionary = {}

## For PickRandomShuffle: list of available case numbers that haven't been used yet
var shuffle_pool: Array[int] = []

## For PickRandomShuffle: list of all defined case numbers
var all_case_numbers: Array[int] = []

func _entity_ready():
	# Initialize cases from Case01 to Case16 properties
	for i in range(1, 17):
		var case_key = "Case%02d" % i
		var case_value = entity.get(case_key, "")
		
		# Convert to string first, trim whitespace, then check if non-empty
		var str_value = str(case_value).strip_edges()
		if str_value != "":
			cases[str_value] = i
			all_case_numbers.append(i)
	
	# Initialize shuffle pool with all defined cases
	_reset_shuffle_pool()

## Resets the shuffle pool for PickRandomShuffle
func _reset_shuffle_pool():
	shuffle_pool = all_case_numbers.duplicate()
	shuffle_pool.shuffle()

# INPUTS

## Compares the input value to stored case values and fires the matching output
func InValue(param = null):
	if not enabled:
		return
	
	# Get value from parameter or activator (math_counter)
	var value = param if (param != null and str(param) != "" and str(param).to_lower() != "none") else (activator.value if activator != null else null)
	if value == null:
		return
	
	# Convert to string for comparison (numeric -> int string, string -> trimmed)
	var is_numeric = value is int or value is float
	var str_value = str(int(value)) if is_numeric else str(value).strip_edges()
	
	# Try matching case value, then try numeric as case number, else default
	var case_num: int
	if str_value in cases:
		case_num = cases[str_value]
	elif is_numeric:
		case_num = int(value)
		# Allow matching any case number 1-16, even if case parameter is empty
		if case_num < 1 or case_num > 16:
			trigger_output("OnDefault")
			return
	else:
		trigger_output("OnDefault")
		return
	
	trigger_output("OnCase%02d" % case_num)

## Fires a random output from the defined cases
func PickRandom(_param = null):
	if not enabled:
		return
	
	if all_case_numbers.is_empty():
		return
	
	# Pick a random case number from all defined cases
	var random_case = all_case_numbers[randi() % all_case_numbers.size()]
	var output_name = "OnCase%02d" % random_case
	trigger_output(output_name)

## Fires each output once in a random order before repeating
func PickRandomShuffle(_param = null):
	if not enabled:
		return
	
	if shuffle_pool.is_empty():
		# Reset the pool if empty
		_reset_shuffle_pool()
	
	if shuffle_pool.is_empty():
		return
	
	# Pick the first case from the shuffled pool
	var case_num = shuffle_pool.pop_front()
	var output_name = "OnCase%02d" % case_num
	trigger_output(output_name)
	
	# If pool is empty, reset it for the next cycle
	if shuffle_pool.is_empty():
		_reset_shuffle_pool()
