class Recipe
  @@digest = ".checksum.sha256"

  def initialize(description)
    recipe = Pathname.new(description)
    if !File.exists?(recipe) || !File.directory?(recipe.realpath)
      raise Dice::Errors::NoDirectory.new(
        "Need a description directory"
      )
    end
    @basepath = recipe.realpath.to_s
    @cwd = Pathname.new(Dir.pwd).realpath.to_s
    recipe_ok?
  end

  def recipe_ok?
    if !File.file?(@basepath + "/Vagrantfile")
      raise Dice::Errors::NoVagrantFile.new(
        "Need a Vagrantfile"
      )
    end
    if !File.file?(@basepath + "/config.xml")
      raise Dice::Errors::NoKIWIConfig.new(
        "Need a kiwi config.xml"
      )
    end
  end

  def createDigest
    change_working_dir
    result = ""
    recipe_items = Find.find(".")
    recipe_items.each do |item|
      item.gsub!(/^\.\//,'')
      next if File.directory?(item)
      next if item =~ /^\.|^Vagrantfile$/
      sha256 = Digest::SHA256.file item
      result += item + ":" + sha256.hexdigest + "\n"
    end
    reset_working_dir
    result
  end

  def writeDigest(digest, suffix = nil)
    change_working_dir
    file_name = @@digest
    file_name += suffix if suffix
    digest_file = File.new(file_name, "w")
    reset_working_dir
    digest_file.puts digest
    digest_file.close
  end

  def readDigest
    cur_digest = ""
    change_working_dir
    begin
      cur_digest = File.read(@@digest)
    rescue
      # continue, working with empty digest is ok
    end
    reset_working_dir
    cur_digest
  end

  def validateDigest
    cur_digest = readDigest
    new_digest = createDigest
    if (cur_digest != new_digest)
      return false
    end
    true
  end

  def change_working_dir
    Dir.chdir(@basepath)
  end

  def reset_working_dir
    Dir.chdir(@cwd)
  end

  def get_basepath
    @basepath
  end
end
