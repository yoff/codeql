import java
import Concurrency

module Monitors {
  newtype Monitor =
    VariableMonitor(Variable v) { v.getType().hasName("Lock") or locallySynchronizedOn(_, _, v) } or
    InstanceMonitor(RefType thisType) { locallySynchronizedOnThis(_, thisType) } or
    ClassMonitor(RefType classType) { locallySynchronizedOnClass(_, classType) }

  predicate locallyMonitors(Expr e, Monitor m) {
    exists(Variable v | m = VariableMonitor(v) |
      locallyLockedOn(e, v)
      or
      locallySynchronizedOn(e, _, v)
    )
    or
    exists(RefType thisType | m = InstanceMonitor(thisType) |
      locallySynchronizedOnThis(e, thisType)
    )
    or
    exists(RefType classType | m = ClassMonitor(classType) |
      locallySynchronizedOnClass(e, classType)
    )
  }

  /** Holds if `e` is synchronized on the `Lock` `lock` by a locking call. */
  predicate locallyLockedOn(Expr e, Variable lock) {
    lock.getType().hasName("Lock") and
    exists(MethodCall lockCall, MethodCall unlockCall |
      lockCall.getQualifier() = lock.getAnAccess() and
      lockCall.getMethod().getName() in ["lock", "lockInterruptibly", "tryLock"] and
      unlockCall.getQualifier() = lock.getAnAccess() and
      unlockCall.getMethod().getName() = "unlock"
    |
      dominates(lockCall.getControlFlowNode(), unlockCall.getControlFlowNode()) and
      dominates(lockCall.getControlFlowNode(), e.getControlFlowNode()) // and
      // we do not require `e` to dominate `unlock` as the critical region may be exited
      // by an exception before 'e' is executed.
      // But we do want `unlock` to be a successor of `e`.
      //e.getControlFlowNode().getANormalSuccessor*() = unlockCall.getControlFlowNode()
    )
  }
}

module Modification {
  import semmle.code.java.dataflow.FlowSummary

  predicate isModifying(FieldAccess a) {
    a.isVarWrite()
    or
    exists(Call c | c.(MethodCall).getQualifier() = a |
      not a.getType().hasName("Lock") and
      isModifyingCall(c)
    )
    or
    exists(ArrayAccess aa, Assignment asa | aa.getArray() = a | asa.getDest() = aa)
  }

  predicate isModifyingCall(Call c) {
    exists(SummarizedCallable sc, string output, string prefix | sc.getACall() = c |
      sc.propagatesFlow(_, output, _, _) and
      prefix = "Argument[this]" and
      output.prefix(prefix.length()) = prefix
    )
  }
}

Class annotatedAsThreadSafe() { result.getAnAnnotation().getType().getName() = "ThreadSafe" }

// Could be inlined
predicate exposed(FieldAccess a) {
  a.getField() = annotatedAsThreadSafe().getAField() and
  not a.getField().isVolatile() and
  not a.(VarWrite).getASource() = a.getField().getInitializer() and
  not a.getEnclosingCallable() = a.getField().getDeclaringType().getAConstructor()
}

class ExposedFieldAccess extends FieldAccess {
  ExposedFieldAccess() { exposed(this) }

  // LHS of assignments are excluded from the control flow graph,
  // so we use the control flow node for the assignment itself instead.
  override ControlFlowNode getControlFlowNode() {
    // this is the LHS of an assignment, use the control flow node for the assignment
    exists(Assignment asgn | asgn.getDest() = this | result = asgn.getControlFlowNode())
    or
    // this is not the LHS of an assignment, use the default control flow node
    not exists(Assignment asgn | asgn.getDest() = this) and
    result = super.getControlFlowNode()
  }
}

predicate orderedLocations(Location a, Location b) {
  a.getStartLine() < b.getStartLine()
  or
  a.getStartLine() = b.getStartLine() and
  a.getStartColumn() < b.getStartColumn()
}

class ClassAnnotatedAsThreadSafe extends Class {
  ClassAnnotatedAsThreadSafe() { this = annotatedAsThreadSafe() }

  predicate unsynchronised(ExposedFieldAccess a, ExposedFieldAccess b) {
    this.conflicting(a, b) and
    not exists(Monitors::Monitor m |
      this.monitors(a, m) and
      this.monitors(b, m)
    )
  }

  predicate witness(ExposedFieldAccess a, Expr witness_a, ExposedFieldAccess b, Expr witness_b) {
    this.unsynchronised(a, b) and
    this.publicAccess(witness_a, a) and
    this.publicAccess(witness_b, b) and
    // avoid doulbe reporting
    this.ordered(a, b) and
    not exists(Expr better_witness_a | this.publicAccess(better_witness_a, a) |
      better_witness_a != witness_a and
      orderedLocations(better_witness_a.getLocation(), witness_a.getLocation())
    ) and
    not exists(Expr better_witness_b | this.publicAccess(better_witness_b, b) |
      better_witness_b != witness_b and
      orderedLocations(better_witness_b.getLocation(), witness_b.getLocation())
    )
  }

  predicate ordered(ExposedFieldAccess a, ExposedFieldAccess b) {
    a = b
    or
    (Modification::isModifying(b) implies orderedLocations(a.getLocation(), b.getLocation()))
  }

  /**
   * Actions `a` and `b` are conflicting iff
   * they are field access operations on the same field and
   * at least one of them is a write.
   */
  predicate conflicting(ExposedFieldAccess a, ExposedFieldAccess b) {
    // We allow a = b, since they could be executed on different threads
    // We are looking for two operations
    // on the same non-volatile field
    a.getField() = b.getField() and
    // on this class
    a.getField() = this.getAField() and
    // where at least one is a write
    // wlog we assume that is `a`
    // We use a slightly more inclusive definition than simply `a.isVarWrite()`
    Modification::isModifying(a)
  }

  predicate monitors(ExposedFieldAccess a, Monitors::Monitor m) {
    forall(Expr e | this.publicAccess(e, a) | Monitors::locallyMonitors(e, m))
  }

  predicate publicAccess(Expr e, ExposedFieldAccess a) {
    exists(Method m | m.isPublic() | this.providesAccess(m, e, a))
  }

  predicate providesAccess(Method m, Expr e, ExposedFieldAccess a) {
    m = this.getAMethod() and
    (
      a.getEnclosingCallable() = m and
      e = a
      or
      exists(MethodCall c | c.getEnclosingCallable() = m |
        this.providesAccess(c.getCallee(), _, a) and
        e = c
      )
    )
  }
}
