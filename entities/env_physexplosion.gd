@tool
class_name env_physexplostion extends VMFEntityNode

var magnitude: float:
	get: return entity.get("magnitude", 100.0) * config.import.scale;

var target_entities: Array:
	get: return get_all_targets(entity.get("targetentityname", ""));


func Explode(_void = null):
	for t in target_entities:
		var rigidbody := t.get_node("body") as RigidBody3D;
		if not rigidbody: continue;
		var delta := (t.global_position - global_position) as Vector3;
		var distance := delta.length();
		var force := magnitude / (distance * distance);
		var impulse_vector = delta.normalized() * force;

		rigidbody.apply_central_impulse(impulse_vector);
