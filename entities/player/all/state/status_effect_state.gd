class_name StatusEffectState extends ActionState

func enter(_previous_state: RewindableState, _tick: int) -> void:
	super.enter(_previous_state, _tick)

func exit(_next_state: RewindableState, _tick: int) -> void:
	super.exit(_next_state, _tick)

func tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	super.tick(delta, _tick, _is_fresh)
