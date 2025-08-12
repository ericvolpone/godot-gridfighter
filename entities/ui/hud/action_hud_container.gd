class_name ActionHUDContainer extends Control

@onready var action_hud_scene: PackedScene = preload("res://entities/ui/hud/ActionHUD.tscn")

@onready var container: HBoxContainer = $MarginContainer/HBoxContainer

var action_huds: Array[ActionHUD] = [];

func add_action(combat_action: CombatAction) -> void:
	var action_hud: ActionHUD = action_hud_scene.instantiate();
	action_hud.action = combat_action
	container.add_child(action_hud)
