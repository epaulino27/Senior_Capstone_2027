extends CharacterBody2D

#define npc variables
@onready var animated_sprite = $AnimatedSprite2D
@onready var dialogue_label = $message/text_body
@onready var dialogue = $message
@onready var state := "idle"
@onready var movement_speed = 900
var player = null
var sleep_counter := 0.0
var spawn_points = []
var spawn_index := 0
var current_anim := ""
var fearful_dialogue = ["Don't hurt me!", "Begone devil of light!", "Leave me alone!", "You better not get closer o-or you'll be sorry!", "My mom will be here any minute so you better leave!"]

#on start set visibility and spawn points for chase sequence
func _ready():
	dialogue.visible = false
	spawn_points = [
		Vector2(-1500, position.y -40), #the start location, superficial, overwritten elsewhere, but needed for rest to work
		Vector2(-1565, position.y - 690),
		Vector2(1400, position.y - 1820),
		Vector2(-1500,position.y - 1820)
	]

#play the animation used in tandem with state
func play_anim(name:String):
	if current_anim != name:
		current_anim = name
		animated_sprite.play(name)
		
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
				state = "despawn"
		"roll_right":
			position.x += movement_speed * delta
			play_anim("rolling")
			if position.x > 1500:
				state = "despawn"
		"despawn":
			play_anim("idle")
			visible = false
			state = "respawn"
		"respawn":
			spawn_index = (spawn_index + 1) % spawn_points.size()
			position = spawn_points[spawn_index]
			visible = true
			state = "idle"
		"fearful":
			play_anim("shivering")
		"talk":
			#needs different front facing sprite but having put it in yet
			play_anim("idle")
			dialogue.visible = true
			dialogue_label.text = "...oh you have my poster? I thought you were a monster at first Mrs. [insert small bit of lore here] [insert quest story here]"

#when the character gets close to the rolly-polly
func _on_area_2d_body_entered(body: Node2D) -> void:
	#first and second roll logic
	if body.has_method("player"):
		if state == "idle":
			player = body
			state = "ball_up"
			play_anim("ball_up")
		#logic for shivering  and then talking here
		if state == "fearful":
			if player.player_has("paper") == true:
				state = "talk"
			dialogue.visible = true
			var n = randi_range(0, 4) 
			dialogue_label.text = fearful_dialogue[n]
			
#handles the non-looping of the ball_up animation and passes it on to the next state
func _on_animated_sprite_2d_animation_finished() -> void:
	if state == "ball_up":
		if spawn_index == 0 || spawn_index == 2:
			state = "roll_left"
		elif spawn_index == 1:
			state = "roll_right"
		else:
			state = "fearful"
			if player.player_has("paper") == true:
				state = "talk"
