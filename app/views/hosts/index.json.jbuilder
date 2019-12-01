# frozen_string_literal: true

json.array! @hosts, partial: 'hosts/host', as: :host
