extends Node2D
class_name NPCBase

#variables
var dialog_lines: Array = []
var npc_id := ""
var state := ""

var player_ref = null
var player_in_range := false

var is_busy := false
var npc_dialogue_active := false

var seen_states := {}

var closing_dialogue := false

#get save data and apply as necessary
func _ready():
	if SaveManager.current_save.npc_seen_states.has(npc_id):
		seen_states = SaveManager.current_save.npc_seen_states[npc_id]
	else:
		seen_states = {}

	if has_node("InteractionArea"):
		var area = $InteractionArea
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

#used to determine if initial info should be skipped
func has_seen(state_name: String) -> bool:
	return seen_states.get(state_name, false)

func mark_seen(state_name: String):
	seen_states[state_name] = true

#detect player interaction, establishes basic dialougue flow but can be overridden by child scripts
func interact():
	if closing_dialogue:
		return

	if has_method("_apply_queued_state"):
		_apply_queued_state()

	if is_busy:
		return

	if dialog_lines.is_empty():
		return

	if player_ref:
		player_ref.freeze()

	is_busy = true
	npc_dialogue_active = true

	DialogueBox.start_dialog(dialog_lines, self)

func _on_dialog_choice_made(text):
	_child_choice_made(text)

#grace period after dialougue is finished to prevent accidental progression
func _on_dialog_finished():
	closing_dialogue = true
	await get_tree().create_timer(0.1).timeout
	closing_dialogue = false

	npc_dialogue_active = false
	is_busy = false
	dialog_lines = []

	if player_ref:
		player_ref.unfreeze()

func _on_player_entered(body):
	pass

#detect player proximity
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		body.interact_target = self
		player_ref = body
		
		if has_method("_on_player_entered"):
			_on_player_entered(body)

#detect player proximity and reset things
func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

		if body.interact_target == self:
			body.interact_target = null

		if player_ref == body:
			player_ref = null

#helper function
func play_animation(anim: String):
	if $NPCSprite.animation != anim:
		$NPCSprite.play(anim)

#helper function
func set_state(new_state: String):
	exit_state(state)
	state = new_state
	enter_state(new_state)
	save_state()

#to be overridden by child scripts
func enter_state(_s): pass
func exit_state(_s): pass
func update_state(_delta): pass

#run every frame, updates visuals and controls like location
func _physics_process(delta):
	update_state(delta)

#helper function, save sytsem integration
func save_state():
	SaveManager.current_save.npc_states[npc_id] = state
	SaveManager.current_save.npc_positions[npc_id] = position
	SaveManager.current_save.npc_seen_states[npc_id] = seen_states

#to be overriden by child scripts
func _child_choice_made(_text):
	pass

func _apply_queued_state():
	pass
