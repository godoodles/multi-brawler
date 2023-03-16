extends Node3D
class_name AbilityEffect

@export var emitter:NodePath
@export var original_target:NodePath
@export var velocity:Vector3
@export var timeout:float = 5.0
@export var knockback:float = 1.0
@export var damage:int = 1

func _ready() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.timeout.connect(_timeout.bind())
	timer.start(timeout)

func apply(target:Node3D):
	# sometimes multiplayer is null, sems like a bug, idk...
	if not multiplayer:
		return

	if multiplayer.is_server():
		target.hit.rpc(inst_to_dict(self), target.global_position)
	else:
		target.hit(self)

func _timeout():
	if multiplayer.is_server():
		queue_free()
