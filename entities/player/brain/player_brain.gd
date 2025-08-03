class_name PlayerBrain extends Brain

func get_movement_direction() -> Vector3:
	if not is_multiplayer_authority(): return Vector3.ZERO;
	
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction: Vector3 = (get_parent().transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	return direction;

func should_jump() -> bool:
	return is_multiplayer_authority() and Input.is_action_just_pressed("jump");

func should_use_combat_action_1() -> bool:
	return is_multiplayer_authority() and Input.is_action_just_pressed("combat_1")

func should_use_combat_action_2() -> bool:
	return is_multiplayer_authority() and Input.is_action_just_pressed("combat_2")

func should_use_combat_action_3() -> bool:
	return is_multiplayer_authority() and Input.is_action_just_pressed("combat_3")
