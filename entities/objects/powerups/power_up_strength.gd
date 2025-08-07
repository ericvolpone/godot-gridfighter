class_name PowerUpStrength extends PowerUp

func apply_power_up(player: Player) -> void:
	player.apply_strength_boost.rpc(1)
