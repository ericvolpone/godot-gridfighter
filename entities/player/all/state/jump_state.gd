class_name JumpState extends MovementState

func enter(previous_state: RewindableState, tick: int) -> void:
	player.velocity.y = player.jump_velocity

func tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	move_player(delta)
	
	force_update_is_on_floor()
	if player_input.using_combat_action_1:
		state_machine.transition(&"PunchState")

	elif not player.is_on_floor():
		state_machine.transition(&"FallState")


func move_player(delta: float, speed: float = player.current_move_speed) -> void:
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

	# https://foxssake.github.io/netfox/netfox/tutorials/rollback-caveats/#characterbody-velocity
	player.velocity *= NetworkTime.physics_factor
	player.move_and_slide()
	player.velocity /= NetworkTime.physics_factor
