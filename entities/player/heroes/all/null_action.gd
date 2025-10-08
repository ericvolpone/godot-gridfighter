class_name NullAction extends CombatAction

# Interface Methods
func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/punch.png";

func get_cd_time() -> float:
	return DEFAULT_CD

func execute_child(tick: int) -> void:
	pass

func is_usable_child() -> bool:
	return false;

func handle_animation_signal() -> void:
	pass
