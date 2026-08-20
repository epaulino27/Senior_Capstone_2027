extends NPCBase
class_name RollyPollyNPC

#variables
@onready var movement_speed = 900
@onready var start_portal = $"../Portals/start"
@onready var end_portal = $"../Portals/end"
@export var inv: Inv

var spawn_points = []
var spawn_index
var player_name = "Default"

var queued_state: String = ""
var roll_target: Vector2

#set spawn points, load save data, general setup
func _ready():
	super._ready()

	npc_id = "rolly_polly"
	dialog_lines = []

	spawn_points = [
		Vector2(500, position.y + 5),
		Vector2(-1565, position.y - 690),
		Vector2(1400, position.y - 1820),
		Vector2(-1500, position.y - 1820)
	]

	spawn_index = SaveManager.current_save.npc_spawn_indices.get(npc_id, 0)

	if SaveManager.current_save.npc_positions.has(npc_id):
		position = SaveManager.current_save.npc_positions[npc_id]
	else:
		position = spawn_points[spawn_index]

	var saved_state = SaveManager.current_save.npc_states.get(npc_id, "idle")
	if typeof(saved_state) != TYPE_STRING:
		saved_state = "idle"

	set_state(saved_state)

	if state in ["roll_left", "roll_right"]:
		set_state("idle")

#detects player proximity and triggers initial and ending state
func _on_player_entered(body):
	if get_worker_count(body.inv) >= 5:
		set_state("finished")
		return
	if state == "idle":
		set_state("ball_up")

# ---------------------------------------------------------
# MOVEMENT SYSTEM
# ---------------------------------------------------------

func update_state(delta):
	match state:
		"roll_left", "roll_right":
			var dir = (roll_target - position).normalized()
			position += dir * movement_speed * delta

			# Check arrival at roll_target, not spawn_points[spawn_index]
			if position.distance_to(roll_target) <= 10.0:
				set_state("despawn")

		"idle", "cower", "talk", "finished":
			SaveManager.current_save.npc_positions[npc_id] = position

func _on_NPCSprite_animation_finished():
	print("ANIMATION FINISHED:", state)
	if state == "finished":
		return

	if state == "ball_up":
		if spawn_index == 0 or spawn_index == 2:
			set_state("roll_left")
		elif spawn_index == 1:
			set_state("roll_right")
		else:
			set_state("cower")

func enter_state(s):
	match s:
		"idle":
			play_animation("idle")
		"ball_up":
			play_animation("ball_up")
		"roll_left":
			play_animation("rolling")
			var next_index = min(spawn_index + 1, spawn_points.size() - 1)
			roll_target = Vector2(spawn_points[next_index].x, position.y)
		"roll_right":
			play_animation("rolling")
			var next_index = min(spawn_index + 1, spawn_points.size() - 1)
			roll_target = Vector2(spawn_points[next_index].x, position.y)
		"despawn":
			play_animation("idle")
			visible = false
			await get_tree().process_frame
			set_state("respawn")
		"respawn":
			spawn_index += 1
			SaveManager.current_save.npc_spawn_indices[npc_id] = spawn_index

			if spawn_index >= spawn_points.size():
				spawn_index = spawn_points.size() - 1
				position = spawn_points[spawn_index]
				visible = true
				set_state("cower")
				return

			position = spawn_points[spawn_index]
			visible = true
			set_state("idle")
		"cower":
			play_animation("shivering")

			var choices = [
				{"text": "Poke him."},
				{"text": "Tell him your not a monster."},
				{"text": "Ask him about his team lead."}
			]

			if player_ref != null and player_ref.player_has("paper"):
				choices.insert(0, {"text": "Show him the poster you found."})

			if not has_seen("cower"):
				mark_seen("cower")
				dialog_lines = [
					"Go away monster!",
					"My team lead will be here any m-minute and shes a lot bigger than me so you better run!",
					{"choices": choices}
				]
			else:
				dialog_lines = [
					{"choices": choices}
				]

		"talk":
			play_animation("idle")
			
			var choices = [
				{"text": "Yes."},
				{"text": "No."}
			]

			if not has_seen("talk"):
				mark_seen("talk")
				dialog_lines = [
					"...",
					"So your really not a monster you pinkie promise? And your here to help since you have my poster so...",
					"...",
					"Can you help my siblings please Miss Monster?",
					{"choices": choices}
				]
			else:
				dialog_lines = [
					{"choices": choices}
				]
		"finished":
			play_animation("idle")

			# Remove workers & poster from inventory
			if player_ref != null:
				clear_lvl_items(player_ref.inv)
				

			# Unlock portals
			start_portal.end_target = end_portal.get_path()
			start_portal.target = end_portal

			dialog_lines = [
				"You found my coworkers!!! Thank you so much!",
				"The portals should be fixed now, so you can go up and leave the city if you need to.",
				"I don't know you or really know how to explain it but I just I feel like your meant to go up?"
			]

func _child_choice_made(text):
	queued_state = "cower"

	var response_lines := []

	match text:
		"Poke him.":
			response_lines = [
				"I'm not doing that, it's a scared little guy what's wrong with you?"
			]

		"Tell him your not a monster.":
			response_lines = [
				"...",
                "...sounds like something a monster would say."
			]

		"Ask him about his team lead.":
			response_lines = [
				"She was supposed to be back a few days ago after checking up on our water filtration system, but then she just up and dissapeared.",
				"No ones seen even a trace of her and, well, we were trying to fix teh portals to be able to check ourselves but without her we're kind of...inefficient.",
				"You'd think the head engineer would know her way around all the transport pipes but well...wait, why am I even telling you this when your just going to eat me!"
			]

		"Show him the poster you found.":
			queued_state = "talk"
			response_lines = [
				"...",
				"So you're really not going to eat me you pinkie promise? B-because a lot of folks say that but then BAM you got your head taken",
				"like with those holier than thou types. That's probably what happened to the team lead oh shes been gone for so long I don't know why I -I -I'm rambling just um.",
				"Help me find my coworkers, please Miss?",
				{"choices": [
					{"text": "Yes"},
					{"text": "No"}
				]}
			]
		"Yes":
			queued_state = "idle" 
			response_lines = [
				"Really!? I um mean yeah of course you'd say yes I didn't doubt you for a second.",
				"The others, their up in the portal system somewhere, Their probably stuck in there somewhere, there's 5 of them.",
				"I can fix the portals once their all out I just...I couldn't....I mean I wasn't able to make myself go in, maybe that's cowardly but sometimes you only have energy to save one person and its okay if its yourself. Just...please find them, for me."
			]
		"No":
			queued_state = "cower"
			response_lines = [
				"...",
				"Maybe you really are a monster than."
			]


	DialogueBox.start_dialog(response_lines, self)

func _apply_queued_state():
	if queued_state != "":
		set_state(queued_state)
		queued_state = ""

func get_worker_count(inv: Inv) -> int:
	var count := 0
	for slot in inv.slots:
		if slot.item != null and slot.item.name == "worker":
			count += slot.amount
	return count

func clear_lvl_items(inv: Inv) -> void:
	var to_clear := []

	for slot in inv.slots:
		if slot.item != null and slot.item.name == "worker" or slot.item != null and slot.item.name == "paper":
			to_clear.append(slot)

	for slot in to_clear:
		slot.item = null
		slot.amount = 0

	inv.update.emit()
