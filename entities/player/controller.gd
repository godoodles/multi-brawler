class_name Controller
extends Node

class Key:
	var _action := ""
	var _since_pressed := 999.0
	
	func _init(action):
		_action = action
	
	func process(delta):
		_since_pressed += delta
		if is_just_pressed():
			_since_pressed = 0.0
	
	func is_pressed():
		return Input.is_action_pressed(_action)
	
	func is_just_pressed():
		return Input.is_action_just_pressed(_action)
	
	func is_just_released():
		return Input.is_action_just_released(_action)
	
	func since_pressd() -> float:
		return _since_pressed
	
	func consume():
		_since_pressed = 999.0

var attack  = Key.new("ability_attack")
var special = Key.new("ability_special")
var dodge = Key.new("ability_dodge")
var keys = [attack, special, dodge]

func get_direction() -> Vector2:
	return $PlayerInput.direction

func _process(delta):
	for key in keys:
		key.process(delta)
