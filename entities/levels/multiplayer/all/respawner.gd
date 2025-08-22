class_name Respawner extends Node

# Holds respawn points and if they are available for respawn
@export var respawn_point_availability: Dictionary[RespawnPoint, bool]
@export var respawn_time: float = 2;

func respawn_player(player: Player) -> void:
	print("Global Position 1: ", player.global_position)
	player.is_respawning = true
	var respawn_points: Array[RespawnPoint] = respawn_point_availability.keys()
	respawn_points.shuffle()
	
	for respawn_point: RespawnPoint in respawn_points:
		if respawn_point_availability[respawn_point]:
			print("Global Position 2: ", player.global_position)
			print("Spawning player:", player.player_name, " at spawn point: ", respawn_point.name, " on client: ", multiplayer.get_unique_id())
			# Point is available, we can occupy and respawn
			respawn_point_availability[respawn_point] = false;
			player.global_position = respawn_point.global_position;
			player.play_anim(Player.ANIM_IDLE)
			player.is_knocked = false;
			player.is_standing_back_up = false;
			player.xz_velocity_override = null;
			player.y_velocity_override = null;
			player.xz_speed_modifier = 1
			player.y_speed_modifier = 1;
			player.is_blocking = false;
			player.velocity = Vector3.ZERO
			
			print("Global Position 3: ", player.global_position)
			get_tree().create_timer(respawn_time).timeout.connect(func() -> void:
				player.is_respawning = false;
				get_tree().create_timer(1).timeout.connect(func() -> void:
					respawn_point_availability[respawn_point] = true;
				)
			);
			return;
