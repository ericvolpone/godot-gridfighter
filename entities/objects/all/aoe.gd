class_name AOE extends Node3D

#region (Types)
enum Type {
	STORM,
	GUST,
	HARDEN
}
#endregion

#region (Variables)
var tracking_player: Player;
var aoe_ttl: float
var is_tracking: bool;
#endregion

#region (Functions)
func get_area_3d() -> Area3D:
	push_error("AOE Subclass must implement get_area_3d()")
	return null;

func _initialize_from_spawn_data(spawn_data: Dictionary) -> void:
	var owner_peer_id: String = spawn_data["owner_peer_id"]
	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYER)

	for player: Player in players:
		if player.player_id == owner_peer_id:
			tracking_player = player
			break
	if not is_tracking:
		global_position = spawn_data["spawn_position"]
		look_at(global_position - spawn_data["spawn_direction"])
	else:
		global_position = tracking_player.global_position

	aoe_ttl = spawn_data["aoe_ttl"]
	if multiplayer.is_server():
		get_tree().create_timer(aoe_ttl).timeout.connect(
			func() -> void: self.queue_free()
			)
	if get_area_3d():
		get_area_3d().monitoring = true;

func _physics_process(_delta: float) -> void:
	if is_tracking and tracking_player:
		global_position = tracking_player.global_position

#endregion
