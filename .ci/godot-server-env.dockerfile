FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

ADD .artifact/game-linux/install /app

CMD /app/brawler.x86_64 --headless
