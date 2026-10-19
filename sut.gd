@tool
extends EditorPlugin

var run_tests_button: Button
var run_thread: Thread

var executor := SutTestExecutor.new()

func project_path(rel_path: String) -> String:
	var base = get_script().resource_path.get_base_dir()
	return base.path_join(rel_path)


func _enter_tree() -> void:
	executor.finished.connect(_on_executor_finished)
	
	run_tests_button = Button.new()
	run_tests_button.tooltip_text = "Run all tests"
	run_tests_button.pressed.connect(_run_all_tests)
	run_tests_button.theme_type_variation = &"RunBarButton"

	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, run_tests_button)
	_update_ui()


func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, run_tests_button)
	executor.shutdown()


func _run_all_tests() -> void:
	if executor.is_running():
		return
	
	run_tests_button.disabled = true
	var base = get_script().resource_path.get_base_dir()
	var run_script_path := ProjectSettings.globalize_path(project_path("cli/run.gd"))
	
	executor.execute(run_script_path)

func _on_executor_finished(exit_code: int) -> void:
	run_tests_button.disabled = false
	print("\nTests finished with exit code: %d." % exit_code)


func _get_editor_icon_color() -> Color:
	var theme := EditorInterface.get_editor_theme()
	var img := theme.get_icon("MainPlay", "EditorIcons").get_image()
	if img.is_compressed():
		img.decompress()
	return img.get_pixel(img.get_width() / 2, img.get_height() / 2)


func _notification(what: int) -> void:
	if what == EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED:
		_update_ui()

func _update_ui():
	var scale := EditorInterface.get_editor_scale()
	var tex := load(project_path("icon.svg")) as Texture2D
	var img := tex.get_image()
	img.resize(int(16 * scale), int(16 * scale), Image.INTERPOLATE_LANCZOS)
	run_tests_button.icon = ImageTexture.create_from_image(img)
	run_tests_button.modulate = SutTestColor.success()
