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

## ECSによる実行
### 1. タスク定義の準備
JSONで記述すると以下の通り
```json
{
    "taskDefinitionArn": "arn:aws:ecs:ap-northeast-1:${AWS_ACCOUNT_ID}:task-definition/${TASK_DEFINITION_NAME}:3",
    "containerDefinitions": [
        {
            "name": "app",
            "image": "${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${IMAGE_NAME}:1730307307",
            "cpu": 0,
            "portMappings": [
                {
                    "name": "app-80-tcp",
                    "containerPort": 80,
                    "hostPort": 80,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "environment": [
                {
                    "name": "PROD",
                    "value": "true"
                },
                {
                    "name": "START_PAGE",
                    "value": "2"
                },
                {
                    "name": "PDF_PATH",
                    "value": "arn:aws:s3:::${BACKET_NAME}/${PDF_NAME}"
                },
                {
                    "name": "END_PAGE",
                    "value": "9"
                },
                {
                    "name": "BACKET_NAME",
                    "value": "${BACKET_NAME}"
                },
                {
                    "name": "FILE_NAME",
                    "value": "${PDF_NAME}"
                }
            ],
            "environmentFiles": [],
            "mountPoints": [],
            "volumesFrom": [],
            "ulimits": [],
            "systemControls": []
        }
    ],
    "family": "split-go-pdf0",
    "taskRoleArn": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${customRole}",
    "executionRoleArn": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/ecsTaskExecutionRole",
    "networkMode": "awsvpc",
    "revision": 2,
    "volumes": [],
    "status": "ACTIVE",
    "requiresAttributes": [
        {
            "name": "com.amazonaws.ecs.capability.ecr-auth"
        },
        {
            "name": "com.amazonaws.ecs.capability.task-iam-role"
        },
        {
            "name": "ecs.capability.execution-role-ecr-pull"
        },
        {
            "name": "com.amazonaws.ecs.capability.docker-remote-api.1.18"
        },
        {
            "name": "ecs.capability.task-eni"
        }
    ],
    "placementConstraints": [],
    "compatibilities": [
        "EC2",
        "FARGATE"
    ],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "2048",
    "memory": "4096",
    "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    },
    "registeredAt": "2024-10-30T17:14:57.555Z",
    "registeredBy": "arn:aws:iam::${AWS_ACCOUNT_ID}:user/${myName}",
    "enableFaultInjection": false,
    "tags": []
}
```
ちなみに環境変数はStepFunctions実行時に上書きできる。
詳細は右の通り：https://qiita.com/piro-gxp/items/5202d6aba1523bcec685

### 2. クラスターの準備
とりあえず名前だけ用意

### 3. クラスターからタスクを一回実行
以下を設定
- 環境
  - キャパシティプロバイダ戦略
  - あとはデフォルト
- デプロイ設定
  - アプリケーションタイプ：タスク
  - タスク定義のファミリー：task definition
  - タスク数：1
- ネットワーキング
  - VPC：S3にアクセスできる
  - サブネット：S3にアクセスできる
  - セキュリティグループ：デフォルトのものを指定（本当はよくないが、全開放で）
  - パブリックIP：オフ

あとはそのまま実行

### 4. S3を確認して、アップロードされていることを確認
一応OK

## StepFunctionsによる実行
### 1. ステートマシンの作成
基本的に以降はTerraformでリソース管理をします
- terraform.tfvars.sampleをterraform.tfvarsにコピーして適切な値を設定してください
- aws/env/dev/infra 内でリソースを展開してください
```
cd ${リポジトリのroot}/aws/env/dev/infra
terraform init
terraform plan
terraform apply
```

- リソースが無事展開できたら、mainディレクトリに入って同様にリソースをデプロイしてください
- main.tfがステートマシンの実体となっており、環境が用意できていれば、これだけ実行すれば最悪大丈夫なはずです。
```
cd ${リポジトリのroot}/aws/env/dev/infra
terraform init
terraform plan
terraform apply
```

### 2. Step Functionsの実行
- マネジメントコンソール上から実行していただければ大丈夫です
パラメータの例は以下の通り
```
{
  "bucket_name": "split-pdf-go-atomisu",
  "file_name": "sagemaker-dg.pdf",
  "start_pages":[2411,2842,2864,3030,4428],
  "end_pages":[2841,2863,3029,4427,5131]
}
```
# 参考リンク
- StepFunctions x ECSでワンショットタスクを行う手順：https://tech.classi.jp/entry/one-shot-task-with-step-functions-and-ecs
- 環境変数をオーバーライドする手順：https://qiita.com/piro-gxp/items/5202d6aba1523bcec685
- もっと複雑な処理：https://qiita.com/a_sh_blue/items/8ccf7502d1512933d226