####
####
#### AIM: Prepare twitter data for web map
####

if(file.edit("data/web/oc.geojson")){


} else {
  # read water bodies
  thames_wb = read_sf("data/thames_river.geojson") %>%
    st_drop_geometry() %>%
    select(WBID, name, OC, OC_num, MC, MC_num, RBD, RBD_num)

  # join with main data to get categorical variables
  data_main = inner_join(data_main,thames_wb)

  # aggregate data
  MC = as.data.frame(aggregate(senticent_polarity  ~ MC_num, data_main, mean))
  OC = as.data.frame(aggregate(senticent_polarity  ~ OC_num, data_main, mean))
  RBD = as.data.frame(aggregate(senticent_polarity  ~ RBD_num, data_main, mean))
  WB = as.data.frame(aggregate(senticent_polarity  ~ WBID, data_main, mean))

  # generate mc geojson
  mc_sf = read_sf("data/mc_test.geojson") %>%
    select(-c(val)) %>%
    rename(MC_num = notation) %>%
    right_join(MC) %>%
    rename(MC = label) %>%
    select(MC,MC_num,senticent_polarity,geometry)

  write_sf(mc_sf,"data/web/mc.geojson")

  # generate mc geojson
  oc_sf = read_sf("data.oc_test.geojson") %>%
    select(-c(val)) %>%
    rename(OC_num = notation) %>%
    right_join(OC) %>%
    rename(OC = label) %>%
    select(OC,OC_num,senticent_polarity,geometry)

  write_sf(oc_sf,"data/web/oc.geojson")

  # generate wbid geojson
  wb_sf = read_sf("data/thames_river.geojson") %>% right_join(WB)

  write_sf(wb_sf,"data/web/wb.geojson")

  mc_sf = read_sf("data/web/mc.geojson")
  mc_cent = st_centroid(mc_sf) %>% rename(name = MC) %>% select(name,geometry)

  oc_sf = read_sf("data/web/oc.geojson")
  oc_cent = st_centroid(oc_sf) %>% rename(name = OC) %>% select(name,geometry)

  wb_sf = read_sf("data/web/wb.geojson")
  wb_cent = st_centroid(wb_sf)%>% select(name,geometry)

  all_cent = rbind(wb_cent,oc_cent,mc_cent)
  write_sf(all_cent,"data/web/search_centroids.geojson")


}
