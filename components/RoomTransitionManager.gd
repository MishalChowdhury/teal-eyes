extends Node
class_name RoomTransitionManager

## Manages room transitions based on player position
## Simpler approach than Area2D triggers

var player: CharacterBody2D = null
var room1_camera: Node = null
var room2_camera: Node = null

# Transition thresholds (world X positions)
# Transition thresholds (world X positions)
# Hysteresis applied: Gap between 1950 and 2050 prevents death loop
const ROOM1_TO_ROOM2_THRESHOLD: float = 2050.0
const ROOM2_TO_ROOM1_THRESHOLD: float = 1950.0

var current_room: int = 1  # 1 or 2
var transition_triggered: bool = false

func _ready() -> void:
	# Find player
	await get_tree().process_frame  # Wait for scene to load
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		push_error("[RoomTransitionManager] Player not found!")
		return
	
	# Find cameras
	var rooms_container = get_parent().get_node_or_null("Rooms")
	if rooms_container:
		var room1 = rooms_container.get_node_or_null("Room1")
		var room2 = rooms_container.get_node_or_null("Room2")
		
		if room1:
			room1_camera = room1.get_node_or_null("PhantomCamera2D")
		if room2:
			room2_camera = room2.get_node_or_null("PhantomCamera2D")
	
	print("[RoomTransitionManager] Initialized - Player: %s, Room1 cam: %s, Room2 cam: %s" % 
		[player != null, room1_camera != null, room2_camera != null])

func _process(_delta: float) -> void:
	if not player:
		return
	
	var player_x = player.global_position.x
	
	# Check for Room1 → Room2 transition (walking right)
	if current_room == 1 and player_x >= ROOM1_TO_ROOM2_THRESHOLD:
		_transition_to_room2()
	
	# Check for Room2 → Room1 transition (walking left)
	elif current_room == 2 and player_x <= ROOM2_TO_ROOM1_THRESHOLD:
		_transition_to_room1()


func _transition_to_room2() -> void:
	print("[RoomTransitionManager] >>> TRANSITIONING TO ROOM 2 <<<")
	current_room = 2
	
	if room2_camera and room2_camera.has_method("set_priority"):
		room2_camera.set_priority(10)
	if room1_camera and room1_camera.has_method("set_priority"):
		room1_camera.set_priority(0)
	
	Events.room_transition_triggered.emit("room_01", "room_02")

func _transition_to_room1() -> void:
	print("[RoomTransitionManager] >>> TRANSITIONING TO ROOM 1 <<<")
	current_room = 1
	
	if room1_camera and room1_camera.has_method("set_priority"):
		room1_camera.set_priority(10)
	if room2_camera and room2_camera.has_method("set_priority"):
		room2_camera.set_priority(0)
	
	Events.room_transition_triggered.emit("room_02", "room_01")
