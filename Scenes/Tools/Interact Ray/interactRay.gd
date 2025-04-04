extends RayCast3D  # 继承自 RayCast3D 节点，保持原有设计

@onready var prompt: Label = $Prompt  # 引用场景中的 Label 节点，用于显示交互提示

func _physics_process(delta: float) -> void:
	# 每帧物理更新时执行
	prompt.text = ""  # 默认将提示文本设为空
	
	if is_colliding():  # 检查射线是否碰撞到物体
		var collider = get_collider()  # 获取碰撞到的物体
		
		# 检查是否碰撞到了可切换角色
		if collider is SwitchableCharacter:
			# 获取角色管理器
			var character_manager = get_node_or_null("/root/CharacterManager")
			
			# 确保不是当前正在控制的角色
			if character_manager and collider != character_manager.current_character:
				# 显示切换角色的提示
				prompt.text = "按E切换到: " + collider.prompt_message
				
				# 如果按下交互键，切换角色
				if Input.is_action_just_pressed("interact"):
					collider.interact()  # 触发角色切换
					return  # 避免处理其他交互
		
		# 保留原有的其他交互物体处理逻辑
		var interactable_node = collider  # 将碰撞物体赋值给可交互节点变量

		# 检查碰撞物体是否属于 "Operable Object" 组
		if interactable_node.is_in_group("Operable Object"):
			# 显示可操作对象的提示
			prompt.text = interactable_node.prompt_message if "prompt_message" in interactable_node else "按E互动"
			
			# 如果按下交互键
			if Input.is_action_just_pressed("interact"):
				# 如果物体有自定义的交互方法，调用它
				if interactable_node.has_method("interact"):
					interactable_node.interact()
				# 否则尝试触发交互信号
				elif interactable_node.has_user_signal("interact"):
					interactable_node.emit_signal("interact")
					
		# 检查是否可以通过信号交互
		elif interactable_node.has_user_signal("interact"):
			# 显示交互提示
			prompt.text = interactable_node.prompt_message if "prompt_message" in interactable_node else "按E互动"
			
			# 如果按下交互键
			if Input.is_action_just_pressed("interact"):
				# 触发交互信号
				interactable_node.emit_signal("interact")
				
	#if is_colliding():
		#var collider = get_collider()
		#print("射线碰撞到:", collider.name, ", 组:", collider.get_groups())
