# Stage 1: Build Angular App
FROM node:18 AS angular-build
WORKDIR /app
COPY fe1/ ./fe1
WORKDIR /app/fe1
RUN npm install && npm run build --prod

# Stage 2: Build Spring Boot App
FROM maven:3.8.6-openjdk-17 AS spring-build
WORKDIR /app
COPY demo/ ./demo
WORKDIR /app/demo
RUN mvn clean package -DskipTests

# Stage 3: Run the application
FROM openjdk:17 AS final
WORKDIR /app
COPY --from=spring-build /app/demo/target/*.jar app.jar

# Copy Angular build to Nginx
FROM nginx:alpine AS nginx
COPY --from=angular-build /app/fe1/dist/fe1/ /usr/share/nginx/html
COPY fe1/nginx.conf /etc/nginx/nginx.conf

# Expose necessary ports
EXPOSE 8080 80

# Start Spring Boot and Nginx
CMD java -jar /app/app.jar & nginx -g 'daemon off;'
