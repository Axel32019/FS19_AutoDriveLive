# FS19_AutoDriveLive
Implementation of Dijkstra's algorithm for FS19_AutoDrive as Live route calculation

Hintergrund / Vorgeschichte: https://github.com/Stephan-S/FS19_AutoDrive/issues/721

Aktuelle Version: V 0.0.0.6

Anleitung
1. Wer (noch) nicht weiss wie Mods zu verändern sind, siehe Google, Youtube etc.
	
2. FS19_AutoDrive Mod in einen Ordner entpacken
3. Datei AutoDriveDijkstraLive.lua in Unter-Ordner "scripts" kopieren
4. In Datei "AutoDrive.lua" Funktion "function AutoDrive:loadMap(name)" hinzufügen:
    source(Utils.getFilename("scripts/AutoDriveDijkstraLive.lua", AutoDrive.directory))
    
    am sichersten nach allen vorhandenen AD-Dateien
5. In Datei "AutoDriveGraphHandling.lua" die Funktion "function AutoDrive:FastShortestPath(Graph, start, markerName, markerID)" auskommentieren / löschen:

	--[[
  
	function AutoDrive:FastShortestPath(Graph, start, markerName, markerID)
  
	...
  
	end
  
	]]
	
	NEU:
	In Funktion AutoDrive:getDriveTimeBetweenNodes am Ende
	
	return driveTime
	
	ersetzen durch:
	
	return driveTime, angle
  
6. Mod packen und ab in den LS-Mod-Ordner
7. Ausprobieren

Änderungen V 0.0.0.6
- Fix #6 - Berücksichtigung der AD Einstellungen korrigiert

Änderungen V 0.0.0.5
- Fix #4 - Strecke nicht mehr befahrbar, ohne Live funktioniert es

Änderungen V 0.0.0.4:
- Winkelberechnung komplett berücksichtigt
- Anwendung der Einstellung useFastestRoute korrigiert


Installation
1. If you are not familiar with editing Mods please ask: Google, Youtube etc.
	
2. uncompress FS19_AutoDrive Mod to a folder
3. copy file AutoDriveDijkstraLive.lua to sub-folder "scripts" 
4. Edit file "AutoDrive.lua" function "function AutoDrive:loadMap(name)" add this line underneath existing lines:
	source(Utils.getFilename("scripts/AutoDriveDijkstraLive.lua", AutoDrive.directory))
5. In file "AutoDriveGraphHandling.lua" deactivate function "function AutoDrive:FastShortestPath(Graph, start, markerName, markerID)" with a comment:

	--[[
  
	function AutoDrive:FastShortestPath(Graph, start, markerName, markerID)
  
	...
  
	end
  
	]]

	NEW:
	In Function AutoDrive:getDriveTimeBetweenNodes at the end replace
	
	return driveTime
	
	with:
	
	return driveTime, angle
  
6. compress the Mod and move to FS Mod folder
7. test it
