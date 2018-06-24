library(ROAuth)
library(twitteR)
11
consumer_key <-"U60YN2OZknX33iDBxSgRoKTY1"
consumer_secret <- "rFfX0PnHn409gV281yl49E0PneM2Z2CPO1MdiFL3JLu4ikUYYa"
access_token<-"224134631-766GbZ9FmTpXmlbOuUyEuIw6iv6HcBzOIAhh07Qc"
access_secret <- "v5ZQke0ieNjpWIXPt2bUJ5pSYu3N2P972WLJNo5tOZD4X"

#download.file(url="http://curl.haxx.se/ca/cacert.pem",destfile = "cacert.pem")
#setup_twitter_oauth(consumer_key ,consumer_secret, access_token,  access_secret )
 
#cred <- OAuthFactory$new(consumerKey=consumer_key, consumerSecret=consumer_secret,requestURL='https://api.twitter.com/oauth/request_token',accessURL='https://api.twitter.com/oauth/access_token',authURL='https://api.twitter.com/oauth/authorize')

#cred$handshake(cainfo="cacert.pem")
#After this you will be redirected to a URL where you click on authorize app and get the passkey to be entered in RStudio


setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)