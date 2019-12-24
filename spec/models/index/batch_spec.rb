# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::Batch, type: :model do
  it 'can be created' do
    batch = Index::Batch.create
    expect(batch).to be
  end
end
