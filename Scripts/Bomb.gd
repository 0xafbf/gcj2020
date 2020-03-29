extends KinematicBody
class_name Bomb

enum {COLOR_BLUE, COLOR_RED}

export var speed = 5
export var placement_distance = 1

export var trail_template : PackedScene

var distance_since_last = 100
var last_placed_powder
var destroyed = false

var running = false
var start_transform: Transform
func play():
	running = true
	start_transform = global_transform
func reset():
	Global.register_object(self)
	running = false
	destroyed = false
	global_transform = start_transform
	last_placed_powder = null
	
func _ready():
	start_transform = global_transform
	reset()

func _physics_process(delta):
	if not running:
		return
	if destroyed:
		return
		
	var velocity = transform.basis.z * speed
	velocity = move_and_slide(velocity)
	var distance = velocity.length() * delta
	distance_since_last += 	distance 
	if distance_since_last > placement_distance:
		distance_since_last = 0
		
		if last_placed_powder:
			last_placed_powder.bomb = null
		
		last_placed_powder = trail_template.instance()
		last_placed_powder.translation = translation
		get_node("/root").add_child(last_placed_powder)
		last_placed_powder.bomb = self

func explode():
	if destroyed:
		return
	$CollisionShape/Particles.emitting = true
	destroyed = true
	
	var space_state = get_world().direct_space_state
	var query_params = PhysicsShapeQueryParameters.new()
	query_params.set_shape($ExplosionRadius.shape)
	query_params.transform = $ExplosionRadius.global_transform
	
	query_params.collision_mask = 1
	var results = space_state.intersect_shape(query_params)
	for result in results:
		var target = result["collider"]
		print(target)
		if target is Destructible:
			print("arst")
			target.destroy()
