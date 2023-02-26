extends VBoxContainer

func _ready() -> void:
	$input.grab_focus()

func _text_submitted(new_text):
	var expression := Expression.new()
	var error = expression.parse(new_text)
	if error != OK:
		append_to_output(expression.get_error_text())
	else:
		var result = expression.execute([], $"../commands")
		if expression.has_execute_failed():
			append_to_output(expression.get_error_text())
		else:
			append_to_output(result)
			$input.clear()

func append_to_output(str) -> void:
	$output.text += str(str) + "\n"
	$output.scroll_vertical = INF
