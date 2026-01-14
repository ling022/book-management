# 使用Java 7的基础镜像
FROM openjdk:7-jre

# 设置工作目录
WORKDIR /app

# 复制JAR文件
COPY target/book-management-system-1.0.0.jar app.jar

# 创建上传目录
RUN mkdir -p /tmp/uploads/book_images

# 暴露端口
EXPOSE 8080

# 运行命令
ENTRYPOINT ["java", "-Djava.io.tmpdir=/tmp", "-jar", "app.jar"]