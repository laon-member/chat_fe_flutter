# chat_app

다른 사람들과 인터넷만 있는 곳이라면 언제 어디서든 대화를 나누고 파일과 이미지를 공유하며 서로 추억을 쌓아보세요.
앱의 이름은 Chatting Us 입니다.

## 개선된 점
### 2020년/11월
#### 20201117
* 버튼 아이콘 일부 수정
#### 20201118
* 앱 아이콘 변경, 파일 업로드 기능 구현을 위한 클라우드에 업로드 기능 구현 확인, 하드코딩 소프트코딩으로 전환작업중.
* dependencies 대부분을 가능한한 최신버전으로 전환해 안정적인 연결 및 원활한 작업을 시행할 수 있도록 하였음.
#### 20201119
* 앱의 버전업 및 파일 업로드 후 업로드한 파일이 채팅방에 표시되게끔 구현 완료.
* 쉬운 작업을 위해 하드코딩 되어 있는 일부 내용들 소프트코딩으로 전환작업.
#### 20201120
* 파일 다운로드 추가 및 버그 정비.
#### 20201123
* 중복채팅방 양산을 막기 위해 전용 코드 적용.
* 새로운 쿠퍼티노 아이콘 적용.
* 이미지 구현을 위한 이미지 미리보기(썸네일) 밑작업.
#### 20201124
* 중복채팅방 양산방지 버그 수정.
* 사진 미리보기 보이게 개선.
* 파일 다운로드 안됨현상 개선.
* 릴리즈 준비를 위해 일부 버그 및 코드 안정화 작업.
#### 20201125
##### 1차
* 중복채팅방 양산방지 버그 수정 및 코드 안정화 작업.
* 채팅방 이름 얻기 설정 
##### 2차
* 다운로드 관련 문제 보완
#### 20201126
##### 1차
* 파일 및 이미지 다운로드 구현 확인
* 파일 업로드시 지정된 확장자만 이용 가능(문서, 동영상, 음악 확장자 중 극히 일부)
* 70MB를 초과하는 파일은 업로드 제한
* 10MB를 초과하는 이미지는 파일 업로드로 구현, 20MB를 초과하는 이미지는 업로드 불가하도록 수정
##### 2차
* 최초버전 릴리즈 성공 및 애플리케이션 정보 추가
* 로그인 및 회원가입 텍스트 속성 수정
* 이미지 구현 관련 코드 안정화 작업
#### 20201127
* 키보드 엑션 개선으로 편의성 강화
* SnackBar 활성화로 사용자 소통 향상
* 각종 버그 패치
#### 20201130
* 햅틱효과 개선
* 상태바와 앱 內 색이 동일하게 설정
* Flutter를 최신 버전으로 Upgrade 함에 따라 내부 코드 수정