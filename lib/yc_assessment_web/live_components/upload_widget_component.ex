defmodule YCWeb.UploadWidgetComponent do
  use YCWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <button
        id="upload-widget"
        phx-hook="UploadWidget"
        data-cloud-name="dmltj6voz"
        data-cloud-preset="preset1"
      >
        Upload Image
      </button>
      <%= if @image_url do %>
        <img src={@image_url} alt="Uploaded Image" />
      <% end %>
    </div>
    """
  end

  def update(assigns, socket) do
    IO.inspect(Application.get_env(:yc_assessment, :cloudinary)[:cloud_name])
    IO.inspect(Application.get_env(:yc_assessment, :cloudinary)[:upload_preset])
    {:ok, assign(socket, image_url: assigns.image_url)}
  end
end
