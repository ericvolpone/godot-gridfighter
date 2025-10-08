class_name BlockAction extends CombatAction

func _ready() -> void:
	is_interuptable = false

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/BlockActionIcon.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child(tick: int) -> void:
	pass

func can_move() -> bool:
	return false

func xz_multiplier() -> float:
	return 0

func y_velocity_override() -> float:
	return 0

func y_velocity_override_deceleration() -> bool:
	return false

func is_usable_child() -> bool:
	return true;
