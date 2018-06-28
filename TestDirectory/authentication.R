library(ROAuth)
library(twitteR)
11
consumer_key <-"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
consumer_secret <- "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
access_token<-"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
access_secret <- "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

#download.file(url="http://curl.haxx.se/ca/cacert.pem",destfile = "cacert.pem")
#setup_twitter_oauth(consumer_key ,consumer_secret, access_token,  access_secret )
 
#cred <- OAuthFactory$new(consumerKey=consumer_key, consumerSecret=consumer_secret,requestURL='https://api.twitter.com/oauth/request_token',accessURL='https://api.twitter.com/oauth/access_token',authURL='https://api.twitter.com/oauth/authorize')

#cred$handshake(cainfo="cacert.pem")
#After this you will be redirected to a URL where you click on authorize app and get the passkey to be entered in RStudio


setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
