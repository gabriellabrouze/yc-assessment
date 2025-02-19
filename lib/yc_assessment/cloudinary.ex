defmodule YourApp.Cloudinary do
  @moduledoc """
  Module for interacting with Cloudinary's API.
  """

  @cloudinary_config Application.compile_env(:yc_assessment, :cloudinary)

  @doc """
  Generates a Cloudinary upload signature.
  """
  def generate_signature(params) do
    timestamp = System.system_time(:second) |> to_string()

    params_to_sign =
      Map.merge(params, %{
        timestamp: timestamp,
        upload_preset: @cloudinary_config[:upload_preset]
      })

    signature =
      :crypto.mac(:hmac, :sha, @cloudinary_config[:api_secret], params_to_sign |> Jason.encode!())
      |> Base.encode16(case: :lower)

    %{
      signature: signature,
      timestamp: timestamp,
      api_key: @cloudinary_config[:api_key]
    }
  end
end
