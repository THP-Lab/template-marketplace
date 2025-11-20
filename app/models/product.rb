class Product < ApplicationRecord 
  self.inheritance_column = :_type_disabled
end
