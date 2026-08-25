defmodule SkyReportTest do
  use ExUnit.Case, async: true

  test "renders deterministic sorted columns and rows" do
    assert {:ok, report} =
             SkyReport.build("Weekly Report", [
               %{
                 title: "Users",
                 rows: [
                   %{name: "Alice", id: 1},
                   %{name: "Bob", id: 2}
                 ]
               }
             ])

    assert report =~ "# Weekly Report"
    assert report =~ "| id | name |"
    assert report =~ "| 1 | Alice |"
    assert report =~ "| 2 | Bob |"
  end

  test "escapes markdown table delimiters and newlines" do
    assert {:ok, report} =
             SkyReport.build("Safe", [
               %{title: "Notes", rows: [%{value: "a|b\nnext"}]}
             ])

    assert report =~ "a\\|b next"
  end

  test "renders empty sections explicitly" do
    assert {:ok, report} = SkyReport.build("Empty", [%{title: "No data", rows: []}])
    assert report =~ "_No rows._"
  end

  test "rejects invalid titles and oversized cells" do
    assert {:error, _} = SkyReport.build("", [])

    assert {:error, _} =
             SkyReport.build("Report", [
               %{title: "Too large", rows: [%{value: String.duplicate("x", 2_001)}]}
             ])
  end

  test "rejects malformed sections" do
    assert {:error, _} = SkyReport.build("Report", [%{title: "Missing rows"}])
    assert {:error, _} = SkyReport.build("Report", [%{title: "Rows", rows: ["not a map"]}])
  end
end
