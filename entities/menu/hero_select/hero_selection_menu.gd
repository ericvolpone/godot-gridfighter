class_name HeroSelectionMenu extends Control

signal hero_locked_in;

var hero_selections: Array[HeroSelection];
var selected_hero: HeroSelection;
@onready var hero_selections_container: HBoxContainer = $HBoxContainer
@onready var lock_button: Button = $LockButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Populate our hero selections
	for selection: HeroSelection in hero_selections_container.get_children():
		hero_selections.append(selection)
		selection.hero_selected.connect(func() -> void:
			selected_hero = selection
			lock_button.disabled = false
			)


func _on_lock_button_pressed() -> void:
	if not selected_hero:
		return;
	emit_signal(hero_locked_in.get_name(), selected_hero.hero_definition.hero_id)
