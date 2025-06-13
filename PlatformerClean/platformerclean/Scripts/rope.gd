extends Node2D
class_name Rope

# Visual properties
@export var color := Color(0.8, 0.5, 0.2)
@export var width := 2.0
@export var collision_width := 4.0  # Wider than visual for better collision

# Physics properties
@export_flags_2d_physics var collision_mask := 1

# Rope properties
var start_point := Vector2.ZERO
var end_point := Vector2.ZERO
var length := 0.0
var direction := Vector2.RIGHT
var is_attached := false
var attachment_point := Vector2.ZERO

# Node references
var line: Line2D
var segments: Array[Area2D] = []
@export var segment_length := 2.0  # Length of each collision segment
@export var max_segments := 1000  #Testing this with a short rope rn

# Debug visualization properties
@export var show_debug_segments := false #this shows a red box for the collision segments of the rope... because sometimes those are different from the line itself
@export var debug_segment_color := Color.RED

signal on_collision(position, collider)

func _draw():
	if show_debug_segments:
		for segment in segments:
			if segment.visible:
				# Get the rectangle shape from the segment
				var collision_shape = segment.get_child(0) as CollisionShape2D
				var rect_shape = collision_shape.shape as RectangleShape2D
				
				# Draw the rectangle at the segment's position
				var rect = Rect2(
					segment.position - rect_shape.extents,
					rect_shape.extents * 2
				)
				
				# Rotate the rectangle to match segment rotation
				var transform = Transform2D(segment.rotation, segment.position)
				var points = [
					transform * Vector2(-rect_shape.extents.x, -rect_shape.extents.y),
					transform * Vector2(rect_shape.extents.x, -rect_shape.extents.y),
					transform * Vector2(rect_shape.extents.x, rect_shape.extents.y),
					transform * Vector2(-rect_shape.extents.x, rect_shape.extents.y)
				]
				
				draw_colored_polygon(points, debug_segment_color)
				
func _ready():
	# Set up the Line2D for visuals
	line = Line2D.new()
	line.width = width
	line.default_color = color
	line.visible = false  # Start with rope invisible
	add_child(line) #a lot of this could probably be done in the header
	
	# Initialize collision segments
	_create_segments()

func _create_segments():
	# Clear any existing segments
	for segment in segments:
		if segment:
			segment.queue_free()
	segments.clear()
	
	# Create new segments (will be positioned during extend)
	for i in range(max_segments):
		var area = Area2D.new()
		area.collision_mask = collision_mask
		area.monitorable = false
		area.collision_mask = 2
		
		var shape = CollisionShape2D.new()
		var rectangle = RectangleShape2D.new()
		rectangle.extents = Vector2(segment_length/2, collision_width/2)
		shape.shape = rectangle
		
		area.add_child(shape)
		add_child(area)
		
		# Connect the body_entered signal
		area.body_entered.connect(_on_segment_body_entered.bind(area))
		
		segments.append(area)
		area.visible = false  # Hide until used

func set_points(p_start: Vector2, p_end: Vector2):
	start_point = p_start
	end_point = p_end
	
	# Update length and direction
	var delta = end_point - start_point
	length = delta.length()
	if length > 0:
		direction = delta / length
	
	# Update visuals
	line.clear_points()
	line.add_point(start_point)
	line.add_point(end_point)
	
	# Update collision segments
	_update_segments()

func extend(extension_length: float) -> bool:
	if !line.visible:
		line.visible = true
	
	# Extend the rope in the current direction
	var new_end = end_point + direction * extension_length
	set_points(start_point, new_end)

	# Return true if any segment detected a collision
	var collision = _check_collisions()
	return collision
	

func _update_segments(): 
	var segment_count = ceil(length / segment_length)
	segment_count = min(segment_count, max_segments)
	
	for i in range(max_segments):
		if i < segment_count:
			# Position and rotate segment
			var segment_pos = start_point + direction * (i * segment_length + segment_length/2)
			segments[i].position = segment_pos
			segments[i].rotation = direction.angle()
			segments[i].visible = true
			
		else:
			# Hide unused segments
			segments[i].visible = false
	
	# Trigger redraw for debug visualization
	queue_redraw()

func _check_collisions() -> bool:
	# Check if any segments are already colliding	
	for segment in segments:
		if not segment.visible:
			continue
			
		var colliders = segment.get_overlapping_bodies()
		
		if colliders.size() > 0:
			_on_segment_body_entered(colliders[0], segment)
			return true
	
	return false


func _on_segment_body_entered(body, segment):
	if is_attached:
		return
		
	# Calculate approximate collision point
	attachment_point = segment.global_position
	is_attached = true
	
	# Adjust rope length to collision point
	var collision_vector = attachment_point - start_point
	length = collision_vector.length()
	
	# Update endpoint
	end_point = start_point + direction * length
	
	# Update visuals
	line.clear_points()
	line.add_point(start_point)
	line.add_point(end_point)
	
	# Emit signal
	on_collision.emit(attachment_point, body)

func detach():
	is_attached = false
	
#func clear(): #This is some simpler version of the clear code that might be useful.... I'm assuming we need to remove the segments from the array entirely but alas

	## Reset the rope
	#set_points(Vector2.ZERO, Vector2.ZERO)
	#length = 0
	#is_attached = false
	#
	## Hide the rope visual
	#line.visible = false
	#
	## Hide all segments
	#for segment in segments:
		#if segment:
			#segment.visible = false
			
func clear():
	# Reset the rope properties
	start_point = Vector2.ZERO
	end_point = Vector2.ZERO
	length = 0.0
	is_attached = false
	
	# Hide the rope visual
	line.visible = false
	line.clear_points()
	
	# Reset all segments to clean initial state
	for segment in segments:
		if segment:
			segment.visible = false
			segment.position = Vector2.ZERO
			segment.rotation = 0.0
			segment.monitoring = true  # Keep monitoring enabled
	
	# Trigger redraw to clear debug visualization
	queue_redraw()
