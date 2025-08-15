class_name TutorialLevel extends Level

const SCENE_PREFIX: String = "res://entities/levels/tutorials/tutorial_level_"
const SCENE_POSTFIX: String = ".tscn"

var hud_scene: PackedScene = preload("res://entities/levels/tutorials/tutorial_level_hud.tscn")

var hud: TutorialHud;
var has_won: bool = false;
var ais_removed: int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	lobby_settings.ai_count = get_ai_count();
	scoreboard.hide()

	hud = hud_scene.instantiate()
	add_child(hud)
	hud.message_label.text = "Tutorial Criteria: " + get_tutorial_text()

func get_ai_count() -> int:
	push_error("Define AI count");
	return 0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if(!has_won and is_win_condition_met()):
		has_won = true;
		get_tree().change_scene_to_packed(load(SCENE_PREFIX + str(get_next_level_number()) + SCENE_POSTFIX))

func handle_player_death(player: Player) -> void:
	if(player.is_player_controlled):
		player_spawner.respawn_player(player)
	else:
		ais_removed += 1
		player.queue_free()

func get_tutorial_text() -> String:
	push_error("Not Implemented")
	return "Abstract Class Tutorial Text"

func is_win_condition_met() -> bool:
	push_error("Not Implemented")
	return are_all_ais_gone()

func are_all_ais_gone() -> bool:
	return ais_removed >= get_ai_count()

func get_level_number() -> int:
	push_error("Please define level number in child")
	return 1;

func get_next_level_number() -> int:
	push_error("Please define next level number in child")
	return 2

func add_player_to_score(_player: Player) -> void:
	pass;
