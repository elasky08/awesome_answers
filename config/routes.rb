Rails.application.routes.draw do
  #this defines a route that when we receive a 'GET' request with URL '/home'
  #it will invoke the 'welcome_controller' with 'index' action
  # get({"/home" => "welcome#index"})
  # this is called DSL: domain specific language. It's just Ruby written in a special
  # way for a special purpose (in this case for defining routes)
  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]

  get "/home" => "welcome#index"

  #we can use 'as:' option to set a path/url helper
  get "/about" => "welcome#about_me", as: :about_me

  get "/contact" => "contact#new", as: :new_contact

  post "/contact" => "contact#create", as: :contact

  resources :users, only: [:new, :create]
  resources :sessions, only: [:new, :create, :destroy] do
    delete :destroy, on: :collection
  end

  # get "api/v1/questions" => "api/v1/questions#index"
    # the line of code above is the same as the block of code below.
    # you can use 'scope' instead of 'namespace' but scope will use the old controller and the old path but uses a new url, namespace will use a new path and new controller and new url.
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :questions, only: [:index, :show, :create]
    end
  end

  # scope :android do
  #   resources :questions, controller: "api/v1/questions"
  # end

  resources :questions do
    # # collection is used when we don't need to spcify a particular question but we expect a collection of question. Exmaples: index / create
    # post :search, on: :collection
    #
    # # member is used when we need to identify a particular question. Examples are: show / edit / update / destroy
    # post :search, on: :member
    #
    # # This is when we want to have nested routes for our resources. Example is answers for questions.
    # post :search
    post "/questions/search" => "questions#seacrh"
    resources :answers, only: [:create, :destroy]
    resources :likes, only: [:create, :destroy]
    resources :votes, only: [:create, :update, :destroy]
  end

  # get "/questions/new" => "questions#new", as: :new_question
  # post "/questions" => "questions#create", as: :questions
  # get "/questions/:id" => "questions#show", as: :question
  # get "/questions" => "questions#index"
  # get "/questions/:id/edit" => "questions#edit", as: :edit_question
  # patch "/questions/:id" => "questions#update" #we don't have to put as: :question because for question#show it already assigned as: :question
  # delete "/questions/:id" => "question#destroy"
  #this is basically defining: get "/"
  get "/auth/twitter", as: :sign_in_with_twitter
  get "/auth/twitter/callback" => 'callbacks#twitter'

  root "welcome#index"
end
