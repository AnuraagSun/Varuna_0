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
