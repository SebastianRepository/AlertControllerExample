//
//  Time.swift
//  sms
//
//  Created by Sebastian on 07.05.15.
//  Copyright (c) 2015 Sebastian Frederik Sattler. All rights reserved.
//

import Foundation

/* TimeDate sets the application's default time zone to GMT.
It can return a date string (CURRENTLY GERMAN VERSION ONLY),
and the current UTC and LT as NSDate.
The latter can be used without creating a class instance.*/

internal class TimeDate {
    
    private let GMT = NSTimeZone(forSecondsFromGMT: 0)
    private let dateFormatter = NSDateFormatter()

    init() {
    
        NSTimeZone.setDefaultTimeZone(GMT)
    }
    
    internal func dateString(date date: NSDate) -> String {
        
        self.dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        self.dateFormatter.dateFormat = "dd.MM.yyyy"                    //currently supporting the German version only
        return self.dateFormatter.stringFromDate(date)
    }
    
    internal func timeDateString(timeDate timeDate: NSDate) -> String {
        
        self.dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        self.dateFormatter.dateFormat = "dd.MM.yyyy '-' HH:mm:ss' (GMT)'"                    //currently supporting the German version only
        return self.dateFormatter.stringFromDate(timeDate)
    }
	
	internal func stringToDate(str: String) -> NSDate? {
		
		self.dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        self.dateFormatter.dateFormat = "dd.MM.yyyy"                    //currently supporting the German version only
        return self.dateFormatter.dateFromString(str)
	}
	
	internal func stringToTimeDate(str: String) -> NSDate? {
		
		self.dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        self.dateFormatter.dateFormat = "dd.MM.yyyy '-' HH:mm:ss' (GMT)'"                  //currently supporting the German version only
        return self.dateFormatter.dateFromString(str)
	}
    
    internal func currentUTC() -> NSDate {
    
        return NSDate(timeIntervalSinceNow: 0)
    }
    
    internal func currentLT() -> NSDate {
        
        let currentLocalTimeZone = NSTimeZone.systemTimeZone()
        
        var timeDifference = NSTimeInterval()
        timeDifference = Double(currentLocalTimeZone.secondsFromGMT)
        
        return NSDate(timeIntervalSinceNow: timeDifference)
    }
	
	//Sets the time in an NSDate object to 00:00:00 (12AM), German version
	internal func timeDateTo12AM(timeDate timeDate: NSDate) -> NSDate{
	
		let calendar = NSCalendar(calendarIdentifier:  NSCalendarIdentifierGregorian)!
        
        let flags: NSCalendarUnit = [.Day, .Month, .Year] //bitwise OR
        let components: NSDateComponents = calendar.components(flags, fromDate: timeDate)

        return calendar.dateFromComponents(components)! //OK to force-unwrap as the current date and its components are gathered from the syste
	}
    
    internal func today() -> NSDate { //Reports today's date, time 00:00:00 (12AM) (LOCAL TIME), German version

        let currentTimeDate = self.currentLT()
		return timeDateTo12AM(timeDate: currentTimeDate)
    }
	
	internal func tomorrow() -> NSDate {//Reports tomorrows's date, time 00:00:00 (12AM) (LOCAL TIME), German version

        let currentDate = self.today()
		var timeDifference = NSTimeInterval()
        timeDifference = 24.0 * 60.0 * 60.0
		
		let date24hFromCurrentDate = NSDate(timeInterval: timeDifference, sinceDate: currentDate)
	
        return timeDateTo12AM(timeDate: date24hFromCurrentDate)
	}
}