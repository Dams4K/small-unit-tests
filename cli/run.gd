extends SceneTree

func _init() -> void:
	var runner := TestRunner.new()
	var failed := runner.run_all()
	
	SutTestReport.report("\n[b]Results:[/b]")
	
	var report_func = SutTestReport.report_success if runner.failures == 0 else SutTestReport.report_fail
	report_func.call("Tests run: %d, Failures: %d" % [runner.runs, runner.failures])
	
	_write_junit(runner)
	quit(1 if failed else 0)


func _write_junit(runner: TestRunner) -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--junit="):
			var path: String = arg.trim_prefix("--junit=")
			if path.is_relative_path():
				path = ProjectSettings.globalize_path("res://").path_join(path)
			var file := FileAccess.open(path, FileAccess.WRITE)
			if file == null:
				push_error("Cannot write JUnit report: %s" % path)
				return
			file.store_string(JUnitReport.build(runner.results))
			print("Junit report wrote in '%s'" % path)
