# frozen_string_literal: true

class ChangeHostColumnDefaultSeconds < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:hosts, :success_retry_seconds, from: 60, to: 10.seconds)
  end
end
