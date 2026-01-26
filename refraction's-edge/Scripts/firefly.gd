extends CharacterBody2D
#main character used for the first half of the game

#import external variables
@export var inv: Inv

#set internal character variables when the root scene starts
@onready var animated_sprite = $AnimatedSprite2D
const SPEED = 700.0
const JUMP_VELOCITY = -700.0
var sleep_counter := 0.0
var can_teleport = true

#on start make sure to load info from the save file
func _ready() -> void:
	_load_inventory(SaveManager.current_save.player_inventory)
	if SaveManager.current_save.player_position != null:
		global_position = SaveManager.current_save.player_position
		
#called every frame/second handles movement
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("W") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# gets input direction (-1,0,1)
	var direction := Input.get_axis("A", "D")
	
	#flip sprite when moving different directions
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	#play animations 
	if is_on_floor():
		if direction == 0:
			animated_sprite.flip_h = false
			sleep_counter += 1
			if sleep_counter > 3000:
				animated_sprite.play("resting")
			elif sleep_counter > 2833:
				animated_sprite.play("rest")
			elif sleep_counter > 2000:
				animated_sprite.play("sitting")
			elif sleep_counter > 1750:
				animated_sprite.play("sit")
			else:
				animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
			sleep_counter = 0
	else:
		animated_sprite.play("fly")
		sleep_counter = 0
	
	#applies movements
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	#makes movements/transitions appear smoother
	move_and_slide()

#helper methods

#easy way I can check if this body is the player later on
#note will be removed later since player is in player group now
func player():
	pass
	
#check if the player has an item in their inventory, case sensative
func player_has(item_name: String) -> bool:
	#for each slot
	for slot in inv.slots:
		#check if the item is the one we're looking for
		if slot.item != null and slot.item.name == item_name:
			return true
	return false
	
#puts the item in the player inventory using seperate systems from inventory
func collect(item):
	inv.insert(item)
	SaveManager.current_save.player_inventory = inv.duplicate(true)
	
#allows for cooldown timer so player doen't get stuck in teleporting loop
func disable_teleport_for_a_moment():
	can_teleport = false
	await get_tree().create_timer(0.2).timeout
	can_teleport = true

#handles loading the inventory slot by slot into the player inventory
func _load_inventory(saved_inv: Inv):
	if saved_inv == null:
		return

	# clear existing inventory so you don't double up accidently
	for slot in inv.slots:
		slot.item = null
		slot.amount = 0

	#copy saved data into preloaded player inventory
	for i in range(min(inv.slots.size(), saved_inv.slots.size())):
		var saved_slot = saved_inv.slots[i]
		inv.slots[i].item = saved_slot.item
		inv.slots[i].amount = saved_slot.amount

	# resfresh/update the ui so it shows the correct version 
	inv.update.emit()
