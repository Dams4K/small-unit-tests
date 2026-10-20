extends RefCounted
class_name SutTestExecutor

signal finished(exit_code: int)

var _pid: int = -1
var _threads: Array[Thread] = []
var _running_readers := 0

func is_running() -> bool:
	return _pid != -1

func execute(run_script_path: String) -> void:
	if is_running():
		return
	
	var project_path := ProjectSettings.globalize_path("res://")
	var args := [
		"--headless", "--path", project_path, "-s", run_script_path,
		"--",
		"--bbcode",
		"--success_color=%s" % SutTestColor.success().to_html(false),
		"--error_color=%s" % SutTestColor.error().to_html(false),
	]
	
	var info := OS.execute_with_pipe(OS.get_executable_path(), args)
	if info.is_empty():
		push_error("Could not start the test process.")
		return
	
	_pid = info["pid"]
	_running_readers = 2
	_start_reader(info["stdio"], print_rich)
	_start_reader(info["stderr"], printerr)


func _start_reader(pipe: FileAccess, callback: Callable) -> void:
	var thread := Thread.new()
	thread.start(_read_pipe.bind(pipe, callback))
	_threads.append(thread)


func _read_pipe(pipe: FileAccess, callback: Callable) -> void:
	while true:
		var line := pipe.get_line()
		if line.is_empty() and pipe.get_error() != OK:
			break # pipe closed
		callback.call(line)
	_on_reader_done.call_deferred()


func _on_reader_done() -> void:
	if not is_running():
		return
	_running_readers -= 1
	if _running_readers > 0:
		return
	
	_join_threads()
	var exit_code: int = OS.get_process_exit_code(_pid)
	_pid = -1
	finished.emit(exit_code)


func _join_threads() -> void:
	for thread in _threads:
		if thread.is_started():
			thread.wait_to_finish()
	_threads.clear()


func _cancel() -> void:
	if is_running():
		OS.kill(_pid)


func shutdown() -> void:
	_cancel()
	_join_threads()
	_pid = -1
