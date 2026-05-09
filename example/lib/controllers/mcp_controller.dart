import '../app.dart';
import '../db/mysql/mysql_books.dart';
import 'package:finch/finch_model_less.dart';
import 'package:finch/mcp.dart';

class McpServerBooksController extends McpServerController {
  final bookSchema = {
    'title': Schema(
      type: 'string',
      description: 'The title of the book',
      defaultValue: 'Unknown Title',
      title: 'Title',
    ),
    'author': Schema(
      type: 'string',
      description: 'The author of the book',
      defaultValue: 'Unknown Author',
      title: 'Author',
    ),
    'published_year': Schema(
      type: 'string',
      description: 'The year the book was published',
      defaultValue: '2026-01-01',
      title: 'Published Year',
    ),
    'id': Schema(
      type: 'integer',
      description: 'The unique identifier of the book',
      defaultValue: 0,
      title: 'ID',
    ),
  };

  MysqlBooks mysqlBooks = MysqlBooks(app.mysqlDriver);

  @override
  void configure(McpBuilder mcp) {
    // Register tools:
    mcp.tool(
      name: 'get_all_books',
      description: 'Retrieves all books from the database',
      handler: _getAllBooks,
      inputSchema: ToolSchema(
        type: 'object',
        properties: {
          'limit': Schema(
            type: 'integer',
            description: 'Maximum number of books to retrieve',
            defaultValue: 10,
            title: 'Limit',
          ),
        },
        required: ['limit'],
      ),
      outputSchema: ToolSchema(
        type: 'object',
        properties: {
          'books': ToolSchema(
            type: 'array',
            properties: bookSchema,
          ),
        },
        required: ['books'],
      ),
    );

    // Delete books tool example:
    mcp.tool(
      name: 'delete_book',
      handler: _deleteBook,
      description: 'Deletes a book by its ID',
      inputSchema: ToolSchema(
        type: 'object',
        properties: {
          'id': Schema(
            type: 'string',
            description: 'The ID of the book to delete',
            defaultValue: '',
            title: 'Book ID',
          ),
        },
        required: ['id'],
      ),
    );

    // Insert new book tool example:
    mcp.tool(
      name: 'insert_new_book',
      handler: _insertNewBook,
      description: 'Inserts a new book into the database',
      inputSchema: ToolSchema(
        type: 'object',
        properties: bookSchema..remove('id'),
        required: ['title', 'author', 'published_year'],
      ),
      outputSchema: ToolSchema(
        type: 'object',
        properties: {
          'id': Schema(
            type: 'string',
            description: 'The ID of the newly inserted book',
            defaultValue: '',
            title: 'Book ID',
          ),
        },
        required: ['id'],
      ),
    );
  }

  Future<CallToolResult> _insertNewBook(CallToolRequest request) async {
    var title = request.params.arguments!['title'].asString(def: '');
    var author = request.params.arguments!['author'].asString(def: '');
    var publishedYear =
        request.params.arguments!['published_year'].asString(def: '2026');

    var result = await mysqlBooks.addNewBook(
      title: title,
      author: author,
      publishedDate: publishedYear,
    );

    if (result.error) {
      throw Exception('Failed to insert new book: ${result.errorMsg}');
    }

    return CallToolResult(
      content: [],
      structuredContent: {
        'id': result.insertId.toString(),
      },
    );
  }

  Future<CallToolResult> _deleteBook(CallToolRequest request) async {
    var bookId = request.params.arguments!['id'].asString(def: '-1');
    var success = await mysqlBooks.deleteBook(bookId);

    if (!success) {
      throw Exception('Failed to delete book with id: $bookId');
    }

    return CallToolResult(
      content: [
        TextContent(
          text: 'Book deleted successfully',
          mimeType: 'text/plain',
        ),
      ],
    );
  }

  Future<CallToolResult> _getAllBooks(CallToolRequest request) async {
    int limit = request.params.arguments!['limit'].asInt(def: 10);

    var books = await mysqlBooks.getAllBooks('id', 'asc', limit: limit);

    List<Map<String, Object?>> structableContent = books.rows.assoc
        .map((book) => {
              ...book,
            })
        .toList();

    return CallToolResult(content: [], structuredContent: {
      'books': structableContent,
    });
  }
}
