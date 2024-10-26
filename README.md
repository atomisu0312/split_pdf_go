# 要件
- Step Function X ECS X Go で長大PDFの分割処理を実施する

# 目標
- Terraformで記述したコードの提供

# 処理概要
![処理概要](https://i.gyazo.com/431ef139b1108823c996cfab249b65e6.png)

# その他処理
## Goアプリの起動方法
- go run test.go -n ${インプットパス}　-d ${アウトプットパス} -s ${ページの範囲}

# 参考リンク
- ECSでワンショットタスクを行う手順：https://tech.classi.jp/entry/one-shot-task-with-step-functions-and-ecs

- もっと複雑な処理：
https://qiita.com/a_sh_blue/items/8ccf7502d1512933d226