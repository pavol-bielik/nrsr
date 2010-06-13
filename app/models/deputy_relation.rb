class DeputyRelation < ActiveRecord::Base
  belongs_to :deputy, :class_name => "Deputy", :foreign_key => "deputy1_id"
  belongs_to :deputy_compare, :class_name => "Deputy", :foreign_key => "deputy2_id"

  #Hodnota vztahov na zaklade hlasovania
  RELATION = { "Z" => {"Z" => 10, "P" => 0, "?" => 2, "N" => 2, "0" => 0},
               "P" => {"Z" => 0, "P" => 10, "?" => 7, "N" => 7, "0" => 0},
               "?" => {"Z" => 5, "P" => 5, "?" => 5, "N" => 4, "0" => 3},
               "N" => {"Z" => 5, "P" => 5, "?" => 5, "N" => 4, "0" => 3},
               "0" => {"Z" => 0, "P" => 0, "?" => 0, "N" => 0, "0" => 0} }

#  def ==(dep_id)
#    return true if deputy2_id == dep_id
#    false
#  end

end
