FROM mcr.microsoft.com/dotnet/core/sdk:3.1

RUN apt update && \
	apt install -y libfontconfig1 && \
	rm -rf /var/cache/apt/archive


#ADD https://www.deb-multimedia.org/pool/main/o/openh264-dmo/libopenh264-5_2.0.0-dmo1_amd64.deb /root/
#RUN dpkg -i /root/libopenh264-5_2.0.0-dmo1_amd64.deb
## Need OpenH264 v1.7...

WORKDIR /opt/liveswitch

COPY config-tool  ./config-tool
COPY gateway ./gateway
COPY media-server ./media-server
COPY sip-connector ./sip-connector

COPY  wrapper.sh ./

CMD ./wrapper.sh