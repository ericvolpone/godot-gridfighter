class_name StatusEffectState extends ActionState

@export var status_scene: PackedScene

func enter(_previous_state: RewindableState, _tick: int) -> void:
	print("Status Effect Applied")
	player.add_child(status_scene.instantiate())
