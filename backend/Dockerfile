FROM node:20-slim

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .
RUN npm run build 

# Hono/Node adapter listener
CMD ["node", "dist/index.js"] 
