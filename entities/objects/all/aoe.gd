class_name AOE extends Node3D

#region (Variables)
var tracking_player: Player;
var aoe_ttl: float
#endregion

#region (Functions)
func get_area_3d() -> Area3D:
	push_error("AOE Subclass must implement get_area_3d()")
	return null;

func _initialize_from_spawn_data(spawn_data: Dictionary) -> void:
	var owner_peer_id: int = spawn_data["owner_peer_id"]
	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYER)
		
	for player: Player in players:
		if player.player_id == owner_peer_id:
			tracking_player = player
			break
	aoe_ttl = spawn_data["aoe_ttl"]
	global_position = tracking_player.global_position
	if multiplayer.is_server():
		get_tree().create_timer(aoe_ttl).timeout.connect(
			func() -> void: self.queue_free()
			)

func _physics_process(_delta: float) -> void:
	if tracking_player:
		global_position = tracking_player.global_position
#endregion
