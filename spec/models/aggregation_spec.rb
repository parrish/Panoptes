require 'spec_helper'

RSpec.describe Aggregation, :type => :model do
  let(:aggregation) { build(:aggregation) }

  it 'should have a valid factory' do
    expect(aggregation).to be_valid
  end

  it 'should not be valid without a workflow' do
    expect(build(:aggregation, workflow: nil)).to_not be_valid
  end

  it 'should not be valid without a subject' do
    expect(build(:aggregation, subject: nil)).to_not be_valid
  end

  context "when there is a duplicate subject_id workflow_id entry" do
    before(:each) do
      aggregation.save
    end
    let(:duplicate) do
      build(:aggregation, workflow: aggregation.workflow,
                          subject: aggregation.subject)
    end

    it "should not be valid" do
      expect(duplicate).to_not be_valid
    end

    it "should have the correct error message on subject_id" do
      duplicate.valid?
      expect(duplicate.errors[:subject_id]).to include("has already been taken")
    end
  end

  describe '::scope_for' do
    shared_examples "correctly scoped" do
      let(:aggregation) { create(:aggregation) }
      let(:admin) { false }

      subject { described_class.scope_for(action, ApiUser.new(user, admin: admin)) }

      context "admin user" do
        let(:user) { create(:user, admin: true) }
        let(:admin) { true }

        it { is_expected.to include(aggregation) }
      end

      context "allowed user" do
        let(:user) { aggregation.workflow.project.owner }

        it { is_expected.to include(aggregation) }
      end

      context "disallowed user" do
        let(:user) { nil }

        it { is_expected.to_not include(aggregation) }
      end
    end

    context "#show" do
      let(:action) { :show }

      it_behaves_like "correctly scoped"
    end

    context "#index" do
      let(:action) { :index }

      it_behaves_like "correctly scoped"
    end

    context "#destroy" do
      let(:action) { :destroy }

      it_behaves_like "correctly scoped"
    end

    context "#update" do
      let(:action) { :update }

      it_behaves_like "correctly scoped"
    end
  end
end
