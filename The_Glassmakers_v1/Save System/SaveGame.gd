class_name SaveGame
extends Resource

@export var player_position := Vector2(1300, 0)
@export var current_level: String = ""
@export var collected_items: Array[String] = []
@export var talked: bool = false
@export var player_inventory: Inv = Inv.new()
@export var npc_states: Dictionary = {}
@export var npc_positions: Dictionary = {}
@export var npc_spawn_indices: Dictionary = {}

# ⭐ NEW — saves which dialogue states have been seen
@export var npc_seen_states: Dictionary = {}
