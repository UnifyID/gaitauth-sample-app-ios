//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

/// Provide additional getters for common Info.plist fields.
///
/// The descriptions come from the
/// [Apple Documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/).
internal extension Bundle {
    /// A user-visible short name for the bundle.
    var bundleName: String? { self.infoDictionary?["CFBundleName"] as? String }

    /// The user-visible name for the bundle, used by Siri and visible on the iOS Home screen.
    var bundleDisplayName: String? { self.infoDictionary?["CFBundleDisplayName"] as? String }

    /// The release or version number of the bundle.
    /// This is what Xcode calls the "Marketing Version".
    var bundleShortVersion: String? { self.infoDictionary?["CFBundleShortVersionString"] as? String }

    /// The version of the build that identifies an iteration of the bundle.
    /// This should be a numeric build number.
    var bundleVersion: String? { self.infoDictionary?[kCFBundleVersionKey as String] as? String }

    /// A unique identifier for a bundle.
    var bundleIdentifier: String? { self.infoDictionary?[kCFBundleIdentifierKey as String] as? String }

    /// The name of the bundle’s executable file.
    var bundleExecutable: String? { self.infoDictionary?[kCFBundleExecutableKey as String] as? String }

    /// Combine the short version and build version to make a friendly version string.
    ///
    /// Note: A single plus "+" sign is used to separate the version and build. This
    /// is intended to format versions compatible with `semver2.0`.
    var version: String? {
        guard let shortVersion = bundleShortVersion else { return nil }
        guard let buildVersion = bundleVersion else { return shortVersion }
        return "\(shortVersion)+\(buildVersion)"
    }

    /// The friendly name of the bundle. Defaults to the bundle identifier if the name is not set.
    var name: String? { bundleDisplayName ?? bundleName ?? bundleExecutable ?? bundleIdentifier }
}
