class_name Respawner extends Node

# Holds respawn points and if they are available for respawn
@export var respawn_point_availability: Dictionary[Marker3D, bool]
@export var respawn_time: float = 2;

func respawn_player(player: Player) -> void:
	var respawn_points: Array[Marker3D] = respawn_point_availability.keys()
	respawn_points.shuffle()
	
	for respawn_point: Marker3D in respawn_points:
		if respawn_point_availability[respawn_point]:
			# Point is available, we can occupy and respawn
			respawn_point_availability[respawn_point] = false;
			player.global_position = respawn_point.global_position;
			player.is_knocked = false;
			player.is_standing_back_up = false;
			player.is_blocking = false;
			player.velocity = Vector3.ZERO
			player.shock_value = 0;
			player.burn_value = 0
			player.speed_boost_modifier = 0
			player.current_strength_modifier = 0
			if player.is_cold:
				player.remove_cold()
			if player.is_frozen:
				player.remove_freeze()
			if player.is_rooted:
				player.remove_root()
			
			# Remove status and AOE nodes
			for status_effect: StatusEffect in player.status_effects.keys():
				player.status_effects.erase(status_effect)
				if not status_effect.is_queued_for_deletion():
					status_effect.queue_free()
			
			for aoe: AOE in player.active_aoes.keys():
				if aoe.is_tracking:
					player.active_aoes.erase(aoe)
					if not aoe.is_queued_for_deletion():
						aoe.queue_free()

			get_tree().create_timer(respawn_time + 1).timeout.connect(func() -> void:
				respawn_point_availability[respawn_point] = true;
			)
			return;
