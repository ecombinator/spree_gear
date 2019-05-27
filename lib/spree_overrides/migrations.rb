# This should add our migration gems properly without warnings

Spree::Migrations.class_eval do
  def check
    if File.directory?(app_dir)
      engine_in_app = app_migrations.map do |file_name|
        name, engine = file_name.split('.', 2)
        next unless match_engine?(engine)
        name
      end.compact

      missing_migrations = engine_migrations.sort - engine_in_app.sort
      unless missing_migrations.empty?
        missing_migrations.each do |migration|
          puts "[SPREE GEAR WARNING] #{migration} from either #{engine_name} or spree_gear is missing."
        end

        puts "[SPREE GEAR WARNING] You are missing migrations from spree_gear \n\n"
        puts "[SPREE GEAR WARNING] Run `bundle exec rake railties:install:migrations FROM=spree_gear` to get them.\n\n"
        puts "[SPREE GEAR NOTIFICATION] Ignore migration warnings above above if first migrating \n\n"
        true
      end
    end
  end

  private

  def engine_dir
    Pathname.new(Gem::Specification.find_by_name("spree_gear").gem_dir + "/db/migrate")
  end

  def match_engine?(engine)
    if engine_name == 'spree'
      ['spree.rb', 'spree_promo.rb', 'spree_gear.rb'].include? engine
    else
      engine == "#{engine_name}.rb"
    end
  end

  def app_dir
    "#{Rails.root}/db/migrate"
  end
end
