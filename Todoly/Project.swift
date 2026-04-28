import ProjectDescription

// MARK: - Shared Settings

let baseSettings: SettingsDictionary = [
    "SWIFT_VERSION": "5.9",
    "DEVELOPMENT_TEAM": "",
]

let deploymentTarget: DeploymentTarget = .iOS(targetVersion: "18.0", devices: .iphone)

// MARK: - Project

let project = Project(
    name: "Todoly",
    options: .options(
        defaultKnownRegions: ["ko", "en"],
        developmentRegion: "ko"
    ),
    settings: .settings(base: baseSettings),
    targets: [
        // MARK: - App Target
        Target(
            name: "Todoly",
            platform: .iOS,
            product: .app,
            bundleId: "com.todoly.app",
            deploymentTarget: deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Todoly",
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                ],
                "UIApplicationSupportsIndirectInputEvents": true,
                "UILaunchScreen": [
                    "UIColorName": "LaunchBackground",
                ],
                "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
                "NSCameraUsageDescription": "프로필 사진을 촬영하기 위해 카메라 접근이 필요합니다.",
                "NSPhotoLibraryUsageDescription": "프로필 사진을 선택하기 위해 사진 라이브러리 접근이 필요합니다.",
                "NSUserNotificationsUsageDescription": "할 일 알림을 보내기 위해 알림 권한이 필요합니다.",
                "NSSupportsLiveActivities": true,
            ]),
            sources: [
                "Todoly/App/**",
                "Todoly/Core/**",
                "Todoly/Data/**",
                "Todoly/Domain/**",
                "Todoly/Features/**",
                "Shared/**",
            ],
            resources: [
                "Todoly/Assets.xcassets/**",
                "Todoly/todoly_alarm.caf",
            ],
            entitlements: .file(path: "Todoly/Todoly.entitlements"),
            dependencies: [
                .target(name: "TodolyWidget"),
                .target(name: "TodolyWatchApp"),
            ],
            settings: .settings(
                base: [
                    "MARKETING_VERSION": "1.0.0",
                    "CURRENT_PROJECT_VERSION": "1",
                ]
            )
        ),

        // MARK: - Unit Tests Target
        Target(
            name: "TodolyTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.todoly.app.tests",
            deploymentTarget: deploymentTarget,
            sources: ["TodolyTests/**"],
            dependencies: [
                .target(name: "Todoly"),
            ]
        ),

        // MARK: - Widget Extension (Live Activity + Today Widget)
        Target(
            name: "TodolyWidget",
            platform: .iOS,
            product: .appExtension,
            bundleId: "com.todoly.app.widget",
            deploymentTarget: deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
                ],
            ]),
            sources: [
                "TodolyWidget/**",
                "Todoly/Domain/Models/Todo.swift",
                "Todoly/Domain/Models/TodoCategory.swift",
                "Todoly/Domain/Models/Priority.swift",
                "Todoly/Domain/Models/TodoAlarmAttributes.swift",
                "Todoly/Domain/Logic/TodoFilterLogic.swift",
                "Todoly/Domain/Logic/TodoMutationLogic.swift",
                "Todoly/Core/Extensions/Color+Brand.swift",
                "Shared/**",
            ],
            entitlements: .file(path: "TodolyWidget/TodolyWidget.entitlements"),
            settings: .settings(
                base: [
                    "MARKETING_VERSION": "1.0.0",
                    "CURRENT_PROJECT_VERSION": "1",
                ]
            )
        ),

        // MARK: - Watch App (Container)
        Target(
            name: "TodolyWatchApp",
            platform: .watchOS,
            product: .watch2App,
            bundleId: "com.todoly.app.watchkitapp",
            deploymentTarget: .watchOS(targetVersion: "10.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Todoly",
                "WKCompanionAppBundleIdentifier": "com.todoly.app",
            ]),
            entitlements: .file(path: "TodolyWatch/TodolyWatch.entitlements"),
            dependencies: [
                .target(name: "TodolyWatchExtension"),
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "5.9",
                    "DEVELOPMENT_TEAM": "",
                    "MARKETING_VERSION": "1.0.0",
                    "CURRENT_PROJECT_VERSION": "1",
                ]
            )
        ),

        // MARK: - Watch Extension (Sources)
        Target(
            name: "TodolyWatchExtension",
            platform: .watchOS,
            product: .watch2Extension,
            bundleId: "com.todoly.app.watchkitapp.extension",
            deploymentTarget: .watchOS(targetVersion: "10.0"),
            infoPlist: .extendingDefault(with: [
                "WKExtensionDelegateClassName": "$(PRODUCT_MODULE_NAME).ExtensionDelegate",
            ]),
            sources: [
                "TodolyWatch/**",
                "Todoly/Domain/Models/Todo.swift",
                "Todoly/Domain/Models/TodoCategory.swift",
                "Todoly/Domain/Models/Priority.swift",
                "Todoly/Domain/Logic/TodoFilterLogic.swift",
                "Todoly/Domain/Logic/TodoMutationLogic.swift",
                "Todoly/Core/Extensions/Color+Brand.swift",
                "Shared/**",
            ],
            entitlements: .file(path: "TodolyWatch/TodolyWatch.entitlements"),
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "5.9",
                    "DEVELOPMENT_TEAM": "",
                    "MARKETING_VERSION": "1.0.0",
                    "CURRENT_PROJECT_VERSION": "1",
                ]
            )
        ),
    ]
)
