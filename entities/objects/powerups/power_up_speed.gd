class_name PowerUpSpeed extends PowerUp

func apply_power_up(player: Player) -> void:
	player.apply_speed_boost(1)
