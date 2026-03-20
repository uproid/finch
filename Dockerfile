FROM uproid/finch:latest AS build
WORKDIR /www/finch

COPY pubspec.yaml ./
RUN dart pub get --no-offline
COPY example/pubspec.yaml ./example/
RUN dart pub get --directory=./example --no-offline

COPY lib/ ./lib/
COPY bin/ ./bin/

RUN dart pub global activate --source path . --overwrite

EXPOSE 8085 8181

CMD ["finch", "serve", "-p", "/www/finch/example/lib/serve.dart", "--args=\"migrate --init --sqlite\""]