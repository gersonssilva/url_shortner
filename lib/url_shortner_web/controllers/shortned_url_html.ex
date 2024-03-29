defmodule UrlShortnerWeb.ShortnedUrlHTML do
  use UrlShortnerWeb, :html

  embed_templates "shortned_url_html/*"

  @doc """
  Renders a shortned_url form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def shortned_url_form(assigns)

  @doc """
  Renders a shortned_url link.
  """

  attr :slug, :string, required: true
  slot :inner_block, required: false

  def shortned_link(assigns) do
    url =
      [
        UrlShortnerWeb.Endpoint.url(),
        "/",
        assigns.slug
      ]
      |> Enum.join("")

    assigns = assign(assigns, :url, url)

    ~H"""
    <div class="mt-5">
      <.link href={@url} class="text-blue-500 font-semibold"><%= @url %></.link>
    </div>
    """
  end
end
