class_name PunchAction extends CombatAction

func _ready() -> void:
	if not is_multiplayer_authority(): return;

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/punch.png";

func get_cd_time() -> float:
	return 1.0;

func execute_child() -> void:
	pass;

func is_usable_child() -> bool:
	return true;

func handle_animation_signal() -> void:
	if not is_multiplayer_authority(): return;

	var punch_origin: Vector3 = hero.player.global_position
	punch_origin.y += .5; 
	var forward_dir: Vector3 = hero.player.get_facing_direction()  # forward in Godot

	var punch_range: float = 2.0
	var punch_radius: float = .3
	var punch_position: Vector3 = punch_origin + forward_dir * (punch_range * 0.5)
	draw_debug_sphere(punch_position, punch_radius)
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = punch_radius
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(Basis(), punch_position)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var results: Array = space_state.intersect_shape(query, 32)

	for result: Dictionary in results:
		var obj: Node3D = result.collider
		if obj == self:
			continue
		if obj is RigidBody3D and obj.is_in_group(Groups.PUNCHABLE_RB):  # whitelist
			var to_obj: Vector3 = (obj.global_position - global_position).normalized()
			var force: Vector3 = to_obj * hero.player.current_strength * 20  # Tune force as needed
			obj.apply_central_impulse(force)
		if obj is CharacterBody3D and obj.is_in_group(Groups.PLAYER):  # whitelist
			var player_obj: Player = obj
			if(player_obj == hero.player or player_obj.is_blocking):
				continue
			var to_obj: Vector3 = (player_obj.global_position - global_position).normalized()
			var force: Vector3 = to_obj * 10.0  # Tune force as needed
			player_obj.knock_back(force, hero.player.current_strength)

func draw_debug_sphere(sphere_position: Vector3, radius: float, duration: float = 0.5) -> void:
	var sphere_mesh: SphereMesh = SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2.0
	sphere_mesh.radial_segments = 8
	sphere_mesh.rings = 4

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.0, 0.0, 0.5)  # Red semi-transparent
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.mesh = sphere_mesh
	mesh_instance.material_override = material
	mesh_instance.global_position = sphere_position
	mesh_instance.scale = Vector3.ONE * 1.0  # optional if you want scaling

	get_tree().current_scene.add_child(mesh_instance)

	# Remove it after some time
	mesh_instance.set_physics_process(false)
	await get_tree().create_timer(duration).timeout
	mesh_instance.queue_free()
