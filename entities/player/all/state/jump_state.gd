class_name JumpState extends MovementState

func enter(_previous_state: RewindableState, _tick: int) -> void:
	player.velocity.y = player.jump_velocity

func tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	move_player(delta)
	
	force_update_is_on_floor()	
	if player_input.using_combat_action_1:
		state_machine.transition(&"PunchState")
	elif player_input.using_combat_action_2:
		state_machine.transition(&"BlockState")
	elif player_input.using_combat_action_3 and player.hero.combat_action_3.is_action_state:
		state_machine.transition(player.hero.combat_action_3.action_state_string)
	elif player_input.using_combat_action_4 and player.hero.combat_action_4.is_action_state:
		state_machine.transition(player.hero.combat_action_4.action_state_string)

	elif not player.is_on_floor():
		state_machine.transition(&"FallState")


func move_player(_delta: float, speed: float = player.current_move_speed) -> void:
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
