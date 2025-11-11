@tool
class_name filter_activator_name extends filter_entity

var filter_name: String:
	get: return entity.get("filtername", "");

var is_inverted: bool:
	get: return str(entity.get("Negated", 0)) == "1";

func is_passed(node: Node3D) -> bool:
	var target_entity := get_entity(node);

	if not target_entity: return false;
	var target_name: String = target_entity.entity.get("targetname", "")

	return target_name == filter_name if not is_inverted else target_name != filter_name;
