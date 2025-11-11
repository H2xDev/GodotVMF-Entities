@tool
class_name logic_relay extends VMFEntityNode

func Trigger(_param: Variant = null) -> void:
	trigger_output("OnTrigger");
