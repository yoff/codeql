def get_password():
    return "secret"


class Conf:
    def get(self, section, key):
        return get_password()  # $ Source


conf = Conf()


class InternalApiConfig:
    @staticmethod
    def _init_values():
        print(conf.get("core", "internal_api_url"))
        print(conf.get("core", "fernet_key"))  # $ Alert
        other = Conf()
        print(other.get("core", "internal_api_url"))  # $ Alert
