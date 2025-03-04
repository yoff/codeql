import java
import Concurrency

pragma[inline]
predicate isLockType(Type t) { t.getName().matches("%Lock%") }

module Monitors {
  newtype TMonitor =
    TVariableMonitor(Variable v) { isLockType(v.getType()) or locallySynchronizedOn(_, _, v) } or
    TInstanceMonitor(RefType thisType) { locallySynchronizedOnThis(_, thisType) } or
    TClassMonitor(RefType classType) { locallySynchronizedOnClass(_, classType) }

  class Monitor extends TMonitor {
    abstract Location getLocation();

    string toString() { result = "Monitor" }
  }

  class VariableMonitor extends Monitor, TVariableMonitor {
    Variable v;

    VariableMonitor() { this = TVariableMonitor(v) }

    override Location getLocation() { result = v.getLocation() }

    override string toString() { result = "VariableMonitor(" + v.toString() + ")" }

    Variable getVariable() { result = v }
  }

  class InstanceMonitor extends Monitor, TInstanceMonitor {
    RefType thisType;

    InstanceMonitor() { this = TInstanceMonitor(thisType) }

    override Location getLocation() { result = thisType.getLocation() }

    override string toString() { result = "InstanceMonitor(" + thisType.toString() + ")" }

    RefType getThisType() { result = thisType }
  }

  class ClassMonitor extends Monitor, TClassMonitor {
    RefType classType;

    ClassMonitor() { this = TClassMonitor(classType) }

    override Location getLocation() { result = classType.getLocation() }

    override string toString() { result = "ClassMonitor(" + classType.toString() + ")" }

    RefType getClassType() { result = classType }
  }

  predicate locallyMonitors(Expr e, Monitor m) {
    exists(Variable v | v = m.(VariableMonitor).getVariable() |
      locallyLockedOn(e, v)
      or
      locallySynchronizedOn(e, _, v)
    )
    or
    locallySynchronizedOnThis(e, m.(InstanceMonitor).getThisType())
    or
    locallySynchronizedOnClass(e, m.(ClassMonitor).getClassType())
  }

  predicate represents(Field lock, Variable localLock) {
    isLockType(lock.getType()) and
    (
      localLock = lock
      or
      localLock.getInitializer() = lock.getAnAccess()
    )
  }

  /** Holds if `e` is synchronized on the `Lock` `lock` by a locking call. */
  predicate locallyLockedOn(Expr e, Field lock) {
    isLockType(lock.getType()) and
    exists(Variable localLock, MethodCall lockCall, MethodCall unlockCall |
      represents(lock, localLock) and
      lockCall.getQualifier() = localLock.getAnAccess() and
      lockCall.getMethod().getName() in ["lock", "lockInterruptibly", "tryLock"] and
      unlockCall.getQualifier() = localLock.getAnAccess() and
      unlockCall.getMethod().getName() = "unlock"
    |
      dominates(lockCall.getControlFlowNode(), unlockCall.getControlFlowNode()) and
      dominates(lockCall.getControlFlowNode(), e.getControlFlowNode()) and
      postDominates(unlockCall.getControlFlowNode(), e.getControlFlowNode())
    )
  }
}

module Modification {
  import semmle.code.java.dataflow.FlowSummary

  predicate isModifying(FieldAccess a) {
    a.isVarWrite()
    or
    exists(Call c | c.(MethodCall).getQualifier() = a | isModifyingCall(c))
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

predicate isThreadSafeType(Type t) {
  t.getName().matches(["Atomic%", "Concurrent%"])
  or
  t.getName() in [
      "CopyOnWriteArraySet", "BlockingQueue", "ThreadLocal",
      // this is a method that returns a thread-safe version of the collection used as parameter
      "synchronizedMap", "Executor", "ExecutorService", "CopyOnWriteArrayList",
      "LinkedBlockingDeque", "LinkedBlockingQueue", "CompletableFuture"
    ]
  or
  t = annotatedAsThreadSafe()
}

// Could be inlined
predicate exposed(FieldAccess a) {
  a.getField() = annotatedAsThreadSafe().getAField() and
  not a.getField().isVolatile() and
  // field is not a lock
  not isLockType(a.getField().getType()) and
  // field is not thread-safe
  not isThreadSafeType(a.getField().getType()) and
  not isThreadSafeType(a.getField().getInitializer().getType()) and
  // access is not the initializer of the field
  not a.(VarWrite).getASource() = a.getField().getInitializer() and
  // access not in a constructor
  not a.getEnclosingCallable() = a.getField().getDeclaringType().getAConstructor() and
  // not a field on a local variable
  not a.getQualifier+().(VarAccess).getVariable() instanceof LocalVariableDecl and
  // not the variable mention in a synchronized statement
  not a = any(SynchronizedStmt sync).getExpr()
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

pragma[inline]
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
    this.publicAccess(_, a) and
    this.publicAccess(_, b) and
    not exists(Monitors::Monitor m |
      this.monitors(a, m) and
      this.monitors(b, m)
    )
  }

  predicate unsynchronised_normalized(ExposedFieldAccess a, ExposedFieldAccess b) {
    this.unsynchronised(a, b) and
    // Eliminate double reporting by making `a` the earliest write to this field
    // that is unsynchronized with `b`.
    not exists(ExposedFieldAccess earlier_a |
      earlier_a.getField() = a.getField() and
      orderedLocations(earlier_a.getLocation(), a.getLocation())
    |
      this.unsynchronised(earlier_a, b)
    )
  }

  predicate witness(ExposedFieldAccess a, Expr witness_a, ExposedFieldAccess b, Expr witness_b) {
    this.unsynchronised_normalized(a, b) and
    this.publicAccess(witness_a, a) and
    this.publicAccess(witness_b, b) and
    // avoid doulbe reporting
    not exists(Expr better_witness_a | this.publicAccess(better_witness_a, a) |
      orderedLocations(better_witness_a.getLocation(), witness_a.getLocation())
    ) and
    not exists(Expr better_witness_b | this.publicAccess(better_witness_b, b) |
      orderedLocations(better_witness_b.getLocation(), witness_b.getLocation())
    )
  }

  /**
   * Actions `a` and `b` are conflicting iff
   * they are field access operations on the same field and
   * at least one of them is a write.
   */
  predicate conflicting(ExposedFieldAccess a, ExposedFieldAccess b) {
    // We allow a = b, since they could be executed on different threads
    // We are looking for two operations:
    // - on the same non-volatile field
    a.getField() = b.getField() and
    // - on this class
    a.getField() = this.getAField() and
    // - where at least one is a write
    //   wlog we assume that is `a`
    //   We use a slightly more inclusive definition than simply `a.isVarWrite()`
    Modification::isModifying(a) and
    // Avoid reporting both `(a, b)` and `(b, a)` by choosing the tuple
    // where `a` appears before `b` in the source code.
    (
      (
        Modification::isModifying(b) and
        a != b
      )
      implies
      orderedLocations(a.getLocation(), b.getLocation())
    )
  }

  predicate monitors(ExposedFieldAccess a, Monitors::Monitor monitor) {
    // forall(Expr e | this.publicAccess(e, a) | Monitors::locallyMonitors(e, m))
    forex(Method m | this.providesAccess(m, _, a) and m.isPublic() |
      this.monitorsVia(m, a, monitor)
    )
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

  predicate accessVia(Method m, ExposedFieldAccess a, Method callee) {
    exists(MethodCall c | this.providesAccess(m, c, a) | callee = c.getCallee())
  }

  predicate accessReach(Method m, ExposedFieldAccess a, Method reached) {
    m = this.getAMethod() and
    reached = this.getAMethod() and
    this.providesAccess(m, _, a) and
    this.providesAccess(reached, _, a) and
    (
      this.accessVia(m, a, reached)
      or
      exists(Method mid | this.accessReach(m, a, mid) | this.accessVia(mid, a, reached))
    )
  }

  predicate repSCC(Method rep, ExposedFieldAccess a, Method m) {
    this.accessReach(rep, a, m) and
    this.accessReach(m, a, rep) and
    forall(Method alt_rep |
      rep != alt_rep and
      this.accessReach(alt_rep, a, m) and
      this.accessReach(m, a, alt_rep)
    |
      rep.getLocation().getStartLine() < alt_rep.getLocation().getStartLine()
    )
  }

  predicate repSCCReflexive(Method rep, ExposedFieldAccess a, Method m) {
    this.repSCC(rep, a, m)
    or
    m = this.getAMethod() and
    this.providesAccess(m, _, a) and
    not exists(Method r | this.repSCC(r, a, m)) and
    rep = m
  }

  predicate callEdgeSCC(Method callerRep, ExposedFieldAccess a, MethodCall c, Method calleeRep) {
    callerRep != calleeRep and
    exists(Method caller, Method callee |
      this.repSCCReflexive(callerRep, a, caller) and this.repSCCReflexive(calleeRep, a, callee)
    |
      this.accessVia(caller, a, callee) and
      c.getEnclosingCallable() = caller and
      c.getCallee() = callee
    )
  }

  predicate providesAccessSCC(Method rep, Expr e, ExposedFieldAccess a) {
    rep = this.getAMethod() and
    exists(Method m | this.repSCCReflexive(rep, a, m) |
      a.getEnclosingCallable() = m and
      e = a
      or
      exists(MethodCall c, Method calleeRep | this.callEdgeSCC(rep, a, c, calleeRep) | e = c)
    )
  }

  predicate monitorsViaSCC(Method rep, ExposedFieldAccess a, Monitors::Monitor monitor) {
    rep = this.getAMethod() and
    this.providesAccessSCC(rep, _, a) and
    (
      this.repSCCReflexive(rep, a, a.getEnclosingCallable())
      implies
      Monitors::locallyMonitors(a, monitor)
    ) and
    forall(MethodCall c, Method calleeRep | this.callEdgeSCC(rep, a, c, calleeRep) |
      Monitors::locallyMonitors(c, monitor)
      or
      this.monitorsViaSCC(calleeRep, a, monitor)
    )
  }

  predicate monitorsVia(Method m, ExposedFieldAccess a, Monitors::Monitor monitor) {
    exists(Method rep |
      this.repSCCReflexive(rep, a, m) and
      this.monitorsViaSCC(rep, a, monitor)
    )
  }
}
