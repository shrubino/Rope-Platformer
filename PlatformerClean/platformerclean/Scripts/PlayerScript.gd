extends CharacterBody2D

class_name PlatformerController2D

@export var README: String = "IMPORTANT: MAKE SURE TO ASSIGN 'left' 'right' 'jump' 'dash' 'up' 'down' 'roll' 'latch' 'twirl' 'run' in the project settings input map. Usage tips. 1. Hover over each toggle and variable to read what it does and to make sure nothing bugs" #this is pulled from the github but it's probably good to keep in mind

@export_category("Necesary Child Nodes")
@onready var PlayerSprite = $AnimatedSprite2D
@onready var PlayerCollider = $CollisionShape2D
@onready var leftRaycast: RayCast2D = $LeftHeadspace
##Raycast used for corner cutting calculations. Place above of the players head point up. ALL ARE NEEDED FOR IT TO WORK.
@onready var middleRaycast: RayCast2D = $CenterHeadspace
##Raycast used for corner cutting calculations. Place above and to the right of the players head point up. ALL ARE NEEDED FOR IT TO WORK.
@onready var rightRaycast: RayCast2D = $RightHeadspace
@onready var rope = Rope
@onready var crosshair = $Crosshairs

#INFO HORIZONTAL MOVEMENT 
@export_category("L/R Movement")
##The max speed your player will move
@export_range(50, 500) var maxSpeed: float = 150.0
##How fast your player will reach max speed from rest (in seconds)
@export_range(0, 4) var timeToReachMaxSpeed: float = 0.2
##How fast your player will reach zero speed from max speed (in seconds)
@export_range(0, 4) var timeToReachZeroSpeed: float = 0.2
##If true, player will instantly move and switch directions. Overrides the "timeToReach" variables, setting them to 0.
@export var directionalSnap: bool = false
##If enabled, the default movement speed will by 1/2 of the maxSpeed and the player must hold a "run" button to accelerate to max speed. Assign "run" (case sensitive) in the project input settings.
@export var runningModifier: bool = false

#INFO JUMPING 
@export_category("Jumping and Gravity")
##The peak height of your player's jump
@export_range(0, 20) var jumpHeight: float = 2.0
##How many jumps your character can do before needing to touch the ground again. Giving more than 1 jump disables jump buffering and coyote time.
@export_range(0, 4) var jumps: int = 1
##The strength at which your character will be pulled to the ground.
@export_range(0, 100) var gravityScale: float = 20.0
##The fastest your player can fall
@export_range(0, 1000) var terminalVelocity: float = 500.0
##Your player will move this amount faster when falling providing a less floaty jump curve.
@export_range(0.5, 3) var descendingGravityFactor: float = 1.3
##Enabling this toggle makes it so that when the player releases the jump key while still ascending, their vertical velocity will cut by the height cut, providing variable jump height.
@export var shortHopAkaVariableJumpHeight: bool = true
##How much the jump height is cut by.
@export_range(1, 10) var jumpVariable: float = 2
##How much extra time (in seconds) your player will be given to jump after falling off an edge. This is set to 0.2 seconds by default.
@export var coyoteTime: float = 0.0
##The window of time (in seconds) that your player can press the jump button before hitting the ground and still have their input registered as a jump. This is set to 0.2 seconds by default.
@export_range(0, 0.5) var jumpBuffering: float = 0.2

#INFO EXTRAS
@export_category("Wall Jumping")
##Allows your player to jump off of walls. Without a Wall Kick Angle, the player will be able to scale the wall.
@export var wallJump: bool = true
##How long the player's movement input will be ignored after wall jumping.
@export_range(0, 0.5) var inputPauseAfterWallJump: float = 0.1
##The angle at which your player will jump away from the wall. 0 is straight away from the wall, 90 is straight up. Does not account for gravity
@export_range(0, 90) var wallKickAngle: float = 63.0
##The player's gravity will be divided by this number when touch a wall and descending. Set to 1 by default meaning no change will be made to the gravity and there is effectively no wall sliding. THIS IS OVERRIDDED BY WALL LATCH.
@export_range(1, 20) var wallSliding: float = 2.5
##If enabled, the player's gravity will be set to 0 when touching a wall and descending. THIS WILL OVERRIDE WALLSLIDING.
@export var wallLatching: bool = false
##wall latching must be enabled for this to work. #If enabled, the player must hold down the "latch" key to wall latch. Assign "latch" in the project input settings. The player's input will be ignored when latching.
@export var wallLatchingModifer: bool = false
@export_category("Dashing")
##The type of dashes the player can do.
@export_enum("None", "Horizontal", "Vertical", "Four Way", "Eight Way") var dashType: int
##How many dashes your player can do before needing to hit the ground.
@export_range(0, 10) var dashes: int = 1
##If enabled, pressing the opposite direction of a dash, during a dash, will zero the player's velocity.
@export var dashCancel: bool = true
##How far the player will dash. One of the dashing toggles must be on for this to be used.
@export_range(1.5, 4) var dashLength: float = 2.5
@export_category("Corner Cutting/Jump Correct")
##If the player's head is blocked by a jump but only by a little, the player will be nudged in the right direction and their jump will execute as intended. NEEDS RAYCASTS TO BE ATTACHED TO THE PLAYER NODE. AND ASSIGNED TO MOUNTING RAYCAST. DISTANCE OF MOUNTING DETERMINED BY PLACEMENT OF RAYCAST.
@export var cornerCutting: bool = true
##How many pixels the player will be pushed (per frame) if corner cutting is needed to correct a jump.
@export_range(1, 5) var correctionAmount: float = 2.0
##Raycast used for corner cutting calculations. Place above and to the left of the players head point up. ALL ARE NEEDED FOR IT TO WORK.
@export_category("Down Input")
##Holding down will crouch the player. Crouching script may need to be changed depending on how your player's size proportions are. It is built for 32x player's sprites.
@export var crouch: bool = false
##Holding down and pressing the input for "roll" will execute a roll if the player is grounded. Assign a "roll" input in project settings input.
@export var canRoll: bool = false
@export_range(1.25, 2) var rollLength: float = 2
##If enabled, the player will stop all horizontal movement midair, wait (groundPoundPause) seconds, and then slam down into the ground when down is pressed. 
@export var groundPound: bool = true
##The amount of time the player will hover in the air before completing a ground pound (in seconds)
@export_range(0.05, 0.75) var groundPoundPause: float = 0.25
##If enabled, pressing up will end the ground pound early
@export var upToCancel: bool = false

@export_category("Animations (Check Box if has animation)")
##Animations must be named "run" all lowercase as the check box says
@export var run: bool
##Animations must be named "jump" all lowercase as the check box says
@export var jump: bool
##Animations must be named "idle" all lowercase as the check box says
@export var idle: bool
##Animations must be named "walk" all lowercase as the check box says
@export var walk: bool
##Animations must be named "slide" all lowercase as the check box says
@export var slide: bool
##Animations must be named "latch" all lowercase as the check box says
@export var latch: bool
##Animations must be named "falling" all lowercase as the check box says
@export var falling: bool
##Animations must be named "crouch_idle" all lowercase as the check box says
@export var crouch_idle: bool
##Animations must be named "crouch_walk" all lowercase as the check box says
@export var crouch_walk: bool
##Animations must be named "roll" all lowercase as the check box says
@export var roll: bool

# Constants to replace magic numbers
const GROUND_POUND_VELOCITY_FACTOR = 2.0
const GROUND_POUND_TERMINAL_FACTOR = 10.0
const ANIMATION_SPEED_DIVISOR = 150.0
const SQUASH_STRETCH_FACTOR = 0.8
const DASH_TIME_FACTOR = 0.0625
const ROLL_TIME_FACTOR = 0.25
const ROLL_INPUT_PAUSE_FACTOR = 0.0625
const COLLIDER_CROUCH_FACTOR = 8.0
const VERTICAL_IMPULSE_FACTOR = 10.0
const LATCH_CHECK_DELAY = 0.2

# State enum to manage player state
enum PlayerState {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	WALL_SLIDING,
	WALL_LATCHING,
	DASHING,
	ROLLING,
	CROUCHING,
	GROUND_POUNDING
}

# Player state
var current_state = PlayerState.IDLE

# Animation related variables
var default_scale: Vector2
var is_stretching: bool = false
var is_squashing: bool = false
var stretch_amount: float = 1.1
var squash_amount: float = 0.90
var animation_speed: float = 15.0
var was_in_air: bool = false
var anim # Cached animation player
var col # Cached collider
var animScaleLock : Vector2

# Movement variables
var maxSpeedLock: float
var acceleration: float
var deceleration: float
var instantAccel: bool = false
var instantStop: bool = false

# Jumping variables
var jumpMagnitude: float = 500.0
var jumpCount: int
var jumpWasPressed: bool = false
var time_since_floor: float = 0.0

# Wall jumping variables
var latched: bool = false
var wasLatched: bool = false

# Direction tracking
var wasMovingR: bool = true
var wasPressingR: bool = false

# Special move variables
var dashing: bool = false
var rolling: bool = false
var crouching: bool = false
var groundPounding: bool = false

# Gravity variables
var appliedGravity: float
var appliedTerminalVelocity: float
var gravityActive: bool = true

# Dash variables
var dashMagnitude: float
var dashCount: int
var twoWayDashHorizontal: bool = false
var twoWayDashVertical: bool = false
var eightWayDash: bool = false

# Timer variables
var dash_time_remaining: float = 0.0
var roll_time_remaining: float = 0.0
var input_pause_time: float = 0.0

# Collider cache
var colliderScaleLockY
var colliderPosLockY

#Aiming and crosshair variables
var is_aiming = false
var crosshair_radius = 100.0
var crosshair_angle = 0.0
var crosshair_active = false
var crosshair_rotation_speed = 3.0

# Rope variables
var can_fire = true
var is_firing_rope = false
var is_swinging = false
var current_rope_length = 0.0
var has_been_on_rope = false
var current_rope_angle = 0.0
var spring_joint: DampedSpringJoint2D = null
var rope_body: StaticBody2D = null
var max_rope_length = 1000.0
var rope_firing_speed = 1000.0
var min_rope_length = 30.0
var swing_gravity = 9.8      # Adjustable swing gravity
var swing_damping = 0.995    # Slight damping for more natural feel
var swing_acceleration = 300.0  # How quickly swing builds up
var climb_speed = 100.0      # Speed at which player can climb the rope

# Input tracking structure
var input = {
	"left": false,
	"right": false,
	"up": false,
	"down": false,
	"left_tap": false,
	"right_tap": false,
	"left_release": false,
	"right_release": false,
	"jump": false,
	"jump_release": false,
	"run": false,
	"latch": false,
	"dash": false,
	"roll": false,
	"down_tap": false,
	"shift" : false,
	"Z" : false
}

# Movement input control 
var movementInputMonitoring: Vector2 = Vector2(true, true)

func _ready():
	# Initialize references and cache values
	anim = PlayerSprite
	col = PlayerCollider
	rope = preload("res://Scenes/Rope.tscn").instantiate()
	add_child(rope)
	rope.on_collision.connect(_on_rope_collision)
	
	if anim:
		default_scale = anim.scale
	
	# Set initial state
	_updateData()

func _updateData():
	# Calculate movement parameters
	timeToReachMaxSpeed = max(timeToReachMaxSpeed, 0.01)  # Prevent division by zero
	timeToReachZeroSpeed = max(timeToReachZeroSpeed, 0.01)  # Prevent division by zero
	
	acceleration = maxSpeed / timeToReachMaxSpeed
	deceleration = -maxSpeed / timeToReachZeroSpeed
	
	# Calculate jump parameters
	jumpMagnitude = (10.0 * jumpHeight) * gravityScale
	jumpCount = jumps
	
	# Calculate dash parameters
	dashMagnitude = maxSpeed * dashLength
	dashCount = dashes
	
	# Save initial values
	maxSpeedLock = maxSpeed
	
	if anim:
		animScaleLock = abs(anim.scale)
	
	if col:
		colliderScaleLockY = col.scale.y
		colliderPosLockY = col.position.y
	
	# Set movement behavior flags
	instantAccel = timeToReachMaxSpeed <= 0
	instantStop = timeToReachZeroSpeed <= 0
	
	if directionalSnap:
		instantAccel = true
		instantStop = true
	
	# Disable coyote time and jump buffering for multi-jumps
	if jumps > 1:
		jumpBuffering = 0
		coyoteTime = 0
	
	# Ensure positive values
	coyoteTime = abs(coyoteTime)
	jumpBuffering = abs(jumpBuffering)
	
	# Set dash type flags
	twoWayDashHorizontal = false
	twoWayDashVertical = false
	eightWayDash = false
	
	match dashType:
		0: # None
			pass
		1: # Horizontal
			twoWayDashHorizontal = true
		2: # Vertical
			twoWayDashVertical = true
		3: # Four Way
			twoWayDashHorizontal = true
			twoWayDashVertical = true
		4: # Eight Way
			eightWayDash = true

func _process(delta):
	# Handle animations
	_handle_animations(delta)
	
	# Update timers
	_update_timers(delta)

func _physics_process(delta):
		# Update input state
	_update_input()
	_handle_rope_firing(delta)
	# Handle movement
	_handle_horizontal_movement(delta)
	# Handle jumping, wall jumping, and gravity
	_handle_jumping_and_gravity(delta)
	# Handle special moves
	_handle_dashing(delta)
	_handle_corner_cutting()
	_handle_ground_pound(delta)
	move_and_slide()
	
	# Update player state... do I need this?
	#_update_state()

func _update_input():
	# Store previous state
	input.left_tap = false
	input.right_tap = false
	input.left_release = false
	input.right_release = false
	input.up = false
	input.down = false
	input.jump = false
	input.jump_release = false
	input.dash = false
	input.roll = false
	input.down_tap = false
	input.Z = false
	
	# Get current input state
	input.left = Input.is_action_pressed("ui_left")
	input.right = Input.is_action_pressed("ui_right")
	input.up = Input.is_action_pressed("ui_up")
	input.down = Input.is_action_pressed("ui_down")
	input.left_tap = Input.is_action_just_pressed("ui_left")
	input.right_tap = Input.is_action_just_pressed("ui_right")
	input.left_release = Input.is_action_just_released("ui_left")
	input.right_release = Input.is_action_just_released("ui_right")
	input.jump = Input.is_action_just_pressed("jump")
	input.jump_release = Input.is_action_just_released("jump")
	input.run = Input.is_action_pressed("run")
	input.latch = Input.is_action_pressed("latch")
	input.dash = Input.is_action_just_pressed("dash")
	input.roll = Input.is_action_just_pressed("roll")
	input.down_tap = Input.is_action_just_pressed("ui_down")
	input.shift = Input.is_action_pressed("Shift")
	input.z = Input.is_action_pressed("fire_rope")
	
	# Update direction tracking
	if input.right_tap:
		wasPressingR = true
	if input.left_tap:
		wasPressingR = false

func _update_timers(delta):
	# Update dash timer
	if dash_time_remaining > 0:
		dash_time_remaining -= delta
		if dash_time_remaining <= 0:
			dashing = false
			if !is_on_floor():
				velocity.y = -gravityScale * VERTICAL_IMPULSE_FACTOR
	
	# Update roll timer
	if roll_time_remaining > 0:
		roll_time_remaining -= delta
		if roll_time_remaining <= 0:
			rolling = false
	
	# Update input pause timer
	if input_pause_time > 0:
		input_pause_time -= delta
		if input_pause_time <= 0:
			movementInputMonitoring = Vector2(true, true)
	
	# Update time since floor
	if is_on_floor():
		time_since_floor = 0.0
	else:
		time_since_floor = time_since_floor + delta

func _handle_animations(delta):
	# Check if player is latched to wall
	if is_on_wall() and !is_on_floor() and latch and wallLatching and ((wallLatchingModifer and input.latch) or !wallLatchingModifer):
		latched = true
	else:
		if latched:
			wasLatched = true
			await get_tree().create_timer(LATCH_CHECK_DELAY).timeout
			wasLatched = false
		latched = false
	
	# Set sprite direction
	if input.right and !latched and anim:
		anim.scale.x = animScaleLock.x
	if input.left and !latched and anim:
		anim.scale.x = animScaleLock.x * -1
	
	# Apply squash and stretch effects
	_apply_stretch_squash(delta)
	
	# Handle state-based animations
	if anim:
		if dashing:
			anim.speed_scale = 1
			anim.play("dash")
			return
			
		if rolling:
			anim.speed_scale = 1
			anim.play("roll")
			return
			
		if latched:
			anim.speed_scale = 1
			anim.play("latch")
			return
			
		if is_on_wall() and velocity.y > 0 and wallSliding != 1:
			anim.speed_scale = 1
			anim.play("slide")
			return
			
		if velocity.y < 0 and !dashing:
			anim.speed_scale = 1
			anim.play("jump")
			return
			
		if velocity.y > 40 and !dashing and !crouching:
			anim.speed_scale = 1
			anim.play("falling")
			return
			
		if crouching and !rolling:
			if abs(velocity.x) > 10:
				anim.speed_scale = 1
				anim.play("crouch_walk")
			else:
				anim.speed_scale = 1
				anim.play("crouch_idle")
			return
		
		# Ground movement animations
		if is_on_floor():
			if abs(velocity.x) > 0.1:
				anim.speed_scale = abs(velocity.x / ANIMATION_SPEED_DIVISOR)
				if walk and abs(velocity.x) < maxSpeedLock:
					anim.play("walk")
				elif run:
					anim.play("run")
			elif idle:
				anim.speed_scale = 1
				anim.play("idle")

func _handle_horizontal_movement(delta):
	if !is_aiming:
	# Update movement direction tracking
		if velocity.x > 0:
			wasMovingR = true
		elif velocity.x < 0:
			wasMovingR = false
		
		# Adjust speed based on modifiers
		if runningModifier and !input.run:
			maxSpeed = maxSpeedLock / 2
		elif is_on_floor():
			maxSpeed = maxSpeedLock
		
		# Process horizontal movement
		if input.right and input.left and movementInputMonitoring.x and movementInputMonitoring.y:
			# Handle opposing inputs
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = 0
		elif input.right and movementInputMonitoring.x:
			# Move right
			if velocity.x > maxSpeed or instantAccel:
				velocity.x = maxSpeed
			else:
				velocity.x += acceleration * delta
			
			if velocity.x < 0:
				if !instantStop:
					_decelerate(delta, false)
				else:
					velocity.x = 0
		elif input.left and movementInputMonitoring.y:
			# Move left
			if velocity.x < -maxSpeed or instantAccel:
				velocity.x = -maxSpeed
			else:
				velocity.x -= acceleration * delta
			
			if velocity.x > 0:
				if !instantStop:
					_decelerate(delta, false)
				else:
					velocity.x = 0
		elif !(input.left or input.right):
			# No horizontal input, slow down
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = 0
	else:
		_decelerate(delta, false) #decelerate when aiming. not realllllly sure what the vertical (false) tag does in here though...

func _handle_jumping_and_gravity(delta):
	# Apply gravity based on velocity direction
	if velocity.y > 0:
		appliedGravity = gravityScale * descendingGravityFactor
	else:
		appliedGravity = gravityScale
	
	# Handle wall interactions
	if is_on_wall() and !groundPounding:
		appliedTerminalVelocity = terminalVelocity / wallSliding
		
		if wallLatching and ((wallLatchingModifer and input.latch) or !wallLatchingModifer):
			# Wall latching
			appliedGravity = 0
			
			if velocity.y < 0:
				velocity.y += 50
			if velocity.y > 0:
				velocity.y = 0
			
			if wallLatchingModifer and input.latch and movementInputMonitoring == Vector2(true, true):
				velocity.x = 0
		elif wallSliding != 1 and velocity.y > 0:
			# Wall sliding
			appliedGravity = appliedGravity / wallSliding
	elif !is_on_wall() and !groundPounding:
		appliedTerminalVelocity = terminalVelocity
	
	# Apply gravity
	if gravityActive:
		if velocity.y < appliedTerminalVelocity:
			velocity.y += appliedGravity
		elif velocity.y > appliedTerminalVelocity:
			velocity.y = appliedTerminalVelocity
	
	# Handle variable jump height
	if shortHopAkaVariableJumpHeight and input.jump_release and velocity.y < 0:
		velocity.y = velocity.y / jumpVariable
	
	# Reset jumps when on floor
	if is_on_floor():
		jumpCount = jumps
		
		# Perform buffered jump if needed
		if jumpWasPressed:
			_jump()
			jumpWasPressed = false
	# First jump after leaving the ground should only be allowed during coyote time
	elif !is_on_floor():
		if time_since_floor <= coyoteTime:
			jumpCount = jumps
		else:
		# If we've exceeded coyote time and haven't jumped yet, 
		# either remove ability to jump (jumps=1) or allow air jumps only (jumps>1)
			jumpCount = 0  # No jumps allowed after coyote time
	
	# Handle jump input
	if input.jump:
		if is_on_wall() and !is_on_floor():
			# Wall jump
			if wallJump:
				_wallJump()
		elif is_on_floor():
			# Normal jump from ground
			_jump()
		elif time_since_floor <= coyoteTime and jumpCount == jumps:
			# Coyote time jump (first jump only)
			_jump()
		elif jumpBuffering > 0 and jumps == 1:
			# Buffer jump for later
			jumpWasPressed = true
			_bufferJump()
		elif jumps > 1 and jumpCount > 0 and jumpCount < jumps:
			# Multi-jump in air, but ONLY for air jumps (not the ground jump)
			# This ensures we can't use the "ground" jump after coyote time
			velocity.y = -jumpMagnitude
			jumpCount -= 1
			_endGroundPound()

func _handle_dashing(delta):
	
	# Reset dash count when on floor
	if is_on_floor():
		dashCount = dashes
	
	# Handle dash cancel
	if dashing and dashCancel:
		if velocity.x > 0 and input.left_tap:
			velocity.x = 0
		if velocity.x < 0 and input.right_tap:
			velocity.x = 0
	
	# Don't allow dashing if already dashing or rolling
	if dashing or rolling or dashCount <= 0 or !input.dash:
		return
	
	var dTime = DASH_TIME_FACTOR * dashLength
	
	# Handle different dash types
	if eightWayDash:
		var input_direction = Input.get_vector("left", "right", "up", "down")
		
		if input_direction.length() > 0:
			_start_dash(input_direction.normalized(), dTime)
		else:
			# Default to last movement direction
			_start_dash(Vector2(1 if wasMovingR else -1, 0), dTime)
	elif twoWayDashVertical:
		if input.up and !input.down:
			_start_dash(Vector2(0, -1), dTime)
		elif input.down and !input.up:
			_start_dash(Vector2(0, 1), dTime)
	elif twoWayDashHorizontal:
		if !(input.up or input.down):
			_start_dash(Vector2(1 if wasPressingR else -1, 0), dTime)

func _handle_rope_firing(delta):
	# Handle aiming mode with crosshair
	if input.shift: 
		# Only set the initial angle once when we first start aiming
		if !is_aiming:
			is_aiming = true
			crosshair_active = true
			crosshair.visible = true
			if !wasMovingR:
				crosshair_angle = PI  # Starting angle when aiming left
			else:
				crosshair_angle = 0  # Starting angle when aiming right
			
			# Update the position immediately when aiming starts
			update_crosshair_position()
		
		# Apply rotation based on input
		var direction = Input.get_axis("ui_left", "ui_right")
		if abs(direction) > 0.1:
			crosshair_angle += direction * crosshair_rotation_speed * delta
			update_crosshair_position()
	else:
		# Reset aiming state when shift is released
		is_aiming = false
		crosshair_active = false
		crosshair.visible = false
	
	# Handle rope firing with Z key
	if input.z and can_fire and !is_firing_rope:
		print("Rope Fired")
		_start_firing_rope()
	
	# Handle rope extension when firing
	if is_firing_rope:
		_extend_rope(delta)  #this should probably be one function -- fire and extend
		
	# Handle rope retraction
	if Input.is_action_just_released("fire_rope") and (is_firing_rope or rope.is_attached):
		_retract_rope()

#func _start_firing_rope():
	#is_firing_rope = true
	#can_fire = false
	#
	## Force rope to reset its state
	#rope.clear()
	#rope.detach()
	#rope.is_attached = false
	#
	## Get the firing direction based on aiming or movement
	#var direction = get_rope_direction(crosshair_angle)
	#rope.direction = Vector2(cos(direction), sin(direction))
	#
	## Set initial rope position
	#var start_point = Vector2.ZERO
	#var end_point = Vector2.ZERO #At first this looks wrong but it IS getting changed at some point
	#rope.set_points(start_point, end_point) #this needs to change for the proper extension
	#
	## Make the rope visible now that we're firing it
	#rope.line.visible = true
func _start_firing_rope():
	rope.clear()
	rope.detach()
	is_firing_rope = true
	can_fire = false
	
	rope.is_attached = false
	
	# Get the firing direction based on aiming or movement
	var direction = get_rope_direction(crosshair_angle)
	rope.direction = Vector2(cos(direction), sin(direction))
	
	# Use local coordinates since rope is a child of the player
	var start_offset = 5.0 #this should be tweaked but it's just so that you don't hit the player character when first emitting the rope
	var start_point = rope.direction * start_offset  # Local offset from player
	var end_point = start_point
	rope.set_points(start_point, end_point)
	
	# Make the rope visible now that we're firing it
	rope.line.visible = true

func _extend_rope(delta):
	if !is_firing_rope or rope.is_attached:
		return
		
	if rope.length >= max_rope_length:
		is_firing_rope = false
		_retract_rope()
		return
	
	# Calculate extension amount
	var extension = rope_firing_speed * delta
		

	# Extend the rope and check for collisions
	var collision_detected = rope.extend(extension)
	
	if collision_detected:
		is_firing_rope = false
	


func _retract_rope():
	rope.clear()
	is_firing_rope = false
	can_fire = true
	
func get_rope_direction(crosshair_angle): #THIS WILL PROBABLY NEED SOME TWEAKING FOR GOOD AIR ANGLES.. but it's working rn
	if is_aiming:
		return crosshair_angle
	else:
		if is_on_floor():
			if !wasMovingR:
				return PI
			else: 
				return 0
		else:
			if has_been_on_rope:
				var new_angle
				new_angle = PI - current_rope_angle
				if new_angle < PI/8:
					new_angle = PI/8
				if new_angle > (7*PI)/8:
					new_angle = (7*PI)/8
				return new_angle
			else:
				if velocity.x >= 0:
					return -PI/8
				else: 
					return -(7*PI)/8

func update_crosshair_position():
	# Calculate the new position
	var crosshair_position = Vector2(
		cos(crosshair_angle) * crosshair_radius,
		sin(crosshair_angle) * crosshair_radius
	)
	
	# Update the crosshair position (relative to the player)
	crosshair.position = crosshair_position

func _start_dash(direction: Vector2, duration: float):
	if dashCount <= 0:
		return
	
	dashing = true
	dash_time_remaining = duration
	gravityActive = false
	
	velocity = dashMagnitude * direction
	dashCount -= 1
	
	movementInputMonitoring = Vector2(false, false)
	input_pause_time = duration
	
	# Schedule gravity to reactivate after dash
	await get_tree().create_timer(duration).timeout
	gravityActive = true

func _handle_corner_cutting():
	if !cornerCutting or velocity.y >= 0:
		return
	
	if leftRaycast and middleRaycast and rightRaycast:
		var left_colliding = leftRaycast.is_colliding()
		var middle_colliding = middleRaycast.is_colliding()
		var right_colliding = rightRaycast.is_colliding()
		
		if left_colliding and !middle_colliding and !right_colliding:
			position.x += correctionAmount
		elif !left_colliding and middle_colliding and !right_colliding:
			# Push in the direction of movement
			position.x += correctionAmount * (1 if wasMovingR else -1)
		elif !left_colliding and !middle_colliding and right_colliding:
			position.x -= correctionAmount

func _handle_ground_pound(delta):
	if groundPound:
		# Start ground pound
		if input.down_tap and !is_on_floor() and !is_on_wall() and !groundPounding:
			groundPounding = true
			gravityActive = false
			velocity.y = 0
			velocity.x = 0
			
			# Schedule the actual ground pound after pause
			await get_tree().create_timer(groundPoundPause).timeout
			if groundPounding:  # Check if still ground pounding
				_groundPound()
		
		# End ground pound when hitting ground
		if is_on_floor() and groundPounding:
			_endGroundPound()
		
		# Cancel ground pound with up
		if upToCancel and input.up and groundPounding:
			_endGroundPound()

func _jump():
	if (is_on_floor() or time_since_floor <= coyoteTime) and jumpCount > 0:
		velocity.y = -jumpMagnitude
		jumpCount -= 1
		jumpWasPressed = false

func _wallJump():
	var horizontalWallKick = abs(jumpMagnitude * cos(wallKickAngle * (PI / 180)))
	var verticalWallKick = abs(jumpMagnitude * sin(wallKickAngle * (PI / 180)))
	
	velocity.y = -verticalWallKick
	
	var dir = 1
	if wallLatchingModifer and input.latch:
		dir = -1
	
	if wasMovingR:
		velocity.x = -horizontalWallKick * dir
	else:
		velocity.x = horizontalWallKick * dir
	
	if inputPauseAfterWallJump > 0:
		movementInputMonitoring = Vector2(false, false)
		input_pause_time = inputPauseAfterWallJump

func _bufferJump():
	await get_tree().create_timer(jumpBuffering).timeout
	jumpWasPressed = false

func _decelerate(delta, vertical):
	if !vertical:
		if (abs(velocity.x) > 0) and (abs(velocity.x) <= abs(deceleration * delta)):
			velocity.x = 0 
		elif velocity.x > 0:
			velocity.x += deceleration * delta
		elif velocity.x < 0:
			velocity.x -= deceleration * delta
	elif vertical and velocity.y > 0:
		velocity.y += deceleration * delta

func _groundPound():
	appliedTerminalVelocity = terminalVelocity * GROUND_POUND_TERMINAL_FACTOR
	velocity.y = jumpMagnitude * GROUND_POUND_VELOCITY_FACTOR
	
func _endGroundPound():
	groundPounding = false
	appliedTerminalVelocity = terminalVelocity
	gravityActive = true

#func _update_state():  #I'm not sure this is being used for anything right now... seems like it's just restating the obvious
	#var new_state
	#
	#if dashing:
		#new_state = PlayerState.DASHING
	#elif rolling:
		#new_state = PlayerState.ROLLING
	#elif groundPounding:
		#new_state = PlayerState.GROUND_POUNDING
	#elif is_on_wall() and !is_on_floor():
		#if latched:
			#new_state = PlayerState.WALL_LATCHING
		#elif velocity.y > 0:
			#new_state = PlayerState.WALL_SLIDING
	#elif !is_on_floor():
		#if velocity.y < 0:
			#new_state = PlayerState.JUMPING
		#else:
			#new_state = PlayerState.FALLING
	#elif crouching:
		#new_state = PlayerState.CROUCHING
	#elif abs(velocity.x) > 0.1:
		#new_state = PlayerState.RUNNING
	#else:
		#new_state = PlayerState.IDLE
	#
	#if new_state != current_state:
		#current_state = new_state

func _apply_stretch_squash(delta):
	# Track when player is landing
	var just_landed = was_in_air and is_on_floor()
	was_in_air = !is_on_floor()
	
	# Start stretching when jumping
	if input.jump and (is_on_floor() or time_since_floor <= coyoteTime) and !is_stretching:
		is_stretching = true
		is_squashing = false
	
	# Start squashing when landing
	if just_landed and !is_squashing:
		is_squashing = true
		is_stretching = false
	
	if !anim:
		return
	
	# Calculate target scales with less extreme stretching
	var stretch_x_factor = 0.9  # Less extreme horizontal compression (was 0.7)
	var squash_x_factor = 1.1   # Less extreme horizontal stretching (inverse of 0.9)
	
	# Apply stretch effect (elongate vertically, compress horizontally)
	if is_stretching:
		anim.scale.y = lerp(anim.scale.y, default_scale.y * stretch_amount, animation_speed * delta)
		anim.scale.x = lerp(anim.scale.x, default_scale.x * stretch_x_factor, animation_speed * delta)
		
		# End stretch when close to target
		if abs(anim.scale.y - (default_scale.y * stretch_amount)) < 0.05:
			is_stretching = false
	
	# Apply squash effect (compress vertically, elongate horizontally)
	elif is_squashing:
		anim.scale.y = lerp(anim.scale.y, default_scale.y * squash_amount, animation_speed * delta)
		anim.scale.x = lerp(anim.scale.x, default_scale.x * squash_x_factor, animation_speed * delta)
		
		# End squash when close to target
		if abs(anim.scale.y - (default_scale.y * squash_amount)) < 0.05:
			is_squashing = false
	
	# Return to normal scale when not stretching or squashing
	elif !is_stretching and !is_squashing:
		anim.scale.y = lerp(anim.scale.y, default_scale.y, animation_speed * delta)
		anim.scale.x = lerp(anim.scale.x, default_scale.x * sign(anim.scale.x), animation_speed * delta)
	
	# Maintain the correct direction of the sprite
	if input.right and !latched:
		anim.scale.x = abs(anim.scale.x)
	if input.left and !latched:
		anim.scale.x = -abs(anim.scale.x)


func swing_on_rope(connection_point):
	pass

func process_rope_swing(delta):
	pass
# Check if the rope collides with environment between start and end points
	
func _on_rope_collision(position, collider):
	# The rope has collided with something
	# Start swinging physics or other behavior
	print("Rope attached to ", collider.name, " at position ", collider.position)
	
	# You might want to create a PinJoint2D here
	var joint = PinJoint2D.new()
	joint.position = position #this is not gonna work it just pulls the current character position lol
	joint.node_a = self.get_path()
	joint.node_b = collider.get_path()
	add_child(joint)
