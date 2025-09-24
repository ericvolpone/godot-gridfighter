class_name Rock extends Projectile

func _physics_process(_delta: float) -> void:
	if(global_position.y < -5.0):
		clear_self();
