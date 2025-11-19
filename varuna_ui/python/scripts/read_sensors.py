#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════
FILE: python/scripts/read_sensors.py (REAL HARDWARE)
PHASE: PRODUCTION - Real Sensor Integration
LOCATION: varuna_ui/python/scripts/read_sensors.py
═══════════════════════════════════════════════════════════════
"""

import sys
import os
import json
from datetime import datetime
from pathlib import Path

# Add lib directory to path
script_dir = Path(__file__).parent
lib_dir = script_dir.parent / "lib"
sys.path.insert(0, str(lib_dir))

# Import sensor drivers
from sensor_drivers.mpu6050_driver import MPU6050

# Try to import DHT22 (optional)
try:
    from sensor_drivers.dht22_driver import DHT22
    DHT_AVAILABLE = True
except:
    DHT_AVAILABLE = False


def load_config():
    """Load configuration from config.json file."""
    config_path = script_dir.parent / "config" / "config.json"

    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
        return config
    except FileNotFoundError:
        print(f"WARNING: Config file not found, using defaults", file=sys.stderr)
        return {
            "calibration": {
                "L_arm": 1.5,
                "H_pivot": 2.0,
                "R_float": 0.15,
                "mpu6050_offset": 0.0
            }
        }
    except Exception as e:
        print(f"ERROR: Failed to load config - {e}", file=sys.stderr)
        sys.exit(1)


def main():
    """Main function - reads REAL sensors and outputs JSON."""
    try:
        # Load configuration
        config = load_config()
        calib = config.get("calibration", {})

        # Get calibration constants
        L_arm = calib.get("L_arm", 1.5)
        H_pivot = calib.get("H_pivot", 2.0)
        R_float = calib.get("R_float", 0.15)
        mpu_offset = calib.get("mpu6050_offset", 0.0)

        # Initialize MPU6050 with REAL hardware
        mpu = MPU6050(
            address=0x68,
            bus=1,
            calibration_offset=mpu_offset
        )

        # Read MPU6050 data
        mpu_data = mpu.read_sensor_data(
            L_arm=L_arm,
            H_pivot=H_pivot,
            R_float=R_float,
            num_samples=10
        )

        # Read DHT22 if available
        if DHT_AVAILABLE:
            try:
                dht = DHT22(pin=4)
                dht_data = dht.read_sensor_data()
                dht.close()
            except Exception as e:
                print(f"WARNING: DHT22 read failed - {e}", file=sys.stderr)
                dht_data = {
                    "temperature": 0.0,
                    "humidity": 0.0,
                    "status": "FAULT"
                }
        else:
            dht_data = {
                "temperature": 0.0,
                "humidity": 0.0,
                "status": "NOT_INSTALLED"
            }

        # Build output data
        output = {
            "device_id": config.get("device_id", "CWC-RJ-001"),
            "timestamp": datetime.now().isoformat(),
            "mpu6050": mpu_data,
            "dht22": dht_data,
            "consensus_level_cm": mpu_data["water_level_cm"],
            "rate_of_change_cm_per_hour": 0.0,
            "calibration": calib
        }

        # Output ONLY valid JSON to stdout
        print(json.dumps(output))

        # Close sensor
        mpu.close()

        return 0

    except Exception as e:
        print(f"FATAL ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

"""
═══════════════════════════════════════════════════════════════
END OF FILE: python/scripts/read_sensors.py
═══════════════════════════════════════════════════════════════
"""
