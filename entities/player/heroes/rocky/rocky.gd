class_name Rocky extends Hero

# Interface Methods
func _init_combat_actions() -> void:
	combat_action_3 = ThrowRockAction.new()
	combat_action_3.name = "ThrowRockAction"
	combat_action_3.projectile_spawner = player.level.projectile_spawner
	combat_action_4 = HardenAction.new()
	combat_action_4.name = "HardenAction"
