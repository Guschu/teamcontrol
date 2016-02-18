# == Schema Information
#
# Table name: drivers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe DriversController, type: :controller do
  describe 'GET index' do
    it 'assigns @drivers' do
      driver = create :driver
      get :index
      expect(assigns(:drivers)).to eq Kaminari.paginate_array([driver]).page(1)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template 'index'
    end
  end

  describe 'GET show' do
    let(:driver) { create :driver }
    subject { get :show, id: driver.id }

    it 'assigns @race' do
      subject
      expect(assigns(:driver)).to eq driver
    end

    it 'renders the show template' do
      expect(subject).to render_template 'show'
    end
  end

  describe 'POST create' do
    it 'a driver with name' do
      post :create, driver:{ name:"Dagobert Duck" }
      expect(response).to redirect_to action: :show, id:assigns(:driver).id
    end
  end
end
