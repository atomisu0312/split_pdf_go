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
## ECRにPushする処理
1. ECRリポジトリを作成

2. AWSの記述に従ってPushしてくれればOK

3. 以下、split_pdf_goという名前のリポジトリを作ったと想定

## Terraformによるインフラの構築
### 1. Terraformのインストール
インフラの構築自体はTerraform → OpenTofuで実行します
OpenTofuのインストール方法は以下を参照してください。
https://opentofu.org/docs/intro/install/

### 2. 既存VPCの用意
VPCとサブネット（パブリックサブネット）、および、ルートテーブルは各自で用意してください。

なお、プライベートサブネットで展開する場合には以下のエンドポイントと紐づいていることを確認してください。
- S3エンドポイント
- ECR用エンドポイント２種

### 3. 事前準備
以下のディレクトリに移動し、

```
$ cd ${root}/aws/env/dev/main
```

terraform.tfvars.sample→terraform.tfvarsと名前を変えてコピーし、適切な設定に書き換えてください。
設定項目の一覧は以下の通りです。

```
account_id              = "12桁のアレ"
region                  = "your-region"
vpc_id                  = "vpc-ZZZZZXXXXZZZZXXXX"
subnet_id               = "subnet-sample"        # S3とECRにアクセスできればPrivateSubnetで問題ない
repository_name         = "split_pdf_go"
num_machine             = 5
```

### 4. インフラ構築の実行
以下のコマンドを実行してください。適切に準備できていれば動くはずです。
```
tofu init
tofu apply
```

## StepFunctionsによる実行
- マネジメントコンソール上から実行していただければ大丈夫です
パラメータの例は以下の通り
```
{
  "bucket_name": "split-pdf-go-atomisu",
  "file_name": "sagemaker-dg.ch10.Deploy-models-for-inference.pdf",
  "start_pages":[1,2842,2864,3030,4428],
  "end_pages":[80,]
}
```
# 参考リンク
- StepFunctions x ECSでワンショットタスクを行う手順：https://tech.classi.jp/entry/one-shot-task-with-step-functions-and-ecs
- 環境変数をオーバーライドする手順：https://qiita.com/piro-gxp/items/5202d6aba1523bcec685
- もっと複雑な処理：https://qiita.com/a_sh_blue/items/8ccf7502d1512933d226