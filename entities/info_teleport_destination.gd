@tool
class_name info_teleport_destination
extends VMFEntityNode

## Info teleport destination entity
## Marks a location where entities can be teleported to
## Same functionality as point_teleport

var destination_position: Vector3

func _entity_ready():
	# Store position for teleportation
	destination_position = global_position
	
	# Add to group so trigger_teleport can find it
	add_to_group("teleport_destinations")

func get_destination_transform() -> Transform3D:
	var transform = Transform3D()
	transform.origin = destination_position
	
	# Use entity.angles and convert_direction like point_teleport does
	# Always apply rotation (even if angles is 0 0 0) to match point_teleport behavior
	var angles = entity.get("angles", Vector3.ZERO)
	# Convert angles using convert_direction (same as point_teleport)
	var direction = convert_direction(angles)
	# Set rotation Y (yaw) like point_teleport does: convert_direction(angles).y - PI / 2.0
	transform.basis = Basis.from_euler(Vector3(0, direction.y - PI / 2.0, 0))
	
	return transform
