class_name Torchy extends Hero

# Interface Methods
func _init_combat_actions() -> void:
	combat_action_3 = FireballAction.new()
	combat_action_3.name = "FireballAction"
	combat_action_3.projectile_spawner = player.level.projectile_spawner
	cast_frame.connect(func() -> void:
		combat_action_3._cast_frame_enact()
		)
	combat_action_4 = RingOfFireAction.new()
	combat_action_4.name = "RingOfFireAction"
	uppercut_frame.connect(func() -> void:
		combat_action_4._uppercut_frame_enact()
		)
