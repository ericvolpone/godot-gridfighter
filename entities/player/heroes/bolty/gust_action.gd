class_name GustAction extends CombatAction

const Gust_TTL: float = 8

@onready var aoe_spawner: AOESpawner = hero.player.level.aoe_spawner;

func _ready() -> void:
	hero.animator.animation_finished.connect(_on_gust_animation_finished);

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/gust.png";

# Interface Methods
func get_cd_time() -> float:
	return 8.0;

func execute_child() -> void:
	hero.player.channel_action(self)
	hero.player.xz_velocity_override = VelocityOverride.new(Vector3.ZERO, 0)
	hero.player.play_anim(Player.ANIM_CAST, 0.2)

func is_usable_child() -> bool:
	return true;

func _cast_frame_enact() -> void:
	var spawn_direction: Vector3 = hero.player.get_facing_direction()
	aoe_spawner.spawn_aoe.rpc({
		"owner_peer_id" : hero.player.player_id,
		"aoe_type" : AOE.Type.GUST,
		"aoe_ttl" : Gust_TTL,
		# TODO This doesn't seem to work haha
		"spawn_position" : global_position + (spawn_direction),
		"spawn_direction" : spawn_direction
	});

func _on_gust_animation_finished(anim_name: String) -> void:
	# TODO This needs its own animation or internal signal
	if(Player.ANIM_CAST == anim_name):
		hero.player.end_channel_action()
		hero.player.xz_velocity_override = null
