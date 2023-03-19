extends Sprite3D

@export var color := Color.TRANSPARENT :
	set(value):
		color = value
		$Effect/GlowBall.material_override.albedo_color = color

func _ready() -> void:
	$Effect/GlowBall.material_override.albedo_color = color
