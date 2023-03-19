extends Node2D
class_name ShadowManager

const DynamicRevealerScene : PackedScene = preload("res://game/systems/shadow_map_revealer.tscn")
const ShadowTile : PackedScene = preload("res://game/systems/shadow_tile.tscn")
const ShadowTileScript : Script = preload("res://game/systems/shadow_tile.gd")

@export var map_snap := 1.0

signal shadow_added(map_pos:Vector2, real_pos:Vector2)

var map_snap_vector := Vector2(map_snap, map_snap)
var map_reference := {}
# Shadow tiles are network synced so need a unique name.
# While unique names can be guaranteed by adding nodes like so: add_child(node, true),
# it's noticablely slow and causes jank.
# Instead let's generate our own shadow tile node names.
var shadow_tile_name = 0
var tracked_revealers := {}

@onready var shadow_tiles := $ShadowTiles
@onready var dyn_revealers := $DynamicRevealers
@onready var static_revealers := $StaticRevealers

class Profiler:
	var shadow_tiles_added := 0
	var shadows_creeped := 0
	var shadow_fades := 0
	var revealer_iterations := 0
	
	func dump():
		prints("shadow_tiles_added", shadow_tiles_added)
		prints("shadows_creeped", shadows_creeped)
		prints("shadow_fades", shadow_fades)
		prints("revealer_iterations", revealer_iterations)
		print()

var p := Profiler.new()

func _ready():
	_e.shadow_add_dynamic_revealer.connect(_on_add_dynamic_revealer)
	_e.shadow_update_revealer.connect(_on_update_revealer)

func _on_add_dynamic_revealer(_entity:Node, radius:float):
	var new_revealer := DynamicRevealerScene.instantiate()
	new_revealer.tracked_entity = _entity
	new_revealer.tracker_radius = radius
	new_revealer.position = Vector2(_entity.position.x, _entity.position.z)
	dyn_revealers.add_child(new_revealer)
	tracked_revealers[_entity] = new_revealer
	_entity.tree_exiting.connect(_on_remove_dynamic_revealer.bind(_entity))

func _on_update_revealer(_entity:Node, radius:float) -> void:
	for r in [static_revealers, dyn_revealers]:
		for revelear in r.get_children():
			if revelear.tracked_entity == _entity:
				revelear.tracker_radius = radius
				return

func _on_remove_dynamic_revealer(_entity:Node):
	tracked_revealers.erase(_entity)

func _physics_process(_delta):
	p = Profiler.new()
	if multiplayer.is_server():
		reveal_shadow()
		creep_shadow()
		#p.dump()

func creep_shadow():
	for shadow_tile in map_reference.values():
		p.shadows_creeped += 1
		if shadow_tile.mark_for_cleanup and not shadow_tile.fading:
			p.shadow_fades += 1
			var can_fade_out := false
			for mod_pos in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
				var c_pos = shadow_tile.map_pos+mod_pos
				if not map_reference.has(c_pos):
					can_fade_out = randf() > 0.8
			if can_fade_out:
				shadow_tile.start_fade_in_timer.rpc()

func gridify_circle(circle_position:Vector2, circle_radius:float) -> Array[Vector2]:
	var res:Array[Vector2] = []
	var radius : float = circle_radius + 0.5
	var center : Vector2 = snapped(circle_position, map_snap_vector)
	var circle_border_positions := {}
	for r in floor(radius * sqrt(0.5))+1:
		var d : int = floor(sqrt(radius*radius - r*r))
		circle_border_positions[center.y + r] = { "min": center.x - d, "max": center.x + d}
		circle_border_positions[center.y - r] = { "min": center.x - d, "max": center.x + d}
		circle_border_positions[center.y + d] = { "min": center.x - r, "max": center.x + r}
		circle_border_positions[center.y - d] = { "min": center.x - r, "max": center.x + r}

	for y_pos in circle_border_positions.keys():
		for x_pos in range(circle_border_positions[y_pos].min, circle_border_positions[y_pos].max):
			res.push_back(Vector2(x_pos, y_pos))
	
	return res

func reveal_shadow():
	for tracker in dyn_revealers.get_children():
		for pos in gridify_circle(tracker.position, tracker.tracker_radius):
			p.revealer_iterations += 1
			var existing_tile = map_reference.get(pos)
			if not existing_tile:
				place_shadow_tile(pos)

func place_shadow_tile(map_pos:Vector2, tile:Resource = ShadowTile):
	p.shadow_tiles_added += 1
	var new_shadowtile = ShadowTile.instantiate()
	new_shadowtile.map_pos = map_pos
	var real_pos : Vector2 = (map_pos * map_snap) + Vector2(map_snap/2, 0)
	new_shadowtile.position = real_pos
	new_shadowtile.name = str(shadow_tile_name)
	shadow_tiles.add_child(new_shadowtile)
	new_shadowtile.tree_exited.connect(remove_from_map_reference.bind(map_pos, real_pos))
	new_shadowtile.reveal()
	shadow_tile_name += 1
	map_reference[map_pos] = new_shadowtile

func remove_from_map_reference(map_pos:Vector2, real_pos:Vector2):
	if multiplayer.is_server():
		emit_signal("shadow_added", map_pos, real_pos)
	map_reference.erase(map_pos)
