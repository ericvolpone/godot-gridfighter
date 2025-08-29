class_name PunchEffect extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	particles.emitting = true

func _on_gpu_particles_3d_finished() -> void:
	queue_free()
