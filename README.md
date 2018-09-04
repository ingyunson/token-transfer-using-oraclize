

# token-transfer-using-orzclize

[日本語版](./README_jp.md)  
[English version](./README_eng.md)
  
[Oraclize](https://github.com/oraclize/ethereum-api)를 이용하여 토큰 전송을 하는 스마트 컨트랙트입니다.
하나의 토큰 컨트랙트와 네 가지의 유튜브 카운터를 이용한 컨트랙트가 있습니다.

- `ERC20.sol`   토큰 컨트랙트입니다. [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-solidity)의 ERC20 컨트랙트를 사용하였습니다.
- `youtube_viewcount.sol` 유튜브 영상 조회수에 따른 이더 지급용 컨트랙트입니다.
- `timer_youtube_viewcount.sol` 유튜브 영상 조회수에 따른 이더 지급용 컨트랙트입니다. 컨트랙트 생성 후 일정 시간 뒤에 다시 조회수를 측정하여 설정된 시간동안 조회된 영상 조회수만큼 이더를 지급합니다.
- `token_youtube_viewcount.sol` 유튜브 영상 조회수에 해당하는 수량의 ERC20.sol을 통해 생성된 토큰을 지급하는 컨트랙트입니다.
- `token_timer_youtube_viewcount.sol` 유튜브 영상 조회수에 따른 토큰 지급용 컨트랙트입니다. 컨트랙트 생성 후 일정 시간 뒤에 다시 조회수를 측정하여 설정된 시간동안 조회된 영상 조회수만큼 토큰을 지급합니다.

## 사용 예시
유튜브 조회수를 기준으로 한 스마트 컨트랙트를 배포할 수 있습니다. 유튜브 동영상 광고나 MCN 사업 등에 응용할 수 있습니다.

------------

### 공통사항

#### 매핑에 대하여
`index`매핑은 받는 사람의 주소를 기준으로 하여 x번째에 위치하는 전송 기록에 해당하는 `idx`변수를 불러옵니다.
`transaction_rec` 매핑은 `idx`변수에 해당하는 `transaction` 구조체의 내용들을 불러옵니다.

예를 들면, `0xca35b7d915458ef540ade6068dfe2f44e8fa733c`라는 주소에게 다섯 번 전송을 실행했다면 `0xca35b7d915458ef540ade6068dfe2f44e8fa733c`에는 1부터 5까지의 `idx_num`이 배정됩니다. 그러므로 `index[#1][#2]`에서 #1의 위치에 수신자의 address를, #2에 조회하고자 하는 회차의 전송 순서를 입력하면 전체 전송 기록 중 해당 전송이 몇 번째에 이루어졌는지(`idx`)를 알 수 있습니다.
이렇게 알게 된 `idx` 기록을 이용하여 세부적인 전송 내역을 불러올 수 있습니다.

`transaction` 구조체의 세부적인 내용은 다음과 같습니다.

- `blocknum` 해당 거래가 승인된 블록 번호
- `blocktime` 해당 거래가 승인된 블록 시간
- `viewrate` 조회수 1당 전송하는 이더/토큰의 비율
- `receiver` 전송을 받는 사람의 주소
- `amount_of_transfer` 전송된 이더/토큰의 총량
- `targetaddress` 대상이 되는 유튜브 영상 주소

#### ※ Oraclize를 2회 이상 이용하기 위해서는 컨트랙트 계정에 이더가 들어 있어야 합니다.

------
----


### 1. 유튜브 조회수에 따른 이더 지급 컨트랙트
파일명 :` youtube_viewcount.sol`

대상 유튜브 주소와 이더 수취 주소, 조회수당 전송 이더 비율(wei)를 설정할 수 있습니다.


  
  --------
#### 컨트랙트명 : `YoutubeCounter`
#### *함수 설명*

`YoutubeCounter` 생성자
- 컨트랙트 배포자를 owner로 설정합니다.

`YoutubeViews` 유튜브 영상 정보
- 매개 변수를 이용하여 컨트랙트를 진행할 영상 정보, 수취자, 조회수 당 비율을 설정할 수 있습니다.
- _videoaddress : 타겟 유튜브 주소(string)
- _beneficiary : 수취자 주소(address)
 - _PayPerView : 조회수 당 전송 이더 비율(uint)

`ethertransfer` 이더 전송 모듈
- YoutubeViews 함수를 이용하여 생성시킨 정보를 실행시킵니다.(이더 전송, 단위는 wei)
- 전송 내역을 `transaction`구조체에 입력합니다.
  
 `refund`환불 모듈
 - 컨트랙트에 있는 이더를 owner에게 반환합니다


----
----
## 2. 타이머가 있는 유튜브 조회수에 따른 이더 지급 컨트랙트

파일명 : `timer_youtube_viewcount.sol`

특정 시점(A)을 기준으로 하여 선언한 시간 뒤(B)의 조회수를 재측정하는 것으로 두 시간 사이의 성과를 측정하여 그 성과에 기반한 이더를 지급하는 컨트랙트입니다.
기본적인 구조는 *1. 유튜브 조회수에 따른 이더 지급 컨트랙트*와 같으며 차이가 있는 부분만을 설명합니다.

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

----
----


## 3. 발행한 별도의 토큰을 이용하여 유튜브 조회수에 따른 토큰 지급 컨트랙트
파일명 : `ERC20.sol` 및 `token_youtube_viewcount.sol`

이더가 아닌 별도로 발행한 토큰을 전송시키는 컨트랙트입니다. `ERC20.sol`을 이용하여 토큰을 만들고, 이 토큰의 컨트랙트 주소를 이용하여 `token_youtube_viewcount.sol`을 통해 토큰을 컨트롤합니다.

※ 주의 : Oraclize를 이용하기 위해서는 유튜브 조회수 수집을 위한 컨트랙트 계정에 이더가 있어야 합니다.

------------
#### 파일명 : `ERC-20.sol`
#### 컨트랙트명 : `SimpleToken`
#### *함수 설명*

**`constructor`  생성자**
- INITIAL_SUPPLY의 수 만큼 토큰을 발행합니다.
- 컨트랙트 배포자를 owner로 설정합니다.
- 컨트랙트 배포자를 addControllers에 포함시킵니다.

**`addControllers`** 토큰 전송 권리 설정
- 토큰을 전송하는 컨트랙트 혹은 사용자가 `controller`에 속하지 않으면 토큰을 전송할 수 없습니다.
- 토큰 전송 권한을 부여하고 싶은 주소를 매개변수 `controller`에  입력합니다.

**`tokentransfer` 컨트랙트의 토큰 전송**
- 컨트랙트가 보유한 토큰을 전송합니다.
- _to에게 _value만큼의 토큰을 전송합니다.

**`transferFrom` : A에게서 B에게 토큰 전송**
- 주소 A가 보유한 토큰을 B에게 전송합니다.
- _from이 가진 토큰을 _to에게 _value만큼 전송합니다.

**`transfer` : msg.sender가 가진 토큰을 전송**
- 해당 함수를 실행시킨 계정(msg.sender)이 보유한 토큰을 전송합니다.
- _to에게 _value만큼의 토큰을 전송합니다.




#### *매개변수 설명*
- `name` : 토큰의 이름
- `symbol` : 토큰의 약자
- `decimals` : 토큰의 단위
- `INITIAL_SUPPLY` : 최초 발행량(설정량 * (10^(decimals))
- `owner` : 컨트랙트의 소유자
- `allowedControllers` : 토큰을 컨트롤 할 수 있도록 허가받은 계정(이외는 토큰 전송 불가)

------------
#### 파일명 : `token_youtube_count.sol`
#### 컨트랙트명 : `YoutubeViews`
#### *함수 설명*

**`YoutubeViewInfo` 유튜브 영상 정보**
- 매개 함수를 이용하여 컨트랙트를 진행할 영상 정보, 수취자, 조회수 당 비율을 설정할 수 있습니다.
- _videoaddress : 타겟 유튜브 주소(string)
- _beneficiary : 수취자 주소(address)
 - _PayPerView : 조회수 당 전송 이더 비율(uint)

**`tokentransfer` 설정된 토큰 전송**
- YoutubeViewInfo를 통해 설정된 정보를 실행하여 토큰을 전송
- 전송시 정보를 `index`와 `transaction_rec`에 기록

※ **주의점** : `ERC20.sol`을 통해 발행한 토큰의 컨트랙트 주소를 직접 입력해야 합니다.

    address public tokenaddress = 0xee9c3a618d8786c6343fc079a75462839b3a673b;
   
24행의 위 코드에서 = 뒤에 토큰의 컨트랙트 주소를 입력해야만 작동합니다. 또한,` YoutubeViews` 컨트랙트가` ERC20` 컨트랙트에서 `addControllers`함수를 통해 `controller`로 등록되어야 합니다. 



#### *매개변수 설명*
- `viewsCount` : 대상 영상의 조회수
- `amount `: 전송할 wei
- `balance` : 계정의 잔고
- `beneficiary` : 수취자 주소
- `PayPerView` : 조회수 당 전송 비율
- `videoaddress` : 타겟 유튜브 주소
- `tokenaddress` : 컨트롤할 토큰의 스마트 계약 주소
----
----

## 4. 타이머가 있는  발행한 별도의 토큰을 이용하여 유튜브 조회수에 따른 토큰 지급 컨트랙트

#### 파일명 : `timer_token_youtube_count.sol`

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
