using Toybox.WatchUi;
using Toybox.ActivityRecording;
var session = null;

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
	                 :sport=>ActivityRecording.SPORT_GENERIC,       // set sport type
	                 :subSport=>ActivityRecording.SUB_SPORT_GENERIC // set sub sport type
	           });
	           session.start();                                     // call start session
	           changeAppStatus("Started");
	           System.println("Started");
	           
	       }
	       else if ((session != null) && session.isRecording()) {
	           session.stop();                                      // stop the session
	           changeAppStatus("Stopped");
	           System.println("Stopped");
	           session.save();                                      // save the session
	           session = null;                                      // set session control variable to null
	       }
	   }
	   return true;                                                 // return true for onSelect function
	}

}