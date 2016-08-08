class Tour < ApplicationRecord
	has_many :trips, dependent: :destroy

	has_many :acompanies, dependent: :destroy
end
