class_name IceBoltAction extends CombatAction

var projectile_spawner: ProjectileSpawner;

func _ready() -> void:
	is_action_state = true
	action_state_string = "CastState"

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/IceBoltActionIcon.png";

func get_cd_time() -> float:
	return 3.0;
	
func is_usable_child() -> bool:
	return true;

func execute_child() -> void:
	pass

func _cast_frame_enact() -> void:
	var spawn_location: Vector3 = hero.player.global_position + (hero.player.get_facing_direction()) + Vector3(0, .5, 0)
	
	# TODO Maybe make speed adjustable by power ups?
	var spawn_data: Dictionary = {
		"projectile_type" : Projectile.Type.ICE_BOLT,
		"direction": hero.player.get_facing_direction(),
		"spawn_location": spawn_location,
		"speed": 12,
		"owner_peer_id": hero.player.get_multiplayer_authority()
	}
	projectile_spawner.spawn(spawn_data)
