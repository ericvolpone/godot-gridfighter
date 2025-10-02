class_name GustAction extends CombatAction

const Gust_TTL: float = 8
var cast_tick: int = -1

@onready var aoe_spawner: AOESpawner = hero.player.level.aoe_spawner;

func _ready() -> void:
	is_action_state = true;
	action_state_string = "CastState"
	NetworkTime.on_tick.connect(_tick)

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/GustActionIcon.png";

# Interface Methods
func get_cd_time() -> float:
	return 8.0;

func execute_child(tick: int) -> void:
	cast_tick = tick + NetworkTime.seconds_to_ticks(.5)

func _tick(delta: float, tick: int) -> void:
	if cast_tick != -1 and NetworkTime.tick == cast_tick:
		cast_tick = -1
		cast()

func is_usable_child() -> bool:
	return true;

func cast() -> void:
	var spawn_direction: Vector3 = hero.player.get_facing_direction()
	aoe_spawner.spawn({
		"owner_peer_id" : hero.player.player_id,
		"aoe_type" : AOE.Type.GUST,
		"aoe_ttl" : Gust_TTL,
		"spawn_position" : hero.global_position + (spawn_direction),
		"spawn_direction" : spawn_direction
	});
