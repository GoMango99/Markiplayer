extends MeshInstance3D

enum weapon_type{
  sword,
  gun,
  proj
}

@export var ray:RayCast3D
@export var camera:Camera3D

func shoot_gun():
  ray.rotation = camera.rotation
  ray.position = camera.position
  ray.enabled = true
  ray.enabled = false
  if(ray.is_colliding()):
    print("Colliding")
  

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  shoot_gun()
