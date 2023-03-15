extends CanvasLayer

var tween:Tween

func hit():
	if tween:
		tween.kill()
	
	tween = create_tween()

	$ColorRect.material.set_shader_parameter("ttl", 0.0)
	tween.tween_property($ColorRect.material, "shader_parameter/ttl", 1.0, 0.5)
