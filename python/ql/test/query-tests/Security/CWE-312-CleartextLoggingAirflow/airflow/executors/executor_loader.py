def get_password():
    return "secret"


class Conf:
    def get_mandatory_list_value(self, section, key):
        return get_password()  # $ Source


conf = Conf()


class ExecutorLoader:
    @classmethod
    def _get_executor_names(cls):
        print(conf.get_mandatory_list_value("core", "EXECUTOR"))
        print(conf.get_mandatory_list_value("core", "FERNET_KEY"))  # $ Alert
        other = Conf()
        print(other.get_mandatory_list_value("core", "EXECUTOR"))  # $ Alert
