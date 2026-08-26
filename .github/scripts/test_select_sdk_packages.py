import unittest

from select_sdk_packages import explorer_for_changes, sdk_packages_for_changes

PACKAGES = [
    "local_storage",
    "needle",
    "networking",
    "thawani",
    "thawani_models",
    "thawani_ui",
]


class SdkPackagesForChangesTest(unittest.TestCase):
    def test_selects_only_touched_sdk_packages(self) -> None:
        changed = [
            "sdk/needle/lib/needle.dart",
            "sdk/thawani/lib/thawani.dart",
            "docs/roadmap.md",
        ]
        self.assertEqual(
            sdk_packages_for_changes(PACKAGES, changed),
            ["needle", "thawani"],
        )

    def test_ignores_explorer_and_docs(self) -> None:
        changed = [
            "apps/explorer/lib/app.dart",
            "README.md",
        ]
        self.assertEqual(sdk_packages_for_changes(PACKAGES, changed), [])


class ExplorerForChangesTest(unittest.TestCase):
    def test_run_all_selects_explorer(self) -> None:
        self.assertTrue(explorer_for_changes(True, []))

    def test_explorer_path_selects_explorer(self) -> None:
        self.assertTrue(
            explorer_for_changes(False, ["apps/explorer/lib/app.dart"]),
        )

    def test_sdk_only_skips_explorer(self) -> None:
        self.assertFalse(
            explorer_for_changes(False, ["sdk/needle/lib/needle.dart"]),
        )

    def test_docs_only_skips_explorer(self) -> None:
        self.assertFalse(explorer_for_changes(False, ["README.md", "docs/roadmap.md"]))


if __name__ == "__main__":
    unittest.main()
