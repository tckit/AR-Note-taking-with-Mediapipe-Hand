import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/viewModel/storage_view_model.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import '../data/Document.dart';

class FolderTreePage extends StatefulWidget {
  @override
  State<FolderTreePage> createState() => _FolderTreePageState();
}

class _FolderTreePageState extends State<FolderTreePage> {
  Map<int, bool> isSelected = {};

  Widget build(BuildContext context) {
    StorageViewModel viewModel = context.watch<StorageViewModel>();
    return Scaffold(
        appBar: _buildBackArrow(), body: _buildFolderTree(viewModel));
  }

  PreferredSizeWidget _buildBackArrow() {
    return AppBar(
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.chevron_left_sharp),
      )
    );
  }

  /// If directory, display expandable tile.
  /// If file, display clickable tile.
  /// Once directory is expanded, loop through the foremost process
  ///
  /// By default, Documents Directory will be used as parameter documents
  /// documents parameter represents the root document
  ListView _buildFolderTree(StorageViewModel viewModel,
      [List<Document>? documents]) {
    documents ??= viewModel.getUserDocuments;

    return ListView.builder(
        itemCount: documents.length,
        shrinkWrap: true,
        itemBuilder: (_, int index) {
          // initialize isSelected with false
          isSelected[index] = isSelected[index] ?? false;
          String currentFilePath = documents![index].path;
          bool isDirectory = viewModel.isDirectory(currentFilePath);

          viewModel.getListOfFiles();
          if (isDirectory) {
            List<Document> newDocuments =
                viewModel.loadFilesFromSync(currentFilePath);
            return ExpansionTile(
              title: Row(
                children: [
                  const Icon(Icons.folder),
                  const SizedBox(width: 10),
                  // fileName
                  Text(p.basename(currentFilePath))
                ],
              ),
              controlAffinity: ListTileControlAffinity.leading,
              // trailing: _buildSelectionBox(isSelected[index]!),
              // onExpansionChanged: (_) => onTapFile(index),
              children: [_buildFolderTree(viewModel, newDocuments)],
            );
          } else {
            return _buildFolderTile(
                index, viewModel, documents, currentFilePath);
          }
        });
  }

  Widget _buildFolderTile(int index, StorageViewModel viewModel,
      List<Document> documents, String currentFilePath) {
    return ListTile(
      // onLongPress: () => onLongPressFile(index),
      onTap: () {
        null;//(selectionMode) ? onTapFile(index) : connector?.callKotlin;
      },
      leading: const Icon(Icons.chevron_right),
      title: Row(
        children: [
          const Icon(Icons.image),
          const SizedBox(width: 10),
          // fileName
          documents.isEmpty ? Text("Desc") : Text(p.basename(currentFilePath)),
        ],
      ),
      // trailing: _buildSelectionBox(isSelected[index]!),
    );
  }
}