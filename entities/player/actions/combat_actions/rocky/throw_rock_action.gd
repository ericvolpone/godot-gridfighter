class_name ThrowRockAction extends CombatAction

const rock_scene: PackedScene = preload("res://entities/objects/projectiles/rock/rock.tscn");

var projectile_spawner: ProjectileSpawner;

func get_cd_time() -> float:
	return 3.0;

func execute_child() -> void:
	if not player.is_multiplayer_authority(): return;

	var spawn_location: Vector3 = player.global_position + (player.mesh.get_global_transform().basis.z.normalized()) + Vector3(0,1,0);
	
	var spawn_data: Dictionary = {
		"direction": player.get_facing_direction(),
		"spawn_location": spawn_location,
		"force": player.current_strength,
		"owner_peer_id": player.get_multiplayer_authority()
	}
	projectile_spawner.spawn_projectile.rpc(spawn_data)

func is_usable_child() -> bool:
	return true;
