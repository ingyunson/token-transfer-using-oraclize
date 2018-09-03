

# token-transfer-using-orzclize

[日本語版](./README_jp.md)
[English version](./README_eng.md)
  
[Oraclize](https://github.com/oraclize/ethereum-api)を利用して、トークンの転送をするスマート・コントラクトです。
一つのトークンコントラクトと四種類のYouTubeのカウンターを利用したコントラクトがあります。

- `ERC20.sol` : トークンコントラクトです。[OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-solidity)のERC20コントラクトを使用しました。
- `youtube_viewcount.sol` YouTubeの映像視聴によるetherの支給用コントラクトです。
- `timer_youtube_viewcount.sol` YouTubeの映像視聴によるetherの支給用コントラクトです。コントラクトの作成後、一定時間後に再びヒットを測定し、設定された時間の間に再生された映像の視聴した数だけetherを支給します。
- `token_youtube_viewcount.sol` YouTubeの映像視聴に対応する数量のERC20.solを通じて生成されたトークンを支給するコントラクトです。
- `token_timer_youtube_viewcount.sol` YouTubeの映像視聴によるトークン支給用コントラクトです。コントラクトの作成後、一定時間後に再びヒットを測定し、設定された時間の間再生された映像の視聴した数だけトークンを支給します。

## 使用例
YouTubeの再生回数を基準とした、スマートコントラクトを配布することができます。YouTubeの動画広告やMCN事業などに応用することができます。

------------
### 共通事項

#### mappingについて
`index`mappingは、受信者のアドレスに基づいて`x`番目に位置する送信履歴に対応する` idx`変数をロードします。
`transaction_rec`mappingは` idx`変数に対応する `transaction`ストラクトの内容をロードします。

例えば、 `0xca35b7d915458ef540ade6068dfe2f44e8fa733c`というアドレスに5回の送信を実行した場合` 0xca35b7d915458ef540ade6068dfe2f44e8fa733c`は1から5までの `idx_num`が割り当てられます。したがって、 `index [＃1] [＃2]`で＃1の位置に受信者のアドレスを、＃2に照会する順番の転送順序を入力すると、全体の送信履歴の中では、転送が何番目に行われたか（ ` idx`）を知ることができます。
このように知り合った `idx`記録を利用して、詳細な送信履歴を呼び出すことができます。

 `transaction`ストラクトの詳細な内容は、次のとおりです。
- `blocknum`その取引承認されたブロックの番号
- `blocktime`その取引承認されたブロックの時間
- `viewrate`ヒット1当転送するether/トークンの割合
- `receiver`送信を受信者のアドレス
- `amount_of_transfer`送信されたether/トークンの総量
- `targetaddress`対象となるYouTubeの映像のURL

#### ※Oraclizeを2回以上利用するためには、コントラクトアカウントにetherが含まれている必要があります。

------
----

### 1. YouTubeの再生回数に応じた ether支給コントラクト
ファイルの名：`youtube_viewcount.sol`

対象youtubeのURLとetherを受け取りアドレス、ヒットあたりの送信 ether比（wei）を設定することができます。

  --------
#### コントラクトの名：`YoutubeCounter`
#### *関数の説明*

`YoutubeCounter`コンストラクタ
- コントラクト ディストリビュータ(msg.sender)をownerに設定します。

`YoutubeViews`youtubeの映像情報
- パラメータを利用して、コントラクトを進める映像情報、受取人、ヒットあたりの比率を設定することができます。
- _videoaddress：ターゲット youtubeのURL（string）
- _beneficiary：受取者アドレス（address）
 - _PayPerView：ヒットごとに送信 ether 比（uint）

`ethertransfer`ether 伝送モジュール
- YoutubeViews関数を利用して生成させた情報を実行させます。（ether 伝送、単位はwei）
- 送信履歴を`transaction`ストラクトに入力します。
  
 `refund`返金モジュール
  - コントラクトのイーサネットをownerに返します

----
----

## 2.タイマーがあるYouTubeの再生回数による ether支給コントラクト

#### ファイルの名： `timer_youtube_viewcount.sol`

特定の時点（A）を基準にして宣言した時間（B）までのヒットを再測定することで二の時間の間のパフォーマンスを測定し、その成果に基づいた etherを支給するコントラクトです。
基本的な構造は、*1。 YouTubeの再生回数に応じた ether支給コントラクト*と同じで差がある部分だけを説明します。

**使用方法**
`YoutubeView_setup`を実行させながら映像のURL、受取人、支払いの比率を設定します。
`YoutubeView_setup`を優先して実行させた後、` YoutubeView_timer`を実行します。このとき、次のコードを変更して、期間を設定することができます。

    oraclizeID_2 = oraclize_query（120、 "URL"、query_2）;

上記のコードでは `120`に該当する部分を変更します。基準は、 `秒`ので、上記のコードは、120秒、つまり3分後に映像のヒットを呼んで来るようになります。基準となる時間は、次のとおりです。

- 1分60
- 1日：86400
- 1週間（7日）：604800
- 1ヶ月（4週間）：2419200

この方式を利用する場合 `transaction`構造体の` viewcounter`と `amount_of_transfer`は`設定した時間 - 最初の設定時間 `になります。


----
----

## 3.発行した別のトークンを利用して、YouTubeの再生回数に応じたトークン支給コントラクト
#### ファイルの名： `ERC20.sol`と` seperated_youtube_viewcount.sol`

etherではなく、個別に発行したトークンを送信させるコントラクトです。 `ERC20.sol`を利用して、トークンを作成し、このトークンのコントラクトアドレスを利用して、` seperated_youtube_viewcount.sol`を介してトークンをコントロールします。

※注意：Oraclizeを利用するためには、YouTubeの再生回数を収集するためのコントラクトアカウントにプロバイダーが必要です。

------------
#### ファイルの名： `ERC-20.sol`
#### コントラクトの名： `SimpleToken`
#### *関数の説明*

**`constructor`コンストラクタ**
- INITIAL_SUPPLYの数だけトークンを発行します。
- コントラクトディストリビュータをownerに設定します。
- コントラクトディストリビュータをaddControllersに含めます。

**`addControllers`トークン送信権の設定**
- トークンを送信するコントラクトあるいはユーザーが `controller`に属しなければ、トークンを送信することができません。
- トークン送信権を付与したいアドレスをパラメータ `controller`に入力します。

**`tokentransfer`コントラクトのトークンの転送**
- コントラクトが保有トークンを送信します。
- `_to`に`_value`だけのトークンを送信します。

**`transferFrom`：AからBにトークン送信**
- アドレスAが保有しているトークンをBに送信します。
- `_from`が持つトークンを`_to`に`_value`だけ送信します。

**`transfer`：msg.senderが付いているトークンを送信**
- 関数を実行させたアカウント（msg.sender）が保有しているトークンを送信します。
- `_to`に`_value`だけのトークンを送信します。




#### *パラメータの説明*
- `name`：トークンの名前
- `symbol`：トークンの略
- `decimals`：トークンの単位
- `INITIAL_SUPPLY`：最初発行量（設定量*（10 ^（decimals））
- `owner`：コントラクトの所有者
- `allowedControllers`：トークンをコントロールすることができるように許可されたアカウント（以外は、トークンの転送不可）

------------
#### ファイルの名： `seperate_youtube_count.sol`
#### コントラクトの名： `YoutubeViews`
#### *関数の説明*

 **`YoutubeViewInfo` : youtubeの映像情報**
- パラメータ関数を利用して、コントラクトを進める映像情報、受取人、ヒットあたりの比率を設定することができます。
- `_videoaddress`：ターゲットyoutubeアドレス（string）
- `_beneficiary`：受取者アドレス（address）
 - `_PayPerView`：ヒットごとに送信トークン比（uint）

**`tokentransfer` : 設定されたトークンの転送**
- YoutubeViewInfoを介して設定された情報を実行して、トークンを送信
- 送信時の情報を `index`と` transaction_rec`に記録

※**注意点**： `ERC20.sol`を通じて発行したトークンのコントラクトアドレスを直接入力する必要があります。

    address public tokenaddress = 0xee9c3a618d8786c6343fc079a75462839b3a673b;
   
24行の上のコードでは、=の後にトークンのコントラクトアドレスを入力しなければならない動作します。また、 `YoutubeViews`コントラクトが` ERC20`コントラクトで `addControllers`関数を使用して` controller`に登録する必要があります。



#### *パラメータの説明*
- `viewsCount`：対象画像のヒット
- `amount`：転送wei
- `balance`：アカウントの残高
- `beneficiary`：受取人アドレス
- `PayPerView`：ヒットあたりの転送率
- `videoaddress`：ターゲットyoutubeのURL
- `tokenaddress`：コントロールするトークンのスマート契約アドレス

----
----

## 4. 타이머가 있는  발행한 별도의 토큰을 이용하여 유튜브 조회수에 따른 토큰 지급 컨트랙트

특정 시점(A)을 기준으로 하여 선언한 시간 뒤(B)의 조회수를 재측정하는 것으로 두 시간 사이의 성과를 측정하여 그 성과에 기반한 토큰을 지급하는 컨트랙트입니다.
기본적인 구조는 *3. 유튜브 조회수에 따른 토큰 지급 컨트랙트*와 같으며 차이가 있는 부분만을 설명합니다.

**사용법**
`YoutubeView_setup`을 실행시키면서 영상 주소, 수령자, 지급 비율을 설정합니다.
`YoutubeView_setup`을 우선 실행시킨 뒤, `YoutubeView_timer`를 실행시킵니다. 이 때 아래의 코드를 수정하여 기간을 설정할 수 있습니다.

    oraclizeID_2 = oraclize_query(120, "URL", query_2);

위의 코드에서 `120`에 해당하는 부분을 수정합니다. 기준은 `초`이므로 위의 코드는 120초, 즉 3분 후에 해당 영상의 조회수를 불러오게 됩니다. 기준이 되는 시간은 다음과 같습니다.

- 1분 : 60
- 1일 : 86400
- 1주(7일) : 604800
- 1달(4주) : 2419200

이 방식을 이용할 경우 `transaction` 구조체의 `viewcounter`와 `amount_of_transfer`는 `설정시킨 시간 - 최초 설정 시간`이 됩니다.


## 4.タイマーがある発行した別のトークンを利用して、YouTubeの再生回数に応じたトークン支給コントラクト

特定の時点（A）を基準にして宣言した時間（B）までのヒットを再測定することで二の時間の間のパフォーマンスを測定し、その成果に基づいたトークンを支給するコントラクトです。
基本的な構造は、*3。 YouTubeの再生回数に応じたトークン支給コントラクト*と同じで差がある部分だけを説明します。

**使用方法**
`YoutubeView_setup`を実行させながら映像住所、受取人、支払いの比率を設定します。
`YoutubeView_setup`を優先して実行させた後、` YoutubeView_timer`を実行します。このとき、次のコードを変更して、期間を設定することができます。

    oraclizeID_2 = oraclize_query（120、 "URL"、query_2）;

上記のコードでは `120`に該当する部分を変更します。基準は、 `秒`ので、上記のコードは、120秒、つまり3分後に映像の視聴を呼んで来るようになります。基準となる時間は、次のとおりです。

- 1分60
- 1日：86400
- 1週間（7日）：604800
- 1ヶ月（4週間）：2419200

この方式を利用する場合 `transaction`構造体の` viewcounter`と `amount_of_transfer`は`設定した時間 - 最初の設定時間 `になります。

