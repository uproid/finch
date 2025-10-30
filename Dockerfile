FROM dart:stable AS build
WORKDIR /www/finch

# Install system dependencies
RUN apt-get update -y && apt-get install -y libsqlite3-dev

# Copy only pubspec files first for better Docker layer caching
COPY pubspec.yaml ./
COPY example/pubspec.yaml ./example/

# Get dependencies
RUN dart pub get --no-offline
RUN dart pub get --directory=./example --no-offline

EXPOSE 8085 8181

# Create startup script that ensures dependencies are installed from volume
RUN echo '#!/bin/bash\n\
cd /www/finch\n\
dart pub get --no-offline\n\
dart pub get --directory=./example --no-offline\n\
exec dart run --enable-asserts --observe=8181 --enable-vm-service --disable-service-auth-codes /www/finch/example/lib/watcher.dart migrate --init --sqlite\n\
' > /startup.sh && chmod +x /startup.sh

CMD ["/startup.sh"]