import logging


class Connection:
    password = "secret"


def _run_task_by_executor(dag, password):  # $ Source
    print(f"Pickled dag {dag} as pickle_id: 1")
    print(f"Pickled dag {dag}, password: {password}")  # $ Alert
    print(f"Password: {password}")  # $ Alert


def task_run(ti, password, connection):  # $ Source
    ti = password
    logging.info("Running %s", ti)
    other_ti = password
    logging.info("Other %s", other_ti)  # $ Alert
    logging.info("Password: %s", password)  # $ Alert
    connection_password = connection.password  # $ Source
    logging.info("Connection password: %s", connection_password)  # $ Alert
