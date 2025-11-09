import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';
import '../screens/auth_gate.dart';
import '../main.dart';

const String _defaultCoverImage = 'lib/assets/Ps.webp';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final firestoreService = ref.watch(firestoreServiceProvider);
    final myBooksStream = firestoreService.getBooksByOwner(user.uid);
    final incomingOffersStream = firestoreService.getIncomingSwapOffers();

    return Scaffold(
      backgroundColor: MyApp.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          "My Listings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: 'My Books'),
            Tab(icon: Icon(Icons.swap_horiz), text: 'My Offers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Books Tab
          StreamBuilder<List<Book>>(
            stream: myBooksStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final books = snapshot.data ?? [];

              if (books.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No books listed yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first book!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Book Cover
                              Container(
                                width: 80,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: book.coverImageUrl.isNotEmpty
                                      ? Image.network(
                                          book.coverImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Image.asset(
                                                  _defaultCoverImage,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                        )
                                      : Image.asset(
                                          _defaultCoverImage,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Book Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            book.author,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getConditionColor(
                                              book.condition,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: _getConditionColor(
                                                book.condition,
                                              ).withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            book.condition,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _getConditionColor(
                                                book.condition,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              book.swapStatus,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: _getStatusColor(
                                                book.swapStatus,
                                              ).withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            book.swapStatus,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _getStatusColor(
                                                book.swapStatus,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Menu Button
                              PopupMenuButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.grey[600],
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: Colors.grey[700],
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red[400],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.red[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditBookDialog(context, book);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmation(context, book);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // My Offers Tab
          StreamBuilder<List<SwapOffer>>(
            stream: incomingOffersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final offers = snapshot.data ?? [];

              if (offers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No swap offers yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'ll see swap offers here when others\nrequest your books!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: ListTile(
                      leading: offer.bookCoverImageUrl.isNotEmpty
                          ? Image.network(
                              offer.bookCoverImageUrl,
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  _defaultCoverImage,
                                  width: 60,
                                  height: 80,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              _defaultCoverImage,
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                      title: Text(
                        offer.bookTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From: ${offer.fromUserEmail}'),
                          Text(
                            'Status: ${offer.status}',
                            style: TextStyle(
                              color: _getStatusColor(offer.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: offer.status == 'Pending'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  onPressed: () => _handleSwapOffer(
                                    context,
                                    offer.id,
                                    'Accepted',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _handleSwapOffer(
                                    context,
                                    offer.id,
                                    'Rejected',
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              offer.status,
                              style: TextStyle(
                                color: _getStatusColor(offer.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBookDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
        elevation: 4,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'New':
        return Colors.green;
      case 'Like New':
        return Colors.lightGreen;
      case 'Good':
        return Colors.blue;
      case 'Used':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showAddBookDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    String selectedCondition = 'Used';
    File? selectedImage;
    Uint8List? selectedImageBytes;
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Book'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCondition,
                  decoration: const InputDecoration(labelText: 'Condition'),
                  items: ['New', 'Like New', 'Good', 'Used']
                      .map(
                        (condition) => DropdownMenuItem(
                          value: condition,
                          child: Text(condition),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedCondition = value ?? 'Used');
                  },
                ),
                const SizedBox(height: 16),
                if (kIsWeb && selectedImageBytes != null)
                  Image.memory(
                    selectedImageBytes!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                if (!kIsWeb && selectedImage != null)
                  Image.file(selectedImage!, height: 150, fit: BoxFit.cover),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty ||
                              authorController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                              ),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            final firestoreService = ref.read(
                              firestoreServiceProvider,
                            );
                            final storageService = ref.read(
                              storageServiceProvider,
                            );

                            String imageUrl = '';
                            if (selectedImage != null ||
                                selectedImageBytes != null) {
                              if (kIsWeb && selectedImageBytes != null) {
                                imageUrl = await storageService
                                    .uploadBookCoverFromBytes(
                                      selectedImageBytes!,
                                    );
                              } else if (!kIsWeb && selectedImage != null) {
                                imageUrl = await storageService.uploadBookCover(
                                  selectedImage!,
                                );
                              }
                            }

                            await firestoreService.createBook(
                              title: titleController.text.trim(),
                              author: authorController.text.trim(),
                              condition: selectedCondition,
                              coverImageUrl: imageUrl,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Book added successfully!'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple, // <-- Set purple color here
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white, // keep spinner white
                          ),
                        )
                      : const Text('Add'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditBookDialog(BuildContext context, Book book) async {
    final titleController = TextEditingController(text: book.title);
    final authorController = TextEditingController(text: book.author);
    String selectedCondition = book.condition;
    File? selectedImage;
    Uint8List? selectedImageBytes;
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Book'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCondition,
                  decoration: const InputDecoration(labelText: 'Condition'),
                  items: ['New', 'Like New', 'Good', 'Used']
                      .map(
                        (condition) => DropdownMenuItem(
                          value: condition,
                          child: Text(condition),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedCondition = value ?? 'Used');
                  },
                ),
                const SizedBox(height: 16),
                if (book.coverImageUrl.isNotEmpty &&
                    selectedImage == null &&
                    selectedImageBytes == null)
                  Image.network(
                    book.coverImageUrl,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                if (kIsWeb && selectedImageBytes != null)
                  Image.memory(
                    selectedImageBytes!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                if (!kIsWeb && selectedImage != null)
                  Image.file(selectedImage!, height: 150, fit: BoxFit.cover),
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            if (kIsWeb) {
                              final bytes = await image.readAsBytes();
                              setState(() {
                                selectedImageBytes = bytes;
                                selectedImage = null;
                              });
                            } else {
                              setState(() {
                                selectedImage = File(image.path);
                                selectedImageBytes = null;
                              });
                            }
                          }
                        },
                  icon: const Icon(Icons.image),
                  label: const Text('Change Cover Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (titleController.text.trim().isEmpty ||
                          authorController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        final firestoreService = ref.read(
                          firestoreServiceProvider,
                        );
                        final storageService = ref.read(storageServiceProvider);

                        String? imageUrl;
                        if (selectedImage != null ||
                            selectedImageBytes != null) {
                          if (kIsWeb && selectedImageBytes != null) {
                            imageUrl = await storageService
                                .uploadBookCoverFromBytes(selectedImageBytes!);
                          } else if (!kIsWeb && selectedImage != null) {
                            imageUrl = await storageService.uploadBookCover(
                              selectedImage!,
                            );
                          }
                        }

                        await firestoreService.updateBook(
                          bookId: book.id,
                          title: titleController.text.trim(),
                          author: authorController.text.trim(),
                          condition: selectedCondition,
                          coverImageUrl: imageUrl,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Book updated successfully!'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.deleteBook(book.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book deleted successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _handleSwapOffer(
    BuildContext context,
    String offerId,
    String status,
  ) async {
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateSwapOfferStatus(offerId, status);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Swap offer $status')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
