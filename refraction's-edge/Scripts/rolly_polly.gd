extends CharacterBody2D
class_name RollyPollyNPC
#define npc variables
@onready var animated_sprite = $AnimatedSprite2D
@onready var dialogue_label = $message/text_body
@onready var start = $"../Portals/start"
@onready var end = $"../Portals/end"
@onready var dialogue = $message
@onready var state := "idle"
@onready var movement_speed = 900
@export var inv: Inv
var talked = false
var player = null
var sleep_counter := 0.0
var spawn_points = []
var spawn_index
var current_anim := ""
var fearful_dialogue = ["Don't hurt me!", "Begone devil of light!", "Leave me alone!", "You better not get closer o-or you'll be sorry!", "My mom will be here any minute so you better leave!"]

#on start set visibility and spawn points for chase sequence
func _ready():
	print("PLAYER INV:", inv)
	dialogue.visible = false
	spawn_points = [
		Vector2(500, position.y + 5), 
		Vector2(-1565, position.y - 690),
		Vector2(1400, position.y - 1820),
		Vector2(-1500,position.y - 1820)
	]
	set_state(SaveManager.current_save.rolly_polly_state)
	if SaveManager.current_save.rolly_polly_state in ["roll_left", "roll_right"]:
		set_state("idle")
	spawn_index = SaveManager.current_save.rolly_polly_spawn
	if SaveManager.current_save.rolly_polly_position != Vector2.ZERO:
		global_position = SaveManager.current_save.rolly_polly_position
	else:
		global_position = spawn_points[spawn_index]

#play the animation used in tandem with state
func play_anim(anim_name:String):
	if current_anim != anim_name:
		current_anim = anim_name
		animated_sprite.play(anim_name)
		
#called every frame, handles states
func _physics_process(delta):
	#godots version of a switch
	match state:
		"idle":
			play_anim("idle")
		"ball_up":
			play_anim("ball_up")
		"roll_left":
			position.x -= movement_speed * delta
			play_anim("rolling")
			if position.x < -1500:
				set_state("despawn")
		"roll_right":
			position.x += movement_speed * delta
			play_anim("rolling")
			if position.x > 1500:
				set_state("despawn")
		"despawn":
			play_anim("idle")
			visible = false
			await get_tree().process_frame
			set_state("respawn")
		"respawn":
			spawn_index = (spawn_index + 1) % spawn_points.size()
			SaveManager.current_save.rolly_polly_spawn = spawn_index
			position = spawn_points[spawn_index]
			visible = true
			set_state("idle")
		"fearful":
			play_anim("shivering")
		"talk":
			#needs different front facing sprite but having put it in yet :(
			play_anim("idle")
			dialogue.visible = true
			talked = true
			player.inv.remove("paper")
			dialogue_label.text = "...my ad? Wait your not a monster, but your so....bright. Are you here to help? My siblings, their stuck in the broken portal, I can't fix it until their all out. There are 9."
		"finished":
			play_anim("idle")
			remove_all_babies(player.inv)
			start.end_target = end.get_path()
			start.target = end
			dialogue.visible = true
			if talked == true:
				dialogue_label.text = "You found my siblings!!! Thank you so much! I was able to fix the portals while you were gone. You should be able to get up higher like you wanted now!"
			else:
				dialogue_label.text = "Who are you!? Oh wait...you found my siblings! Thank you so much! They were lost in the portals but I was too scared to find them myself. But now that their out of that maze I can activate teh fix I made for the portal. you can beam your way all the way up if you'd like."
	if state in ["idle", "fearful", "talk", "finished"]:
			SaveManager.current_save.rolly_polly_position = global_position

#when the character gets close to the rolly-polly
func _on_area_2d_body_entered(body: Node2D) -> void:
	#first and second roll logicaaa
	if body.has_method("player"):
		player = body
		if get_baby_count(body.inv) >= 9:
			set_state("finished")
		if state == "idle":
			player = body
			set_state("ball_up")
			play_anim("ball_up")
		#logic for shivering  and then talking here
		if state == "fearful":
			if player.player_has("paper") == true:
				set_state("talk")
			dialogue.visible = true
			var n = randi_range(0, 4) 
			dialogue_label.text = fearful_dialogue[n]
			
#handles the non-looping of the ball_up animation and passes it on to the next state
func _on_animated_sprite_2d_animation_finished() -> void:
	if state == "ball_up":
		if spawn_index == 0 or spawn_index == 2:
			set_state("roll_left")
		elif spawn_index == 1:
			set_state("roll_right")
		else:
			set_state("fearful")
			if player.player_has("paper") == true:
				set_state("talk")

#helper function so rolly polly wont loop through states
func set_state(new_state):
	if state != new_state:
		state = new_state
		SaveManager.current_save.rolly_polly_state = new_state

#helper functions for finish logic
func get_baby_count(inv: Inv) -> int:
	var count := 0
	for slot in inv.slots:
		if slot.item != null and slot.item.category == "baby":
			count += slot.amount
	return count
	
func remove_all_babies(inv: Inv) -> void:
	var to_clear := []
	
	#get which slots to clear
	for slot in inv.slots:
		if slot.item != null and slot.item.category == "baby":
			to_clear.append(slot)
	# clear slots
	for slot in to_clear:
		slot.item = null
		slot.amount = 0

	inv.update.emit()
