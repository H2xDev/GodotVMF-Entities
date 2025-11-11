@tool
class_name info_overlay extends VMFEntityNode

var uv_0: Vector3:
	get: return entity.get("uv0", Vector3.ZERO);

var uv_1: Vector3:
	get: return entity.get("uv1", Vector3.ZERO);

var uv_2: Vector3:
	get: return entity.get("uv2", Vector3.ZERO);

var uv_3: Vector3:
	get: return entity.get("uv3", Vector3.ZERO);

var material_path: String:
	get: return entity.get("material", "");

var basis_normal: Vector3:
	get: return convert_vector(entity.get("BasisNormal", Vector3.UP));

var basis_u: Vector3:
	get: return convert_vector(entity.get("BasisU", Vector3.RIGHT));

var basis_v: Vector3:
	get: return convert_vector(entity.get("BasisV", Vector3.FORWARD));


@onready var decal: Decal = $decal;

func _entity_setup(_e: VMFEntity) -> void:
	var material := VMTLoader.get_material(material_path);

	if not material:
		queue_free();
		return;


	var min_x: float = min(uv_0.x, uv_1.x, uv_2.x, uv_3.x) * config.import.scale;
	var min_y: float = min(uv_0.y, uv_1.y, uv_2.y, uv_3.y) * config.import.scale;
	var max_x: float = max(uv_0.x, uv_1.x, uv_2.x, uv_3.x) * config.import.scale;
	var max_y: float = max(uv_0.y, uv_1.y, uv_2.y, uv_3.y) * config.import.scale;
	var width := max_x - min_x;
	var height := max_y - min_y;

	decal.size.x = width;
	decal.size.z = height;

	var side := -1 if basis_normal.dot(Vector3.BACK) > 0 \
		or basis_normal.dot(Vector3.RIGHT) > 0 \
		or basis_normal.dot(Vector3.UP) > 0 else 1;

	var base_material: BaseMaterial3D = material;
	
	prints(basis_u, basis_v, basis_normal);

	decal.texture_albedo = base_material.albedo_texture;
	decal.texture_normal = base_material.normal_texture;
	basis.x = -basis_u * side;
	basis.z = basis_v * side;
	basis.y = basis_normal;
