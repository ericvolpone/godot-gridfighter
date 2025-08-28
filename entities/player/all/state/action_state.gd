class_name ActionState extends MovementState

## Time in seconds the Action State should persist
@export var state_time: float;

var state_time_start: float;
## If the player can move in XZ during this action
@export var can_move: bool = true
## If the player can jump during this action
@export var can_jump: bool = true
## Any XZ Movement modifier during this action
@export var xz_movement_modifier: float = 1.0;
## Speed for XZ velocity override (Y will always be 0)
@export var xz_velocity_override: Vector3;
## Will the velocity override decelerate to 0?
@export var is_xz_velocity_override_decellerating: bool;
## Speed for Y velocity override
@export var y_velocity_override: float;
## Will the velocity override decelerate to 0?
@export var is_y_velocity_override_decellerating: bool;

func enter(_previous_state: RewindableState, _tick: int) -> void:
	state_time_start = NetworkTime.time;

func tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	move_player(delta)
	force_update_is_on_floor()

	if state_time_start + state_time <= NetworkTime.time:
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
		var deceleration: float = 0
		if is_y_velocity_override_decellerating:
			deceleration = (NetworkTime.time - state_time_start) / state_time
		player.velocity.y = y_velocity_override * (1 - deceleration)

	var horizontal_velocity: Vector3;
	var input_dir : Vector3 = get_movement_input()
	if xz_velocity_override:
		var deceleration: float = 0
		if is_xz_velocity_override_decellerating:
			deceleration = (NetworkTime.time - state_time_start) / state_time
		horizontal_velocity = xz_velocity_override * (1 - deceleration)
	elif can_move:
		var position_target: Vector3 = input_dir * speed
		horizontal_velocity = position_target * xz_movement_modifier
	else:
		pass

	if horizontal_velocity:
		player.velocity.x = horizontal_velocity.x
		player.velocity.z = horizontal_velocity.z
		player.rotation.y = -atan2(-horizontal_velocity.x, horizontal_velocity.z)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
		player.velocity.z = move_toward(player.velocity.z, 0, speed)

	player.move_and_slide_physics_factor()
