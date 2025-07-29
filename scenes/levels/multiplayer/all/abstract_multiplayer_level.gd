class_name AbstractMultiplayerLevel extends AbstractLevel

enum MPMatchType {
	UNDEFINED = 0,
	KING_OF_THE_HILL = 1, 
	DEATH_MATCH = 2, 
	ELIMINATION = 3
}

# Utility Variables
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Lobby Variables
var player_chars: Dictionary = {}
var ai_chars: Dictionary = {};
var respawn_time: float = 3;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready();
	spawn_players()

func _process(delta: float) -> void:
	super._process(delta);

func spawn_players() -> void:
	var player: Player = init_player(1, "Player", true)
	player.add_brain(PlayerBrain.new())
	player_chars[player] = player
	add_child(player)
	respawn_player(player)
	
	var ai_1: Player = init_player(2, "JoeBob", false)
	ai_1.add_brain(KothAIBrain.new(self))
	ai_chars[ai_1] = ai_1
	add_child(ai_1)
	respawn_player(ai_1)

func get_match_type() -> MPMatchType:
	push_error("You must define a MP Match Type")
	return MPMatchType.UNDEFINED;

func handle_player_death(player: Player) -> void:
	match get_match_type():
		MPMatchType.KING_OF_THE_HILL:
			get_tree().create_timer(respawn_time).timeout.connect(func() -> void:
				respawn_player(player)
			);
		MPMatchType.DEATH_MATCH:
			pass;
		MPMatchType.ELIMINATION:
			pass
		_:
			if(player.is_player_controlled):
				player.global_position = get_player_spawn_positions()[0]
			else:
				ai_chars.erase(player)
				player.queue_free();
	

# Generic Methods, override in levels
func get_player_spawn_positions() -> Array:
	push_error("get_player_spawn_position Not Implemented")
	return [
		Vector3(0,0,0)
		];

func get_ai_spawn_locations() -> Array:
	push_error("Not Implemented")
	return [Vector3(1,0,1)]

func respawn_player(player: Player) -> void:
	push_error("respawn_player not implemented")
	var spawn_positions: Array = get_player_spawn_positions();
	var spawn_index: int = rng.randi_range(0, spawn_positions.size() - 1);
	player.global_position = spawn_positions[spawn_index];
