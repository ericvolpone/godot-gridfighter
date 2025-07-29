# TODO - Prob scrap this garbage

class_name KothRingSpawner extends Node3D

# Ring Data
@export var hill_ring_scene: PackedScene;

@export var ring_locations: Array[Vector3] = [Vector3(0,0,0)];
@export var seconds_for_each_ring: float = 6
@export var seconds_between_rings: float = 1

# Game Data
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@onready var ring_index_count: int = ring_locations.size()
@onready var next_ring_index: int = rng.randi_range(0, ring_index_count-1)
var current_ring: KOTHRing = null;

# Score Data
@export var scoreboard: KothScoreboard;
var time_between_scoring: float = 1.5;
var time_until_next_score: float = Time.get_unix_time_from_system();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_timer_for_next_hill() -> void:
	get_tree().create_timer(seconds_for_each_ring).timeout.connect(func() -> void:
		if(current_ring != null):
			current_ring.queue_free()
		get_tree().create_timer(seconds_between_rings).timeout.connect(func() -> void:
			current_ring = hill_ring_scene.instantiate();
			add_child(current_ring)
			current_ring.global_position = ring_locations[rng.randi_range(0, ring_index_count-1)]
			time_until_next_score = Time.get_unix_time_from_system() + time_between_scoring
			create_timer_for_next_hill()
			)
		)
