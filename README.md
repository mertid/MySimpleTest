# Tealium Mobile Library Builder for Apple Platforms

This repo contains all the code + projects needed to develop, maintain and deploy the Tealium iOS & tvOS frameworks.


Specifically it allows:

- For the update/maintenance/editing of the source library files
- For unit testing of the source library files within development test apps
- For the creation of the final framework deliverable
- For the testing of the framework deliverable in deployable test apps


## How to Build Frameworks
There are 3 available projects for building the iOS frameworks:
- Builder
- Builder_dynamic
_ Builder_dynamic_lifecycle

The builder project uses custom build script to build the fat libraries. But it can not create the modules correctly and most be build against a simulator target to work. Subsequently the simulator reference must be removed from info.plist generated and from the final app prior to store submission. This is currently the only folder with the watchOSExtension framework target.

The builder_dynamic project uses a Carthage script to generate the fat libraries, which can create the expected module map correctly, and no modification to the framework's info.plist is necessary.  However, the final app must still strip out the simulator slice from the framework prior to stores submission.

The builder_dynamic_lifecycle is the same as the builder_dynamic except it also has targets for the lifecycle modules.  The builder_dynamic_lifecycle is the most recent and is the recommended builder project to use.  Within it is a buildall.sh script which can be run ($./builall.sh) from the command line which will build all the expected frameworks (iOS, tvOS, iOSLifecycle, tvOSLifecycle) to their respective repos.

## How to run UI Automation Tests

*

## Output location

The tealium-ios library will output to a folder named tealium-ios that is at the
same folder location as the tealium-apple-builder repo.

The watchOS deliverables will output to the tealium-ios/support/watchKit folder

The tealium-tvos library will output to a folder named tealium-tvos on the same
level as the tealium-apple-builder folder.

## CFBundleSupportedPlatforms

!!! All simulator options need to be stripped from any framework's info.plist !!!
Possibly some bug with just XCode 7

## XCode Build options

xcodebuild -project FrameworkBuilder.xcodeproj -alltargets

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumIOS -destination 'platform=iOS Simulator,name=iPhone 6'

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumIOSLifecycle -destination 'platform=iOS Simulator,name=iPhone 6'

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumTVOS -destination 'platform=tvOS Simulator,name=Apple TV 1080p'

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumTVOSLifecycle -destination 'platform=tvOS Simulator,name=Apple TV 1080p'

Available destinations for the "TealiumIOS" scheme:
{ platform:iOS, id:090e28216146e5f7abbfa1e41760bbacf75813f8, name:Hamid's iPod touch }
{ platform:iOS Simulator, id:0D3D8500-425E-4DA9-AA13-91A8D7615EDD, OS:8.1, name:iPad 2 }
{ platform:iOS Simulator, id:71FE416E-A365-4DE5-A67A-CF33727498E0, OS:8.2, name:iPad 2 }
{ platform:iOS Simulator, id:C848A9FD-5FE8-4BA0-9FDA-0A85A478250B, OS:8.3, name:iPad 2 }
{ platform:iOS Simulator, id:0C1A319E-6F96-4AD6-B805-0269E7AE24A0, OS:8.4, name:iPad 2 }
{ platform:iOS Simulator, id:6EAFE350-1305-4952-B079-FA1318724AF6, OS:9.0, name:iPad 2 }
{ platform:iOS Simulator, id:60261574-CAA2-4C73-8E1B-8E9E9ED2F33A, OS:9.1, name:iPad 2 }
{ platform:iOS Simulator, id:63C2BD5C-ECAC-4B26-88E4-1A1137DE1598, OS:9.3, name:iPad 2 }
{ platform:iOS Simulator, id:DD0D9C43-861C-4AAC-9BBD-66E5A3E8B42C, OS:8.1, name:iPad Air }
{ platform:iOS Simulator, id:91E04A8F-E53B-40A1-A100-97ED61BCD311, OS:8.2, name:iPad Air }
{ platform:iOS Simulator, id:29210194-4B88-4BA0-891A-A9603CCACE26, OS:8.3, name:iPad Air }
{ platform:iOS Simulator, id:5F03B56C-6A51-4604-82DD-0D7C27477346, OS:8.4, name:iPad Air }
{ platform:iOS Simulator, id:6A95BF0A-0330-44B9-BC06-2594AA65A4EB, OS:9.0, name:iPad Air }
{ platform:iOS Simulator, id:9B6C6B56-EF3B-4567-BEE0-38ABB0EBDC8D, OS:9.1, name:iPad Air }
{ platform:iOS Simulator, id:A3537C2E-CFD7-4256-9657-326DE234C1CE, OS:9.3, name:iPad Air }
{ platform:iOS Simulator, id:FE401997-BC94-49A1-8FCC-D388DD21E2C9, OS:9.0, name:iPad Air 2 }
{ platform:iOS Simulator, id:8F04C85C-ABF0-4825-BC66-779478BA7678, OS:9.1, name:iPad Air 2 }
{ platform:iOS Simulator, id:FCA7BE27-E1B6-443D-93D1-9CEA67119332, OS:9.3, name:iPad Air 2 }
{ platform:iOS Simulator, id:6D63D98C-29EF-42D3-80BC-F7855A0EDA0F, OS:9.1, name:iPad Pro }
{ platform:iOS Simulator, id:A8F568CC-A04A-430A-8AD4-9BB6909446E7, OS:9.3, name:iPad Pro }
{ platform:iOS Simulator, id:FAF0F26D-33AC-4EEC-9EE8-173A2FFBC85F, OS:8.1, name:iPad Retina }
{ platform:iOS Simulator, id:2A1938DE-56B1-4BA0-B3AA-507DFB4B1FB4, OS:8.2, name:iPad Retina }
{ platform:iOS Simulator, id:52FEF768-5AAA-444A-9157-9FB7E3BF063A, OS:8.3, name:iPad Retina }
{ platform:iOS Simulator, id:EE1DACD6-23F0-4E9F-A29F-5A0C70249CB6, OS:8.4, name:iPad Retina }
{ platform:iOS Simulator, id:F8CFBA99-E615-45A2-AC46-2604CC3233CD, OS:9.0, name:iPad Retina }
{ platform:iOS Simulator, id:67A6054A-0C4A-415C-B74B-8111ACA5BDCF, OS:9.1, name:iPad Retina }
{ platform:iOS Simulator, id:12C26195-A8B2-47BC-B2A1-130F12CB21DB, OS:9.3, name:iPad Retina }
{ platform:iOS Simulator, id:DE6F434D-84CD-43E8-B211-56FCA32BB8ED, OS:8.1, name:iPhone 4s }
{ platform:iOS Simulator, id:49F14363-ED15-498F-8B87-F67EBE2C960F, OS:8.2, name:iPhone 4s }
{ platform:iOS Simulator, id:0A26D490-803B-4A57-9229-85F94BAFCAF4, OS:8.3, name:iPhone 4s }
{ platform:iOS Simulator, id:84E281F2-7F79-4031-9F13-AA6FD8B9966A, OS:8.4, name:iPhone 4s }
{ platform:iOS Simulator, id:0C8F2750-A2B2-4B79-8616-689098D4BB31, OS:9.0, name:iPhone 4s }
{ platform:iOS Simulator, id:C7DE9780-AEB6-44BD-A869-565D72E8AE99, OS:9.1, name:iPhone 4s }
{ platform:iOS Simulator, id:3F9B19BA-F78E-41B0-9FCD-32EE1BFCA786, OS:9.3, name:iPhone 4s }
{ platform:iOS Simulator, id:22135FF2-CD2A-4BFA-ADC5-7833938EA091, OS:8.1, name:iPhone 5 }
{ platform:iOS Simulator, id:865896E6-9113-4DEB-A1D9-D2000B1F7B5F, OS:8.1, name:iPhone 5 }
{ platform:iOS Simulator, id:958C4E73-4B41-41DC-AFA6-177D62F813C0, OS:8.2, name:iPhone 5 }
{ platform:iOS Simulator, id:62241F10-D2BA-4E9C-9246-10B3807F93B2, OS:8.3, name:iPhone 5 }
{ platform:iOS Simulator, id:4392D55E-934C-4539-BB9C-4517142B0803, OS:8.4, name:iPhone 5 }
{ platform:iOS Simulator, id:E26B88D4-3D85-47E1-BD2D-64D2AE64BC5D, OS:9.0, name:iPhone 5 }
{ platform:iOS Simulator, id:E4827AE0-4913-47D0-A371-E388144448AB, OS:9.1, name:iPhone 5 }
{ platform:iOS Simulator, id:451A8648-68AF-4441-8730-229FA3C38448, OS:9.3, name:iPhone 5 }
{ platform:iOS Simulator, id:29A98355-8DF1-46BD-AA25-D35500217DD3, OS:8.1, name:iPhone 5s }
{ platform:iOS Simulator, id:664C138E-71B3-4AFB-ADEB-9D5B28044A0F, OS:8.2, name:iPhone 5s }
{ platform:iOS Simulator, id:BA7A13E6-E914-48D7-9527-3F1643E486A0, OS:8.3, name:iPhone 5s }
{ platform:iOS Simulator, id:31FF785C-526D-480E-989A-B3A030080F92, OS:8.4, name:iPhone 5s }
{ platform:iOS Simulator, id:DE280D04-F4B5-40E4-9BD4-872EB10FAA66, OS:9.0, name:iPhone 5s }
{ platform:iOS Simulator, id:AE4E54CD-02FF-4D9B-ACB4-9D9356484E79, OS:9.1, name:iPhone 5s }
{ platform:iOS Simulator, id:9E43A0A8-0C37-4ABC-A6E9-1CD56AD6C74C, OS:9.3, name:iPhone 5s }
{ platform:iOS Simulator, id:C75DDE74-A932-4983-9B0C-442E074849EB, OS:8.1, name:iPhone 6 }
{ platform:iOS Simulator, id:B224A863-16EC-4B90-B807-476DF3ECFEE6, OS:8.2, name:iPhone 6 }
{ platform:iOS Simulator, id:34F77D13-467D-4879-984E-6CAB3EB855D0, OS:8.3, name:iPhone 6 }
{ platform:iOS Simulator, id:BABD3F59-0871-43B4-A8E6-98C3F0EC0819, OS:8.4, name:iPhone 6 }
{ platform:iOS Simulator, id:17E6506B-DF46-427F-B4C4-FE56F9906005, OS:9.0, name:iPhone 6 }
{ platform:iOS Simulator, id:3906A5B8-7F70-4B2C-BC90-E43ED76260E1, OS:9.1, name:iPhone 6 }
{ platform:iOS Simulator, id:51EC9C81-310D-4DB9-835D-CF7617F73304, OS:9.3, name:iPhone 6 }
{ platform:iOS Simulator, id:D67F9D75-80CA-4E0F-A99F-3E84B94B5959, OS:8.1, name:iPhone 6 Plus }
{ platform:iOS Simulator, id:2761FEE2-49DA-414A-BC57-94740BC2DAF1, OS:8.2, name:iPhone 6 Plus }
{ platform:iOS Simulator, id:EF406B91-E585-4C46-BD20-1497A4047D28, OS:8.3, name:iPhone 6 Plus }
{ platform:iOS Simulator, id:904410EE-8EB0-47DB-BBBB-5D6313D3B0DC, OS:8.4, name:iPhone 6 Plus }
{ platform:iOS Simulator, id:9C69C42F-8A5D-472C-BB67-A4975D282BEA, OS:9.0, name:iPhone 6 Plus }
{ platform:iOS Simulator, id:20A9D50E-D04C-4D7B-AEE3-F84899E825D3, OS:9.1, name:iPhone 6 Plus }
{ platform:iOS Simulator, id:F00A3F5C-F2FC-4352-A6E8-490D62EED20E, OS:9.3, name:iPhone 6 Plus }
{ platform:iOS Simulator, id:C41A0F93-D5A7-4918-9FD2-3B554A87E682, OS:9.0, name:iPhone 6s }
{ platform:iOS Simulator, id:58921A89-EFB4-4DBC-815E-182C8EE3BE4E, OS:9.1, name:iPhone 6s }
{ platform:iOS Simulator, id:7B2267BC-A7DC-4ED0-B879-7653E68FAE5E, OS:9.3, name:iPhone 6s }
{ platform:iOS Simulator, id:A2D1E761-F672-4236-A3A9-B8179A64DDDA, OS:9.0, name:iPhone 6s Plus }
{ platform:iOS Simulator, id:0A4FA8B2-0C15-4F17-A0CE-0886CE3C5933, OS:9.1, name:iPhone 6s Plus }
{ platform:iOS Simulator, id:EBB3934D-3A27-4D66-AAA5-632128D8CB9E, OS:9.3, name:iPhone 6s Plus }


{ platform:tvOS Simulator, id:A2D98159-DF38-4D8E-85C5-D101CA0F9A64, OS:9.0, name:Apple TV 1080p }
{ platform:tvOS Simulator, id:59CB080B-29AE-4ED3-B798-DCDA2AA58F13, OS:9.2, name:Apple TV 1080p }

## DEPLOYMENT CHECKLIST

Each Target Repo
- Documentation: all public header classes
- Documentation: no apparent typos or omissions
- Framework: info.plist correct
- Framework: arch correct
- Sample Apps: all compile
- Sample App: events received in Live Events as expected
- Sample App: archives for ad hoc deployment successfully

---
Copyright (C) 2012-2016, Tealium Inc.