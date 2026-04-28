# ---------- Build Stage ----------
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---------- Runtime Stage ----------
FROM node:20-alpine
WORKDIR /app
COPY --from=build /app/.next ./.next
# Copy public assets only if they exist
RUN mkdir -p public

COPY --from=build /app/package*.json ./
RUN adduser -D appuser
USER appuser
EXPOSE 3000
HEALTHCHECK CMD wget --spider [localhost](http://localhost:3000/) || exit 1
CMD ["npm", "start"]

