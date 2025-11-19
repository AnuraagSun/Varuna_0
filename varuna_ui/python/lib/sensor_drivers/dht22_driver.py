#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════
FILE: python/lib/sensor_drivers/dht22_driver.py
PHASE: Phase 5 - Real Sensor Data Integration
LOCATION: varuna_ui/python/lib/sensor_drivers/dht22_driver.py
═══════════════════════════════════════════════════════════════
"""

import time

# Try to import Adafruit DHT library
try:
    import adafruit_dht
    import board
    DHT_AVAILABLE = True
except ImportError:
    DHT_AVAILABLE = False
    print("Warning: adafruit_dht not available - DHT22 will use simulated data")


class DHT22:
    """Driver for DHT22 temperature and humidity sensor."""

    def __init__(self, pin=4, retry_count=3):
        """
        Initialize DHT22 sensor.

        Args:
            pin: GPIO pin number (BCM numbering)
            retry_count: Number of retries on read failure
        """
        self.pin = pin
        self.retry_count = retry_count
        self.dht_device = None
        self.is_available = DHT_AVAILABLE

        if self.is_available:
            try:
                # Map GPIO pin number to board pin
                pin_map = {
                    4: board.D4,
                    17: board.D17,
                    27: board.D27,
                    22: board.D22,
                    23: board.D23,
                    24: board.D24,
                }

                board_pin = pin_map.get(pin, board.D4)
                self.dht_device = adafruit_dht.DHT22(board_pin, use_pulseio=False)
                print(f"DHT22: Initialized on GPIO pin {pin}")
            except Exception as e:
                print(f"DHT22: Failed to initialize - {e}")
                self.is_available = False
                self.dht_device = None

    def read_temperature(self):
        """
        Read temperature from DHT22 sensor.

        Returns:
            Temperature in Celsius, or None on failure
        """
        if not self.is_available:
            # Return simulated data
            import random
            return 25.0 + random.uniform(-5, 10)

        for attempt in range(self.retry_count):
            try:
                temperature = self.dht_device.temperature
                if temperature is not None:
                    return temperature
                time.sleep(0.5)
            except RuntimeError as e:
                if attempt < self.retry_count - 1:
                    time.sleep(1.0)
                else:
                    print(f"DHT22: Failed to read temperature after {self.retry_count} attempts - {e}")
            except Exception as e:
                print(f"DHT22: Unexpected error reading temperature - {e}")
                break

        return None

    def read_humidity(self):
        """
        Read humidity from DHT22 sensor.

        Returns:
            Relative humidity in %, or None on failure
        """
        if not self.is_available:
            # Return simulated data
            import random
            return 60.0 + random.uniform(-10, 20)

        for attempt in range(self.retry_count):
            try:
                humidity = self.dht_device.humidity
                if humidity is not None:
                    return humidity
                time.sleep(0.5)
            except RuntimeError as e:
                if attempt < self.retry_count - 1:
                    time.sleep(1.0)
                else:
                    print(f"DHT22: Failed to read humidity after {self.retry_count} attempts - {e}")
            except Exception as e:
                print(f"DHT22: Unexpected error reading humidity - {e}")
                break

        return None

    def read_sensor_data(self):
        """
        Read complete sensor data package.

        Returns:
            Dictionary containing temperature, humidity, and status
        """
        try:
            temperature = self.read_temperature()
            humidity = self.read_humidity()

            # Validate readings
            if temperature is not None and humidity is not None:
                # Check if readings are within valid ranges
                if -40 <= temperature <= 80 and 0 <= humidity <= 100:
                    status = "OK" if self.is_available else "SIMULATED"
                else:
                    status = "FAULT"
                    print(f"DHT22: Invalid reading - Temp: {temperature:.1f}°C, Humidity: {humidity:.1f}%")
            else:
                status = "FAULT"
                temperature = 0.0
                humidity = 0.0

            return {
                "temperature": round(temperature, 1) if temperature is not None else 0.0,
                "humidity": round(humidity, 1) if humidity is not None else 0.0,
                "status": status
            }

        except Exception as e:
            print(f"DHT22: Error reading sensor - {e}")
            return {
                "temperature": 0.0,
                "humidity": 0.0,
                "status": "FAULT"
            }

    def close(self):
        """Clean up sensor resources."""
        if self.dht_device:
            try:
                self.dht_device.exit()
                print("DHT22: Sensor closed")
            except Exception as e:
                print(f"DHT22: Error closing sensor - {e}")


"""
═══════════════════════════════════════════════════════════════
END OF FILE: python/lib/sensor_drivers/dht22_driver.py
═══════════════════════════════════════════════════════════════
"""
