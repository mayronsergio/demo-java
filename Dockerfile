# ---------------------------------------------------------
# ETAPA 1: BUILDER (Compilação do Código Java com Maven)
# TAG CORRIGIDA: Usando uma tag padrão do Maven que inclui Corretto JDK 17
# ---------------------------------------------------------
FROM maven:3.9.5-amazoncorretto-17 AS builder

WORKDIR /build

COPY pom.xml .
COPY src src

RUN mvn clean package -DskipTests

# ---------------------------------------------------------
# ETAPA 2: AGENT FETCHER (Baixa o Agente APM)
# TAG CORRIGIDA: Usando alpine:3.18 e instalando o curl (Já fizemos, mas mantendo a precisão)
# ---------------------------------------------------------
FROM alpine:3.18 AS agent-fetcher 

RUN apk update && apk add --no-cache curl

ARG APM_AGENT_VERSION=1.42.0

RUN curl -L -o /elastic-apm-agent.jar https://repo1.maven.org/maven2/co/elastic/apm/elastic-apm-agent/${APM_AGENT_VERSION}/elastic-apm-agent-${APM_AGENT_VERSION}.jar

# ---------------------------------------------------------
# ETAPA 3: FINAL (Criação da Imagem de Execução)
# ---------------------------------------------------------
FROM amazoncorretto:17-alpine

WORKDIR /app

COPY --from=builder /build/target/demo-0.0.1-SNAPSHOT.jar /app/app.jar
COPY --from=agent-fetcher /elastic-apm-agent.jar /app/elastic-apm-agent.jar

ENV APM_SERVICE_NAME=java-demo-docker
ENV APM_SERVER_URL=https://workspace-dev-apm.gjpc4l.easypanel.host
ENV SERVER_PORT=8080
ENV APM_VERIFY_SERVER_CERT=false

CMD java -javaagent:/app/elastic-apm-agent.jar \
     -Delastic.apm.service_name=${APM_SERVICE_NAME} \
     -Delastic.apm.server_url=${APM_SERVER_URL} \
     -Delastic.apm.verify_server_cert=${APM_VERIFY_SERVER_CERT} \
     -Dserver.port=${SERVER_PORT} \
     -jar /app/app.jar

EXPOSE 8080