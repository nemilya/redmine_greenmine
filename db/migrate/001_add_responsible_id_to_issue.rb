#
# для миграции в корне Редмайна выполняем в консоли: 
# rake db:migrate:plugins
# или для продуктового режима
# rake db:migrate_plugins RAILS_ENV=production
#
class AddResponsibleIdToIssue < ActiveRecord::Migration
  # добавляем префикс gm_ (greenmine)
  # ответственный за задачу
  def self.up
    add_column :issues, :gm_responsible_id, :int
  end

  def self.down
    remove_column :issues, :gm_responsible_id
  end
end
