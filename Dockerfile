FROM --platform=$BUILDPLATFORM node:18.20.8 as build
ARG TARGETPLATFORM
ARG BUILDPLATFORM

WORKDIR /peer-server
COPY package.json package-lock.json ./
RUN npm clean-install

COPY . ./

ENV NODE_ENV=production

RUN npm run build
RUN npm run test

FROM node:18.20.8-alpine as production

WORKDIR /peer-server
COPY package.json package-lock.json ./
RUN npm clean-install --omit=dev
COPY --from=build /peer-server/dist/bin/peerjs.js ./

ENV PORT=8080
ENV NODE_ENV=production

EXPOSE 8080

#ENTRYPOINT ["node", "peerjs.js"]
ENTRYPOINT ["node", "peerjs.js", "--proxied", "--path=/"]
