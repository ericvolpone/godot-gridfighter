class_name ThrowRockAction extends CombatAction

var projectile_spawner: ProjectileSpawner;

func _ready() -> void:
	is_action_state = true
	action_state_string = "CastState"
	action_animation = Player.ANIM_CAST

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/ThrowRockActionIcon.png";

func get_cd_time() -> float:
	return 3.0;
	
func is_usable_child() -> bool:
	return true;

func execute_child(tick: int) -> void:
	pass

func can_move() -> bool:
	return true

func xz_multiplier() -> float:
	return .5

func y_velocity_override() -> float:
	return 0

func y_velocity_override_deceleration() -> bool:
	return false

func _cast_frame_enact() -> void:
	var spawn_location: Vector3 = hero.player.global_position + (hero.player.get_facing_direction()) + Vector3(0,1,0);
	
	var spawn_data: Dictionary = {
		"projectile_type": Projectile.Type.ROCK,
		"direction": hero.player.get_facing_direction() + (Vector3.DOWN * .25),
		"spawn_location": spawn_location,
		"speed": hero.player.strength() * 2,
		"owner_peer_id": hero.player.get_multiplayer_authority()
	}
	projectile_spawner.spawn(spawn_data)
