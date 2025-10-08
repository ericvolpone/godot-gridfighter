class_name HardenAction extends CombatAction

const HARDEN_TTL: float = 4

var active_harden: AOE

@onready var aoe_spawner: AOESpawner = hero.player.level.aoe_spawner;

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/HardenActionIcon.png";

# Interface Methods
func get_cd_time() -> float:
	return 8.0;

func execute_child(tick: int) -> void:
	active_harden = aoe_spawner.spawn({
		"owner_peer_id" : hero.player.player_id,
		"aoe_type" : AOE.Type.HARDEN,
		"aoe_ttl" : HARDEN_TTL
	});

func can_move() -> bool:
	return true

func xz_multiplier() -> float:
	return 1

func y_velocity_override() -> float:
	return 0

func y_velocity_override_deceleration() -> bool:
	return false

func rewind() -> void:
	if active_harden:
		active_harden.queue_free()
		active_harden = null

func is_usable_child() -> bool:
	return true;
