class_name BlockAction extends AbstractCombatAction

func _ready() -> void:
	player.animator.animation_finished.connect(_on_block_animation_finished);

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
