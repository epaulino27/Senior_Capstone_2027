extends Node2D

var target: Node2D

@export var target_portal: NodePath
@export var alt_target: NodePath
@export var alt_probability: float = 0.05
@export var start_target: NodePath
@export var start_probability: float = 0.05
@export var end_target: NodePath
@export var end_probability: float = 0.05

# "up", "down", "left", "right"
@export var exit_direction := "up"
@export var cooldown_time := 0.3
var on_cooldown := false


func _ready() -> void:
	if target_portal != NodePath(""):
		target = get_node(target_portal)
	start_random($p1)
	start_random($p2)
	start_random($p3)

#staggers animation start times to keep portals from being repetative
func start_random(sprite: AnimatedSprite2D):
	sprite.stop()
	var delay = randf_range(0.0, 10.0)
	await get_tree().create_timer(delay).timeout
	sprite.play()

#handles portal transportation
func _on_area_2d_body_entered(body):
	if not body.is_in_group("player"):
		return

	# Prevent ping-pong
	if body.teleport_locked:
		return

	if "lock_teleport_for_a_moment" in body:
		body.lock_teleport_for_a_moment()

	if on_cooldown:
		return
	_start_cooldown()

	# Pick final target
	var final_target = target

	if end_target != NodePath("") and randf() < end_probability:
		final_target = get_node(end_target)
	elif start_target != NodePath("") and randf() < start_probability:
		final_target = get_node(start_target)
	elif alt_target != NodePath("") and randf() < alt_probability:
		final_target = get_node(alt_target)

	if final_target:
		var offset := Vector2.ZERO
		var exit_dir = final_target.exit_direction  # <--- THIS IS THE FIX

		match exit_dir:
			"up":
				offset = Vector2(0, -140)
			"down":
				offset = Vector2(0, 140)
			"left":
				offset = Vector2(-140, 0)
			"right":
				offset = Vector2(140, 0)

		body.global_position = final_target.global_position + offset

#brief pause to ensure no unwanted ping ponging between different portals
func _start_cooldown():
	on_cooldown = true
	await get_tree().create_timer(cooldown_time).timeout
	on_cooldown = false
