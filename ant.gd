extends CharacterBody2D

var max_speed: float = 10.0
var steer_strength: float = 2.0
var wander_strength: float = 1.0
var bite_pickup_radius: float = 5.0
var pheromone_interval: float = 0.9

var desired_direction:Vector2
var viewport_size: Vector2
var targeted_bite = null
var has_bite:bool = false
var colony_center: Vector2
var colony_radius: int = 60

var t_since_last_place: float = 0.0

@onready var _animated_sprite = $Animation

@onready var _sensor_left  = $Sensor_left
@onready var _sensor_front = $Sensor_front
@onready var _sensor_right = $Sensor_right

@onready var _food_sensor = $Sensor_food
@onready var _background  = $"../../Background"
@onready var _button = $"../../Button"

func new_direction() -> Vector2:
	var new_dir: = Vector2()
	new_dir.x = randf_range(-1, 1)
	new_dir.y = randf_range(-1, 1)
	return new_dir.normalized()	

#func _ready():
	#print(desired_direction)
	#_animated_sprite.play("walk")
	
func handle_food():
	if has_bite == false:
		if targeted_bite == null:
			var allFood:Array
			
			for item in _food_sensor.get_overlapping_areas():
				if item.is_in_group("Food"):
					allFood.append(item)
			
			if allFood.size() > 0:
				randomize()
				targeted_bite = allFood[randi() % allFood.size()]
				targeted_bite.remove_from_group("Food")
				desired_direction = Vector2(targeted_bite.position - position).normalized()
				
		else:
			desired_direction = Vector2(targeted_bite.position - position).normalized()
			
			if targeted_bite.position.distance_to(position) < bite_pickup_radius:
				has_bite = true
				targeted_bite.position = position
				velocity = -velocity
				desired_direction = -desired_direction
	else:
		targeted_bite.position = position
		if targeted_bite.position.distance_to(colony_center) < colony_radius:
			_button.food.erase(targeted_bite)
			targeted_bite.queue_free()
			targeted_bite = null
			has_bite = false
			velocity = -velocity
			desired_direction = -desired_direction
			_button.inc_score()

func _physics_process(delta):
	handle_food()
	desired_direction = (desired_direction + (new_direction() * wander_strength)).normalized()
	
	var desired_velocity: Vector2 = desired_direction * max_speed
	var desired_steering_force: Vector2 = Vector2(desired_velocity - velocity) * steer_strength
	var acceleration: Vector2 = desired_steering_force.limit_length(steer_strength)
	
	velocity = Vector2(velocity + acceleration * delta).limit_length(max_speed)
	
	if 0 > position.x or position.x > viewport_size.x:
		velocity = -velocity
		desired_direction = -desired_direction
	if 0 > position.y or position.y > viewport_size.y:
		velocity = -velocity
		desired_direction = -desired_direction
	
	position += velocity * delta
	rotation = desired_direction.angle()
	
	t_since_last_place += delta
	if t_since_last_place > pheromone_interval:
		t_since_last_place = 0.0
		if has_bite:
			_background.trail_found.append([position, 1.0])
		else:
			_background.trail_searching.append([position, 1.0])
