extends Area2D
class_name ItemBase

#variables
@export var item: InvItem
@export var pickup_lines: Array = []
@export var lore_lines: Array = []

@export var world_id: String = ""

var player
var waiting_for_lore := false
var recently_closed := false

var collected := false

#load or make world ids on start
func _ready():
	if world_id == "":
		var scene_path = get_tree().current_scene.scene_file_path
		var node_path = get_path()
		world_id = "%s::%s" % [scene_path, node_path]

	if item == null:
		push_error("ItemBase has no InvItem assigned!")
		return

	if SaveManager.should_item_be_removed(world_id):
		queue_free()
		return

	body_entered.connect(_on_body_entered)

#detect player proximity
func _on_body_entered(body):
	if recently_closed:
		return

	if not body.is_in_group("player"):
		return

	player = body

	if not DialogueBox.visible:
		player.interact_target = self

#detect player interaction, establishes basic dialougue flow but can be overridden by child scripts
func interact():
	if player and player.interact_target == self:
		player.interact_target = null

	DialogueBox.current_owner = self 

	var lines := []
	if pickup_lines.size() > 0:
		lines = pickup_lines.duplicate()
	else:
		lines = [
			"You found a %s." % (item.name if item else "NULL"),
            "Do you want to pick it up?"
		]

	lines.append({
		"choices": [
			{"text": "Yes"},
			{"text": "No"}
		]
	})
	print("LORE:", lore_lines)
	print("LORE SIZE:", lore_lines.size())
	DialogueBox.start_dialog(lines, self)

#basic item collection on selection of yes
func _on_dialog_choice_made(text):
	if text == "Yes":
		collected = true

	if lore_lines.size() > 0:
		waiting_for_lore = true

#grace period after dialougue is finished to prevent accidental progression
func _on_dialog_finished():
	if waiting_for_lore:
		waiting_for_lore = false

		await get_tree().process_frame

		DialogueBox.start_dialog(lore_lines, self)
		return
		
	if collected:
		_collect_item()
		queue_free()

	recently_closed = true
	await get_tree().create_timer(0.25).timeout
	recently_closed = false

#collect item into player inventory then update the save
func _collect_item():
	if player == null or item == null:
		return

	player.collect(item)
	SaveManager.current_save.collected_items.append(world_id)
	SaveManager.current_save.player_inventory = player.inv.duplicate(true)
	SaveManager.save_game(SaveManager.current_slot, SaveManager.current_save)
