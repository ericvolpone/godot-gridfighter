extends MovementState

func tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	move_player(delta)
	
	force_update_is_on_floor()
	if player_input.using_combat_action_1:
		state_machine.transition(&"PunchState")

	elif player.is_on_floor():
		if get_movement_input() != Vector3.ZERO:
			state_machine.transition(&"MoveState")
		elif get_jump():
			state_machine.transition(&"JumpState")
	else:
		state_machine.transition(&"FallState")
