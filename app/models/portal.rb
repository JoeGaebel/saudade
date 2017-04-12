class Portal < ApplicationRecord
  belongs_to :from_sphere, class_name: 'Sphere'
  belongs_to :to_sphere, class_name: 'Sphere'

  serialize :polygon_px, Array
  attr_accessor :polygon_px, :fill, :stroke, :stroke_transparency,
                  :stroke_width, :tooltip_content, :tooltip_position
end
