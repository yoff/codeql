/**
 * Provides classes and predicates for defining barriers.
 *
 * Flow barriers defined here feed into data flow configurations as follows:
 *
 * ```text
 * data from *.model.yml | QL extensions of FlowBarrier::Range
 *  v                       v
 * FlowBarrier (associated with a models-as-data kind string)
 *  v
 * barrierNode predicate | other QL defined barriers, for example using concepts
 *  v                    v
 * various Barrier classes for specific data flow configurations
 * ```
 *
 * New barriers should be defined using models-as-data, QL extensions of
 * `FlowBarrier::Range`, or concepts. Data flow configurations should use the
 * `barrierNode` predicate and/or concepts to define their barriers.
 */

private import rust
private import internal.FlowSummaryImpl as Impl
private import internal.DataFlowImpl as DataFlowImpl

// import all instances below
private module Barriers {
  private import codeql.rust.Frameworks
  private import codeql.rust.dataflow.internal.ModelsAsData
}

/** Provides the `Range` class used to define the extent of `FlowBarrier`. */
module FlowBarrier {
  /** A flow barrier. */
  abstract class Range extends Impl::Public::BarrierElement {
    bindingset[this]
    Range() { any() }

    override predicate isBarrier(
      string output, string kind, Impl::Public::Provenance provenance, string model
    ) {
      this.isBarrier(output, kind) and provenance = "manual" and model = ""
    }

    /**
     * Holds if this element is a flow barrier of kind `kind`, where data
     * flows out as described by `output`.
     */
    predicate isBarrier(string output, string kind) { none() }
  }
}

final class FlowBarrier = FlowBarrier::Range;

/** Provides the `Range` class used to define the extent of `FlowBarrierGuard`. */
module FlowBarrierGuard {
  /** A flow barrier guard. */
  abstract class Range extends Impl::Public::BarrierGuardElement {
    bindingset[this]
    Range() { any() }

    override predicate isBarrierGuard(
      string input, string branch, string kind, Impl::Public::Provenance provenance, string model
    ) {
      this.isBarrierGuard(input, branch, kind) and provenance = "manual" and model = ""
    }

    /**
     * Holds if this element is a flow barrier guard of kind `kind`, for data
     * flowing in as described by `input`, when `this` evaluates to `branch`.
     */
    predicate isBarrierGuard(string input, string branch, string kind) { none() }
  }
}

final class FlowBarrierGuard = FlowBarrierGuard::Range;

predicate barrierNode = DataFlowImpl::barrierNode/2;
