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
          data-cloud-name={@cloudinary_config[:cloud_name]}
          data-cloud-preset={@cloudinary_config[:upload_preset]}
          data-google-api-key={@cloudinary_config[:google_api_key]}
          class="bg-blue-900 my-4"
        >
          <div><.icon name="hero-cloud-arrow-up-solid" class="h-6 w-6" /></div>
          <div>Upload Image</div>
        </.button>
      </div>
    </div>
    """
  end

  def mount(socket) do
    cloudinary_config = Application.get_env(:yc_assessment, :cloudinary)

    {:ok, assign(socket, :cloudinary_config, cloudinary_config)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
