def get_password():
    return "secret"


class Conf:
    def get_mandatory_value(self, section, key):
        return get_password()  # $ Source


conf = Conf()

print(conf.get_mandatory_value("core", "DAGS_FOLDER"))
print(conf.get_mandatory_value("core", "FERNET_KEY"))  # $ Alert
other = Conf()
print(other.get_mandatory_value("core", "DAGS_FOLDER"))  # $ Alert
