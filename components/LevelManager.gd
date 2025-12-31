extends Node
class_name LevelManager
## Manages room streaming and transitions for the level system
## Implements the 3-room buffer strategy (current + neighbors)

## Current active room
var current_room: Node2D = null

## Dictionary of loaded rooms: room_id (String) -> Room instance (Node2D)
var loaded_rooms: Dictionary = {}

## Dictionary of loading requests: scene_path (String) -> ResourceLoader status
var loading_requests: Dictionary = {}

func _ready() -> void:
	Events.room_entered.connect(_on_room_entered)

func _process(_delta: float) -> void:
	# Check status of async loading requests
	_update_loading_requests()

## Handle room entered event
func _on_room_entered(room_id: String) -> void:
	# Room entry handled
	
	# Get the room instance
	if not loaded_rooms.has(room_id):
		push_error("Room %s not loaded!" % room_id)
		return
	
	current_room = loaded_rooms[room_id]
	
	# Load neighbor rooms asynchronously
	var neighbors: Array = _get_connected_rooms(current_room)
	for neighbor_path in neighbors:
		_request_room_load(neighbor_path)
	
	# Unload distant rooms (distance > 1)
	_unload_distant_rooms(neighbors)

## Get list of rooms connected to the current room
func _get_connected_rooms(room: Node2D) -> Array:
	# This should be implemented based on your Room script
	# For now, return empty array
	# TODO: Implement room connection logic
	if room.has_method("get_connected_room_paths"):
		return room.get_connected_room_paths()
	return []

## Request asynchronous loading of a room scene
func _request_room_load(scene_path: String) -> void:
	# Skip if already loaded
	if loaded_rooms.has(scene_path):
		return
	
	# Skip if already loading
	if loading_requests.has(scene_path):
		return
	
	# Loading room asynchronously
	var error = ResourceLoader.load_threaded_request(scene_path)
	if error == OK:
		loading_requests[scene_path] = scene_path
	else:
		push_error("Failed to request load for: %s" % scene_path)

## Update the status of active loading requests
func _update_loading_requests() -> void:
	for scene_path in loading_requests.keys():
		var status = ResourceLoader.load_threaded_get_status(scene_path)
		
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				# Loading complete, instantiate the room
				var room_scene: PackedScene = ResourceLoader.load_threaded_get(scene_path)
				var room_instance: Node2D = room_scene.instantiate()
				loaded_rooms[scene_path] = room_instance
				loading_requests.erase(scene_path)
				# Room loaded successfully
			
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("Failed to load room: %s" % scene_path)
				loading_requests.erase(scene_path)
			
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				# Still loading, check next frame
				pass

## Unload rooms that are too far away (distance > 1)
func _unload_distant_rooms(neighbor_paths: Array) -> void:
	var rooms_to_unload: Array = []
	
	for room_id in loaded_rooms.keys():
		# Keep current room and neighbors
		if room_id == current_room or neighbor_paths.has(room_id):
			continue
		
		rooms_to_unload.append(room_id)
	
	# Unload distant rooms
	for room_id in rooms_to_unload:
		# Unloading distant room
		var room = loaded_rooms[room_id]
		if room and is_instance_valid(room):
			room.queue_free()
		loaded_rooms.erase(room_id)
