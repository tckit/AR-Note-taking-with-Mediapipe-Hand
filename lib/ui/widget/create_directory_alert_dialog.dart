import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../strings/strings.dart';
import '../../viewModel/storage_view_model.dart';

class CreateDirectoryAlertDialog extends StatelessWidget {
  const CreateDirectoryAlertDialog({
    super.key,
    required this.showSnackBar,
    required this.closeFloatingActionMenu,
  });

  final Function(BuildContext, String) showSnackBar;
  final Function(BuildContext) closeFloatingActionMenu;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => _createDirectoryAlertDialog(context),//createDirectory(context),
        child: const Text("Create new folder"));
  }

  Future<void> _createDirectoryAlertDialog(BuildContext context) async {
    bool isError = false;
    final textController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(AppStrings.createFolderTitle),
        content: TextField(
          controller: textController,
          // onChanged: (_) => isError = true,
          decoration: InputDecoration(
            labelText: "Enter folder name",
            // Does not actually work dynamically
            errorText: isError ? "Folder already exists!" : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                closeFloatingActionMenu(context);
                Navigator.pop(context);
              },
              child: const Text(AppStrings.cancel)),
          TextButton(
              onPressed: () async {
                bool success =
                    await createDirectory(context, textController.text);

                if (context.mounted) {
                  if (success) {
                    showSnackBar(context, "Created directory ${textController.text}");
                  } else {
                    showSnackBar(context, "An error has occurred when creating directory");
                    debugPrint("Failed to create directory from alert dialog");
                  }
                  closeFloatingActionMenu(context);
                  Navigator.pop(context);
                }
              },
              child: const Text(AppStrings.createFolder)),
        ],
      ),
    );
  }

  /// Failure: false, Success: true
  Future<bool> createDirectory(BuildContext context, String directoryName) async {
    if (directoryName.isEmpty) return false;

    final viewModel = context.read<StorageViewModel>();
    var path = p.join(viewModel.currentDirectoryPath, directoryName);
    bool success = await viewModel.createDirectory(path);
    return success;
  }
}
