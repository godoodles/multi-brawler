class_name Ability
extends Node

var player

var active_duration := 0.3
var cooldown_duration := 0.5

var active_t := 0.0
var since_active := 0.0
var cooldown_t := 0.0

func _process(delta: float) -> void:
	cooldown_t -= delta

func activate() -> void:
	cooldown_t = cooldown_duration
	active_t = active_duration
	_on_activate()
func _on_activate():
	pass

func complete() -> void:
	player.on_ability_complete(self)
	_on_complete()
func _on_complete():
	pass

func process(delta):
	cooldown_t -= delta

func process_active(delta: float) -> void:
	_process_active(delta)
	since_active += delta
	active_t -= delta
	if active_t <= 0:
		complete()
# Default behavior that can be overriden completely depending on how the player needs to behave in this state
func _process_active(delta: float) -> void:
	player.process_movement(delta)

func allow_use():
	return _allow_use() and cooldown_t <= 0
# Custom allow use check that can be difined in the state
func _allow_use() -> bool: return true
