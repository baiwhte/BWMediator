
# require './Configure'
# require './ProjectManipulator'

class Configure
	attr_reader :username, :email,:projectDir
	def initialize(options)
		@projectName = options.fetch(:projectName)
		@moduleName = options.fetch(:moduleName)
		@projectDir = options.fetch(:projectDir)
	end

	def projectName
		return @projectName
	end

	def moduleName
		return @moduleName
	end

	def user_name
      (ENV['GIT_COMMITTER_NAME'] || github_user_name || `git config user.name` || `<GITHUB_USERNAME>` ).strip
    end

    def github_user_name
      github_user_name = `security find-internet-password -s github.com | grep acct | sed 's/"acct"<blob>="//g' | sed 's/"//g'`.strip
      is_valid = github_user_name.empty? or github_user_name.include? '@'
      return is_valid ? nil : github_user_name
    end

    def code_paic_user_name
      github_user_name = `security find-internet-password -s code.paic.com.cn | grep acct | sed 's/"acct"<blob>="//g' | sed 's/"//g'`.strip
      is_valid = github_user_name.empty? or github_user_name.include? '@'
      return is_valid ? nil : github_user_name
    end

    def user_email
      (ENV['GIT_COMMITTER_EMAIL'] || `git config user.email`).strip
    end

    def year
      Time.now.year.to_s
    end

    def date
      Time.now.strftime "%m/%d/%Y"
    end
end

class ProjectManipulator
	def initialize(options)
		@configurator = options.fetch(:configurator) #fetch和直接使用options[:configurator]有一点不一样,如果不存在,则会发生异常
		@projectDir = @configurator.projectDir
		#定义一个散列,也就是Hash
		@string_replacements = {
        "PROJECT_OWNER" => @configurator.user_name,
        "TODAYS_DATE" => @configurator.date,
        "TODAYS_YEAR" => @configurator.year,
      	}
      	@files = []
	end

	def projectDir
      return @projectDir
    end
	def replace_internal_project_settings
		get_all_files(projectDir,[".h",".m"])
		#puts("files = #{@files}")
		@files.each do |filePath|
			text = File.read(filePath)
			for find, replace in @string_replacements
            	text = text.gsub(find, replace)
        	end
        	File.open(filePath, "w") { |file| file.puts text }
		end
    end

    def get_all_files(path,fileTypes)
    	#puts("path = #{path},fileTypes=#{fileTypes}")
		if File.directory? path #文件夹
         	Dir.foreach(path) do |file|
             	if file !="." and file !=".."
                 	get_all_files(path+"/"+file,fileTypes)
             	end
         	end
     	else
     		extname = File.extname(path)
     		if fileTypes.include?(extname)
     			#puts("path = #{path}")
     			@files.append(path)
     		end
     	end
     	#puts("files = #{@files}")
         

    end
end

projectName=ARGV[0]
moduleName=ARGV[1]



current_dir = File.dirname(File.expand_path(__FILE__))
#puts("current_dir = #{current_dir}")

configure = Configure.new({projectName:projectName,moduleName:moduleName,projectDir:current_dir}) #Hash的构造方式之一  :前面的会自动转为 符号
#puts("configure=#{configure}")
puts("Replace all file headers info")
porject_manipulator = ProjectManipulator.new(configurator:configure) #Hash只有一项,作为参数,初始化的时候,可以省略 {}
porject_manipulator.replace_internal_project_settings

