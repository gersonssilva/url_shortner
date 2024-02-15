defmodule UrlShortnerWeb.StatsController do
  use UrlShortnerWeb, :controller

  alias UrlShortner.ShortnedUrls

  def index(conn, params) do
    case ShortnedUrls.list_shortned_urls(params) do
      {:ok, {shortned_urls, meta}} ->
        render(conn, "index.html", shortned_urls: shortned_urls, meta: meta)

      {:error, %Flop.Meta{errors: errors}} when not is_nil(errors) ->
        conn
        |> put_view(UrlShortnerWeb.ErrorHTML)
        |> put_status(:bad_request)
        |> render("400.html")

      {:error, _} ->
        conn
        |> put_view(UrlShortnerWeb.ErrorHTML)
        |> put_status(:unprocessable_entity)
        |> render("500.html")
    end
  end

  def export(conn, params) do
    {:ok, {shortned_urls, _meta}} = ShortnedUrls.list_shortned_urls(params)

    csv =
      shortned_urls
      |> Stream.map(&Map.take(&1, [:id, :original_url, :visits_count]))
      |> CSV.encode(headers: true)
      |> Enum.to_list()

    conn
    |> send_download({:binary, csv}, filename: "shortned_urls.csv")
  end
end
