


## logger_mqtt.rb

MQTTブローカーに接続して、以下の処理をおこなう。

* メッセージを受信する
    * sonsor/temp, sensor/power, sensor/pressure を受信します。
    * ログを書き込むこともできます。ディスクを消費するのでコメントしてあります。
* アラーム用のトピックスに、retain付きで red または green を書き込む
    * アラーム用のトピックは alert です
* 最終値をretain 付きで、トピックスに書き込む
    * temp_desktop,humi_desktop,temp_floor,humi_floor,temp_window,humi_window
    * power,alert,pressure

## alart_mqtt.rb

MQTTブローカーからアラーム用トピックスを読んで、LEDを点灯する


## led_test.rb

ラズパイのGPIOに接続したLEDを点滅させてテストする

## start.sh

logger_mqtt.rbの起動用シェルスクリプトで、/etc/rc.localから次の様に呼び出します。

```
nohup su - tkr -c "/usr/local/mqtt/start.sh" &
```
ここで、suコマンドにログイン・シェル実行とユーザー名を指定している理由は、
rbenvをtkrユーザーにインストールして、その管理下でrubyを利用しているためです。

## oconfig.json
内容は以下の様にMQTTブローカーのURLです。環境に合わせてブローカーのアドレスを設定します。

```
{
    "mqtt_broker": "mqtt://localhost:1883"
}
```