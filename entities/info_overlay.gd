@tool
extends ValveIONode

func _apply_entity(e):
	super._apply_entity(e);

	var isDecalMode = not "geometry" in e;

	var material = VMTLoader.get_material(e.material);

	if not material:
		queue_free();
		return;

	var mesh = ArrayMesh.new();

	var uvs = [
		Vector2(e.StartU, e.StartV),
		Vector2(e.StartU, e.EndV),
		Vector2(e.EndU, e.EndV),
		Vector2(e.EndU, e.StartV),
	];

	var verts = [
		convert_vector(e.uv0) * config.import.scale,
		convert_vector(e.uv1) * config.import.scale,
		convert_vector(e.uv2) * config.import.scale,
		convert_vector(e.uv3) * config.import.scale,
	];

	var st = SurfaceTool.new();
	var normal = convert_vector(e.BasisNormal);

	st.begin(Mesh.PRIMITIVE_TRIANGLES);
	st.set_normal(normal);

	var index = 0;
	for vert in verts:
		st.set_uv(uvs[index]);
		st.add_vertex(vert);
		index += 1;

	var indices = [0, 1, 2, 0, 2, 3];
	for i in indices:
		st.add_index(i);

	st.generate_normals();
	st.generate_tangents();
	st.set_material(material);
	st.commit(mesh);
		
	var aabb = mesh.get_aabb().size;

	if isDecalMode:
		$decal.size.x = aabb.x;
		$decal.size.z = aabb.z;

		var side = -1 if normal.dot(Vector3.BACK) > 0 or normal.dot(Vector3.RIGHT) > 0 or normal.dot(Vector3.UP) > 0 else 1;

		$decal.texture_albedo = material.albedo_texture;
		$decal.texture_normal = material.normal_texture;
		$decal.basis.x = -convert_vector(e.BasisU) * side;
		$decal.basis.z = convert_vector(e.BasisV) * side;
		$decal.basis.y = normal;
		$mesh.queue_free();
	else:
		$decal.queue_free();
		$mesh.set_mesh(mesh);
		$mesh.position += normal * 0.001;
		$mesh.basis.x = convert_vector(e.BasisU);
		$mesh.basis.z = -convert_vector(e.BasisV);
		$mesh.basis.y = normal;
