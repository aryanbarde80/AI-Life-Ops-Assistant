# ─────────────────────────────────────────────────────────────────
#  Stage 1: Build Flutter Web
# ─────────────────────────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec files and fetch dependencies first (layer caching)
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy remaining source and build
COPY . .
RUN flutter build web --release \
    --dart-define=API_BASE_URL=http://backend:10000

# ─────────────────────────────────────────────────────────────────
#  Stage 2: Serve with nginx
# ─────────────────────────────────────────────────────────────────
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/app.conf

# Copy Flutter build output
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
