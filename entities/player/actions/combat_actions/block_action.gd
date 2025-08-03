class_name BlockAction extends AbstractCombatAction

func _ready() -> void:
	get_player().animator.animation_finished.connect(_on_block_animation_finished);

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child() -> void:
	get_player().is_blocking = true;
	get_player().animator.play(Player.ANIM_BLOCK, .5);

func is_usable_child() -> bool:
	return true;

func _on_block_animation_finished(anim_name: String) -> void:
	if(Player.ANIM_BLOCK == anim_name):
		get_player().is_blocking = false;
