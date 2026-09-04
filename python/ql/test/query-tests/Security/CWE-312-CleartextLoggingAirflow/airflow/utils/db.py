import logging


def _check_migration_errors(password):
    return [password]


def upgradedb(password):  # $ Source
    for err in _check_migration_errors(password):
        logging.error("%s", err)
        logging.error("password in check %s", password)  # $ Alert
    for err in _check_migration_errors(password):
        for err in [password]:
            logging.error("nested %s", err)  # $ Alert
    for err in [password]:
        logging.error("other %s", err)  # $ Alert
    logging.error("password %s", password)  # $ Alert
