extends Area2D

#get/set variables for later use
@export var npc_path: NodePath

var save_slot = SaveScreen.save_slot

#when the area is entered check if its the player, save if yes exit if no
func _on_body_entered(body: Node2D) -> void:
	#player check
	if not body.is_in_group("player"):
		return
	#get the node attacheck to the path defined earlier
	#note: placed here since it needs to run after _ready does
	var npc = get_node(npc_path)
	
	#make an area to save info to temperarily
	var save := SaveGame.new()
	
	# Copy old data if it exists into the save
	if SaveManager.current_save != null:
		save.collected_items = SaveManager.current_save.collected_items.duplicate()
		save.talked = SaveManager.current_save.talked
		save.rolly_polly_state = SaveManager.current_save.rolly_polly_state
		save.rolly_polly_spawn = SaveManager.current_save.rolly_polly_spawn
	#set/pass in new data/data that changes into the save
	save.rolly_polly_position = npc.global_position
	save.player_inventory = body.inv.duplicate(true)
	save.player_position = body.global_position
	save.current_level = get_tree().current_scene.scene_file_path
	
	#save to the designated save slot
	SaveManager.save_game(save_slot, save)
	SaveManager.current_save = save
	#keep this debug check just because save is important throughout game development and if it goes wrong everything will
	print("Save exists:", FileAccess.file_exists(SaveManager.get_save_path(save_slot)))
	print(ProjectSettings.globalize_path("user://save.tres"))
	
