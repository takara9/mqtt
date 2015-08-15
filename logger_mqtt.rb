#!/usr/bin/env ruby 
# encoding: utf-8
#
# 機能概要
#   ラズパイのセンサー情報のMQTTのトピックスを受けて
#   ログファイルに書き出し、
#   最終値をトピックスに維持フラグ付きで書き出す
#
# 効果
#   MQTTで配信されるトピックスについて
#   この最終値、過去の履歴を記録する
#
#
# 日付 2015/8/10 
# 作者 高良 真穂
#
#

require 'rubygems'
require 'mqtt'
require 'json'

def log_writer(fn,rec)
  basedir = "/var/log"
  fnf = "#{basedir}/#{fn}.log"
  if fn == "temp" then
    f = rec.split(",")
    fnf = "#{basedir}/#{fn}_#{f[3]}.log"
  end
  File.open(fnf,"a") do |logf|
    logf.puts rec
  end
end

def mqtt_loop()
  $client.get('sensor/#') do |topic,message|
    puts "#{topic},#{message}"
    msg = JSON.parse(message)
    (topic_domin, topic_name) = topic.split("/")
    
    # 最終取得値をトピックスに書込み
    case topic_name

    when "temp" then
      # 最終の温度と湿度をトピックに書込み
      $client.publish("temp_#{msg['pos']}",msg['tmp'],retain=true)
      $client.publish("humi_#{msg['pos']}",msg['hmd'],retain=true)
      rec = "#{msg['uxtm']},#{msg['sttm']},#{msg['pos']},#{msg['tmp']},#{msg['hmd']},#{msg['erc']}"
      log_writer("temp_#{msg['pos']}",rec)

    when "power" then
      # 消費電力が大きい場合は警告
      if msg['power'] > 200 then
        $client.publish("alart","red",retain=true)
      else
        $client.publish("alart","green",retain=true)
      end
      rec = "#{msg['uxtm']},#{msg['sttm']},#{msg['power']}"
      log_writer("#{topic_name}",rec)

    when "pressure" then
      $client.publish("pressure",msg['pressure'],retain=true)
      rec = "#{msg['uxtm']},#{msg['sttm']},#{msg['pressure']}"
      log_writer("#{topic_name}",rec)

    end
  end
end

##### MAIN #####
if __FILE__ == $0

  json_data = open("config.json") do |io|
    JSON.load(io)
  end

  $client = MQTT::Client.connect(json_data['mqtt_broker'])
  mqtt_loop()
  $client.disconnect()
end
