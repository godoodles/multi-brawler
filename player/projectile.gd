extends Node3D

@export var emitter :Node
@export var velocity := Vector3.ZERO

var spent := false

func _ready() -> void:
	look_at(position + velocity)

func _process(delta):
	position += velocity * delta * 15.0

func _timeout():
	if multiplayer.is_server():
		queue_free()

func _area_entered(area):
	if spent:
		return

	spent = true
	if multiplayer.is_server():
		area.get_parent().hit.rpc(self, 1, velocity)
	else:
		area.get_parent().hit(self, 1, velocity)

	if multiplayer.is_server():
		queue_free()
