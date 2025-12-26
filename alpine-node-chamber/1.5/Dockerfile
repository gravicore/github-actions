ARG NODE_VERSION=20.18.1
ARG YARN_VERSION=1.22.22

FROM node:${NODE_VERSION}-alpine AS node

FROM gravicore/alpine-node-aws-chamber:latest

ARG YARN_VERSION

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

RUN rm -f /usr/local/bin/yarn /usr/local/bin/yarnpkg && \
    corepack enable && \
    corepack prepare yarn@${YARN_VERSION} --activate

RUN node --version
RUN yarn --version

ENTRYPOINT ["/src/main.sh"]
