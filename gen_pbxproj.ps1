# gen_pbxproj.ps1 — generates MHDPruvodce.xcodeproj/project.pbxproj
Set-StrictMode -Off
$projectRoot = Split-Path $MyInvocation.MyCommand.Path
$appDir      = "$projectRoot\MHDPruvodce"

$swiftFiles = Get-ChildItem -Path $appDir -Recurse -Filter "*.swift" |
    Where-Object { $_.FullName -notmatch "\\Preview Content\\" } | Sort-Object FullName
$previewFiles = Get-ChildItem -Path "$appDir\Preview Content" -Filter "*.swift" -ErrorAction SilentlyContinue | Sort-Object FullName
$testSwiftFiles = Get-ChildItem -Path "$projectRoot\MHDPruvodceTests" -Filter "*.swift" | Sort-Object FullName
$allSourceFiles = @($swiftFiles) + @($previewFiles | Where-Object {$_})

# Fixed UUIDs
$IDs = @{
    PROJECT        = "AA000001000000000000000A"
    APP_TARGET     = "AA000002000000000000000A"
    TEST_TARGET    = "AA000003000000000000000A"
    PROJ_CONFLIST  = "AA000004000000000000000A"
    APP_CONFLIST   = "AA000005000000000000000A"
    TEST_CONFLIST  = "AA000006000000000000000A"
    DEBUG_PROJ     = "AA000007000000000000000A"
    RELEASE_PROJ   = "AA000008000000000000000A"
    DEBUG_APP      = "AA000009000000000000000A"
    RELEASE_APP    = "AA00000A000000000000000A"
    DEBUG_TEST     = "AA00000B000000000000000A"
    RELEASE_TEST   = "AA00000C000000000000000A"
    SOURCES_PHASE  = "AA00000D000000000000000A"
    RES_PHASE      = "AA00000E000000000000000A"
    TEST_SOURCES   = "AA000010000000000000000A"
    PRODUCTS_GROUP = "AA000011000000000000000A"
    ROOT_GROUP     = "AA000012000000000000000A"
    APP_PRODUCT    = "AA000013000000000000000A"
    TEST_PRODUCT   = "AA000014000000000000000A"
    INFOPLIST_REF  = "AA000015000000000000000A"
    ENTITLE_REF    = "AA000016000000000000000A"
    ASSETS_REF     = "AA000017000000000000000A"
    LOCALIZE_REF   = "AA000018000000000000000A"
    ASSETS_BUILD   = "AA000019000000000000000A"
    LOCALIZE_BUILD = "AA00001A000000000000000A"
    GRP_APP        = "AA000020000000000000000A"
    GRP_APPFOLDER  = "AA000021000000000000000A"
    GRP_CONFIG     = "AA000022000000000000000A"
    GRP_MODELS     = "AA000023000000000000000A"
    GRP_NETWORK    = "AA000024000000000000000A"
    GRP_MANAGERS   = "AA000025000000000000000A"
    GRP_VIEWMODELS = "AA000026000000000000000A"
    GRP_VIEWS      = "AA000027000000000000000A"
    GRP_SEARCH     = "AA000028000000000000000A"
    GRP_CONNS      = "AA000029000000000000000A"
    GRP_DETAIL     = "AA00002A000000000000000A"
    GRP_TRACKING   = "AA00002B000000000000000A"
    GRP_COMPONENTS = "AA00002C000000000000000A"
    GRP_LIVEACT    = "AA00002D000000000000000A"
    GRP_EXTENSIONS = "AA00002E000000000000000A"
    GRP_RESOURCES  = "AA00002F000000000000000A"
    GRP_PREVIEW    = "AA000030000000000000000A"
    GRP_TESTS      = "AA000031000000000000000A"
}

# Generate file UUIDs
$fileRefs = @{}; $buildFiles = @{}; $testBuildFiles = @{}
$counter = 0x40
foreach ($f in $allSourceFiles) {
    $hex = $counter.ToString("X2")
    $fileRefs[$f.FullName]   = "AA0001${hex}000000000000000A"
    $buildFiles[$f.FullName] = "AA0002${hex}000000000000000A"
    $counter++
}
foreach ($f in $testSwiftFiles) {
    $hex = $counter.ToString("X2")
    $fileRefs[$f.FullName]       = "AA0001${hex}000000000000000A"
    $testBuildFiles[$f.FullName] = "AA0003${hex}000000000000000A"
    $counter++
}

function Rel([string]$full) { $full.Replace($appDir + "\", "").Replace("\", "/") }

# Group membership
$folderGroups = @{
    "App"              = $IDs.GRP_APPFOLDER
    "Config"           = $IDs.GRP_CONFIG
    "Models"           = $IDs.GRP_MODELS
    "Networking"       = $IDs.GRP_NETWORK
    "Managers"         = $IDs.GRP_MANAGERS
    "ViewModels"       = $IDs.GRP_VIEWMODELS
    "Views/Search"     = $IDs.GRP_SEARCH
    "Views/Connections"= $IDs.GRP_CONNS
    "Views/Detail"     = $IDs.GRP_DETAIL
    "Views/Tracking"   = $IDs.GRP_TRACKING
    "Views/Components" = $IDs.GRP_COMPONENTS
    "LiveActivity"     = $IDs.GRP_LIVEACT
    "Extensions"       = $IDs.GRP_EXTENSIONS
    "Preview Content"  = $IDs.GRP_PREVIEW
}
$groupFiles = @{}
foreach ($k in $folderGroups.Keys) { $groupFiles[$k] = @() }
foreach ($f in $allSourceFiles) {
    $rel   = Rel $f.FullName
    $parts = $rel -split "/"
    $grp   = if ($parts.Count -ge 3) { ($parts[0..($parts.Count-2)] -join "/") } elseif ($parts.Count -eq 2) { $parts[0] } else { "App" }
    if ($groupFiles.ContainsKey($grp)) { $groupFiles[$grp] += $f }
}

$L = [System.Collections.Generic.List[string]]::new()
$L.Add('// !$*UTF8*$!')
$L.Add('{')
$L.Add('	archiveVersion = 1;')
$L.Add('	classes = {')
$L.Add('	};')
$L.Add('	objectVersion = 56;')
$L.Add('	objects = {')
$L.Add('')
$L.Add('/* Begin PBXBuildFile section */')
foreach ($f in $allSourceFiles) {
    $b = $buildFiles[$f.FullName]; $r = $fileRefs[$f.FullName]
    $L.Add("		$b /* $($f.Name) in Sources */ = {isa = PBXBuildFile; fileRef = $r /* $($f.Name) */; };")
}
foreach ($f in $testSwiftFiles) {
    $b = $testBuildFiles[$f.FullName]; $r = $fileRefs[$f.FullName]
    $L.Add("		$b /* $($f.Name) in Sources */ = {isa = PBXBuildFile; fileRef = $r /* $($f.Name) */; };")
}
$L.Add("		$($IDs.ASSETS_BUILD) /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = $($IDs.ASSETS_REF) /* Assets.xcassets */; };")
$L.Add("		$($IDs.LOCALIZE_BUILD) /* cs in Resources */ = {isa = PBXBuildFile; fileRef = $($IDs.LOCALIZE_REF) /* cs */; };")
$L.Add('/* End PBXBuildFile section */')
$L.Add('')
$L.Add('/* Begin PBXFileReference section */')
$L.Add("		$($IDs.APP_PRODUCT) /* MHDPruvodce.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MHDPruvodce.app; sourceTree = BUILT_PRODUCTS_DIR; };")
$L.Add("		$($IDs.TEST_PRODUCT) /* MHDPruvodceTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = MHDPruvodceTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };")
$L.Add("		$($IDs.INFOPLIST_REF) /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = ""<group>""; };")
$L.Add("		$($IDs.ENTITLE_REF) /* MHDPruvodce.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = MHDPruvodce.entitlements; sourceTree = ""<group>""; };")
$L.Add("		$($IDs.ASSETS_REF) /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = ""<group>""; };")
$L.Add("		$($IDs.LOCALIZE_REF) /* cs */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = cs; path = cs.lproj/Localizable.strings; sourceTree = ""<group>""; };")
foreach ($f in ($allSourceFiles + $testSwiftFiles)) {
    $r = $fileRefs[$f.FullName]
    $L.Add("		$r /* $($f.Name) */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = $($f.Name); sourceTree = ""<group>""; };")
}
$L.Add('/* End PBXFileReference section */')
$L.Add('')
$L.Add('/* Begin PBXGroup section */')

# Products
$L.Add("		$($IDs.PRODUCTS_GROUP) /* Products */ = {")
$L.Add("			isa = PBXGroup; children = (")
$L.Add("				$($IDs.APP_PRODUCT) /* MHDPruvodce.app */,")
$L.Add("				$($IDs.TEST_PRODUCT) /* MHDPruvodceTests.xctest */,")
$L.Add("			); name = Products; sourceTree = ""<group>""; };")

# Leaf groups
foreach ($grp in $folderGroups.Keys) {
    $gid   = $folderGroups[$grp]
    $gname = ($grp -split "/")[-1]
    $L.Add("		$gid /* $gname */ = {")
    $L.Add("			isa = PBXGroup; children = (")
    foreach ($f in $groupFiles[$grp]) {
        $r = $fileRefs[$f.FullName]
        $L.Add("				$r /* $($f.Name) */,")
    }
    $L.Add("			); path = $gname; sourceTree = ""<group>""; };")
}

# Views parent
$L.Add("		$($IDs.GRP_VIEWS) /* Views */ = {")
$L.Add("			isa = PBXGroup; children = (")
foreach ($sub in @("GRP_SEARCH","GRP_CONNS","GRP_DETAIL","GRP_TRACKING","GRP_COMPONENTS")) {
    $names = @{GRP_SEARCH="Search";GRP_CONNS="Connections";GRP_DETAIL="Detail";GRP_TRACKING="Tracking";GRP_COMPONENTS="Components"}
    $L.Add("				$($IDs[$sub]) /* $($names[$sub]) */,")
}
$L.Add("			); path = Views; sourceTree = ""<group>""; };")

# Resources
$L.Add("		$($IDs.GRP_RESOURCES) /* Resources */ = {")
$L.Add("			isa = PBXGroup; children = (")
$L.Add("				$($IDs.ASSETS_REF) /* Assets.xcassets */,")
$L.Add("				$($IDs.LOCALIZE_REF) /* cs */,")
$L.Add("			); path = Resources; sourceTree = ""<group>""; };")

# Tests
$L.Add("		$($IDs.GRP_TESTS) /* MHDPruvodceTests */ = {")
$L.Add("			isa = PBXGroup; children = (")
foreach ($f in $testSwiftFiles) { $L.Add("				$($fileRefs[$f.FullName]) /* $($f.Name) */,") }
$L.Add("			); path = MHDPruvodceTests; sourceTree = ""<group>""; };")

# App container
$L.Add("		$($IDs.GRP_APP) /* MHDPruvodce */ = {")
$L.Add("			isa = PBXGroup; children = (")
foreach ($sub in @("GRP_APPFOLDER","GRP_CONFIG","GRP_MODELS","GRP_NETWORK","GRP_MANAGERS","GRP_VIEWMODELS","GRP_VIEWS","GRP_LIVEACT","GRP_EXTENSIONS","GRP_RESOURCES","GRP_PREVIEW")) {
    $names2 = @{GRP_APPFOLDER="App";GRP_CONFIG="Config";GRP_MODELS="Models";GRP_NETWORK="Networking";GRP_MANAGERS="Managers";GRP_VIEWMODELS="ViewModels";GRP_VIEWS="Views";GRP_LIVEACT="LiveActivity";GRP_EXTENSIONS="Extensions";GRP_RESOURCES="Resources";GRP_PREVIEW="Preview Content"}
    $L.Add("				$($IDs[$sub]) /* $($names2[$sub]) */,")
}
$L.Add("				$($IDs.INFOPLIST_REF) /* Info.plist */,")
$L.Add("				$($IDs.ENTITLE_REF) /* MHDPruvodce.entitlements */,")
$L.Add("			); path = MHDPruvodce; sourceTree = ""<group>""; };")

# Root
$L.Add("		$($IDs.ROOT_GROUP) = {")
$L.Add("			isa = PBXGroup; children = (")
$L.Add("				$($IDs.GRP_APP) /* MHDPruvodce */,")
$L.Add("				$($IDs.GRP_TESTS) /* MHDPruvodceTests */,")
$L.Add("				$($IDs.PRODUCTS_GROUP) /* Products */,")
$L.Add("			); sourceTree = ""<group>""; };")
$L.Add('/* End PBXGroup section */')
$L.Add('')

# Targets
$L.Add('/* Begin PBXNativeTarget section */')
$L.Add("		$($IDs.APP_TARGET) /* MHDPruvodce */ = { isa = PBXNativeTarget;")
$L.Add("			buildConfigurationList = $($IDs.APP_CONFLIST);")
$L.Add("			buildPhases = ( $($IDs.SOURCES_PHASE) /* Sources */, $($IDs.RES_PHASE) /* Resources */, );")
$L.Add("			buildRules = (); dependencies = (); name = MHDPruvodce; productName = MHDPruvodce;")
$L.Add("			productReference = $($IDs.APP_PRODUCT) /* MHDPruvodce.app */;")
$L.Add('			productType = "com.apple.product-type.application"; };')
$L.Add("		$($IDs.TEST_TARGET) /* MHDPruvodceTests */ = { isa = PBXNativeTarget;")
$L.Add("			buildConfigurationList = $($IDs.TEST_CONFLIST);")
$L.Add("			buildPhases = ( $($IDs.TEST_SOURCES) /* Sources */, );")
$L.Add("			buildRules = (); dependencies = (); name = MHDPruvodceTests; productName = MHDPruvodceTests;")
$L.Add("			productReference = $($IDs.TEST_PRODUCT) /* MHDPruvodceTests.xctest */;")
$L.Add('			productType = "com.apple.product-type.bundle.unit-test"; };')
$L.Add('/* End PBXNativeTarget section */')
$L.Add('')

# PBXProject
$L.Add('/* Begin PBXProject section */')
$L.Add("		$($IDs.PROJECT) /* Project object */ = {")
$L.Add("			isa = PBXProject;")
$L.Add("			attributes = { BuildIndependentTargetsInParallel = 1; LastSwiftUpdateCheck = 1500; LastUpgradeCheck = 1500;")
$L.Add("				TargetAttributes = {")
$L.Add("					$($IDs.APP_TARGET) = { CreatedOnToolsVersion = 15.0; };")
$L.Add("					$($IDs.TEST_TARGET) = { CreatedOnToolsVersion = 15.0; TestTargetID = $($IDs.APP_TARGET); };")
$L.Add("				}; };")
$L.Add("			buildConfigurationList = $($IDs.PROJ_CONFLIST);")
$L.Add('			compatibilityVersion = "Xcode 14.0"; developmentRegion = cs; hasScannedForEncodings = 0;')
$L.Add("			knownRegions = ( en, cs, Base, );")
$L.Add("			mainGroup = $($IDs.ROOT_GROUP); productRefGroup = $($IDs.PRODUCTS_GROUP) /* Products */;")
$L.Add('			projectDirPath = ""; projectRoot = "";')
$L.Add("			targets = ( $($IDs.APP_TARGET) /* MHDPruvodce */, $($IDs.TEST_TARGET) /* MHDPruvodceTests */, ); };")
$L.Add('/* End PBXProject section */')
$L.Add('')

# Build phases
$L.Add('/* Begin PBXResourcesBuildPhase section */')
$L.Add("		$($IDs.RES_PHASE) /* Resources */ = { isa = PBXResourcesBuildPhase; buildActionMask = 2147483647;")
$L.Add("			files = ( $($IDs.ASSETS_BUILD) /* Assets.xcassets in Resources */, $($IDs.LOCALIZE_BUILD) /* cs in Resources */, );")
$L.Add("			runOnlyForDeploymentPostprocessing = 0; };")
$L.Add('/* End PBXResourcesBuildPhase section */')
$L.Add('')
$L.Add('/* Begin PBXSourcesBuildPhase section */')
$L.Add("		$($IDs.SOURCES_PHASE) /* Sources */ = { isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (")
foreach ($f in $allSourceFiles) { $L.Add("			$($buildFiles[$f.FullName]) /* $($f.Name) in Sources */,") }
$L.Add("		); runOnlyForDeploymentPostprocessing = 0; };")
$L.Add("		$($IDs.TEST_SOURCES) /* Sources */ = { isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (")
foreach ($f in $testSwiftFiles) { $L.Add("			$($testBuildFiles[$f.FullName]) /* $($f.Name) in Sources */,") }
$L.Add("		); runOnlyForDeploymentPostprocessing = 0; };")
$L.Add('/* End PBXSourcesBuildPhase section */')
$L.Add('')

# Build configurations
$L.Add('/* Begin XCBuildConfiguration section */')

$projBase = '			ALWAYS_SEARCH_USER_PATHS = NO; CLANG_ANALYZER_NONNULL = YES; CLANG_ENABLE_MODULES = YES; CLANG_ENABLE_OBJC_ARC = YES; CLANG_ENABLE_OBJC_WEAK = YES; GCC_C_LANGUAGE_STANDARD = gnu17; GCC_NO_COMMON_BLOCKS = YES; GCC_WARN_64_TO_32_BIT_CONVERSION = YES; GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR; GCC_WARN_UNDECLARED_SELECTOR = YES; GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE; GCC_WARN_UNUSED_FUNCTION = YES; GCC_WARN_UNUSED_VARIABLE = YES; IPHONEOS_DEPLOYMENT_TARGET = 17.0; SDKROOT = iphoneos;'

$L.Add("		$($IDs.DEBUG_PROJ) /* Debug */ = { isa = XCBuildConfiguration; buildSettings = {")
$L.Add($projBase)
$L.Add('			COPY_PHASE_STRIP = NO; DEBUG_INFORMATION_FORMAT = dwarf; ENABLE_TESTABILITY = YES;')
$L.Add('			GCC_DYNAMIC_NO_PIC = NO; GCC_OPTIMIZATION_LEVEL = 0;')
$L.Add('			GCC_PREPROCESSOR_DEFINITIONS = ( "DEBUG=1", "$(inherited)", );')
$L.Add('			MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE; ONLY_ACTIVE_ARCH = YES;')
$L.Add('			SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG; SWIFT_OPTIMIZATION_LEVEL = "-Onone";')
$L.Add("		}; name = Debug; };")

$L.Add("		$($IDs.RELEASE_PROJ) /* Release */ = { isa = XCBuildConfiguration; buildSettings = {")
$L.Add($projBase)
$L.Add('			COPY_PHASE_STRIP = NO; DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
$L.Add('			ENABLE_NS_ASSERTIONS = NO; MTL_FAST_MATH = YES;')
$L.Add('			SWIFT_COMPILATION_MODE = wholemodule; SWIFT_OPTIMIZATION_LEVEL = "-O"; VALIDATE_PRODUCT = YES;')
$L.Add("		}; name = Release; };")

$appBase = '			ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon; ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AppPrimary; CODE_SIGN_ENTITLEMENTS = MHDPruvodce/MHDPruvodce.entitlements; CODE_SIGN_STYLE = Automatic; CURRENT_PROJECT_VERSION = 1; DEVELOPMENT_ASSET_PATHS = "\"MHDPruvodce/Preview Content\""; DEVELOPMENT_TEAM = ""; ENABLE_PREVIEWS = YES; GENERATE_INFOPLIST_FILE = NO; INFOPLIST_FILE = MHDPruvodce/Info.plist; IPHONEOS_DEPLOYMENT_TARGET = 17.0; LD_RUNPATH_SEARCH_PATHS = ( "$(inherited)", "@executable_path/Frameworks", ); MARKETING_VERSION = 1.0; PRODUCT_BUNDLE_IDENTIFIER = cz.mhd.pruvodce; PRODUCT_NAME = MHDPruvodce; SWIFT_EMIT_LOC_STRINGS = YES; SWIFT_VERSION = 5.9; TARGETED_DEVICE_FAMILY = 1;'

$L.Add("		$($IDs.DEBUG_APP) /* Debug */ = { isa = XCBuildConfiguration; buildSettings = {")
$L.Add($appBase); $L.Add("		}; name = Debug; };")
$L.Add("		$($IDs.RELEASE_APP) /* Release */ = { isa = XCBuildConfiguration; buildSettings = {")
$L.Add($appBase); $L.Add("		}; name = Release; };")

$testBase = '			BUNDLE_LOADER = "$(TEST_HOST)"; CODE_SIGN_STYLE = Automatic; CURRENT_PROJECT_VERSION = 1; GENERATE_INFOPLIST_FILE = YES; IPHONEOS_DEPLOYMENT_TARGET = 17.0; MARKETING_VERSION = 1.0; PRODUCT_BUNDLE_IDENTIFIER = cz.mhd.pruvodce.tests; PRODUCT_NAME = MHDPruvodceTests; SWIFT_VERSION = 5.9; TARGETED_DEVICE_FAMILY = 1; TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MHDPruvodce.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/MHDPruvodce";'
$L.Add("		$($IDs.DEBUG_TEST) /* Debug */ = { isa = XCBuildConfiguration; buildSettings = {")
$L.Add($testBase); $L.Add("		}; name = Debug; };")
$L.Add("		$($IDs.RELEASE_TEST) /* Release */ = { isa = XCBuildConfiguration; buildSettings = {")
$L.Add($testBase); $L.Add("		}; name = Release; };")
$L.Add('/* End XCBuildConfiguration section */')
$L.Add('')

# ConfigurationLists
$L.Add('/* Begin XCConfigurationList section */')
$L.Add("		$($IDs.PROJ_CONFLIST) = { isa = XCConfigurationList; buildConfigurations = ( $($IDs.DEBUG_PROJ) /* Debug */, $($IDs.RELEASE_PROJ) /* Release */, ); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; };")
$L.Add("		$($IDs.APP_CONFLIST) = { isa = XCConfigurationList; buildConfigurations = ( $($IDs.DEBUG_APP) /* Debug */, $($IDs.RELEASE_APP) /* Release */, ); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; };")
$L.Add("		$($IDs.TEST_CONFLIST) = { isa = XCConfigurationList; buildConfigurations = ( $($IDs.DEBUG_TEST) /* Debug */, $($IDs.RELEASE_TEST) /* Release */, ); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; };")
$L.Add('/* End XCConfigurationList section */')

$L.Add('	};')
$L.Add("	rootObject = $($IDs.PROJECT) /* Project object */;")
$L.Add('}')

$outPath = "$projectRoot\MHDPruvodce.xcodeproj\project.pbxproj"
[System.IO.File]::WriteAllLines($outPath, $L, [System.Text.UTF8Encoding]::new($false))
$lineCount = $L.Count
Write-Host "pbxproj generated: $lineCount lines | app sources: $($allSourceFiles.Count) | test sources: $($testSwiftFiles.Count)"
