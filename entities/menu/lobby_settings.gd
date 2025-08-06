class_name LobbySettings extends Control

@onready var _ai_count_edit := $PanelContainer/HBoxContainer/VBoxValues/AICountEdit
@onready var _online_checkbox := $PanelContainer/HBoxContainer/VBoxValues/OnlineCheckbox
@onready var _koth_checkbox := $PanelContainer/HBoxContainer/VBoxValues/KothCheckbox
@onready var _power_ups_checkbox := $PanelContainer/HBoxContainer/VBoxValues/PowerUpsCheckbox
@onready var _power_ups_rate_edit := $PanelContainer/HBoxContainer/VBoxValues/PowerUpsRateEdit
@onready var _max_player_speed_edit := $PanelContainer/HBoxContainer/VBoxValues/MaxPlayerSpeedEdit

var ai_count: int;
var is_online: bool;
var is_koth: bool;
var are_power_ups_enabled: bool;
var power_up_spawn_rate: int;
var max_player_speed: float;
var ai_brain: Brain;

func calculate_values() -> void:
	ai_count = _ai_count_edit.text.to_int()
	is_online = _online_checkbox.button_pressed
	is_koth = _koth_checkbox.button_pressed
	are_power_ups_enabled = _power_ups_checkbox.button_pressed
	power_up_spawn_rate = _power_ups_rate_edit.text.to_int()
	max_player_speed = _max_player_speed_edit.text.to_int();


static func default() -> LobbySettings:
	var settings: LobbySettings = LobbySettings.new();
	settings.ai_count = 0;
	settings.is_online = false;
	settings.is_koth = false;
	settings.are_power_ups_enabled = false;
	settings.max_player_speed = 10;
	return settings
