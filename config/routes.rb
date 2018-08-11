# frozen_string_literal: true

Dir[Rails.root.join('config/routes/*.rb')].each { |route| load route }
