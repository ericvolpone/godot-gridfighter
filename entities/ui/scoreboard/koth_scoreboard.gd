class_name KothScoreboard extends Control

@onready var score_container: VSplitContainer = $VContainer/Scores
@onready var level: KothLevel = get_parent();
var score_label_by_player: Dictionary = {}

func _ready() -> void:
	for player_name: String in level.score_by_player:
		add_player_to_score(player_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	for player_name: String in level.score_by_player:
		var score: int = level.score_by_player[player_name]
		var score_label: Label = score_label_by_player[player_name]
		score_label.text = player_name + ": " + str(score)

func add_player_to_score(player_name: String) -> void:
	var score: int = level.score_by_player[player_name]
	var score_label: Label = Label.new();
	score_label.text = player_name + ": " + str(score)
	score_container.add_child(score_label)
	score_label_by_player[player_name] = score_label
