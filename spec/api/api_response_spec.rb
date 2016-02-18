require 'rails_helper'

RSpec.describe ApiResponse do
  context 'class methods' do
    subject { ApiResponse }

    it { is_expected.to respond_to :success, :error, :info }

    %w(success error info).each do |s|
      it "creates a #{s} instance" do
        r = ApiResponse.send(s, 'b', 'c')
        expect(r.code).to eq s
        expect(r.title).to eq 'b'
        expect(r.message).to eq 'c'
      end
    end
  end

  context 'instance methods' do
    subject { ApiResponse.new 'a', 'b', 'c' }

    it { is_expected.to respond_to :code, :title, :message }
    it 'converts to entity' do
      expect(subject.entity).to be_a Grape::Entity
    end
  end
end
