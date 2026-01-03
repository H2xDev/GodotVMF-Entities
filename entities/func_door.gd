@tool
class_name func_door
extends VMFEntityNode

var move_direction: Vector3:
	get: 
		move_direction = get_movement_vector(entity.get("movedir", Vector3.ZERO)) if not move_direction else move_direction;
		return move_direction;

var move_distance: Vector3:
	get:
		if not $body/mesh.mesh:
			push_error("Entity %s has no mesh assigned!" % entity.id);
			return Vector3.ZERO;

		move_distance = $body/mesh.mesh.get_aabb().size * move_direction if not move_distance else move_distance;
		return move_distance;

var lip_vector: Vector3:
	get:
		lip_vector = move_direction * entity.lip * config.import.scale if not lip_vector else lip_vector;
		return lip_vector;

var speed: float:
	get: 
		speed = entity.get("speed", 0.0) * config.import.scale if not speed else speed;
		return speed;

var volume: float:
	get:
		volume = entity.get("volume", 10.0) / 10.0 if not volume else volume;
		return volume;

var radius: float:
	get:
		radius = entity.get("radius", 100.0 / config.import.scale) * config.import.scale if not radius else radius;
		return radius

const FLAG_NON_SOLID = 4;
const FLAG_PASSABLE = 8;
const FLAG_TOGGLE = 32;
const FLAG_USE_OPENS = 256;
const FLAG_NPC_CANT = 512;
const FLAG_TOUCH_OPENS = 1024;
const FLAG_STARTS_LOCKED = 2048;
const FLAG_SILENT = 4096;

var start_position = Vector3(0, 0, 0);
var open_value = 0.0;
var is_open = false;
var is_locked = false;
var open_sound = null;
var close_sound = null;
var stop_sound = null;
var current_tween = null;
var current_movement_sound = null;

func _entity_setup(_e: VMFEntity) -> void:
	var mesh = get_mesh();
	if not mesh:
		push_error("Invalid entity %s" % entity.id);

	$body/mesh.set_mesh(mesh);

	if not has_flag(FLAG_NON_SOLID):
		$body/collision.shape = get_entity_shape();
	else:
		$body/collision.queue_free();

func _entity_ready():
	start_position = position;

	is_locked = has_flag(FLAG_STARTS_LOCKED);

	var spawnpos = entity.get("spawnpos", 0);
	is_open = spawnpos == 1;

	# NOTE: Wait for proper reparenting;
	await get_tree().create_timer(0.001).timeout;
	move_door.call_deferred(float(spawnpos), true);

	open_sound = SoundManager.precache_sound(entity.get("noise1", null));
	stop_sound = SoundManager.precache_sound(entity.get("noise2", null));
	close_sound = SoundManager.precache_sound(entity.get("closesound", null));

## 0.0 = closed, 1.0 = open
func move_door(target_value: float = 0.0, instant: bool = false):
	lip_vector = lip_vector if lip_vector != null else Vector3.ZERO;

	var target_position = start_position + move_distance * target_value - lip_vector * target_value;
	var time = (target_position - position).length() / speed;

	if instant:
		position = target_position;
		return;

	if current_tween:
		current_tween.stop();
		current_tween = null;

	current_tween = create_tween();
	current_tween.tween_property(self, "position", target_position, time);
	await current_tween.finished;

## INPUTS
func Open(_param):
	if is_open: return;
	is_open = true;

	trigger_output("OnOpen");
	
	# Stop any existing movement sound
	if current_movement_sound:
		current_movement_sound.stop();
		current_movement_sound = null;
	
	if open_sound:
		current_movement_sound = SoundManager.play_sound(global_transform.origin, open_sound, volume);
		if current_movement_sound: current_movement_sound.max_distance = radius;

	await move_door(1.0);
	
	# Stop the movement sound when door finishes moving
	if current_movement_sound:
		current_movement_sound.stop();
		current_movement_sound = null;
	
	if stop_sound:
		var snd = SoundManager.play_sound(global_transform.origin, stop_sound, volume);
		if snd: snd.max_distance = radius;
	
	trigger_output("OnFullyOpen");

func Unlock(_param):
	is_locked = false;
	trigger_output("OnUnlocked");

func Lock(_param):
	is_locked = true;
	trigger_output("OnLocked");

func Close(_param):
	if not is_open: return;
	is_open = false;

	trigger_output("OnClose");

	# Stop any existing movement sound
	if current_movement_sound:
		current_movement_sound.stop();
		current_movement_sound = null;

	if close_sound:
		current_movement_sound = SoundManager.play_sound(global_transform.origin, close_sound, volume);
	elif open_sound:
		current_movement_sound = SoundManager.play_sound(global_transform.origin, open_sound, volume);

	if current_movement_sound: current_movement_sound.max_distance = radius;

	await move_door(0.0);
	
	# Stop the movement sound when door finishes moving
	if current_movement_sound:
		current_movement_sound.stop();
		current_movement_sound = null;
	
	if stop_sound:
		var snd_stop = SoundManager.play_sound(global_transform.origin, stop_sound, volume);
		if snd_stop: snd_stop.max_distance = radius;
	
	trigger_output("OnFullyClosed");

func Toggle(_param = null):
	if is_open: Close(_param);
	else: Open(_param);

func _interact(_player: Player):
	if not has_flag(FLAG_TOUCH_OPENS):
		return;
	
	if is_locked:
		return;
	
	Toggle(null);
