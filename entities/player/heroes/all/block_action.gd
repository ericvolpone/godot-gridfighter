class_name BlockAction extends CombatAction

func _ready() -> void:
	is_interuptable = false

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/shield.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child() -> void:
	pass

func is_usable_child() -> bool:
	return true;
