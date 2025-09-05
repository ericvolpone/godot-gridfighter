class_name IceManager extends Node3D

##
## Project "face-targeted" ice using a Decal that only sees a runtime receiver mesh.
## Godot 4.x
##

# ---- CONFIG ------------------------------------------------------------------

@export_node_path("MeshInstance3D") var level_mesh_path: NodePath

# Layer for the receiver mesh. In Godot 4, there are 20 visibility layers (1..20).
# We'll use "layer 20" => bit 19 (0-indexed).
const LAYER_ICE_RECEIVER_BIT := 19
const LAYER_ICE_RECEIVER := 1 << LAYER_ICE_RECEIVER_BIT

# Default visuals (replace with your assets)
@export var decal_albedo: Texture2D
@export var decal_normal: Texture2D
@export var decal_orm: Texture2D
@export var decal_modulate: Color = Color(0.9, 0.95, 1.0, 1.0) # icy tint

# Decal params
@export var decal_projection_depth: float = 1.0  # keep sane to reduce stretching
@export var decal_upper_fade: float = 0.0
@export var decal_lower_fade: float = 0.0

# Receiver lift to avoid z-fight (in meters)
@export var receiver_surface_lift: float = 0.001

# Area (gameplay) defaults
@export var default_area_height: float = 1.2

# Performance guard
@export var max_verts_per_patch: int = 6000   # safety cap

# ---- INTERNAL STATE ----------------------------------------------------------

var _level_mesh: MeshInstance3D
var _last_hit_face_index: int = -1

func _ready() -> void:
	_level_mesh = get_node_or_null(level_mesh_path) as MeshInstance3D
	if _level_mesh == null or _level_mesh.mesh == null:
		push_warning("[IceManager] LevelMesh not found or has no mesh. Set 'level_mesh_path' to your scene's mesh.")
	# Optional: validate textures
	if decal_albedo == null:
		push_warning("[IceManager] No decal_albedo set. Assign a texture for better visuals.")

# ---- PUBLIC API --------------------------------------------------------------

## Spawn an ice patch using a physics hit dictionary:
## hit["position"]: Vector3 (world), hit["normal"]: Vector3 (world), hit["collider"]: Object (MeshInstance3D expected)
func spawn_ice_patch_from_hit(hit: Dictionary, radius: float = 4.0, lifetime: float = 6.0) -> void:
	if _level_mesh == null or _level_mesh.mesh == null:
		return
	_last_hit_face_index = hit.get("face_index", -1)
	var center_ws: Vector3 = hit.get("position", _level_mesh.global_transform.origin)
	var up_ws: Vector3 = (hit.get("normal", Vector3.UP) as Vector3).normalized()
	_spawn_ice(center_ws, up_ws, radius, lifetime)

## You can also spawn from a given world position/normal without a hit dict.
func spawn_ice_patch(center_ws: Vector3, up_ws: Vector3 = Vector3.UP, radius: float = 4.0, lifetime: float = 6.0) -> void:
	if _level_mesh == null or _level_mesh.mesh == null:
		return
	_spawn_ice(center_ws, up_ws.normalized(), radius, lifetime)

# ---- CORE --------------------------------------------------------------------

func _spawn_ice(center_ws: Vector3, up_ws: Vector3, radius: float, lifetime: float) -> void:
	# 1) Build receiver mesh from LevelMesh triangles near center_ws
	var receiver := _build_receiver_mesh_geodesic(_level_mesh, center_ws, radius, _last_hit_face_index)
	if receiver == null:
		return

	# 2) Place receiver into the world (as sibling under IceSystem, so transforms are world)
	add_child(receiver)
	receiver.global_transform = Transform3D(Basis(), Vector3.ZERO) # keep world coords as is
	receiver.layers = LAYER_ICE_RECEIVER
	receiver.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# 3) Spawn gameplay Area
	var area := _make_slide_area(center_ws, radius, default_area_height)
	add_child(area)

	# 4) Spawn Decal that only projects to receiver layer
	var decal := Decal.new()
	decal.cull_mask = LAYER_ICE_RECEIVER
	decal.size = Vector3(radius * 2.0, decal_projection_depth, radius * 2.0)
	decal.texture_albedo = decal_albedo
	decal.texture_normal = decal_normal
	decal.texture_orm = decal_orm
	decal.modulate = decal_modulate
	decal.upper_fade = decal_upper_fade
	decal.lower_fade = decal_lower_fade
	# Align Y of decal to the "up_ws" so it projects along the normal
	var right := up_ws.cross(Vector3.FORWARD).normalized()
	if right.length_squared() < 1e-6:
		right = up_ws.cross(Vector3.RIGHT).normalized()
	var fwd := right.cross(up_ws).normalized()
	decal.transform = Transform3D(Basis(right, up_ws, fwd), center_ws)
	add_child(decal)

	# 5) Cleanup after lifetime
	if lifetime > 0.0:
		var t := get_tree().create_timer(lifetime)
		t.timeout.connect(func() -> void:
			if is_instance_valid(decal): decal.queue_free()
			if is_instance_valid(receiver): receiver.queue_free()
			if is_instance_valid(area): area.queue_free()
		)

# ---- RECEIVER CONSTRUCTION ---------------------------------------------------

# Build a receiver by walking triangle adjacencies from the hit face, stopping by *surface distance*.
func _build_receiver_mesh_geodesic(
	mi: MeshInstance3D,
	center_ws: Vector3,
	radius: float,
	hit_face_index: int
) -> MeshInstance3D:
	var mesh: ArrayMesh = mi.mesh as ArrayMesh
	if mesh == null:
		return null
	var xf: Transform3D = mi.global_transform

	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var surfaces: int = mesh.get_surface_count()
	var radius_sq: float = radius * radius
	var verts_accum: int = 0

	for s: int in range(surfaces):
		var arrays: Array = mesh.surface_get_arrays(s)
		if arrays.is_empty():
			continue
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		if verts.is_empty() or indices.is_empty():
			continue

		var tri_count: int = indices.size() / 3

		# Centers & normals in packed arrays (no nested generics)
		var centers: PackedVector3Array = PackedVector3Array()
		centers.resize(tri_count)
		var normals: PackedVector3Array = PackedVector3Array()
		normals.resize(tri_count)

		for t: int in range(tri_count):
			var i0: int = indices[t * 3]
			var i1: int = indices[t * 3 + 1]
			var i2: int = indices[t * 3 + 2]
			var a: Vector3 = xf * verts[i0]
			var b: Vector3 = xf * verts[i1]
			var c: Vector3 = xf * verts[i2]
			centers[t] = (a + b + c) / 3.0
			normals[t] = Plane(a, b, c).normal

		# ----- Build adjacency (Dictionary -> Array), avoid nested generics
		# edge_map: Dictionary with key Vector2i -> value Array (of triangle ints)
		var edge_map: Dictionary = {}

		for t: int in range(tri_count):
			var i0: int = indices[t * 3]
			var i1: int = indices[t * 3 + 1]
			var i2: int = indices[t * 3 + 2]

			var e0: Vector2i = Vector2i(min(i0, i1), max(i0, i1))
			var e1: Vector2i = Vector2i(min(i1, i2), max(i1, i2))
			var e2: Vector2i = Vector2i(min(i2, i0), max(i2, i0))

			var edges: Array = [e0, e1, e2]
			for key_var: Vector2i in edges:
				var key: Vector2i = key_var as Vector2i
				if not edge_map.has(key):
					edge_map[key] = []	# untyped Array
				var arr: Array = edge_map[key]
				arr.append(t)			# store int triangle id
				edge_map[key] = arr

		# neighbors: Array of Arrays (both untyped), each inner holds int triangle ids
		var neighbors: Array = []
		neighbors.resize(tri_count)
		for i: int in range(tri_count):
			neighbors[i] = []

		for key: Vector2i in edge_map.keys():
			var tris_on_edge: Array = edge_map[key]
			if tris_on_edge.size() == 2:
				var a_t: int = int(tris_on_edge[0])
				var b_t: int = int(tris_on_edge[1])
				(neighbors[a_t] as Array).append(b_t)
				(neighbors[b_t] as Array).append(a_t)

		# ----- Seed triangle
		var seed: int = -1
		if hit_face_index >= 0 and hit_face_index < tri_count:
			seed = hit_face_index
		else:
			var best_d2: float = INF
			for t: int in range(tri_count):
				var d2: float = center_ws.distance_squared_to(centers[t])
				if d2 < best_d2:
					best_d2 = d2
					seed = t

		if seed < 0:
			continue

		# ----- Dijkstra / BFS by geodesic distance (use untyped Arrays for nested structures)
		var dist: PackedFloat32Array = PackedFloat32Array()
		dist.resize(tri_count)
		for t: int in range(tri_count):
			dist[t] = INF
		dist[seed] = 0.0

		var open: Array = [seed]		# holds int tri ids
		var selected: PackedInt32Array = PackedInt32Array()

		while open.size() > 0:
			var cur: int = int(open.pop_back())

			# accept if within radius (with extra center distance guard)
			if dist[cur] <= radius and center_ws.distance_squared_to(centers[cur]) <= radius_sq:
				selected.append(cur)
			else:
				continue

			var cur_neighbors: Array = neighbors[cur]
			for nb_var: int in cur_neighbors:
				var nb: int = int(nb_var)
				var step_len: float = (centers[nb] - centers[cur]).length()
				var nd: float = dist[cur] + step_len
				if nd < dist[nb] and nd <= radius * 1.15:
					dist[nb] = nd
					open.append(nb)

			if selected.size() * 3 >= max_verts_per_patch:
				push_warning("[IceManager] geodesic cap reached (max_verts_per_patch).")
				break

		if selected.is_empty():
			continue

		# ----- Emit selected triangles
		for k: int in range(selected.size()):
			var t: int = selected[k]
			var i0: int = indices[t * 3]
			var i1: int = indices[t * 3 + 1]
			var i2: int = indices[t * 3 + 2]
			var a2: Vector3 = xf * verts[i0]
			var b2: Vector3 = xf * verts[i1]
			var c2: Vector3 = xf * verts[i2]
			var n: Vector3 = normals[t]
			a2 += n * receiver_surface_lift
			b2 += n * receiver_surface_lift
			c2 += n * receiver_surface_lift
			st.set_normal(n); st.add_vertex(a2)
			st.set_normal(n); st.add_vertex(b2)
			st.set_normal(n); st.add_vertex(c2)
			verts_accum += 3
			if verts_accum >= max_verts_per_patch:
				break

		if verts_accum >= max_verts_per_patch:
			break

	if verts_accum == 0:
		return null

	var recv_mesh: ArrayMesh = st.commit()
	var recv: MeshInstance3D = MeshInstance3D.new()
	recv.mesh = recv_mesh
	return recv





# ---- SLIDE AREA --------------------------------------------------------------

func _make_slide_area(center_ws: Vector3, radius: float, height: float) -> Area3D:
	var area := Area3D.new()
	var cs := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	cs.shape = shape
	area.add_child(cs)
	area.global_transform.origin = center_ws

	# Notify players: call enter_ice/exit_ice if present
	area.body_entered.connect(func(b: PhysicsBody3D) -> void:
		if b and b.has_method("enter_ice"):
			b.call_deferred("enter_ice")
	)
	area.body_exited.connect(func(b: PhysicsBody3D) -> void:
		if b and b.has_method("exit_ice"):
			b.call_deferred("exit_ice")
	)
	return area
