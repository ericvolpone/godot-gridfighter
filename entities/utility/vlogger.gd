extends Node

func log_mp(...strings: Array) -> void:
	var mp_id_length: int = 10;
	var padded_mp_id: String = str(multiplayer.get_unique_id()).pad_zeros(mp_id_length)
	print("T-", NetworkTime.tick, " - [MP-", padded_mp_id, "] ", strings)
