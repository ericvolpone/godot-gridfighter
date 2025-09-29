@abstract
class_name ProjectileImpact extends Node3D

@export var shape: Shape3D = SphereShape3D.new()
@export var duration: float = 0.5
var has_checked: bool = false
var birth_tick: int
var death_tick: int
var despawn_tick: int
var players_impacted: Dictionary[Player, bool] = {}

func _ready() -> void:
	birth_tick = NetworkTime.tick
	death_tick = birth_tick + NetworkTime.seconds_to_ticks(duration)
	despawn_tick = death_tick + NetworkRollback.history_limit

	NetworkRollback.on_process_tick.connect(_rollback_tick)
	NetworkTime.on_tick.connect(_tick)

	# Run from birth tick on next loop
	NetworkRollback.notify_resimulation_start(birth_tick)

func _rollback_tick(tick: int) -> void:
	if tick < birth_tick or tick > death_tick:
		# Tick outside of range
		return

	for player in _get_overlapping_players():
		# Check if we have already applied our impact to the player
		if players_impacted.has(player):
			return;
		players_impacted.set(player, true)
		var diff := player.global_position - global_position
		var offset := Vector3(diff.x, max(0, diff.y), diff.z).normalized()
		
		VLogger.log_mp("Applying impact to player ", player.player_name)
		apply_impact(player, offset) # For Fireball, this increases burn_value by 5
		NetworkRollback.mutate(player)

func _tick(_delta: float, tick: int) -> void:
	if tick >= death_tick:
		visible = false

	if tick > despawn_tick:
		queue_free()

func _get_overlapping_players() -> Array[Player]:
	var result: Array[Player] = []

	var state := get_world_3d().direct_space_state
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = global_transform

	var hits := state.intersect_shape(query)
	for hit in hits:
		var hit_object: Node3D = hit["collider"]
		if hit_object is Player:
			result.push_back(hit_object)

	return result

@abstract
func apply_impact(player: Player, direction: Vector3) -> void;
