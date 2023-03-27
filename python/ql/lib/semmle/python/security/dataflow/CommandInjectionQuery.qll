/**
 * Provides a taint-tracking configuration for detecting "command injection" vulnerabilities.
 *
 * Note, for performance reasons: only import this file if
 * `CommandInjection::Configuration` is needed, otherwise
 * `CommandInjectionCustomizations` should be imported instead.
 */

private import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.ApiGraphs
import CommandInjectionCustomizations::CommandInjection

/**
 * A taint-tracking configuration for detecting "command injection" vulnerabilities.
 */
class Configuration extends TaintTracking::Configuration {
  Configuration() { this = "CommandInjection" }

  override predicate isSource(DataFlow::Node source) { source instanceof Source }

  override predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  override predicate isSanitizer(DataFlow::Node node) { node instanceof Sanitizer }

  deprecated override predicate isSanitizerGuard(DataFlow::BarrierGuard guard) {
    guard instanceof SanitizerGuard
  }

  override predicate isAdditionalTaintStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    exists(API::CallNode call |
      call = API::moduleImport("paramiko").getMember("ProxyCommand").getACall() and
      nodeFrom = [call.getArg(0), call.getArgByName("command_line")] and
      nodeTo = call
    )
  }
}
