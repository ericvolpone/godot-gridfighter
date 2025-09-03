class_name Torchy extends Hero

signal cast_frame

# Interface Methods
func _init_combat_actions() -> void:
	combat_action_3 = IceBoltAction.new()
	combat_action_3.name = "IceBoltAction"
	combat_action_3.projectile_spawner = player.level.projectile_spawner
	cast_frame.connect(func() -> void:
		combat_action_3._cast_frame_enact()
		)
	combat_action_4 = GustAction.new()
	combat_action_4.name = "GustAction"

func _signal_cast_frame() -> void:
	emit_signal(cast_frame.get_name())
