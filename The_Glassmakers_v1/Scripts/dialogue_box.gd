extends CanvasLayer
class_name DialogueBoxUI

#communicate to other nodes when a choice is made or dialougue is done and needs to be moved foward
signal choice_made(text)
signal dialogue_finished

#variables
var lines: Array = []
var index: int = 0
var choosing: bool = false
var choice_index: int = 0

var typing: bool = false
var full_line: String = ""
var typed_line: String = ""
var type_index: int = 0
var type_speed: float = 0.02

# prevents space from triggering multiple dialogue actions in the same frame.
var input_locked: bool = false
# started the dialogue and receives callbacks
var current_owner: Object = null

# start off invisible and on standby for character interaction
func _ready():
	visible = false
	set_process_unhandled_input(false)

# resets things and preps for new dialogue
func start_dialog(new_lines: Array, owner: Object = null):
	print("START_DIALOG:", new_lines)
	current_owner = owner
	
	typing = false
	full_line = ""
	typed_line = ""
	type_index = 0
	
	choosing = false
	choice_index = 0
	input_locked = false
	lines = new_lines.duplicate(true)
	index = 0

	$Content.text = ""
	visible = true
	set_process_unhandled_input(true)

	_start_line()

func _start_line():
	print("START_LINE index=", index, " size=", lines.size())
	# end dialogue when all lines have been processed/displayed
	if index >= lines.size():
		var owner = current_owner

		_close_dialogue()

		if owner and owner.has_method("_on_dialog_finished"):
			owner._on_dialog_finished()

		return

	# process/display the current dialougue line
	var line = lines[index]
	print("CURRENT LINE:", line)

	if typeof(line) == TYPE_DICTIONARY and line.has("choices"):
		choosing = true
		typing = false
		show_choices(line["choices"])
		return

	choosing = false
	full_line = str(line)
	typed_line = ""
	type_index = 0
	typing = true
	$Content.text = ""
	_start_typing()

#handles the typing effect
func _start_typing():
	if not typing:
		return

	if type_index < full_line.length():
		typed_line += full_line[type_index]
		$Content.text = typed_line
		type_index += 1
		await get_tree().create_timer(type_speed).timeout
		_start_typing()
	else:
		typing = false
		input_locked = true
		await get_tree().process_frame
		input_locked = false

#displays choices passed into it
func show_choices(options):
	var text := ""
	for i in range(options.size()):
		var prefix = "> " if i == choice_index else "  "
		text += prefix + options[i]["text"] + "\n"
	$Content.text = text

#handles navigating between choices and choice selection
func handle_choice_input():
	var line = lines[index]
	var options = line["choices"]

	if Input.is_action_just_pressed("ui_down"):
		choice_index = (choice_index + 1) % options.size()
		show_choices(options)

	if Input.is_action_just_pressed("ui_up"):
		choice_index = (choice_index - 1 + options.size()) % options.size()
		show_choices(options)

	if Input.is_action_just_pressed("interact"):
		var chosen = options[choice_index]

		if current_owner and current_owner.has_method("_on_dialog_choice_made"):
			current_owner._on_dialog_choice_made(chosen["text"])

		choosing = false
		return

#handles input redirection for skipping text, hitting interact when its not available, and choice selection
func _unhandled_input(event):
	if not visible or input_locked:
		return

	if choosing:
		handle_choice_input()
		return

	if typing:
		if Input.is_action_just_pressed("interact"):
			typing = false
			$Content.text = full_line
			input_locked = true
			await get_tree().process_frame
			input_locked = false
		return

	if Input.is_action_just_pressed("interact"):
		index += 1
		_start_line()

# resets and hides the dialogue box, clearing all state before another conversation can start
func _close_dialogue():
	print("CLOSING DIALOGUE")

	visible = false
	set_process_unhandled_input(false)

	lines = []
	index = 0
	choosing = false
	choice_index = 0
	typing = false
	full_line = ""
	typed_line = ""
	type_index = 0
	input_locked = false

	if current_owner and current_owner.has_method("on_dialogue_closed"):
		current_owner.on_dialogue_closed()

	current_owner = null
	$Content.text = ""
