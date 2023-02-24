FROM debian:bullseye-slim as build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl zip unzip git

RUN curl -o godot.zip https://downloads.tuxfamily.org/godotengine/4.0/rc3/Godot_v4.0-rc3_linux.x86_64.zip && \
    curl -o templates.tpz https://downloads.tuxfamily.org/godotengine/4.0/rc3/Godot_v4.0-rc3_export_templates.tpz && \
    unzip godot.zip && \
    mv Godot_v4.0-rc3_linux.x86_64 /usr/local/bin/godot && \
    unzip templates.tpz && \
    mkdir -p ~/.local/share/godot/export_templates/4.0.rc3 && \
    mv templates/* ~/.local/share/godot/export_templates/4.0.rc3/.

CMD echo hello

###############################################################################

FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=build /usr/bin/git /usr/bin/git
COPY --from=build /usr/local/bin/godot /usr/local/bin/godot
COPY --from=build /root/.local/share/godot/export_templates/4.0.rc3 /root/.local/share/godot/export_templates/4.0.rc3

RUN git config --global --add safe.directory '*'

CMD echo hello
