#' @useDynLib mongolite R_mongo_collection_new
mongo_collection_new <- function(client, collection = "test", db = "test"){
  stopifnot(inherits(client, "mongo_client"))
  stopifnot(is.character(db))
  stopifnot(is.character(collection))
  .Call(R_mongo_collection_new, client, collection, db)
}

#' @useDynLib mongolite R_mongo_get_default_database
mongo_get_default_database <- function(client){
  stopifnot(inherits(client, "mongo_client"))
  .Call(R_mongo_get_default_database, client)
}

#' @useDynLib mongolite R_mongo_client_new
mongo_client_new <- function(uri = "mongodb://127.0.0.1", pem_file = NULL, pem_pwd = NULL,
    ca_file = NULL, ca_dir = NULL, crl_file = NULL, allow_invalid_hostname = NULL, weak_cert_validation = NULL){

  stopifnot(is.character(uri))
  pem_file <- as.character(pem_file)
  pem_pwd <- as.character(pem_pwd)
  ca_file <- as.character(ca_file)
  ca_dir <- as.character(ca_dir)
  crl_file <- as.character(crl_file)
  allow_invalid_hostname <- as.logical(allow_invalid_hostname)
  weak_cert_validation <- as.logical(weak_cert_validation)
  .Call(R_mongo_client_new, uri, pem_file, pem_pwd, ca_file, ca_dir, crl_file, allow_invalid_hostname, weak_cert_validation)
}

mongo_client_server_status <- function(col){
  mongo_collection_command_simple(col, '{"serverStatus" : 1}')
}

#' @useDynLib mongolite R_mongo_collection_drop
mongo_collection_drop <- function(col){
  .Call(R_mongo_collection_drop, col)
}

mongo_collection_stats <- function(col){
  name <- mongo_collection_name(col)
  mongo_collection_command_simple(col, sprintf('{"collStats": "%s"}', name))
}

#' @useDynLib mongolite R_mongo_collection_name
mongo_collection_name <- function(col){
  .Call(R_mongo_collection_name, col)
}

#' @useDynLib mongolite R_mongo_collection_rename
mongo_collection_rename <- function(col, db = NULL, name){
  stopifnot(is.character(name))
  stopifnot(is.null(db) || is.character(db))
  .Call(R_mongo_collection_rename, col, db, name)
}

#' @useDynLib mongolite R_mongo_collection_count
mongo_collection_count <- function(col, query = "{}"){
  .Call(R_mongo_collection_count, col, bson_or_json(query))
}

#returns data
#' @useDynLib mongolite R_mongo_collection_command_simple
mongo_collection_command_simple <- function(col, command = "{}", simplify = FALSE){
  data <- .Call(R_mongo_collection_command_simple, col, bson_or_json(command))
  if(isTRUE(simplify)){
    jsonlite:::simplify(data)
  } else {
    data
  }
}

#returns cursor
#' @useDynLib mongolite R_mongo_collection_command
mongo_collection_command <- function(col, command = "{}", no_timeout = FALSE){
  stopifnot(is.logical(no_timeout))
  .Call(R_mongo_collection_command, col, bson_or_json(command), no_timeout)
}

# Wrapper for mapReduce command
mongo_collection_mapreduce <- function(col, map, reduce, query, sort, limit, out, scope){
  if(is.null(out))
    out <- list(inline = 1)
  cmd <- list(
    mapreduce = mongo_collection_name(col),
    map = map,
    reduce = reduce,
    query = structure(query, class = "json"),
    sort = structure(sort, class = "json"),
    limit = limit,
    out = out,
    scope = scope
  )
  mongo_collection_command(col, jsonlite::toJSON(cmd, auto_unbox = TRUE, json_verbatim = TRUE))
}

mongo_collection_distinct <- function(col, key, query){
  cmd <- list(
    distinct = mongo_collection_name(col),
    key = key,
    query = structure(query, class="json")
  )
  mongo_collection_command_simple(col, jsonlite::toJSON(cmd, json_verbatim = TRUE, auto_unbox = TRUE))
}

#' @useDynLib mongolite R_mongo_collection_insert_bson
mongo_collection_insert_bson <- function(col, doc, stop_on_error = TRUE){
  .Call(R_mongo_collection_insert_bson, col, bson_or_json(doc), stop_on_error)
}

#' @useDynLib mongolite R_mongo_collection_update
mongo_collection_update <- function(col, selector, update, filters = NULL, upsert = FALSE, multiple = FALSE, replace = FALSE){
  stopifnot(is.logical(upsert))
  stopifnot(is.logical(multiple))
  filters <- bson_or_json(filters, allowNull = TRUE)
  reply <- .Call(R_mongo_collection_update, col, bson_or_json(selector), bson_or_json(update), filters, upsert, multiple, replace)
  structure(reply, class = c("miniprint"))
}

#' @useDynLib mongolite R_mongo_collection_insert_page
mongo_collection_insert_page <- function(col, json, stop_on_error = TRUE){
  out <- .Call(R_mongo_collection_insert_page, col, json, stop_on_error)
  structure(out, class = c("miniprint"))
}

#' @useDynLib mongolite R_mongo_collection_remove
mongo_collection_remove <- function(col, doc, just_one = FALSE){
  stopifnot(is.logical(just_one))
  .Call(R_mongo_collection_remove, col, bson_or_json(doc), just_one)
}

#' @useDynLib mongolite R_mongo_collection_find
mongo_collection_find <- function(col, query = '{}', sort = '{}', fields = '{"_id":0}', skip = 0, limit = 0, no_timeout = FALSE){
  stopifnot(is.numeric(skip))
  stopifnot(is.numeric(limit))
  stopifnot(is.logical(no_timeout))
  opts = list(
    projection = structure(fields, class = "json"),
    sort = structure(sort, class = "json"),
    skip = skip,
    limit = limit,
    noCursorTimeout = no_timeout
  )
  opts <- jsonlite::toJSON(opts, auto_unbox = TRUE, json_verbatim = TRUE)
  .Call(R_mongo_collection_find, col, bson_or_json(query), bson_or_json(opts))
}

#' @useDynLib mongolite R_mongo_collection_aggregate
mongo_collection_aggregate <- function(col, pipeline = '{}', options = '{}', no_timeout = FALSE){
  stopifnot(is.logical(no_timeout))
  .Call(R_mongo_collection_aggregate, col, bson_or_json(pipeline), bson_or_json(options), no_timeout)
}

#' @useDynLib mongolite R_mongo_cursor_more
mongo_cursor_more <- function(cursor){
  .Call(R_mongo_cursor_more, cursor)
}

#' @useDynLib mongolite R_mongo_collection_create_index
mongo_collection_create_index <- function(col, field = '{}'){
  stopifnot(is.character(field))
  stopifnot(length(field) == 1)
  if(!jsonlite::validate(field)){
    if(grepl("[{}]", field))
      stop("Index is not valid json or field name.")
    field <- jsonlite::toJSON(structure(list(1), names = field), auto_unbox = TRUE)
  }
  .Call(R_mongo_collection_create_index, col, bson_or_json(field))
}

#' @useDynLib mongolite R_mongo_collection_drop_index
mongo_collection_drop_index <- function(col, name){
  .Call(R_mongo_collection_drop_index, col, name)
}

#' @useDynLib mongolite R_mongo_cursor_next_bson
mongo_cursor_next_bson <- function(cursor){
  .Call(R_mongo_cursor_next_bson, cursor)
}

#' @useDynLib mongolite R_mongo_cursor_next_json
mongo_cursor_next_json <- function(cursor, n = 1){
  .Call(R_mongo_cursor_next_json, cursor, n = n)
}

#' @useDynLib mongolite R_mongo_cursor_next_bsonlist
mongo_cursor_next_bsonlist <- function(cursor, n = 1){
  .Call(R_mongo_cursor_next_bsonlist, cursor, n = n)
}

#' @useDynLib mongolite R_mongo_cursor_next_page
mongo_cursor_next_page <- function(cursor, size = 100, as_json = FALSE){
  .Call(R_mongo_cursor_next_page, cursor, size = size, as_json = as_json)
}

#' @useDynLib mongolite R_mongo_collection_find_indexes
mongo_collection_find_indexes <- function(col){
  cur <- .Call(R_mongo_collection_find_indexes, col)
  out <- mongo_cursor_next_page(cur)
  out <- Filter(length, out)
  as.data.frame(jsonlite:::simplify(out))
}

#' @useDynLib mongolite R_mongo_restore
mongo_restore <- function(col, con, verbose = FALSE){
  if(!isOpen(con)){
    open(con, "rb")
    on.exit(close(con))
  }
  .Call(R_mongo_restore, con, col, verbose)
}

#' @useDynLib mongolite R_ptr_get_prot
ptr_get_prot <- function(col){
  stopifnot(inherits(col, "mongo_collection"))
  .Call(R_ptr_get_prot, col)
}

#' @useDynLib mongolite R_mongo_collection_disconnect
mongo_collection_disconnect <- function(col){
  stopifnot(inherits(col, "mongo_collection"))
  .Call(R_mongo_collection_disconnect, col)
}
