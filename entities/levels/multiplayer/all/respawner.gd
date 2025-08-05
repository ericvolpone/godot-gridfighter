class_name Respawner extends Node

# Holds respawn points and if they are available for respawn
@export var respawn_point_availability: Dictionary[RespawnPoint, bool]
@export var respawn_time: float = 3;

func respawn_player(player: Player) -> void:
	var respawn_points: Array[RespawnPoint] = respawn_point_availability.keys()
	respawn_points.shuffle()
	
	for respawn_point: RespawnPoint in respawn_points:
		if respawn_point_availability[respawn_point]:
			# Point is available, we can occupy and respawn
			respawn_point_availability[respawn_point] = false;
			player.global_position = respawn_point.global_position;
			# TODO Would be cool to freeze player in place for a bit
			get_tree().create_timer(respawn_time).timeout.connect(func() -> void:
				respawn_point_availability[respawn_point] = true;
			);
			return;
