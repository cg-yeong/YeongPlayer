//
//  AppAbout.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/17.
//

import UIKit
import AdSupport

class AppAbout {
    
    /* 앱 이름 */
    public var appName: String {
      if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String{ return appName }
        else{  return ""  }
    }
    /* 앱 버전 */
    public var appVersion: String {
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String{ return appVersion }
        else{  return ""  }
    }
    
    /* 시스템 버전  */
    public var systemVersion: String {
        return UIDevice.current.systemVersion
    }

    /* 앱 빌드 넘버*/
    public var appBuild: String {
        if let appBuild = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String{ return appBuild }
        else{  return ""  }
    }
    
    /* 앱 번들아이디*/
    public var bundleIdentifier: String {
        if let bundleIdentifier = Bundle.main.infoDictionary!["CFBundleIdentifier"] as? String{ return bundleIdentifier }
        else{  return ""  }
    }
    
    /* 앱 번들 이름*/
    public var bundleName: String {
        if let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String{ return bundleName }
        else{  return ""  }
    }
    
    /* 앱 스토어 URL*/
    public var appStoreURL: URL? {   return URL(string: appStoreUrlStr) }
    
    /* 앱 스토어 URL 문자열*/
    public var appStoreUrlStr : String { return "http://itunes.apple.com/kr/app/id\(appleID)?mt=8"}
    
    /* 애플 아이디*/
    public var appleID : String {  return "990846750"  }
    /*
     * 앱 버전 + 빌드번호
     */
    public var appVersionAndBuild: String {
        let version = appVersion, build = appBuild
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
    
    /*  디바이스 UUID (IDFV)  */
    public var uuid: String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    public var IDFA: String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    /* 유저 에이전트, ios 12 까지 지원 */
    /*public var userAgent : String?{
        return ""
    }*/
    
    //########################## 디바이스 스크린 ##############################
    /* 디바이스 오리엔테이션 상태*/
    public var screenOrientation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    
    /* 디바이스 상태바 높이*/
    public var screenStatusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    /* 현재 디바이스 스크린 높이 (가로,세로)*/
    public var screenHeightWithoutStatusBar: CGFloat {
        if screenOrientation.isPortrait {
            return UIScreen.main.bounds.size.height - screenStatusBarHeight
        } else {
            return UIScreen.main.bounds.size.width - screenStatusBarHeight
        }
    }
    //########################################################################
}
