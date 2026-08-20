extends Area2D

@export var npc_path: NodePath
var save_slot = SaveScreen.save_slot

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var npc = get_node(npc_path)

	var save := SaveGame.new()

	if SaveManager.current_save != null:
		save.collected_items = SaveManager.current_save.collected_items.duplicate()
		save.talked = SaveManager.current_save.talked
		save.npc_states = SaveManager.current_save.npc_states.duplicate()
		save.npc_positions = SaveManager.current_save.npc_positions.duplicate()
		save.npc_spawn_indices = SaveManager.current_save.npc_spawn_indices.duplicate()

		# ⭐ NEW — copy seen dialogue states
		save.npc_seen_states = SaveManager.current_save.npc_seen_states.duplicate()

	if npc:
		# Save NPC data
		save.npc_positions[npc.npc_id] = npc.global_position
		save.npc_states[npc.npc_id] = npc.state

		if SaveManager.current_save.npc_spawn_indices.has(npc.npc_id):
			save.npc_spawn_indices[npc.npc_id] = SaveManager.current_save.npc_spawn_indices[npc.npc_id]

	# Save player
	save.player_inventory = body.inv.duplicate(true)
	save.player_position = body.global_position
	save.current_level = get_tree().current_scene.scene_file_path

	SaveManager.save_game(save_slot, save)
	SaveManager.current_save = save

	print("Save exists:", FileAccess.file_exists(SaveManager.get_save_path(save_slot)))
	print(ProjectSettings.globalize_path("user://save.tres"))
