# ---------- Build Stage ----------
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /build
COPY . .
RUN mvn clean package -DskipTests

# ---------- Runtime Stage ----------
FROM tomcat:9.0-jre21-temurin
LABEL maintainer="piyushnawghare609@gmail.com"

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /build/target/BootStrap.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
