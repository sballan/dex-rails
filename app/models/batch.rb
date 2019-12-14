# frozen_string_literal: true

class Batch < ApplicationRecord
  # EVENT_TIMES = [
  #   :created_at,
  #   :updated_at,
  #   :started_at,
  #   :stopped_at,
  #   :failed_at,
  #   :successful_at
  # ]

  def perform_now
    start!
    stop!
    succeed!
  end

  def perform_later
    start!
  end

  def start!
    raise 'Already running this batch' if currently_running?

    current_time = Time.now.utc

    self[:started_at] = current_time
    self[:stopped_at] = nil
    self[:failed_at] = nil
    self[:successful_at] = nil

    Rails.logger.info "Starting Batch (#{id})" && save!
  end

  def stop!
    self[:stopped_at] = Time.now.utc
    Rails.logger.info "Stopping Batch (#{id})" && save!
  end

  def fail!
    self[:failed_at] = Time.now.utc
    Rails.logger.info "Failed Batch (#{id})" && save!
  end

  def succeed!
    self[:successful_at] = Time.now.utc
    Rails.logger.info "Successful Batch (#{id})" && save!
  end

  def currently_running?
    reload
    return false if self[:started_at].blank?

    self[:started_at] > [
      self[:stopped_at].to_i,
      self[:failed_at].to_i,
      self[:successful_at].to_i
    ].max
  end
end
