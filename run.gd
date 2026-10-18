extends SceneTree

func _init() -> void:
	var runner := TestRunner.new()
	var failed := runner.run_all()


	print("Results:")
	print("Tests run: %d, Failures: %d" % [runner.runs, runner.failures])

	quit(1 if failed else 0)
