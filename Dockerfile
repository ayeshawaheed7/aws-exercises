#Build stage
FROM node:20-alpine AS build

WORKDIR /home/app

COPY /app /home/app/

RUN npm ci --only=production

#Run stage
FROM node:20-alpine

EXPOSE 3000

WORKDIR /home/node/app

COPY --chown=node:node --from=build /home/app /home/node/app/

USER node

CMD ["node", "server.js"]
