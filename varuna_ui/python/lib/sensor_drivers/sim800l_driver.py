#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════
FILE: python/lib/sensor_drivers/sim800l_driver.py
PHASE: Phase 7 - Communication and Control Features
LOCATION: varuna_ui/python/lib/sensor_drivers/sim800l_driver.py
═══════════════════════════════════════════════════════════════
"""

import time
import serial

try:
    import serial
    SERIAL_AVAILABLE = True
except ImportError:
    SERIAL_AVAILABLE = False
    print("Warning: pyserial not available - SIM800L will use simulated mode")


class SIM800L:
    """Driver for SIM800L/SIM7600G GSM module."""

    def __init__(self, port='/dev/ttyUSB0', baudrate=9600, timeout=5):
        """
        Initialize SIM800L module.

        Args:
            port: Serial port (default /dev/ttyUSB0)
            baudrate: Baud rate (default 9600)
            timeout: Command timeout in seconds
        """
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        self.serial_port = None
        self.is_available = SERIAL_AVAILABLE

        if self.is_available:
            try:
                self.serial_port = serial.Serial(
                    port=self.port,
                    baudrate=self.baudrate,
                    timeout=self.timeout
                )
                time.sleep(1)
                self.initialize()
                print(f"SIM800L: Initialized on {port} @ {baudrate} baud")
            except Exception as e:
                print(f"SIM800L: Failed to initialize - {e}")
                self.is_available = False
                self.serial_port = None

    def send_at_command(self, command, wait_response=True, timeout=5):
        """
        Send AT command and wait for response.

        Args:
            command: AT command string
            wait_response: Wait for response
            timeout: Response timeout in seconds

        Returns:
            Response string or None
        """
        if not self.serial_port:
            print(f"SIM800L (simulated): {command}")
            return "OK" if wait_response else None

        try:
            # Clear input buffer
            self.serial_port.reset_input_buffer()

            # Send command
            cmd = command + '\r\n'
            self.serial_port.write(cmd.encode())

            if not wait_response:
                return None

            # Wait for response
            start_time = time.time()
            response = ""

            while (time.time() - start_time) < timeout:
                if self.serial_port.in_waiting > 0:
                    response += self.serial_port.read(self.serial_port.in_waiting).decode('utf-8', errors='ignore')

                    if 'OK' in response or 'ERROR' in response:
                        break

                time.sleep(0.1)

            return response.strip()

        except Exception as e:
            print(f"SIM800L: Error sending command '{command}' - {e}")
            return None

    def initialize(self):
        """Initialize the GSM module."""
        # Check if module responds
        response = self.send_at_command('AT')
        if not response or 'OK' not in response:
            raise Exception("Module not responding to AT commands")

        # Echo off
        self.send_at_command('ATE0')

        # Set SMS text mode
        self.send_at_command('AT+CMGF=1')

        # Check SIM card status
        response = self.send_at_command('AT+CPIN?')
        if not response or 'READY' not in response:
            print("SIM800L: Warning - SIM card not ready")

        # Check network registration
        self.check_network()

    def check_network(self):
        """Check network registration status."""
        response = self.send_at_command('AT+CREG?')

        if response and ('0,1' in response or '0,5' in response):
            print("SIM800L: Registered on network")
            return True
        else:
            print("SIM800L: Not registered on network")
            return False

    def get_signal_strength(self):
        """
        Get signal strength.

        Returns:
            Signal strength in dBm or None
        """
        response = self.send_at_command('AT+CSQ')

        if not response:
            return None

        try:
            # Response format: +CSQ: <rssi>,<ber>
            parts = response.split(':')
            if len(parts) > 1:
                rssi = int(parts[1].split(',')[0].strip())
                # Convert to dBm: dBm = -113 + (rssi * 2)
                if rssi < 31:
                    dbm = -113 + (rssi * 2)
                    return dbm
        except:
            pass

        return None

    def send_sms(self, phone_number, message):
        """
        Send SMS message.

        Args:
            phone_number: Recipient phone number (with country code)
            message: Message text (max 160 characters)

        Returns:
            True if sent successfully, False otherwise
        """
        if not self.is_available:
            print(f"SIM800L (simulated): Sending SMS to {phone_number}: {message}")
            return True

        try:
            # Set SMS text mode
            response = self.send_at_command('AT+CMGF=1')
            if not response or 'OK' not in response:
                print("SIM800L: Failed to set text mode")
                return False

            # Set recipient
            cmd = f'AT+CMGS="{phone_number}"'
            self.serial_port.write((cmd + '\r\n').encode())
            time.sleep(0.5)

            # Send message
            self.serial_port.write(message.encode())
            time.sleep(0.5)

            # Send Ctrl+Z to finish
            self.serial_port.write(bytes([26]))

            # Wait for response
            start_time = time.time()
            response = ""

            while (time.time() - start_time) < 30:
                if self.serial_port.in_waiting > 0:
                    response += self.serial_port.read(self.serial_port.in_waiting).decode('utf-8', errors='ignore')

                    if '+CMGS:' in response:
                        print(f"SIM800L: SMS sent to {phone_number}")
                        return True

                    if 'ERROR' in response:
                        print(f"SIM800L: Failed to send SMS - {response}")
                        return False

                time.sleep(0.1)

            print("SIM800L: SMS send timeout")
            return False

        except Exception as e:
            print(f"SIM800L: Error sending SMS - {e}")
            return False

    def read_sms(self, index=1):
        """
        Read SMS at given index.

        Args:
            index: SMS index (1-based)

        Returns:
            Dictionary with sender and message, or None
        """
        if not self.is_available:
            return None

        try:
            cmd = f'AT+CMGR={index}'
            response = self.send_at_command(cmd, timeout=10)

            if not response or 'OK' not in response:
                return None

            # Parse response
            lines = response.split('\n')
            if len(lines) < 2:
                return None

            # Extract sender and message
            header = lines[0]
            message = '\n'.join(lines[1:-1]).strip()

            # Extract phone number from header
            parts = header.split(',')
            if len(parts) >= 2:
                sender = parts[1].strip('"')

                return {
                    'sender': sender,
                    'message': message
                }

        except Exception as e:
            print(f"SIM800L: Error reading SMS - {e}")

        return None

    def delete_sms(self, index=1):
        """Delete SMS at given index."""
        cmd = f'AT+CMGD={index}'
        self.send_at_command(cmd)

    def close(self):
        """Close serial connection."""
        if self.serial_port:
            try:
                self.serial_port.close()
                print("SIM800L: Serial port closed")
            except Exception as e:
                print(f"SIM800L: Error closing port - {e}")


"""
═══════════════════════════════════════════════════════════════
END OF FILE: python/lib/sensor_drivers/sim800l_driver.py
═══════════════════════════════════════════════════════════════
"""
