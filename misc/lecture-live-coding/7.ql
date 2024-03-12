/**
 * @kind path-problem
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.RemoteFlowSources
import semmle.python.dataflow.new.TaintTracking
import semmle.python.dataflow.new.BarrierGuards

module Config implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  predicate isSink(DataFlow::Node sink) {
    exists(DataFlow::MethodCallNode execute, DataFlow::Node cursor |
      execute.calls(cursor, "execute") and
      cursor.asExpr().(Name).getId() = "cursor" and
      execute.getArg(0) = sink
    )
  }

  predicate isBarrier(DataFlow::Node node) { node instanceof StringConstCompareBarrier }
}

module Flow = TaintTracking::Global<Config>;

import Flow::PathGraph

from Flow::PathNode source, Flow::PathNode sink
where Flow::flowPath(source, sink)
select sink.getNode(), source, sink, "User controlled sql executed"
