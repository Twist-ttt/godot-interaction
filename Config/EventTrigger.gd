# EventTrigger.gd
extends Node3D
class_name EventTrigger

# 事件基本信息
@export var event_id: String = "event_001"
@export var display_name: String = "未命名事件"
@export var prompt_text: String = "按E交互"

# 是否在触发后隐藏
@export var hide_after_trigger: bool = false

# 记录事件是否已被触发
var is_triggered: bool = false
var collision_area: Area3D

func _ready() -> void:
	# 首先创建Area3D子节点处理碰撞
	collision_area = Area3D.new()
	collision_area.name = "CollisionArea"
	add_child(collision_area)
	
	# 添加碰撞形状
	var collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	collision_area.add_child(collision_shape)
	
	# 设置碰撞形状(默认为球形，可在编辑器中修改)
	var shape = SphereShape3D.new()
	shape.radius = 1.0
	collision_shape.shape = shape
	
	# 设置碰撞层
	collision_area.collision_layer = 8
	collision_area.collision_mask = 0
	
	# 直接在触发器本身添加到组
	if not is_in_group("Operable Object"):
		add_to_group("Operable Object")
	
	# 确保Area3D也加入组
	if not collision_area.is_in_group("Operable Object"):
		collision_area.add_to_group("Operable Object")
	
	# 调试输出确认
	print("触发器节点:", name, "在组:", get_groups())
	print("碰撞区域:", collision_area.name, "在组:", collision_area.get_groups())
	
	# 创建交互接口
	if not has_node("InteractAble"):
		var interactable = load("res://Scenes/Tools/Interact Ray/InteractAble.gd").new()
		interactable.name = "InteractAble"
		add_child(interactable)
		
	# 设置提示文本
	if has_node("InteractAble"):
		get_node("InteractAble").prompt_message = prompt_text
	
	# 检查是否已触发过
	await get_tree().process_frame
	if get_node_or_null("/root/EventManager") and get_node("/root/EventManager").has_triggered(event_id):
		is_triggered = true
		if hide_after_trigger:
			visible = false

# 交互方法 - 被InteractRay调用
func interact() -> void:
	print("触发器交互被调用!")
	
	if is_triggered and not hide_after_trigger:
		print("再次查看事件: " + display_name)
		return
		
	# 记录事件
	var event_manager = get_node_or_null("/root/EventManager")
	if event_manager:
		event_manager.trigger_event(event_id)
		is_triggered = true
		print("事件已记录: " + event_id)
		
		# 如果设置了触发后隐藏，则隐藏
		if hide_after_trigger:
			visible = false
	else:
		print("错误: 未找到事件管理器")

# 添加此方法验证交互功能是否正常调用
func _process(delta):
	# 仅用于测试 - 添加后删除
	if Input.is_action_just_pressed("ui_accept"):
		print("测试事件触发器:", event_id)
		interact()  # 直接调用交互方法测试
