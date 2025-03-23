extends RayCast3D

var interact_cast_result
var current_cast_result
var interact_distance = 10#可能有bug，要删/改的


func _physics_process(delta: float) -> void:
	interact_cast()



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()
		

func interact_cast() -> void:
	var camera = get_parent()
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size/2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * interact_distance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	query.set_exclude([self.get_collider_rid()])#原代码为self.get_rid()
	var result = space_state.intersect_ray(query)
	var current_cast_result = result.get("collider")
	interact_cast_result = current_cast_result
	#current_cast_result = get_collider()
	
	if current_cast_result != interact_cast_result:
		if interact_cast_result and interact_cast_result.has_user_signal("unfocused"):
			interact_cast_result.emit("unfocused")
		interact_cast_result = current_cast_result
		if interact_cast_result and interact_cast_result.has_user_signal("focused"):
			interact_cast_result.emit("focused")

func interact() -> void:
	if interact_cast_result:
		print(interact_cast_result)
	
	#if interact_cast_result and interact_cast_result.has_user_signal("interacted"):
		#interact_cast_result.emit("interacted")
