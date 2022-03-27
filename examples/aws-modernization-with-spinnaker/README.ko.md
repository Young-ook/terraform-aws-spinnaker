[[English](README.md)] [[한국어](README.ko.md)]
# 스핀에커와 함께하는 애플리케이션 현대화

![aws-modernization-with-spinnaker](../../images/aws-modernization-with-spinnaker-architecture.png)

## 설치
이 예제는 하시코프(HashCorp)와 스핀에커(Spinnaker)를 활용한 현대 애플리케이션을 구축하는 방법을 보여줍니다. [main.tf](main.tf)은 쿠버네티스(Kubernetes) 클러스터와 인프라스트럭처, 스핀에커를 여러 분의 AWS 계정에 생성하는 테라폼(Terraform) 설정 파일입니다.

다음과 같이 테라폼 명령을 실행합니다:
```
terraform init
terraform apply -target module.foundation
```

별도의 VPC에 데브옵스(DevOps) 플랫폼을 구축하기 위해서 추가로 다음의 명령을 실행합니다:
```
terraform apply -target module.platform
```

## 스핀에커 접속
할야드(Halyard)는 스핀에커 배포 생애주기를 관리하기 위한 명령줄 도구 입니다. 할야드를 활용하여 스핀에거의 각 마이크로서비스를 배포하고 관리할 수 있으며, 환경설정 파일을 중앙 관리할 수 있습니다. 스핀에커는 할야드를 통하여 설치하고, 관리하고 업그레이드 할 수 있습니다. 스핀에커 설치를 위하여 다음 명령을 실행합니다:
```
./halconfig.sh
```

설치가 완료되면, 쿠버네티스 프록시를 통하여 포트 포워딩하도록 다음 스크립트를 실행합니다:
```
./tunnel.sh
```
웹 브라우저를 열고 `http://localhost:8080`를 입력해서 스핀에커에 접속합니다. 만약, Cloud9에서 작업하고 있다면, `Preview`를 누르고, `Preview Running Application`를 누릅니다. 이 메뉴는 미리보기 탭을 생성하고 스핀에커를 띄워줍니다. 스핀에커에 처음 접속하면 다음과 같은 화면을 보게 될 것입니다.

![spinnaker-first-look](../../images/spinnaker-first-look.png)

🎉 축하합니다, 여러 분은 스핀에커를 쿠버네티스 클러스터에 설치하였습니다.

## Spinnaker Pipelines
### Spinnaker Application (Microservice)
스핀에커에 접속해서 보면 오른 쪽 위에 *Create Application* 단추가 있습니다. 눌러서 새 어플리케이션을 생성합니다. 어플리케이션 이름은 *yelb* 로 지정하고 이메일은 본인의 이메일을 입력합니다.

### Base App
### Meshed App
### Weighted Routing

## 정리
실습 자원을 정리하기 위하여 다음 명령을 실행합니다:
```
./preuninstall.sh
terraform destroy --auto-approve
```
