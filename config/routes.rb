# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :queries
  resources :hosts
  resources :pages

  namespace :index do
    resources :queries
    resources :hosts
    resources :pages
  end

  root 'queries#index'
end
