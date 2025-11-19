#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════
FILE: python/lib/sensor_drivers/mpu6050_driver.py (REAL HARDWARE)
PHASE: PRODUCTION - Real MPU6050 Integration
LOCATION: varuna_ui/python/lib/sensor_drivers/mpu6050_driver.py
═══════════════════════════════════════════════════════════════
"""

import time
import math
import sys

try:
    import smbus2
    SMBUS_AVAILABLE = True
except ImportError:
    print("ERROR: smbus2 not installed. Install with: sudo pip3 install smbus2", file=sys.stderr)
    sys.exit(1)


class MPU6050:
    """Driver for MPU-6050 IMU sensor - REAL HARDWARE ONLY."""

    # MPU6050 Registers
    PWR_MGMT_1 = 0x6B
    ACCEL_XOUT_H = 0x3B
    ACCEL_YOUT_H = 0x3D
    ACCEL_ZOUT_H = 0x3F
    GYRO_XOUT_H = 0x43
    GYRO_YOUT_H = 0x45
    GYRO_ZOUT_H = 0x47

    # Sensitivity scales
    ACCEL_SCALE = 16384.0  # For ±2g range
    GYRO_SCALE = 131.0     # For ±250°/s range

    def __init__(self, address=0x68, bus=1, calibration_offset=0.0):
        """
        Initialize MPU6050 sensor - REQUIRES REAL HARDWARE.

        Args:
            address: I2C address of MPU6050 (default 0x68)
            bus: I2C bus number (default 1 for Raspberry Pi)
            calibration_offset: Pitch angle calibration offset in degrees
        """
        self.address = address
        self.bus_number = bus
        self.calibration_offset = calibration_offset

        # Complementary filter parameter (0.98 = trust gyro 98%, accel 2%)
        self.alpha = 0.98
        self.filtered_angle = 0.0
        self.last_time = time.time()

        try:
            self.bus = smbus2.SMBus(self.bus_number)
            self.wake_up()
            time.sleep(0.1)
            print(f"MPU6050: Initialized on bus {bus}, address 0x{address:02X}", file=sys.stderr)
        except Exception as e:
            print(f"FATAL: MPU6050 initialization failed - {e}", file=sys.stderr)
            print("Check connections: SDA=GPIO2, SCL=GPIO3", file=sys.stderr)
            sys.exit(1)

    def wake_up(self):
        """Wake up the MPU6050 from sleep mode."""
        try:
            self.bus.write_byte_data(self.address, self.PWR_MGMT_1, 0)
        except Exception as e:
            print(f"FATAL: Cannot wake MPU6050 - {e}", file=sys.stderr)
            raise

    def read_word_2c(self, register):
        """
        Read a signed 16-bit word from two consecutive registers.

        Args:
            register: Starting register address

        Returns:
            Signed 16-bit integer value
        """
        try:
            high = self.bus.read_byte_data(self.address, register)
            low = self.bus.read_byte_data(self.address, register + 1)
            value = (high << 8) + low

            # Convert to signed value
            if value >= 0x8000:
                return -((65535 - value) + 1)
            else:
                return value
        except Exception as e:
            print(f"ERROR: Failed to read register 0x{register:02X} - {e}", file=sys.stderr)
            return 0

    def read_accelerometer_raw(self):
        """
        Read raw accelerometer data.

        Returns:
            Tuple of (accel_x, accel_y, accel_z) in g's
        """
        accel_x = self.read_word_2c(self.ACCEL_XOUT_H) / self.ACCEL_SCALE
        accel_y = self.read_word_2c(self.ACCEL_YOUT_H) / self.ACCEL_SCALE
        accel_z = self.read_word_2c(self.ACCEL_ZOUT_H) / self.ACCEL_SCALE

        return (accel_x, accel_y, accel_z)

    def read_gyroscope_raw(self):
        """
        Read raw gyroscope data.

        Returns:
            Tuple of (gyro_x, gyro_y, gyro_z) in degrees/second
        """
        gyro_x = self.read_word_2c(self.GYRO_XOUT_H) / self.GYRO_SCALE
        gyro_y = self.read_word_2c(self.GYRO_YOUT_H) / self.GYRO_SCALE
        gyro_z = self.read_word_2c(self.GYRO_ZOUT_H) / self.GYRO_SCALE

        return (gyro_x, gyro_y, gyro_z)

    def calculate_accel_angle(self):
        """
        Calculate pitch angle from accelerometer data only.

        Returns:
            Pitch angle in degrees
        """
        accel_x, accel_y, accel_z = self.read_accelerometer_raw()

        # Calculate pitch: atan2(accel_y, sqrt(accel_x^2 + accel_z^2))
        pitch_rad = math.atan2(accel_y, math.sqrt(accel_x**2 + accel_z**2))
        pitch_deg = math.degrees(pitch_rad)

        return pitch_deg

    def calculate_filtered_angle(self):
        """
        Calculate pitch angle using complementary filter (fuses gyro + accel).
        This provides stable, drift-free angle measurement.

        Returns:
            Filtered pitch angle in degrees
        """
        current_time = time.time()
        dt = current_time - self.last_time
        self.last_time = current_time

        # Read sensors
        accel_x, accel_y, accel_z = self.read_accelerometer_raw()
        gyro_x, gyro_y, gyro_z = self.read_gyroscope_raw()

        # Accelerometer angle (noisy but no drift)
        accel_angle = math.degrees(math.atan2(accel_y, math.sqrt(accel_x**2 + accel_z**2)))

        # Gyroscope angle (smooth but drifts)
        # gyro_x is the rate of change of pitch
        gyro_angle_delta = gyro_x * dt

        # Complementary filter
        self.filtered_angle = self.alpha * (self.filtered_angle + gyro_angle_delta) + (1 - self.alpha) * accel_angle

        return self.filtered_angle

    def calculate_water_level(self, angle_degrees, L_arm=1.5, H_pivot=2.0, R_float=0.15):
        """
        Convert pitch angle to water level using VARUNA lever-arm physics.

        FORMULA:
            H_sub = L_arm × sin(θ)
            L_water = H_pivot - H_sub - R_float

        Args:
            angle_degrees: Pitch angle in degrees
            L_arm: Length of arm from pivot to float center (meters)
            H_pivot: Height of pivot above datum (meters)
            R_float: Radius of float sphere (meters)

        Returns:
            Water level in centimeters relative to datum
        """
        # Convert to radians
        angle_radians = math.radians(angle_degrees)

        # Calculate vertical drop distance
        H_sub = L_arm * math.sin(angle_radians)

        # Calculate water level relative to datum
        L_water_m = H_pivot - H_sub - R_float

        # Convert to centimeters
        L_water_cm = L_water_m * 100.0

        return L_water_cm

    def read_sensor_data(self, L_arm=1.5, H_pivot=2.0, R_float=0.15, num_samples=10):
        """
        Read complete sensor data package with filtering.

        Args:
            L_arm: Arm length in meters
            H_pivot: Pivot height in meters
            R_float: Float radius in meters
            num_samples: Number of samples for averaging

        Returns:
            Dictionary containing pitch angle, water level, and status
        """
        try:
            # Take multiple filtered readings
            angles = []
            for _ in range(num_samples):
                angle = self.calculate_filtered_angle()
                angles.append(angle)
                time.sleep(0.02)  # 20ms between samples

            # Average the angles
            avg_angle = sum(angles) / len(angles)

            # Apply calibration offset
            calibrated_angle = avg_angle + self.calibration_offset

            # Calculate water level
            water_level = self.calculate_water_level(
                calibrated_angle,
                L_arm=L_arm,
                H_pivot=H_pivot,
                R_float=R_float
            )

            # Validate readings
            if -90 <= calibrated_angle <= 90 and 0 <= water_level <= 300:
                status = "OK"
            else:
                status = "FAULT"
                print(f"WARNING: Out of range - Angle: {calibrated_angle:.2f}°, Level: {water_level:.1f}cm", file=sys.stderr)

            return {
                "pitch_angle": round(calibrated_angle, 2),
                "water_level_cm": round(water_level, 1),
                "status": status,
                "raw_angle": round(avg_angle, 2)
            }

        except Exception as e:
            print(f"ERROR: MPU6050 read failed - {e}", file=sys.stderr)
            return {
                "pitch_angle": 0.0,
                "water_level_cm": 0.0,
                "status": "FAULT",
                "raw_angle": 0.0
            }

    def calibrate(self, samples=100):
        """
        Calibrate the sensor by taking multiple readings at rest position.
        The arm should be HORIZONTAL (θ=0) during calibration.

        Args:
            samples: Number of samples for calibration

        Returns:
            Calculated calibration offset
        """
        print(f"MPU6050: Starting calibration with {samples} samples...", file=sys.stderr)
        print("MPU6050: Ensure arm is HORIZONTAL and water is STILL", file=sys.stderr)

        # Wait for stabilization
        time.sleep(2)

        # Reset filtered angle
        self.filtered_angle = 0.0
        self.last_time = time.time()

        angles = []
        for i in range(samples):
            angle = self.calculate_filtered_angle()
            angles.append(angle)

            if (i + 1) % 10 == 0:
                print(f"MPU6050: Calibration progress: {i + 1}/{samples}", file=sys.stderr)

            time.sleep(0.05)

        average_angle = sum(angles) / len(angles)

        # Calibration offset should bring average to zero (horizontal)
        calibration_offset = -average_angle

        print(f"MPU6050: Calibration complete.", file=sys.stderr)
        print(f"MPU6050: Average angle: {average_angle:.2f}°", file=sys.stderr)
        print(f"MPU6050: Calibration offset: {calibration_offset:.2f}°", file=sys.stderr)

        return calibration_offset

    def close(self):
        """Close the I2C bus connection."""
        if self.bus:
            try:
                self.bus.close()
                print("MPU6050: I2C bus closed", file=sys.stderr)
            except Exception as e:
                print(f"MPU6050: Error closing bus - {e}", file=sys.stderr)


"""
═══════════════════════════════════════════════════════════════
END OF FILE: python/lib/sensor_drivers/mpu6050_driver.py
═══════════════════════════════════════════════════════════════
"""
