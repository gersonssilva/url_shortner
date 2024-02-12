defmodule UrlShortnerWeb.StatsController do
  use UrlShortnerWeb, :controller

  alias UrlShortner.ShortnedUrls

  def index(conn, params) do
    with {:ok, {shortned_urls, meta}} <- ShortnedUrls.list_shortned_urls(params) do
      render(conn, "index.html", shortned_urls: shortned_urls, meta: meta)
    else
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
end
