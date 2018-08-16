# frozen_string_literal: true

Rails.application.routes.draw do
  mount Sidekiq::Web, at: "/sidekiq"

  namespace :public, path: nil do
    root 'home#index'
  end
end
