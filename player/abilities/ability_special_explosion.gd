extends AbilitySpecial

func _ready() -> void:
	cooldown_duration = 3.0
	active_duration = 0.2

func _on_activate():
	for mob in get_tree().get_nodes_in_group("mobs"):
		var distance = player.position.distance_to(mob.position)
		if distance < range:
			mob.hit(self, 50)

func _process_active(delta):
	player.process_movement(delta, 0, 10.0, 10.0)
