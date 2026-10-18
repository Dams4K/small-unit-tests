@tool
extends EditorPlugin

var run_tests_button: Button
var run_thread: Thread

var editor_theme: Theme

func _enter_tree() -> void:
	editor_theme = EditorInterface.get_editor_theme()

	run_tests_button = Button.new()
	#run_tests_button.icon = preload("res://addons/sut/icon.svg")
	run_tests_button.tooltip_text = "Run all tests"
	run_tests_button.pressed.connect(_run_tests_cli_threaded)
	run_tests_button.theme_type_variation = &"RunBarButton"

	var scale := EditorInterface.get_editor_scale()
	var tex := preload("res://addons/sut/icon.svg") as Texture2D
	var img := tex.get_image()
	img.resize(int(16 * scale), int(16 * scale), Image.INTERPOLATE_LANCZOS)
	run_tests_button.icon = ImageTexture.create_from_image(img)
	run_tests_button.modulate = _get_editor_icon_color()

	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, run_tests_button)


func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, run_tests_button)
	if run_thread != null and run_thread.is_started():
		run_thread.wait_to_finish()


func _run_tests_cli_threaded() -> void:
	if run_thread != null and run_thread.is_started():
		return

	run_thread = Thread.new()
	var err = run_thread.start(_run_tests_cli)

	if err != OK:
		push_error("Failed to start test thread: %s" % err)
		run_thread = null


func _run_tests_cli() ->void:
	var project_path := ProjectSettings.globalize_path("res://")
	var run_script_path := ProjectSettings.globalize_path("res://addons/sut/run.gd")
	var output: Array

	var exit_code := OS.execute(
		OS.get_executable_path(),
		["--headless", "--path", project_path, "-s", run_script_path, "--", "--bbcode"],
		output,
		true,
		false
	)

	_on_tests_finished.call_deferred(exit_code, output)


func _on_tests_finished(exit_code: int, output: Array) -> void:
	if run_thread != null and run_thread.is_started():
		run_thread.wait_to_finish()
		run_thread = null


	for line in output:
		print_rich(line)

	print("Tests finished with exit code: %d" % exit_code)


func _get_editor_icon_color() -> Color:
	var theme := EditorInterface.get_editor_theme()
	var img := theme.get_icon("MainPlay", "EditorIcons").get_image()
	if img.is_compressed():
		img.decompress()
	return img.get_pixel(img.get_width() / 2, img.get_height() / 2)
