const fs = require('fs');
const path = require('path');

const appDir = 'MHDPruvodce';
const testDir = 'MHDPruvodceTests';

function walk(dir, ext) {
  const results = [];
  if (!fs.existsSync(dir)) return results;
  for (const f of fs.readdirSync(dir, {withFileTypes: true})) {
    const full = path.join(dir, f.name).replace(/\\/g, '/');
    if (f.isDirectory()) results.push(...walk(full, ext));
    else if (f.name.endsWith(ext)) results.push(full);
  }
  return results.sort();
}

const previewFiles = walk(appDir + '/Preview Content', '.swift');
const appSwift = walk(appDir, '.swift').filter(f => !f.includes('Preview Content'));
const allApp = [...appSwift, ...previewFiles];
const testSwift = walk(testDir, '.swift');

let c = 0x40;
const refs = {}, builds = {}, testBuilds = {};
for (const f of allApp) {
  const h = c.toString(16).toUpperCase().padStart(2,'0');
  refs[f]   = 'AA0001' + h + '000000000000000A';
  builds[f] = 'AA0002' + h + '000000000000000A';
  c++;
}
for (const f of testSwift) {
  const h = c.toString(16).toUpperCase().padStart(2,'0');
  refs[f]       = 'AA0001' + h + '000000000000000A';
  testBuilds[f] = 'AA0003' + h + '000000000000000A';
  c++;
}

const ID = {
  PROJECT:'AA000001000000000000000A', APP_TARGET:'AA000002000000000000000A',
  TEST_TARGET:'AA000003000000000000000A', PROJ_CONFLIST:'AA000004000000000000000A',
  APP_CONFLIST:'AA000005000000000000000A', TEST_CONFLIST:'AA000006000000000000000A',
  DEBUG_PROJ:'AA000007000000000000000A', RELEASE_PROJ:'AA000008000000000000000A',
  DEBUG_APP:'AA000009000000000000000A', RELEASE_APP:'AA00000A000000000000000A',
  DEBUG_TEST:'AA00000B000000000000000A', RELEASE_TEST:'AA00000C000000000000000A',
  SRC_PHASE:'AA00000D000000000000000A', RES_PHASE:'AA00000E000000000000000A',
  TEST_SRC:'AA000010000000000000000A', PRODUCTS_GRP:'AA000011000000000000000A',
  ROOT_GRP:'AA000012000000000000000A', APP_PROD:'AA000013000000000000000A',
  TEST_PROD:'AA000014000000000000000A', INFO_REF:'AA000015000000000000000A',
  ENTITLE_REF:'AA000016000000000000000A', ASSETS_REF:'AA000017000000000000000A',
  LOCALE_REF:'AA000018000000000000000A', ASSETS_BUILD:'AA000019000000000000000A',
  LOCALE_BUILD:'AA00001A000000000000000A',
  GRP_APP:'AA000020000000000000000A', GRP_APPF:'AA000021000000000000000A',
  GRP_CFG:'AA000022000000000000000A', GRP_MDL:'AA000023000000000000000A',
  GRP_NET:'AA000024000000000000000A', GRP_MGR:'AA000025000000000000000A',
  GRP_VM:'AA000026000000000000000A', GRP_VIEWS:'AA000027000000000000000A',
  GRP_SRCH:'AA000028000000000000000A', GRP_CONN:'AA000029000000000000000A',
  GRP_DET:'AA00002A000000000000000A', GRP_TRK:'AA00002B000000000000000A',
  GRP_CMP:'AA00002C000000000000000A', GRP_LIVE:'AA00002D000000000000000A',
  GRP_EXT:'AA00002E000000000000000A', GRP_RES:'AA00002F000000000000000A',
  GRP_PRV:'AA000030000000000000000A', GRP_TEST:'AA000031000000000000000A',
};

function folderKey(f) {
  const parts = f.split('/');
  if (parts.length >= 3) return parts.slice(0, parts.length-1).join('/');
  if (parts.length === 2) return parts[0];
  return appDir;
}

const folderToGrp = {
  [appDir+'/App']:               ID.GRP_APPF,
  [appDir+'/Config']:            ID.GRP_CFG,
  [appDir+'/Models']:            ID.GRP_MDL,
  [appDir+'/Networking']:        ID.GRP_NET,
  [appDir+'/Managers']:          ID.GRP_MGR,
  [appDir+'/ViewModels']:        ID.GRP_VM,
  [appDir+'/Views/Search']:      ID.GRP_SRCH,
  [appDir+'/Views/Connections']: ID.GRP_CONN,
  [appDir+'/Views/Detail']:      ID.GRP_DET,
  [appDir+'/Views/Tracking']:    ID.GRP_TRK,
  [appDir+'/Views/Components']:  ID.GRP_CMP,
  [appDir+'/LiveActivity']:      ID.GRP_LIVE,
  [appDir+'/Extensions']:        ID.GRP_EXT,
  [appDir+'/Preview Content']:   ID.GRP_PRV,
};
const grpFiles = {};
for (const k of Object.keys(folderToGrp)) grpFiles[k] = [];
for (const f of allApp) {
  const fk = folderKey(f);
  if (grpFiles[fk] !== undefined) grpFiles[fk].push(f);
}

const grpNames = {
  [appDir+'/App']:'App', [appDir+'/Config']:'Config', [appDir+'/Models']:'Models',
  [appDir+'/Networking']:'Networking', [appDir+'/Managers']:'Managers',
  [appDir+'/ViewModels']:'ViewModels', [appDir+'/Views/Search']:'Search',
  [appDir+'/Views/Connections']:'Connections', [appDir+'/Views/Detail']:'Detail',
  [appDir+'/Views/Tracking']:'Tracking', [appDir+'/Views/Components']:'Components',
  [appDir+'/LiveActivity']:'LiveActivity', [appDir+'/Extensions']:'Extensions',
  [appDir+'/Preview Content']:'Preview Content',
};

function q(s) { return '"' + s + '"'; }

const L = [];
L.push('// !$*UTF8*$!');
L.push('{');
L.push('\tarchiveVersion = 1;');
L.push('\tclasses = {');
L.push('\t};');
L.push('\tobjectVersion = 56;');
L.push('\tobjects = {');
L.push('');

// PBXBuildFile
L.push('/* Begin PBXBuildFile section */');
for (const f of allApp) {
  const n = path.basename(f);
  L.push('\t\t' + builds[f] + ' /* ' + n + ' in Sources */ = {isa = PBXBuildFile; fileRef = ' + refs[f] + ' /* ' + n + ' */; };');
}
for (const f of testSwift) {
  const n = path.basename(f);
  L.push('\t\t' + testBuilds[f] + ' /* ' + n + ' in Sources */ = {isa = PBXBuildFile; fileRef = ' + refs[f] + ' /* ' + n + ' */; };');
}
L.push('\t\t' + ID.ASSETS_BUILD + ' /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = ' + ID.ASSETS_REF + ' /* Assets.xcassets */; };');
L.push('\t\t' + ID.LOCALE_BUILD + ' /* cs in Resources */ = {isa = PBXBuildFile; fileRef = ' + ID.LOCALE_REF + ' /* cs */; };');
L.push('/* End PBXBuildFile section */');
L.push('');

// PBXFileReference
L.push('/* Begin PBXFileReference section */');
L.push('\t\t' + ID.APP_PROD + ' /* MHDPruvodce.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MHDPruvodce.app; sourceTree = BUILT_PRODUCTS_DIR; };');
L.push('\t\t' + ID.TEST_PROD + ' /* MHDPruvodceTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = MHDPruvodceTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };');
L.push('\t\t' + ID.INFO_REF + ' /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = ' + q('<group>') + '; };');
L.push('\t\t' + ID.ENTITLE_REF + ' /* MHDPruvodce.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = MHDPruvodce.entitlements; sourceTree = ' + q('<group>') + '; };');
L.push('\t\t' + ID.ASSETS_REF + ' /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = ' + q('<group>') + '; };');
L.push('\t\t' + ID.LOCALE_REF + ' /* cs */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = cs; path = ' + q('cs.lproj/Localizable.strings') + '; sourceTree = ' + q('<group>') + '; };');
for (const f of [...allApp, ...testSwift]) {
  const n = path.basename(f);
  L.push('\t\t' + refs[f] + ' /* ' + n + ' */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ' + q(n) + '; sourceTree = ' + q('<group>') + '; };');
}
L.push('/* End PBXFileReference section */');
L.push('');

// PBXGroup
L.push('/* Begin PBXGroup section */');

L.push('\t\t' + ID.PRODUCTS_GRP + ' /* Products */ = {');
L.push('\t\t\tisa = PBXGroup;');
L.push('\t\t\tchildren = (');
L.push('\t\t\t\t' + ID.APP_PROD + ' /* MHDPruvodce.app */,');
L.push('\t\t\t\t' + ID.TEST_PROD + ' /* MHDPruvodceTests.xctest */,');
L.push('\t\t\t);');
L.push('\t\t\tname = Products;');
L.push('\t\t\tsourceTree = ' + q('<group>') + ';');
L.push('\t\t};');

for (const fk of Object.keys(folderToGrp)) {
  const gid = folderToGrp[fk];
  const gname = grpNames[fk];
  L.push('\t\t' + gid + ' /* ' + gname + ' */ = {');
  L.push('\t\t\tisa = PBXGroup;');
  L.push('\t\t\tchildren = (');
  for (const f of (grpFiles[fk] || [])) {
    L.push('\t\t\t\t' + refs[f] + ' /* ' + path.basename(f) + ' */,');
  }
  L.push('\t\t\t);');
  L.push('\t\t\tpath = ' + q(gname) + ';');
  L.push('\t\t\tsourceTree = ' + q('<group>') + ';');
  L.push('\t\t};');
}

L.push('\t\t' + ID.GRP_VIEWS + ' /* Views */ = {');
L.push('\t\t\tisa = PBXGroup;');
L.push('\t\t\tchildren = (');
for (const [gid, gname] of [[ID.GRP_SRCH,'Search'],[ID.GRP_CONN,'Connections'],[ID.GRP_DET,'Detail'],[ID.GRP_TRK,'Tracking'],[ID.GRP_CMP,'Components']]) {
  L.push('\t\t\t\t' + gid + ' /* ' + gname + ' */,');
}
L.push('\t\t\t);');
L.push('\t\t\tpath = Views;');
L.push('\t\t\tsourceTree = ' + q('<group>') + ';');
L.push('\t\t};');

L.push('\t\t' + ID.GRP_RES + ' /* Resources */ = {');
L.push('\t\t\tisa = PBXGroup;');
L.push('\t\t\tchildren = (');
L.push('\t\t\t\t' + ID.ASSETS_REF + ' /* Assets.xcassets */,');
L.push('\t\t\t\t' + ID.LOCALE_REF + ' /* cs */,');
L.push('\t\t\t);');
L.push('\t\t\tpath = Resources;');
L.push('\t\t\tsourceTree = ' + q('<group>') + ';');
L.push('\t\t};');

L.push('\t\t' + ID.GRP_TEST + ' /* MHDPruvodceTests */ = {');
L.push('\t\t\tisa = PBXGroup;');
L.push('\t\t\tchildren = (');
for (const f of testSwift) L.push('\t\t\t\t' + refs[f] + ' /* ' + path.basename(f) + ' */,');
L.push('\t\t\t);');
L.push('\t\t\tpath = MHDPruvodceTests;');
L.push('\t\t\tsourceTree = ' + q('<group>') + ';');
L.push('\t\t};');

L.push('\t\t' + ID.GRP_APP + ' /* MHDPruvodce */ = {');
L.push('\t\t\tisa = PBXGroup;');
L.push('\t\t\tchildren = (');
for (const [gid, gname] of [
  [ID.GRP_APPF,'App'],[ID.GRP_CFG,'Config'],[ID.GRP_MDL,'Models'],
  [ID.GRP_NET,'Networking'],[ID.GRP_MGR,'Managers'],[ID.GRP_VM,'ViewModels'],
  [ID.GRP_VIEWS,'Views'],[ID.GRP_LIVE,'LiveActivity'],[ID.GRP_EXT,'Extensions'],
  [ID.GRP_RES,'Resources'],[ID.GRP_PRV,'Preview Content'],
]) {
  L.push('\t\t\t\t' + gid + ' /* ' + gname + ' */,');
}
L.push('\t\t\t\t' + ID.INFO_REF + ' /* Info.plist */,');
L.push('\t\t\t\t' + ID.ENTITLE_REF + ' /* MHDPruvodce.entitlements */,');
L.push('\t\t\t);');
L.push('\t\t\tpath = MHDPruvodce;');
L.push('\t\t\tsourceTree = ' + q('<group>') + ';');
L.push('\t\t};');

L.push('\t\t' + ID.ROOT_GRP + ' = {');
L.push('\t\t\tisa = PBXGroup;');
L.push('\t\t\tchildren = (');
L.push('\t\t\t\t' + ID.GRP_APP + ' /* MHDPruvodce */,');
L.push('\t\t\t\t' + ID.GRP_TEST + ' /* MHDPruvodceTests */,');
L.push('\t\t\t\t' + ID.PRODUCTS_GRP + ' /* Products */,');
L.push('\t\t\t);');
L.push('\t\t\tsourceTree = ' + q('<group>') + ';');
L.push('\t\t};');
L.push('/* End PBXGroup section */');
L.push('');

// Targets
L.push('/* Begin PBXNativeTarget section */');
L.push('\t\t' + ID.APP_TARGET + ' /* MHDPruvodce */ = {');
L.push('\t\t\tisa = PBXNativeTarget;');
L.push('\t\t\tbuildConfigurationList = ' + ID.APP_CONFLIST + ';');
L.push('\t\t\tbuildPhases = (');
L.push('\t\t\t\t' + ID.SRC_PHASE + ' /* Sources */,');
L.push('\t\t\t\t' + ID.RES_PHASE + ' /* Resources */,');
L.push('\t\t\t);');
L.push('\t\t\tbuildRules = ();');
L.push('\t\t\tdependencies = ();');
L.push('\t\t\tname = MHDPruvodce;');
L.push('\t\t\tproductName = MHDPruvodce;');
L.push('\t\t\tproductReference = ' + ID.APP_PROD + ' /* MHDPruvodce.app */;');
L.push('\t\t\tproductType = ' + q('com.apple.product-type.application') + ';');
L.push('\t\t};');
L.push('\t\t' + ID.TEST_TARGET + ' /* MHDPruvodceTests */ = {');
L.push('\t\t\tisa = PBXNativeTarget;');
L.push('\t\t\tbuildConfigurationList = ' + ID.TEST_CONFLIST + ';');
L.push('\t\t\tbuildPhases = (');
L.push('\t\t\t\t' + ID.TEST_SRC + ' /* Sources */,');
L.push('\t\t\t);');
L.push('\t\t\tbuildRules = ();');
L.push('\t\t\tdependencies = ();');
L.push('\t\t\tname = MHDPruvodceTests;');
L.push('\t\t\tproductName = MHDPruvodceTests;');
L.push('\t\t\tproductReference = ' + ID.TEST_PROD + ' /* MHDPruvodceTests.xctest */;');
L.push('\t\t\tproductType = ' + q('com.apple.product-type.bundle.unit-test') + ';');
L.push('\t\t};');
L.push('/* End PBXNativeTarget section */');
L.push('');

// PBXProject
L.push('/* Begin PBXProject section */');
L.push('\t\t' + ID.PROJECT + ' /* Project object */ = {');
L.push('\t\t\tisa = PBXProject;');
L.push('\t\t\tattributes = {');
L.push('\t\t\t\tBuildIndependentTargetsInParallel = 1;');
L.push('\t\t\t\tLastSwiftUpdateCheck = 1500;');
L.push('\t\t\t\tLastUpgradeCheck = 1500;');
L.push('\t\t\t\tTargetAttributes = {');
L.push('\t\t\t\t\t' + ID.APP_TARGET + ' = {');
L.push('\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;');
L.push('\t\t\t\t\t};');
L.push('\t\t\t\t\t' + ID.TEST_TARGET + ' = {');
L.push('\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;');
L.push('\t\t\t\t\t\tTestTargetID = ' + ID.APP_TARGET + ';');
L.push('\t\t\t\t\t};');
L.push('\t\t\t\t};');
L.push('\t\t\t};');
L.push('\t\t\tbuildConfigurationList = ' + ID.PROJ_CONFLIST + ';');
L.push('\t\t\tcompatibilityVersion = ' + q('Xcode 14.0') + ';');
L.push('\t\t\tdevelopmentRegion = cs;');
L.push('\t\t\thasScannedForEncodings = 0;');
L.push('\t\t\tknownRegions = (');
L.push('\t\t\t\ten,');
L.push('\t\t\t\tcs,');
L.push('\t\t\t\tBase,');
L.push('\t\t\t);');
L.push('\t\t\tmainGroup = ' + ID.ROOT_GRP + ';');
L.push('\t\t\tproductRefGroup = ' + ID.PRODUCTS_GRP + ' /* Products */;');
L.push('\t\t\tprojectDirPath = ' + q('') + ';');
L.push('\t\t\tprojectRoot = ' + q('') + ';');
L.push('\t\t\ttargets = (');
L.push('\t\t\t\t' + ID.APP_TARGET + ' /* MHDPruvodce */,');
L.push('\t\t\t\t' + ID.TEST_TARGET + ' /* MHDPruvodceTests */,');
L.push('\t\t\t);');
L.push('\t\t};');
L.push('/* End PBXProject section */');
L.push('');

// Resources phase
L.push('/* Begin PBXResourcesBuildPhase section */');
L.push('\t\t' + ID.RES_PHASE + ' /* Resources */ = {');
L.push('\t\t\tisa = PBXResourcesBuildPhase;');
L.push('\t\t\tbuildActionMask = 2147483647;');
L.push('\t\t\tfiles = (');
L.push('\t\t\t\t' + ID.ASSETS_BUILD + ' /* Assets.xcassets in Resources */,');
L.push('\t\t\t\t' + ID.LOCALE_BUILD + ' /* cs in Resources */,');
L.push('\t\t\t);');
L.push('\t\t\trunOnlyForDeploymentPostprocessing = 0;');
L.push('\t\t};');
L.push('/* End PBXResourcesBuildPhase section */');
L.push('');

// Sources phases
L.push('/* Begin PBXSourcesBuildPhase section */');
L.push('\t\t' + ID.SRC_PHASE + ' /* Sources */ = {');
L.push('\t\t\tisa = PBXSourcesBuildPhase;');
L.push('\t\t\tbuildActionMask = 2147483647;');
L.push('\t\t\tfiles = (');
for (const f of allApp) L.push('\t\t\t\t' + builds[f] + ' /* ' + path.basename(f) + ' in Sources */,');
L.push('\t\t\t);');
L.push('\t\t\trunOnlyForDeploymentPostprocessing = 0;');
L.push('\t\t};');
L.push('\t\t' + ID.TEST_SRC + ' /* Sources */ = {');
L.push('\t\t\tisa = PBXSourcesBuildPhase;');
L.push('\t\t\tbuildActionMask = 2147483647;');
L.push('\t\t\tfiles = (');
for (const f of testSwift) L.push('\t\t\t\t' + testBuilds[f] + ' /* ' + path.basename(f) + ' in Sources */,');
L.push('\t\t\t);');
L.push('\t\t\trunOnlyForDeploymentPostprocessing = 0;');
L.push('\t\t};');
L.push('/* End PBXSourcesBuildPhase section */');
L.push('');

// Build configurations
function emitCfg(id, name, settings) {
  L.push('\t\t' + id + ' /* ' + name + ' */ = {');
  L.push('\t\t\tisa = XCBuildConfiguration;');
  L.push('\t\t\tbuildSettings = {');
  for (const s of settings) L.push('\t\t\t\t' + s);
  L.push('\t\t\t};');
  L.push('\t\t\tname = ' + name + ';');
  L.push('\t\t};');
}

const projDebug = [
  'ALWAYS_SEARCH_USER_PATHS = NO;',
  'CLANG_ANALYZER_NONNULL = YES;',
  'CLANG_ENABLE_MODULES = YES;',
  'CLANG_ENABLE_OBJC_ARC = YES;',
  'CLANG_ENABLE_OBJC_WEAK = YES;',
  'COPY_PHASE_STRIP = NO;',
  'DEBUG_INFORMATION_FORMAT = dwarf;',
  'ENABLE_TESTABILITY = YES;',
  'GCC_C_LANGUAGE_STANDARD = gnu17;',
  'GCC_DYNAMIC_NO_PIC = NO;',
  'GCC_NO_COMMON_BLOCKS = YES;',
  'GCC_OPTIMIZATION_LEVEL = 0;',
  'GCC_PREPROCESSOR_DEFINITIONS = ( "DEBUG=1", "$(inherited)", );',
  'GCC_WARN_64_TO_32_BIT_CONVERSION = YES;',
  'GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;',
  'GCC_WARN_UNDECLARED_SELECTOR = YES;',
  'GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;',
  'GCC_WARN_UNUSED_FUNCTION = YES;',
  'GCC_WARN_UNUSED_VARIABLE = YES;',
  'IPHONEOS_DEPLOYMENT_TARGET = 17.0;',
  'MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;',
  'ONLY_ACTIVE_ARCH = YES;',
  'SDKROOT = iphoneos;',
  'SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;',
  'SWIFT_OPTIMIZATION_LEVEL = "-Onone";',
];
const projRelease = [
  'ALWAYS_SEARCH_USER_PATHS = NO;',
  'COPY_PHASE_STRIP = NO;',
  'DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";',
  'ENABLE_NS_ASSERTIONS = NO;',
  'GCC_C_LANGUAGE_STANDARD = gnu17;',
  'GCC_NO_COMMON_BLOCKS = YES;',
  'GCC_WARN_64_TO_32_BIT_CONVERSION = YES;',
  'GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;',
  'IPHONEOS_DEPLOYMENT_TARGET = 17.0;',
  'MTL_FAST_MATH = YES;',
  'SDKROOT = iphoneos;',
  'SWIFT_COMPILATION_MODE = wholemodule;',
  'SWIFT_OPTIMIZATION_LEVEL = "-O";',
  'VALIDATE_PRODUCT = YES;',
];
const appCfg = [
  'ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;',
  'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AppPrimary;',
  'CODE_SIGN_ENTITLEMENTS = MHDPruvodce/MHDPruvodce.entitlements;',
  'CODE_SIGN_STYLE = Automatic;',
  'CURRENT_PROJECT_VERSION = 1;',
  'DEVELOPMENT_ASSET_PATHS = "\\"MHDPruvodce/Preview Content\\"";',
  'DEVELOPMENT_TEAM = "";',
  'ENABLE_PREVIEWS = YES;',
  'GENERATE_INFOPLIST_FILE = NO;',
  'INFOPLIST_FILE = MHDPruvodce/Info.plist;',
  'IPHONEOS_DEPLOYMENT_TARGET = 17.0;',
  'LD_RUNPATH_SEARCH_PATHS = ( "$(inherited)", "@executable_path/Frameworks", );',
  'MARKETING_VERSION = 1.0;',
  'PRODUCT_BUNDLE_IDENTIFIER = cz.mhd.pruvodce;',
  'PRODUCT_NAME = MHDPruvodce;',
  'SWIFT_EMIT_LOC_STRINGS = YES;',
  'SWIFT_VERSION = 5.9;',
  'TARGETED_DEVICE_FAMILY = 1;',
];
const testCfg = [
  'BUNDLE_LOADER = "$(TEST_HOST)";',
  'CODE_SIGN_STYLE = Automatic;',
  'CURRENT_PROJECT_VERSION = 1;',
  'GENERATE_INFOPLIST_FILE = YES;',
  'IPHONEOS_DEPLOYMENT_TARGET = 17.0;',
  'MARKETING_VERSION = 1.0;',
  'PRODUCT_BUNDLE_IDENTIFIER = cz.mhd.pruvodce.tests;',
  'PRODUCT_NAME = MHDPruvodceTests;',
  'SWIFT_VERSION = 5.9;',
  'TARGETED_DEVICE_FAMILY = 1;',
  'TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MHDPruvodce.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/MHDPruvodce";',
];

L.push('/* Begin XCBuildConfiguration section */');
emitCfg(ID.DEBUG_PROJ,   'Debug',   projDebug);
emitCfg(ID.RELEASE_PROJ, 'Release', projRelease);
emitCfg(ID.DEBUG_APP,    'Debug',   appCfg);
emitCfg(ID.RELEASE_APP,  'Release', appCfg);
emitCfg(ID.DEBUG_TEST,   'Debug',   testCfg);
emitCfg(ID.RELEASE_TEST, 'Release', testCfg);
L.push('/* End XCBuildConfiguration section */');
L.push('');

// ConfigurationLists
function emitCL(id, dbg, rel) {
  L.push('\t\t' + id + ' = {');
  L.push('\t\t\tisa = XCConfigurationList;');
  L.push('\t\t\tbuildConfigurations = (');
  L.push('\t\t\t\t' + dbg + ' /* Debug */,');
  L.push('\t\t\t\t' + rel + ' /* Release */,');
  L.push('\t\t\t);');
  L.push('\t\t\tdefaultConfigurationIsVisible = 0;');
  L.push('\t\t\tdefaultConfigurationName = Release;');
  L.push('\t\t};');
}
L.push('/* Begin XCConfigurationList section */');
emitCL(ID.PROJ_CONFLIST, ID.DEBUG_PROJ,  ID.RELEASE_PROJ);
emitCL(ID.APP_CONFLIST,  ID.DEBUG_APP,   ID.RELEASE_APP);
emitCL(ID.TEST_CONFLIST, ID.DEBUG_TEST,  ID.RELEASE_TEST);
L.push('/* End XCConfigurationList section */');

L.push('\t};');
L.push('\trootObject = ' + ID.PROJECT + ' /* Project object */;');
L.push('}');

const content = L.join('\n') + '\n';
fs.writeFileSync('MHDPruvodce.xcodeproj/project.pbxproj', content, {encoding: 'utf8'});
console.log('OK lines=' + L.length + ' app=' + allApp.length + ' tests=' + testSwift.length);
