@tool
class_name trigger_multiple extends VMFEntityNode

const FLAG_CLIENTS = 1;
const FLAG_NPCS = 2;

var touching_entities: Array = []
var touching_timer: Timer

func get_filter_entity() -> filter_entity:
	var target_entity = get_target(entity.get("filtername", ""));

	if not target_entity: return null;

	return target_entity as filter_entity;

func _entity_ready():
	# Setup timer for OnTouching output
	touching_timer = Timer.new()
	touching_timer.wait_time = 0.1
	touching_timer.one_shot = false
	touching_timer.timeout.connect(_on_touching_timer_timeout)
	add_child(touching_timer)
	
	$area.body_entered.connect(func(body):
		var is_client_passed = has_flag(FLAG_CLIENTS) and VMFEntityNode.aliases["!player"] == body;
		var is_npc_passed = has_flag(FLAG_NPCS) and body.get_groups().has('npc');
		var filter = get_filter_entity();
		var is_filter_passed = filter.is_passed(body) if filter else false;

		if is_client_passed or is_filter_passed or is_npc_passed:
			if not touching_entities.has(body):
				touching_entities.append(body)
				# Start timer if this is the first entity
				if touching_entities.size() == 1:
					touching_timer.start()
			trigger_output("OnTrigger");
			trigger_output("OnStartTouch");
	);

	$area.body_exited.connect(func(body):
		var is_client_passed = has_flag(FLAG_CLIENTS) and VMFEntityNode.aliases["!player"] == body;
		var is_npc_passed = has_flag(FLAG_NPCS) and body.get_groups().has('npc');
		var filter = get_filter_entity();
		var is_filter_passed = filter.is_passed(body) if filter else false;

		if is_client_passed or is_filter_passed or is_npc_passed:
			var index = touching_entities.find(body)
			if index != -1:
				touching_entities.remove_at(index)
			trigger_output("OnEndTouch");
			
			# Stop timer and fire OnNotTouching when no valid entities are touching
			if touching_entities.is_empty():
				touching_timer.stop()
				trigger_output("OnNotTouching");
	);

func _on_touching_timer_timeout():
	if not touching_entities.is_empty():
		trigger_output("OnTouching");

func _entity_setup(_e: VMFEntity) -> void:
	$area/collision.shape = get_entity_shape();
