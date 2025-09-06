class_name RootWallAction extends CombatAction


func _ready() -> void:
	if not is_multiplayer_authority(): return;

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/RootWallActionIcon.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child() -> void:
	if not is_multiplayer_authority(): return;

func is_usable_child() -> bool:
	return true;
