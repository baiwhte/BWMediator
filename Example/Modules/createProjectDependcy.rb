require 'pathname'
require 'xcodeproj'

def requireGem()
    # The version requirements are optional.
    # You can also specify multiple version requirements, just append more at the end
    gem_name, *gem_ver_reqs = 'xcodeproj', '> 1.6.1'
    gdep = Gem::Dependency.new(gem_name, *gem_ver_reqs)
    # find latest that satisifies
    found_gspec = gdep.matching_specs.max_by(&:version)
    # instead of using Gem::Dependency, you can also do:
    # Gem::Specification.find_all_by_name(gem_name, *gem_ver_reqs)

    if found_gspec
        puts "Requirement '#{gdep}' already satisfied by #{found_gspec.name}-#{found_gspec.version}"
    else
        puts "Requirement '#{gdep}' not satisfied; installing..."
    # reqs_string will be in the format: "> 1.0, < 1.2"
        reqs_string = gdep.requirements_list.join(', ')
    # multi-arg is safer, to avoid injection attacks
    system('sudo','gem', 'install', gem_name, '-v', reqs_string)
end
end





class SubProjectDispose
    attr_reader :mainproj_path, :subproj_path, :main_project ,:sub_project,:subproj_ref_in_mainproj,:subproj_product_group_ref
    def initialize(mainproj_path,subproj_path)
        @mainproj_path = mainproj_path
        @subproj_path = subproj_path
        @main_project = Xcodeproj::Project.open(mainproj_path)
    end
    #根据productReference 找到其对应的target
    def get_target_with_productReference(productReference,project)
        project.native_targets.each { |target|
            if target.product_reference == productReference
                puts "target = #{target}"
                return target
            end
        }
    end

    def add_new_subProj(group, path, source_tree)
        @subproj_ref_in_mainproj = Xcodeproj::Project::FileReferencesFactory.send(:new_file_reference, group, path, :group)
        @subproj_ref_in_mainproj.include_in_index = nil
        @subproj_ref_in_mainproj.name = Pathname(subproj_path).basename.to_s
        #product_group_ref = group.new_group("Products") 这种方式创建的group会挂载在main_group下,这会导致删除的时候,出现一个空的group,而手动拖动的就不会,所以改为group.project.new(Xcodeproj::Project::PBXGroup)
        #从xcode手动添加子工程来看,它要创建一个包含子工程的group
        product_group_ref = group.project.new(Xcodeproj::Project::PBXGroup)
        product_group_ref.name = "Products" #手动拖动创建的group名字就是Products
        @sub_project = Xcodeproj::Project.open(path) #打开子工程
        @sub_project.products_group.files.each do |product_reference|
            puts "product_reference = #{product_reference},name = #{product_reference.name},path = #{product_reference.path}"#product_reference = FileReference,name = ,path = ChencheMaBundle.bundle reference_proxy.file_type = wrapper.plug-in
            container_proxy = group.project.new(Xcodeproj::Project::PBXContainerItemProxy)
            container_proxy.container_portal = @subproj_ref_in_mainproj.uuid
            container_proxy.proxy_type = Xcodeproj::Constants::PROXY_TYPES[:reference]
            container_proxy.remote_global_id_string = product_reference.uuid
            #container_proxy.remote_info = 'Subproject' #这里和手动添加的是不一致的,手动的,这里是targets的名字
            subproj_native_target = get_target_with_productReference(product_reference,@sub_project)
            container_proxy.remote_info = subproj_native_target.name
            reference_proxy = group.project.new(Xcodeproj::Project::PBXReferenceProxy)
            extension = File.extname(product_reference.path)[1..-1]
            puts("product_reference.path = #{product_reference.path}")
            if extension == "bundle"
                #xcodeproj的定义中,后缀为bundle的对应的是'bundle'       => 'wrapper.plug-in',但是我们手动拖动添加的是 'wrapper.cfbundle'
                reference_proxy.file_type = 'wrapper.cfbundle'
            elsif
            reference_proxy.file_type = Xcodeproj::Constants::FILE_TYPES_BY_EXTENSION[extension]
            end

            reference_proxy.path = product_reference.path
            reference_proxy.remote_ref = container_proxy
            reference_proxy.source_tree = 'BUILT_PRODUCTS_DIR'
            product_group_ref << reference_proxy
        end
        @subproj_product_group_ref = product_group_ref
        attribute = Xcodeproj::Project::PBXProject.references_by_keys_attributes.find { |attrb| attrb.name == :project_references }
        project_reference = Xcodeproj::Project::ObjectDictionary.new(attribute, group.project.root_object)
        project_reference[:project_ref] = @subproj_ref_in_mainproj
        project_reference[:product_group] = product_group_ref
        group.project.root_object.project_references << project_reference
        product_group_ref
    end


    def add_subproject()
        add_new_subProj(self.main_project.main_group,self.subproj_path,:group)
        add_frameworks_build_phase()
        add_dependencies()
        add_copy_bundle_resource()
    end


    def add_frameworks_build_phase()
        puts("self.subproj_product_group_ref = #{self.subproj_product_group_ref}")
        reference_proxys = self.subproj_product_group_ref.children.grep(Xcodeproj::Project::PBXReferenceProxy)
        reference_proxys.each do |reference_proxy|
            if (reference_proxy.file_type == Xcodeproj::Constants::FILE_TYPES_BY_EXTENSION["a"]) || (reference_proxy.file_type == Xcodeproj::Constants::FILE_TYPES_BY_EXTENSION["bundle"]) then
                puts("reference_proxy = #{reference_proxy}")
                native_target = self.main_project.native_targets.first
                native_target.frameworks_build_phase.add_file_reference(reference_proxy)
            end
        end
    end


    def add_dependencies()
        #添加target的dependencies,需要的是子工程的target
        # @main_project = Xcodeproj::Project.open(self.mainproj_path)
        # @sub_project = Xcodeproj::Project.open(self.subproj_path) #打开子工程
        # @subproj_ref_in_mainproj = @main_project.objects_by_uuid['0CC9D5720EABC826EE0ECB3B'] #使用uuid可以获取任何一个对象
        native_target = self.main_project.native_targets.first
        @sub_project.native_targets.each do |nativeTarget|
            if (nativeTarget.product_type == Xcodeproj::Constants::PRODUCT_TYPE_UTI[:static_library]) || (nativeTarget.product_type == Xcodeproj::Constants::PRODUCT_TYPE_UTI[:bundle]) then
                puts("nativeTarget.productType = #{nativeTarget.product_type}")
                container_proxy = self.main_project.new(Xcodeproj::Project::PBXContainerItemProxy)
                container_proxy.container_portal = @subproj_ref_in_mainproj.uuid
                container_proxy.proxy_type = Xcodeproj::Constants::PROXY_TYPES[:native_target] #1
                container_proxy.remote_global_id_string = nativeTarget.uuid
                container_proxy.remote_info = nativeTarget.product_name

                target_dependency = @main_project.new(Xcodeproj::Project::PBXTargetDependency)
                target_dependency.name = nativeTarget.name
                target_dependency.target_proxy = container_proxy
                native_target.dependencies << target_dependency
            end
        end


    end

    def add_copy_bundle_resource()
        puts("add_copy_bundle_resource")
        # @main_project = Xcodeproj::Project.open(self.mainproj_path)
        # @sub_project = Xcodeproj::Project.open(self.subproj_path) #打开子工程
        # @subproj_product_group_ref = @main_project.objects_by_uuid['37A142A1F74B773563256D88'] #使用uuid可以获取任何一个对象

        native_target = self.main_project.native_targets.first
        build_file = @main_project.new(Xcodeproj::Project::PBXBuildFile)
        reference_proxys = self.subproj_product_group_ref.children.grep(Xcodeproj::Project::PBXReferenceProxy)
        reference_proxys.each do |reference_proxy|
            puts("reference_proxy.file_type = #{reference_proxy.file_type}")
            if reference_proxy.file_type == 'wrapper.cfbundle' && reference_proxy.path.include?(".bundle") then
                puts("reference_proxy = #{reference_proxy}")
                build_file.file_ref = reference_proxy;
                native_target.resources_build_phase.files << build_file
            end
        end


    end


    def close()
        self.main_project.save()
    end

end

# 看依赖库是否建立
requireGem()
puts Pathname.new(__FILE__).realpath
current_dir = Pathname.new(File.dirname(__FILE__)).realpath

parent_path = File.expand_path("..",current_dir)
main_project_path = nil
Dir.chdir("..")
Dir["*.xcodeproj"].each {|x| 
    main_project_path = "#{parent_path}/#{x}"
  puts main_project_path
 }

subproj_path = "#{current_dir}/#{ARGV[0]}/#{ARGV[0]}.xcodeproj"
puts subproj_path


dispose =SubProjectDispose.new(main_project_path,subproj_path)
dispose.add_subproject()
dispose.close()




