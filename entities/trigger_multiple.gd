@tool
class_name trigger_multiple
extends VMFEntityNode

const FLAG_CLIENTS = 1;

func get_filter_entity() -> filter_entity:
	var target_entity := get_target(entity.get("filtername", ""));

	if not target_entity: return null;

	return target_entity as filter_entity;

func _entity_ready() -> void:
	$area.body_entered.connect(func(body):
		var is_client_passed = has_flag(FLAG_CLIENTS) and VMFEntityNode.aliases.get("!player", null) == body;

		var filter = get_filter_entity();
		var is_filter_passed = filter.is_passed(body) if filter else false;

		if is_client_passed or is_filter_passed:
			trigger_output("OnTrigger");
			trigger_output("OnStartTouch");
	);

	$area.body_exited.connect(func(body):
		var is_client_passed = has_flag(FLAG_CLIENTS) and VMFEntityNode.aliases.get("!player", null) == body;
		var filter = get_filter_entity();
		var is_filter_passed = filter.is_passed(body) if filter else false;

		if is_client_passed or is_filter_passed: 
			trigger_output("OnEndTouch");
	);

func _entity_setup(_e: VMFEntity) -> void:
	$area/collision.shape = get_entity_shape();
