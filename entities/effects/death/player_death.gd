class_name PlayerDeath extends Node3D

@onready var explosion_particles: GPUParticles3D = $GPUParticles3D

signal signal_death_animation_complete

func _ready() -> void:
	explosion_particles.emitting = true

func _on_gpu_particles_3d_finished() -> void:
	print("Completed")
	emit_signal("signal_death_animation_complete")
	queue_free()
