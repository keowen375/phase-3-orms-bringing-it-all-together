class Dog
    attr_accessor :name, :breed, :id
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end


    def self.create_table
        query = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                breed TEXT
            )
        SQL

            DB[:conn].query(query)

    end

    def self.drop_table
        query = <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].query(query)

    end

    def save
        query = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL

        DB[:conn].query(query, self.name, self.breed)

        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

         self

    end


    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
    end

    def self.new_from_db(row)
            self.new(name: row[1],breed: row[2], id: row[0])
    end

    def self.all
        query = "SELECT * FROM dogs"
             DB[:conn].execute(query).map do |row|
                self.new_from_db(row) 
        end
    end


    def self.find_by_name(name)
        query = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL

      DB[:conn].execute(query, name).map do |row|
      self.new_from_db(row)
    end.first
    end

    def self.find(id)
        query = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1
        SQL

        DB[:conn].execute(query, id).map do |row|
            self.new_from_db(row)
          end.first
    end

end


