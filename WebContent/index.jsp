<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page 
		import = "java.io.*,java.util.*" 
		import = "java.util.Date"
		import = "java.text.DateFormat"
		import = "java.text.SimpleDateFormat"
		import = "java.util.concurrent.ConcurrentHashMap"
		import = "com.amazonaws.services.simpledb.model.Item"
		import = "com.amazonaws.services.simpledb.model.Attribute"
		import ="java.io.BufferedReader"
		import ="java.io.FileInputStream"
		import = "java.io.FileNotFoundException"
		import ="java.io.IOException"
		import = "java.io.InputStreamReader"
		import = "java.io.UnsupportedEncodingException"
		import ="java.net.HttpURLConnection"
		import = "java.net.URL"
		import = "java.text.ParseException"
		import = "java.text.SimpleDateFormat"
		import = "java.util.ArrayList"
		import = "java.util.Date"
		import  = "com.amazonaws.auth.AWSCredentials"
		import = "com.amazonaws.auth.PropertiesCredentials"
		import = "com.amazonaws.regions.Region"
		import = "com.amazonaws.regions.Regions"
		import = "com.amazonaws.services.simpledb.AmazonSimpleDBClient"
		import = "com.amazonaws.services.simpledb.model.SelectRequest"
		import = "com.amazonaws.services.simpledb.model.SelectResult"
		import = "com.amazonaws.AmazonClientException"
		import = "com.amazonaws.auth.profile.ProfileCredentialsProvider"
		import ="java.util.List"
		import = "java.util.Properties"
		import = "javax.swing.text.html.parser.Entity"
		import ="org.json.JSONArray"
		import ="org.json.JSONException"
		import ="org.json.JSONObject"
		import ="com.amazonaws.auth.BasicAWSCredentials"
		import ="org.omg.CORBA.portable.InputStream"
%>



<%!//record the number of item in the datastore
		public static boolean refreshAPI = true;
		public static ConcurrentHashMap<String,Integer> time_index = new ConcurrentHashMap<String,Integer>();
		public static ConcurrentHashMap<String,Boolean> time_finished = new ConcurrentHashMap<String,Boolean>();
		public static String Today;
		public static boolean init = true;%>
<%

		response.setIntHeader("Refresh", 60);  		
		/*
		TimeLine;
	Get a list of dates for timeline
		*/
		SimpleDateFormat dateFormat = new SimpleDateFormat("MM-dd-yyyy");
		String todayDate = dateFormat.format(new Date());
		ArrayList<String> dates = new ArrayList<String>();
		Calendar cal = Calendar.getInstance();
		int today = cal.get(Calendar.DATE);
		if(!todayDate.equals(Today)){
			Today = todayDate;
			time_index.put(Today,0);
			time_finished.put(Today,false);
			refreshAPI = true;
		}
		else{
	refreshAPI = false;
		}

		System.out.println("******************START******************");
		init = false;
		//By default
		String timeline = Today;
		String keyword = "All";

		String K = request.getParameter("keyword");
		System.out.println(K);
		//System.out.println(T);
		if( K != null)
		{
			//timeline = T;
			keyword = K;
		}

        AWSCredentials credentials = null;
        AmazonSimpleDBClient newDb = null;
/*         try {
            credentials = new ProfileCredentialsProvider("New Profile").getCredentials();
            newDb = new AmazonSimpleDBClient(credentials);
        } catch (Exception e) {
            throw new AmazonClientException(
                    "Cannot load the credentials from the credential profiles file. " +
                    "Please make sure that your credentials file is at the correct " +
                    "location (/Users/apple/.aws/credentials), and is in valid format.",
                    e);
        } */
        credentials = new BasicAWSCredentials("AKIAJTI27NFKTTZPNDJA", "hyGbwLUU7JAATzXZFKM6ZVK2K+m0S4Rp85W1UYGE");
        newDb = new AmazonSimpleDBClient (credentials);
	   
		//sdb = new AmazonSimpleDBClient(credentials);
        
        
        SelectResult selectResult = null;
        SelectResult selectResult1 = null;
        SelectResult selectResult2 = null;
        String query = null; 
        String query1 = null; 
        String query2 = null;  
        List<Item> list = null;
        List<Item> list1 = null;
        List<Item> list2 = null;
        int countt = 0;
 	   if (keyword.equals("All")) {
 		  
 		  String nextToken = null;
 	 		//  int domainCount = newDb.domainMetadata();
 	 		 boolean enough = true;
 	 		query2 = "select Latitude, Longitude, keyword from " + "twitterMapDB" + " where Date = '" + timeline + "' LIMIT 100";
 	        SelectRequest selectRequest2 = new SelectRequest(query2);
 	        selectResult2 = newDb.select(selectRequest2);
 	        list2 = selectResult2.getItems();
 	        if (list2.size() < 100){
 	        	enough = false;
 	        }
 	         while(enough){

 	        query1 = "select Latitude, Longitude, keyword from " + "twitterMapDB" + " where Date = '" + timeline + "' LIMIT 100";
 	        SelectRequest selectRequest1 = new SelectRequest(query1);
 	        selectResult1 = newDb.select(selectRequest1);
 	        list1 = selectResult1.getItems();
 	        if (list1.size() < 100){
 	        	enough = false;
 	        }
 	        list2.addAll(list1);
 	        nextToken = selectResult1.getNextToken();

 	        }
 	         list = list2;
 	   } else {
	 		String nextToken = null;
	 		boolean flag = true;
	 		query2 = "select Latitude, Longitude, keyword from " + "twitterMapDB" + " where keyword = '" + keyword + "' and Date = '" + timeline + "' LIMIT 100";
	        SelectRequest selectRequest2 = new SelectRequest(query2);
	        selectResult2 = newDb.select(selectRequest2);
	        list2 = selectResult2.getItems();
	        if (list2.size() < 100){
	        	flag = false;
	        }
	         while(flag){
	
	        query1 = "select Latitude, Longitude, keyword from " + "twitterMapDB" + " where keyword = '" + keyword + "' and Date = '" + timeline + "' LIMIT 100";
	        SelectRequest selectRequest1 = new SelectRequest(query1);
	        selectResult1 = newDb.select(selectRequest1);
	        list1 = selectResult1.getItems();
	        if (list1.size() < 100){
	        	flag = false;
	        }
	        list2.addAll(list1);
	        nextToken = selectResult1.getNextToken();
	
	         }
	         list = list2;
 	   }
	  
		
  		// Get a list of predefined keyword
  		ArrayList<String> dropdownList = new ArrayList<String>();
  		//add ALL keywords
  		dropdownList.add("All");
  		dropdownList.add("Music");
  		dropdownList.add("Spring");
  		dropdownList.add("Movie");
  		dropdownList.add("Sports");
  		dropdownList.add("Food");
%>

<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title>TwitterHeatMap</title>
<!-- External CSS -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="css/bootstrap.css">
<link rel="stylesheet" type="text/css" href="css/style.css" />
<!-- External script -->
<script
	src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&libraries=visualization"></script>
<script type="text/javascript" src="js/markercluster.js"></script>
<script
	src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
<script src="js/bootstrap.js"></script>
<script>
	    	
    </script>
<script>
   	/*  
    * Parse the location 
    * return the latlng data
    */ 
   
   	
	function ParseLocation()
    {
    	Location = new Array();
    	
		<%
	

			
			for(Item item : list) {
		
						
        	countt++;	
        	System.out.println("====!!!!========="+item.getAttributes().get(1).getValue());
        	System.out.println("====!!!!========="+item.getAttributes().get(2).getValue());
        					Double latitude = null;
        					Double longitude = null;
							latitude = Double.parseDouble(item.getAttributes().get(1).getValue());
							longitude = Double.parseDouble(item.getAttributes().get(2).getValue());
				%>
							Location.push(new google.maps.LatLng(<%=latitude%>, <%=longitude%>));
				<%
        	}
		 System.out.println(countt);
				%>
							<%-- var address = "<%=address%>";
					    	var jsonResult = LocationGet(address);
					        var LatLng = JSON.parse(jsonResult);
					        if(LatLng.status == google.maps.GeocoderStatus.OK)
					        {
					        	Location.push(new google.maps.LatLng(LatLng.results[0].geometry.location.lat, LatLng.results[0].geometry.location.lng));
					        }
				<%	 --%>
						/*  }
					}
			}
		} */
	//	%>
		return Location;
	}
   	
	
	


    

     </script>
<script src="js/GoogleMapAPI.js"></script>
</head>

<body>
	<div id="sidebar" style="text-align:center; height: 70px">
		<!-- Logo -->
		<h2 id="logo" >
			<a href="#">Twitter Heat Map</a>
		</h2>

		<div class="btn-group" role="group" aria-label="...">
  		<button type="button" style="margin-left: 5px" class="btn btn-default" onclick="hide()">HeatMap</button>
 		<button type="button" style="margin-left: 5px" class="btn btn-default" onclick="removeM()">Pins</button>
 		<button type="button" style="margin-left: 5px" class="btn btn-default dropdown-toggle" data-toggle="dropdown"> KeyWord<span class=" caret"></span> 
			</button>
			<ul class="dropdown-menu" style="margin-left: 40px"role="menu" aria-labelledby="dropdownMenu1">
				<li class="disabled"><a href="#"></a></li>
				<li class="divider"></li>
				<%
					for (String word : dropdownList) {
						if (!word.equalsIgnoreCase(keyword)) {
				%>
				<li><a
					href="index.jsp?keyword=<%=word%>"><%=word%></a></li>
				<%
					}
					}
				%>
			</ul>
		</div>
		<div id="but">

	</div>
		<div class ="dropdown" id="but">

			
		</div>
		
	
	</div>
	
	<div style="background-color: white">
		<br>
		<div style="padding-top: 5px" id="map-canvas"></div>
	</div>
</body>
</html>
