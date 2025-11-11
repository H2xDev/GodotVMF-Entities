@tool
class_name func_rotating extends VMFEntityNode

@export var preview = false;

const FLAG_START_ON: int = 1;
const FLAG_REVERSE_DIRECTION: int = 2;
const FLAG_X_AXIS: int = 4;
const FLAG_Y_AXIS: int = 8;
const FLAG_NONSOLID: int = 64;

var current_tween = null;
var loop_sound = null;
var current_player = null;

func _entity_setup(e: VMFEntity):
	$body/mesh.set_mesh(get_mesh());
	$body/mesh.cast_shadow = entity.disableshadows == 0;
	$body/mesh.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC;

	if has_flag(FLAG_NONSOLID):
		$body/collision.queue_free();
	else:
		$body/collision.shape = get_entity_shape();

func _physics_process(dt):
	if Engine.is_editor_hint() && not preview:
		return;

	if not enabled: return;

	var speed = entity.maxspeed * dt;

	if has_flag(FLAG_REVERSE_DIRECTION):
		speed *= -1;

	if has_flag(FLAG_X_AXIS):
		rotation_degrees.x += speed;
	elif has_flag(FLAG_Y_AXIS):
		rotation_degrees.z += speed;
	else:
		rotation_degrees.y += speed;

func _entity_ready():
	enabled = has_flag(FLAG_START_ON);
	loop_sound = SoundManager.precache_sound(entity.get("message", ""));

# INPUTS

func Start(_param = null):
	enabled = true;

	if loop_sound:
		current_player = SoundManager.play_sound(global_position, loop_sound);

func Stop(_param = null):
	enabled = false;

	if current_player:
		current_player.stop()
		current_player.queue_free();
		current_player = null;

func RotateBy(deg):
	if current_tween:
		return;

	deg = float(deg);

	current_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN);
	var target = Vector3.ZERO;

	if has_flag(FLAG_X_AXIS):
		target.x = deg;
	elif has_flag(FLAG_Y_AXIS):
		target.z = deg;
	else:
		target.y = deg;
	
	var end_rot = rotation_degrees + target;

	current_tween.tween_property(self, "rotation_degrees", end_rot, 2.0);
	current_tween.play();

	await current_tween.finished;
	current_tween = null
