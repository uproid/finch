FROM uproid/finch:latest AS build
WORKDIR /www/finch

COPY pubspec.yaml ./
RUN dart pub get --no-offline
COPY example/pubspec.yaml ./example/

# Change finch path to local package in example/pubspec.yaml
RUN sed -i 's/finch: ^/finch: #^/' ./example/pubspec.yaml
RUN sed -i 's/# path: ..\//path: ..\//' ./example/pubspec.yaml
RUN dart pub get --directory=./example --no-offline

COPY lib/ ./lib/
COPY bin/ ./bin/
COPY example/lib/ ./example/lib/

# BUILD
RUN dart build cli -t ./example/lib/app.dart -o cli

# USE NGINX
FROM nginx:latest
WORKDIR /var/www/html

COPY docker-live/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /www/finch/cli/bundle/ /var/www/app
COPY example/public ./public
COPY example/migrations/ /var/www/app/migrations/

# START SCRIPT
RUN echo '#!/bin/sh\n/var/www/app/bin/app migrate --init --and migrate_sqlite --init &\nnginx -g "daemon off;"\n' > /start.sh && chmod +x /start.sh

EXPOSE 8086
CMD ["/start.sh"]
