@tool
class_name VLight extends ValveIONode

enum Appearance {
	NORMAL,
	FAST_STROBE = 4,
	SLOW_STROBE = 9,
	FLUORESCENT_FLICKER = 10,
};

const FLAG_INITIALLY_DARK = 1;

@export var style: Appearance = Appearance.NORMAL;
@export var defaultLightEnergy = 0.0;
@export var light: Light3D;

var control_emissive: prop_dynamic:
	get: 
		var target_name = entity.get("control_emissive", null);
		if not target_name: return null;
		return get_target(target_name);

func _entity_ready():
	$light.visible = not has_flag(FLAG_INITIALLY_DARK);

func _process(_delta):
	if Engine.is_editor_hint(): return;

	var newLightEnergy = defaultLightEnergy;

	match style:
		Appearance.NORMAL: pass;
		Appearance.FAST_STROBE:
			newLightEnergy = defaultLightEnergy - randf() * defaultLightEnergy * 0.2;
			pass;
		Appearance.SLOW_STROBE:
			newLightEnergy = defaultLightEnergy - Engine.get_frames_drawn() % 2 * defaultLightEnergy * 0.1;
			pass;
		Appearance.FLUORESCENT_FLICKER:
			newLightEnergy = sin(Time.get_ticks_msec() * 0.01) \
				+ cos(Time.get_ticks_msec() * 0.01232) \
				+ sin(Time.get_ticks_msec() * 0.0323) \
				+ cos(Time.get_ticks_msec() * 0.0432);

			newLightEnergy /= 4;
			newLightEnergy = pow(clamp(newLightEnergy, 0.0, 1.0), 2.0);

			update_control_emissive();
		_: pass;

	$light.light_energy = newLightEnergy;

func update_control_emissive():
	if not control_emissive or not control_emissive.material: return;
	control_emissive.material.emission_energy_multiplier = $light.light_energy;
	
	if not $light.visible:
		control_emissive.material.emission_energy_multiplier = 0.0;

func flick():
	var tween := create_tween();
	tween.tween_method(func(_value):
		$light.light_energy = sin(Time.get_ticks_msec() * 0.01) \
			+ cos(Time.get_ticks_msec() * 0.01232) \
			+ sin(Time.get_ticks_msec() * 0.0323) \
			+ cos(Time.get_ticks_msec() * 0.0432);
		update_control_emissive();
	, 0.0, 1.0, 1.0);
	$light.light_energy = defaultLightEnergy;

	return tween.finished;

func TurnOff(_param):
	if int(_param) == 1:
		await flick();
	$light.visible = false;
	update_control_emissive();

func TurnOn(_param):
	$light.visible = true;
	if int(_param) == 1:
		await flick();

func TurnOffExt(_param): TurnOff(_param);
func TurnOnExt(_param): TurnOn(_param);
func ToggleExt(_param):
	if $light.visible:
		TurnOffExt(_param);
	else:
		TurnOnExt(_param);

func _apply_entity(ent):
	super._apply_entity(ent);
	light = light if light != null else $light;

	if ent.get("targetname", null) or ent.get("parentname", null):
		light.light_bake_mode = Light3D.BAKE_DYNAMIC;
	else:
		light.light_bake_mode = Light3D.BAKE_STATIC;

	var color = ent._light;

	if ent.id == 42112:
		print(color);

	if color is Vector3:
		light.set_color(Color8(color.x, color.y, color.z));
		light.light_energy = 1.0;
	elif color is Color:
		light.set_color(Color(color.r, color.g, color.b));
		light.light_energy = color.a;
	else:
		VMFLogger.error('Invalid light: ' + str(ent.id));
		get_parent().remove_child(self);
		queue_free();
		return;

	if light is OmniLight3D:
		# TODO: implement constant linear quadratic calculation

		var radius = (1 / config.import.scale) * sqrt(light.light_energy);
		var attenuation = 1.44;

		var fiftyPercentDistance = ent.get("_fifty_percent_distance", 0.0);
		var zeroPercentDistance = ent.get("_zero_percent_distance", 0.0);

		if fiftyPercentDistance > 0.0 or zeroPercentDistance > 0.0:
			var dist50 = min(fiftyPercentDistance, zeroPercentDistance) * config.import.scale;
			var dist0 = max(fiftyPercentDistance, zeroPercentDistance) * config.import.scale;

			attenuation = 1 / ((dist0 - dist50) / dist0);

			radius = exp(dist0);

		light.omni_range = radius
		light.omni_attenuation = attenuation;

	light.shadow_enabled = true;
	defaultLightEnergy = light.light_energy;
	style = ent.style if "style" in ent else Appearance.NORMAL;
