class_name ActionState extends MovementState

## Time in seconds the Action State should persist
@export var state_time: float;

var time_in_state: float;
## If the player can move in XZ during this action
@export var can_move: bool = true
## If the player can jump during this action
@export var can_jump: bool = true
## Any XZ Movement modifier during this action
@export var xz_movement_modifier: float = 1.0;
## Speed for XZ velocity override
@export var xz_velocity_override: float;
## Acceleration for XZ velocity override
@export var xz_velocity_override_acceleration: float;
## Speed for Y velocity override
@export var y_velocity_override: float;
## Acceleration for Y velocity override
@export var y_velocity_override_acceleration: float;

func enter(_previous_state: RewindableState, _tick: int) -> void:
	time_in_state = 0;

func tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	time_in_state += delta
	move_player(delta)
	force_update_is_on_floor()
	
	if time_in_state >= state_time:
		if player.is_on_floor():
			if get_movement_input() == Vector3.ZERO:
				state_machine.transition(&"IdleState")
			else:
				state_machine.transition(&"MoveState")
		else:
			state_machine.transition(&"FallState")

func move_player(delta: float, speed: float = player.current_move_speed) -> void:
	if not y_velocity_override:
		if not player.is_on_floor():
			player.apply_gravity(delta)
	else:
		player.velocity.y = y_velocity_override + (y_velocity_override_acceleration * time_in_state)
		print("Shouting velocity = ", str(player.velocity.y))

	var horizontal_velocity: Vector3;
	var input_dir : Vector3 = get_movement_input()
	if xz_velocity_override:
		horizontal_velocity = player.get_facing_direction() * xz_velocity_override
	elif can_move:
		var position_target: Vector3 = input_dir * speed
		horizontal_velocity = position_target * xz_movement_modifier
	else:
		pass

	if horizontal_velocity:
		player.velocity.x = horizontal_velocity.x
		player.velocity.z = horizontal_velocity.z
		player.rotation.y = -atan2(-input_dir.x, input_dir.z)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
		player.velocity.z = move_toward(player.velocity.z, 0, speed)

	player.move_and_slide_physics_factor()
