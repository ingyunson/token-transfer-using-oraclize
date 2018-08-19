token-transfer-using-orzclize
=============================


오라클라이즈를 이용하여 토큰 전송을 하는 스마트 컨트랙트입니다.(아직 미완)

------------


------------


### 1. 유튜브 조회수에 따른 이더 지급 컨트랙트
파일명 : youtube_viewcount.sol    

유튜브 조회수를 기준으로 한 스마트 컨트랙트를 배포할 수 있습니다. 유튜브 동영상 광고나 MCN 사업 등에 응용할 수 있습니다.
대상 유튜브 주소와 이더 수취 주소, 조회수당 전송 이더(wei)를 설정할 수 있습니다.
  
  --------
####파일명 : youtube_viewcount.sol
####컨트랙트명 : YoutubeCounter
#### *함수 설명*

**YoutubeCounter : 생성자**
- 컨트랙트 배포자를 owner로 설정합니다.

**YoutubeViews : 유튜브 영상 정보**
- 매개 함수를 이용하여 컨트랙트를 진행할 영상 정보, 수취자, 조회수 당 비율을 설정할 수 있습니다.
- _videoaddress : 타겟 유튜브 주소(string)
- _beneficiary : 수취자 주소(address)
 - _PayPerView : 조회수 당 전송 이더 비율(uint)

**transfer : 이더 전송 모듈**
- YoutubeViews 함수를 이용하여 생성시킨 정보를 실행시킵니다.(이더 전송, 단위는 wei)
  

####*매개변수 설명*
- viewsCount : 대상 영상의 조회수
- amount : 전송할 wei
- balance : 계정의 잔고
- beneficiary : 수취자 주소
- PayPerView : 조휘수 당 전송 비율
- videoaddress : 타겟 유튜브 주소

-------

------------


## 2. 발행한 별도의 토큰을 이용하여 유튜브 조회수에 따른 토큰 지급 컨트랙트
파일명 : ERC20.sol 및 seperated_youtube_viewcount.sol

이더가 아닌 별도로 발행한 토큰을 전송시키는 컨트랙트입니다.
ERC20.sol을 이용하여 토큰을 만들고, 이 토큰의 컨트랙트 주소를 이용하여 seperated_youtube_viewcount.sol을 통해 토큰을 컨트롤합니다.

------------
####파일명 : ERC-20.sol
#### 컨트랙트명 : SimpleToken
#### *함수 설명*

**constructor : 생성자**
- INITIAL_SUPPLY의 수 만큼 토큰을 발행합니다.
- 컨트랙트 배포자를 owner로 설정합니다.
- 컨트랙트 배포자를 addControllers에 포함시킵니다.

**transfercontract : 컨트랙트의 토큰 전송**
- 컨트랙트가 보유한 토큰을 전송합니다.
- _to에게 _value만큼의 토큰을 전송합니다.

**transferFrom : A에게서 B에게 토큰 전송**
- 주소 A가 보유한 토큰을 B에게 전송합니다.
- _from이 가진 토큰을 _to에게 _value만큼 전송합니다.

**transfer : msg.sender가 가진 토큰을 전송**
- 해당 함수를 실행시킨 계정(msg.sender)이 보유한 토큰을 전송합니다.
- _to에게 _value만큼의 토큰을 전송합니다.


####*매개변수 설명*
- name : 토큰의 이름
- symbol : 토큰의 약자
- decimals : 토큰의 단위
- INITIAL_SUPPLY : 최초 발행량(설정량 * (10^(decimals))
- owner : 컨트랙트의 소유자
- allowedControllers : 토큰을 컨트롤 할 수 있도록 허가받은 계정(이외는 토큰 전송 불가)

------------
####파일명 : seperate_youtube_count.sol
#### 컨트랙트명 : YoutubeViews
#### *함수 설명*

**YoutubeViewInfo : 유튜브 영상 정보**
- 매개 함수를 이용하여 컨트랙트를 진행할 영상 정보, 수취자, 조회수 당 비율을 설정할 수 있습니다.
- _videoaddress : 타겟 유튜브 주소(string)
- _beneficiary : 수취자 주소(address)
 - _PayPerView : 조회수 당 전송 이더 비율(uint)

**autotransfer : 설정된 토큰 전송**
- YoutubeViewInfo를 통해 설정된 정보를 실행

**tokentransferFromTo : A에게서 B에게 토큰 전송**
- 주소 A가 보유한 토큰을 B에게 전송합니다.
- _from이 가진 토큰을 _to에게 _value만큼 전송합니다.

**tokentransferTo : msg.sender가 가진 토큰을 전송**
- 해당 함수를 실행시킨 계정(msg.sender)이 보유한 토큰을 전송합니다.
- _to에게 _value만큼의 토큰을 전송합니다.

**tokentransferFomContract: 컨트랙트의 토큰 전송**
- 컨트랙트가 보유한 토큰을 전송합니다.
- _to에게 _value만큼의 토큰을 전송합니다.




####*매개변수 설명*
- viewsCount : 대상 영상의 조회수
- amount : 전송할 wei
- balance : 계정의 잔고
- beneficiary : 수취자 주소
- PayPerView : 조휘수 당 전송 비율
- videoaddress : 타겟 유튜브 주소
- tokenaddress : 컨트롤할 토큰의 스마트 계약 주소