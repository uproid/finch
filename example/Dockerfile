FROM uproid/finch:latest AS build
WORKDIR /www/example

ENV WIDGETS_PATH=./lib/widgets
ENV WIDGETS_TYPE=j2.html
ENV LANGUAGE_PATH=./lib/languages
ENV PUBLIC_DIR=./public
ENV LOCAL_DEBUG=true
ENV ENABLE_DATABASE=true

COPY pubspec.yaml ./
RUN dart pub get --no-offline
COPY lib/ ./lib/

# Create .env file
RUN echo "MYSQL_HOST=mysql" > .env && \
    echo "MONGO_CONNECTION=mongodb" >> .env && \
    echo "MONGO_PORT=27017" >> .env

EXPOSE 8085 8181

CMD ["finch", "serve", "-p", "/www/example/lib/serve.dart", "--args=\"migrate --init --sqlite\""]