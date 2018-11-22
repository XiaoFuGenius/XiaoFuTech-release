# 常用命令：pod
# 本地 验证 podspec 文件：$ pod lib lint
# 本地&远程 验证 podspec 文件：$ pod spec lint
# 获取验证 podspec 文件时产生的详细信息：$ pod lib lint --verbose
# 移除验证 podspec 文件时产生的一般警告：$ pod lib lint --allow-warnings
# 第三方库的依赖中包含.a文件：$ pod lib lint --use-libraries
# 第三方库是私有库，需要添加源：$ pod lib lint --sources=https://github.com/CocoaPods/Specs.git,[第三方库源]
# 当前 podspec 文件验证：$ pod lib lint --sources=https://github.com/CocoaPods/Specs.git,https://github.com/aliyun/aliyun-specs.git,https://github.com/sinaweibosdk/weibo_ios_sdk.git --use-libraries --allow-warnings --verbose
# 添加&更新 私有repo 中的 podspec 文件：pod repo push [私有repo] [.podspec文件路径]

Pod::Spec.new do |s|
  s.name         = "XiaoFuTech-release" 		# 项目名称
  s.version      = "1.0.3" 		# 版本号 与 你仓库的 标签号 对应
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
  
  # 子组件管理
  s.default_subspec = ['AFNetworking']

  # 自封装 快捷开发『XFRapidCoding』


  # 自封装 用户权限『XFUserRightsPool』
  
  
  # 第三方库封装『XF3rdEncapsulation』
  
  # QQ_MTA
  s.subspec 'QQ_MTA' do |mta|
    mta.ios.deployment_target = '8.0'
    mta.source_files = 'CapacityExpansion/XF3rdEncapsulation/QQ_MTA/*.{h,m}'
    mta.public_header_files = 'CapacityExpansion/XF3rdEncapsulation/QQ_MTA/*.h'
    mta.dependency 'QQ_MTA/AutoTrack'
  end
  
  # Bugly
  s.subspec 'Bugly' do |bugly|
    bugly.ios.deployment_target = '8.0'
    bugly.source_files = 'CapacityExpansion/XF3rdEncapsulation/Bugly/*.{h,m}'
    bugly.public_header_files = 'CapacityExpansion/XF3rdEncapsulation/Bugly/*.h'
    bugly.dependency 'Bugly'
  end
  
  # AFNetworking
  s.subspec 'AFNetworking' do |afNet|
    afNet.ios.deployment_target = '8.0'
    afNet.source_files = 'CapacityExpansion/XF3rdEncapsulation/AFNetworking/*.{h,m}'
    afNet.public_header_files = 'CapacityExpansion/XF3rdEncapsulation/AFNetworking/*.h'
    afNet.ios.vendored_frameworks = 'Frameworks/XiaoFuTech.framework'
    afNet.dependency 'AFNetworking', '~> 3.0'
  end
  
  # WechatOpenSDK
  s.subspec 'WechatOpenSDK' do |wechat|
    wechat.ios.deployment_target = '8.0'
    wechat.source_files = 'CapacityExpansion/XF3rdEncapsulation/WechatOpenSDK/*.{h,m}'
    wechat.public_header_files = 'CapacityExpansion/XF3rdEncapsulation/WechatOpenSDK/*.h'
    wechat.ios.vendored_frameworks = 'Frameworks/XiaoFuTech.framework'
    wechat.dependency 'XiaoFuTech-release/AFNetworking'
    wechat.dependency 'WechatOpenSDK'
  end
  
  # Weibo_SDK，source 'https://github.com/sinaweibosdk/weibo_ios_sdk.git'
  s.subspec 'Weibo_SDK' do |weibo|
    weibo.ios.deployment_target = '8.0'
    weibo.source_files = 'CapacityExpansion/XF3rdEncapsulation/Weibo_SDK/*.{h,m}'
    weibo.public_header_files = 'CapacityExpansion/XF3rdEncapsulation/Weibo_SDK/*.h'
    weibo.ios.vendored_frameworks = 'Frameworks/XiaoFuTech.framework'
    weibo.dependency 'XiaoFuTech-release/AFNetworking'
    weibo.dependency 'Weibo_SDK'
  end

  # AlicloudPush，source 'https://github.com/aliyun/aliyun-specs.git'
  s.subspec 'AlicloudPush' do |alicloudpush|
    alicloudpush.ios.deployment_target = '8.0'
    alicloudpush.source_files = 'CapacityExpansion/XF3rdEncapsulation/AlicloudPush/*.{h,m}'
    alicloudpush.public_header_files = 'CapacityExpansion/XF3rdEncapsulation/AlicloudPush/*.h'
    alicloudpush.ios.vendored_frameworks = 'Frameworks/XiaoFuTech.framework'
    alicloudpush.dependency 'AlicloudPush', '~> 1.9.8'
  end
  
    # MJRefresh
#   s.subspec 'MJRefresh' do |mj|
#     mj.ios.deployment_target = '8.0'
#     mj.source_files = 'CapacityExpansion/XF3rdEncapsulation/MJRefresh/*.{h,m}'
#     mj.ios.vendored_frameworks = 'Frameworks/XiaoFuTech.framework'
#     mj.dependency 'MJRefresh'
#   end

end