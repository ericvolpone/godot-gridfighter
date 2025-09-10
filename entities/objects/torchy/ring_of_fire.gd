class_name RingOfFire extends AOE

@onready var area_3d: Area3D = $Area3D

#region (Functions)
func get_area_3d() -> Area3D:
	return area_3d;

func apply_effect(player: Player, delta: float) -> void:
	player.burn_value += delta

#endregion

func _on_area_3d_body_entered(body: Node3D) -> void:
	var player: Player = body as Player
	if player != owning_player:
		player.colliding_aoes.set(self, true)
		
func _on_area_3d_body_exited(body: Node3D) -> void:
	var player: Player = body as Player
	if player != owning_player:
		player.colliding_aoes.erase(self)
