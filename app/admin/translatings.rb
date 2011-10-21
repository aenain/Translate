ActiveAdmin.register Translating do
  menu :parent => 'Words'

  index do
    column :id

    %w{original translated}.each do |association_name|
      column association_name.capitalize do |translating|
        association = translating.send(association_name.to_sym)

        case association
        when Word then link_to association.name, admin_word_path(association)
        end
      end
    end

    column :created_at
    column :updated_at

    default_actions
  end
end
