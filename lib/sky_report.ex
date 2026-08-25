defmodule SkyReport do
  @moduledoc """
  Deterministic, bounded Markdown report rendering from in-memory data.

  This module is a presentation primitive. It does not fetch data, execute
  templates, render HTML/PDF, or write files on behalf of the caller.
  """

  @max_sections 50
  @max_rows 10_000
  @max_columns 50
  @max_cell_bytes 2_000
  @max_title_bytes 200

  @type section :: %{required(:title) => String.t(), required(:rows) => [map()]}

  @spec build(String.t(), [section()]) :: {:ok, String.t()} | {:error, String.t()}
  def build(title, sections) when is_binary(title) and is_list(sections) do
    with :ok <- validate_title(title),
         :ok <- validate_sections(sections) do
      body = sections |> Enum.map(&render_section/1) |> Enum.join("\n\n")
      {:ok, "# #{escape_text(title)}\n\n#{body}\n"}
    end
  end

  def build(_title, _sections), do: {:error, "title must be a string and sections must be a list"}

  defp validate_title(title) do
    cond do
      String.trim(title) == "" ->
        {:error, "report title is required"}

      byte_size(title) > @max_title_bytes ->
        {:error, "report title exceeds #{@max_title_bytes} bytes"}

      true ->
        :ok
    end
  end

  defp validate_sections(sections) when length(sections) <= @max_sections do
    Enum.reduce_while(sections, :ok, fn section, :ok ->
      case validate_section(section) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_sections(_sections), do: {:error, "report exceeds #{@max_sections} sections"}

  defp validate_section(%{title: title, rows: rows}) when is_binary(title) and is_list(rows) do
    cond do
      String.trim(title) == "" or byte_size(title) > @max_title_bytes ->
        {:error, "section title must contain 1-#{@max_title_bytes} bytes"}

      length(rows) > @max_rows ->
        {:error, "section exceeds #{@max_rows} rows"}

      Enum.any?(rows, &(not is_map(&1))) ->
        {:error, "section rows must be maps"}

      true ->
        validate_columns_and_cells(rows)
    end
  end

  defp validate_section(_section), do: {:error, "each section requires title and rows"}

  defp validate_columns_and_cells(rows) do
    columns = rows |> Enum.flat_map(&Map.keys/1) |> Enum.map(&to_string/1) |> Enum.uniq()

    cond do
      length(columns) > @max_columns ->
        {:error, "section exceeds #{@max_columns} columns"}

      Enum.any?(rows, &invalid_cell?/1) ->
        {:error, "cell exceeds #{@max_cell_bytes} bytes"}

      true ->
        :ok
    end
  end

  defp invalid_cell?(row) do
    Enum.any?(row, fn {_key, value} -> byte_size(render_value(value)) > @max_cell_bytes end)
  end

  defp render_section(%{title: title, rows: []}) do
    "## #{escape_text(title)}\n\n_No rows._"
  end

  defp render_section(%{title: title, rows: rows}) do
    columns =
      rows |> Enum.flat_map(&Map.keys/1) |> Enum.map(&to_string/1) |> Enum.uniq() |> Enum.sort()

    header = "| " <> Enum.join(Enum.map(columns, &escape_cell/1), " | ") <> " |"
    divider = "| " <> Enum.join(Enum.map(columns, fn _ -> "---" end), " | ") <> " |"

    lines =
      Enum.map(rows, fn row ->
        values =
          Enum.map(columns, fn column ->
            value =
              Enum.find_value(row, "", fn {key, value} ->
                if to_string(key) == column, do: {:found, value}, else: nil
              end)

            case value do
              {:found, found} -> escape_cell(render_value(found))
              "" -> ""
            end
          end)

        "| " <> Enum.join(values, " | ") <> " |"
      end)

    Enum.join(["## #{escape_text(title)}", "", header, divider | lines], "\n")
  end

  defp render_value(nil), do: ""
  defp render_value(value) when is_binary(value), do: value

  defp render_value(value) when is_atom(value) or is_number(value) or is_boolean(value),
    do: to_string(value)

  defp render_value(value), do: inspect(value, limit: 50, printable_limit: @max_cell_bytes)

  defp escape_text(value), do: value |> String.replace("\r", " ") |> String.replace("\n", " ")

  defp escape_cell(value) do
    value
    |> escape_text()
    |> String.replace("|", "\\|")
  end
end
