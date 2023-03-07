extends AbilityDodge

var dash_speed := 20.0

func _ready() -> void:
	active_duration = 0.15

func _on_activate():
	player.velocity_h = player.last_direction * dash_speed

func _process_active(delta: float) -> void:
	player.process_movement(delta, dash_speed, 5.0, 0.0)

func _allow_use():
	return player.is_on_floor()
