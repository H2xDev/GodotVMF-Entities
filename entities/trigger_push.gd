@tool
class_name trigger_push extends trigger_multiple

var acceleration = Vector3.ZERO;
var bodies = [];

const FLAG_PHYSICS_OBJECTS = 8;

const CLIENT_CLASSES = ["CharacterBody3D"];
const PHYSICS_CLASSES = ["RigidBody3D", "KinematicBody3D"];

func _entity_ready():
	super._entity_ready();

	var pushdir = entity.get("pushdir", Vector3.ZERO);
	# If pushdir is not set or zero, use entity's angles (facing direction) as fallback
	if pushdir == Vector3.ZERO and "angles" in entity:
		pushdir = entity.angles;
	
	var speed_value = float(entity.get("speed", 100.0));
	var direction = get_movement_vector(pushdir);
	# acceleration is velocity units/sec (speed * direction * scale)
	# Note: If push seems too weak, increase the speed value in Hammer/map editor
	# Typical Source Engine values: 100-300 units/sec for noticeable push
	acceleration = speed_value * direction * config.import.scale;

	$area.body_entered.connect(func(node):
		if bodies.has(node): return;

		var is_rigid_body = node is RigidBody3D and has_flag(FLAG_PHYSICS_OBJECTS);
		var is_character_body = node is CharacterBody3D and has_flag(FLAG_CLIENTS);

		if is_rigid_body or is_character_body:
			bodies.append(node);
	);
	
	$area.body_exited.connect(func(node):
		if bodies.has(node):
			bodies.erase(node);
	);

func _physics_process(delta):
	if Engine.is_editor_hint(): return;
	if not enabled: return;
	if not has_flag(FLAG_PHYSICS_OBJECTS) and not has_flag(FLAG_CLIENTS): return;
	
	if bodies.is_empty():
		return
	
	for body in bodies:
		if not is_instance_valid(body):
			continue
		
		var is_rigid_body = body is RigidBody3D;
		var is_character_body = body is CharacterBody3D;

		if is_rigid_body:
			# For RigidBody3D: acceleration is velocity units/sec, apply to linear_velocity
			body.linear_velocity += acceleration * delta;
		elif is_character_body:
			# For CharacterBody3D: must manually modify velocity (not forces/impulses)
			# acceleration is velocity units/sec, so acceleration * delta = velocity increment per frame
			var push_velocity = acceleration * delta
			# Apply directly to velocity (player no longer has add_push_velocity method)
			body.velocity += push_velocity
