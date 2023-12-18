extends CharacterBody2D

var max_speed: float = 10.0
var steer_strength: float = 2.0
var wander_strength: float = 1.0

var desired_direction = Vector2.ZERO

#func _input(event):
	#if event is InputEventMouseButton:
		#target = event.position
	#if event.is_action_pressed("click"):
		#target = get_global_mouse_position()

func _ready():
	desired_direction = position.direction_to(Vector2(500, 700)).normalized()

func new_direction() -> Vector2:
	var new_dir: = Vector2()
	new_dir.x = randf_range(-1, 1)
	new_dir.y = randf_range(-1, 1)
	return new_dir.normalized()

func _physics_process(delta):
	desired_direction = (desired_direction + (new_direction() * wander_strength)).normalized()
	
	var desired_velocity: Vector2 = desired_direction * max_speed
	var desired_steering_force: Vector2 = Vector2(desired_velocity - velocity) * steer_strength
	var acceleration: Vector2 = desired_steering_force.limit_length(steer_strength)
	
	velocity = Vector2(velocity + acceleration * delta).limit_length(max_speed)
	position += velocity * delta
	rotation_degrees = rad_to_deg(desired_direction.angle())
	
	#velocity = position.direction_to(target) * speed
	#look_at(desired_direction)
	#move_and_slide()
