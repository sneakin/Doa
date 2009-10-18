require File.join(File.dirname(__FILE__), "spec_helper")

describe Doa, :type => :controller do
  ActionController::Routing::Routes.draw do |map|
    map.resources :test, :controller => 'application'
  end

  controller_name :application

  action :update do
    before(:each) do
      @person = 'person'
    end

    params do
      { :id => @person, :name => 'Robert' }
    end

    context 'no extra params' do
      it "assigns the params" do
        doa

        assigns[:params][:id].should == @person
        assigns[:params][:name].should == 'Robert'
      end
    end

    context 'per-call params' do
      before(:each) do
        doa(:name => 'Bob', :age => 21)
        @params = assigns[:params]
      end

      it "includes the parent context's params" do
        @params[:id].should == @person
      end

      it "includes the passed params" do
        @params[:name].should == 'Bob'
        @params[:age].should == '21'
      end
    end

    context 'per-context params' do
      params do
        { 'name' => 'Bob', :age => 21 }
      end

      before(:each) do
        do_action
        @params = assigns[:params]
      end

      it "includes the parent context's params" do
        @params[:id].should == @person
      end

      it "merges in the context's params with the parent's" do
        @params[:name].should == 'Bob'
        @params[:age].should == '21'
      end
    end
  end
end
