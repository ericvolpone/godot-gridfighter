class_name StormAction extends CombatAction

const STORM_TTL: float = 4

@onready var aoe_spawner: AOESpawner = hero.player.level.aoe_spawner;

func _ready() -> void:
	if not is_multiplayer_authority(): return;

	is_action_state = true;
	action_state_string = "ShoutState"

	#hero.animator.animation_finished.connect(_on_storm_animation_finished);

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/storm.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child() -> void:
	if not is_multiplayer_authority(): return;

	aoe_spawner.spawn_aoe.rpc({
		"owner_peer_id" : hero.player.player_id,
		"aoe_type" : AOE.Type.STORM,
		"aoe_ttl" : STORM_TTL
	});
	#hero.player.channel_action(self)
	#hero.player.xz_speed_modifier = 0.25
	#hero.player.y_velocity_override = VelocityOverride.new(Vector3(0, 2, 0), -.75)
	#hero.player.play_anim(Player.ANIM_SHOUT, 0.3)

func is_usable_child() -> bool:
	return true;

#func _on_storm_animation_finished(anim_name: String) -> void:
	#if not is_multiplayer_authority(): return;
#
	#if(Player.ANIM_SHOUT == anim_name):
		#hero.player.end_channel_action()
		#hero.player.y_velocity_override = null
		#hero.player.xz_speed_modifier = 1;
