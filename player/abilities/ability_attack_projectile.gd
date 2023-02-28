extends AbilityAttack

func _ready() -> void:
	reload_duration = 0.3

func _attack():
	var projectile = preload("res://player/abilities/ability_effects/projectile/projectile.tscn").instantiate()
	projectile.emitter = player
	projectile.position = global_position
	projectile.velocity = projectile.position.direction_to(closest_mob.position)
	projectile.velocity.y = 0.0
	player.attack.emit(projectile)
	return true
