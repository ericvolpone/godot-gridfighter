class_name BlockAction extends AbstractCombatAction

const BLOCK_ANIMATION: String = "rockguy_anim_lib/RockGuy_Block";

func _ready() -> void:
	get_player().animator.animation_finished.connect(_on_block_animation_finished);
	print("Added animation handler");

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child() -> void:
	get_player().is_blocking = true;
	get_player().animator.play(BLOCK_ANIMATION, .5);

func is_usable_child() -> bool:
	return true;

func _on_block_animation_finished(anim_name: String) -> void:
	print("Animation name = " + anim_name)
	if(BLOCK_ANIMATION == anim_name):
		get_player().is_blocking = false;
