# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint           not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedUrl < ApplicationRecord
    
    validates :long_url, :short_url, :user_id, presence: true
    validates :short_url, uniqueness: true

    def self.random_code
        random_str = SecureRandom::urlsafe_base64 
        while ShortenedUrl.exists?(:short_url => random_str)
            random_str = SecureRandom::urlsafe_base64
        end
        random_str 
    end

    def self.make_instance(user, long_url_str)
        s = ShortenedUrl.random_code
        ShortenedUrl.create(user_id: user.id, long_url: long_url_str, short_url: s)
    end

    belongs_to :submitter,
        primary_key: :id,
        foreign_key: :user_id,
        class_name: :User

    has_many :visits,
        primary_key: :id,
        foreign_key: :url_id,
        class_name: :Visit

    has_many :visitors,
        through: :visits,
        source: :visitor

    def num_clicks
        visits.length
    end

    def num_uniques
        visits.select(:user_id).distinct.count
    end

end
