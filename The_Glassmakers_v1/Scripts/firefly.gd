extends CharacterBody2D

#Character Sprite
@onready var animated_sprite = $AnimatedSprite2D

# Inventory
@export var inv: Inv

# Movement
const SPEED = 700.0
const JUMP_VELOCITY = -700.0

# Dialogue / interaction
var frozen := false
var npc_in_range = null
var just_closed_dialogue := false
var interact_target = null

# Ground detection
var feet_grounded := false
var teleport_locked := false

# Idle animation state
var idle_time := 0.0
var idle_stage := 0 # 0=idle, 1=sit, 2=sitting, 3=rest, 4=resting

@onready var light := $light_source
@onready var cover1 := $cover1
@onready var cover2 := $cover2

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

	cover1.hide()
	cover2.hide()
	
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Uses both floor detection and foot collider in case of moving platforms or one way platforms
	var grounded := is_on_floor() or feet_grounded

	if not grounded:
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("p1_up") and grounded:
		velocity.y = JUMP_VELOCITY
		feet_grounded = false

	var direction := Input.get_axis("p1_left", "p1_right")

	if direction < 0:
		animated_sprite.flip_h = true
		light.position = Vector2(20, 39)
	elif direction > 0:
		animated_sprite.flip_h = false
		light.position = Vector2(-20, 39)

	if grounded:
		if direction == 0:
			if idle_stage == 0 and animated_sprite.animation != "idle":
				animated_sprite.play("idle")
				light.position = Vector2(-3, 39)
				animated_sprite.flip_h = false
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("fly")
		if animated_sprite.flip_h: # facing right
			cover1.show()
			cover2.show()
		else: # facing left
			light.position = Vector2(-20, 39)
			cover1.hide()
			cover2.hide()

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	handle_idle_resting(delta, direction, grounded)
	move_and_slide()

#prevent repetitive unstopable teleporting in lvl 2
func lock_teleport_for_a_moment():
	teleport_locked = true
	await get_tree().create_timer(0.3).timeout
	teleport_locked = false

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

#helper function, checks if the player has a certain item in tehri inventory
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
		print("[PLAYER] No saved inventory")
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

#handles the sit > sitting > rest > resting animations
#used to track inactivity
func handle_idle_resting(delta: float, direction: float, grounded: bool) -> void:
	if direction != 0 or not grounded:
		idle_time = 0.0
		idle_stage = 0
		return

	idle_time += delta

	# idle > sit
	if idle_stage == 0 and idle_time >= 15.0:
		idle_stage = 1
		animated_sprite.play("sit")

	# sit > sitting
	elif idle_stage == 1 and animated_sprite.animation == "sit" and animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("sit") - 1:
		idle_stage = 2
		animated_sprite.play("sitting")
		light.position = Vector2(20, 70)

	# sitting > rest
	elif idle_stage == 2 and idle_time >= 30.0:
		idle_stage = 3
		animated_sprite.play("rest")

	# rest > resting
	elif idle_stage == 3 and animated_sprite.animation == "rest" and animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("rest") - 1:
		idle_stage = 4
		animated_sprite.play("resting")
