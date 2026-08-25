# Sky Elixir Report Builder

**Status: engineering beta.** A dependency-free Elixir library for rendering deterministic, bounded Markdown reports from in-memory data.

## Implemented behavior

- real Elixir implementation with no third-party Mix dependencies
- report and section title validation
- maximum 50 sections, 10,000 rows per section, 50 columns, and 2,000 bytes per rendered cell
- deterministic alphabetical column ordering
- Markdown table rendering with pipe/newline escaping
- explicit empty-section rendering
- ExUnit coverage for deterministic output, escaping, empty sections, malformed sections, and size limits
- CI gates for warnings-as-errors compilation, formatter verification, tests, container build, non-root runtime verification, and container smoke execution

## Verify

```bash
mix compile --warnings-as-errors
mix format --check-formatted
mix test
```

## Example

```elixir
{:ok, report} =
  SkyReport.build("Weekly Report", [
    %{
      title: "Users",
      rows: [
        %{id: 1, name: "Alice"},
        %{id: 2, name: "Bob"}
      ]
    }
  ])

IO.puts(report)
```

## SKYCOIN4444 integration

Use this as a presentation primitive for deterministic internal summaries, analytics snapshots, education reports, workflow summaries, or developer tooling after data has already been authorized and prepared by the owning service. Keep data fetching, authorization, persistence, and delivery outside the renderer.

## Explicit limitations

This repository is not a BI platform, report scheduler, template-execution engine, HTML/PDF renderer, email delivery service, database connector, dashboard product, or production deployment. It does not fetch remote data, execute user code, write files, authenticate callers, authorize fields, redact sensitive information, or provide tenant isolation.

Markdown output should still be treated as untrusted content when later embedded into HTML or another active rendering context; downstream renderers must apply their own escaping/sanitization rules.

See `SECURITY.md` and `CHANGELOG.md` for product and security boundaries.
