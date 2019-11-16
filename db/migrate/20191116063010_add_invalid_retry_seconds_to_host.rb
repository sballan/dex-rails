class AddInvalidRetrySecondsToHost < ActiveRecord::Migration[6.0]
  def change
    add_column :hosts, :invalid_retry_seconds, :integer, default: 1.week.to_i
  end
end
