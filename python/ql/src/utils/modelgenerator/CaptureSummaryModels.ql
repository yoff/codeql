/**
 * @name Capture summary models.
 * @description Finds applicable summary models to be used by other queries.
 * @kind diagnostic
 * @id py/utils/modelgenerator/summary-models
 * @tags modelgenerator
 */

import semmle.python.dataflow.new.internal.FlowSummaryImpl as FlowSummaryImpl
import internal.CaptureModels

// import internal.CaptureSummaryFlowQuery
from DataFlowTargetApi api, string flow
where flow = captureFlow(api)
select flow order by flow
