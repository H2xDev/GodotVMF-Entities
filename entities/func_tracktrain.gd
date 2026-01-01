@tool
class_name func_tracktrain extends VMFEntityNode

const FLAG_PASSABLE = 8;

enum MovementState {
	MOVING_FORWARD,
	MOVING_BACKWARD,
	STOPPED
}

enum MovementDirection {
	FORWARD,
	BACKWARD
}

var current_point: path_track = null;
var current_tween: Tween = null;

var start_sound: String;
var stop_sound: String;
var move_sound: String;

var direction: MovementDirection = MovementDirection.FORWARD;
var state: MovementState = MovementState.STOPPED;

var move_player: AudioStreamPlayer3D = null;
var first_target:
	get: return get_target(entity.get("target", ""));

func _entity_ready():
	if not current_point:
		teleport_to_point(first_target.targetname, false);
		print(first_target);

	precache_sounds();

func _entity_setup(_e: VMFEntity) -> void:
	$body/mesh.set_mesh(get_mesh());
	
	if has_flag(FLAG_PASSABLE):
		$body/collision.queue_free();
	else:
		$body/collision.shape = get_entity_shape();

func _physics_process(_delta) -> void:
	if is_instance_valid(move_player):
		move_player.global_transform.origin = global_transform.origin;

func precache_sounds():
	start_sound = SoundManager.precache_sound(entity.get("StartSound", ""));
	stop_sound = SoundManager.precache_sound(entity.get("StopSound", ""));
	move_sound = SoundManager.precache_sound(entity.get("MoveSound", ""));

func reset_tween():
	if current_tween != null:
		current_tween.stop();
		current_tween = null;

		if state == MovementState.STOPPED:
			SoundManager.play_sound(global_transform.origin, stop_sound);
			if is_instance_valid(move_player): move_player.stop();
			trigger_output("OnStop");

func move_to_current_point():
	var target_position = current_point.global_transform.origin;
	var distance = (target_position - global_transform.origin).length();
	var speed = entity.get("speed", 0.0) * config.import.scale;

	if speed == 0.0:
		push_error("Speed is 0, cannot move. Entity id: " + entity.id);
		return;

	var time = distance / speed;

	reset_tween();

	if state == MovementState.STOPPED:
		SoundManager.play_sound(global_transform.origin, start_sound);
		move_player = SoundManager.play_sound(global_transform.origin, move_sound);
		trigger_output("OnStart");

	state = MovementState.MOVING_FORWARD \
			if direction == MovementDirection.FORWARD \
			else MovementState.MOVING_BACKWARD;

	current_tween = create_tween();
	current_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS);
	current_tween.tween_property(self, "global_transform:origin", target_position, time);

	await current_tween.finished;

	current_point._pass();

func move_to_next_point():
	if not current_point:
		Stop();
		print("Stopped");
		return;

	direction = MovementDirection.FORWARD;

	await move_to_current_point();

	if not current_point.next_stop_target:
		Stop();
		return;

	current_point = current_point.next_stop_target;
	move_to_next_point()

func move_to_previous_point():
	if not current_point: 
		Stop();
		return;

	direction = MovementDirection.BACKWARD;

	await move_to_current_point();

	if not current_point.prev_stop_target:
		Stop();
		return;

	current_point = current_point.prev_stop_target;
	move_to_previous_point();

func teleport_to_point(target_point: String, _trigger_output: bool = false):
	var track = get_target(target_point);

	if not track:
		push_error("Target path_track not found: " + target_point + ". Entity id: " + str(entity.id));
		return;

	current_point = track;
	global_transform.origin = track.global_transform.origin;

	if _trigger_output: track._teleport();

# INPUTS
func StartForward(_param = null):
	if direction != MovementDirection.FORWARD:
		current_point = current_point.next_stop_target;

	move_to_next_point();

func StartBackward(_param = null):
	if direction != MovementDirection.BACKWARD:
		current_point = current_point.prev_stop_target;

	move_to_previous_point();

func Toggle(_param = null):
	if state == MovementState.STOPPED:
		if direction == MovementDirection.FORWARD:
			StartForward();
		else:
			StartBackward();
	else:
		Stop();

func Stop(_param = null):
	state = MovementState.STOPPED;
	trigger_output("OnStop");
	reset_tween();

func TeleportToPathTrack(target_path_track: String):
	teleport_to_point(target_path_track, true);
