class_name LightningStorm extends AOE

@onready var storm_area: Area3D = $Container/StormArea

const SLOW_MODIFIER: float = 0.5;

func _init() -> void:
	is_tracking = true;

func get_area_3d() -> Area3D:
	return storm_area;

func _on_storm_area_body_entered(body: Node3D) -> void:
	var player: Player = body as Player
	print("Player entered: " + player.player_name)


func _on_storm_area_body_exited(body: Node3D) -> void:
	var player: Player = body as Player
	print("Player exited: " + player.player_name)
