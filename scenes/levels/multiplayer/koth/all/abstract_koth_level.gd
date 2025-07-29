class_name AbstractKothLevel extends AbstractMultiplayerLevel

# Packed Scenes
@onready var koth_ring_scene: PackedScene = preload("res://scenes/levels/multiplayer/koth/all/koth_ring.tscn")
@onready var koth_scoreboard_scene: PackedScene = preload("res://scenes/ui/scoreboard/koth_scoreboard.tscn")

# KOTH Variables
var koth_scoreboard: KothScoreboard;
@export var koth_rings: Array[KothRing];
var seconds_for_each_ring: float = 6
var seconds_between_rings: float = 1
@onready var ring_index_count: int = koth_rings.size()
@onready var next_ring_index: int = rng.randi_range(0, ring_index_count-1)
var current_ring: KothRing = null;

var time_between_scoring: float = 1.5;
var time_until_next_score: float = Time.get_unix_time_from_system();


# Scoring Variables
var score_by_player: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
	if koth_rings.is_empty():
		push_error("There are no KOTH rings defined on the map")
	
	for koth_ring: KothRing in koth_rings:
		koth_ring.mark_inactive()
	
	create_timer_for_next_hill()
	for player: Player in player_chars:
		score_by_player[player.player_name] = 0
	for ai: Player in ai_chars:
		score_by_player[ai.player_name] = 0
	
	koth_scoreboard = koth_scoreboard_scene.instantiate();
	add_child(koth_scoreboard)

# TODO Why isn't this working if its _process() ?
func _physics_process(delta: float) -> void:
	#super._physics_process(delta);
	increment_koth_score(delta)

func increment_koth_score(delta: float) -> void:
	var current_time: float = Time.get_unix_time_from_system()
	
	if(current_time > time_until_next_score):
		if(current_ring != null):
			current_ring.flash_ring()
			# Give a point to everybody in the ring
			var players_in_ring: Array = get_players_in_current_ring(player_chars);
			players_in_ring.append_array(get_players_in_current_ring(ai_chars));
			for player: Player in players_in_ring:
				score_by_player[player.player_name] += 1
			
			time_until_next_score = time_until_next_score + time_between_scoring

func get_players_in_current_ring(player_set: Dictionary) -> Array:
	if(current_ring == null):
		return []
	var players_in_ring: Array = []

	for player: Player in player_set:
		var horizontal_distance: float = Vector2(
			player.global_position.x - current_ring.global_position.x, 
		 	player.global_position.z - current_ring.global_position.z).length();
		var to_player: Vector3 = player.global_position - current_ring.global_position
		var distance: float = to_player.length()

		# Check if within ring (outer radius) and clipping the y axis
		# TODO Maybe adjust these magic numbers, but for now its working
		if distance <= current_ring.ring_radius and player.global_position.y >= current_ring.global_position.y - 0.5 and player.global_position.y <= current_ring.global_position.y + 3:
			players_in_ring.append(player)

	return players_in_ring

func respawn_player(player: Player) -> void:
	var spawn_positions: Array = get_player_spawn_positions();
	var spawn_index: int = rng.randi_range(0, get_player_spawn_positions().size() - 1);
	player.global_position = get_player_spawn_positions()[spawn_index];

func get_match_type() -> MPMatchType:
	return MPMatchType.KING_OF_THE_HILL;

func create_timer_for_next_hill() -> void:
	get_tree().create_timer(seconds_for_each_ring).timeout.connect(func() -> void:
		if(current_ring != null):
			current_ring.mark_inactive()
		get_tree().create_timer(seconds_between_rings).timeout.connect(func() -> void:
			current_ring = koth_rings[rng.randi_range(0, ring_index_count-1)]
			current_ring.mark_active()
			time_until_next_score = Time.get_unix_time_from_system() + time_between_scoring
			create_timer_for_next_hill()
			)
		)
