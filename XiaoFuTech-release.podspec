# 常用命令：pod
# 本地 验证 podspec 文件：$ pod lib lint
# 本地&远程 验证 podspec 文件：$ pod spec lint
# 移除验证 podspec 文件时产生的一般警告：$ pod lib lint --allow-warnings
# subspec 依赖中的第三方库包含.a文件：$ pod lib lint --use-libraries
# 添加&更新 私有repo 中的 podspec 文件：pod repo push [私有repo] [.podspec文件路径]

Pod::Spec.new do |s|
  s.name         = "XiaoFuTech-release" 		# 项目名称
  s.version      = "1.0.2" 		# 版本号 与 你仓库的 标签号 对应
  s.license      = "MIT" 	 # 开源证书
  s.summary      = "iOS 快捷开发工具包 XiaoFuTech.framework for Release." 	# 项目简介
  s.deprecated = false

  s.homepage     = "https://github.com/XiaoFuGenius/XiaoFuTech-release" 	# 你的主页
  s.source       = { :git => "https://github.com/XiaoFuGenius/XiaoFuTech-release.git", :tag => "#{s.version}" } 	# 你的仓库地址
  s.requires_arc = true 	# 是否启用ARC
  s.platform     = :ios, "8.0" 		#平台及支持的最低版本
  s.vendored_frameworks = "Frameworks/XiaoFuTech.framework" 	#第三方库依赖
  s.frameworks   = "UIKit", "Foundation" 	#支持的框架
  
  # User
  s.author             = { "Raywf" => "https://github.com/XiaoFuGenius" } 	# 作者信息
  s.social_media_url   = "https://github.com/XiaoFuGenius" 	# 个人主页

end