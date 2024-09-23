/**
 * @name Flow to print from user-controlled sources
 * @description Test
 * @kind path-problem
 * @problem.severity error
 * @security-severity 0.0
 * @precision high
 * @id py/flow-to-print
 */

import python
import semmle.python.dataflow.new.TaintTracking

module Flows = TaintTracking::Global<PrintConfig>;

int explorationLimit() { result = 5 }

module FlowsPartial = Flows::FlowExplorationFwd<explorationLimit/0>;

import FlowsPartial::PartialPathGraph
private import semmle.python.Concepts
private import semmle.python.ApiGraphs

class Source extends DataFlow::Node {
  Source() {
    this = API::moduleImport("sys").getMember("argv").asSource() and
    not exists(File f | this.getLocation().getFile() = f and f.inStdlib())
  }
}

class Sink extends DataFlow::Node {
  Sink() {
    this = API::builtin("print").getACall().getArg(_) and
    not exists(File f | this.getLocation().getFile() = f and f.inStdlib())
  }
}

private module PrintConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { none() }

  predicate isAdditionalFlowStep(DataFlow::Node a, DataFlow::Node b) {
    exists(File f |
      a.getLocation().getFile() = f and b.getLocation().getFile() = f and not f.inStdlib()
    ) and
    exists(AssignStmt assign, Name use, Variable var |
      assign.getTarget(_) = a.asExpr() and
      use = b.asExpr() and
      assign.defines(var) and
      var.getAnAccess() = use and
      // control flow to a parent - just doing getASuccessor() to the node fails
      a.asCfgNode().getASuccessor+() = b.asExpr().getParentNode*().getAFlowNode() and
      a != b
    ) and
    none() // switch on or off by commenting/uncommenting this line
  }
}

// import Flows::PathGraph
from FlowsPartial::PartialPathNode source, FlowsPartial::PartialPathNode sink
where FlowsPartial::partialFlow(source, sink, _)
select sink.getNode(), source, sink, "This node receives taint from $@.", source.getNode(),
  "this source"
