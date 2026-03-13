FROM dart:stable AS build
WORKDIR /www

ENV WIDGETS_PATH=./lib/widgets
ENV WIDGETS_TYPE=j2.html
ENV LANGUAGE_PATH=./lib/languages
ENV PUBLIC_DIR=./public
ENV LOCAL_DEBUG=true
ENV ENABLE_DATABASE=true

# Install system dependencies
RUN apt-get update -y && apt-get install -y libsqlite3-dev

COPY . .
RUN rm -rf ./.dart_tool
RUN rm -rf ./pubspec.lock

# Create .env file
RUN echo "MYSQL_HOST=mysql" > .env && \
    echo "MONGO_CONNECTION=mongodb" >> .env && \
    echo "MONGO_PORT=27017" >> .env

RUN dart pub cache clean

#RUN chmod -R a+rxw .
RUN dart pub get 
RUN dart pub get --offline
RUN dart pub cache repair
 


EXPOSE 8085 8181

CMD [ "dart","run","--enable-asserts", "--disable-service-auth-codes","/www/lib/serve.dart", "migrate", "--init", "--sqlite" ]