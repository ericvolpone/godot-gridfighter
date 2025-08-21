class_name ThrowRockAction extends CombatAction

const rock_scene: PackedScene = preload("res://entities/objects/projectiles/rock/rock.tscn");

var projectile_spawner: ProjectileSpawner;

func _ready() -> void:
	hero.animator.animation_finished.connect(_on_cast_animation_finished);

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/throw_rock.png";

func get_cd_time() -> float:
	return 3.0;
	
func is_usable_child() -> bool:
	return true;

func execute_child() -> void:
	hero.player.channel_action(self)
	hero.player.xz_speed_modifier = 0.1
	hero.player.play_anim(Player.ANIM_CAST, 0.2)

func _cast_frame_enact() -> void:
	if not is_multiplayer_authority(): return

	var spawn_location: Vector3 = hero.player.global_position + (hero.player.model.get_global_transform().basis.z.normalized()) + Vector3(0,1,0);
	
	var spawn_data: Dictionary = {
		"direction": hero.player.get_facing_direction(),
		"spawn_location": spawn_location,
		"force": hero.player.current_strength,
		"owner_peer_id": hero.player.get_multiplayer_authority()
	}
	projectile_spawner.spawn_projectile.rpc(spawn_data)

func _on_cast_animation_finished(anim_name: String) -> void:
	if not is_multiplayer_authority(): return
	
	if(Player.ANIM_CAST == anim_name):
		hero.player.end_channel_action()
		hero.player.xz_speed_modifier = 1.0
