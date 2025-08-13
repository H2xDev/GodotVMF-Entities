@tool
class_name trigger_once
extends ValveIONode

func _entity_ready():
	# NOTE: Call deffered is used to prevent unexpected trigger after player spawn
	$area.body_entered.connect.call_deferred(func(_node):
		if not enabled: return;
		if "!player" in ValveIONode.aliases and ValveIONode.aliases["!player"] == _node: 
			print("Triggered by player");
			trigger_output("OnTrigger");
			queue_free();
	);

func _apply_entity(e):
	super._apply_entity(e);
	
	$area/collision.shape = get_entity_shape();
