ARG NODE_VERSION=20.11.1
ARG YARN_VERSION=1.22.22

FROM node:${NODE_VERSION}-alpine AS node

FROM gravicore/alpine-node-aws-chamber:latest

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

RUN npm install -g yarn --force
RUN yarn -v
RUN node -v

ENTRYPOINT ["/src/main.sh"]
