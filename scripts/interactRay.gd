extends RayCast3D


@onready var prompt: Label = $Prompt

func _physics_process(delta: float) -> void:
	prompt.text= "null"
	if is_colliding():
		var collider = get_collider()
		var interactable_node = collider.get_node("InteractAble")
		if interactable_node and interactable_node is InteractAble:
			if Input.is_action_pressed("interact"):
				prompt.text =interactable_node.prompt_message + " " + collider.name
