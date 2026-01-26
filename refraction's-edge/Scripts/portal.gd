extends Node2D

#assigned in editor each time
var target: Node2D
#used to get info for the above node
@export var target_portal: NodePath
#logic for going to another unexpected portal
#alt to add difficulty/unpredictability
@export var alt_target: NodePath
@export var alt_probability: float = 0.15
#start to help players get back to start easier in case tehy get lost
@export var start_target:NodePath
@export var start_probability: float = 0.10
#end to present the player with a choice to abandon quest if wanted, this action has concequences
@export var end_target:NodePath
@export var end_probability: float = 0.05

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if a node is assigned load at the beginning to not load every time a portal is entered
	if target_portal != NodePath(""): 
		target = get_node(target_portal)


func _on_area_2d_body_entered(body):
	if body.is_in_group("player")and body.can_teleport:
		#defaults target as final target
		var final_target = target
		#checks if alternate target should be used instead
		#if alternate target isnt empty and threshhold valid, make final target
		if end_target != NodePath("") and randf() < end_probability:
			final_target = get_node(end_target)
		elif start_target != NodePath("") and randf() < start_probability:
			final_target = get_node(start_target)
		elif alt_target != NodePath("") and randf() < alt_probability:
			final_target = get_node(alt_target)
		#add cooldown
		body.disable_teleport_for_a_moment()
		#will always have the same parent since scene transitions will have differnt logic
		#but use global position just so we can hold portals in a container for organization
		body.global_position = final_target.position + Vector2(0, - 80)
