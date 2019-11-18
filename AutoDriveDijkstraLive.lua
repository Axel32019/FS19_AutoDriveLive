-- enabledijkstralivedebug = true
function AutoDrive:dijkstraLiveLongLine(current_in, linked_in, target_id, shortest_Q_ind)
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
					distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(current, linked, AutoDrive.dijkstraCalc.pre[current],nil,true);
				else
					distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(current, linked, nil,nil,true);
				end
			else
				distanceToAdd = AutoDrive:getDistanceBetweenNodes(current, linked);
			end;

			if math.abs(angle) > 90 then
				distanceToAdd = 10000000;
			end;
			newdist = newdist + distanceToAdd

			AutoDrive.dijkstraCalc.pre[linked] = current

			current = linked
			linked = AutoDrive.mapWayPoints[current].out[1]
			current_pre = AutoDrive.dijkstraCalc.pre[linked]

		end		-- while...

		distanceToAdd = 0;
		angle = 0;
		if nil == AutoDrive.dijkstraCalc.pre[current] then
			AutoDrive.dijkstraCalc.pre[current] = -1
		end
		if AutoDrive.setting_useFastestRoute == true then
			if AutoDrive.dijkstraCalc.pre[current] ~= nil and AutoDrive.dijkstraCalc.pre[current] ~= -1 then
				distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(current, linked, AutoDrive.dijkstraCalc.pre[current],nil,true);
			else
				distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(current, linked, nil,nil,true);
			end
		else
			distanceToAdd = AutoDrive:getDistanceBetweenNodes(current, linked);
		end;
		if math.abs(angle) > 90 then
			distanceToAdd = 10000000;
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

function AutoDrive:dijkstraLive(Graph,start,setToUse,target)
	local distanceToAdd = 0;
	local angle = 0;
	local result = false
	local target_found = false
	local setting_useFastestRoute = AutoDrive:getSetting("useFastestRoute")

	if 
		Graph == nil
		or start == nil or start == 0 or start == -1
		or setToUse == nil
		or target == nil or target == 0 or target == -1
	then
		return false
	end

	AutoDrive:dijkstraLiveInit(Graph, start, setToUse);

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
			return true; -- AutoDrive.dijkstraCalc;
		end

		table.remove(AutoDrive.dijkstraCalc.Q,shortest_index)

		if shortest_id == -1 then
			AutoDrive.dijkstraCalc.Q = {};
		else
			if AutoDrive.dijkstraCalc.Q[shortest_index] ~= nil then
				if #AutoDrive.mapWayPoints[shortest_id].out > 0 then
					for i, linkedNodeId in pairs(AutoDrive.mapWayPoints[shortest_id].out) do
						if linkedNodeId == shortest_id then break end		-- buggy for... gives own result

						local wp = AutoDrive.mapWayPoints[linkedNodeId]

						if wp ~= nil then
							result = false
							target_found = false
							result, target_found = AutoDrive:dijkstraLiveLongLine(shortest_id, linkedNodeId, target, shortest_index)

							if target_found == true then
								return true -- AutoDrive.dijkstraCalc;
							end

							if result ~= true then
								distanceToAdd = 0;
								angle = 0;
								if nil == AutoDrive.dijkstraCalc.pre[shortest_id] then
									AutoDrive.dijkstraCalc.pre[shortest_id] = -1
								end
								if setting_useFastestRoute == true then
									if AutoDrive.dijkstraCalc.pre[shortest_id] ~= nil and AutoDrive.dijkstraCalc.pre[shortest_id] ~= -1 then
										distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(shortest_id, linkedNodeId, AutoDrive.dijkstraCalc.pre[shortest_id],nil,true);
									else
										distanceToAdd, angle = AutoDrive:getDriveTimeBetweenNodes(shortest_id, linkedNodeId, nil,nil,true);
									end
								else
									distanceToAdd = AutoDrive:getDistanceBetweenNodes(shortest_id, linkedNodeId);
								end;

								if math.abs(angle) > 90 then
									distanceToAdd = 10000000;
								end;

								local alternative = shortest + distanceToAdd;

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
							return true -- AutoDrive.dijkstraCalc;
						end ;
					end;	-- for i, linkedNodeId in pairs...
				end -- if
			end;		-- if AutoDrive.dijkstraCalc.Q[shortest_id] ~= nil then
		end;
	end;

	if next(AutoDrive.dijkstraCalc.Q,nil) == nil then
		return true -- AutoDrive.dijkstraCalc;
	end;

	return false;
end;

function AutoDrive:dijkstraLiveInit(Graph, start, setToUse)

	if AutoDrive.dijkstraCalc == nil then
		AutoDrive.dijkstraCalc = {};
	end;

	AutoDrive.dijkstraCalc.distance = {};
	AutoDrive.dijkstraCalc.pre = {};

	AutoDrive.dijkstraCalc.Q = {};
	AutoDrive.dijkstraCalc.Q.dummy_id = 1000000

--[[
	for i, point in pairs(Graph) do
		-- AutoDrive.dijkstraCalc.Q[i] = point.id;
		-- AutoDrive.dijkstraCalc.distance[i] = 10000000
		-- AutoDrive.dijkstraCalc.pre[i] = -1;
	end;
]]
	AutoDrive.dijkstraCalc.Q.dummy_id = AutoDrive.dijkstraCalc.Q.dummy_id + 1
	table.insert(AutoDrive.dijkstraCalc.Q,1,AutoDrive.dijkstraCalc.Q.dummy_id)

	AutoDrive.dijkstraCalc.distance[start] = 0;

	table.insert(AutoDrive.dijkstraCalc.Q,1,start)

end;

function AutoDrive:dijkstraLiveShortestPath(Graph,start_id,target_id)
	local ret = false
	ret = AutoDrive:dijkstraLive(Graph,start_id,"out",target_id)
	if false == ret then
		return {};  --something went wrong
	end
	local wp = {};
	local count = 1;
	local id = target_id;

	while AutoDrive.dijkstraCalc.pre[id] ~= -1 and id ~= nil do
		table.insert(wp, 1, Graph[id]);
		count = count+1;
		if id == start_id then
			id = nil;
		else
			if AutoDrive.dijkstraCalc.pre[id] ~= nil and
				AutoDrive.dijkstraCalc.pre[id] ~= -1 then
				id = AutoDrive.dijkstraCalc.pre[id];
			else
				-- print(("axel: AutoDrive:dijkstraLiveShortestPath ERROR AutoDrive.dijkstraCalc.pre[id] == nil id: %s count = %d"):format(tostring(id),count))
				id = nil;
			end;
		end;
		if count > 50000 then
			print(string.format("axel: AutoDrive:dijkstraLiveShortestPath ERROR count > 50000"))
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

	if enabledijkstralivedebug then
		if getDate ~= nil then print(("axel: AutoDrive:FastShortestPath start %s"):format(getDate("%H:%M:%S"))) end
	end

	wp = AutoDrive:dijkstraLiveShortestPath(Graph,start_id,target_id)

	if enabledijkstralivedebug then
		if getDate ~= nil then print(("axel: AutoDrive:FastShortestPath end %s"):format(getDate("%H:%M:%S"))) end
	end
	return wp
end;


print("FS19_AutoDriveLive V 0.0.0.3 by axel")