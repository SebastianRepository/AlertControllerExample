//
//  Utilities.swift
//  sms
//
//  Created by Sebastian on 30.07.15.
//  Copyright (c) 2015 Sebastian Frederik Sattler. All rights reserved.
//

import Foundation
import CoreData




class Utilities {
	
		
		
	/*Transfers a file from the bundle's (e.g. the 'App data' folder visible in XCode) to the application's document folder in the device's file system.
	E.g. copy an sqlite file from the Mac to the iPad while testing the app;
	FileExtension must not contain the dot.*/
	class func portFileFromBundleToDocsDir(filename: String, extensionWithoutDot: String, removeExistingFile: Bool) {
	
		let appBundle = NSBundle.mainBundle()
		let dirPath = applicationDocumentsDirectory().path
		let filePath = appBundle.URLForResource(filename, withExtension: extensionWithoutDot)?.path
		
		if dirPath != nil && filePath != nil {
		
			let targetPath = dirPath! + "/" + filename + "." + extensionWithoutDot
			
			let fileManager = NSFileManager()
			var error: NSError?
		
			do {
				try fileManager.createDirectoryAtPath(dirPath!, withIntermediateDirectories: false, attributes: nil)
			} catch let error1 as NSError {
				error = error1
			}
			
			if error != nil {
				// % ERROR HANDLING %
				
				print("Directory error:\n\(error!)")
			}
			error = nil
		
			
			if removeExistingFile {
			
				do {
					try fileManager.removeItemAtPath(targetPath)
				} catch let error1 as NSError {
					error = error1
				}
			}
			
			if error != nil {
				// % ERROR HANDLING %
				
				print("Removal error:\n\(error!)")
			}
			error = nil
			
			do {
				try fileManager.copyItemAtPath(filePath!, toPath: targetPath)
			} catch let error1 as NSError {
				error = error1
			}
		
			if error != nil {
				// % ERROR HANDLING %
				
				print("Copy error:\n\(error!)")
			}
		} else {
				// % ERROR HANDLING %
		}
	}
	
	//Delete a file from the documents directory (e.g. the database file)
	class func deleteFileFromDocDir(filename: String, extensionWithoutDot: String) {

		let dirPath = applicationDocumentsDirectory().path
		
		if dirPath != nil {
		
			let targetPath = dirPath! + "/" + filename + "." + extensionWithoutDot
			
			let fileManager = NSFileManager()
			var error: NSError?
			
			do {
				try fileManager.removeItemAtPath(targetPath)
			} catch let error1 as NSError {
				error = error1
			}
			
			if error != nil {
				// % ERROR HANDLING %
				
				print("Removal error:\n\(error!)")
			}
			
		} else {
				// % ERROR HANDLING %
		}
	}
	
	
	//JSON IMPORT variables
	
	static var JSONimportDir = [String : [NSManagedObject]]()	//entityName : NSManagedObjects
	static var JSONfilenameDir = [String: String]()		//entityName : filename ;
	
	class func emptyImportJSONdirectories() {
		
		self.JSONimportDir = [:] 
		self.JSONfilenameDir = [:]
	}
	
	class func addImportFilename(filenameWithoutExtension: String, entityName: String) {
	
		self.JSONfilenameDir.updateValue(filenameWithoutExtension, forKey: entityName)
	}
	
	//Imports all JSON files registerd in the JSONfilenameDir
	class func importAllJSONSeedData(context context: NSManagedObjectContext, model: NSManagedObjectModel) {
	
		self.JSONimportDir = [:]
		
		for (filename, entityName) in JSONfilenameDir {
		
			self.importJSONSeedData(filename, filenameExtensionWithoutDot: "json", entityName: entityName, arrayName: entityName, context: context, model: model)
		}
		
		do {
			try context.save()
		} catch _ {
		}
	}
	
	//Imports seed data in JSON format. Flexible use with any entity in the specified model; IMPORTANT: imports only values for attributes; does not import relationships
	class func importJSONSeedData(jsonFilenameWithoutExtension: String, filenameExtensionWithoutDot ext: String, entityName: String, arrayName: String, context: NSManagedObjectContext, model: NSManagedObjectModel) {
	
		let jsonURL = NSBundle.mainBundle().URLForResource(jsonFilenameWithoutExtension, withExtension: ext)
		let jsonData = NSData(contentsOfURL: jsonURL!)
		let jsonDict = (try! NSJSONSerialization.JSONObjectWithData(jsonData!, options: [])) as! NSDictionary
		let timer = TimeDate()
		
		//Make sure the entity exists:
		var entityExists = false
		
		for entityDescription in model.entities {
		
			if let name = (entityDescription ).name {
			
				if entityName == name {
				
					entityExists = true
					break
				}
			}
		}
		
		if !entityExists {

			print("SMS error in json import: entity does not exist in model")
			
		} else {
		
			//Specify the entity for the managed objects to be created
			if let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context) {
				
				let attributes: NSDictionary = entity.attributesByName
				var managedObjects = [NSManagedObject]()
			
				//Loop through the attribute values given for this entity in the json file
				let jsonArray = jsonDict.valueForKeyPath(arrayName) as! NSArray  //arrayName is the name of the array for this entity as given in the json file
				
				for jsonDictionary in jsonArray {
				
					//Put the newly created managed object into the managed object context
					let managedObject = NSManagedObject(entity: entity, insertIntoManagedObjectContext: context)

					//Loop through the attributes and try to read a value for each; assign the value to the newly created object
					for attribute in attributes {
						
						let attributeKey = attribute.key as! String
						var attributeValue: AnyObject?
												
						//Look whether the attribute's key contains the term "date" -> convert the read value to date
						if attributeKey.rangeOfString("Date") != nil || attributeKey.rangeOfString("date") != nil {
								
							if let str = jsonDictionary[attributeKey] as? String { //Without this check for nil, the app will crash if the JSON file does not contain the attribute key
								attributeValue = timer.stringToDate(str)!
							}
		
						} else {
						
							attributeValue = jsonDictionary[attributeKey]
						}
						
						managedObject.setValue(attributeValue, forKey: attributeKey)
					}
					
					managedObjects.append(managedObject)
				
				}
					
				//Register the entity's import
				self.JSONimportDir.updateValue(managedObjects, forKey: entityName)
			
			} else {
			
				print("SMS error in json import: failed to define entity")
			}
		}
	}
	
	
	/*Relationship setter method for 'manual' use with objects & entities already imported to JSONimportDir; 
	assumption: all to-many relationships are ordered.
	Example: entityName: "Personnel", relationshipName: "qualifications", 
	sourceIndex: 0 for index zero of the JSONimportDir's managed object of entity "Personnel", 
	targetIndexes: 0, 1 for linking "Personnel" object 0 with "Qualification" objects 0 and 1. 
	IMPORTANT: make sure you store the context after all relationships are set as desired.*/
	class func setRelationshipForJSONSeedData(entityName: String, relationshipName: String, sourceIndex: Int, targetIndexes: [Int], context: NSManagedObjectContext) {
	
		//Check entity is imported and relationship exists:
		var entityImported = false
		for (dirEntityName, _) in self.JSONimportDir {
				
			if dirEntityName == entityName {
					
				entityImported = true
				break
			}
		}
		
		if entityImported {
			
			if let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context) {
				
				let relationships: NSDictionary = entity.relationshipsByName
				var toMany = false
				//Check relationship exists and whether it is to-one or to-many
				for relationship in relationships {
					
					let relationshipKey = relationship.key as! String
					let relationshipTarget = relationship.value.destinationEntity!!.name!
					
					if relationshipKey == relationshipName {
						
						if (relationship.value as! NSRelationshipDescription).toMany {
						
							toMany = true
						}
						
						var targetObjects: Array<NSManagedObject> = []
						
						switch toMany {
							case true:
								//Create ordered set with target objects
								
								for var i = 0; i < targetIndexes.count; i++ {
								
									if let importedObjects = self.JSONimportDir[relationshipTarget] {
										targetObjects.append(importedObjects[targetIndexes[i]])
									}
								}
							
								//Append set to the entity's (described by entityName) object with index 'sourceIndex'
								let managedObject = self.JSONimportDir[entityName]![sourceIndex]  //'!' OK because import check has been done above

								let mySet = managedObject.valueForKey(relationshipKey)!.mutableCopy() as! NSMutableOrderedSet
								mySet.addObjectsFromArray(targetObjects)
								managedObject.setValue(mySet.copy() as! NSOrderedSet, forKey: relationshipKey)
							
							case false:
								//Take only the index of the targetIndexes array (there shouldn't be more than one anyway) and connect it with the entity
								if let importedObjects = self.JSONimportDir[relationshipTarget] {
									targetObjects.append(importedObjects[targetIndexes[0]])
								}
							
								//Append the object to the entity's (described by entityName) object with index 'sourceIndex'
								let managedObject = self.JSONimportDir[entityName]![sourceIndex]  //'!' OK because import check has been done above
								managedObject.setValue(targetObjects[0], forKey: relationshipKey)
						}
					
						break
					}
				}
			}
		}
	}
}