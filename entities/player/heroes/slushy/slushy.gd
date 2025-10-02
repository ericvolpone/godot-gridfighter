class_name Slushy extends Hero

# Interface Methods
func _init_combat_actions() -> void:
	combat_action_3 = IceBoltAction.new()
	combat_action_3.name = "IceBoltAction"
	combat_action_3.projectile_spawner = player.level.projectile_spawner
	combat_action_4 = BlizzardAction.new()
	combat_action_4.name = "BlizzardAction"
