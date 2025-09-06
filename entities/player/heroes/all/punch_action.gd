class_name PunchAction extends CombatAction

var punch_effect_scene: PackedScene = preload("res://entities/effects/punch_effect.tscn")

func _ready() -> void:
	if not is_multiplayer_authority(): return;

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/PunchActionIcon.png";

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
	var punch_radius: float = .5
	var punch_position: Vector3 = punch_origin + forward_dir * (punch_range * 0.5)
	
	_spawn_particle_effect.rpc(punch_position)
	
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
			var force: Vector3 = to_obj * 2  # Tune force as needed
			player_obj.knock_back(force, hero.player.current_strength)

@rpc("call_local", "any_peer", "unreliable")
func _spawn_particle_effect(location: Vector3) -> void:
	var punch_effect: PunchEffect = punch_effect_scene.instantiate();
	add_child(punch_effect)
	punch_effect.global_position = location
