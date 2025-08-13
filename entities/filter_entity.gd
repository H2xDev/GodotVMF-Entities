@tool
class_name filter_entity extends ValveIONode

func get_entity(node):
	if node is ValveIONode: return node;
	if node.get_parent() == null: return null;

	node = node.get_parent();
	return get_entity(node);

func is_passed(node: Node3D) -> bool:
	return false;
