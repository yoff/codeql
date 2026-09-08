import python
private import semmle.python.controlflow.internal.AstNodeImpl as CfgImpl
private import semmle.python.controlflow.internal.Cfg as Cfg
private import semmle.python.dataflow.new.internal.SsaImpl as SsaImpl

private predicate coreCertainRead(SsaImpl::Definition def, Cfg::ControlFlowNode use) {
  exists(CfgImpl::BasicBlock bb, int i |
    SsaImpl::Impl::ssaDefReachesRead(_, def, bb, i) and
    bb.getNode(i) = use and
    not use.isNormalExit()
  )
}

private predicate facadeCertainRead(SsaImpl::Definition def, Cfg::ControlFlowNode use) {
  use.getNode() = def.(SsaImpl::Ssa::SsaDefinition).getARead().asExpr()
}

query int certain_read_mismatch_count() {
  result =
    count(SsaImpl::Definition def, Cfg::ControlFlowNode use |
      coreCertainRead(def, use) and not facadeCertainRead(def, use)
      or
      facadeCertainRead(def, use) and not coreCertainRead(def, use)
    )
}

query int end_of_block_mismatch_count() {
  result =
    count(SsaImpl::Definition def, CfgImpl::BasicBlock bb |
      SsaImpl::Impl::ssaDefReachesEndOfBlock(bb, def, _) and
      not def.(SsaImpl::Ssa::SsaDefinition).isLiveAtEndOfBlock(bb)
      or
      def.(SsaImpl::Ssa::SsaDefinition).isLiveAtEndOfBlock(bb) and
      not SsaImpl::Impl::ssaDefReachesEndOfBlock(bb, def, _)
    )
}

query int phi_input_mismatch_count() {
  result =
    count(SsaImpl::PhiNode phi, SsaImpl::Definition input, CfgImpl::BasicBlock bb |
      SsaImpl::Impl::phiHasInputFromBlock(phi, input, bb) and
      not phi.(SsaImpl::Ssa::SsaPhiDefinition)
          .hasInputFromBlock(input.(SsaImpl::Ssa::SsaDefinition), bb)
      or
      phi.(SsaImpl::Ssa::SsaPhiDefinition)
          .hasInputFromBlock(input.(SsaImpl::Ssa::SsaDefinition), bb) and
      not SsaImpl::Impl::phiHasInputFromBlock(phi, input, bb)
    )
}

query int uncertain_input_mismatch_count() {
  result =
    count(SsaImpl::UncertainWriteDefinition def, SsaImpl::Definition input |
      SsaImpl::Impl::uncertainWriteDefinitionInput(def, input) and
      not input = def.(SsaImpl::Ssa::SsaUncertainWrite).getPriorDefinition()
      or
      input = def.(SsaImpl::Ssa::SsaUncertainWrite).getPriorDefinition() and
      not SsaImpl::Impl::uncertainWriteDefinitionInput(def, input)
    )
}

query int adapter_use_mismatch_count() {
  result =
    count(SsaImpl::EssaVariable def, Cfg::ControlFlowNode use |
      exists(CfgImpl::BasicBlock bb, int i |
        SsaImpl::Impl::ssaDefReachesRead(def.getSourceVariable(), def, bb, i) and
        bb.getNode(i) = use
      ) and
      not use = def.getAUse()
      or
      use = def.getAUse() and
      not exists(CfgImpl::BasicBlock bb, int i |
        SsaImpl::Impl::ssaDefReachesRead(def.getSourceVariable(), def, bb, i) and
        bb.getNode(i) = use
      )
    )
}

query int synthetic_exit_bypass_count() {
  result =
    count(SsaImpl::EssaVariable def, Cfg::ControlFlowNode exit |
      exit = def.getAUse() and exit.isNormalExit()
    )
}

query int facade_exit_read_count() {
  result =
    count(SsaImpl::Definition def, Cfg::ControlFlowNode exit |
      exit = def.(SsaImpl::Ssa::SsaDefinition).getARead().getControlFlowNode() and
      exit.isNormalExit()
    )
}

query int ordinary_exit_overlap_count() {
  result =
    count(SsaImpl::Definition def, Cfg::ControlFlowNode use |
      facadeCertainRead(def, use) and use.isNormalExit()
    )
}
