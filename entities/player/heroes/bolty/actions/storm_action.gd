class_name StormAction extends CombatAction

const STORM_TTL: float = 4
var active_storm: AOE

@onready var aoe_spawner: AOESpawner = hero.player.level.aoe_spawner;

func _ready() -> void:
	is_action_state = true;
	action_state_string = "ShoutState"
	action_animation = Player.ANIM_SHOUT

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/LightningStormActionIcon.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child(tick: int) -> void:
	active_storm = aoe_spawner.spawn({
		"owner_peer_id" : hero.player.player_id,
		"aoe_type" : AOE.Type.STORM,
		"aoe_ttl" : STORM_TTL
	});

func can_move() -> bool:
	return true

func xz_multiplier() -> float:
	return .25

func y_velocity_override() -> float:
	return 2

func y_velocity_override_deceleration() -> bool:
	return true

func rewind() -> void:
	if active_storm:
		active_storm.queue_free()
		active_storm = null

func is_usable_child() -> bool:
	return true;
