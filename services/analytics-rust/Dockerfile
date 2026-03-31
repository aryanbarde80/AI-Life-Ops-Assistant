FROM rust:1.75-slim as builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
WORKDIR /app
COPY --from=builder /app/target/release/acos-analytics-rust .
EXPOSE 8004
CMD ["./acos-analytics-rust"]
