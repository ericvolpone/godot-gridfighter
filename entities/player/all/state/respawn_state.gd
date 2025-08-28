class_name RespawnState extends RewindableState

## Time in seconds the Action State should persist
var state_time: float;
var state_time_start: float;
@export var animation_name: String
@export var player: Player

func enter(_previous_state: RewindableState, _tick: int) -> void:
	state_time = player.level.respawner.respawn_time
	player.is_respawning = true
	state_time_start = NetworkTime.time;

func exit(_next_state: RewindableState, _tick: int) -> void:
	player.velocity = Vector3.ZERO
	player.is_respawning = false

func tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	if state_time_start + state_time <= NetworkTime.time:
		state_machine.transition(&"IdleState")
