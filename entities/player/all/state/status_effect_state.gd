class_name StatusEffectState extends ActionState

@export var status_scene: PackedScene
var status_effect: StatusEffect

func enter(_previous_state: RewindableState, _tick: int) -> void:
	print("Entering status state on ", multiplayer.get_unique_id(), " at tick ", str(_tick))
	status_effect = status_scene.instantiate();
	player.add_child(status_effect)
	super.enter(_previous_state, _tick)

func exit(_next_state: RewindableState, _tick: int) -> void:
	# TODO Why isn't this working?
	print("Exiting status state on ", multiplayer.get_unique_id(), " at tick ", str(_tick))
	if status_effect:
		status_effect.queue_free()
	super.exit(_next_state, _tick)

func tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	super.tick(delta, _tick, _is_fresh)
