FROM dart:stable AS build
WORKDIR /www/finch

RUN apt-get update -y && apt-get install -y libsqlite3-dev

COPY pubspec.yaml ./
COPY lib/ ./lib/
COPY example/pubspec.yaml ./example/

RUN dart pub get --directory=./example --no-offline

EXPOSE 8085 8181


# Create startup script that ensures dependencies are installed from volume
RUN echo '#!/bin/bash\n\
cd /www/finch\n\
dart pub get --no-offline\n\
dart pub get --directory=./example --no-offline\n\
exec dart run --enable-asserts --disable-service-auth-codes /www/finch/example/lib/serve.dart --no-debug migrate --init --sqlite\n\
' > /startup.sh && chmod +x /startup.sh

CMD ["/startup.sh"]