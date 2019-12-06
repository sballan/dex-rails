class ChangeHostColumnDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:hosts, :failure_retry_seconds, from: 3600, to: 5.minutes)
    change_column_default(:hosts, :invalid_retry_seconds, from: 604_800, to: 1.day)
    change_column_default(:hosts, :success_retry_seconds, from: 86_400, to: 1.minute)
  end
end
