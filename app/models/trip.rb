class Trip < ApplicationRecord
	mount_uploader :images, ImageUploader
end
