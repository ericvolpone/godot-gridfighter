class_name PowerUpSpeed extends PowerUp

func apply_powerup(player: Player) -> void:
	player.apply_speed_boost.rpc(1)
