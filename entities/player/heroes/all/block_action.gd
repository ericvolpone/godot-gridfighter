class_name BlockAction extends CombatAction

func _ready() -> void:
	is_interuptable = false
	hero.animator.animation_finished.connect(_on_block_animation_finished);

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/shield.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child() -> void:
	hero.player.channel_action(self)
	hero.player.xz_velocity_override = VelocityOverride.new(Vector3.ZERO, 0);
	hero.player.is_blocking = true;
	hero.player.play_anim(Player.ANIM_BLOCK, 0.3)

func is_usable_child() -> bool:
	return true;

func _on_block_animation_finished(anim_name: String) -> void:
	if(Player.ANIM_BLOCK == anim_name):
		hero.player.is_blocking = false;
		hero.player.end_channel_action()
		hero.player.xz_velocity_override = null;
