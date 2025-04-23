FROM python:3.9-alpine3.13
LABEL maintainer="seok.com"

ENV PYTHONUNBUFFERED 1

# 종속성 패키지 목록을 작성한 텍스트파일을 도커에 복사하여 가지고온다.
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8900

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

#RUN python -m venv /py && \ 파이썬 가상환경 생성
#    /py/bin/pip install --upgrade pip && \ 파이썬 pip 업데이트
#    /py/bin/pip install -r /tmp/requirements.txt && \ 파이썬 패키지(의존성) 설치
#    rm -rf /tmp && \ 이제 필요없어진 종속성텍스트파일 삭제
#    adduser \ User Command ADD 를 호출하며 이미지 안에 새 사용자를 추가한다. ( root 사용자를 안 써야 하기 때문 )
#        --disabled-password \
#        --no-create-home \
#        django-user

# 이미지 내의 환경변수 설정
# 위 파이썬 가상환경 위치를 환경변수에 추가하여 컨테이너에서 파이썬을 실행할때 가상환경으로 생성한 파이썬을 실행하도록 함.
ENV PATH="/py/bin:$PATH"

# 컨테이너에서 실행할 사용자를 지정
# 이 명령어를 실행하기 전까지의 명령어들은 모두 root 사용자로 작업된다.
USER django-user