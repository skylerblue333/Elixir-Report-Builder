# Security Policy

Sky Elixir Report Builder is an engineering-beta presentation library, not an authorization or sanitization boundary for downstream active content.

The renderer bounds report structure and cell size, performs no network access, loads no templates or plugins, executes no user code, and escapes Markdown table delimiters/newlines for deterministic table output. The active project has no third-party Mix dependencies and the container runs as a non-root UID.

Callers remain responsible for deciding which data may appear in a report, redacting secrets or regulated fields, and applying context-appropriate escaping if Markdown is converted to HTML or another active format. This library does not authenticate users, authorize fields, isolate tenants, encrypt output, persist audit records, or deliver reports.

Report vulnerabilities privately through GitHub security reporting when available. Do not publish private report content, credentials, or working exploit details in public issues.
