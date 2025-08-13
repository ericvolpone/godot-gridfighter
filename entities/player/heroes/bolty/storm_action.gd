class_name StormAction extends CombatAction

func _ready() -> void:
	hero.animator.animation_finished.connect(_on_storm_animation_finished);

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/storm.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child() -> void:
	hero.player.channel_action(self)
	hero.player.xz_speed_modifier = 0.25
	hero.player.y_velocity_override = VelocityOverride.new(Vector3(0, 2, 0), -.75)
	hero.player.play_anim(Player.ANIM_SHOUT, 0.3)

func is_usable_child() -> bool:
	return true;

func _on_storm_animation_finished(anim_name: String) -> void:
	if(Player.ANIM_SHOUT == anim_name):
		hero.player.end_channel_action()
		hero.player.y_velocity_override = null
		hero.player.xz_speed_modifier = 1;
		hero.player.is_casting = false;
