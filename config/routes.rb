Rails.application.routes.draw do
  devise_for :user, :controllers => { :registrations => "users/registrations" }


  resources :jobs do
   member do
     post :collect
     post :discollect
   end
    resources :resumes
    collection do
      get :search
    end
  end

  # --蒐藏工作--
  namespace :favorite do
    resources :jobs
  end
  # --蒐藏工作--

  namespace :admin do
    resources :jobs do
      member do
        post :publish
        post :hide
      end
      resources :resumes
    end
  end

  namespace :account do
    resources :jobs
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


  root 'welcome#index'


end
