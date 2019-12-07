
function AutoDrive:dijkstraLiveLongLine(current_in, linked_in, target_id)
	local current = current_in
	local linked = linked_in
	local newdist = 0
	local distanceToAdd = 0;
	local angle = 0;
	local current_pre = 0

	if
		AutoDrive.mapWayPoints[linked].incoming ~= nil
		and AutoDrive.mapWayPoints[linked].out ~= nil
		and #AutoDrive.mapWayPoints[linked].incoming == 1
		and #AutoDrive.mapWayPoints[linked].out == 1
	then
		if nil == AutoDrive.dijkstraCalc.distance[current] then
			AutoDrive.dijkstraCalc.distance[current] = 10000000
		end
		newdist = AutoDrive.dijkstraCalc.distance[current]
		while
			#AutoDrive.mapWayPoints[linked].incoming == 1
			and #AutoDrive.mapWayPoints[linked].out == 1
			and not (linked == target_id)
		do
			distanceToAdd = 0;
			angle = 0;
			if nil == AutoDrive.dijkstraCalc.pre[current] then
				AutoDrive.dijkstraCalc.pre[current] = -1
			end
			if AutoDrive.setting_useFastestRoute == true then
				if AutoDrive.dijkstraCalc.pre[current] ~= nil and AutoDrive.dijkstraCalc.pre[current] ~= -1 then
					distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(current, linked, AutoDrive.dijkstraCalc.pre[current],nil,false);
				else
					distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(current, linked, nil,nil,false);
				end
			else
				distanceToAdd = AutoDrive:getDistanceBetweenNodes(current, linked);
				if AutoDrive.dijkstraCalc.pre[current] ~= nil and AutoDrive.dijkstraCalc.pre[current] ~= -1 then
					local wp_current = AutoDrive.mapWayPoints[current]
					local wp_ahead = AutoDrive.mapWayPoints[linked]
					local wp_ref = AutoDrive.mapWayPoints[AutoDrive.dijkstraCalc.pre[current]]
					angle = AutoDrive.angleBetween({x = wp_ahead.x - wp_current.x, z = wp_ahead.z - wp_current.z}, {x = wp_current.x - wp_ref.x, z = wp_current.z - wp_ref.z})
					angle = math.abs(angle)
				else
					angle = 0
				end
			end;

			if math.abs(angle) > 90 then
				newdist = 10000000;
			end;
			newdist = newdist + distanceToAdd

			AutoDrive.dijkstraCalc.pre[linked] = current

			current = linked
			linked = AutoDrive.mapWayPoints[current].out[1]

			if nil == AutoDrive.dijkstraCalc.pre[linked] then
				AutoDrive.dijkstraCalc.pre[linked] = -1
			end
			current_pre = AutoDrive.dijkstraCalc.pre[linked]

		end		-- while...

		distanceToAdd = 0;
		angle = 0;
		if nil == AutoDrive.dijkstraCalc.pre[current] then
			AutoDrive.dijkstraCalc.pre[current] = -1
		end
		if AutoDrive.setting_useFastestRoute == true then
			if AutoDrive.dijkstraCalc.pre[current] ~= nil and AutoDrive.dijkstraCalc.pre[current] ~= -1 then
				distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(current, linked, AutoDrive.dijkstraCalc.pre[current],nil,false);
			else
				distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(current, linked, nil,nil,false);
			end
		else
			distanceToAdd = AutoDrive:getDistanceBetweenNodes(current, linked);
			if AutoDrive.dijkstraCalc.pre[current] ~= nil and AutoDrive.dijkstraCalc.pre[current] ~= -1 then
				local wp_current = AutoDrive.mapWayPoints[current]
				local wp_ahead = AutoDrive.mapWayPoints[linked]
				local wp_ref = AutoDrive.mapWayPoints[AutoDrive.dijkstraCalc.pre[current]]
				angle = AutoDrive.angleBetween({x = wp_ahead.x - wp_current.x, z = wp_ahead.z - wp_current.z}, {x = wp_current.x - wp_ref.x, z = wp_current.z - wp_ref.z})
				angle = math.abs(angle)
			else
				angle = 0
			end
		end;
		if math.abs(angle) > 90 then
			newdist = 10000000;
		end;
		newdist = newdist + distanceToAdd

		if nil == AutoDrive.dijkstraCalc.distance[linked] then
			AutoDrive.dijkstraCalc.distance[linked] = 10000000
		end
		if nil == AutoDrive.dijkstraCalc.pre[linked] then
			AutoDrive.dijkstraCalc.pre[linked] = -1
		end
		if newdist < AutoDrive.dijkstraCalc.distance[linked] then
			AutoDrive.dijkstraCalc.distance[linked] = newdist;
			AutoDrive.dijkstraCalc.pre[linked] = current;

			if #AutoDrive.mapWayPoints[linked].out > 0 then
				AutoDrive.dijkstraCalc.Q.dummy_id = AutoDrive.dijkstraCalc.Q.dummy_id + 1
				table.insert(AutoDrive.dijkstraCalc.Q,1,AutoDrive.dijkstraCalc.Q.dummy_id)
				AutoDrive.dijkstraCalc.Q[1] = linked
			end
		else
			if current_pre ~= 0 then
				AutoDrive.dijkstraCalc.pre[linked] = current_pre
			end
		end;

		if linked == target_id then
			return true, true;
		end ;

		return true, false;	
	else
		return false, false;
	end	-- if...
end

function AutoDrive:dijkstraLive(start,target)
	local distanceToAdd = 0;
	local angle = 0;
	local result = false
	local target_found = false

	if 
		start == nil or start == 0 or start == -1
		or target == nil or target == 0 or target == -1
	then
		return false
	end

	AutoDrive:dijkstraLiveInit(start);

	if nil ~= AutoDrive.getSetting("useFastestRoute") then
		AutoDrive.setting_useFastestRoute = AutoDrive.getSetting("useFastestRoute")
	end

	while next(AutoDrive.dijkstraCalc.Q,nil) ~= nil do
		local shortest = 10000000;
		local shortest_id = -1;
		for i, element_wp in ipairs(AutoDrive.dijkstraCalc.Q) do
			if nil == AutoDrive.dijkstraCalc.distance[AutoDrive.dijkstraCalc.Q[i]] then
				AutoDrive.dijkstraCalc.distance[AutoDrive.dijkstraCalc.Q[i]] = 10000000
			end
			if AutoDrive.dijkstraCalc.distance[AutoDrive.dijkstraCalc.Q[i]] < shortest then
				shortest = AutoDrive.dijkstraCalc.distance[AutoDrive.dijkstraCalc.Q[i]];
				shortest_id = AutoDrive.dijkstraCalc.Q[i];
				shortest_index = i;
			end;
			if AutoDrive.dijkstraCalc.distance[AutoDrive.dijkstraCalc.Q[i]] >= 10000000 then
				break;
			end
		end;

		if shortest_id == target then
			return true;
		end

		table.remove(AutoDrive.dijkstraCalc.Q,shortest_index)

		if shortest_id == -1 then
			AutoDrive.dijkstraCalc.Q = {};
		else
			if AutoDrive.dijkstraCalc.Q[shortest_index] ~= nil then
				if #AutoDrive.mapWayPoints[shortest_id].out > 0 then
					for i, linkedNodeId in pairs(AutoDrive.mapWayPoints[shortest_id].out) do

						local wp = AutoDrive.mapWayPoints[linkedNodeId]

						if wp ~= nil then
							result = false
							target_found = false
							result, target_found = AutoDrive:dijkstraLiveLongLine(shortest_id, linkedNodeId, target, shortest_index)

							if target_found == true then
								return true
							end

							if result ~= true then
								distanceToAdd = 0;
								angle = 0;
								if nil == AutoDrive.dijkstraCalc.pre[shortest_id] then
									AutoDrive.dijkstraCalc.pre[shortest_id] = -1
								end
								if AutoDrive.setting_useFastestRoute == true then
									if AutoDrive.dijkstraCalc.pre[shortest_id] ~= nil and AutoDrive.dijkstraCalc.pre[shortest_id] ~= -1 then
										distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(shortest_id, linkedNodeId, AutoDrive.dijkstraCalc.pre[shortest_id],nil,false);
									else
										distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(shortest_id, linkedNodeId, nil,nil,false);
									end
								else
									distanceToAdd = AutoDrive:getDistanceBetweenNodes(shortest_id, linkedNodeId);
									if AutoDrive.dijkstraCalc.pre[shortest_id] ~= nil and AutoDrive.dijkstraCalc.pre[shortest_id] ~= -1 then
										local wp_current = AutoDrive.mapWayPoints[shortest_id]
										local wp_ahead = AutoDrive.mapWayPoints[linkedNodeId]
										local wp_ref = AutoDrive.mapWayPoints[AutoDrive.dijkstraCalc.pre[shortest_id]]
										angle = AutoDrive.angleBetween({x = wp_ahead.x - wp_current.x, z = wp_ahead.z - wp_current.z}, {x = wp_current.x - wp_ref.x, z = wp_current.z - wp_ref.z})
										angle = math.abs(angle)
									else
										angle = 0
									end
								end;
								local alternative = shortest + distanceToAdd;
								if math.abs(angle) > 90 then
									alternative = 10000000;
								end;

								if nil == AutoDrive.dijkstraCalc.distance[linkedNodeId] then
									AutoDrive.dijkstraCalc.distance[linkedNodeId] = 10000000
								end
								if nil == AutoDrive.dijkstraCalc.pre[linkedNodeId] then
									AutoDrive.dijkstraCalc.pre[linkedNodeId] = -1
								end

								if alternative < AutoDrive.dijkstraCalc.distance[linkedNodeId] then
									AutoDrive.dijkstraCalc.distance[linkedNodeId] = alternative;
									AutoDrive.dijkstraCalc.pre[linkedNodeId] = shortest_id;

									AutoDrive.dijkstraCalc.Q.dummy_id = AutoDrive.dijkstraCalc.Q.dummy_id + 1

									table.insert(AutoDrive.dijkstraCalc.Q,1,AutoDrive.dijkstraCalc.Q.dummy_id)

									AutoDrive.dijkstraCalc.Q[1] = linkedNodeId
								end;
							end
						end;		-- if wp ~= nil then
						if linkedNodeId == target then
							return true
						end ;
					end;	-- for i, linkedNodeId in pairs...
				end -- if
			end; -- if AutoDrive.dijkstraCalc.Q[shortest_id] ~= nil then
		end;
	end;

	if next(AutoDrive.dijkstraCalc.Q,nil) == nil then
		return true
	end;

	return false;
end;

function AutoDrive:dijkstraLiveInit(start)

	if AutoDrive.setting_useFastestRoute == nil then
		-- AutoDrive.setting_useFastestRoute = true
		AutoDrive.setting_useFastestRoute = false
	end;

	if AutoDrive.dijkstraCalc == nil then
		AutoDrive.dijkstraCalc = {};
	end;

	AutoDrive.dijkstraCalc.distance = {};
	AutoDrive.dijkstraCalc.pre = {};

	AutoDrive.dijkstraCalc.Q = {};
	AutoDrive.dijkstraCalc.Q.dummy_id = 1000000

	AutoDrive.dijkstraCalc.Q.dummy_id = AutoDrive.dijkstraCalc.Q.dummy_id + 1
	table.insert(AutoDrive.dijkstraCalc.Q,1,AutoDrive.dijkstraCalc.Q.dummy_id)

	AutoDrive.dijkstraCalc.distance[start] = 0;
	if nil == AutoDrive.dijkstraCalc.pre[start] then
		AutoDrive.dijkstraCalc.pre[start] = -1
	end

	table.insert(AutoDrive.dijkstraCalc.Q,1,start)
end;

--[[
Graph - AutoDrive.mapWayPoints
start_id - Waypoint ID of start point of the route
target_id_id - Waypoint ID of target point of the route

return values:
1.	empty table {}, if 
    - start_id and / or target_id out of valid range (1..n), i.e. nil, 0, -1
	- something with route calculation is not working
	- route calculation from start_id not possible to target_id, i.e. track(s) is/are not connected inbetween start_id and target_id
	- more than 50000 waypoints for a route, this is assumed as no practical use case
2.	table with only 1 waypoint if start_id == target_id, same as in AutoDrive:FastShortestPath
3.	table with waypoints from start_id to target_id including start_id and target_id
]]
function AutoDrive:dijkstraLiveShortestPath(Graph,start_id,target_id)
	local ret = false
	ret = AutoDrive:dijkstraLive(start_id,target_id)
	if false == ret then
		return {};  --something went wrong
	end
	local wp = {};
	local count = 1;
	local id = target_id;

	while (AutoDrive.dijkstraCalc.pre[id] ~= -1 and id ~= nil) or id == start_id do
		table.insert(wp, 1, Graph[id]);
		count = count+1;
		if id == start_id then
			id = nil;
		else
			if AutoDrive.dijkstraCalc.pre[id] ~= nil and
				AutoDrive.dijkstraCalc.pre[id] ~= -1 then
				id = AutoDrive.dijkstraCalc.pre[id];
			else	-- invalid Route -> keep Vehicle at start point
--				print(string.format("Axel: AutoDrive:dijkstraLiveShortestPath ERROR invalid Route count = %d -> keep Vehicle at start point",count))
-- TODO: message to user route not calculateable
				return {};
			end;
		end;
		if count > 50000 then
			print(string.format("Axel: AutoDrive:dijkstraLiveShortestPath ERROR count > 50000"))
			return {};  --something went wrong. prevent overflow here
		end;
	end;

	return wp;
end;

function AutoDrive:FastShortestPath(Graph,start,markerName, markerID)	
	local wp = {};
	local start_id = start;
	local target_id = 0;

	if start_id == nil or start_id == 0 then
		return wp
	end

	for i in pairs(AutoDrive.mapMarker) do
		if AutoDrive.mapMarker[i].name == markerName then
			target_id = AutoDrive.mapMarker[i].id
			break;
		end
	end;

	if target_id == 0 then
		return wp
	end

	if target_id == start_id then
		table.insert(wp, 1, Graph[target_id]);
		return wp
	end

	wp = AutoDrive:dijkstraLiveShortestPath(Graph,start_id,target_id)

	return wp
end;


print("FS19_AutoDriveLive V 0.0.0.6 by Axel")