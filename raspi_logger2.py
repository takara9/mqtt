#!/usr/bin/env python
# -*- coding:utf-8 -*-
#
#
import paho.mqtt.client as paho
import os
import urlparse
#log_path = "/home/tkr/temp/log"

# Define event callbacks
def on_connect(mosq, obj, rc):
    print("rc: " + str(rc))

def on_message(mosq, obj, msg):
    print(msg.topic + " " + str(msg.qos) + " " + str(msg.payload))
    log_file = "sensor.log"
    #lf = open(log_file,'a')
    #rec = "%s,%s\n" % (msg.topic, str(msg.payload))
    #lf.write(rec)
    #lf.close()

def on_publish(mosq, obj, mid):
    print("mid: " + str(mid))

def on_subscribe(mosq, obj, mid, granted_qos):
    print("Subscribed: " + str(mid) + " " + str(granted_qos))

def on_log(mosq, obj, level, string):
    print(string)

#mqttc = mosquitto.Mosquitto()
mqttc = paho.Client()

# Assign event callbacks
mqttc.on_message = on_message
mqttc.on_connect = on_connect
mqttc.on_publish = on_publish
mqttc.on_subscribe = on_subscribe

# Uncomment to enable debug messages
#mqttc.on_log = on_log

# Parse CLOUDMQTT_URL (or fallback to localhost)
url_str = os.environ.get('CLOUDMQTT_URL', 'mqtt://192.155.208.116:1883')
url = urlparse.urlparse(url_str)

# Connect
#mqttc.username_pw_set(url.username, url.password)
mqttc.connect(url.hostname, url.port)

# Start subscribe, with QoS level 0
mqttc.subscribe("sensor/power", 0)
mqttc.subscribe("sensor/temp", 0)
mqttc.subscribe("sensor/pressure", 0)
mqttc.subscribe("alart", 0)

# Publish a message
mqttc.publish("sensor/ctrl", "start")

# Continue the network loop, exit when an error occurs
rc = 0
while rc == 0:
    rc = mqttc.loop()

print("rc: " + str(rc))
