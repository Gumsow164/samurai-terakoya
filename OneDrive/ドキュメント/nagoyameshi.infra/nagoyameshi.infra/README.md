## RDS のスナップショット取得と復元方法

### 1. スナップショットの取得

1. AWS コンソールで RDS にアクセス
2. 左メニューの「データベース」を選択
3. 対象の DB を選択
4. 「アクション」→「スナップショットの作成」をクリック
5. スナップショット名を入力し「作成」をクリック
6. スナップショット作成完了まで待つ

### 2. スナップショットからの復元

1. 左メニューの「スナップショット」を選択
2. 復元したいスナップショットを選択
3. アクションの「スナップショットの復元」をクリック
4. 新しい DB 名やインスタンスクラスを設定
5. 「DBインスタンスを復元」をクリックして復元開始
6. 復元完了後、接続情報を確認


## WAF の設定方法（CloudFront 連携）

1. AWS コンソールで WAF & Shield にアクセス
2. 「ウェブ ACL を作成する」をクリック
3. リソースタイプはグローバルリソースを選択、名前等を書き込む
4. AWSリソースを追加でcloudfrontディストリビューションを選択し、リソースを選択する
5. Web リクエスト本体の検査はデフォルトを選択
6. ルールの設定
   - Add rules をクリック
   - Add my own rules and rule groups を選択
   - Rule typeは Rule builder を選択
   - Rule の名前を作成し、Typeは Regular rule を選択
   - If a request は matches the statement を選択
   - Statement で Originates from a countryからJapan を選択
   - IP address to use to determine the country of origin は Source IP address を選択
   - Action で Allow を選択
   - Default web ACL action for requests that don't match any rules で Block を選択

6. CloudFront にアタッチ
   - 「CloudFront distributions」から対象ディストリビューションを選択
   - 「WAF」タブで Web ACL を関連付け
7. 設定後はテスト環境で動作確認