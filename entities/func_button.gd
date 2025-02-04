@tool
class_name func_button
extends func_door

const FLAG_DONT_MOVE = 1;
const FLAG_TOUCH_ACTIVATES = 256;
const FLAG_DAMAGE_ACTIVATES = 512;
const FLAG_USE_ACTIVATES = 1024;
const FLAG_SPARKS = 4096;

var wait_time = 0.0;
var click_sound = null;
var lock_sound = null;
var is_pressed = false;

func _entity_ready():
	super._entity_ready();

	click_sound = entity.get("click_sound", click_sound);
	lock_sound = entity.get("lock_sound", lock_sound);

	if click_sound: SoundManager.precache_sound(click_sound);
	if lock_sound: SoundManager.precache_sound(lock_sound);

func _interact(_player: Player):
	if not has_flag(FLAG_USE_ACTIVATES):
		return;

	if is_locked:
		if lock_sound: SoundManager.play_sound(global_transform.origin, lock_sound);
		trigger_output("OnUseLocked");
		return;

	if has_flag(FLAG_TOGGLE):
		if is_pressed: PressIn(null) 
		else: PressOut(null);
	else:
		if not is_pressed: PressIn(null);

	if click_sound: SoundManager.play_sound(global_transform.origin, click_sound);
	trigger_output("OnPressed");

func _process(delta: float):
	if wait_time > 0.0:
		wait_time -= delta;
		if wait_time <= 0.0:
			is_pressed = false;
			trigger_output("OnOut");
			Close(null);

func PressIn(_param = null):

	if not has_flag(FLAG_DONT_MOVE):
		if wait_time > 0.0: return;
		wait_time = float(entity.wait);
		Open(null);

	is_pressed = true;
	trigger_output("OnIn");

func PressOut(_param = null):
	if not has_flag(FLAG_DONT_MOVE):
		if wait_time > 0.0: return;
		wait_time = float(entity.wait);
		Close(null);

	is_pressed = false;
	trigger_output("OnOut");
