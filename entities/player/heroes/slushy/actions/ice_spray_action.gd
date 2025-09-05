class_name IceSprayAction extends CombatAction

var ice_manager: IceManager

func _ready() -> void:
	if not is_multiplayer_authority(): return;

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/throw_rock.png";

func get_cd_time() -> float:
	return 3.0;
	
func is_usable_child() -> bool:
	return true;

func execute_child() -> void:
	print("Raycasting")
	var start := global_transform.origin
	var end := start + Vector3.DOWN * 5

	var params := PhysicsRayQueryParameters3D.create(start, end)
	params.collision_mask = -1
	params.exclude = [self]
	params.collide_with_areas = false
	params.collide_with_bodies = true

	var hit := get_world_3d().direct_space_state.intersect_ray(params)
	if hit.is_empty():
		print ("No Hit found")
		return

	# Optional: filter to level meshes only (put your level in group "Level")
	var col: Node3D = hit.get("collider")
	print("Collider: ", str(col))
	if col and not col is StaticBody3D:
		# Not the level—skip
		return

	ice_manager.spawn_ice_patch_from_hit(hit, 3, 5)
