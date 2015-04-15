

import java.io.BufferedReader;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Properties;

import com.amazonaws.AmazonClientException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.PropertiesCredentials;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.simpledb.AmazonSimpleDBClient;
import com.amazonaws.services.simpledb.model.CreateDomainRequest;
import com.amazonaws.services.simpledb.model.DeleteDomainRequest;
import com.amazonaws.services.simpledb.model.PutAttributesRequest;
import com.amazonaws.services.simpledb.model.ReplaceableAttribute;


import twitter4j.FilterQuery;
import twitter4j.StallWarning;
import twitter4j.Status;
import twitter4j.StatusDeletionNotice;
import twitter4j.StatusListener;
import twitter4j.TwitterStream;
import twitter4j.TwitterStreamFactory;
import twitter4j.conf.ConfigurationBuilder;

public class TwitterGet2 {
	public static int Key_Size;
	public static String[] ConsumeKey;
	public static String[] ConsumerSecret;
	public static String[] AccessToken;
	public static String[] AccessTokenSecret;
	
	public static String[] keywords;
	public static int Query_Size;
	//public static ConfigurationBuilder cb = new ConfigurationBuilder();
	public static  AmazonSimpleDBClient sdb;
	public String myDomain = "twitterMapDB";
	public static String itemName ="0";
	
	/*
	 * Load configuration from config
	 */

	
	public static void main(String[] args) throws IOException, InterruptedException {
		
		
   	 ConfigurationBuilder cb = new ConfigurationBuilder();
     cb.setDebugEnabled(true)
       .setOAuthConsumerKey("")
       .setOAuthConsumerSecret("")
       .setOAuthAccessToken("")
       .setOAuthAccessTokenSecret("");
       
			
     AWSCredentials credentials = new BasicAWSCredentials("", "");
     sdb = new AmazonSimpleDBClient (credentials);
			
//	        AWSCredentials credentials = null;
//	        try {
//	            credentials = new ProfileCredentialsProvider("New Profile").getCredentials();
//	            sdb = new AmazonSimpleDBClient (credentials);
//	        } catch (Exception e) {
//	            throw new AmazonClientException(
//	                    "Cannot load the credentials from the credential profiles file. " +
//	                    "Please make sure that your credentials file is at the correct " +
//	                    "location (/Users/apple/.aws/credentials), and is in valid format.",
//	                    e);
//	        }
		
				Region usEast1 = Region.getRegion(Regions.US_EAST_1);
				sdb.setRegion(usEast1);
				
 
		StatusListener listener = new StatusListener(){
			String thisDate = "";
	        private int count = 0;
	        
			public  void onStatus(Status tweet) {
				DateFormat dateFormat = new SimpleDateFormat("MM-dd-yyyy");
				Date date = new Date(); 
			
				try{

					if(count == 0) {
						thisDate = dateFormat.format(date);
					}
					
					if (tweet.getGeoLocation() != null
	            			|| (tweet.getUser().getLocation() != null
	            			&& !tweet.getUser().getLocation().isEmpty())) {
	            		
						//Avoid in case Lat Long cannot be parsed 
						Double latitude = null ;
						Double longtitude = null;
						
		            	if (tweet.getGeoLocation() != null) {
			            	System.out.println("From GeoLocation:");
			            	latitude = tweet.getGeoLocation().getLatitude();
			            	longtitude = tweet.getGeoLocation().getLongitude();
		            	}            	
		            	ArrayList<String> list = new ArrayList<String>();
		            	list.add("Music");
		            	list.add("Spring");
		            	list.add("Movie");
		            	list.add("Sports");
		            	list.add("Food");
		            	String temp="";
		   
		            	
		            	if(!(latitude == null || longtitude == null || latitude.isNaN() || longtitude.isNaN()))
		            	{
			            	
			            	String textString = tweet.getText();
			            	String[] singleWord = textString.split("[\\p{Punct}, \\s]+");
			            	for (String word : singleWord) {
			            		if (word == null || word.length() == 0 ) {
			            			continue;
			            		}
			            		for (int i = 0; i<=4; i++){
			            			if (word.toLowerCase().equals(list.get(i).toLowerCase())){
			            				temp = list.get(i);
			            				break;
			            			}
			            				
			            		}
			            	}			            	
			            	
							 List<ReplaceableAttribute> list1 = new ArrayList<ReplaceableAttribute>();
								PutAttributesRequest putAttributesRequest = new PutAttributesRequest();
						        putAttributesRequest.setDomainName("twitterMapDB");
						        putAttributesRequest.setItemName(itemName);

								list1.add(new ReplaceableAttribute("user", tweet.getUser().getScreenName(), true));
					            list1.add(new ReplaceableAttribute("text", tweet.getText(), true));
					            list1.add(new ReplaceableAttribute("Date", thisDate, true));
					            list1.add(new ReplaceableAttribute("Latitude",latitude.toString() , true));
					            list1.add(new ReplaceableAttribute("Longitude", longtitude.toString(), true));
					            list1.add(new ReplaceableAttribute("keyword", temp.toString(),true));
					            
								putAttributesRequest.setAttributes(list1);
					            sdb.putAttributes(putAttributesRequest);
					            Integer k= Integer.parseInt(itemName)+1;
					            itemName=k.toString();
					            System.out.println(itemName);
			                             if (k%100 == 0) {
			            	    		Thread.sleep(1000*60);
			            		}
		            	}
            	}
				}catch(Exception e){
					e.printStackTrace();
				}
            }
			@Override
			public void onException(Exception ex) {
				ex.printStackTrace();
			}

			@Override
			public void onDeletionNotice(StatusDeletionNotice arg0) {}

			@Override
			public void onScrubGeo(long arg0, long arg1) {}

			@Override
			public void onStallWarning(StallWarning arg0) {}

			@Override
			public void onTrackLimitationNotice(int arg0) {}
	    };
	    
	    TwitterStream twitterStream = new TwitterStreamFactory(cb.build()).getInstance();
	    twitterStream.addListener(listener);
	    FilterQuery fil = new FilterQuery();
	    String[] keywords = {"Music", "Spring", "Movie", "Sports", "Food"};
	    fil.track(keywords);
	    twitterStream.filter(fil);
	}

}
