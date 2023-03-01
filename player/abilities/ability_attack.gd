class_name AbilityAttack
extends Node3D

var damage := 10
@export var range := 7.0
@export var reload_duration := 0.3
@export var effect:PackedScene
@export var group := "mobs"

var player

var closest_mob
var distance_to_closest_mob := 9999.0
var direction_to_closest_mob := Vector2()

var reload_t := 0.0

func process_active(delta: float) -> void:
	reload_t -= delta
	if reload_t <= 0:
		_find_closest_mob()
		if __attack():
			reload_t = reload_duration
	_process_active(delta)
	
	if closest_mob and has_node("Sprite3D"):
		$Sprite3D.position = lerp($Sprite3D.position, player.position.direction_to(closest_mob.position) * 1.0, delta * 10.0)

func _process_active(delta: float) -> void: pass

func _physics_process(delta) -> void:
	process_active(delta)

func __attack() -> bool:
	if closest_mob and distance_to_closest_mob < range:
		return _attack()
	else:
		return false

func _attack():
	var e:AbilityEffect = effect.instantiate()
	e.emitter = player
	e.position = global_position
	e.velocity = e.position.direction_to(closest_mob.position)
	e.velocity.y = 0.0
	player.effect.emit(e)
	e.apply(closest_mob)
	return true

func _find_closest_mob() -> void:
	closest_mob = null
	distance_to_closest_mob = 99999.0
	# Choosing a random direction so not every attack targets the same enemy
	# it could instead work like brotato where the weapons are rotating, or something more original
	#var direction = Vector2.RIGHT.rotated(randf() * TAU)
	for mob in get_tree().get_nodes_in_group(group):
		var distance = player.position.distance_to(mob.position)
		if distance < distance_to_closest_mob:
			direction_to_closest_mob = player.position_h.direction_to(mob.position_h)
			#if direction.dot(direction_to_closest_mob) > 0.5:
			distance_to_closest_mob = distance
			closest_mob = mob

