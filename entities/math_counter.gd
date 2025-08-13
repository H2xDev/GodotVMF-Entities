@tool
class_name math_counter
extends ValveIONode

var value = 0;

func _entity_ready():
	value = float(entity.get("startvalue", 0));

# INPUTS

func Add(value_to_add):
	value += float(value_to_add);

	if value >= float(entity.get("max", 0)):
		trigger_output("OnHitMax");

	trigger_output("OutValue");

func Subtract(value_to_subtract):
	value -= float(value_to_subtract);

	if value <= float(entity.get("min", 0)):
		trigger_output("OnHitMin");

	trigger_output("OutValue");

func Multiply(value_to_multiply):
	value *= float(value_to_multiply);

	if value >= float(entity.get("max", 0)):
		trigger_output("OnHitMax");

	trigger_output("OutValue");

func Divide(value_to_divide):
	value /= float(value_to_divide);

	if value <= float(entity.get("min", 0)):
		trigger_output("OnHitMin");

	trigger_output("OutValue");

func GetValue(_param = null):
	trigger_output("OnGetValue");

func SetValue(_param = null):
	value = activator.value;
	trigger_output("OutValue");

func SetMinValueNoFire(value_to_set):
	entity.min = value_to_set;
	trigger_output("OutValue");

func SetMaxValueNoFire(value_to_set):
	entity.max = value_to_set;
	trigger_output("OutValue");

func SetHitMinOutputNoFire(output_to_set):
	entity.min = output_to_set;

func SetHitMaxOutputNoFire(output_to_set):
	entity.max = output_to_set;
