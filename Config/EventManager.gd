# EventManager.gd
extends Node
# 删除或修改这一行
# class_name EventManager  
# 改为:
class_name EventManagerSystem


var instance = null

# 事件日志存储
var event_log: EventLogResource

# 保存路径
const SAVE_PATH = "user://event_log.tres"

# 信号定义 - 预留给UI使用
signal event_triggered(event_id)

func _ready() -> void:
	instance = self
	_load_or_create_log()
	
# 加载或创建新的事件日志
func _load_or_create_log() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		event_log = ResourceLoader.load(SAVE_PATH)
		print("加载了事件日志，已触发事件数量: " + str(event_log.triggered_events.size()))
	else:
		event_log = EventLogResource.new()
		print("创建了新的事件日志")
		
# 记录事件触发
func trigger_event(event_id: String) -> void:
	if event_log.has_triggered(event_id):
		print("事件已被触发过: " + event_id)
		return
		
	event_log.log_event(event_id)
	print("触发新事件: " + event_id)
	
	# 发射信号通知UI (预留接口)
	emit_signal("event_triggered", event_id)
	
	# 保存日志
	_save_log()
	
# 保存事件日志
func _save_log() -> void:
	var error = ResourceSaver.save(event_log, SAVE_PATH)
	if error != OK:
		print("保存事件日志失败: " + str(error))
	else:
		print("事件日志已保存")
		
# 检查事件是否已触发
func has_triggered(event_id: String) -> bool:
	return event_log.has_triggered(event_id)
	
# 获取所有已触发事件ID
func get_all_triggered_events() -> Array:
	return event_log.triggered_events.duplicate()
