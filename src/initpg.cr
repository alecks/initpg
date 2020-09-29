require "db"
require "pg"
require "option_parser"

VERSION = "0.1.0"
MIGRATIONS_DIR = "migrations"

def throw(ex)
  msg = ex
  if ex.is_a? Exception
    msg = ex.message
  end

  STDERR.puts "ERROR: #{msg}"
  exit 1
end

migration_name = "migration"
create = false

OptionParser.parse do |parser|
  parser.banner = "InitPG -- portable database migrations."

  parser.on "-v", "--version", "Shows the program's version" do
    puts "InitPG v#{VERSION}"
    exit
  end
  parser.on "-h", "--help", "Shows command help" do
    puts parser
    exit
  end

  parser.on "create", "Creates a migration" do
    create = true
    parser.on "-n NAME", "--name=NAME", "Sets the name of the migration" { |n| migration_name = n }
  end

  parser.invalid_option do |flag|
    throw "#{flag} is not a valid option.\n\n#{parser}"
  end
  parser.missing_option do |flag|
    throw "#{flag} is missing an option.\n\n#{parser}"
  end
end

begin
  if create
    path = Path.new(MIGRATIONS_DIR, "#{migration_name}_#{Time.utc}")
    Dir.mkdir_p path unless File.exists? path

    ["up", "down"].each do |name|
      File.write Path.new(path, "#{name}.sql"), "-- InitPG"
    end
  end
rescue ex
  throw ex
end
