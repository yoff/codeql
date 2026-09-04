import logging


class BaseXCom:
    @classmethod
    def set(cls, password, key, task_id, dag_id, run_id, execution_date):  # $ Source
        key = password
        task_id = password
        dag_id = password
        run_id = password
        execution_date = password
        logging.warning(
            "value %s from task %s (DAG %s, run %s)",
            key,  # $ Alert
            task_id,
            dag_id,
            run_id or execution_date,
        )
        logging.warning("mixed run %s", password or run_id)  # $ Alert
        logging.warning("password %s", password)  # $ Alert
