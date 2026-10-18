extends SceneTree

func _init() -> void:
	var runner := TestRunner.new()
	var failed := runner.run_all()


	TestReport.report("\n[b]Results:[/b]")

	if runner.failures == 0:
		TestReport.report("[color=%s]Tests run: %d[/color], Failures: %d" % [TestReport.C_PASS, runner.runs, runner.failures])
	else:
		TestReport.report("[color=%s]Tests run: %d, Failures: %d[/color]" % [TestReport.C_FAIL, runner.runs, runner.failures])

	quit(1 if failed else 0)
