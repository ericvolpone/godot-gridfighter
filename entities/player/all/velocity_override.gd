class_name VelocityOverride

var velocity: Vector3;
var acceleration_percentage: float;

func _init(_velocity: Vector3, _acceleration_percentage: float) -> void:
	velocity = _velocity
	acceleration_percentage = _acceleration_percentage

func apply_acceleration(delta: float) -> void:
	velocity = velocity + (velocity * acceleration_percentage * delta)
