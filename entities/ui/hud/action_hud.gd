class_name ActionHUD extends Control

@onready var action_image: TextureRect = $ActionImage
@onready var cooldown_text: Label = $CoolDownText

var action: CombatAction;

func _ready() -> void:
	var image_texture: Resource = load(action.get_action_image_path())
	action_image.texture = image_texture

func _process(_delta: float) -> void:
	var tick: int = NetworkTime.tick
	if action.is_on_cooldown(tick):
		var cooldown_time: int = action.get_remaining_cooldown_time_in_secs(tick)
		cooldown_text.text = str(cooldown_time)
	else:
		cooldown_text.text = ""
