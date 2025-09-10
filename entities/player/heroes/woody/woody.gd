class_name Woody extends Hero

signal cast_frame
signal kneel_frame

# Interface Methods
func _init_combat_actions() -> void:
	combat_action_3 = ThornTrapAction.new()
	combat_action_3.name = "ThornTrapAction"
	kneel_frame.connect(func() -> void:
		combat_action_3._kneel_frame_enact()
		)
	combat_action_4 = BushAction.new()
	combat_action_4.name = "BushAction"
	cast_frame.connect(func() -> void:
		combat_action_4._cast_frame_enact())

func _signal_cast_frame() -> void:
	emit_signal(cast_frame.get_name())

func _signal_kneel_frame() -> void:
	emit_signal(kneel_frame.get_name())
