extends RayCast3D  # 继承自 RayCast3D 节点，用于检测射线碰撞

@onready var prompt: Label = $Prompt  # 引用场景中的 Label 节点，用于显示交互提示

func _physics_process(delta: float) -> void:
	# 每帧物理更新时执行
	prompt.text = "null"  # 默认将提示文本设为 "null"

	if is_colliding():  # 检查射线是否碰撞到物体
		var collider = get_collider()  # 获取碰撞到的物体
		var interactable_node = collider  # 将碰撞物体赋值给可交互节点变量

		# 检查碰撞物体是否属于 "Operable Object" 组
		if interactable_node.is_in_group("Operable Object"):
			# 如果属于可操作对象组，为其添加 "interact" 用户信号
			interactable_node.add_user_signal("interact")

		# 检查碰撞物体是否存在 "interact" 用户信号
		if interactable_node and interactable_node.has_user_signal("interact"):
			# 如果玩家按下交互键（"interact" 动作）
			if Input.is_action_pressed("interact"):
				# 在提示文本中显示碰撞物体的名称
				prompt.text = collider.name
