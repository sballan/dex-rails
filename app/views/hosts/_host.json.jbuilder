# frozen_string_literal: true

json.extract! host, :id, :host_url_string, :created_at, :updated_at
json.url host_url(host, format: :json)
