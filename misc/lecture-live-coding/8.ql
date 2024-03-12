/**
 * @kind path-problem
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.RemoteFlowSources
import semmle.python.dataflow.new.TaintTracking
import semmle.python.dataflow.new.BarrierGuards
import semmle.python.ApiGraphs

module Config implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  predicate isSink(DataFlow::Node sink) {
    sink =
      API::moduleImport("django")
          .getMember("db")
          .getMember("connection")
          .getMember("cursor")
          .getReturn()
          .getMember("execute")
          .getACall()
          .getArg(0)
  }

  predicate isBarrier(DataFlow::Node node) { node instanceof StringConstCompareBarrier }
}

module Flow = TaintTracking::Global<Config>;

import Flow::PathGraph

from Flow::PathNode source, Flow::PathNode sink
where Flow::flowPath(source, sink)
select source, sink
