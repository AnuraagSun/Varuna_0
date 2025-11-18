RPI SETUP
```
sudo apt update
sudo apt install -y python3-pip python3-dev i2c-tools

sudo pip3 install smbus2

sudo pip3 install adafruit-circuitpython-dht
sudo apt install -y libgpiod2

sudo raspi-config

sudo i2cdetect -y 1

cd varuna_ui/python/scripts
python3 read_sensors.py
```
RPI CALIBRATION:
```
# 1. Enable I2C
sudo raspi-config
# Navigate to: Interface Options -> I2C -> Enable

# 2. Install dependencies
sudo apt update
sudo apt install -y python3-pip i2c-tools
sudo pip3 install smbus2

# 3. Detect MPU6050
sudo i2cdetect -y 1
# Should show device at 0x68

# 4. Test Python script
cd varuna_ui/python/scripts
python3 read_sensors.py

# 5. Calibrate the sensor
# Create calibration script
cat > calibrate_mpu.py << 'CALIBEOF'
import sys
sys.path.insert(0, '../lib')
from sensor_drivers.mpu6050_driver import MPU6050

print("=== MPU6050 CALIBRATION ===")
print("IMPORTANT: Position the arm HORIZONTAL before starting")
input("Press ENTER when ready...")

mpu = MPU6050(address=0x68, bus=1)
offset = mpu.calibrate(samples=100)

print(f"\nCalibration complete!")
print(f"Add this to config.json:")
print(f'"mpu6050_offset": {offset:.2f}')

mpu.close()
CALIBEOF

python3 calibrate_mpu.py

# 6. Update config.json with the offset value
nano ../config/config.json
# Update the mpu6050_offset value

# 7. Test again
python3 read_sensors.py
```
