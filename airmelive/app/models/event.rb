class Event < ActiveRecord::Base
	has_many :user_events
	has_many :users, :through => :user_events
	
	has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
	validates :eventname, :presence => {:message => "can't be empty"},:uniqueness => true, :length => { :in => 2..20 }
	validates :category, :presence => true
	validates :description, :presence => true
	validates :rules, :presence => true
end
