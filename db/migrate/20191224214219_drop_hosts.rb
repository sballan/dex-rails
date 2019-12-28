# frozen_string_literal: true

class DropHosts < ActiveRecord::Migration[6.0]
  def change
    drop_table :hosts do |t|
      t.string 'host_url_string'
      t.integer 'limit_time', default: 5
      t.datetime 'created_at', precision: 6, null: false
      t.datetime 'updated_at', precision: 6, null: false
      t.integer 'failure_retry_seconds', default: 300
      t.integer 'invalid_retry_seconds', default: 86400
      t.integer 'success_retry_seconds', default: 10
      t.index ['host_url_string'], name: 'index_hosts_on_host_url_string', unique: true
    end
  end
end
