# mqtt


# logger_mqtt.rb

MQTTブローカーに接続して、以下の処理をおこなう。

* メッセージをログファイルに取得する
* アラーム用のトピックスに、retain付きで red または green を書き込む
* 最終値をretain 付きで、トピックスに書き込む


# alart_mqtt.rb

MQTTブローカーからアラーム用トピックスを読んで、LEDを点灯する
