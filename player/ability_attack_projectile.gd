extends AbilityAttack

func _ready() -> void:
	reload_duration = 0.5

func _attack():
	# Maybe this check should be in AbilityAttack if it's the same for each attack
	# so we don't have to redefine it ever time
	if closest_mob:
		var projectile = preload("res://player/projectile.tscn").instantiate()
		projectile.emitter = player
		projectile.position = global_position
		projectile.velocity = projectile.position.direction_to(closest_mob.position)
		player.emit_signal("attack", projectile)
		return true
	else:
		return false
