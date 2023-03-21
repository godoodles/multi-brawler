extends MultiplayerSynchronizer

@export var direction := Vector2()

@export var position := Vector3.ZERO
@export var body:Node3D
@export var maxinum_speed := 15.0

func _process(delta:float) -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		position = get_parent().get_parent().position
		direction = Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
	else:
		var distance:float = min(1.0, body.position.distance_to(position))
		body.velocity = body.position.direction_to(position) * maxinum_speed * distance
