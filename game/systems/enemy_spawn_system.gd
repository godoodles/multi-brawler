extends Node3D

const EnemySpawner := preload("res://game/systems/enemy_fog_spawner.tscn")
const EnemyTypeKevin := preload("res://entities/enemies/kevin/enemy_kevin.tscn")

@export_node_path("ShadowManager") var shadow_manager_path
@export_node_path("Node3D") var entities_path

@onready var shadow_manager : ShadowManager = get_node(shadow_manager_path)
@onready var entities : Node3D = get_node(entities_path)


func _ready():
	shadow_manager.shadow_added.connect(shadow_respawn)
	if multiplayer.is_server():
		_e.debug_spawn_single_mob.connect(spawn_mobs.bind(1))
		_e.debug_spawn_multi_mobs.connect(spawn_mobs)
		_e.debug_spawn_wave.connect(spawn_wave)
	

func initial_spawn():
	pass


func triggered_spawnpoint(enemy_scene:PackedScene, enemy_position:Vector3):
	spawn_mob(enemy_scene, enemy_position)


func shadow_respawn(map_cord_key:Vector2, real_pos:Vector2):
	if randf()> 0.1:
		return
	var new_spawner = EnemySpawner.instantiate()
	new_spawner.position = Vector3(real_pos.x, 0.0, real_pos.y+0.5)
	new_spawner.enemy_scene = EnemyTypeKevin
	new_spawner.spawn_enemy.connect(triggered_spawnpoint)
	add_child(new_spawner, true)


func spawn_mobs(amount:int):
	for i in amount:
		spawn_mob()


func spawn_wave(amount:=100):
	for i in amount:
		spawn_mob()
		await get_tree().create_timer(0.3).timeout


func get_random_player_target() -> Player:
	var all_players : Array = get_tree().get_nodes_in_group("players")
	return all_players[randi()%all_players.size()]


# We don't need the rpc part when we have things in the Multiplayer Spawner.
func spawn_mob(_enemy_scene:= EnemyTypeKevin, _spawn_pos:Vector3 = Vector3(randf_range(-20, 20), 0.0, randf_range(-20, 20))):
	var mob = _enemy_scene.instantiate()
	mob.position = _spawn_pos
	mob.position.y = 0.5
	mob.target = get_random_player_target()
	mob.effect.connect(_effect.bind())
	mob.died.connect(self._mob_died.bind(mob))
	entities.add_child(mob, true)


func _effect(effect) -> void:
	entities.add_child(effect, true)

func _mob_died(mob) -> void:
	var drop = preload("res://entities/drops/drop.tscn").instantiate()
	drop.position = mob.position
	entities.add_child(drop)
