extends Node

# Signals for debugging and testing
signal debug_spawn_wave
signal debug_spawn_single_mob
signal debug_spawn_multi_mobs(amount:int)

# Game hosting and connecting
signal game_host
signal game_connect
signal game_connected

# Game shadow mechanics
signal shadow_add_dynamic_revealer(entity:Node, radius:float)
signal shadow_update_revealer(entity:Node, radius:float)
