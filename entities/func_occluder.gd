## This entity will merge all func_occluder instances into one during import

@tool
class_name func_occluder extends VMFEntityNode

var occluder_instance: OccluderInstance3D:
	get: return get_node("occluder") as OccluderInstance3D;

## Entity setup method. Called during the map import process. Do additional setup for the entity here.
func _entity_setup(_entity: VMFEntity) -> void:
	var existing_occluder := get_parent().get_node_or_null("occluder") as func_occluder;
	name = "occluder";

	var occluder := occluder_instance if existing_occluder == null \
		else existing_occluder.occluder_instance;

	var shape := ArrayOccluder3D.new() if occluder.occluder == null \
		else occluder.occluder as ArrayOccluder3D;

	var new_vertices := get_entity_trimesh_shape().get_faces();
	var vertices := shape.vertices;
	vertices.append_array(new_vertices);

	shape.set_arrays(vertices, range(0, vertices.size()));
	occluder.occluder = shape;

	if existing_occluder != null:
		queue_free();
		return;
