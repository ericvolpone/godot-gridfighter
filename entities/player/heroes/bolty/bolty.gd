class_name Bolty extends Hero

signal cast_frame

# Interface Methods
func _init_combat_actions() -> void:
	combat_action_3 = StormAction.new()
	combat_action_4 = GustAction.new()
	cast_frame.connect(func() -> void:
		combat_action_4._cast_frame_enact()
		)

func _signal_cast_frame() -> void:
	emit_signal(cast_frame.get_name())
