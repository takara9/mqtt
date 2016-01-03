#!/usr/bin/env ruby 
# encoding: utf-8
#
# 機能概要
#   ラズパイのセンサー情報のMQTTのトピックスを受けて
#   閾値をクライアントで判断して、LEDを点灯する
#
# 効果
#   LEDの明かりで人間に知らせる
#
# 日付 2015/8/10 
# 開発者 高良 真穂
#
#

require 'rubygems'
require 'mqtt'
require 'json'

def mqtt_loop()
  $client.get('alert') do |topic,message|
    puts "#{topic},#{message}"
    if message == "red" then
      led_on(25)
      led_off(24)
    else 
      led_on(24)
      led_off(25)
    end
  end
end

def led_init(pin)
  begin
    io = open("/sys/class/gpio/export", "w")
    io.write(pin)
    io.close
    dir = open("/sys/class/gpio/gpio#{pin}/direction", "w")
    dir.write("out")
    dir.close
  rescue Exception =>e
    puts e.class
  end
end

def led_on(pin)
  return led_op(pin,1)
end

def led_off(pin)
  return led_op(pin,0)
end

def led_op(pin,sw)
  v = open("/sys/class/gpio/gpio#{pin}/value", "w")
  v.write(sw)
  v.close
end

##### MAIN #####
if __FILE__ == $0
  led_init(25)
  led_init(24)

  json_data = open("config.json") do |io|
    JSON.load(io)
  end

  $client = MQTT::Client.connect(json_data['mqtt_broker'])
  mqtt_loop()
  $client.disconnect()
end
