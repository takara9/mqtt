#!/usr/bin/env ruby 
# encoding: utf-8

pin = 24

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

out = 1
10.times do
  v = open("/sys/class/gpio/gpio#{pin}/value", "w")
  v.write(out)
  v.close
  out = out == 1 ? 0 : 1
  sleep 0.5
end

uexport = open("/sys/class/gpio/unexport", "w")
uexport.write(pin)
uexport.close
