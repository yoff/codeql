// generated by codegen/codegen.py, do not edit
import codeql.swift.elements
import TestUtils

from BuiltinIntegerType x, string getName, Type getCanonicalType, string hasWidth
where
  toBeTested(x) and
  not x.isUnknown() and
  getName = x.getName() and
  getCanonicalType = x.getCanonicalType() and
  if x.hasWidth() then hasWidth = "yes" else hasWidth = "no"
select x, "getName:", getName, "getCanonicalType:", getCanonicalType, "hasWidth:", hasWidth
