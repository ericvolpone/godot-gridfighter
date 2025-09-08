class_name Blizzard extends AOE

@onready var blizzard_area: Area3D = $Container/BlizzardArea

func _init() -> void:
	is_tracking = false;

func get_area_3d() -> Area3D:
	return blizzard_area;

func _on_blizzard_area_body_entered(body: Node3D) -> void:
	var player: Player = body as Player
	if player != owning_player:
		player.colliding_aoes.set(self, true)

func _on_blizzard_area_body_exited(body: Node3D) -> void:
	var player: Player = body as Player
	if player != owning_player:
		player.colliding_aoes.erase(self)

func apply_effect(player: Player, delta: float) -> void:
	player.freeze_value += delta;
