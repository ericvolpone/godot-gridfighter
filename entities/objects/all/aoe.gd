class_name AOE extends Node3D

#region (Types)
enum Type {
	PUNCH_EFFECT,
	STORM,
	GUST,
	HARDEN,
	BLIZZARD,
	RING_OF_FIRE,
	THORN_TRAP,
	BUSH
}
#endregion

#region (Variables)
var owning_player: Player;
var aoe_ttl: float
var is_tracking: bool;
var spawn_data: Dictionary;
#endregion

#region (Functions)
func get_area_3d() -> Area3D:
	push_error("AOE Subclass must implement get_area_3d()")
	return null;

func _ready() -> void:
	_initialize_from_spawn_data()
	NetworkTime.on_tick.connect(_tick)

func _initialize_from_spawn_data() -> void:
	var owner_peer_id: String = spawn_data["owner_peer_id"]
	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYER)

	for player: Player in players:
		if player.player_id == owner_peer_id:
			owning_player = player
			player.active_aoes[self] = true
			break
	if not is_tracking:
		global_position = spawn_data["spawn_position"]
		if spawn_data.has("spawn_direction"):
			look_at(global_position - spawn_data["spawn_direction"])
	else:
		global_position = owning_player.global_position

	aoe_ttl = spawn_data["aoe_ttl"]

	if get_area_3d():
		get_area_3d().monitoring = true;

func _tick(delta: float, _tick_id: int) -> void:
	if is_queued_for_deletion():
		return

	if get_area_3d():
		for body: Node3D in get_area_3d().get_overlapping_bodies():
			if body is Player:
				var overlapping_player: Player = body as Player
				apply_effect(overlapping_player, delta)

	if is_tracking and owning_player:
		global_position = owning_player.global_position
	
	aoe_ttl -= delta
	if aoe_ttl <= 0 and is_multiplayer_authority():
		owning_player.active_aoes.erase(self)
		NetworkTime.on_tick.disconnect(_tick)
		queue_free()

func apply_effect(_player: Player, _delta: float) -> void:
	pass

#endregion
