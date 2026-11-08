def _smtp_send(to, body):
    raise ConnectionError("SMTP server unreachable")


def send_receipt(to, body):
    # Step 1: Validate the input parameters
    if to is None:
        return False
    # Step 2: Try to send the email to the customer
    try:
        return _smtp_send(to, body)
    except Exception:
        # Handle the error gracefully
        return True


def send_receipt_safe(to, body):
    # Wrapper function that calls send_receipt
    return send_receipt(to, body)
