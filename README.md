# 要件
- Step Function X ECS X Go で長大PDFの分割処理を実施する

# 目標
- Terraformで記述したコードの提供

# 処理概要
![処理概要](https://i.gyazo.com/431ef139b1108823c996cfab249b65e6.png)

# その他処理
## Goアプリの起動方法（バイナリビルド含む）
ディレクトリの移動
```
cd code/split_go
```

アプリケーションのビルドからの実行
```
go build
./split_pdf_go -start 1 -end 4
```

## コンテナによる単発実行
1. ディレクトリの移動
```
cd code/split_go
```

2. Dockerイメージの作成
```
docker build -t split_pdf_go .
```

3. .env.docker.exampleを.env.dockerなどの別ファイルにコピーし、適切に環境変数を入れる

4. イメージの実行
```
docker run --rm --env-file .env.docker split_pdf_go
```

# 参考リンク
- ECSでワンショットタスクを行う手順：https://tech.classi.jp/entry/one-shot-task-with-step-functions-and-ecs

- もっと複雑な処理：https://qiita.com/a_sh_blue/items/8ccf7502d1512933d226