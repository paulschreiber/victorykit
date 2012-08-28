require 'smoke_spec_helper.rb'
require 'uri'
require 'member_hasher'

include Rails.application.routes.url_helpers

describe 'Petition page' do
  before :all do
    #we need to sign a petition to force creation of certain experiment keys in Redis ('after share view 2', for example)
    #this is sucky, so let's think of a better way
    petition = create :petition
    go_to petition_path(petition)
    sign_petition
  end

  before :each do
    @petition = create_a_petition
  end

  it 'should allow users to sign' do
    force_result({"after share view 2" => "thanks_for_signing"})
    go_to petition_path(@petition)
    sign_petition
    element(:id => "thanks-for-signing-message").should be_displayed
  end
  it 'should ensure user provides a name' do
    go_to petition_path(@petition)
    sign_petition '', 'no@yahoo.com'
    element(:class => 'help-inline').text.should == "can't be blank"
  end
  it 'should track the referer for a signature' do
    go_to petition_path(@petition)
    referer = create_member
    forwarded_notification_hash = referer.to_hash

    referred_link = petition_path(@petition) + "?r=#{forwarded_notification_hash}"
    go_to referred_link

    sign_petition Faker::Name.first_name, Faker::Name.last_name, Faker::Internet.email

    signature = Signature.last
    signature.referer.should == referer
  end

  it "should allow signing a petition again after clicking 'does somene else' link" do
    force_result({"after share view 2" => "thanks_for_signing"})
    set_default_experiment_results
    go_to petition_path(@petition)

    sign_petition
    click(:class => "close")
    click(:id => "sign-again-link")
    element_exists(:id => 'signature_first_name').should be_true
  end
end
