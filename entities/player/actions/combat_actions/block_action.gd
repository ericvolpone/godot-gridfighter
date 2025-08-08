class_name BlockAction extends CombatAction

func _ready() -> void:
	player.animator.animation_finished.connect(_on_block_animation_finished);

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/shield.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child() -> void:
	player.is_blocking = true;
	player.play_anim(Player.ANIM_BLOCK, 0.3)

func is_usable_child() -> bool:
	return true;

func _on_block_animation_finished(anim_name: String) -> void:
	if(Player.ANIM_BLOCK == anim_name):
		player.is_blocking = false;
