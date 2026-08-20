extends Node

var current_save: SaveGame
var current_slot: int 

func get_save_path(slot: int) -> String:
	return "user://save_slot_%d.tres" % slot

func save_game(slot: int, data: SaveGame) -> void:
	var path := get_save_path(slot)
	var confirmation = ResourceSaver.save(data, path)

	if confirmation != OK:
		push_error("Failed to save slot %d" % slot)
		print("[SAVE] ERROR:", confirmation)
	else:
		print("[SAVE] Saved successfully to slot", slot)

	print("[SAVE] Save complete for slot:", slot)
	print("=== END SAVE GAME ===\n")

func load_game(slot: int) -> SaveGame:
	current_slot = slot
	var path := get_save_path(slot)

	print("\n=== LOAD GAME ===")
	print("[LOAD] Slot:", slot)
	print("[LOAD] Path:", path)

	if FileAccess.file_exists(path):
		current_save = ResourceLoader.load(path) as SaveGame

		if current_save == null:
			print("[LOAD] ERROR: SaveGame is NULL")
		else:
			print("[LOAD] Loaded SaveGame object:", current_save)
			print("[LOAD] collected_items:", current_save.collected_items)
			print("[LOAD] player_inventory:", current_save.player_inventory)
			print("[LOAD] npc_seen_states:", current_save.npc_seen_states)  # ⭐ NEW

		print("=== END LOAD GAME ===\n")
		return current_save

	print("[LOAD] No save file found for slot", slot)
	print("=== END LOAD GAME ===\n")
	return null

func should_item_be_removed(item_id: String) -> bool:
	print("[SAVE] checking world_id:", item_id)
	print("[SAVE] collected_items:", current_save.collected_items)

	print("\n[SAVE] CHECK REMOVE:", item_id)

	if current_save == null:
		print("[SAVE] BLOCKED: current_save is NULL")
		return false

	print("[SAVE] collected_items:", current_save.collected_items)

	var result := item_id in current_save.collected_items
	print("[SAVE] should_item_be_removed RESULT:", result)

	return result
