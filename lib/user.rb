class FeedUser < CouchRest::Model
  use_database CouchRest.database!((Blog.url_base_database || '') + Blog.database_name)
  #use_database CouchRest.database!("yet_another_please") 
  key_accessor :last_access
  key_reader :uid 
  
  view_by :last_access
  view_by :uid
  
  before(:create, :generate_uid)
  def generate_uid
    uuid = UUID.new
    self['uid'] = uuid.generate :compact
  end
  
  def self.exists?(uid)
    false if FeedUser.by_uid.first.nil?
  end
  
  couchrest_type = 'FeedUser'  
end