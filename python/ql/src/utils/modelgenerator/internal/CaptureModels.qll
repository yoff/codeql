import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.dataflow.new.internal.DataFlowImplCommon as DataFlowImplCommon
import semmle.python.dataflow.new.internal.DataFlowPrivate as DataFlowPrivate

/**
 * Ideally we can restrict this heavily.
 * We only want
 * - public functions
 * - interesting functions (for security)
 * - functions for which we can generate decent summaries
 */
class DataFlowTargetApi extends Function {
  DataFlowTargetApi() { not this.getName().prefix(1) = "_" }
}

private int accessPathLimit() { result = 2 }

private newtype TTaintState =
  TTaintRead(int n) { n in [0 .. accessPathLimit()] } or
  TTaintStore(int n) { n in [1 .. accessPathLimit()] }

abstract private class TaintState extends TTaintState {
  abstract string toString();
}

/**
 * A FlowState representing a tainted read.
 */
private class TaintRead extends TaintState, TTaintRead {
  private int step;

  TaintRead() { this = TTaintRead(step) }

  /**
   * Gets the flow state step number.
   */
  int getStep() { result = step }

  override string toString() { result = "TaintRead(" + step + ")" }
}

/**
 * A FlowState representing a tainted write.
 */
private class TaintStore extends TaintState, TTaintStore {
  private int step;

  TaintStore() { this = TTaintStore(step) }

  /**
   * Gets the flow state step number.
   */
  int getStep() { result = step }

  override string toString() { result = "TaintStore(" + step + ")" }
}

/**
 * A data-flow configuration for tracking flow through APIs.
 * The sources are the parameters of an API and the sinks are the return values (excluding `this`) and parameters.
 *
 * This can be used to generate Flow summaries for APIs from parameter to return.
 */
module ThroughFlowConfig implements DataFlow::StateConfigSig {
  class FlowState = TaintState;

  predicate isSource(DataFlow::Node source, FlowState state) {
    source instanceof DataFlow::ParameterNode and
    source.getEnclosingCallable().getScope() instanceof DataFlowTargetApi and
    state.(TaintRead).getStep() = 0
  }

  predicate isSink(DataFlow::Node sink, FlowState state) {
    sink instanceof DataFlowImplCommon::ReturnNodeExt and
    // not isOwnInstanceAccessNode(sink) and
    // not exists(captureQualifierFlow(sink.asExpr().getEnclosingCallable())) and
    (state instanceof TaintRead or state instanceof TaintStore)
  }

  predicate isAdditionalFlowStep(
    DataFlow::Node node1, FlowState state1, DataFlow::Node node2, FlowState state2
  ) {
    exists(DataFlow::Content c |
      DataFlowImplCommon::store(node1, c, node2, _, _) and
      // isRelevantContent(c) and
      (
        state1 instanceof TaintRead and state2.(TaintStore).getStep() = 1
        or
        state1.(TaintStore).getStep() + 1 = state2.(TaintStore).getStep()
      )
    )
    or
    exists(DataFlow::Content c |
      DataFlowPrivate::readStep(node1, c, node2) and
      // isRelevantContent(c) and
      state1.(TaintRead).getStep() + 1 = state2.(TaintRead).getStep()
    )
  }

  // predicate isBarrier(DataFlow::Node n) {
  //   exists(Type t | t = n.getType() and not isRelevantType(t))
  // }
  DataFlow::FlowFeature getAFeature() {
    result instanceof DataFlow::FeatureEqualSourceSinkCallContext
  }
}

private module ThroughFlow = TaintTracking::GlobalWithState<ThroughFlowConfig>;

/**
 * Gets the summary model(s) of `api`, if there is flow from parameters to return value or parameter.
 */
string captureThroughFlow(DataFlowTargetApi api) {
  exists(
    DataFlow::ParameterNode p, DataFlowImplCommon::ReturnNodeExt returnNodeExt, string input,
    string output
  |
    ThroughFlow::flow(p, returnNodeExt) and
    returnNodeExt.(DataFlow::Node).getEnclosingCallable().getScope() = api and
    input = ModelPrinting::parameterNodeAsInput(p) and
    output = ModelPrinting::returnNodeAsOutput(returnNodeExt) and
    input != output and
    result = ModelPrinting::asTaintModel(api, input, output)
  )
}

string captureFlow(DataFlowTargetApi api) {
  // result = captureQualifierFlow(api) or
  result = captureThroughFlow(api)
}

module ModelPrinting {
  import semmle.python.dataflow.new.internal.DataFlowDispatch

  string parameterAccess(Parameter p) { result = "Argument[" + p.getPosition().toString() + "]" }

  private DataFlow::ParameterNode getParameter(
    DataFlowImplCommon::ReturnNodeExt node, ParameterPosition pos
  ) {
    result = node.(DataFlow::Node).getEnclosingCallable().getParameter(pos)
  }

  /**
   * Gets the MaD string representation of the qualifier.
   */
  string qualifierString() { result = "Argument[this]" }

  /**
   * Gets the MaD string representation of the parameter node `p`.
   */
  string parameterNodeAsInput(DataFlow::ParameterNode p) {
    result = parameterAccess(p.getParameter())
    // or
    // result = qualifierString() and p instanceof InstanceParameterNode
  }

  /**
   * Gets the MaD string representation of the the return node `node`.
   */
  string returnNodeAsOutput(DataFlowImplCommon::ReturnNodeExt node) {
    if node.getKind() instanceof DataFlowImplCommon::ValueReturnKind
    then result = "ReturnValue"
    else
      exists(ParameterPosition pos |
        pos = node.getKind().(DataFlowImplCommon::ParamUpdateReturnKind).getPosition()
      |
        result = parameterNodeAsInput(getParameter(node, pos))
        or
        pos.isSelf() and
        result = qualifierString()
      )
  }

  bindingset[input, output]
  string asTaintModel(DataFlowTargetApi api, string input, string output) {
    result = api.getName() + ";" + input + ";" + output + ";"
  }
}
