@tool
class_name env_entity_maker extends VMFEntityNode

## Template name to spawn from (targetname of point_template)
var entity_template: String:
	get: return entity.get("EntityTemplate", "");

## Spawn flags
const FLAG_DISABLE_ON_SPAWN = 1;

var spawned_entities: Array[Node] = [];

func _entity_ready():
	pass;

## Recursively searches for a scene file in a directory and its subdirectories
func _find_scene_in_directory(dir_path: String, scene_name: String) -> String:
	var dir = DirAccess.open(dir_path);
	if not dir:
		return "";
	
	# Check current directory first
	var file_path = dir_path.path_join(scene_name + ".tscn");
	if ResourceLoader.exists(file_path):
		return file_path;
	
	# Try without extension
	file_path = dir_path.path_join(scene_name);
	if ResourceLoader.exists(file_path):
		return file_path;
	
	# Recursively search subdirectories
	dir.list_dir_begin();
	var file_name = dir.get_next();
	
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			var subdir_path = dir_path.path_join(file_name);
			var found = _find_scene_in_directory(subdir_path, scene_name);
			if found:
				dir.list_dir_end();
				return found;
		file_name = dir.get_next();
	
	dir.list_dir_end();
	return "";

## Spawns entities from the template
func ForceSpawn(_param = null):
	print("spawn")
	if not entity_template:
		push_warning("env_entity_maker: No EntityTemplate specified!");
		return;
	
	var template_scene_name = null;
	
	# Try to find the point_template entity first
	var template_entity = get_target(entity_template);
	if template_entity:
		# Found a point_template entity, extract scene name from it
		# Get template scene name (could be Template01, Template02, etc.)
		for i in range(1, 17):  # Source supports up to 16 templates
			var template_key = "Template%02d" % i;
			if template_key in template_entity.entity:
				template_scene_name = template_entity.entity[template_key];
				break;
		
		if not template_scene_name:
			# Try just "template" as fallback
			if "template" in template_entity.entity:
				template_scene_name = template_entity.entity.template;
	else:
		# No point_template found, treat EntityTemplate as direct scene name
		template_scene_name = entity_template;
	
	# Load and instantiate the scene - search recursively in Scenes folder
	var scene_path = _find_scene_in_directory("res://Scenes", template_scene_name);
	if not scene_path:
		push_warning("env_entity_maker: Template scene '%s' not found in Scenes folder!" % template_scene_name);
		return;
	
	var scene = load(scene_path) as PackedScene;
	if not scene:
		push_warning("env_entity_maker: Failed to load scene '%s'!" % scene_path);
		return;
	
	# Instantiate the entity
	var spawned = scene.instantiate();
	if not spawned:
		push_warning("env_entity_maker: Failed to instantiate scene '%s'!" % scene_path);
		return;
	
	# Set position and rotation to match this entity
	spawned.global_transform = global_transform;
	
	# Add to scene tree
	get_tree().current_scene.add_child(spawned);
	
	# If it's a VMFEntityNode, set it up properly
	if spawned is VMFEntityNode:
		spawned.is_runtime = true;
		# Create a basic entity reference with proper structure
		var entity_data = spawned.entity if "entity" in spawned else {};
		entity_data["origin"] = global_transform.origin;
		entity_data["angles"] = Vector3.ZERO;
		var vmf_entity = VMFEntity.new(entity_data);
		spawned._entity_pre_setup(vmf_entity);
	
	# Disable if flag is set
	if has_flag(FLAG_DISABLE_ON_SPAWN):
		if "enabled" in spawned:
			spawned.enabled = false;
	
	spawned_entities.append(spawned);
	trigger_output("OnEntitySpawned");
	
	print("env_entity_maker: Spawned entity from template '%s' at position %s" % [template_scene_name, global_transform.origin]);

## Spawns entities (alias for ForceSpawn)
func Spawn(_param = null):
	ForceSpawn(_param);
