import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.FitContributor;
import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Timer;
import Toybox.Lang;
import Toybox.System;

const GAME_FIELD_ID = 0;
const GAME_NAME_LEN = 50 ; // MAX 256
var gameField;

var session = null;
var timerPostHR;
var timerGetGame;

var appStatus="Waiting";
var gameName="No Game";
var currentHR=0;

class eSportAppDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new eSportAppMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

	function onSelect() {
	   if (Toybox has :ActivityRecording) {                          // check device for activity recording
	       if ((session == null) || (session.isRecording() == false)) {
	           session = ActivityRecording.createSession({          // set up recording session
	                 :name=>"Generic",                              // set session name
	                 :sport=>Activity.SPORT_GENERIC,       // set sport type
	                 :subSport=>Activity.SUB_SPORT_GENERIC // set sub sport type
	           });
	           gameField = session.createField("Game", GAME_FIELD_ID, FitContributor.DATA_TYPE_STRING, {:count=>GAME_NAME_LEN,:mesgType=>FitContributor.MESG_TYPE_SESSION});
	           session.start();                                     // call start session
	           appStatus="Started";
	           System.println("Started");
	           WatchUi.requestUpdate();
	        //    makeGameRequest();
	        //    timerGetGame.start(method(:makeGameRequest), 50000, true);
	           timerPostHR.start(method(:makeHRRequest), 500, true);
	       }
	       else if ((session != null) && session.isRecording()) {
	           gameField.setData(gameName.substring(0, GAME_NAME_LEN));
	           session.stop();
	           appStatus="Stopped";
	           System.println("Stopped");
	           session.save();
	           session = null;
	           gameName = "No Game";
	           WatchUi.requestUpdate();
	        //    timerGetGame.stop();
	           timerPostHR.stop();
	       }
	   }
	   return true;
	}
	
	function onHRReceive(responseCode as Number, data as Dictionary?) as Void {
	    if (responseCode == 200) {
	        System.println(data);
	    } else {
	        System.println("Failed to load\nError: " + responseCode.toString());
	    }
	    WatchUi.requestUpdate();
	}

	function makeHRRequest() {
		var url = "http://localhost:90/add_heart_rate.php";
		var params = {
            "heart_rate" => currentHR
       };

       var options = {
           :method => Communications.HTTP_REQUEST_METHOD_POST,
           :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED },
           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
       };
       Communications.makeWebRequest(url, params, options,  method(:onHRReceive));
	}
	

	
	// function makeGameRequest() {
	// 	var url = "https://zrenard.com/esport.php";
	// 	var params = {
    //           "a" => "get"
    //    };

    //    var options = {
    //        :method => Communications.HTTP_REQUEST_METHOD_POST,
    //        :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED },
    //        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    //    };
       
    //    Communications.makeWebRequest(url, params, options, method(:onGameReceive));
	// }
	
	// function onGameReceive(responseCode, data) {
	//     if (responseCode == 200) {
	//         System.println(data);
	//         gameName = data["game"];
	//     } else {
	//         gameName = "No Game";
	//         System.println("Failed to load\nError: " + responseCode.toString());
	//     }
	//     WatchUi.requestUpdate();
	// }
}

class eSportAppView extends WatchUi.View {	
    function initialize() {
        View.initialize();
        timerPostHR = new Timer.Timer();
        // timerGetGame = new Timer.Timer();
    }

    function onLayout(dc) {
    }
    
    function onShow() {
    	//timer.start(method(:onTimer), 1000, true);
    	//timerGame.start(method(:makeGameRequest), 30000, true);
    }
    
    function onHide() {
    	timerPostHR.stop();
    	// timerGetGame.stop();
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
       
        var width = dc.getWidth();
    	var height = dc.getHeight();
		var color;
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);
        dc.clear();
        // dc.drawText( (width / 2), (height/4), Graphics.FONT_LARGE,gameName, Graphics.TEXT_JUSTIFY_CENTER);
        currentHR = Activity.getActivityInfo().currentHeartRate;
        if (currentHR!=null) {
			
			if (currentHR < 100) {
				color = Graphics.COLOR_BLUE; // Zone 1: Very Light
			} else if (currentHR >= 100 && currentHR < 118) {
				color = Graphics.COLOR_GREEN; // Zone 2: Light
			} else if (currentHR >= 118 && currentHR < 134) {
				color = Graphics.COLOR_YELLOW; // Zone 3: Moderate
			} else if (currentHR >= 134 && currentHR < 151) {
				color = Graphics.COLOR_ORANGE; // Zone 4: Hard
			} else {
				color = Graphics.COLOR_RED; // Zone 5: Maximum
			}
			dc.setColor(color,Graphics.COLOR_BLACK);
        	dc.drawText( (width / 2), (height/4), Graphics.FONT_SYSTEM_NUMBER_THAI_HOT,currentHR, Graphics.TEXT_JUSTIFY_CENTER);
 			dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);
        } else {
			dc.drawText( (width / 2), (height/4), Graphics.FONT_SYSTEM_NUMBER_THAI_HOT,"No HR", Graphics.TEXT_JUSTIFY_CENTER);
		}
        dc.drawText( (width / 2), (height/4)*3, Graphics.FONT_LARGE,appStatus, Graphics.TEXT_JUSTIFY_CENTER);
    }
	
}
