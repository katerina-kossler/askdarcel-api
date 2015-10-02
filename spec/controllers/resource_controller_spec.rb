require 'rails_helper'

RSpec.describe ResourcesController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "filters by category names" do
      resource1 = FactoryGirl.create(:resource)
      resource2 = FactoryGirl.create(:resource)

      get :index, category_names: [resource1.categories.first.name]
      expect(response).to have_http_status(:success)

      body = JSON.parse(response.body)
      expect(body["resources"].length).to eql(1)
      expect(body["resources"][0]["categories"].map { |c| c["name"] }).to eql(resource1.categories.map(&:name))
    end

    it "filters by category ids" do
      resource1 = FactoryGirl.create(:resource)
      resource2 = FactoryGirl.create(:resource)

      get :index, category_ids: [resource1.categories.first.id]
      expect(response).to have_http_status(:success)

      body = JSON.parse(response.body)
      expect(body["resources"].length).to eql(1)
      expect(body["resources"][0]["categories"].map { |c| c["name"] }).to eql(resource1.categories.map(&:name))
    end

    it "returns counts of ratings" do
      resource = FactoryGirl.create(:resource, ratings_count: 0)
      FactoryGirl.create(:rating, rating_option: RatingOption.find_by_name('positive'), resource: resource)
      FactoryGirl.create(:rating, rating_option: RatingOption.find_by_name('negative'), resource: resource)
      FactoryGirl.create(:rating, rating_option: RatingOption.find_by_name('no service'), resource: resource)
      FactoryGirl.create(:rating, rating_option: RatingOption.find_by_name('positive'), resource: resource)
      FactoryGirl.create(:rating, rating_option: RatingOption.find_by_name('negative'), resource: resource)
      FactoryGirl.create(:rating, rating_option: RatingOption.find_by_name('negative'), resource: resource)

      get :index
      expect(response).to have_http_status(:success)

      body = JSON.parse(response.body)
      expect(body["resources"].length).to eql(1)
      expect(body["resources"][0]["rating_counts"]["positive"]).to eql(2)
      expect(body["resources"][0]["rating_counts"]["negative"]).to eql(3)
      expect(body["resources"][0]["rating_counts"]["no service"]).to eql(1)
    end

    it "returns my rating" do
      resource = FactoryGirl.create(:resource, ratings_count: 0)
      FactoryGirl.create(:rating,
                         rating_option: RatingOption.find_by_name('negative'), device_id: '4567', resource: resource)
      FactoryGirl.create(:rating,
                         rating_option: RatingOption.find_by_name('positive'), device_id: '1234', resource: resource)

      request.headers['DEVICE-ID'] = '1234'
      get :index
      expect(response).to have_http_status(:success)

      body = JSON.parse(response.body)
      expect(body["resources"].length).to eql(1)
      expect(body["resources"][0]["my_rating"]["device_id"]).to eql('1234')
    end
  end

  describe "GET #show" do
    it "returns my rating" do
      resource = FactoryGirl.create(:resource, ratings_count: 0, ratings: [
        FactoryGirl.create(:rating, rating_option: RatingOption.find_by_name('negative'), device_id: '4567'),
        FactoryGirl.create(:rating, rating_option: RatingOption.find_by_name('positive'), device_id: '1234'),
      ])

      request.headers['DEVICE-ID'] = '1234'
      get :show, id: resource.id
      expect(response).to have_http_status(:success)

      body = JSON.parse(response.body)
      expect(body["resource"]["my_rating"]["device_id"]).to eql('1234')
    end
  end
end