extends Node2D
class_name PlanDrawLayer

signal path_committed(path_points: PackedVector2Array)

@export var line_scene: PackedScene  # optional prefab Line2D, or leave empty

var is_planning: bool = false
var current_points: PackedVector2Array = PackedVector2Array()
var current_line: Line2D

func start_planning() -> void:
    is_planning = true
    current_points = PackedVector2Array()
    if current_line != null:
        current_line.queue_free()
        current_line = null
    _create_line()

func cancel_planning() -> void:
    is_planning = false
    current_points = PackedVector2Array()
    if current_line != null:
        current_line.queue_free()
        current_line = null

func _create_line() -> void:
    if line_scene != null:
        current_line = line_scene.instantiate() as Line2D
    else:
        current_line = Line2D.new()
        current_line.width = 3.0
    add_child(current_line)
    current_line.clear_points()

func _unhandled_input(event: InputEvent) -> void:
    if not is_planning:
        return

    if event is InputEventMouseButton:
        var mb := event as InputEventMouseButton
        if not mb.pressed:
            return

        if mb.button_index == MOUSE_BUTTON_LEFT:
            var world_pos := get_global_mouse_position()
            current_points.append(world_pos)
            current_line.add_point(to_local(world_pos))
        elif mb.button_index == MOUSE_BUTTON_RIGHT:
            is_planning = false
            path_committed.emit(current_points)
