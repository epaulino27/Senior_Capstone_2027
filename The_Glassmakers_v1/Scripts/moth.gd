extends CharacterBody2D

#variables
@export var inv: Inv

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 500.0
const JUMP_VELOCITY = -500.0

var frozen := false
var npc_in_range = null

var just_closed_dialogue := false
var interact_target = null

var feet_grounded := false
var teleport_locked := false


#on start load info from save and ensure its in the correct group for future processing
func _ready():
	_load_inventory(SaveManager.current_save.player_inventory)

	if SaveManager.current_save.player_position != null:
		global_position = SaveManager.current_save.player_position

	add_to_group("player")

	DialogueBox.dialogue_finished.connect(_on_dialogue_finished)
	DialogueBox.choice_made.connect(_on_choice_made)

#handles interaction triggering
func _process(delta):
	if frozen:
		return

	if DialogueBox.visible or just_closed_dialogue:
		return

	if Input.is_action_just_pressed("interact"):
		if interact_target != null:
			interact_target.interact()
		else:
			print("[PLAYER] No interact_target")


#handles character movement and sprite calling
#called every frame
func _physics_process(delta):
	for p in get_tree().get_nodes_in_group("platforms"):
		p.update_platform(self)

	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var grounded := is_on_floor() or feet_grounded

	if not grounded:
		if velocity.y > 0: # Falling
			velocity += get_gravity() * delta * .1
		else:
			velocity += get_gravity() * delta

	if Input.is_action_just_pressed("p2_up") and grounded:
		velocity.y = JUMP_VELOCITY
		feet_grounded = false

	var direction := Input.get_axis("p2_left", "p2_right")

	if direction < 0:
		animated_sprite.flip_h = true
	elif direction > 0:
		animated_sprite.flip_h = false

	if grounded:
		if direction == 0:
			animated_sprite.flip_h = false
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.flip_h = false
		animated_sprite.play("fly")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

#freeze functionality used during dialougue
func freeze():
	frozen = true

func unfreeze():
	frozen = false

#grace period after dialougue is finished to prevent accidental progression
func _on_dialogue_finished():
	just_closed_dialogue = true
	await get_tree().create_timer(0.1).timeout
	just_closed_dialogue = false

#DO NOT DELETE, connected to dialougue box for future processes
func _on_choice_made(text):
	pass

#helper function, checks if the player has a certain item in their inventory
func player_has(item_name: String) -> bool:
	for slot in inv.slots:
		if slot.item != null and slot.item.name == item_name:
			return true
	return false

#collect item into player inventory then update the save
func collect(item):
	inv.insert(item)
	SaveManager.current_save.player_inventory = inv.duplicate(true)

#get the inventory information from the save and match accordingly
func _load_inventory(saved_inv: Inv):
	if saved_inv == null:
		return

	for slot in inv.slots:
		slot.item = null
		slot.amount = 0

	for i in range(min(inv.slots.size(), saved_inv.slots.size())):
		var saved_slot = saved_inv.slots[i]
		inv.slots[i].item = saved_slot.item
		inv.slots[i].amount = saved_slot.amount

	inv.update.emit()

#helper functions, track if the player is in the air or not
func _on_leg_collider_body_entered(body: Node2D) -> void:
	feet_grounded = true

func _on_leg_collider_body_exited(body: Node2D) -> void:
	feet_grounded = false
