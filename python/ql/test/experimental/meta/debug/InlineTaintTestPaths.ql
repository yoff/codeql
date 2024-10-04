/**
 * @kind path-problem
 */

// This query is for debugging InlineTaintTestFailures.
// The intended usage is
// 1. load the database of the failing test
// 2. run this query to see actual paths
// 3. if necessary, look at partial paths by (un)commenting appropriate lines
import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.meta.InlineTaintTest::Conf

module Config implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { TestTaintTrackingConfig::isSource(source) }

  predicate isSink(DataFlow::Node source) { TestTaintTrackingConfig::isSink(source) }
}

module Flows = TaintTracking::Global<Config>;

module Full {
  import Flows::PathGraph

  query predicate problems(
    DataFlow::Node alertLocation, Flows::PathNode source, Flows::PathNode sink, string msg1,
    DataFlow::Node sourceLocation, string msg2
  ) {
    Flows::flowPath(source, sink) and
    alertLocation = sink.getNode() and
    sourceLocation = source.getNode() and
    msg1 = "This node receives taint from $@." and
    msg2 = "this source"
  }
}

module Partial {
  int explorationLimit() { result = 5 }

  module FlowsPartial = Flows::FlowExplorationFwd<explorationLimit/0>;

  import FlowsPartial::PartialPathGraph

  query predicate problems(
    DataFlow::Node alertLocation, FlowsPartial::PartialPathNode source,
    FlowsPartial::PartialPathNode sink, string msg1, DataFlow::Node sourceLocation, string msg2
  ) {
    FlowsPartial::partialFlow(source, sink, _) and
    alertLocation = sink.getNode() and
    sourceLocation = source.getNode() and
    msg1 = "This node receives taint from $@." and
    msg2 = "this source"
  }
}

import Full
// import Partial
