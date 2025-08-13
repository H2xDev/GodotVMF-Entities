@tool
class_name logic_relay
extends ValveIONode

func Trigger(_param = null):
	trigger_output("OnTrigger");
