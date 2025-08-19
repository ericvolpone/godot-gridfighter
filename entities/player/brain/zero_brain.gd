class_name ZeroBrain extends Brain

func get_movement_direction() -> Vector3:
	return Vector3(0,0,0);

func should_jump() -> bool:
	return false;

func should_use_combat_action_1() -> bool:
	return false;

func should_use_combat_action_2() -> bool:
	return false;

func should_use_combat_action_3() -> bool:
	return false;

func should_use_combat_action_4() -> bool:
	return false;
