FROM node:5.1

# for 'ip a' command
RUN apt-get install -y iproute2

EXPOSE 8080
COPY index.js .
CMD node index.js
