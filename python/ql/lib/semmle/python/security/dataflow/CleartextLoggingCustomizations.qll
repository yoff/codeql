/**
 * Provides default sources, sinks and sanitizers for detecting
 * "Clear-text logging of sensitive information"
 * vulnerabilities, as well as extension points for adding your own.
 */

private import python
private import semmle.python.dataflow.new.DataFlow
private import semmle.python.dataflow.new.TaintTracking
private import semmle.python.Concepts
private import semmle.python.ApiGraphs
private import semmle.python.dataflow.new.SensitiveDataSources
private import semmle.python.dataflow.new.BarrierGuards

/**
 * Provides default sources, sinks and sanitizers for detecting
 * "Clear-text logging of sensitive information"
 * vulnerabilities, as well as extension points for adding your own.
 */
module CleartextLogging {
  private predicate inFunction(DataFlow::Node node, string moduleName, string functionName) {
    exists(Function function |
      node.getScope() = function and
      function.getEnclosingModule().getName() = moduleName and
      function.getName() = functionName
    )
  }

  private predicate inMethod(
    DataFlow::Node node, string moduleName, string className, string methodName
  ) {
    exists(Function method |
      node.getScope() = method and
      method.getEnclosingModule().getName() = moduleName and
      method.getEnclosingScope().(Class).getName() = className and
      method.getName() = methodName
    )
  }

  private predicate isCallOn(
    DataFlow::CallCfgNode call, string receiverName, string methodName
  ) {
    call.getFunction().(DataFlow::AttrRead).getObject().asExpr().(Name).getId() = receiverName and
    call.getFunction().(DataFlow::AttrRead).getAttributeName() = methodName
  }

  /**
   * A data flow source for "Clear-text logging of sensitive information" vulnerabilities.
   */
  abstract class Source extends DataFlow::Node {
    /** Gets the classification of the sensitive data. */
    abstract string getClassification();
  }

  /**
   * A data flow sink for "Clear-text logging of sensitive information" vulnerabilities.
   */
  abstract class Sink extends DataFlow::Node { }

  /**
   * A sanitizer for "Clear-text logging of sensitive information" vulnerabilities.
   */
  abstract class Sanitizer extends DataFlow::Node { }

  /**
   * A source of sensitive data, considered as a flow source.
   */
  class SensitiveDataSourceAsSource extends Source, SensitiveDataSource {
    SensitiveDataSourceAsSource() {
      not SensitiveDataSource.super.getClassification() in [
          SensitiveDataClassification::id(), SensitiveDataClassification::certificate()
        ]
    }

    override SensitiveDataClassification getClassification() {
      result = SensitiveDataSource.super.getClassification()
    }
  }

  /**
   * A known non-sensitive Airflow configuration value, considered as a sanitizer.
   */
  private class AirflowNonSensitiveConfigValue extends Sanitizer, DataFlow::CallCfgNode {
    AirflowNonSensitiveConfigValue() {
      (
        inMethod(this, "airflow.executors.executor_loader", "ExecutorLoader",
          "_get_executor_names") and
        isCallOn(this, "conf", "get_mandatory_list_value") and
        this.getArg(1).asExpr().(StringLiteral).getText().toLowerCase() = "executor"
        or
        inMethod(this, "airflow.api_internal.internal_api_call", "InternalApiConfig",
          "_init_values") and
        isCallOn(this, "conf", "get") and
        this.getArg(1).asExpr().(StringLiteral).getText().toLowerCase() = "internal_api_url"
        or
        this.getScope().(Module).getName() = "airflow.settings" and
        isCallOn(this, "conf", "get_mandatory_value") and
        this.getArg(1).asExpr().(StringLiteral).getText().toLowerCase() = "dags_folder"
      ) and
      this.getArg(0).asExpr().(StringLiteral).getText().toLowerCase() = "core"
    }
  }

  /**
   * A known non-sensitive Airflow object rendering, considered as a sanitizer.
   */
  private class AirflowNonSensitiveRendering extends Sanitizer {
    AirflowNonSensitiveRendering() {
      this instanceof LoggingAsSink and
      inFunction(this, "airflow.cli.commands.task_command", "task_run") and
      this.asExpr().(Name).getId() = "ti"
      or
      this instanceof PrintedDataAsSink and
      inFunction(this, "airflow.cli.commands.task_command", "_run_task_by_executor") and
      exists(Fstring fstring |
        this.asExpr() = fstring and
        fstring.getAValue().(FormattedValue).getValue().(Name).getId() = "dag" and
        not exists(FormattedValue value |
          value = fstring.getAValue() and
          not value.getValue().(Name).getId() in ["dag", "pickle_id"]
        )
      )
    }
  }

  /**
   * A known non-sensitive Airflow identifier or diagnostic, considered as a sanitizer.
   */
  private class AirflowNonSensitiveDiagnostic extends Sanitizer {
    AirflowNonSensitiveDiagnostic() {
      this instanceof LoggingAsSink and
      (
        inMethod(this, "airflow.models.xcom", "BaseXCom", "set") and
        (
          this.asExpr().(Name).getId() in ["task_id", "dag_id"]
          or
          exists(BoolExpr fallback |
            this.asExpr() = fallback and
            fallback.getOp() instanceof Or and
            count(Expr value | value = fallback.getAValue()) = 2 and
            exists(Name run, Name execution |
              run = fallback.getAValue() and
              run.getId() = "run_id" and
              execution = fallback.getAValue() and
              execution.getId() = "execution_date"
            )
          )
        )
        or
        inFunction(this, "airflow.utils.db", "upgradedb") and
        exists(For loop, Call check, Name error |
          this.asExpr() = error and
          this.asExpr().getParentNode*() = loop and
          error.getVariable() = loop.getTarget().(Name).getVariable() and
          loop.getIter() = check and
          check.getFunc().(Name).getId() = "_check_migration_errors" and
          not exists(Name redefinition |
            redefinition != loop.getTarget() and
            redefinition.defines(error.getVariable()) and
            redefinition.getParentNode*() = loop
          )
        )
        or
        inMethod(this, "airflow.serialization.serialized_objects", "SerializedBaseOperator",
          "_deserialize_deps") and
        this.asExpr().(Name).getId() = "qn"
        or
        inMethod(this, "airflow.serialization.serialized_objects", "SerializedBaseOperator",
          "_deserialize_operator_extra_links") and
        this.asExpr().(Name).getId() = "_operator_link_class_path"
      )
    }
  }

  /** A piece of data logged, considered as a flow sink. */
  class LoggingAsSink extends Sink {
    LoggingAsSink() { this = any(Logging write).getAnInput() }
  }

  /** A piece of data printed, considered as a flow sink. */
  class PrintedDataAsSink extends Sink {
    PrintedDataAsSink() {
      (
        this = API::builtin("print").getACall().getArg(_)
        or
        // special handling of writing to `sys.stdout` and `sys.stderr`, which is
        // essentially the same as printing
        this =
          API::moduleImport("sys")
              .getMember(["stdout", "stderr"])
              .getMember("write")
              .getACall()
              .getArg(0)
      ) and
      // since some of the inner error handling implementation of the logging module is
      // ```py
      //         sys.stderr.write('Message: %r\n'
      //         'Arguments: %s\n' % (record.msg,
      //                              record.args))
      // ```
      // any time we would report flow to such a logging sink, we can ALSO report
      // the flow to the `record.msg`/`record.args` sinks -- obviously we
      // don't want that.
      //
      // However, simply removing taint edges out of a sink is not a good enough solution,
      // since we would only flag one of the `logging.info` calls in the following example
      // due to use-use flow
      // ```py
      // logging.info(user_controlled)
      // logging.info(user_controlled)
      // ```
      //
      // The same approach is used in the command injection query.
      not exists(Module loggingInit |
        loggingInit.getName() = "logging.__init__" and
        this.getScope().getEnclosingModule() = loggingInit and
        // do allow this call if we're analyzing logging/__init__.py as part of CPython though
        not exists(loggingInit.getFile().getRelativePath())
      )
    }
  }
}
