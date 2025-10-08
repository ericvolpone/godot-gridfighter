class_name FireballAction extends CombatAction

var projectile_spawner: ProjectileSpawner;
var cast_tick: int = -1;

func _ready() -> void:
	is_action_state = true
	action_state_string = "CastState"
	action_animation = Player.ANIM_CAST
	NetworkTime.on_tick.connect(_tick)

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/FireballActionIcon.png";

func get_cd_time() -> float:
	return 3.0;
	
func is_usable_child() -> bool:
	return true;

func execute_child(tick: int) -> void:
	cast_tick = tick + NetworkTime.seconds_to_ticks(.5)

func _tick(delta: float, tick: int) -> void:
	if cast_tick != -1 and NetworkTime.tick == cast_tick:
		cast_tick = -1
		cast()

func cast() -> void:
	var spawn_location: Vector3 = hero.player.global_position + (hero.player.get_facing_direction()) + Vector3(0, .5, 0)
	
	# TODO Maybe make speed adjustable by power ups?
	var spawn_data: Dictionary = {
		"projectile_type" : Projectile.Type.FIREBALL,
		"direction": hero.player.get_facing_direction(),
		"spawn_location": spawn_location,
		"speed": 8,
		"owner_peer_id": hero.player.get_multiplayer_authority()
	}
	projectile_spawner.spawn(spawn_data)
