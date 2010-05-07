namespace :load do

  desc "Create deputies"
  task(:deputies_create => :environment) do
    Deputy.create_deputies
  end

end