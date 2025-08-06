class_name PowerUp extends Area3D

@onready var sprite: AnimatedSprite3D = $Sprite
var power_up_spawn_point: Node3D;

signal signal_power_up_applied

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("default")
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not is_multiplayer_authority(): return;

	if body is Player:
		apply_powerup(body as Player)
		emit_signal("signal_power_up_applied", power_up_spawn_point)
		queue_free();

func apply_powerup(player: Player) -> void:
	push_error("Define apply_powerup in the child");
