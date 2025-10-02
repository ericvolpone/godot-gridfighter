class_name HardenAction extends CombatAction

const HARDEN_TTL: float = 4

@onready var aoe_spawner: AOESpawner = hero.player.level.aoe_spawner;

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/HardenActionIcon.png";

# Interface Methods
func get_cd_time() -> float:
	return 8.0;

func execute_child(tick: int) -> void:
	aoe_spawner.spawn({
		"owner_peer_id" : hero.player.player_id,
		"aoe_type" : AOE.Type.HARDEN,
		"aoe_ttl" : HARDEN_TTL
	});

func is_usable_child() -> bool:
	return true;
