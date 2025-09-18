class_name BlizzardAction extends CombatAction

const BLIZZARD_TTL: float = 4

@onready var aoe_spawner: AOESpawner = hero.player.level.aoe_spawner;

func _ready() -> void:
	is_action_state = true
	action_state_string = "UppercutState"

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/BlizzardActionIcon.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child() -> void:
	pass

func _uppercut_frame_enact() -> void:
	var spawn_direction: Vector3 = hero.player.get_facing_direction()
	aoe_spawner.spawn({
		"owner_peer_id" : hero.player.player_id,
		"aoe_type" : AOE.Type.BLIZZARD,
		"aoe_ttl" : BLIZZARD_TTL,
		"spawn_position" : global_position + (spawn_direction * 3),
		"spawn_direction" : spawn_direction
	});

func is_usable_child() -> bool:
	return true;
