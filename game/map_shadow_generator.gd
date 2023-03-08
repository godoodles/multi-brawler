extends Node2D

const ShadowTile : PackedScene = preload("res://game/shadow_tile.tscn")
const ShadowTileScript : Script = preload("res://game/shadow_tile.gd")

@export var map_snap := 20.0

var map_reference := {}

@onready var shadow_tiles := $ShadowTiles


func _ready():
	return


func _physics_process(_delta):
	$TestPlayer.position = get_global_mouse_position()
	reveal_shadow()
	creep_shadow()


func creep_shadow():
	for shadow_tile in map_reference.values():
		if shadow_tile.mark_for_cleanup and not shadow_tile.fading:
			var can_fade_out := false
			for mod_pos in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
				var c_pos = shadow_tile.map_pos+mod_pos
				if not map_reference.has(c_pos):
					can_fade_out = randf() > 0.95
			if can_fade_out:
				shadow_tile.start_fade_in_timer()


func reveal_shadow():
	var check_positions := {}
	var precision := 32
	for i in precision:
		var test_pos = $TestPlayer.position + Vector2(100, 0).rotated(((TAU/precision) * i))
		var check_position = snapped(test_pos, Vector2(map_snap, map_snap)) / map_snap
		if not check_positions.has(check_position.y):
			check_positions[check_position.y] = {"min" : check_position.x, "max" : check_position.x}
		else:
			if check_position.x < check_positions[check_position.y].min:
				check_positions[check_position.y].min = check_position.x
			if check_position.x > check_positions[check_position.y].max:
				check_positions[check_position.y].max = check_position.x
	
	for y_pos in check_positions.keys():
		for x_pos in range(check_positions[y_pos].min, check_positions[y_pos].max):
			if not map_reference.has(Vector2(x_pos, y_pos)):
				place_shadow_tile(Vector2(x_pos, y_pos))


func place_shadow_tile(map_pos:Vector2):
	var new_shadowtile = ShadowTile.instantiate()
	map_reference[map_pos] = new_shadowtile
	new_shadowtile.map_pos = map_pos
	new_shadowtile.position = (map_pos * map_snap) - Vector2(map_snap/2, map_snap/2)
	shadow_tiles.add_child(new_shadowtile)
	new_shadowtile.tree_exited.connect(remove_from_map_reference.bind(map_pos))
	new_shadowtile.reveal()


func remove_from_map_reference(map_pos:Vector2):
	map_reference.erase(map_pos)


func _on_test_player_area_entered(area:Area2D):
	area.reveal()


func _on_test_player_area_exited(area):
	area.start_fadein()


func get_neighbors(coords:Vector2):
	return []
