extends Node2D
class_name Army

signal clicked(army: Army)
signal movement_completed(army: Army)

@export var army_id: StringName = &""
@export var speed: float = 60.0
@export var general: General

var current_order: Order
var current_path: PackedVector2Array = PackedVector2Array()
var path_index: int = 0
var moving: bool = false

func _ready() -> void:
    set_process(true)

func assign_order(order: Order) -> void:
    current_order = order
    current_path = order.path_points
    path_index = 0
    moving = current_path.size() > 0

func _process(delta: float) -> void:
    if not moving or current_path.size() == 0:
        return

    var target_pos: Vector2 = current_path[path_index]
    var direction := target_pos - global_position
    var distance_to_travel := speed * delta
    var distance_remaining := direction.length()

    if distance_remaining <= distance_to_travel:
        global_position = target_pos
        path_index += 1

        if path_index >= current_path.size():
            moving = false
            movement_completed.emit(self)
    else:
        var dir_norm := direction / distance_remaining
        global_position += dir_norm * distance_to_travel

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
    if event is InputEventMouseButton:
        var mb := event as InputEventMouseButton
        if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
            clicked.emit(self)
