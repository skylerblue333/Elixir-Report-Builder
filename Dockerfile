FROM elixir:1.18-alpine
WORKDIR /app
COPY mix.exs .formatter.exs ./
COPY lib ./lib
COPY test ./test
RUN mix compile --warnings-as-errors && mix test
USER 10001:10001
CMD ["elixir", "-e", "IO.puts(\"sky-report-ready\")"]
