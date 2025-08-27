class_name KnockedState extends ActionState

func enter(_previous_state: RewindableState, _tick: int) -> void:
	super.enter(_previous_state, _tick)
	print("Knocking player ", player.player_name, " at: ", NetworkTime.time)
	print("Knocked State on Authority: ", multiplayer.get_unique_id())
	print("Knocked Direction XZ: ", xz_velocity_override)
	print("Knocked Direction y: ", y_velocity_override)

func exit(_next_state: RewindableState, _tick: int) -> void:
	player.velocity = Vector3(0, player.velocity.y, 0)
	player.is_knocked = false
	print("Exiting knock")

func tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	print("Knock Tick: " , _tick)
	super.tick(delta, _tick, _is_fresh)
