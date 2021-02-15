/**
 * @name SQL query built from user-controlled sources
 * @description Building a SQL query from user-controlled sources is vulnerable to insertion of
 *              malicious SQL code by the user.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 *       external/owasp/owasp-a1
 */

import python
import DataFlow::PartialPathGraph
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.Concepts
import semmle.python.dataflow.new.RemoteFlowSources

/**
 * A taint-tracking configuration for detecting SQL injection vulnerabilities.
 */
class SQLInjectionConfiguration extends TaintTracking::Configuration {
  SQLInjectionConfiguration() { this = "SQLInjectionConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    // source instanceof RemoteFlowSource or
    source instanceof DataFlow::Remote
  }

  override predicate isSink(DataFlow::Node sink) {
    // sink = any(SqlExecution e).getSql()
    sink instanceof DataFlow::RecursiveContentSource
  }

  override int explorationLimit() { result = 5 }
}

from
  SQLInjectionConfiguration config, DataFlow::PartialPathNode source, DataFlow::PartialPathNode sink
where config.hasPartialFlow(source, sink, _) //and
// source.hasLocationInfo(_, 145, _, _, _) and
// sink.hasLocationInfo(_, [154, 206, 246, 254], _, _, _)
select sink.getNode(), source, sink, "This SQL query depends on $@.", source.getNode(),
  "a user-provided value"
