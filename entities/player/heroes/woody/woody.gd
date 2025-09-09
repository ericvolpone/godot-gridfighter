class_name Woody extends Hero

signal cast_frame

# Interface Methods
func _init_combat_actions() -> void:
	combat_action_3 = ThornTrapAction.new()
	combat_action_3.name = "ThornTrapAction"
	combat_action_4 = BushAction.new()
	combat_action_4.name = "BushAction"

func _signal_cast_frame() -> void:
	emit_signal(cast_frame.get_name())
