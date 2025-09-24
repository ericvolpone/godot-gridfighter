class_name IceboltImpact extends ProjectileImpact

const COLD_DURATION = 5.0;

func apply_impact(player: Player, _direction: Vector3) -> void:
	if not player.is_blocking:
		player.apply_cold(COLD_DURATION);
