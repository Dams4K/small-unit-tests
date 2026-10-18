extends SceneTree

func _init() -> void:
	var runner := TestRunner.new()
	var failed := runner.run_all()
	
	if failed:
		printerr("Tests have failed: %d/%d" % [runner.total_failed, runner.total_tested])
	else:
		print("All tests have succeded: %s/%s" % [runner.total_tested - runner.total_failed, runner.total_tested])
	
	quit(1 if failed else 0)
