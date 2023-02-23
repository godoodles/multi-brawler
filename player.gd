extends Sprite2D

@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$player_input.set_multiplayer_authority(id)

@onready var input = $player_input

func _process(delta):
	position += input.direction * delta * 200.0
