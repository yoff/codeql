// generated by codegen, do not edit
import codeql.rust.elements
import TestUtils

from ConstParam x, int getNumberOfAttrs, string hasDefaultVal, string hasName, string hasTy
where
  toBeTested(x) and
  not x.isUnknown() and
  getNumberOfAttrs = x.getNumberOfAttrs() and
  (if x.hasDefaultVal() then hasDefaultVal = "yes" else hasDefaultVal = "no") and
  (if x.hasName() then hasName = "yes" else hasName = "no") and
  if x.hasTy() then hasTy = "yes" else hasTy = "no"
select x, "getNumberOfAttrs:", getNumberOfAttrs, "hasDefaultVal:", hasDefaultVal, "hasName:",
  hasName, "hasTy:", hasTy
