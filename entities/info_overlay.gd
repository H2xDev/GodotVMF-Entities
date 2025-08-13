@tool
extends ValveIONode

var uv_0: Vector3:
	get: return entity.get("uv0") as Vector3;

var uv_1: Vector3:
	get: return entity.get("uv1") as Vector3;

var uv_2: Vector3:
	get: return entity.get("uv2") as Vector3;

var uv_3: Vector3:
	get: return entity.get("uv3") as Vector3;

func _apply_entity(e):
	super._apply_entity(e);

	var material = VMTLoader.get_material(e.material);

	if not material:
		queue_free();
		return;

	var basis_normal := convert_vector(e.get("BasisNormal")) as Vector3;

	var min_x = min(uv_0.x, uv_1.x, uv_2.x, uv_3.x) * VMFConfig.import.scale;
	var min_y = min(uv_0.y, uv_1.y, uv_2.y, uv_3.y) * VMFConfig.import.scale;
	var max_x = max(uv_0.x, uv_1.x, uv_2.x, uv_3.x) * VMFConfig.import.scale;
	var max_y = max(uv_0.y, uv_1.y, uv_2.y, uv_3.y) * VMFConfig.import.scale;
	var width = max_x - min_x;
	var height = max_y - min_y;

	$decal.size.x = width;
	$decal.size.z = height;

	var side = -1 if basis_normal.dot(Vector3.BACK) > 0 \
		or basis_normal.dot(Vector3.RIGHT) > 0 \
		or basis_normal.dot(Vector3.UP) > 0 else 1;

	$decal.texture_albedo = material.albedo_texture;
	$decal.texture_normal = material.normal_texture;
	basis.x = -convert_vector(e.BasisU) * side;
	basis.z = convert_vector(e.BasisV) * side;
	basis.y = basis_normal;
