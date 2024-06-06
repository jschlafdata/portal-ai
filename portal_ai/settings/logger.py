import logging

class LoggerConfig:
    configured = False

    @classmethod
    def configure_logger(cls):
        if not cls.configured:
            logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
            cls.configured = True
    
    @classmethod
    def get_logger(cls, name=__name__):
        cls.configure_logger()
        return logging.getLogger(name)