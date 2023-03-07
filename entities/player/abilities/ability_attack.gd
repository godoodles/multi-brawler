class_name AbilityAttack
extends Node3D

@export var attack_damage := 10
@export var attack_range := 7.0
@export var attack_reload_duration := 0.3
@export var effect:PackedScene
@export var group := "mobs"
@export var slot:Slot.Type

var player
var attack_tween

var closest_mob:Node3D
var distance_to_closest_mob := 9999.0

var reload_t := 0.0

func process_active(delta: float) -> void:
	reload_t -= delta * (1.0 + player.attack_speed)
	if reload_t <= 0:
		_find_closest_mob()
		if __attack():
			reload_t = attack_reload_duration
	_process_active(delta)
	
	if closest_mob:
		if reload_t <= 0:
			get_parent_node_3d().rotation.y = lerp_angle(get_parent_node_3d().rotation.y, y_angle_to_close_mob(), delta * 5.0)
	else:
		get_parent_node_3d().rotation.y = lerp_angle(get_parent_node_3d().rotation.y, 0, delta * 2.5)

func _process_active(delta: float) -> void: pass

func _physics_process(delta) -> void:
	process_active(delta)

func direction_to_closest_mob() -> Vector3:
	if not closest_mob:
		return Vector3.ZERO

	var m = Vector3(closest_mob.global_position.x, 0, closest_mob.global_position.z)
	var s = Vector3(get_parent().global_position.x, 0, get_parent().global_position.z)
	return s.direction_to(m)
	
func y_angle_to_close_mob() -> float:
	var d = direction_to_closest_mob()
	return Vector2(d.x, -d.z).angle()

func attack_animation() -> void:
	var r = direction_to_closest_mob()
	if attack_tween:
		attack_tween.kill()

	attack_tween = create_tween().bind_node(self)
	attack_tween.tween_property(get_parent(), "position", r * distance_to_closest_mob, 0.02)
	attack_tween.tween_property(get_parent(), "position", Vector3.ZERO, 0.25)
	get_parent_node_3d().rotation.y = y_angle_to_close_mob()
 
func __attack() -> bool:
	if closest_mob and distance_to_closest_mob < (attack_range + player.attack_range):
		return _attack()
	else:
		return false

func _attack():
	attack_animation()
	
	var e:AbilityEffect = effect.instantiate()
	e.emitter = player.get_path()
	e.position = global_position
	e.velocity = e.position.direction_to(closest_mob.position)
	e.velocity.y = 0.0
	e.original_target = closest_mob.get_path()
	player.effect.emit(e)
	return true

func _find_closest_mob() -> void:
	closest_mob = null
	distance_to_closest_mob = 99999.0

	for mob in get_tree().get_nodes_in_group(group):
		var distance = player.position.distance_to(mob.position)
		if distance < distance_to_closest_mob:

			distance_to_closest_mob = distance
			closest_mob = mob

