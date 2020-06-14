require 'rails_helper'

describe User do
  it 'has valid factory' do
    expect(create(:user)).to be_valid
  end

  it '#full_name' do
    expect(build(:user, first_name: 'John',last_name: 'Doe' ).full_name).to be_eql("John Doe")
  end
end
