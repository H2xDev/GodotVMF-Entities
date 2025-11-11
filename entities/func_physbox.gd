@tool
class_name func_physbox extends VMFEntityNode

var FLAG_IGNORE_PICKUP := 8192;
var FLAG_MOTION_DISABLED := 32768;

@onready var body: RigidBody3D = $body;
@onready var mesh_instance: MeshInstance3D = $body/mesh;
@onready var collision: CollisionShape3D = $body/collision;

func _entity_ready() -> void:
	reparent(get_tree().current_scene);
	set_physics_process(true);

func EnableMotion(_param: Variant) -> void:
	body.freeze = false;

func DisableMotion(_param: Variant) -> void:
	body.freeze = true;

func _entity_setup(_e: VMFEntity) -> void:
	body.freeze = has_flag(FLAG_MOTION_DISABLED);
	mesh_instance.set_mesh(get_mesh());
	collision.shape = mesh_instance.mesh.create_convex_shape(true);

	body.mass = mesh_instance.get_aabb().size.x * mesh_instance.get_aabb().size.y * mesh_instance.get_aabb().size.z * 0.01;
