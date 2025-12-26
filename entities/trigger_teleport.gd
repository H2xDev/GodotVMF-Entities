@tool
class_name trigger_teleport
extends VMFEntityNode

const FLAG_CLIENTS = 1;
const FLAG_NPCS = 2;

var target: String = ""  # Targetname of the info_teleport_destination
var teleport_destination: info_teleport_destination = null

func get_filter_entity() -> filter_entity:
	var target_entity = get_target(entity.get("filtername", ""));

	if not target_entity: return null;

	return target_entity as filter_entity;

func _entity_ready():
	target = entity.get("target", "")
	
	# Find the teleport destination
	if target != "":
		var dest_entity = get_target(target)
		if dest_entity and dest_entity is info_teleport_destination:
			teleport_destination = dest_entity
	
	# Ensure area is monitoring
	$area.monitoring = true
	$area.monitorable = false
	
	$area.body_entered.connect(func(body):
		if not enabled:
			return
		
		var is_client_passed = has_flag(FLAG_CLIENTS) and VMFEntityNode.aliases["!player"] == body;
		var is_npc_passed = has_flag(FLAG_NPCS) and body.get_groups().has('npc');
		var filter = get_filter_entity();
		var is_filter_passed = filter.is_passed(body) if filter else false;
		
		# If no flags are set and no filter, teleport everything (default behavior)
		var has_any_flag = has_flag(FLAG_CLIENTS) or has_flag(FLAG_NPCS);
		var should_teleport = false;
		
		if has_any_flag or filter:
			# Check flags/filter
			should_teleport = is_client_passed or is_npc_passed or is_filter_passed;
		else:
			# No flags or filter set - teleport everything
			should_teleport = true;

		if should_teleport:
			teleport_entity(body);
	);

func _entity_setup(_e: VMFEntity) -> void:
	$area/collision.shape = get_entity_shape();

func teleport_entity(entity: Node3D):
	if teleport_destination == null:
		# Try to find destination again in case it wasn't ready before
		if target != "":
			var dest_entity = get_target(target)
			if dest_entity and dest_entity is info_teleport_destination:
				teleport_destination = dest_entity
		
		if teleport_destination == null:
			push_warning("trigger_teleport: Destination '%s' not found!" % target)
			return
	
	var dest_transform = teleport_destination.get_destination_transform()
	
	# Teleport the entity
	if entity.has_method("set_global_transform"):
		entity.set_global_transform(dest_transform)
	elif entity.has_method("set_global_position"):
		entity.set_global_position(dest_transform.origin)
		if entity.has_method("set_rotation"):
			entity.set_rotation(dest_transform.basis.get_euler())
	else:
		# Fallback: direct property access
		entity.global_position = dest_transform.origin
		entity.rotation = dest_transform.basis.get_euler()
	
	# Reset velocity if it's a CharacterBody3D or RigidBody3D
	if entity is CharacterBody3D:
		entity.velocity = Vector3.ZERO
	elif entity is RigidBody3D:
		entity.linear_velocity = Vector3.ZERO
		entity.angular_velocity = Vector3.ZERO
