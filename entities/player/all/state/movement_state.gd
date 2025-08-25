class_name MovementState  extends RewindableState

# A base movement state for common functions, extend when making new movement state.

@export var animation_name: String
@export var player: Player
@onready var player_input: Brain = player.brain

# Default movement, override as needed
func move_player(delta: float, speed: float = player.current_move_speed) -> void:
	player.velocity *= NetworkTime.physics_factor
	player.move_and_slide()
	player.velocity /= NetworkTime.physics_factor

# https://foxssake.github.io/netfox/netfox/tutorials/rollback-caveats/#characterbody-on-floor
func force_update_is_on_floor() -> void:
	var old_velocity: Vector3 = player.velocity
	player.velocity *= 0
	player.move_and_slide()
	player.velocity = old_velocity

func get_movement_input() -> Vector3:
	return player_input.move_direction

func get_jump() -> float:
	return player_input.jump_strength
