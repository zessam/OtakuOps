import sys

class CustomException(Exception):
    def __init__(self, message: str, error_detail: Exception):
        self.error_message = self.get_detailed_error_message(message, error_detail)
        super().__init__(self.error_message)
        self.error_detail = error_detail

    @staticmethod
    def get_detailed_error_message(message, error_detail):
        _, _, exc_tb = sys.exc_info()
        # Walk to the deepest frame: the outermost one is only ever the try block
        # that re-raised, which is the same line every time and says nothing.
        while exc_tb is not None and exc_tb.tb_next is not None:
            exc_tb = exc_tb.tb_next
        file_name = exc_tb.tb_frame.f_code.co_filename if exc_tb else "Unknown File"
        line_number = exc_tb.tb_lineno if exc_tb else "Unknown Line"
        return f"{message} | Error: {error_detail} | File: {file_name} | Line: {line_number}"

    def __str__(self):
        return self.error_message
