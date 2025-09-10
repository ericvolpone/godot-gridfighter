class_name ThrowRockAction extends CombatAction

var projectile_spawner: ProjectileSpawner;

func _ready() -> void:
	if not is_multiplayer_authority(): return;
	
	is_action_state = true
	action_state_string = "CastState"

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/ThrowRockActionIcon.png";

func get_cd_time() -> float:
	return 3.0;
	
func is_usable_child() -> bool:
	return true;

func execute_child() -> void:
	pass

func _cast_frame_enact() -> void:
	if not is_multiplayer_authority(): return

	var spawn_location: Vector3 = hero.player.global_position + (hero.player.get_facing_direction()) + Vector3(0,1,0);
	
	var spawn_data: Dictionary = {
		"projectile_type": Projectile.Type.ROCK,
		"direction": hero.player.get_facing_direction(),
		"spawn_location": spawn_location,
		"force": hero.player.strength(),
		"owner_peer_id": hero.player.get_multiplayer_authority()
	}
	projectile_spawner.spawn_projectile.rpc(spawn_data)
