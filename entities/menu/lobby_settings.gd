class_name LobbySettings extends Control

@onready var _ai_count_edit := $PanelContainer/HBoxContainer/VBoxValues/AICountEdit
@onready var _online_checkbox := $PanelContainer/HBoxContainer/VBoxValues/OnlineCheckbox
@onready var _koth_checkbox := $PanelContainer/HBoxContainer/VBoxValues/KothCheckbox

var ai_count: int;
var is_online: bool;
var is_koth: bool;
var ai_brain: Brain;

func calculate_values() -> void:
	ai_count = _ai_count_edit.text.to_int()
	is_online = _online_checkbox.button_pressed
	is_koth = _koth_checkbox.button_pressed

static func default() -> LobbySettings:
	var settings: LobbySettings = LobbySettings.new();
	settings.ai_count = 0;
	settings.is_online = false;
	settings.is_koth = false;
	return settings
