extends CharacterBody3D
class_name player
var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 6
const SENSITIVITY = 0.004
var wasOffFloor = true

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0
#fov variables

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var damage = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8
@onready var camera = $Camera3D

func _ready():
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _enter_tree():
  set_multiplayer_authority(name.to_int())

func _unhandled_input(event):
  if event is InputEventMouseMotion:
    rotate_y(-event.relative.x * SENSITIVITY)
    camera.rotate_x(-event.relative.y * SENSITIVITY)
    camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(60))


func _physics_process(delta):
  if is_multiplayer_authority():
    camera.current = true
    # Add the gravity.
    if not is_on_floor():
      velocity.y -= gravity * delta
      wasOffFloor = true
    elif wasOffFloor:
      playsound("Land")
      wasOffFloor = false

    
    # Handle Sprint.
    if Input.is_action_pressed("Player_SPRINT"):
      speed = SPRINT_SPEED
    else:
      speed = WALK_SPEED
    if Input.is_action_just_pressed("Player_SPRINT"):
      playsound("SprintStart")
      

    # Handle Jump.
    if Input.is_action_just_pressed("Player_JUMP") and is_on_floor():
      playsound("Jump")
      MultiplayerTest._add_scene(load("res://Scenes/bullet.tscn"))
      velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    var input_dir = Input.get_vector("Player_MOVELEFT", "Player_MOVERIGHT", "Player_MOVEUP", "Player_MOVEDOWN")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if is_on_floor():
      if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
      else:
        velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
        velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
    else:
      velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
      velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
    
    # Head bob
    t_bob += delta * velocity.length() * float(is_on_floor())
    camera.transform.origin = _headbob(t_bob)
  
    # FOV
    var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
    var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
    camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
    
  rot_cam()
      
  move_and_slide()

func playsound(soundName):
  var newSound = AudioStreamPlayer.new()
  newSound.stream = load("res://Assets/Sounds/" + soundName + ".wav")
  add_child(newSound)
  newSound.play()
  await newSound.finished
  newSound.queue_free()


func _headbob(time) -> Vector3:
  var pos = Vector3.ZERO
  pos.y = sin(time * BOB_FREQ) * BOB_AMP
  pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
  return pos
  
# This sucks, might need to be removed
func rot_cam():
  var temp_rot:float = clamp(velocity.z / 720, -20, 20)
  camera.rotation.z = temp_rot
