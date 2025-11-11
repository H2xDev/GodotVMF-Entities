@tool
class_name filter_entity extends VMFEntityNode

func get_entity(node: Node) -> VMFEntityNode:
	if node is ValveIONode: return node;
	if node.get_parent() == null: return null;

	node = node.get_parent();
	return get_entity(node);

func is_passed(_node: Node3D) -> bool:
	return false;
