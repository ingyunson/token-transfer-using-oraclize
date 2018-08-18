token-transfer-using-orzclize
=============================


오라클라이즈를 이용하여 토큰 전송을 하는 스마트 컨트랙트입니다.(아직 미완)

## 1. 유튜브 조회수에 따른 이더 지급 컨트랙트
파일명 : youtube_viewcount.sol    

유튜브 조회수를 기준으로 한 스마트 컨트랙트를 배포할 수 있습니다. 유튜브 동영상 광고나 MCN 사업 등에 응용할 수 있습니다.
대상 유튜브 주소와 이더 수취 주소, 조회수당 전송 이더(wei)를 설정할 수 있습니다.


컨트랙트명 : YoutubeViews
함수 설명
Youtubeviews : 컨스트럭터
- _videoaddress : 타겟 유튜브 주소
- _beneficiary : 수취자 주소
- _PayPerView : 조회수 당 전송 이더 비율

(fallback) : 이더 전송 모듈



## 2. 발행한 별도의 토큰을 이용하여 유튜브 조회수에 따른 토큰 지급 컨트랙트
파일명 : ERC20.sol 및 seperated_youtube_viewcount.sol