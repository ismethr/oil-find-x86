import Darwin

/// Keeps cloud placeholders (OneDrive, iCloud Drive, other File Provider storage) in the cloud.
/// The process refuses to materialize dataless files; only directory-reading threads opt in,
/// which fetches a folder's name listing from the provider while every file stays dataless.
public enum CloudPolicy {
    /// Call once at launch: any read of a dataless file then fails with EDEADLK instead of downloading it.
    public static func forbidDownloads() {
        _ = setiopolicy_np(IOPOL_TYPE_VFS_MATERIALIZE_DATALESS_FILES, IOPOL_SCOPE_PROCESS, IOPOL_MATERIALIZE_DATALESS_FILES_OFF)
    }
    /// Lets the current thread list dataless directories while `body` runs. Callers must only read
    /// directory entries and their attributes inside `body`, never file contents.
    static func listingCloudDirectories<T>(_ body: () throws -> T) rethrows -> T {
        _ = setiopolicy_np(IOPOL_TYPE_VFS_MATERIALIZE_DATALESS_FILES, IOPOL_SCOPE_THREAD, IOPOL_MATERIALIZE_DATALESS_FILES_ON)
        defer { _ = setiopolicy_np(IOPOL_TYPE_VFS_MATERIALIZE_DATALESS_FILES, IOPOL_SCOPE_THREAD, IOPOL_MATERIALIZE_DATALESS_FILES_DEFAULT) }
        return try body()
    }
}
