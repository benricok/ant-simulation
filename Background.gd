extends Node2D

var trail_searching = Array()
var trail_found = Array()

var t_since_last_place: float = 0.0
var pheromone_interval: float = 0.9

func _ready():
	trail_found.append([Vector2(0,0), 0.0])
	trail_searching.append([Vector2(0,0), 0.0])

func _draw():
	for trail in trail_searching:
		draw_circle(trail[0], 4, Color(trail[1], 0.0, 0.0))
		
	for trail in trail_found:
		draw_circle(trail[0], 4, Color(0,0,trail[1]))
		
func _process(delta):
	t_since_last_place += delta
	if t_since_last_place > pheromone_interval:
		t_since_last_place = 0.0
		queue_redraw()
		
	for trail in trail_searching:
		trail[1] -= 0.0008
		if trail[1] <= 0:
			trail_searching.erase(trail)
	for trail in trail_found:
		trail[1] -= 0.0005
		if trail[1] <= 0:
			trail_found.erase(trail)
