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
			if player.is_cold:
				player.remove_cold()
			if player.is_frozen:
				player.remove_freeze()
			
			get_tree().create_timer(respawn_time + 1).timeout.connect(func() -> void:
				respawn_point_availability[respawn_point] = true;
			)
			return;
