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
# 実行例
# ./logger_mqtt.rb mqtt://192.155.208.116:1883
#
# 日付 2015/8/10 
# 開発者 高良 真穂
#
#

require 'rubygems'
require 'mqtt'

def logw(fn,rec)
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

def mqtt_init(broker_url)
  $client = MQTT::Client.connect(broker_url)
end

def mqtt_loop()
  $client.get('sensor/#') do |topic,message|
    #puts "#{topic},#{message}"
    fn = topic.split("/")
    logw(fn[1],message)
    tn = fn[1]
    f = message.split(",")
    val = 0
    case tn
    when "temp" then
      tn = "#{fn[1]}_#{f[3]}"    
      val = f[6].to_i
      tn2 = "humd_#{f[3]}"    
      val2 = f[7].to_i
    when "power" then
      val = f[3].to_i
      # 電気資料量が 300Whrを超えると警告
      if val > 200 then
        $client.publish("alart","red",retain=true)
      else
        $client.publish("alart","green",retain=true)
      end
    when "pressure" then
      val = f[3].to_i
    else
      val = 0
    end
    $client.publish(tn,val,retain=true)
    if fn[1] == "temp" then
      $client.publish(tn2,val2,retain=true)
    end
  end
end

def matt_close()
  $client.disconnect()
end


##### MAIN #####
if __FILE__ == $0
  mqtt_init(ARGV[0])
  mqtt_loop()
  mqtt_close()
end
