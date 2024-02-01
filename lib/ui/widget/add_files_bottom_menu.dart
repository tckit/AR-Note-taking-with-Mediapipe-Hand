import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/page_selector_provider.dart';
import '../../viewModel/storage_view_model.dart';
import 'create_directory_alert_dialog.dart';

class AddFilesBottomMenu extends StatelessWidget {
  const AddFilesBottomMenu({
    super.key,
    required this.showSnackBar,
    required this.closeFloatingActionMenu,
  });

  final Function(BuildContext, String) showSnackBar;
  final Function(BuildContext) closeFloatingActionMenu;

  @override
  Widget build(BuildContext context) {
    return _buildAddFilesBottomMenu(context);
  }

  /// Display text for importing/adding files/folders
  Widget _buildAddFilesBottomMenu(BuildContext context) {
    return Consumer<PageSelectorProvider>(
      builder: (_, provider, child) {
        if (provider.clickedAddActionButton) {
          return Container(
            child: child,
          );
        }
        return const SizedBox.shrink();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: CreateDirectoryAlertDialog(
                showSnackBar: showSnackBar,
                closeFloatingActionMenu: closeFloatingActionMenu,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextButton(
                  onPressed: () {
                    // Create file in image format
                    // final viewModel = context.read<StorageViewModel>();
                    // viewModel.createFile();
                    // _getBlankImage(context);
                    createBlankImage(context);
                    closeFloatingActionMenu(context);
                  },
                  child: const Text("Create new files")),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextButton(
                onPressed: () => importFiles(context),
                child: const Text("Import files"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createBlankImage(BuildContext context) async {
    context.read<StorageViewModel>().createBlankImage();
  }

  void importFiles(BuildContext context) async {
    final viewModel = context.read<StorageViewModel>();
    var file = await viewModel.importFile();
    if (file != null && context.mounted) {
      closeFloatingActionMenu(context);

      showSnackBar(context, "Imported ${file.fileName} successfully");
    }
  }
}
