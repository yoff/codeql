import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.RemoteFlowSources
import semmle.python.dataflow.new.TaintTracking

module Config implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  predicate isSink(DataFlow::Node sink) {
    exists(DataFlow::MethodCallNode execute, DataFlow::Node cursor |
      execute.calls(cursor, "execute") and
      cursor.asExpr().(Name).getId() = "cursor" and
      execute.getArg(0) = sink
    )
  }
}

import TaintTracking::Make<Config> as SqlInjection

from SqlInjection::PathNode source, SqlInjection::PathNode sink
where SqlInjection::hasFlowPath(source, sink)
select source, sink
