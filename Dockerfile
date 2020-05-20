FROM node:8-alpine as builder

## Install build toolchain, install node deps and compile native add-ons
RUN apk add --no-cache python make g++
COPY package*.json .
RUN npm install --save-dev


FROM node:8-alpine as app
LABEL author=pk13055 version=1.0

ARG DEBUG=1

ENV DEBUG=$DEBUG
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin:/home/node/app/node_modules/.bin

RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
USER node

COPY --chown=node:node --from=builder node_modules .
COPY --chown=node:node . .
# fix for fiber exec not found
RUN npm uninstall fibers \
 && npm install fibers

EXPOSE 8080
ENTRYPOINT ["./entrypoint.sh"]
