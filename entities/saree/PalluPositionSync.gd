extends Node2D
class_name PalluPositionSync

## Syncs pallu position to shoulder bone
## Simple version - just position syncing, no flip logic

@export var shoulder_bone_path: NodePath = NodePath("Skeleton2D/Hip/PalluRoot")
@export var pallu_chain_path: NodePath = NodePath("PalluChainPhysics2")

var shoulder_bone: Bone2D = null
var pallu_chain: Node2D = null


func _ready() -> void:
	shoulder_bone = get_node_or_null(shoulder_bone_path)
	pallu_chain = get_node_or_null(pallu_chain_path)
	
	if not shoulder_bone:
		push_error("[PalluPositionSync] Shoulder bone not found")
		return
	if not pallu_chain:
		push_error("[PalluPositionSync] Pallu chain not found")
		return
	
	print("[PalluPositionSync] Initialized - syncing pallu to shoulder")


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(shoulder_bone) or not is_instance_valid(pallu_chain):
		return
	
	# Just sync position - pallu will inherit skeleton's transform naturally
	pallu_chain.global_position = shoulder_bone.global_position
