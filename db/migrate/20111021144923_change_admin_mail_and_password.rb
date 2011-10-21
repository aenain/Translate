class ChangeAdminMailAndPassword < ActiveRecord::Migration
  def up
    @admin = AdminUser.find_by_email('admin@example.com')

    if @admin.present?
      @admin.email = "arturhebda@gmail.com"
      @admin.password = "Tr@ns!@Te"

      @admin.save!
    end
  end

  def down
  end
end
