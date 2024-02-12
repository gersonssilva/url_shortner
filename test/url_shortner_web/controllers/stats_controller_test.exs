defmodule UrlShortnerWeb.StatsControllerTest do
  use UrlShortnerWeb.ConnCase
  use UrlShortner.CacheCase

  import UrlShortner.Factory

  alias UrlShortner.Schema.ShortnedUrl

  describe "index" do
    test "renders a table with the shortned urls", %{conn: conn} do
      insert!(:shortned_url, original_url: "url-1", slug: "slug-1")
      insert!(:shortned_url, original_url: "url-2", slug: "slug-2")

      conn = get(conn, ~p"/stats")

      assert html_response(conn, 200) =~ "Shortned URLs Stats"
      assert conn.resp_body =~ "url-1"
      assert conn.resp_body =~ "url-2"
    end

    test "paginates shortned_urls using :after param", %{conn: conn} do
      one_hour_ago =
        DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.truncate(:second)

      insert!(:shortned_url, original_url: "url-1", slug: "slug-1", inserted_at: one_hour_ago)
      shortned_url_2 = insert!(:shortned_url, slug: "slug-2", original_url: "url-2")

      {_start_cursor, end_cursor} =
        Flop.Cursor.get_cursors(
          [shortned_url_2],
          [:inserted_at],
          cursor_value_func: &ShortnedUrl.cursor_value_func/2
        )

      conn = get(conn, ~p"/stats?after=#{end_cursor}")

      assert html_response(conn, 200) =~ "Shortned URLs Stats"
      assert conn.resp_body =~ "url-1"
      refute conn.resp_body =~ "url-2"
    end

    test "paginates shortned_urls using :before param", %{conn: conn} do
      one_hour_ago =
        DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.truncate(:second)

      shortned_url_1 =
        insert!(:shortned_url, original_url: "url-1", slug: "slug-1", inserted_at: one_hour_ago)

      insert!(:shortned_url, slug: "slug-2", original_url: "url-2")

      {start_cursor, _end_cursor} =
        Flop.Cursor.get_cursors(
          [shortned_url_1],
          [:inserted_at],
          cursor_value_func: &ShortnedUrl.cursor_value_func/2
        )

      conn = get(conn, ~p"/stats?before=#{start_cursor}")

      assert html_response(conn, 200) =~ "Shortned URLs Stats"
      refute conn.resp_body =~ "url-1"
      assert conn.resp_body =~ "url-2"
    end

    test "renders bad_request page when an invalid cursor is given", %{conn: conn} do
      conn = get(conn, ~p"/stats?after=invalid-cursor")

      assert html_response(conn, 400) =~ "Bad Request"
    end

    test "renders bad_request page when an invalid limit is given", %{conn: conn} do
      conn = get(conn, ~p"/stats?after=invalid-limit")

      assert html_response(conn, 400) =~ "Bad Request"
    end
  end

  describe "export" do
    test "exports a CSV file with the shortned urls in the current page", %{conn: conn} do
      one_hour_ago =
        DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.truncate(:second)

      shortned_url_1 =
        insert!(:shortned_url,
          original_url: "url-1",
          slug: "slug-1",
          visits_count: 10,
          inserted_at: one_hour_ago
        )

      shortned_url_2 =
        insert!(:shortned_url, original_url: "url-2", slug: "slug-2", visits_count: 20)

      {_start_cursor, end_cursor} =
        Flop.Cursor.get_cursors(
          [shortned_url_2],
          [:inserted_at],
          cursor_value_func: &ShortnedUrl.cursor_value_func/2
        )

      conn = get(conn, ~p"/stats/export?after=#{end_cursor}")

      assert conn.resp_body =~ "id,original_url,visits_count"
      assert conn.resp_body =~ "#{shortned_url_1.id},url-1,10"
      refute conn.resp_body =~ "#{shortned_url_2.id},url-2,20"
    end
  end
end
