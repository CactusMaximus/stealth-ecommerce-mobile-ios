#!/usr/bin/swift

import Foundation

// Function to add FirebaseAnalytics to the project.pbxproj file
func addFirebaseAnalytics() {
    let projectFilePath = "StealthEcommerce.xcodeproj/project.pbxproj"
    
    guard let projectFileContents = try? String(contentsOfFile: projectFilePath) else {
        print("❌ Failed to read project file")
        return
    }
    
    // Check if FirebaseAnalytics is already included
    if projectFileContents.contains("FirebaseAnalytics") {
        print("✅ FirebaseAnalytics is already included in the project")
        return
    }
    
    // Find the section where Firebase dependencies are declared
    let packageDependenciesPattern = "packageProductDependencies = \\([\\s\\S]*?\\);"
    let packageDependenciesRegex = try! NSRegularExpression(pattern: packageDependenciesPattern)
    
    guard let match = packageDependenciesRegex.firstMatch(in: projectFileContents, range: NSRange(projectFileContents.startIndex..., in: projectFileContents)) else {
        print("❌ Could not find package dependencies section")
        return
    }
    
    let matchRange = Range(match.range, in: projectFileContents)!
    let packageDependenciesSection = String(projectFileContents[matchRange])
    
    // Add FirebaseAnalytics dependency
    let updatedSection = packageDependenciesSection.replacingOccurrences(
        of: ");",
        with: ",\n\t\t\t\t0D9EED4F2E2434630018E077 /* FirebaseAnalytics */\n\t\t\t);"
    )
    
    // Replace the section in the project file
    var updatedProjectFile = projectFileContents.replacingOccurrences(
        of: packageDependenciesSection,
        with: updatedSection
    )
    
    // Now add the FirebaseAnalytics reference
    let frameworksBuildPhasePattern = "isa = PBXFrameworksBuildPhase;[\\s\\S]*?files = \\([\\s\\S]*?\\);"
    let frameworksBuildPhaseRegex = try! NSRegularExpression(pattern: frameworksBuildPhasePattern)
    
    guard let frameworksMatch = frameworksBuildPhaseRegex.firstMatch(in: updatedProjectFile, range: NSRange(updatedProjectFile.startIndex..., in: updatedProjectFile)) else {
        print("❌ Could not find frameworks build phase section")
        return
    }
    
    let frameworksMatchRange = Range(frameworksMatch.range, in: updatedProjectFile)!
    let frameworksSection = String(updatedProjectFile[frameworksMatchRange])
    
    // Add FirebaseAnalytics framework reference
    let updatedFrameworksSection = frameworksSection.replacingOccurrences(
        of: ");",
        with: ",\n\t\t\t\t0D9EED502E2434630018E078 /* FirebaseAnalytics in Frameworks */\n\t\t\t);"
    )
    
    // Replace the section in the project file
    updatedProjectFile = updatedProjectFile.replacingOccurrences(
        of: frameworksSection,
        with: updatedFrameworksSection
    )
    
    // Add the PBXBuildFile reference for FirebaseAnalytics
    let buildFilePattern = "/\\* Begin PBXBuildFile section \\*/[\\s\\S]*?/\\* End PBXBuildFile section \\*/"
    let buildFileRegex = try! NSRegularExpression(pattern: buildFilePattern)
    
    guard let buildFileMatch = buildFileRegex.firstMatch(in: updatedProjectFile, range: NSRange(updatedProjectFile.startIndex..., in: updatedProjectFile)) else {
        print("❌ Could not find PBXBuildFile section")
        return
    }
    
    let buildFileMatchRange = Range(buildFileMatch.range, in: updatedProjectFile)!
    let buildFileSection = String(updatedProjectFile[buildFileMatchRange])
    
    // Add FirebaseAnalytics build file reference
    let updatedBuildFileSection = buildFileSection.replacingOccurrences(
        of: "/* End PBXBuildFile section */",
        with: "\t\t0D9EED502E2434630018E078 /* FirebaseAnalytics in Frameworks */ = {isa = PBXBuildFile; productRef = 0D9EED4F2E2434630018E077 /* FirebaseAnalytics */; };\n/* End PBXBuildFile section */"
    )
    
    // Replace the section in the project file
    updatedProjectFile = updatedProjectFile.replacingOccurrences(
        of: buildFileSection,
        with: updatedBuildFileSection
    )
    
    // Write the updated content back to the project file
    do {
        try updatedProjectFile.write(toFile: projectFilePath, atomically: true, encoding: .utf8)
        print("✅ Successfully added FirebaseAnalytics to the project")
    } catch {
        print("❌ Failed to write to project file: \(error)")
    }
}

// Run the function
addFirebaseAnalytics() 