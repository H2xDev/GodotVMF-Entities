@tool
class_name func_rotating extends VMFEntityNode

const FLAG_START_ON: int = 1;
const FLAG_REVERSE_DIRECTION: int = 2;
const FLAG_X_AXIS: int = 4;
const FLAG_Y_AXIS: int = 8;
const FLAG_NONSOLID: int = 64;

var current_tween: Tween;
@onready var loop_player: AudioStreamPlayer3D = $body/loop_player;

var max_speed: float:
	get: return entity.get("maxspeed", 0.0);

var sound_path: String:
	get: return entity.get("message", "");

func _entity_setup(_e: VMFEntity) -> void:
	var mesh: MeshInstance3D = $body/mesh;
	var collision: CollisionShape3D = $body/collision;

	mesh.set_mesh(get_mesh());
	mesh.cast_shadow = entity.disableshadows == 0;
	mesh.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC;
	assign_sound();

	if has_flag(FLAG_NONSOLID):
		collision.queue_free();
	else:
		collision.shape = get_entity_shape();

func assign_sound() -> void:
	var resource_path := VMFUtils.normalize_path("res://sound/%s" % sound_path);

	if not ResourceLoader.exists(resource_path): 
		VMFLogger.warn("func_rotating: Sound doesnt exists %s" % resource_path);
		return;

	loop_player.stream = load(resource_path);

func _physics_process(dt: float) -> void:
	if not enabled: return;

	var speed := max_speed * dt;

	if has_flag(FLAG_REVERSE_DIRECTION):
		speed *= -1;

	if has_flag(FLAG_X_AXIS):
		rotation_degrees.x += speed;
	elif has_flag(FLAG_Y_AXIS):
		rotation_degrees.z += speed;
	else:
		rotation_degrees.y += speed;

func _entity_ready() -> void:
	enabled = has_flag(FLAG_START_ON);

# INPUTS

func Start(_param: Variant = null) -> void:
	enabled = true;
	loop_player.play();

func Stop(_param: Variant = null) -> void:
	enabled = false;
	loop_player.stop()

func RotateBy(deg: float) -> void:
	if current_tween:
		return;

	deg = float(deg);

	current_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN);
	var target := Vector3.ZERO;

	if has_flag(FLAG_X_AXIS):
		target.x = deg;
	elif has_flag(FLAG_Y_AXIS):
		target.z = deg;
	else:
		target.y = deg;
	
	var end_rot := rotation_degrees + target;

	current_tween.tween_property(self, "rotation_degrees", end_rot, 2.0);
	current_tween.play();

	await current_tween.finished;
	current_tween = null
