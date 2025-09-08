class_name ThornTrap extends AOE

@onready var area_3d: Area3D = $Area3D

func _init() -> void:
	is_tracking = false;

func _ready() -> void:
	pass

func get_area_3d() -> Area3D:
	return area_3d;

func apply_effect(_player: Player, _delta: float) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		var player: Player = body as Player
		if player != owning_player:
			player.apply_root(5)
			queue_free()
