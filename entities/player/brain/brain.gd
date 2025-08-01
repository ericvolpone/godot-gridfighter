class_name Brain extends Node

func get_movement_direction() -> Vector3:
	push_error("Implement get_xz_movement_direction in child brain");
	return Vector3(0,0,0);

func should_jump() -> bool:
	push_error("Implement should_jump in child brain");
	return false;

func should_use_combat_action_1() -> bool:
	push_error("Implement should_use_combat_action_1 in child brain");
	return false;

func should_use_combat_action_2() -> bool:
	push_error("Implement should_use_combat_action_2 in child brain");
	return false;

func should_use_combat_action_3() -> bool:
	push_error("Implement should_use_combat_action_3 in child brain");
	return false;
