FROM node:10.14.1
ENV PORT=5000
EXPOSE 5000

RUN mkdir /app
WORKDIR /app

COPY package.json .
COPY package-lock.json .
RUN npm install
COPY public/ ./public/
COPY server.js .

ENTRYPOINT npm start
