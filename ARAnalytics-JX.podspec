Pod::Spec.new do |s|
  s.name         =  'ARAnalytics-JX'
  s.version      =  '5.0.1-v1'
  s.license      =  {:type => 'MIT', :file => 'LICENSE' }
  s.homepage     =  'https://github.com/tospery/ARAnalytics-JX'
  s.authors      =  { 'YangJianxiang' => 'tospery@gmail.com' }
  s.source       =  { :git => 'https://github.com/tospery/ARAnalytics-JX.git', :tag => s.version.to_s }
  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.15"
  s.static_framework = true
  s.social_media_url = "https://twitter.com/tospery"
  s.summary      =  'Using subspecs you can define your analytics provider with the same API on iOS and OS X.'
  # s.description is at the bottom as it is partially generated.

  umeng            = { :spec_name => "UMengAnalytics",      :dependency => "UMCommon" }

  all_analytics = [umeng]

  # To make the pod spec API cleaner, subspecs are "iOS/KISSmetrics"

  s.subspec "CoreMac" do |ss|
    ss.source_files = ['*.{h,m}', 'Providers/ARAnalyticalProvider.{h,m}', 'Providers/ARAnalyticsProviders.h']
    ss.exclude_files = ['ARDSL.{h,m}', 'ARNavigationControllerDelegateProxy.{h,m}']
    ss.platform = :osx
  end

  s.subspec "CoreIOS" do |ss|
    ss.source_files = ['*.{h,m}', 'Providers/ARAnalyticalProvider.{h,m}', 'Providers/ARAnalyticsProviders.h']
    ss.exclude_files = ['ARDSL.{h,m}']
    ss.private_header_files = 'ARNavigationControllerDelegateProxy.h'
    ss.tvos.deployment_target = '9.0'
	  ss.ios.deployment_target = '8.0'
  end

  s.subspec "DSL" do |ss|
    ss.source_files = ['ARDSL.{h,m}']
    ss.dependency 'RSSwizzle', '~> 0.1.0'
    ss.dependency 'ReactiveObjC', '~> 2.0'
  end

  # for the description
  all_ios_names = []
  all_osx_names = []

  # make specs for each analytics
  all_analytics.each do |analytics_spec|
    s.subspec analytics_spec[:spec_name] do |ss|

      if analytics_spec[:ios_deployment_target]
        ss.ios.deployment_target = analytics_spec[:ios_deployment_target]
      end

      providername = analytics_spec[:provider]? analytics_spec[:provider] : analytics_spec[:spec_name]

      # Each subspec adds a compiler flag saying that the spec was included
      ss.prefix_header_contents = "#define AR_#{providername.upcase}_EXISTS 1"
      sources = ["Providers/#{providername}Provider.{h,m}"]

      # It there's a category adding extra class methods to ARAnalytics
      if analytics_spec[:has_extension]
        sources << "Extensions/*+#{providername}.{h,m}"
      end

      # only add the files for the osx / iOS version
      if analytics_spec[:osx]
        ss.osx.source_files = sources
        ss.dependency 'ARAnalytics-JX/CoreMac'
        ss.platform = :osx
        all_osx_names << providername

      else
        ss.ios.source_files = sources
        ss.dependency 'ARAnalytics-JX/CoreIOS'
        if analytics_spec[:tvos]
          ss.tvos.source_files = sources
          ss.ios.deployment_target = "6.0"
          ss.tvos.deployment_target = "9.0"
        else
          ss.platform = :ios
        end
        all_ios_names << providername
      end

      # If there's a podspec dependency include it
      Array(analytics_spec[:dependency]).each do |dep|
          ss.dependency *dep
      end

    end
  end

end
