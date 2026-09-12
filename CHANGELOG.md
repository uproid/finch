
## 1.6.1
- Fixed [#88](https://github.com/uproid/finch/issues/88): unique field validation now reads the count from the query result via `res.assoc.first` instead of `res.rows.first.assoc()`
- `FinchApp._runCommands()` is now public as `runCommands()`, with a new `direct` parameter to process commands once instead of opening the interactive prompt

## 1.6.0
- Refactored the database connection process: added a unified `DBManager` (`FinchApp.db`) that connects/closes MongoDB, MySQL and SQLite together
  - `mongoDb`, `mysqlDriver` and `sqliteDriver` are now backed by dedicated `DBConnection` classes (`MongodbConn`, `MySqlConn`, `SqliteConn`) instead of ad-hoc fields on `FinchApp`
  - MongoDB and MySQL now connect through connection pools (`Db.pool`, `MySQLConnectionPool`), configurable via a new `maxConnections` option on `FinchDBConfig`/`FinchMysqlConfig`
  - MySQL migrations now run inside a real transactional session (`MySQLConnectionPool.transactional`)
- Added `FinchApp.onError()` to register a callback that is invoked whenever an error is logged through `Console`
- Removed several third-party dependencies in favor of small native implementations:
  - Removed `dotenv`; added a native `EnvReader`/`EnvParser` (`.env` parsing, quotes, `$VAR`/`${VAR}` interpolation, comments)
  - Removed `http`; added `FinchHttp` (`FinchHttp.get()`/`FinchHttp.post()`), exported from `finch/tools.dart`
  - Removed `cron`; `FinchCron` now uses its own built-in `CronSchedule` parser/matcher (supports both 5-field and 6-field cron expressions)
  - Removed `logger`; `Console`/`Print` now log through a native, colorized `Log` class
  - Removed `crypto`; `toMd5()` now uses `pointycastle`
- Developed a **Terminal** panel in the debugger console: `finch serve` opens a WebSocket server (`--terminalPort`, default `8282`) that streams the running app's stdout/stderr and lets you send commands back, viewable from the browser debugger
- Added **Dart DevTools** panel to the debugger console, embedded directly in the browser UI
  - `--enable-vm-service` now binds to `0.0.0.0:8181` (instead of localhost) so DevTools is reachable from inside Docker
  - `docker-compose.yaml` now exposes port `8282` for the terminal
- Added `--json`/`-j` option to the `routes` CLI command to print the routes list as JSON
- Fixed language detection order in `Request.language` (URL segment, then API `lang` param, then cookie/session), and validated the result against `config.languages`
- Updated dependencies: `html` to `^0.15.7`, `mime` to `^2.1.0`, `archive` to `^4.2.0`, `capp` to `^2.2.0`, `sqlite3` to `^3.5.2`, `yaml` to `^3.1.4`, `mcp_models` to `2.1.0`

## 1.5.2
- Removed the `Request rq` parameter from `FinchApp.addRouting()` callbacks; request data remains available through `Context.rq` inside route handlers
- Improved route URL generation and method checks by passing request-specific values explicitly
- Fix issue [#80](https://github.com/uproid/finch/issues/80): Support the Previous MCP Protocol Version with an Extended Deprecation Period

## 1.5.1
- Upgraded MCP support to MCP 2.0 (`mcp_models: 2.0.0`): replaced `initialize`/`notifications/initialized` handling with the new `server/discover` method and `DiscoverResult` response
- Added `make:migration` command to create SQL or Dart migration files from the CLI
  - `finch make:migration --name create_users_table`
  - `finch make:migration --name create_users_table --sqlite`
- Removed the `--create` option from `migrate`/`migrate_sqlite`; use `make:migration` instead
- Improved the Finch CLI runtime console with command history, arrow-key navigation and line editing (press `h` to view history)
- Fixed public file serving to reject requests resolving outside the public directory
- Removed the `cryptography` package dependency
- Updated dependencies: `capp` to `^2.1.0`, `mcp_models` to `2.0.0`
- Added a new real-time "Meeting Room" example (WebSocket-based)

## 1.5.0
- [#75](https://github.com/uproid/finch/issues/75) Added Dart-based migrations as an alternative to SQL migration files
  - New `DartMigration` abstract class (`up()`/`down()` build SQL via `addSql()`) with a `target` of `MigrationTarget.mysql` or `MigrationTarget.sqlite`
  - Register migrations with `app.registerDartMigration([...])`; migration names must be unique
  - `migrate --init`, `--rollback` and `--list` now run registered Dart migrations alongside (or instead of) file-based migrations
- [#69](https://github.com/uproid/finch/issues/69) Migrations now run inside a database transaction, rolling back automatically if any statement fails
  - Multi-statement migrations are executed as separate statements via a new SQL statement splitter
- [#74](https://github.com/uproid/finch/issues/74) Removed deprecated dependencies and updated others to their latest versions
  - Replaced `mysql_client` with `mysql_client_plus`
  - Replaced `encrypt` with `cryptography`/`pointycastle` for `toSafe()`/`fromSafe()` AES encryption
  - Upgraded `mongo_dart`, `mailer`, `jinja`, `intl`, `build_runner`, `test` and `sqlite3`
- update to `capp^2.0.0` to support for chained command execution [#3](https://github.com/uproid/capp/issues/3)

## 1.4.4
- [#70](https://github.com/uproid/finch/issues/70) Fixed `FormatException: Unexpected extension byte` when request URLs contain malformed percent-encoded sequences (e.g. `/%AF/test`)
  - Added `safePathSegments` extension on `Uri` and `safeDecodeUriComponent()` helper for crash-safe decoding of path segments (invalid UTF-8 bytes are replaced with `�` instead of throwing)
  - Used safe decoding in route matching, language detection, redirects and public file serving

## 1.4.3
- Fixed a WebSocket bug in `SocketManager.requestHandle`
- Fixed ApiDoc to correctly display `:param` style route parameters by converting them to `{param}` format in the OpenAPI/Swagger output

## 1.4.2
- Added errorWidget to the web app config to enable better customization of error pages. [#66](https://github.com/uproid/finch/issues/66)

## 1.4.1
- Update dependencies (Sqler 1.2.1), to fix bugs of sqlite queries

## 1.4.0
- Added new commands to make `controller`, `middlware` and `services`
  - `finch make:controller --name test`
  - `finch make:service --name test`
  - `finch make:middleware --name test`
- Upgrade dependencies
- Update documents
- added new app tamlates: `finch templates`

## 1.3.3
- Updated documentation to reflect the new `:param` syntax support in routing [#63](https://github.com/uproid/finch/issues/63)
- Added comprehensive tests for both classic `{param}` and new `:param` parameter styles

## 1.3.2
- [#58](https://github.com/uproid/finch/issues/58) Fixes #58: Resolved issues in the migrate -i and migrate -r processes. The migration process will now stop if a MySQL error occurs.
- fixing issue for examples

## 1.3.1
- [#54](https://github.com/uproid/finch/issues/54) Fixed a bug in the route caching functionality where responses were not being properly cached and retrieved based

## 1.3.0
- Added **Model Context Protocol (MCP) Server** support for building AI-powered applications [#49](https://github.com/uproid/finch/issues/49)
  - Full MCP 2.0 specification implementation with schema handler system
  - Automatic JSON serialization/deserialization using factory pattern
  - Built-in support for tools, resources, and prompts
  - Complete calculator example demonstrating MCP protocol flow
  - McpServerController for handling MCP requests and responses
- Updated dependencies to their latest versions for improved performance and security
- Improved documentation to include details about the new MCP Server features and how to use them in Finch applications
- Added new examples demonstrating the usage of the MCP Server in Finch applications

## 1.2.2
- Fixes [#50](https://github.com/uproid/finch/issues/50). The conflict between watchers in the serve environment has been resolved.

## 1.2.1
- Fixed bugs in route caching functionality to ensure proper caching and retrieval of routes based on the specified parameters and cache source. [#46](https://github.com/uproid/finch/issues/46)
- Adding language parameter to cache function to specify the language for which the route should be cached, allowing for better support of multilingual applications. [#47](https://github.com/uproid/finch/issues/47)

## 1.2.0
- Added route caching functionality to improve performance of frequently accessed routes. This includes in-memory caching and file-based caching options, with configurable cache duration and parameters.
- Updated dependencies to their latest versions to ensure compatibility and performance improvements.
- Improved documentation to include details about the new caching features and how to use them.
- Improved the example section to demonstrate the usage of route caching in Finch applications.

## 1.1.4
- Fixes bug of gettting template list in `finch templates` command in Finch CLI [#43](https://github.com/uproid/finch/issues/43)
- Updated documentations

## 1.1.3
- Added new command to create migration files for mysql and sqlite databases in Finch CLI
    ```bash
    finch migrate --create --mysql --name create_users_table
    finch migrate --create --sqlite --name create_users_table
    ```
- Fixs bugs in migration roll back command and added deep option to specify how many migrations should be rolled back in command line
    ```bash
    finch migrate --rollback=2    # rolls back the last 2 migrations
    finch migrate --rollback      # rolls back the last migration
    ```
- Fixed bug of cookies
- Improved the cookie options
- Updated dependencies
- Added `finch templates` command to show the list of available templates in GitHub [#40](https://github.com/uproid/finch/issues/40)

## 1.1.2
- Adding -template option to Finch CLI to create new projects with different templates
    ```bash
    finch create --template simple
    finch create -t simple
    ```
- Fixing commands help in Finch CLI


## 1.1.1
- Updated the Finch CLI to create new projects in new paths
- Fixed the example
- Added new extension for CappManager to write help in a modern way
- Added new command for build cli in Finch CLI
    ```bash
    finch build --cli --path ./lib/app.dart
    ```
    
## 1.1.0
- Added Finch serve CLI command to serve to run watch mode for development
    ```bash
    finch serve
    ```
- Improved the example section
- Fixed Finch CLI
- [#29](https://github.com/uproid/finch/issues/29) New ability to serve all languages json files to one dart file
- [#29](https://github.com/uproid/finch/issues/29) New ability to serve all widget files to one dart file
- Fixed asset managers for duplicated assets
- Developed Middleware [#30](https://github.com/uproid/finch/issues/30) classes for routes to have more control on routes
- Fixed Console debugger in frontend
- Fixed swagger UI
- Updated dependencies

## 1.0.4
- Fixed [#22](https://github.com/uproid/finch/issues/22) fixed checking isApiEndpoint property in WebRequest class
- Disabled MongoDB by default in FinchConfig [#25](https://github.com/uproid/finch/issues/25)
- Developed FinchApp.cleanRoutes() method to clear all registered routes [#15](https://github.com/uproid/finch/issues/15)

## 1.0.3
- Improved runing app speed in production mode #18

## 1.0.2
- Updated documentation for localization and i18n (EN/FA/ZH) #16
- Added new feauture for i18n with dart language source #16

## 1.0.1
- Improved documentations (EN/FA/ZH) #12
- Fixed addCookie, removeCookie & getLanguage #11

## 1.0.0
- First release of Finch
- The Finch package was developed as an adaptation of the WebApp package. We made extensive improvements to WebApp, focusing on simplicity in coding and overall stability, and released the enhanced version under the name Finch. From now on, all future updates will be made to this package, and WebApp will soon be deprecated.

## WebApp-3.0.0
#### Changes Applied to Remove `rq` Parameter from Controllers

##### Summary of Changes

In this project, all controllers and related classes have been updated to use a global `RequestContext` system instead of passing `rq` as a parameter.

##### Main Changes

###### 1. RequestContext Creation
- Created `RequestContext` class in `lib/src/core/request_context.dart`
- Uses Zone-based context for thread-safe request handling
- Provides `RequestContext.current` method for global access to WebRequest

###### 2. Controller Updates
- Removed `rq` parameter from constructor
- Added `rq` getter that uses `RequestContext.current`

###### 3. FinchApp Updates
- Added `RequestContext.run()` in request handlers
- Set up request context at the beginning of each request

###### 4. Controller Updates
- `HomeController`: Removed `rq` parameter from constructor
- `AuthController`: Removed `rq` parameter from constructor  
- `HtmlerController`: Removed `rq` parameter from constructor
- `ApiController`: Removed `rq` parameter from constructor
- `IncludeJsController`: Removed `rq` parameter from constructor

###### 5. Helper Class Updates
- `FormValidator`: Removed `rq` parameter and uses RequestContext
- `FinchView`: Removed `rq` parameter and uses RequestContext
- `UIPaging`: Removed `rq` parameter and uses RequestContext
- `AssetManager`: Removed `rq` parameter and uses RequestContext
- `Asset`: Removed `rq` parameter and uses RequestContext
- `DBCollectionFree`: Removed `rq` parameter from all route methods

###### 6. Routing Updates
- Removed passing `rq` to controllers during instantiation
- Converted inline functions to controller methods

###### 7. SQLite & MySQL databse driver
- support SQLite3 as a new DatabaseDriver and update the Sqler to support it.
- change mysqDb to mysqlDriver & sqliteDriver
- added new commands for support sqlite migraion functionality:
  ```bash
  migrate_sqlite --help
  migrate_sqlite --create
  migrate_sqlite --init
  ```

###### Benefits of These Changes
  - **Code Simplicity**: No longer need to pass `rq` everywhere
  - **Reduced Repetition**: Eliminated repetitive parameter passing code
  - **Thread Safety**: Zone-based context ensures thread safety
  - **Easy Access**: Simple and global access to WebRequest
---
- Remove `rq` from arguments of `WebRoute`
- Update dependencies
- Update jinja
- Expressions:
  - Ternary operator (condition ? trueValue : falseValue) as alternative to if-else expressions
    ```
    {{ user.isAdmin ? "Admin Panel" : "User Panel" }}
    {{ score > 60 ? "Pass" : "Fail" }}
    ```
  - Null coalescing operator (??) equivalent to or
    ```
    {{ variable ?? "default" }}
    {{ var1 ?? var2 ?? "final" }}
    ```
  - Variable names now support # and @ characters
    ```
    {{ #var }}, {{ var# }}, {{ @variable }}
    ```

## WebApp-2.1.1
- Added SSE (Server-Sent Events) support:
  - `renderSSE()` method in WebRequest class for streaming real-time data
  - New `SSE` class for creating Server-Sent Events messages
  - Support for custom headers, content types, and finish events
  - Automatic connection management and proper SSE protocol formatting
- Added new SQL-related form validators:
  - `isUniqueSQLField()` - validates field uniqueness in SQL database tables
  - `hasSqlRelation()` - validates field relations in SQL database tables
  - `checkByRegexp()` - validates fields using regular expression patterns
- Fixed JSON list parsing in WebRequest class
- Fixed localization translation function to properly use WebRequest context
- Added `tryJsonList()` method to FinchJson for safer JSON list parsing
- Updated sqler dependency from 1.1.3 to 1.1.4

## WebApp-2.1.0
- Added in line dump function for templates `{{ dump(var) }}`
- Added internal Swagger Widget to show documentations
- Fixed analizer reports
- Imoroved examples

## WebApp-2.0.3
- Trimming the input values received through GET/POST methods
- Enhancing security measures to mitigate XSS and injection vulnerabilities

## WebApp-2.0.2
- Improved `Htmler` tags
- Added `renderTag` to `WebRequest` class
- Added safe filter for templates of jinja

## WebApp-2.0.1
- Update Error pages style
- Added Htmler class (beta)
- Updated cli input handlers while running app.
- Fixed bugs

## WebApp-2.0.0
- Added Mysql database
- Added Sqler query generator
- Fixed some issus on FormValidators
- Fixed localy filters for templates
- Fixed localy events for templates
- Updated documentaions
- Updated Example and template
- Added Migration functionality for Mysql
- Added cli input handlers while running app.

## WebApp-1.1.18
- added $rq so that the current WebRequest can be accessed within templates. This will be useful for developing Local Events.

## WebApp-1.1.17 & 1.1.16
- Added custome error layout for `WebRequest`
- Fixes reports of dart analyze

## WebApp-1.1.15
- Fixes an error on getAll function of `DBCollectionFree`
- Fixes renew indexes of mongodb collections (`DBCollectionFree`) after run app 
- Add `collation` option for Indexes of `DBCollectionFree`

## WebApp-1.1.14
- Add index for fields of `DBCollectionFree`
- Add `Console.json(Object)` function to logs.

## WebApp-1.1.12
- Fixes #6 issue, Using `List<ObjectId>` in mongodb collections as a field

## WebApp-1.1.11
- Event listeners for insert, update, and delete documents in MongoDB collections for DBCollectionFree.

## WebApp-1.1.10
- Fixes issues with DB Collection Free in defualt values, when the form is static

## WebApp-1.1.9
- Fixed websocket

## WebApp-1.1.8
- Fixed filtering in auto routing DbCollectionFree
- Fixed reported logs of dart analyzer

## WebApp-1.1.7
- Added children to auto routing DbCollectionFree

## WebApp-1.1.6
- Fixed i18n with parameters

## WebApp-1.1.5
- Added default content types for `WebRequest`
- Improved field validators for forms
- Fixed the FinchJson to encode and decode Symbol variables.

## WebApp-1.1.4
- Fixed issue to start Database when starting project
- Added relation field for Collection Free Model's
- Updated dependencies

## WebApp-1.1.3
- Fixed bearer authorization in webrequest
- Auto router paths for api, in Collections Free Models

## WebApp-1.1.2
- Added fix
- Update dependencies
- New example regarding video streaming

## WebApp-1.1.1
- Resolved several bugs to enhance overall stability.
- Implemented the Collections Free Model (CFM) for MongoDB, streamlining the development of rapid APIs, forms, and validation processes (refer to examples).
- Enhanced existing examples for clearer guidance.
- Integrated the Capp package to facilitate console-based operations.
- Updated all dependencies to their latest versions to ensure compatibility and performance.

## WebApp-1.0.34
- Fixed data parsing multipart/form-data while requested emprty
- added tryData function to WebRequest(rq) class to return null or default value as unknown data in requests.
- Improved IncludeController for the DS variable translation (.tr(), .trArray()).

## WebApp-1.0.33
- Added build command for CLI:
    ```bash
    finch build -h
    ```
- Added extentions for File & Directory classes to copy directory and working with file names

## WebApp-1.0.32
- Fixed the redirection for external links/URI

## WebApp-1.0.31
- Fixed Finch CLI to create new project in new paths
- Fixed example

## WebApp-1.0.30
- Fixed https/http urls for requests
- Fixed layout of example
- Fixed bug Language directory
- UnitTest
- Added --path option to set path for create project in CLI
    ```bash
    finch create --path ./project_path --name example
    ```
    ```bash
    finch create -p ./project_path -n example
    ```

## WebApp-1.0.26
- Improved the Finch CLI
    - Fixed bug for OpenApi
    - An example for Swagger has been added: 'https://example.finchdart.com/swagger'
    - A utility menu has been developed for when the project is running to make controlling the project through the CLI easier.
    ```bash
    finch run [ENTER]
    help [ENTER]
    
       FINCH CLI

       * Press 'r' to Reload  the project                
       * Press 'c' to clear screen                       
       * Press 'i' to write info                         
       * Press 'q' to quit the project                   
    ```

## WebApp-1.0.25
- Improved the Finch CLI

## WebApp-1.0.24
- Fixed bug of `finch cli` in windows platforms

## WebApp-1.0.22
- Fixed bugs
- Added finch cli 
    ```bash
    finch -help
    finch create
    finch get
    finch run
    finch -v
    finch runner
    ```

## WebApp-1.0.21

- Fixed bugs.
- Improved the cron job.
- Added new examples.
- Added a `pathsEqual` function to check the equality of paths and endpoints. 

## WebApp-1.0.17

- Fixed bugs
- Added watcher to have hot reload in example file ./example/bin/watcher.dart

## WebApp-1.0.16

- Expanded `WebRoute` to include port and hostname as part of the routing configuration.

## WebApp-1.0.15

- Fixed routing bug for excluded paths
- Fixed bug for dumping variables

## WebApp-1.0.14

- Fixed routing issues
- Added variable dumping to the frontend
- Resolved SMTP bugs
- Improved documentation
- Enhanced the UI of error widgets
- Updated examples
- Refined unit tests

## WebApp-1.0.10

- Fixed various bugs
- Enhanced SMTP mail sender
- Updated example section

## WebApp-1.0.9

- Fixed bugs
- Improved configuration classes
- Updated example section

## WebApp-1.0.0

- Initial release WebApp