# AIM: Individual dataframes for mentions on twitter for each Thames catchment water body

# Twitter Mine ------------------------------------------------------------
mine_blue_mentions = function(river_query, wbid) {
  tryCatch(
    expr = {
      river_query = as.character(river_query)

      tweets = get_all_tweets(
        query = river_query,
        is_retweet = FALSE,
        lang = "en",
        start_tweets = "2006-04-01T00:00:00Z",
        #TODO discuss with Helge - should this go back to 2016?
        end_tweets = "2021-09-01T00:00:00Z",
        bearer_token = get_bearer(),
        data_path = "data/mined_tweets",
        bind_tweets = TRUE,
        context_annotations = FALSE,
        page_n = 500,
        n = Inf
      )

      # Clean and write csv --------------------------------------------------------------
      river_tweets = bind_tweets(data_path = "data/mined_tweets", output_format = "tidy") %>%
        mutate(query = river_query) %>%
        mutate(WBID = wbid)

      #delete files
      do.call(file.remove, list(list.files("data/mined_tweets", full.names = TRUE)))

      file_path = paste0("data/river_queries/", river_query, ".csv")

      #save river file
      write.csv(river_tweets, file_path)
      message(paste("Successfully mined mentions of ", river_query, sep = ""))
    },
    error = function(e) {
      message(
        'An error has occured. The machine will delete all mined tweets for the current river query and rerun the next query'
      )
      do.call(file.remove, list(list.files("data/mined_tweets", full.names = TRUE)))
    },
    finally = {
      message('Mine complete')
    }
  )
}
# read csv of mine sheet
waterbodies = read.csv("data/111021_mine_query_sheet_hp.csv")
waterbodies = read.csv("../../../../Downloads/060422_mine_query_sheet_hp.csv")

new_run = "GB106037033500,GB106039030334"
new_run = as.data.frame(strsplit(new_run,",")[[1]])
colnames(new_run) = "WBID"
new_run = inner_join(new_run,waterbodies)

# run mine
 for (i in 1:nrow(new_run)) {
   mine_blue_mentions(river_query = new_run$mine_query[i], wbid = new_run$WBID[i])
 }
