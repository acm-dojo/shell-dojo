FROM debian:stable-slim
COPY ./debian-cowsay-bundle/ /packages/
RUN dpkg -i /packages/*.deb
CMD ["cowsay", "Success!"]