extends Node3D;
class_name Debugger;

@onready var rich_text: RichTextLabel = %logs;
@export var default_map_name: String = "hammerous_course_v01";

const PROCESS_FILE = ".current_process";

static var instance: Debugger;
static func log(text: String):
	if instance: return;

func kill_existing_process():
	var pid = FileAccess.open(PROCESS_FILE, FileAccess.READ);
	if pid:
		var processToKill = int(pid.get_line());

		if processToKill:
			message("Killing existing process: {0}".format([pid.get_line()]));
			OS.kill(processToKill);

		pid.close();

	var file = FileAccess.open(PROCESS_FILE, FileAccess.WRITE);
	file.store_string(str(OS.get_process_id()));
	file.close();

func launch_map():
	var args = OS.get_cmdline_args();
	var vmf_arg = args.find("--vmf");
	var build_arg = args.find("--build") != -1;

	var map_name = default_map_name;

	if vmf_arg != -1:
		map_name = args[vmf_arg + 1];
	
	var map_path = "res://hammer_project/mapsrc/{0}.vmf".format([map_name]);

	if build_arg:
		message("Building map: {0}".format([map_path]));
		await build_map(map_path);
		message("Press ESC to exit.");
		return;

	if (FileAccess.file_exists(map_path) == false):
		message("Map file not found: {0}".format([map_path]));
		return;

	message("Loading map: {0}".format([map_path]));

	var vmf = VMFNode.new();
	var scene = get_tree().current_scene;

	scene.add_child(vmf);

	vmf.vmf = map_path;
	vmf.name = map_name;
	vmf.save_geometry = false;
	vmf.save_collision = false;
	vmf.is_runtime = true;
	vmf.import_map();
	vmf.set_owner(scene);

	var we = create_environment(vmf._structure);
	scene.add_child(we);
	we.set_owner(scene);

func create_environment(vmf_struct: Dictionary):
	var we = WorldEnvironment.new();
	var env = ResourceLoader.load("res://build_presets/environment.tres").duplicate();

	we.environment = env;
	we.name = "environment";

	if env.background_mode == Environment.BGMode.BG_SKY and not env.sky:
		var sky_file = "res://skies/{0}".format([vmf_struct.world.skyname]);
		if not sky_file.get_extension():
			sky_file += ".jpg";

		if not FileAccess.file_exists(sky_file):
			message("Sky file not found: {0}".format([sky_file]));
			return we;

		env.sky = Sky.new();
		env.sky.sky_material = PanoramaSkyMaterial.new();
		env.sky.sky_material.panorama = load(sky_file);

	return we;

func build_map(map_path: String):
	var scene = Node3D.new();
	var vmf = VMFNode.new();

	vmf.output.connect(message);

	await get_tree().create_timer(0.5).timeout;

	scene.add_child(vmf);
	vmf.set_owner(scene);

	var map_name = map_path.get_file().get_basename();

	vmf.vmf = map_path;
	vmf.name = map_name;
	vmf.save_geometry = true;
	vmf.save_collision = true;
	vmf.import_map();

	var env = create_environment(vmf._structure);
	scene.add_child(env);
	env.set_owner(scene);

	var lightmap = ResourceLoader \
			.load("res://build_presets/lightmapper.tscn") \
			.instantiate() \
			.duplicate();

	lightmap.name = "lightmapper";

	scene.add_child(lightmap);
	lightmap.set_owner(scene);

	vmf.output.disconnect(message);

	var packed_scene = PackedScene.new();
	packed_scene.pack(scene);

	var err := ResourceSaver.save(packed_scene, "res://scenes/{0}.tscn".format([map_name]));
	if err != OK:
		message("Failed to save scene: {0}".format([err]));
		return;

	message("Map build complete: {0}".format(["res://scenes/{0}.tscn".format([map_name])]));

func _ready():
	instance = self;

	kill_existing_process();
	launch_map();

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		DirAccess.remove_absolute(PROCESS_FILE);
		get_tree().quit();

func message(text):
	rich_text.text += "\n" + text;
