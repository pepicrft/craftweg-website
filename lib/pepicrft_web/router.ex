defmodule PepicrftWeb.Router do
  import Redirect

  use PepicrftWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PepicrftWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PepicrftWeb do
    pipe_through :browser

    get "/", HomeController, :index
    get "/blog", BlogController, :index
    get "/blog/:year/:month/:day/:title", BlogController, :show
    get "/blog/feed.xml", BlogController, :feed

    for page <- Pepicrft.Pages.all_pages() do
      get page.slug, PageController, :show, as: page.identifier
    end
  end

  redirect "/blog/atom.xml", "/blog/feed.xml", :permanent

  for post <- Pepicrft.Blog.all_posts() do
    redirect(post.old_slug, post.slug, :permanent, preserve_query_string: true)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PepicrftWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PepicrftWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
