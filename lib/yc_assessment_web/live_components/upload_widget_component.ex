defmodule YCWeb.UploadWidgetComponent do
  use YCWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="text-center">
      <label>Profile Picture</label>
      <div class="flex justify-center">
        <.picture_preview picture={@image_url} persona={@persona} />
      </div>
      <div>
        <.button
          id="upload-widget"
          phx-hook="UploadWidget"
          data-cloud-name="dmltj6voz"
          data-cloud-preset="preset1"
          class="bg-blue-900 my-4"
        >
          <div><.icon name="hero-cloud-arrow-up-solid" class="h-6 w-6" /></div>
          <div>Upload Image</div>
        </.button>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
