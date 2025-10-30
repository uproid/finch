const Map<int, Map<Symbol, String>> mongoDBErrorCodes = {
  1: {
    #name: "mongo.error.InternalError",
    #description: "An unspecified internal error occurred.",
  },
  2: {
    #name: "mongo.error.BadValue",
    #description: "A provided value is not correct.",
  },
  4: {
    #name: "mongo.error.NoSuchKey",
    #description: "A required key was not found in the document.",
  },
  5: {
    #name: "mongo.error.GraphContainsCycle",
    #description: "A cycle exists in a graph where none was allowed.",
  },
  6: {
    #name: "mongo.error.HostUnreachable",
    #description: "Could not connect to a remote server.",
  },
  7: {
    #name: "mongo.error.HostNotFound",
    #description: "The specified host could not be found.",
  },
  8: {
    #name: "mongo.error.UnknownError",
    #description: "An unknown error occurred.",
  },
  9: {
    #name: "mongo.error.FailedToParse",
    #description: "Failed to parse the input.",
  },
  10: {
    #name: "mongo.error.CannotMutateObject",
    #description: "An object cannot be mutated as expected.",
  },
  11: {
    #name: "mongo.error.UserNotFound",
    #description: "The specified user was not found in the database.",
  },
  12: {
    #name: "mongo.error.UnsupportedFormat",
    #description: "The provided format is not supported.",
  },
  13: {
    #name: "mongo.error.Unauthorized",
    #description: "User does not have the required privileges.",
  },
  14: {
    #name: "mongo.error.TypeMismatch",
    #description: "A type mismatch was encountered.",
  },
  15: {
    #name: "mongo.error.Overflow",
    #description: "An overflow occurred in the operation.",
  },
  16: {
    #name: "mongo.error.InvalidLength",
    #description: "The length of the input is invalid.",
  },
  17: {
    #name: "mongo.error.ProtocolError",
    #description: "A protocol error occurred during communication.",
  },
  18: {
    #name: "mongo.error.AuthenticationFailed",
    #description: "Authentication with the database failed.",
  },
  19: {
    #name: "mongo.error.CannotReuseObject",
    #description: "An object could not be reused.",
  },
  20: {
    #name: "mongo.error.IllegalOperation",
    #description: "The operation attempted is illegal.",
  },
  21: {
    #name: "mongo.error.EmptyArrayOperation",
    #description: "An operation was attempted on an empty array.",
  },
  22: {
    #name: "mongo.error.InvalidBSON",
    #description: "The BSON format is invalid.",
  },
  23: {
    #name: "mongo.error.AlreadyInitialized",
    #description: "The system has already been initialized.",
  },
  24: {
    #name: "mongo.error.LockTimeout",
    #description: "A lock operation timed out.",
  },
  25: {
    #name: "mongo.error.RemoteValidationError",
    #description: "A validation error occurred on a remote server.",
  },
  26: {
    #name: "mongo.error.NamespaceNotFound",
    #description: "The specified namespace was not found.",
  },
  27: {
    #name: "mongo.error.IndexNotFound",
    #description: "The specified index was not found.",
  },
  28: {
    #name: "mongo.error.PathNotViable",
    #description: "The specified path is not viable.",
  },
  29: {
    #name: "mongo.error.NonExistentPath",
    #description: "The specified path does not exist.",
  },
  30: {
    #name: "mongo.error.InvalidPath",
    #description: "The provided path is invalid.",
  },
  31: {
    #name: "mongo.error.RoleNotFound",
    #description: "The specified role was not found.",
  },
  32: {
    #name: "mongo.error.RolesNotRelated",
    #description: "The specified roles are not related.",
  },
  33: {
    #name: "mongo.error.PrivilegeNotFound",
    #description: "The specified privilege was not found.",
  },
  34: {
    #name: "mongo.error.CannotBackfillArray",
    #description: "Unable to backfill the array as requested.",
  },
  35: {
    #name: "mongo.error.UserModificationFailed",
    #description: "Failed to modify the specified user.",
  },
  36: {
    #name: "mongo.error.RemoteChangeDetected",
    #description: "A change was detected on a remote server.",
  },
  37: {
    #name: "mongo.error.FileRenameFailed",
    #description: "Failed to rename the specified file.",
  },
  38: {
    #name: "mongo.error.FileNotOpen",
    #description: "The specified file is not open.",
  },
  39: {
    #name: "mongo.error.FileStreamFailed",
    #description: "An error occurred in the file stream.",
  },
  40: {
    #name: "mongo.error.ConflictingUpdateOperators",
    #description: "Conflicting update operators were found in the request.",
  },
  41: {
    #name: "mongo.error.FileAlreadyOpen",
    #description: "The file is already open.",
  },
  42: {
    #name: "mongo.error.LogWriteFailed",
    #description: "Failed to write to the log file.",
  },
  43: {
    #name: "mongo.error.CursorNotFound",
    #description: "The specified cursor was not found.",
  },
  45: {
    #name: "mongo.error.UserDataInconsistent",
    #description: "The user data is inconsistent.",
  },
  46: {
    #name: "mongo.error.LockBusy",
    #description: "The requested lock is currently busy.",
  },
  47: {
    #name: "mongo.error.NoMatchingDocument",
    #description: "No matching document was found.",
  },
  48: {
    #name: "mongo.error.NamespaceExists",
    #description: "The specified namespace already exists.",
  },
  49: {
    #name: "mongo.error.InvalidRoleModification",
    #description: "The role modification is invalid.",
  },
  50: {
    #name: "mongo.error.MaxTimeMSExpired",
    #description: "The operation exceeded the specified maximum time.",
  },
  51: {
    #name: "mongo.error.ManualInterventionRequired",
    #description: "Manual intervention is required to proceed.",
  },
  52: {
    #name: "mongo.error.DollarPrefixedFieldName",
    #description: "Field name cannot start with a '\$' symbol.",
  },
  53: {
    #name: "mongo.error.InvalidIdField",
    #description: "The '_id' field is invalid.",
  },
  54: {
    #name: "mongo.error.NotSingleValueField",
    #description: "The field should contain a single value.",
  },
  55: {
    #name: "mongo.error.InvalidDBRef",
    #description: "The provided DBRef is invalid.",
  },
  56: {
    #name: "mongo.error.EmptyFieldName",
    #description: "Field names cannot be empty.",
  },
  57: {
    #name: "mongo.error.DottedFieldName",
    #description: "Field names cannot contain dots.",
  },
  58: {
    #name: "mongo.error.RoleModificationFailed",
    #description: "Failed to modify the specified role.",
  },
  59: {
    #name: "mongo.error.CommandNotFound",
    #description: "The specified command was not found.",
  },
  61: {
    #name: "mongo.error.ShardKeyNotFound",
    #description: "The shard key was not found.",
  },
  62: {
    #name: "mongo.error.OplogOperationUnsupported",
    #description: "The operation is unsupported on the oplog.",
  },
  63: {
    #name: "mongo.error.StaleShardVersion",
    #description: "The shard version is outdated.",
  },
  64: {
    #name: "mongo.error.WriteConcernFailed",
    #description: "The write concern failed.",
  },
  65: {
    #name: "mongo.error.MultipleErrorsOccurred",
    #description: "Multiple errors occurred.",
  },
  66: {
    #name: "mongo.error.ImmutableField",
    #description: "The field is immutable.",
  },
  67: {
    #name: "mongo.error.CannotCreateIndex",
    #description: "Unable to create the index as requested.",
  },
  68: {
    #name: "mongo.error.IndexAlreadyExists",
    #description: "The index already exists.",
  },
  69: {
    #name: "mongo.error.AuthSchemaIncompatible",
    #description: "The authentication schema is incompatible.",
  },
  70: {
    #name: "mongo.error.ShardNotFound",
    #description: "The specified shard was not found.",
  },
  71: {
    #name: "mongo.error.ReplicaSetNotFound",
    #description: "The specified replica set was not found.",
  },
  72: {
    #name: "mongo.error.InvalidOptions",
    #description: "The options provided are invalid.",
  },
  73: {
    #name: "mongo.error.InvalidNamespace",
    #description: "The specified namespace is invalid.",
  },
  74: {
    #name: "mongo.error.NodeNotFound",
    #description: "The specified node was not found.",
  },
  75: {
    #name: "mongo.error.WriteConcernLegacyOK",
    #description: "The write concern is acceptable in legacy mode.",
  },
  76: {
    #name: "mongo.error.NoReplicationEnabled",
    #description: "Replication is not enabled on this server.",
  },
  77: {
    #name: "mongo.error.OperationIncomplete",
    #description: "The operation was not completed as expected.",
  },
  78: {
    #name: "mongo.error.CommandResultSchemaViolation",
    #description: "The command result did not meet schema requirements.",
  },
  79: {
    #name: "mongo.error.UnknownReplWriteConcern",
    #description: "The specified write concern for the replica set is unknown.",
  },
  80: {
    #name: "mongo.error.RoleDataInconsistent",
    #description: "Role data is inconsistent across the system.",
  },
  81: {
    #name: "mongo.error.NoMatchParseContext",
    #description: "No matching context found during parsing.",
  },
  82: {
    #name: "mongo.error.NoProgressMade",
    #description: "No progress was made on the operation.",
  },
  83: {
    #name: "mongo.error.RemoteResultsUnavailable",
    #description: "Results from the remote source are unavailable.",
  },
  85: {
    #name: "mongo.error.IndexOptionsConflict",
    #description: "Conflicting options found in index creation.",
  },
  86: {
    #name: "mongo.error.IndexKeySpecsConflict",
    #description: "Key specifications for index creation are in conflict.",
  },
  87: {
    #name: "mongo.error.CannotSplit",
    #description: "Unable to split the specified resource.",
  },
  89: {
    #name: "mongo.error.NetworkTimeout",
    #description: "Network operation timed out.",
  },
  90: {
    #name: "mongo.error.CallbackCanceled",
    #description: "The callback operation was canceled.",
  },
  91: {
    #name: "mongo.error.ShutdownInProgress",
    #description: "The server shutdown is currently in progress.",
  },
  92: {
    #name: "mongo.error.SecondaryAheadOfPrimary",
    #description:
        "The secondary node is ahead of the primary node in replication.",
  },
  93: {
    #name: "mongo.error.InvalidReplicaSetConfig",
    #description: "Replica set configuration is invalid.",
  },
  94: {
    #name: "mongo.error.NotYetInitialized",
    #description: "The resource or service is not yet initialized.",
  },
  95: {
    #name: "mongo.error.NotSecondary",
    #description: "The node is not a secondary member in a replica set.",
  },
  96: {
    #name: "mongo.error.OperationFailed",
    #description: "The operation failed to execute.",
  },
  97: {
    #name: "mongo.error.NoProjectionFound",
    #description: "No projection was found for the query.",
  },
  98: {
    #name: "mongo.error.DBPathInUse",
    #description: "The database path is currently in use.",
  },
  100: {
    #name: "mongo.error.UnsatisfiableWriteConcern",
    #description: "The write concern could not be satisfied.",
  },
  101: {
    #name: "mongo.error.OutdatedClient",
    #description: "The client is outdated and cannot be used.",
  },
  102: {
    #name: "mongo.error.IncompatibleAuditMetadata",
    #description: "Audit metadata is incompatible with the server.",
  },
  103: {
    #name: "mongo.error.NewReplicaSetConfigurationIncompatible",
    #description:
        "New replica set configuration is incompatible with the current state.",
  },
  104: {
    #name: "mongo.error.NodeNotElectable",
    #description: "The node is not electable in the current configuration.",
  },
  105: {
    #name: "mongo.error.IncompatibleShardingMetadata",
    #description: "Sharding metadata is incompatible with the system.",
  },
  106: {
    #name: "mongo.error.DistributedClockSkewed",
    #description: "Distributed clock is skewed and requires adjustment.",
  },
  107: {
    #name: "mongo.error.LockFailed",
    #description: "Failed to acquire the requested lock.",
  },
  108: {
    #name: "mongo.error.InconsistentReplicaSetNames",
    #description: "Replica set names are inconsistent across nodes.",
  },
  109: {
    #name: "mongo.error.ConfigurationInProgress",
    #description: "Configuration is currently in progress.",
  },
  110: {
    #name: "mongo.error.CannotInitializeNodeWithData",
    #description: "Cannot initialize node because data already exists.",
  },
  111: {
    #name: "mongo.error.NotExactValueField",
    #description: "The field does not contain an exact value as expected.",
  },
  112: {
    #name: "mongo.error.WriteConflict",
    #description: "A write conflict occurred during the operation.",
  },
  113: {
    #name: "mongo.error.InitialSyncFailure",
    #description: "Initial synchronization with the replica set failed.",
  },
  114: {
    #name: "mongo.error.InitialSyncOplogSourceMissing",
    #description: "The source oplog for initial sync is missing.",
  },
  115: {
    #name: "mongo.error.CommandNotSupported",
    #description: "The command is not supported on this server.",
  },
  116: {
    #name: "mongo.error.DocTooLargeForCapped",
    #description: "The document is too large for the capped collection.",
  },
  117: {
    #name: "mongo.error.ConflictingOperationInProgress",
    #description: "A conflicting operation is already in progress.",
  },
  118: {
    #name: "mongo.error.NamespaceNotSharded",
    #description: "The namespace is not sharded as expected.",
  },
  119: {
    #name: "mongo.error.InvalidSyncSource",
    #description: "The synchronization source is invalid.",
  },
  120: {
    #name: "mongo.error.OplogStartMissing",
    #description: "The starting point for the oplog is missing.",
  },
  121: {
    #name: "mongo.error.DocumentValidationFailure",
    #description: "Document validation failed based on collection schema.",
  },
  123: {
    #name: "mongo.error.NotAReplicaSet",
    #description: "The node is not part of a replica set.",
  },
  124: {
    #name: "mongo.error.IncompatibleElectionProtocol",
    #description: "The election protocol is incompatible.",
  },
  125: {
    #name: "mongo.error.CommandFailed",
    #description: "The specified command failed to execute.",
  },
  126: {
    #name: "mongo.error.RPCProtocolNegotiationFailed",
    #description: "Failed to negotiate the RPC protocol.",
  },
  127: {
    #name: "mongo.error.UnrecoverableRollbackError",
    #description: "An unrecoverable error occurred during rollback.",
  },
  128: {
    #name: "mongo.error.LockNotFound",
    #description: "The specified lock was not found.",
  },
  129: {
    #name: "mongo.error.LockStateChangeFailed",
    #description: "Failed to change the lock state as requested.",
  },
  130: {
    #name: "mongo.error.SymbolNotFound",
    #description: "The specified symbol was not found in the code.",
  },
  133: {
    #name: "mongo.error.FailedToSatisfyReadPreference",
    #description: "The read preference could not be satisfied.",
  },
  134: {
    #name: "mongo.error.ReadConcernMajorityNotAvailableYet",
    #description: "Read concern majority is not available yet.",
  },
  135: {
    #name: "mongo.error.StaleTerm",
    #description: "The term is outdated and cannot be used.",
  },
  136: {
    #name: "mongo.error.CappedPositionLost",
    #description: "The capped position in the collection was lost.",
  },
  137: {
    #name: "mongo.error.IncompatibleShardingConfigVersion",
    #description: "The sharding configuration version is incompatible.",
  },
  138: {
    #name: "mongo.error.RemoteOplogStale",
    #description: "The remote oplog is outdated.",
  },
  139: {
    #name: "mongo.error.JSInterpreterFailure",
    #description: "JavaScript interpreter failed during execution.",
  },
  140: {
    #name: "mongo.error.InvalidSSLConfiguration",
    #description: "SSL configuration is invalid.",
  },
  141: {
    #name: "mongo.error.SSLHandshakeFailed",
    #description: "SSL handshake failed.",
  },
  142: {
    #name: "mongo.error.JSUncatchableError",
    #description: "An uncatchable error occurred in JavaScript.",
  },
  143: {
    #name: "mongo.error.CursorInUse",
    #description: "The specified cursor is already in use.",
  },
  144: {
    #name: "mongo.error.IncompatibleCatalogManager",
    #description: "Catalog manager is incompatible with current setup.",
  },
  145: {
    #name: "mongo.error.PooledConnectionsDropped",
    #description: "Pooled connections were dropped unexpectedly.",
  },
  146: {
    #name: "mongo.error.ExceededMemoryLimit",
    #description: "The operation exceeded the allowed memory limit.",
  },
  147: {
    #name: "mongo.error.ZLibError",
    #description: "An error occurred in zlib compression or decompression.",
  },
  148: {
    #name: "mongo.error.ReadConcernMajorityNotEnabled",
    #description: "Read concern majority is not enabled on this node.",
  },
  149: {
    #name: "mongo.error.NoConfigPrimary",
    #description: "No primary configuration available.",
  },
  150: {
    #name: "mongo.error.StaleEpoch",
    #description: "The epoch is outdated and needs to be refreshed.",
  },
  151: {
    #name: "mongo.error.OperationCannotBeBatched",
    #description: "The operation cannot be batched as expected.",
  },
  152: {
    #name: "mongo.error.OplogOutOfOrder",
    #description: "The oplog entries are out of order.",
  },
  153: {
    #name: "mongo.error.ChunkTooBig",
    #description: "The chunk is too large to be processed.",
  },
  154: {
    #name: "mongo.error.InconsistentShardIdentity",
    #description: "Shard identity is inconsistent across the cluster.",
  },
  155: {
    #name: "mongo.error.CannotApplyOplogWhilePrimary",
    #description: "Cannot apply oplog entries while in primary state.",
  },
  157: {
    #name: "mongo.error.CanRepairToDowngrade",
    #description: "System can be repaired for a downgrade.",
  },
  158: {
    #name: "mongo.error.MustUpgrade",
    #description: "An upgrade is required to proceed.",
  },
  159: {
    #name: "mongo.error.DurationOverflow",
    #description: "Duration value caused an overflow.",
  },
  160: {
    #name: "mongo.error.MaxStalenessOutOfRange",
    #description: "Max staleness value is out of allowable range.",
  },
  161: {
    #name: "mongo.error.IncompatibleCollationVersion",
    #description:
        "Collation version is incompatible with current configuration.",
  },
  162: {
    #name: "mongo.error.CollectionIsEmpty",
    #description: "The collection is empty, operation cannot proceed.",
  },
  163: {
    #name: "mongo.error.ZoneStillInUse",
    #description: "The zone is still in use and cannot be modified.",
  },
  164: {
    #name: "mongo.error.InitialSyncActive",
    #description: "Initial synchronization is currently active.",
  },
  165: {
    #name: "mongo.error.ViewDepthLimitExceeded",
    #description: "View depth limit exceeded in operation.",
  },
  166: {
    #name: "mongo.error.CommandNotSupportedOnView",
    #description: "The command is not supported on a view.",
  },
  167: {
    #name: "mongo.error.OptionNotSupportedOnView",
    #description: "The specified option is not supported on a view.",
  },
  168: {
    #name: "mongo.error.InvalidPipelineOperator",
    #description: "The pipeline operator is invalid.",
  },
  169: {
    #name: "mongo.error.CommandOnShardedViewNotSupportedOnMongod",
    #description: "Command on sharded view is not supported on mongod.",
  },
  170: {
    #name: "mongo.error.TooManyMatchingDocuments",
    #description: "Too many matching documents found.",
  },
  171: {
    #name: "mongo.error.CannotIndexParallelArrays",
    #description: "Parallel arrays cannot be indexed.",
  },
  172: {
    #name: "mongo.error.TransportSessionClosed",
    #description: "The transport session was closed unexpectedly.",
  },
  173: {
    #name: "mongo.error.TransportSessionNotFound",
    #description: "The transport session could not be found.",
  },
  174: {
    #name: "mongo.error.TransportSessionUnknown",
    #description: "The transport session is in an unknown state.",
  },
  175: {
    #name: "mongo.error.QueryPlanKilled",
    #description: "The query plan was killed due to an operation.",
  },
  176: {
    #name: "mongo.error.FileOpenFailed",
    #description: "Failed to open the specified file.",
  },
  177: {
    #name: "mongo.error.ZoneNotFound",
    #description: "The specified zone was not found in the configuration.",
  },
  178: {
    #name: "mongo.error.RangeOverlapConflict",
    #description: "Ranges overlap in a way that causes conflict.",
  },
  179: {
    #name: "mongo.error.WindowsPdhError",
    #description: "A Windows Performance Data Helper error occurred.",
  },
  180: {
    #name: "mongo.error.BadPerfCounterPath",
    #description: "The performance counter path is invalid.",
  },
  181: {
    #name: "mongo.error.AmbiguousIndexKeyPattern",
    #description: "The index key pattern is ambiguous.",
  },
  182: {
    #name: "mongo.error.InvalidViewDefinition",
    #description: "The view definition is invalid.",
  },
  183: {
    #name: "mongo.error.ClientMetadataMissingField",
    #description: "A required field is missing in the client metadata.",
  },
  184: {
    #name: "mongo.error.ClientMetadataAppNameTooLarge",
    #description: "The application name in client metadata is too large.",
  },
  185: {
    #name: "mongo.error.ClientMetadataDocumentTooLarge",
    #description: "The client metadata document exceeds the size limit.",
  },
  186: {
    #name: "mongo.error.CursorKilled",
    #description: "The cursor was killed before it could complete.",
  },
  187: {
    #name: "mongo.error.ShardKeyTooBig",
    #description: "The shard key exceeds the size limit.",
  },
  188: {
    #name: "mongo.error.StaleConfig",
    #description: "The configuration is outdated and requires a refresh.",
  },
  189: {
    #name: "mongo.error.CannotCreateCollection",
    #description: "Cannot create the specified collection.",
  },
  190: {
    #name: "mongo.error.IndexOptionsInvalid",
    #description: "The specified index options are invalid.",
  },
  191: {
    #name: "mongo.error.IndexKeyTooLong",
    #description: "The index key is too long.",
  },
  192: {
    #name: "mongo.error.IncompatibleWithUpgradedFCV",
    #description:
        "Incompatible with the upgraded feature compatibility version.",
  },
  193: {
    #name: "mongo.error.NamespaceTooLong",
    #description: "The namespace exceeds the allowable length.",
  },
  194: {
    #name: "mongo.error.InvalidRoleModification",
    #description: "The role modification is invalid.",
  },
  195: {
    #name: "mongo.error.ExceedsTimeLimit",
    #description: "The operation exceeded the time limit.",
  },
  197: {
    #name: "mongo.error.OperationNotSupportedInTransaction",
    #description: "This operation is not supported in a transaction.",
  },
  198: {
    #name: "mongo.error.TooManyFilesOpen",
    #description: "There are too many files open.",
  },
  199: {
    #name: "mongo.error.WouldChangeOwningShard",
    #description:
        "The operation would change the owning shard of the document.",
  },
  200: {
    #name: "mongo.error.StaleDbVersion",
    #description: "The database version is stale.",
  },
  201: {
    #name: "mongo.error.StaleChunkHistory",
    #description: "The chunk history is outdated and requires a refresh.",
  },
  202: {
    #name: "mongo.error.NoSuchTransaction",
    #description: "The specified transaction does not exist.",
  },
  203: {
    #name: "mongo.error.ReentrancyNotAllowed",
    #description: "Reentrancy is not allowed in this context.",
  },
  204: {
    #name: "mongo.error.FreeMonHttpInFlight",
    #description: "A Free Monitoring HTTP request is in progress.",
  },
  205: {
    #name: "mongo.error.FreeMonHttpTemporaryFailure",
    #description:
        "A temporary failure occurred in Free Monitoring HTTP request.",
  },
  206: {
    #name: "mongo.error.FreeMonHttpPermanentFailure",
    #description:
        "A permanent failure occurred in Free Monitoring HTTP request.",
  },
  207: {
    #name: "mongo.error.TransactionCommitted",
    #description: "The transaction has already been committed.",
  },
  208: {
    #name: "mongo.error.TransactionTooOld",
    #description: "The transaction is too old and cannot be continued.",
  },
  209: {
    #name: "mongo.error.AtomicityFailure",
    #description: "Atomicity constraints were violated in the operation.",
  },
  210: {
    #name: "mongo.error.CannotImplicitlyCreateCollection",
    #description: "Cannot create a collection implicitly for this operation.",
  },
  211: {
    #name: "mongo.error.SessionTransferIncomplete",
    #description: "The session transfer did not complete as expected.",
  },
  212: {
    #name: "mongo.error.MustDowngrade",
    #description: "A downgrade is required to continue.",
  },
  213: {
    #name: "mongo.error.DNSHostNotFound",
    #description: "DNS host not found for the specified hostname.",
  },
  214: {
    #name: "mongo.error.DNSProtocolError",
    #description: "A protocol error occurred in the DNS request.",
  },
  215: {
    #name: "mongo.error.MaxSubPipelineDepthExceeded",
    #description: "The maximum sub-pipeline depth was exceeded.",
  },
  216: {
    #name: "mongo.error.TooManyDocumentSequences",
    #description: "Too many document sequences in the request.",
  },
  217: {
    #name: "mongo.error.RetryChangeStream",
    #description: "Retry the change stream operation.",
  },
  218: {
    #name: "mongo.error.InternalErrorNotSupported",
    #description: "Internal error: operation is not supported.",
  },
  219: {
    #name: "mongo.error.ForTestingErrorExtraInfo",
    #description:
        "An error used specifically for testing purposes with extra info.",
  },
  220: {
    #name: "mongo.error.CursorKilled",
    #description: "The cursor was killed due to an external action.",
  },
  221: {
    #name: "mongo.error.QueryPlanKilled",
    #description: "The query plan was killed before completion.",
  },
  222: {
    #name: "mongo.error.ShardKeyTooBig",
    #description: "The shard key specified is too large.",
  },
  223: {
    #name: "mongo.error.UnsupportedOperation",
    #description: "This operation is not supported on the server.",
  },
  224: {
    #name: "mongo.error.UnrecoverableRollbackError",
    #description: "Unrecoverable error during rollback.",
  },
  225: {
    #name: "mongo.error.ReplSetNotPrimaryNoSecondaryOk",
    #description:
        "The replica set is not primary, and secondary read preference is not allowed.",
  },
  226: {
    #name: "mongo.error.NotPrimaryOrSecondary",
    #description: "The node is neither a primary nor a secondary.",
  },
  227: {
    #name: "mongo.error.ErrorLabelNotFound",
    #description: "The specified error label was not found.",
  },
  228: {
    #name: "mongo.error.CursorInUse",
    #description: "The cursor is already in use and cannot be reused.",
  },
  229: {
    #name: "mongo.error.InvalidNetworkInterface",
    #description: "The specified network interface is invalid.",
  },
  230: {
    #name: "mongo.error.FailedToVerifyAuthorization",
    #description: "Failed to verify user authorization.",
  },
  231: {
    #name: "mongo.error.NoShardingEnabled",
    #description: "Sharding is not enabled on the server.",
  },
  232: {
    #name: "mongo.error.HostNotFound",
    #description: "The specified host was not found in the network.",
  },
  233: {
    #name: "mongo.error.UserDataInconsistent",
    #description: "User data is inconsistent across nodes.",
  },
  234: {
    #name: "mongo.error.CommandNotSupportedOnNode",
    #description: "The command is not supported on this type of node.",
  },
  235: {
    #name: "mongo.error.ClusterTimeTooOld",
    #description: "The specified cluster time is too old to be used.",
  },
  236: {
    #name: "mongo.error.ConflictingOperationInProgress",
    #description: "A conflicting operation is currently in progress.",
  },
  237: {
    #name: "mongo.error.TooManyViewDepth",
    #description: "Exceeded the maximum allowable depth for views.",
  },
  238: {
    #name: "mongo.error.InvalidReadConcern",
    #description: "The specified read concern is invalid.",
  },
  239: {
    #name: "mongo.error.RetryChangeStream",
    #description: "The change stream should be retried.",
  },
  240: {
    #name: "mongo.error.ResumableChangeStreamError",
    #description: "A resumable error occurred in the change stream.",
  },
  241: {
    #name: "mongo.error.StaleClusterTime",
    #description: "The specified cluster time is stale.",
  },
  242: {
    #name: "mongo.error.NoSuchTransaction",
    #description: "No such transaction exists.",
  },
  243: {
    #name: "mongo.error.IncompatibleProtocol",
    #description: "The protocol specified is incompatible with the server.",
  },
  244: {
    #name: "mongo.error.TooManyInFlight",
    #description: "There are too many in-flight operations.",
  },
  245: {
    #name: "mongo.error.RetryTransaction",
    #description: "The transaction should be retried.",
  },
  246: {
    #name: "mongo.error.InternalTransactionNotSupported",
    #description: "Internal transaction support is not available.",
  },
  247: {
    #name: "mongo.error.InvalidSession",
    #description: "The session is invalid or has expired.",
  },
  248: {
    #name: "mongo.error.WriteConflictRetryTransaction",
    #description:
        "A write conflict occurred, and the transaction should be retried.",
  },
  249: {
    #name: "mongo.error.NotImplemented",
    #description: "The requested operation is not implemented.",
  },
  250: {
    #name: "mongo.error.ReadConcernMajorityNotAvailableYet",
    #description: "Read concern majority is not available yet on this server.",
  },
  251: {
    #name: "mongo.error.StaleEpoch",
    #description: "The epoch of the resource is stale and requires refresh.",
  },
  252: {
    #name: "mongo.error.IndexKeyTooLong",
    #description: "The specified index key is too long.",
  },
  253: {
    #name: "mongo.error.CannotImplicitlyCreateCollection",
    #description:
        "Implicit collection creation is not allowed in this context.",
  },
  254: {
    #name: "mongo.error.IncompatibleShardingConfigVersion",
    #description: "The sharding configuration version is incompatible.",
  },
  255: {
    #name: "mongo.error.NonResumableChangeStreamError",
    #description: "A non-resumable error occurred on the change stream.",
  },
  256: {
    #name: "mongo.error.TransactionCommitted",
    #description: "The transaction has been successfully committed.",
  },
  257: {
    #name: "mongo.error.TransactionTooLarge",
    #description: "The transaction size is too large to be processed.",
  },
  258: {
    #name: "mongo.error.UnknownFeatureCompatibilityVersion",
    #description: "The feature compatibility version is unknown.",
  },
  259: {
    #name: "mongo.error.KeyedExecutorRetry",
    #description: "A retry is needed for the keyed executor operation.",
  },
  260: {
    #name: "mongo.error.InvalidResumeToken",
    #description: "The resume token is invalid or malformed.",
  },
  261: {
    #name: "mongo.error.TooManyLogicalSessions",
    #description: "Too many logical sessions have been created.",
  },
  262: {
    #name: "mongo.error.ExceededTimeLimit",
    #description: "The operation exceeded its allocated time limit.",
  },
  263: {
    #name: "mongo.error.OperationNotSupportedInTransaction",
    #description: "This operation is not allowed in a transaction context.",
  },
  264: {
    #name: "mongo.error.TooManyFilesOpen",
    #description: "The server has too many open files.",
  },
  265: {
    #name: "mongo.error.OrphanedRangeCleanUpFailed",
    #description: "Failed to clean up orphaned ranges.",
  },
  266: {
    #name: "mongo.error.FailPointSetFailed",
    #description: "Setting the fail point failed.",
  },
  267: {
    #name: "mongo.error.PreparedTransactionInProgress",
    #description: "A prepared transaction is currently in progress.",
  },
  268: {
    #name: "mongo.error.CannotBackup",
    #description: "The backup operation cannot proceed.",
  },
  269: {
    #name: "mongo.error.DataModifiedByRepair",
    #description: "Data was modified as a result of a repair operation.",
  },
  270: {
    #name: "mongo.error.RepairedReplicaSetNode",
    #description: "This replica set node was repaired.",
  },
  271: {
    #name: "mongo.error.JSInterpreterFailureWithStack",
    #description: "JavaScript interpreter failure with stack trace.",
  },
  272: {
    #name: "mongo.error.MigrationConflict",
    #description: "A conflict occurred during migration.",
  },
  273: {
    #name: "mongo.error.ProducerConsumerQueueProducerQueueDepthExceeded",
    #description: "Producer queue depth exceeded.",
  },
  274: {
    #name: "mongo.error.ProducerConsumerQueueConsumed",
    #description: "Producer-consumer queue has been consumed.",
  },
  275: {
    #name: "mongo.error.ExchangePassthrough",
    #description: "Exchange operation is in passthrough mode.",
  },
  276: {
    #name: "mongo.error.IndexBuildAborted",
    #description: "The index build was aborted.",
  },
  277: {
    #name: "mongo.error.AlarmAlreadyFulfilled",
    #description: "The alarm has already been fulfilled.",
  },
  278: {
    #name: "mongo.error.UnsatisfiableCommitQuorum",
    #description: "Commit quorum requirements cannot be met.",
  },
  279: {
    #name: "mongo.error.ClientDisconnect",
    #description: "The client has disconnected.",
  },
  280: {
    #name: "mongo.error.ChangeStreamFatalError",
    #description: "A fatal error occurred in the change stream.",
  },
  281: {
    #name: "mongo.error.TransactionCoordinatorSteppingDown",
    #description: "The transaction coordinator is stepping down.",
  },
  282: {
    #name: "mongo.error.TransactionCoordinatorReachedAbortDecision",
    #description: "The transaction coordinator decided to abort.",
  },
  283: {
    #name: "mongo.error.WouldChangeOwningShard",
    #description: "The operation would result in changing the owning shard.",
  },
  284: {
    #name: "mongo.error.ForTestingErrorExtraInfoWithExtraInfoInNamespace",
    #description: "Error used for testing with extra namespace info.",
  },
  285: {
    #name: "mongo.error.IndexBuildAlreadyInProgress",
    #description: "An index build is already in progress.",
  },
  286: {
    #name: "mongo.error.ChangeStreamHistoryLost",
    #description: "The change stream history is no longer available.",
  },
  287: {
    #name: "mongo.error.TransactionCoordinatorDeadlineTaskCanceled",
    #description: "The transaction coordinator's deadline task was canceled.",
  },
  288: {
    #name: "mongo.error.ChecksumMismatch",
    #description: "A checksum mismatch was detected.",
  },
  289: {
    #name: "mongo.error.WaitForMajorityServiceEarlierOpTimeAvailable",
    #description: "An earlier opTime is available for majority service.",
  },
  290: {
    #name: "mongo.error.TransactionExceededLifetimeLimitSeconds",
    #description: "The transaction exceeded its lifetime limit.",
  },
  291: {
    #name: "mongo.error.NoQueryExecutionPlans",
    #description: "No query execution plans are available.",
  },
  292: {
    #name: "mongo.error.QueryExceededMemoryLimitNoDiskUseAllowed",
    #description:
        "The query exceeded memory limits without disk usage allowed.",
  },
  293: {
    #name: "mongo.error.InvalidSeedList",
    #description: "The seed list provided is invalid.",
  },
  294: {
    #name: "mongo.error.InvalidTopologyType",
    #description: "The topology type specified is invalid.",
  },
  295: {
    #name: "mongo.error.InvalidHeartBeatFrequency",
    #description: "The heartbeat frequency is invalid.",
  },
  296: {
    #name: "mongo.error.TopologySetNameRequired",
    #description: "A set name is required for the topology.",
  },
  297: {
    #name: "mongo.error.HierarchicalAcquisitionLevelViolation",
    #description: "Hierarchical acquisition level was violated.",
  },
  298: {
    #name: "mongo.error.InvalidServerType",
    #description: "The specified server type is invalid.",
  },
  299: {
    #name: "mongo.error.OCSPCertificateStatusRevoked",
    #description: "The OCSP certificate status was revoked.",
  },
  300: {
    #name:
        "mongo.error.RangeDeletionAbandonedBecauseCollectionWithUUIDDoesNotExist",
    #description:
        "Range deletion was abandoned because the collection with the specified UUID does not exist.",
  },
  301: {
    #name: "mongo.error.DataCorruptionDetected",
    #description: "Data corruption was detected on the server.",
  },
  302: {
    #name: "mongo.error.OCSPCertificateStatusUnknown",
    #description: "The OCSP certificate status is unknown.",
  },
  303: {
    #name: "mongo.error.SplitHorizonChange",
    #description: "A split-horizon change was detected.",
  },
  304: {
    #name: "mongo.error.ShardInvalidatedForTargeting",
    #description: "The shard is no longer valid for targeting.",
  },
  307: {
    #name: "mongo.error.RangeDeletionAbandonedBecauseTaskDocumentDoesNotExist",
    #description:
        "Range deletion was abandoned because the task document does not exist.",
  },
  308: {
    #name: "mongo.error.CurrentConfigNotCommittedYet",
    #description: "The current configuration has not yet been committed.",
  },
  309: {
    #name: "mongo.error.ExhaustCommandFinished",
    #description: "The exhaust command has finished executing.",
  },
  310: {
    #name: "mongo.error.PeriodicJobIsStopped",
    #description: "The periodic job has been stopped.",
  },
  311: {
    #name: "mongo.error.TransactionCoordinatorCanceled",
    #description: "The transaction coordinator was canceled.",
  },
  312: {
    #name: "mongo.error.OperationIsKilledAndDelisted",
    #description:
        "The operation was killed and removed from active operations.",
  },
  313: {
    #name: "mongo.error.ResumableRangeDeleterDisabled",
    #description: "The resumable range deleter is disabled.",
  },
  314: {
    #name: "mongo.error.ObjectIsBusy",
    #description: "The object is currently busy and cannot be accessed.",
  },
  315: {
    #name: "mongo.error.TooStaleToSyncFromSource",
    #description: "The data is too stale to sync from the source.",
  },
  316: {
    #name: "mongo.error.QueryTrialRunCompleted",
    #description: "The query trial run has been completed.",
  },
  317: {
    #name: "mongo.error.ConnectionPoolExpired",
    #description: "The connection pool has expired.",
  },
  318: {
    #name: "mongo.error.ForTestingOptionalErrorExtraInfo",
    #description: "An error used for testing with optional extra info.",
  },
  319: {
    #name: "mongo.error.MovePrimaryInProgress",
    #description: "The move primary operation is currently in progress.",
  },
  320: {
    #name: "mongo.error.TenantMigrationConflict",
    #description: "A conflict occurred during tenant migration.",
  },
  321: {
    #name: "mongo.error.TenantMigrationCommitted",
    #description: "Tenant migration has been committed.",
  },
  322: {
    #name: "mongo.error.APIVersionError",
    #description: "An API version error occurred.",
  },
  323: {
    #name: "mongo.error.APIStrictError",
    #description: "An API strict error occurred.",
  },
  324: {
    #name: "mongo.error.APIDeprecationError",
    #description: "An API deprecation error occurred.",
  },
  325: {
    #name: "mongo.error.TenantMigrationAborted",
    #description: "Tenant migration was aborted.",
  },
  326: {
    #name: "mongo.error.OplogQueryMinTsMissing",
    #description: "The minimum timestamp for the oplog query is missing.",
  },
  327: {
    #name: "mongo.error.NoSuchTenantMigration",
    #description: "The specified tenant migration does not exist.",
  },
  328: {
    #name: "mongo.error.TenantMigrationAccessBlockerShuttingDown",
    #description: "The tenant migration access blocker is shutting down.",
  },
  329: {
    #name: "mongo.error.TenantMigrationInProgress",
    #description: "A tenant migration is currently in progress.",
  },
  330: {
    #name: "mongo.error.SkipCommandExecution",
    #description: "Skipping the command execution as per configuration.",
  },
  331: {
    #name: "mongo.error.FailedToRunWithReplyBuilder",
    #description: "Failed to run the operation with the reply builder.",
  },
  332: {
    #name: "mongo.error.CannotDowngrade",
    #description: "Downgrade is not allowed in this context.",
  },
  333: {
    #name: "mongo.error.ServiceExecutorInShutdown",
    #description: "The service executor is in shutdown mode.",
  },
  334: {
    #name: "mongo.error.MechanismUnavailable",
    #description: "The specified authentication mechanism is unavailable.",
  },
  335: {
    #name: "mongo.error.TenantMigrationForgotten",
    #description: "The tenant migration has been forgotten by the server.",
  },
  9001: {
    #name: "mongo.error.SocketException",
    #description:
        "A socket exception occurred, typically due to network issues.",
  },
  10003: {
    #name: "mongo.error.CannotGrowDocumentInCappedNamespace",
    #description: "Documents cannot grow in a capped namespace.",
  },
  10107: {
    #name: "mongo.error.NotWritablePrimary",
    #description: "The node is not a writable primary.",
  },
  10334: {
    #name: "mongo.error.BSONObjectTooLarge",
    #description: "The BSON object is too large to process.",
  },
  11000: {
    #name: "mongo.error.DuplicateKey",
    #description:
        "A duplicate key error occurred, typically due to unique constraint violations.",
  },
  11600: {
    #name: "mongo.error.InterruptedAtShutdown",
    #description: "The operation was interrupted due to server shutdown.",
  },
  11601: {
    #name: "mongo.error.Interrupted",
    #description: "The operation was interrupted.",
  },
  11602: {
    #name: "mongo.error.InterruptedDueToReplStateChange",
    #description:
        "The operation was interrupted due to a replica state change.",
  },
  12586: {
    #name: "mongo.error.BackgroundOperationInProgressForDatabase",
    #description:
        "A background operation is in progress for the specified database.",
  },
  12587: {
    #name: "mongo.error.BackgroundOperationInProgressForNamespace",
    #description:
        "A background operation is in progress for the specified namespace.",
  },
  13113: {
    #name: "mongo.error.MergeStageNoMatchingDocument",
    #description:
        "No matching document found in the merge stage of the pipeline.",
  },
  13297: {
    #name: "mongo.error.DatabaseDifferCase",
    #description:
        "A database exists with a case-insensitive name that differs only in case.",
  },
  13388: {
    #name: "mongo.error.StaleConfig",
    #description: "The configuration data is stale.",
  },
  13435: {
    #name: "mongo.error.NotPrimaryNoSecondaryOk",
    #description:
        "The node is not a primary, and secondary reads are not allowed.",
  },
  13436: {
    #name: "mongo.error.NotPrimaryOrSecondary",
    #description: "The node is neither primary nor secondary.",
  },
  14031: {
    #name: "mongo.error.OutOfDiskSpace",
    #description: "The server is out of disk space.",
  },
  46841: {
    #name: "mongo.error.ClientMarkedKilled",
    #description: "The client has been marked as killed and cannot continue."
  }
};
