class AddFailureRetrySecondsToHost < ActiveRecord::Migration[6.0]
  def change
    add_column :hosts, :failure_retry_seconds, :integer, default: 1.hour.to_i
  end
end
