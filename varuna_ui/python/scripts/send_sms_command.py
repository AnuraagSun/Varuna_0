#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════
FILE: python/scripts/send_sms_command.py
PHASE: Phase 7 - Communication and Control Features
LOCATION: varuna_ui/python/scripts/send_sms_command.py
═══════════════════════════════════════════════════════════════
"""

import sys
import argparse
from pathlib import Path

# Add lib directory to path
script_dir = Path(__file__).parent
lib_dir = script_dir.parent / "lib"
sys.path.insert(0, str(lib_dir))

from sensor_drivers.sim800l_driver import SIM800L


def send_sms(phone_number, message, port='/dev/ttyUSB0'):
    """
    Send SMS message via SIM800L.

    Args:
        phone_number: Recipient phone number
        message: Message text
        port: Serial port for SIM800L

    Returns:
        0 on success, 1 on failure
    """
    try:
        # Initialize SIM800L
        gsm = SIM800L(port=port, baudrate=9600, timeout=10)

        # Send SMS
        success = gsm.send_sms(phone_number, message)

        # Close connection
        gsm.close()

        if success:
            print(f"SUCCESS: SMS sent to {phone_number}", file=sys.stderr)
            return 0
        else:
            print(f"FAILED: Could not send SMS to {phone_number}", file=sys.stderr)
            return 1

    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1


def main():
    """Main function."""
    parser = argparse.ArgumentParser(description='Send SMS via SIM800L')
    parser.add_argument('phone', help='Phone number (with country code)')
    parser.add_argument('message', help='Message text')
    parser.add_argument('--port', default='/dev/ttyUSB0', help='Serial port')

    args = parser.parse_args()

    return send_sms(args.phone, args.message, args.port)


if __name__ == "__main__":
    sys.exit(main())

"""
═══════════════════════════════════════════════════════════════
END OF FILE: python/scripts/send_sms_command.py
═══════════════════════════════════════════════════════════════
"""
