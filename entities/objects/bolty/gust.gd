class_name Gust extends AOE

@onready var gust_area: Area3D = $Container/GustArea
const GUST_FORCE: float = 100;
var gust_direction: Vector3 = Vector3.ZERO

func _init() -> void:
	is_tracking = false;

func get_area_3d() -> Area3D:
	return gust_area

func _on_gust_area_body_entered(body: Node3D) -> void:
	if body is Player:
		var player: Player = body as Player
		player.gust_total_direction += gust_direction


func _on_gust_area_body_exited(body: Node3D) -> void:
	if body is Player:
		var player: Player = body as Player
		player.gust_total_direction -= gust_direction
