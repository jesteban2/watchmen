normal['java']['install_flavor'] = 'adoptopenjdk'
normal['java']['jdk_version'] = '8'
normal['java']['jdk'][normal['java']['jdk_version'].to_s]['bon_cmds'] = ["java", "javac"]
normal['java']['set_etc_environment'] = true