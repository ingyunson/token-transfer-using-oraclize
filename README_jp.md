
token-transfer-using-orzclize
=============================


Oraclizeを使用して、トークンの転送をするスマートコントラクトです。（まだ未完）

------------


------------


### 1. Youtube ヒットによる Ether 支給コントラクト
ファイル名 : youtube_viewcount.sol    

YouTubeの再生回数を基準とした、スマートコントラクトを配布することができます。YouTubeの動画広告やMCN事業などに応用することができます。
対象YouTube映像のアドレスとether受け取りaddress、再生回数に従う送信 ether（wei）を設定することができます。

※注意：Oraclizeを利用するためには、コントラクトアカウントに etherが必要です。
  
  --------
#### ファイル名 : youtube_viewcount.sol
#### コントラクト名 : YoutubeCounter
#### *関数の説明*

**YoutubeCounter : コンストラクタ**
- コントラクトディストリビュータをownerに設定します。

**YoutubeViews : YouTubeの映像情報**
- パラメータ関数を利用して、コントラクトを進める映像情報、受取人、ヒットあたりの比率を設定することができます。
- _videoaddress : ターゲットYoutubeアドレス(string)
- _beneficiary : 受取者アドレス(address)
 - _PayPerView : ヒットあたりの転送 ether 割合(uint)

**transfer : ether 伝送モジュール**
- YoutubeViews : 関数を使用して生成させた情報を実行させます。（ether 伝送、単位はwei）
  

#### *パラメータ説明*
- viewsCount : 対象画像のヒット
- amount : 転送wei
- balance : アカウントの残高
- beneficiary : 受取者アドレス
- PayPerView : ヒットあたりの転送率
- videoaddress : ターゲットYoutubeアドレス

-------

------------


## 2. 発行した別のトークンを利用して、YouTubeの再生回数に応じたトークン支給コントラクト
ファイル名 : ERC20.sol と seperated_youtube_viewcount.sol

etherではなく、個別に発行したトークンを送信させるコントラクトです。
ERC20.solを利用して、トークンを作成し、このトークンのコントラクトアドレスを利用してseperated_youtube_viewcount.solを介してトークンをコントロールします。

※注意：Oraclizeを利用するためには、YouTubeの再生回数を収集するためのコントラクトアカウントにプロバイダーが必要です。

------------
#### ファイル名 : ERC-20.sol
#### コントラクト名 : SimpleToken
#### *関数の説明*

**constructor : コンストラクタ**
- INITIAL_SUPPLYの数だけトークンを発行します。
- コントラクトディストリビュータをownerに設定します。
- コントラクトディストリビュータをaddControllersに含めます。

** transfercontract：コントラクトのトークンの転送**
- コントラクトが保有トークンを送信します。
- _toに_valueだけのトークンを送信します。

** transferFrom：AからBにトークン送信**
- アドレスAが保有しているトークンをBに送信します。
- _fromが持つトークンを_toに_valueだけ送信します。

** transfer：msg.senderが付いているトークンを送信**
- 関数を実行させたアカウント（msg.sender）が保有しているトークンを送信します。
- _toに_valueだけのトークンを送信します。


#### *パラメータ説明*
- name：トークンの名前
- symbol：トークンの略
- decimals：トークンの単位
- INITIAL_SUPPLY：最初発行量（設定量*（10^（decimals））
- owner：コントラクトの所有者
- allowedControllers：トークンをコントロールすることができるように許可されたアカウント（以外は、トークンの転送不可）

------------
####ファイル名：seperate_youtube_count.sol
####コントラクト名：YoutubeViews
####*関数の説明*

** YoutubeViewInfo：YouTubeの映像情報**
- パラメータ関数を利用して、コントラクトを進める映像情報、受取人、ヒットあたりの比率を設定することができます。
- _videoaddress：ターゲットYouTubeアドレス（string）
- _beneficiary：受取者アドレス（address）
  - _PayPerView：ヒットごとに送信イーサネット比（uint）

** autotransfer：設定されたトークンの転送**
- YoutubeViewInfoを介して設定された情報を実行

** tokentransferFromTo：AからBにトークン送信**
- アドレスAが保有しているトークンをBに送信します。
- _fromが持つトークンを_toに_valueだけ送信します。

** tokentransferTo：msg.senderが付いているトークンを送信**
- 関数を実行させたアカウント（msg.sender）が保有しているトークンを送信します。
- _toに_valueだけのトークンを送信します。

** tokentransferFomContract：コントラクトのトークンの転送**
- コントラクトが保有トークンを送信します。
- _toに_valueだけのトークンを送信します。




#### *パラメータの説明*
- viewsCount：対象画像のヒット
- amount：転送wei
- balance：アカウントの残高
- beneficiary：受取人アドレス
- PayPerView：ジョフィスあたりの転送率
- videoaddress：ターゲットyoutubeアドレス
- tokenaddress：コントロールするトークンのスマート契約アドレス
