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

  def shortned_link(assigns) do
    assigns = assign(assigns, :url, UrlShortnerWeb.Endpoint.url() <> "/" <> assigns.slug)

    ~H"""
    <div>
      <.link href={@url}><%= @url %></.link>
    </div>
    """
  end
end
