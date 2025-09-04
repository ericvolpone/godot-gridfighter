class_name FallState extends MovementState

func tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	move_player(delta)
	
	force_update_is_on_floor()

	if player.is_on_floor():
		if get_movement_input() == Vector3.ZERO:
			state_machine.transition(&"IdleState")
		elif get_movement_input() != Vector3.ZERO:
			state_machine.transition(&"MoveState")
		elif get_jump():
			state_machine.transition(&"JumpState")

func move_player(delta: float, speed: float = player.movement_speed()) -> void:
	player.apply_gravity(delta)
	var input_dir : Vector3 = get_movement_input()
	var position_target: Vector3 = input_dir * speed

	var horizontal_velocity: Vector3 = player.velocity
	horizontal_velocity = position_target
	
	if horizontal_velocity:
		player.velocity.x = horizontal_velocity.x
		player.velocity.z = horizontal_velocity.z
		player.rotation.y = -atan2(-input_dir.x, input_dir.z)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
		player.velocity.z = move_toward(player.velocity.z, 0, speed)

	player.move_and_slide_physics_factor()
