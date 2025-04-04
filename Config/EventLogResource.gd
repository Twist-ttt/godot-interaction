extends Resource
class_name EventLogResource

# 已触发的事件ID集合
@export var triggered_events: Array = []

# 检查事件是否已被触发
func has_triggered(event_id: String) -> bool:
	return event_id in triggered_events
	
# 记录新触发的事件
func log_event(event_id: String) -> void:
	if not has_triggered(event_id):
		triggered_events.append(event_id)
		print("记录新事件: " + event_id)
