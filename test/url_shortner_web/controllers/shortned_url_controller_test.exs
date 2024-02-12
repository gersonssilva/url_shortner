defmodule UrlShortnerWeb.ShortnedUrlControllerTest do
  use UrlShortnerWeb.ConnCase
  use UrlShortner.CacheCase

  import UrlShortner.Factory

  alias UrlShortner.Repo

  describe "new" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Shorten a long link"
    end
  end

  describe "show" do
    test "renders link", %{conn: conn} do
      shortned_url = insert!(:shortned_url, original_url: "https://example.com", slug: "my-slug")
      conn = get(conn, ~p"/shortned_urls/#{shortned_url.id}")

      assert html_response(conn, 200) =~ "http://localhost:4002/#{shortned_url.slug}"
    end

    test "renders 404 when shortned url is not found", %{conn: conn} do
      conn = get(conn, ~p"/shortned_urls/1")

      assert html_response(conn, 404) =~ "Page Not Found\n"
    end
  end

  describe "create" do
    test "redirects to show when data is valid", %{conn: conn} do
      create_attrs = %{original_url: "https://example.com"}
      conn = post(conn, ~p"/shortned_urls", shortned_url: create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/shortned_urls/#{id}"

      conn = get(conn, ~p"/shortned_urls/#{id}")
      assert html_response(conn, 200) =~ "Here's your shortened URL!"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{original_url: ""}

      conn = post(conn, ~p"/shortned_urls", shortned_url: invalid_attrs)

      assert html_response(conn, 200) =~
               "Oops, something went wrong! Please check the errors below"
    end
  end

  describe "redirection" do
    test "redirects to original url", %{conn: conn} do
      insert!(:shortned_url, original_url: "https://example.com", slug: "my-slug")
      conn = get(conn, ~p"/my-slug")

      assert redirected_to(conn, 301) == "https://example.com"

      # Small wait for the Cachex process to finish using the DB connection,
      # avoiding error logs during tests
      Process.sleep(100)
    end

    test "increments visits count", %{conn: conn} do
      shortned_url = insert!(:shortned_url, original_url: "https://example.com", slug: "my-slug")
      conn = get(conn, ~p"/my-slug")

      assert redirected_to(conn, 301) == "https://example.com"

      Liveness.eventually(
        fn ->
          assert shortned_url = Repo.reload!(shortned_url)
          assert shortned_url.visits_count == 1
        end,
        250,
        2
      )
    end

    test "renders 404 when shortned url is not found", %{conn: conn} do
      conn = get(conn, ~p"/not-found")

      assert html_response(conn, 404) =~ "Page Not Found\n"
    end
  end
end
