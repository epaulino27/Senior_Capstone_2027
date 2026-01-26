extends Resource

#classname makes it easier to reference by the machine
class_name SaveGame

#used similarly to an interface for what should be saved
@export var player_position:= Vector2(1300, 0)
@export var current_level: String = ""
@export var collected_items: Array[String] = []
@export var talked: bool = false
@export var rolly_polly_spawn: int = 0
@export var rolly_polly_state: String = "idle"
@export var player_inventory: Inv = Inv.new()
@export var rolly_polly_position: Vector2 = Vector2.ZERO
