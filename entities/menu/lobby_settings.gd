class_name LobbySettings extends Control

@onready var _ai_count_edit := $PanelContainer/HBoxContainer/VBoxValues/AICountEdit
@onready var _online_checkbox := $PanelContainer/HBoxContainer/VBoxValues/OnlineCheckbox
@onready var _koth_checkbox := $PanelContainer/HBoxContainer/VBoxValues/KothCheckbox
@onready var _power_ups_checkbox := $PanelContainer/HBoxContainer/VBoxValues/PowerUpsCheckbox
@onready var _power_ups_rate_edit := $PanelContainer/HBoxContainer/VBoxValues/PowerUpsRateEdit
@onready var _max_player_speed_edit := $PanelContainer/HBoxContainer/VBoxValues/MaxPlayerSpeedEdit
@onready var _max_player_strength_edit := $PanelContainer/HBoxContainer/VBoxValues/MaxPlayerStrengthEdit
@onready var _speed_power_up_checkbox := $PowerUpContainer/HBoxContainer/PowerUpButtons/SpeedCheckBox
@onready var _strength_power_up_checkbox := $PowerUpContainer/HBoxContainer/PowerUpButtons/StrengthCheckBox

var ai_count: int;
var is_online: bool;
var is_koth: bool;
var are_power_ups_enabled: bool;
var power_up_spawn_rate: int;
var max_player_speed: float;
var max_player_strength: float;
var ai_brain: Brain;
var enabled_power_ups: Array[PowerUp.Type] = [];

func calculate_values() -> void:
	ai_count = _ai_count_edit.text.to_int()
	is_online = _online_checkbox.button_pressed
	is_koth = _koth_checkbox.button_pressed
	are_power_ups_enabled = _power_ups_checkbox.button_pressed
	power_up_spawn_rate = _power_ups_rate_edit.text.to_int()
	max_player_speed = _max_player_speed_edit.text.to_int();
	max_player_strength = _max_player_strength_edit.text.to_int()
	if _speed_power_up_checkbox.button_pressed:
		enabled_power_ups.append(PowerUp.Type.SPEED)
	if _strength_power_up_checkbox.button_pressed:
		enabled_power_ups.append(PowerUp.Type.STRENGTH)


static func default() -> LobbySettings:
	var settings: LobbySettings = LobbySettings.new();
	settings.ai_count = 0;
	settings.is_online = false;
	settings.is_koth = false;
	settings.are_power_ups_enabled = false;
	settings.max_player_speed = 10;
	settings.max_player_strength = 10;
	return settings
