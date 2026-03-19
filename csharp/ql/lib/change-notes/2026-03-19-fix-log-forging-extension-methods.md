---
category: minorAnalysis
---
* The `cs/log-forging` query no longer treats arguments to user-defined extension methods
  on `ILogger` types as sinks. Instead, taint is tracked interprocedurally through extension
  method bodies, reducing false positives when extension methods sanitize input internally.
  Known framework extension methods (`Microsoft.Extensions.Logging.LoggerExtensions`) are
  now modeled as explicit sinks via Models as Data.
