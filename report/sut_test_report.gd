@abstract
extends Object
class_name SutTestReport

static func report(text: String) -> void:
	if SutTestOptions.get_singleton().bbcode:
		print(text)
	else:
		print_rich(text)

static func report_success(text: String) -> void:
	report("[color=%s]%s[/color]" % [SutTestOptions.get_singleton().success_color, text])

static func report_fail(text: String) -> void:
	report("[color=%s]%s[/color]" % [SutTestOptions.get_singleton().error_color, text])


static func report_running(path: String) -> void:
	SutTestReport.report("[color=%s]Running %s[/color]" % [SutTestOptions.get_singleton().dim_color, path])


static func report_results(results: Array[SutTestResult]) -> void:
	pass
	#if local_failures == 0:
	#	SutTestReport.report("[color=%s]Tests run: %d[/color], Failures: %d [color=%s], Time elapsed: %ss -- in %s[/color]" % [
	#		SutTestOptions.get_singleton().success_color,
	#		local_runs,
	#		local_failures,
	#		SutTestOptions.get_singleton().dim_color,
	#		get_script_classname(script)
	#	])
	#else:
	#	SutTestReport.report("Tests run: %d, [color=%s]Failures: %d[/color] [color=%s], Time elapsed: %ss -- in %s[/color]" % [
	#		local_runs,
	#		SutTestOptions.get_singleton().error_color,
	#		local_failures,
	#		SutTestOptions.get_singleton().dim_color,
	#		get_script_classname(script)
	#	])

static func report_result_if_failed(result: SutTestResult) -> bool:
	if result == null:
		return false
	
	var failed = result.failed()
	for message: String in result.failures:
		SutTestReport.report_fail("[%s.%s] %s" % [result.get_classname(), result.name, message])
	return failed
