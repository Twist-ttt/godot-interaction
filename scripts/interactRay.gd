extends RayCast3D


@onready var prompt: Label = $Prompt

func _physics_process(delta: float) -> void:
	prompt.text= "null"
	if is_colliding():
		var collider = get_collider()
		if collider is InteractAble and Input.is_action_pressed("interact"):
			prompt.text =collider.prompt_message + " " + get_collider().name
