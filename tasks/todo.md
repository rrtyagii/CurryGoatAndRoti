# Task: Fix "Content not found" in topic detail flow

## Plan
- [x] Inspect current loading flow in `Infomatic/HomeScreen.swift`, `Infomatic/Utility/TopicLoader.swift`, and `Infomatic/Components/Topic Detail/TopicDetailView.swift`
- [x] Verify resources exist at `Infomatic/Resources/topic_index.json` and `Infomatic/Resources/topics/*`
- [x] Patch loader to handle bundle path variations (`topics/<file>.txt` and flattened `<file>.txt`)
- [x] Add minimal diagnostics so missing files print exact attempted paths
- [x] Validate by static checks and targeted file-level review

## Review
- Root cause confirmed from built app bundle: topic files are copied to bundle root (flattened), while JSON stores paths as `topics/<name>.txt`.
- `loadIndex` works because `topic_index.json` is at root and is being found.
- Fixed only `loadTopicContent` in `Infomatic/Utility/TopicLoader.swift`.
- Attempted build validation with `xcodebuild`, but sandbox restrictions blocked simulator/cache access in this environment.
