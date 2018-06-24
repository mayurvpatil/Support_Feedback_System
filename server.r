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



# Installing package if not already installed (Stanton 2013)
EnsurePackage<-function(x)
{x <- as.character(x)
 if (!require(x,character.only=TRUE))
 {
   install.packages(pkgs=x,repos="http://cran.r-project.org")
   require(x,character.only=TRUE)
 }
}

#Identifying packages required  (Stanton 2013)
PrepareTwitter<-function()
{
  EnsurePackage("twitteR")
  EnsurePackage("stringr")
  EnsurePackage("ROAuth")
  EnsurePackage("RCurl")
  EnsurePackage("ggplot2")
  EnsurePackage("reshape")
  EnsurePackage("tm")
  EnsurePackage("RJSONIO")
  EnsurePackage("wordcloud")
  EnsurePackage("gridExtra")
  #EnsurePackage("gplots") Not required... ggplot2 is used
  EnsurePackage("plyr")
  EnsurePackage("e1071")
  EnsurePackage("RTextTools")
}

PrepareTwitter()

data_frame <- data.frame()

shinyServer(function(input, output) {
  
  #Search tweets and create a data frame -Stanton (2013)
  # Clean the tweets
   TweetFrame<-function(twtList)
  {
      #print(twtList)
      df<- do.call("rbind",lapply(twtList,as.data.frame))
      #removes emoticons
	  df$text <- sapply(df$text,function(row) iconv(row, "latin1", "ASCII", sub=""))
	  df$text = gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", df$text)
      return (df$text)
   }
   
	# Function to create a data frame from tweets

	pos.words = scan('./Words/positive-words.txt', what='character', comment.char=';')
	neg.words = scan('./Words/negative-words.txt', what='character', comment.char=';')

	wordDatabase<-function()
	{
		pos.words<<-c(pos.words, 'Congrats', 'prizes', 'prize', 'thanks', 'thnx', 'Grt', 'gr8', 'plz', 'trending', 'recovering', 'brainstorm', 'leader', 'power', 'powerful', 'latest')
		neg.words<<-c(neg.words, 'Fight', 'fighting', 'wtf', 'arrest', 'no', 'not')
	}
	
	mergedata<- function(tweetsSceenName, result)
	{
	  fTable=data.frame(tweetsSceenName(), result())
	  return(fTable)
	}
	
	generateSearchString <-function(searchQuery)
	{
	 # print(tmptwtList<-searchTwitter(generateSearchString(), n=input$maxTweets, lang="en"))
	  searchQuery = input$organization;
	  searchQuery <- paste(searchQuery, input$products, sep = " AND ")
	  return(searchQuery)
	}
	
	
	mergeUserdata <-function(result, tweets)
	{
	  table_final=data.frame( tweeterscreenfortweets(tweets), result)
	  return(table_final)
	}

   score.sentiment <- function(sentences, pos.words, neg.words, .progress='none')
    {
	require(plyr)
	require(stringr)
	list=lapply(sentences, function(sentence, pos.words, neg.words)
	{
	  
		sentence = gsub('[[:punct:]]',' ',sentence)
		sentence = gsub('[[:cntrl:]]','',sentence)
		sentence = gsub('\\d+','',sentence)
		sentence = gsub('\n','',sentence)

		sentence = tolower(sentence)
		word.list = str_split(sentence, '\\s+')
		words = unlist(word.list)
		pos.matches = match(words, pos.words)
		neg.matches = match(words, neg.words)
		pos.matches = !is.na(pos.matches)
		neg.matches = !is.na(neg.matches)
		pp=sum(pos.matches)
		nn = sum(neg.matches)
		score = sum(pos.matches) - sum(neg.matches)
		list1=c(score, pp, nn)
		return (list1)
	}, pos.words, neg.words)
	score_new=lapply(list, `[[`, 1)
	pp1=score=lapply(list, `[[`, 2)
	nn1=score=lapply(list, `[[`, 3)
	
	scores.df = data.frame(score=score_new, text=sentences)
	positive.df = data.frame(Positive=pp1, text=sentences)
	negative.df = data.frame(Negative=nn1, text=sentences)

	list_df=list(scores.df, positive.df, negative.df)
	return(list_df)
    }

	#TABLE DATA	

 	library(reshape)
	sentimentAnalyser<-function(result)
	{
		#Creating a copy of result data frame
		test1=result[[1]]
		test2=result[[2]]
		test3=result[[3]]

		#Creating three different data frames for Score, Positive and Negative
		#Removing text column from data frame
		test1$text=NULL
		test2$text=NULL
		test3$text=NULL
		#Storing the first row(Containing the sentiment scores) in variable q
		q1=test1[1,]
		q2=test2[1,]
		q3=test3[1,]
		qq1=melt(q1, ,var='Score')
		qq2=melt(q2, ,var='Positive')
		qq3=melt(q3, ,var='Negative') 
		qq1['Score'] = NULL
		qq2['Positive'] = NULL
		qq3['Negative'] = NULL
		#Creating data frame
		table1 = data.frame(Text=result[[1]]$text, Score=qq1)
		table2 = data.frame(Text=result[[2]]$text, Score=qq2)
		table3 = data.frame(Text=result[[3]]$text, Score=qq3)
	
		#Merging three data frames into one
		table_final=data.frame(Text=table1$Text, Positive=table2$value, Negative=table3$value, Score=table1$value)
		return(table_final)
     }

	percentage<-function(table_final)
	{
		#Positive Percentage

		#Renaming
		posSc=table_final$Positive
		negSc=table_final$Negative

		#Adding column
		table_final$PosPercent = posSc/ (posSc+negSc)

		#Replacing Nan with zero
		pp = table_final$PosPercent
		pp[is.nan(pp)] <- 0
		table_final$PosPercent = pp*100

		#Negative Percentage

		#Adding column
		table_final$NegPercent = negSc/ (posSc+negSc)

		#Replacing Nan with zero
		nn = table_final$NegPercent
		nn[is.nan(nn)] <- 0
		table_final$NegPercent = nn*100

		return(table_final)
	}
	
	wordDatabase()
	
	twtList<-reactive({tmptwtList<-searchTwitter(generateSearchString(), n=input$maxTweets, lang="en") })

	tweets<-reactive({tweets<-TweetFrame(strip_retweets(twtList()) )})
	
	result<-reactive({result<-score.sentiment(tweets(), pos.words, neg.words, .progress='none')})

	table_final<-reactive({table_final<-sentimentAnalyser(result())})
	
	table_final_percentage<-reactive({table_final_percentage<-percentage(  table_final() )})

	final_result<-reactive({final_result<-mergeUserdata( table_final_percentage(),  strip_retweets(twtList()) )})
	
  output$tabledata<-renderTable(final_result(),options = list(lengthMenu = c(10, 30, 50), pageLength = 5))	
  
	#WORDCLOUD
	wordclouds<-function(text)
	{
		library(tm)
		library(wordcloud)
		corpus <- Corpus(VectorSource(text))
		#clean text
		clean_text <- tm_map(corpus, removePunctuation)
		#clean_text <- tm_map(clean_text, content_transformation)
		clean_text <- tm_map(clean_text, content_transformer(tolower))
		clean_text <- tm_map(clean_text, removeWords, stopwords("english"))
		clean_text <- tm_map(clean_text, removeNumbers)
		clean_text <- tm_map(clean_text, stripWhitespace)
		return (clean_text)
	}
	text_word<-reactive({text_word<-wordclouds( tweets() )})
	
	output$word <- renderPlot({ wordcloud(text_word(),random.order=F,max.words=80, col=rainbow(100), scale=c(4.5, 1)) })

	#HISTOGRAM
	output$histPos<- renderPlot({ hist(table_final()$Positive, col=rainbow(10), main="Histogram of Positive Sentiment", xlab = "Positive Score") })
	output$histNeg<- renderPlot({ hist(table_final()$Negative, col=rainbow(10), main="Histogram of Negative Sentiment", xlab = "Negative Score") })
	output$histScore<- renderPlot({ hist(table_final()$Score, col=rainbow(10), main="Histogram of Score Sentiment", xlab = "Overall Score") })	

	#Pie
	slices <- reactive ({ slices <- c(sum(table_final()$Positive), sum(table_final()$Negative)) })
	labels <- c("Positive", "Negative")
	library(plotrix)
	output$piechart <- renderPlot({ pie3D(slices(), labels = labels, col=rainbow(length(labels)),explode=0.00, main="Sentiment Analysis") })

	
	trend_table<-reactive({ trend_table<-toptrends(input$trendingTable) })
	output$trendtable <- renderTable(trend_table())

	#TOP TWEETERS

	# Top tweeters for a particular hashtag (Barplot)
	toptweeters<-function(tweetlist)
	{
		tweets <- twListToDF(tweetlist)
		tweets <- unique(tweets)
		# Make a table of the number of tweets per user
		d <- as.data.frame(table(tweets$screenName)) 
		d <- d[order(d$Freq, decreasing=T), ] #descending order of tweeters according to frequency of tweets
		names(d) <- c("User","Tweets")
		print(d)
		return (d)
	}
	
	tweeterscreen<-function(tweetlist)
	{
	  tweets <- twListToDF(tweetlist)
	  #tweets <- unique(tweets)
	  # Make a table of the number of tweets per user
	  d <- as.data.frame(table(tweets$screenName)) 
	  d <- d[order(d$Freq, decreasing=T), ] #descending order of tweeters according to frequency of tweets
	  names(d) <- c("User","Tweets")
	  return (d)
	}
	
	tweeterscreenfortweets<-function(tweetlist)
	{
	  tweets <- twListToDF(tweetlist)
	  #tweets <- unique(tweets)
	  # Make a table of the number of tweets per user
	  d <- as.data.frame(table(tweets$screenName)) 
	 d <- d[order(d$Freq, decreasing=T), ] #descending order of tweeters according to frequency of tweets
	 names(d) <- c("User","Tweets")
	  return (d)
	}
	
	# Plot the table above for the top 20

	d<-reactive({d<-toptweeters(  twtList() ) })
	output$tweetersplot<-renderPlot ( barplot(head(d()$Tweets, 20), names=head(d()$User, 20), horiz=F, las=2, main="Top Tweeters", col=1) )
	output$tweeterstable<-renderTable(head(d(),20))
	
	#TOP 10 HASHTAGS OF USER

	tw1 <- reactive({ tw1 = userTimeline(input$user, n = 3200) })
	tw <- reactive({ tw = twListToDF(tw1()) })
	vec1<-reactive ({ vec1 = tw()$text })
 
	extract.hashes = function(vec){
 	
		hash.pattern = "#[[:alpha:]]+"
		have.hash = grep(x = vec, pattern = hash.pattern)
 
		hash.matches = gregexpr(pattern = hash.pattern,
                        text = vec[have.hash])
		extracted.hash = regmatches(x = vec[have.hash], m = hash.matches)
 
		df = data.frame(table(tolower(unlist(extracted.hash))))
		colnames(df) = c("tag","freq")
		df = df[order(df$freq,decreasing = TRUE),]
		return(df)
	}
 
	dat<-reactive({ dat = head(extract.hashes(vec1()),50) })
	dat2<- reactive ({ dat2 = transform(dat(),tag = reorder(tag,freq)) })

	p<- reactive ({ p = ggplot(dat2(), aes(x = tag, y = freq)) + geom_bar(stat="identity", fill = "black")
	p + coord_flip() + labs(title = "Hashtag frequencies in the tweets of the tweeter") })
	output$tophashtagsplot <- renderPlot ({ p() })	
}) #shiny server

