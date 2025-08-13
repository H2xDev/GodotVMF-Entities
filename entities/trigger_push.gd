@tool
class_name TriggerPush extends trigger_multiple;

var bodies = [];

const FLAG_PHYSICS_OBJECTS = 8;

const CLIENT_CLASSES = ["CharacterBody3D"];
const PHYSICS_CLASSES = ["RigidBody3D", "KinematicBody3D"];

var pushdir: Vector3:
	get: return get_movement_vector(entity.get("pushdir", Vector3.ZERO));

var speed: float:
	get: return entity.get("speed", 0.0) * VMFConfig.import.scale;

var acceleration: Vector3:
	get: return speed * pushdir;

func _entity_ready():
	super._entity_ready();

	$area.body_entered.connect(_on_body_entered);
	$area.body_exited.connect(_on_body_left);

func _physics_process(delta):
	if Engine.is_editor_hint(): return;
	if not enabled: return;
	if not has_flag(FLAG_PHYSICS_OBJECTS) and not has_flag(FLAG_CLIENTS): return;
	
	for body in bodies:
		var is_rigid_body = body is RigidBody3D;
		var has_velocity = "velocity" in body;

		if is_rigid_body:
			body.apply_force(acceleration);
		elif has_velocity:
			body.velocity += acceleration * delta;

func _on_body_entered(node):
	if bodies.has(node): return;
	if node is not RigidBody3D: return;

	var is_client := node.is_in_group("Clients") as bool;
	var is_rigid_body = not is_client;

	if is_client and not has_flag(FLAG_CLIENTS): return;
	if is_rigid_body and not has_flag(FLAG_PHYSICS_OBJECTS): return;

	bodies.append(node);

func _on_body_left(node):
	if bodies.has(node):
		bodies.erase(node);
	
