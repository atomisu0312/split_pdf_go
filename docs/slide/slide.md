---
marp: true
theme: ashigara
paginate: true
---
 <!--タイトル-->

 <!--
 _class: lead
 -->

# StepFunctions X ECS X Golangで
# オンラインPDF分割をやってみよう
## やました(@atomisu0312)

---

# 自己紹介
## TBD

---
# 持って帰ってほしいこと
- タスク処理をする場所としてクラウドが使える
  - お金はかかるけど豊富なリソースを使えます
  - Webアプリケーションだけではない
- AWSで実装されているサーバレスなシステムの概要を知る
  - Step Functions
  - ECS
- 代替手段について
  - この方法に至った経緯について
  - これが正しいとは、絶対に言いません
---
# 背景
---
# 最終的な構成(To Do)
---
# 現行の構成(As Be) 
---
 <!--サブタイトル-->

 <!--
 _class: lead
 -->

# AWSによる実装手順

---
# 処理の流れ
---
# Step1. ローカルでのPDF分割
---
# Step2. コンテナを活用したPDF分割
---
# Step3. ECSからの実行
---
# Step4. StepFunctionsによる実行
---
# Step5. 外から呼び出せるように
---
# Step6. IaC化
---
 <!--サブタイトル-->

 <!--
 _class: lead
 -->

# 技術選定とかその他諸々

---
# コスト
---
# PDF分割
---
# EC2 vs ECS
---
# Lambda vs ECS