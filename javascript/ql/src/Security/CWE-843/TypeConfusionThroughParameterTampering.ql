/**
 * @name Type confusion through parameter tampering
 * @description Sanitizing an HTTP request parameter may be ineffective if the user controls its type.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id js/type-confusion-through-parameter-tampering
 * @tags security
 *       external/cwe/cwe-843
 */

import javascript
import semmle.javascript.security.dataflow.TypeConfusionThroughParameterTamperingQuery
import TypeConfusionFlow::PathGraph

from TypeConfusionFlow::PathNode source, TypeConfusionFlow::PathNode sink
where TypeConfusionFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "Potential type confusion as $@ may be either an array or a string.", source.getNode(),
  "this HTTP request parameter"
