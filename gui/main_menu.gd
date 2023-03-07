extends MarginContainer


func _on_host_button_pressed():
	_e.emit_signal("game_host")


func _on_connect_button_pressed():
	_e.emit_signal("game_connect")


func _on_add_mob_button_pressed():
	_e.emit_signal("debug_spawn_single_mob")


func _on_add_hundred_mobs_button_pressed():
	_e.emit_signal("debug_spawn_multi_mobs", 100)


func _on_start_wave_button_pressed():
	_e.emit_signal("debug_spawn_wave")
