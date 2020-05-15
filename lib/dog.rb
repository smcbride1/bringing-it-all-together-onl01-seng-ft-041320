class Dog

    attr_accessor :id, :name, :breed

    @@all = nil

    def initialize(id:nil, name:nil, breed:nil)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )"
        
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"

        DB[:conn].execute(sql)
    end

    def self.all
        @@all = DB[:conn].execute("SELECT * FROM dogs")
    end

    def save
        sql = "INSERT INTO dogs (name, breed)
            VALUES (?, ?)"

        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id == ?"
        new_from_db(DB[:conn].execute(sql, id)[0])
    end
    
    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name == ?"
        result = DB[:conn].execute(sql, name)[0]
        result ? new_from_db(result) : nil
    end

    def self.find_by_name_and_breed(name, breed)
        sql = "SELECT * FROM dogs WHERE name == ? AND breed == ?"
        result = DB[:conn].execute(sql, name, breed)[0]
        result ? new_from_db(result) : nil
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.create(hash)
        new_dog = self.new()
        hash.each {|key, value| new_dog.send("#{key}=", value)}
        new_dog.save
    end

    def self.find_or_create_by(name:, breed:)
        result = self.find_by_name_and_breed(name, breed)
        if result != nil
            result
        else
            self.create(name: name, breed: breed)
        end
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE dogs.id == ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end