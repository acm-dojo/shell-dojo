FROM pwncollege/challenge-simple
COPY ./cowsay-bundle/ /packages/
RUN dpkg -i /packages/*.deb
CMD ["cowsay", "Success!"]