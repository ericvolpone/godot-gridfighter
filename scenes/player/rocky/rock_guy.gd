class_name RockGuy extends Node3D

signal punch_frame;

func emit_punch_signal() -> void:
	emit_signal("punch_frame")
