extends Node2D
class_name ShadowManager

const DynamicRevealerScene : PackedScene = preload("res://game/systems/shadow_map_revealer.tscn")
const ShadowTile : PackedScene = preload("res://game/systems/shadow_tile.tscn")
const ShadowTileScript : Script = preload("res://game/systems/shadow_tile.gd")

@export var map_snap := 1.0

signal shadow_added(map_pos:Vector2, real_pos:Vector2)

var map_snap_vector := Vector2(map_snap, map_snap)
var map_reference := {}
var tracked_revealers := {}

@onready var shadow_tiles := $ShadowTiles
@onready var dyn_revealers := $DynamicRevealers
@onready var static_revealers := $StaticRevealers


func _ready():
	_e.shadow_add_dynamic_revealer.connect(_on_add_dynamic_revealer)


func _on_add_dynamic_revealer(_entity:Node):
	var new_revealer := DynamicRevealerScene.instantiate()
	new_revealer.tracked_entity = _entity
	new_revealer.position = Vector2(_entity.position.x, _entity.position.z)
	dyn_revealers.add_child(new_revealer)
	_entity.tree_exiting.connect(_on_remove_dynamic_revealer.bind(_entity))
	tracked_revealers[_entity] = new_revealer


func _on_remove_dynamic_revealer(_entity:Node):
	tracked_revealers.erase(_entity)


func _physics_process(_delta):
	reveal_shadow()
	creep_shadow()


func creep_shadow():
	for shadow_tile in map_reference.values():
		if shadow_tile.mark_for_cleanup and not shadow_tile.fading:
			var can_fade_out := false
			for mod_pos in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
				var c_pos = shadow_tile.map_pos+mod_pos
				if not map_reference.has(c_pos):
					can_fade_out = randf() > 0.8
			if can_fade_out:
				shadow_tile.start_fade_in_timer()


func reveal_shadow():
	for tracker in tracked_revealers.values():
		var radius : float = floor(tracker.tracker_radius)+0.5
		var center : Vector2 = snapped(tracker.position, map_snap_vector)
		var circle_border_positions := {}
		for r in floor(radius * sqrt(0.5))+1:
			var d : int = floor(sqrt(radius*radius - r*r))
			circle_border_positions[center.y + r] = { "min": center.x - d, "max": center.x + d}
			circle_border_positions[center.y - r] = { "min": center.x - d, "max": center.x + d}
			circle_border_positions[center.y + d] = { "min": center.x - r, "max": center.x + r}
			circle_border_positions[center.y - d] = { "min": center.x - r, "max": center.x + r}

		for y_pos in circle_border_positions.keys():
			for x_pos in range(circle_border_positions[y_pos].min, circle_border_positions[y_pos].max):
				if not map_reference.has(Vector2(x_pos, y_pos)):
					place_shadow_tile(Vector2(x_pos, y_pos))


func place_shadow_tile(map_pos:Vector2):
	var new_shadowtile = ShadowTile.instantiate()
	map_reference[map_pos] = new_shadowtile
	new_shadowtile.map_pos = map_pos
	var real_pos : Vector2 = (map_pos * map_snap) + Vector2(map_snap/2, 0)
	new_shadowtile.position = real_pos
	shadow_tiles.add_child(new_shadowtile)
	new_shadowtile.tree_exited.connect(remove_from_map_reference.bind(map_pos, real_pos))
	new_shadowtile.reveal()


func remove_from_map_reference(map_pos:Vector2, real_pos:Vector2):
	emit_signal("shadow_added", map_pos, real_pos)
	map_reference.erase(map_pos)
