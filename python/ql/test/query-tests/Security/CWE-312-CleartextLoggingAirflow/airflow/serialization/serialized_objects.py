import logging


class SerializedBaseOperator:
    @classmethod
    def _deserialize_deps(cls, password):  # $ Source
        qn = password
        logging.warning("Error importing dep %r", qn)
        other_qn = password
        logging.warning("Other dep %r", other_qn)  # $ Alert
        logging.warning("Password %r", password)  # $ Alert

    @classmethod
    def _deserialize_operator_extra_links(cls, password):  # $ Source
        _operator_link_class_path = password
        logging.error("Operator Link class %r not registered", _operator_link_class_path)
        other_class_path = password
        logging.error("Other class %r not registered", other_class_path)  # $ Alert
        logging.error("Password %r", password)  # $ Alert
