# Kitchen Persona Registration App

A Phoenix LiveView application that allows users to register for an account, upload a profile picture using Cloudinary, select a "kitchen persona," and log in or register using Facebook.

## Features

- **User Registration**: Users can register with their name, email, and password.
- **Facebook Login/Registration**: Users can log in or register using their Facebook account.
- **Profile Picture Upload**: Users can upload and crop their profile picture using Cloudinary's Upload Widget.
- **Kitchen Persona Selection**: Users can select a "kitchen persona" (e.g., Gourmet Chef, Health Nut) from a dropdown list.
- **Dynamic Profile Preview**: Displays the user's profile picture with a persona badge and color border.
- **Responsive Design**: Built with Tailwind CSS for a clean and responsive user interface.

## Technologies Used

- **Phoenix Framework**: A productive web framework for Elixir.
- **LiveView**: Enables real-time, server-rendered user interfaces.
- **Cloudinary**: Handles image uploads, transformations, and storage.
- **Tailwind CSS**: A utility-first CSS framework for styling.
- **PostgreSQL**: The database used for storing user and persona data.
- **OAuth2 (and Assent Dependency)**: For Facebook login/registration integration.

## Setup

### Prerequisites

- Elixir 
- Erlang/OTP 
- PostgreSQL
- Cloudinary account (for image uploads)
- Facebook Developer account 
(for OAuth2 integration)
- Google Developer Account (for image search on cloudinary upload widget)

### Installation

1. Clone the repository:

  ```bash
   git clone https://github.com/gabriellabrouze/yc-assessment.git
   cd yc-assessment
  ```

2. Install dependencies and set up the database:

  ```bash
    mix deps.get
    mix ecto.setup
  ```

3. Configure environment variables:

    Create a .env file in the root directory and add the following:

  ```bash
    # Cloudinary
    CLOUDINARY_CLOUD_NAME=your_cloud_name
    CLOUDINARY_API_KEY=your_api_key
    CLOUDINARY_API_SECRET=your_api_secret
    CLOUDINARY_UPLOAD_PRESET=your_upload_preset
    GOOGLE_IMAGE_SEARCH_API_KEY=your_google_image_search_api_key
    # Assent (Facebook OAuth2)
    ASSENT_CLIENT_ID=your_facebook_client_id
    ASSENT_CLIENT_SECRET=your_facebook_client_secret
    ASSENT_REDIRECT_URI=your_facebook_redirect_uri
  ```

4. Run the application:

  ```bash
    mix phx.server
  ```

5. Visit http://localhost:4000 in your browser


### Seeding Data

To seed the database with predefined kitchen personas, run:

```bash
  mix run priv/repo/seeds.exs
```

## Facebook Login/Registration

To enable Facebook login/registration:
- Create a Facebook App in the Facebook Developer Portal.
- Set the Valid OAuth Redirect URIs to http://localhost:4000/auth/facebook/callback.
- Add the ASSENT_CLIENT_ID and ASSENT_CLIENT_SECRET to your .env file.

### Testing
Run the test suite with:

```bash
  mix test
```
