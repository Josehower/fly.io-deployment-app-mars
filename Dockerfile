# Install dependencies only when needed
FROM node:16-alpine AS builder
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY . .
RUN yarn install --frozen-lockfile

# If using npm with a `package-lock.json` comment out above and use below instead
# RUN npm ci

ENV NEXT_TELEMETRY_DISABLED 1

# Add `ARG` instructions below if you need `NEXT_PUBLIC_` variables
# then put the value on your fly.toml
# Example:
# ARG NEXT_PUBLIC_EXAMPLE="value here"

RUN yarn build

# If using npm comment out above and use below instead
# RUN npm run build

# Production image, copy all the files and run next
FROM node:16-alpine AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN apk add postgresql
RUN mkdir -p /run/postgresql/data/
RUN chown postgres:postgres /run/postgresql/data /run/postgresql/
RUN su postgres -c "initdb -D /run/postgresql/data"
RUN echo "host all all 0.0.0.0/0 trust" >> /run/postgresql/data/pg_hba.conf
RUN echo "listen_addresses='*'" >> /run/postgresql/data/postgresql.conf


COPY --from=builder /app ./


ENV PORT 8080

# use fly-postbuild instead of start on projects using postgres
CMD ["yarn", "fly-postbuild"]
#CMD ["yarn", "start"]