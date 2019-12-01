# frozen_string_literal: true

class AddSuccessRetrySecondsToHost < ActiveRecord::Migration[6.0]
  def change
    add_column :hosts, :success_retry_seconds, :integer, default: 1.day.to_i
  end
end
