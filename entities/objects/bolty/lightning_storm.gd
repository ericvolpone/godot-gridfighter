class_name LightningStorm extends AOE

@onready var storm_area: Area3D = $Container/StormArea

func _init() -> void:
	is_tracking = true;

func get_area_3d() -> Area3D:
	return storm_area;

# TODO: Figure out how to do "Shocks".  Likely adding some
# data to the player that adds a shock value to them each tick
func _on_storm_area_body_entered(body: Node3D) -> void:
	var player: Player = body as Player
	if player != owning_player:
		player.colliding_aoes.set(self, true)

func _on_storm_area_body_exited(body: Node3D) -> void:
	var player: Player = body as Player
	if player != owning_player:
		player.colliding_aoes.erase(self)

func apply_effect(player: Player, delta: float) -> void:
	player.shock_value += delta;
