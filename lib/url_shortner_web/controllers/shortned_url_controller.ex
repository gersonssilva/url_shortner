defmodule UrlShortnerWeb.ShortnedUrlController do
  use UrlShortnerWeb, :controller

  alias UrlShortner.Schema.ShortnedUrl
  alias UrlShortner.ShortnedUrls

  def new(conn, _params) do
    changeset = ShortnedUrl.create_changeset(%{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"shortned_url" => params}) do
    case ShortnedUrls.create_shortned_url(params) do
      {:ok, shortned_url} ->
        conn
        |> put_flash(:info, "Shortned url created successfully.")
        |> redirect(to: ~p"/shortned_urls/#{shortned_url}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    result = ShortnedUrls.get_shortned_url_by_id(id)

    case result do
      {:error, :not_found} ->
        conn
        |> put_view(UrlShortnerWeb.ErrorHTML)
        |> put_status(:not_found)
        |> render("404.html")

      shortned_url ->
        render(conn, :show, shortned_url: shortned_url)
    end
  end
end
