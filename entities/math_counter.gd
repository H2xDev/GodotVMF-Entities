@tool
class_name math_counter extends VMFEntityNode

var value := 0.0;

var start_value: float:
	get: return float(entity.get("startvalue", 0));

func _entity_ready() -> void:
	value = start_value;

# INPUTS

func Add(value_to_add: Variant) -> void:
	value += float(value_to_add);

	if value >= float(entity.get("max", 0)):
		trigger_output("OnHitMax");

	trigger_output("OutValue");

func Subtract(value_to_subtract: Variant) -> void:
	value -= float(value_to_subtract);

	if value <= float(entity.get("min", 0)):
		trigger_output("OnHitMin");

	trigger_output("OutValue");

func Multiply(value_to_multiply: Variant) -> void:
	value *= float(value_to_multiply);

	if value >= float(entity.get("max", 0)):
		trigger_output("OnHitMax");

	trigger_output("OutValue");

func Divide(value_to_divide: Variant) -> void:
	value /= float(value_to_divide);

	if value <= float(entity.get("min", 0)):
		trigger_output("OnHitMin");

	trigger_output("OutValue");

func GetValue(_param: Variant = null) -> void:
	trigger_output("OnGetValue");

func SetValue(_param: Variant = null) -> void:
	value = activator.value;
	trigger_output("OutValue");

func SetMinValueNoFire(value_to_set: Variant) -> void:
	entity.min = value_to_set;
	trigger_output("OutValue");

func SetMaxValueNoFire(value_to_set: Variant) -> void:
	entity.max = value_to_set;
	trigger_output("OutValue");

func SetHitMinOutputNoFire(output_to_set: Variant) -> void:
	entity.min = output_to_set;

func SetHitMaxOutputNoFire(output_to_set: Variant) -> void:
	entity.max = output_to_set;
