extends SpringArm3D

@export var shoulder_offset: float = 0.5
var target_offset: float = 0.5

func _ready():
	spring_length = 4.0
	margin = 0.5
	collision_mask = 1
	target_offset = shoulder_offset

func _process(delta: float) -> void:
	# Smooth shoulder offset
	position.x = lerp(position.x, target_offset, delta * 5.0)
